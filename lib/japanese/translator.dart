import 'dictionary.dart';
import 'vocabulary.dart';
import 'deinflector.dart';
import 'pitch.dart';
import 'package:immersion_reader/dictionary/dictionary_entry.dart';

class TranslatorDeinflection {
  String originalText;
  String transformedText;
  String deinflectedText;
  int rules;
  List<String> reasons;
  List<DictionaryEntry> databaseEntries;

  TranslatorDeinflection(
      {required this.originalText,
      required this.transformedText,
      required this.deinflectedText,
      required this.rules,
      required this.reasons,
      required this.databaseEntries});
}

class Translator {
  Dictionary dictionary;
  Deinflector deinflector;
  Pitch pitch;

  Translator(
      {required this.dictionary,
      required this.deinflector,
      required this.pitch});

  static Future<Translator> create() async {
    Dictionary dictionary = await Dictionary.create();
    Pitch pitch = await Pitch.create();
    Translator translator = Translator(
        dictionary: dictionary, pitch: pitch, deinflector: Deinflector());
    return translator;
  }

  Future<List<Vocabulary>> findTerm(String text,
      {wildcards = false, reading = '', getPitch = true}) async {
    List<TranslatorDeinflection> deinflections = [];
    for (int i = text.length; i > 0; i--) {
      String term = text.substring(0, i);
      List<Deinflection> dfs = deinflector.deinflect(term);
      for (Deinflection df in dfs) {
        deinflections.add(TranslatorDeinflection(
            originalText: text,
            transformedText: term,
            deinflectedText: df.term,
            rules: df.rules,
            reasons: df.reasons,
            databaseEntries: []));
      }
    }
    // if (dfs.isEmpty) {
    //   return [];
    // }

    List<String> uniqueDeinflectionTerms = [];
    List<List<TranslatorDeinflection>> uniqueDeinflectionArrays = [];
    Map<String, List<TranslatorDeinflection>> uniqueDeinflectionsMap = {};
    for (TranslatorDeinflection deinflection in deinflections) {
      String term = deinflection.deinflectedText;
      List<TranslatorDeinflection> deinflectionArray =
          uniqueDeinflectionsMap.containsKey(term)
              ? uniqueDeinflectionsMap[term]!
              : [];
      if (!uniqueDeinflectionsMap.containsKey(term)) {
        List<TranslatorDeinflection> deinflectionArray = [];
        uniqueDeinflectionTerms.add(term);
        uniqueDeinflectionArrays.add(deinflectionArray);
        uniqueDeinflectionsMap[term] = deinflectionArray;
      }
      deinflectionArray.add(deinflection);
    }

    // List<DictionaryEntry> finalEntries = [];

    List<DictionaryEntry> entries =
        await dictionary.findTermsBulk(uniqueDeinflectionTerms);
    for (DictionaryEntry entry in entries) {
      int definitionRules = deinflector.rulesToRuleFlags(entry.meaningTags);
      for (TranslatorDeinflection deinflection
          in uniqueDeinflectionArrays[entry.index!]) {
        int deinflectionRules = deinflection.rules;
        if (deinflectionRules == 0 ||
            (definitionRules & deinflectionRules) != 0) {
          deinflection.databaseEntries.add(entry);
        }
      }
    }

    // int originalTextLength = 0;
    var ids = <int>{};
    List<DictionaryEntry> finalEntries = entries;
    for (TranslatorDeinflection deinflection in deinflections) {
      if (deinflection.databaseEntries.isEmpty) {
        continue;
      }
      print('got one: ');
      print(deinflection.databaseEntries.length);
      // originalTextLength =
      //     max(originalTextLength, deinflection.originalText.length);
      for (DictionaryEntry databaseEntry in deinflection.databaseEntries) {
        int id = databaseEntry.id!;
        if (ids.contains(id)) {
          continue;
        }
        finalEntries.add(databaseEntry);
        ids.add(id);
      }
    }

    // print(finalEntries.length);
    List<Vocabulary> definitions =
        await dictionary.getVocabularyBatch(finalEntries);

    // get pitch svg
    if (getPitch) {
      for (Vocabulary definition in definitions) {
        definition.pitchSvg = await pitch.getSvg(definition.expression ?? '',
            reading: definition.reading ?? '');
      }
    }

    // to do: update sorting based on yomichan:
    // https://github.com/FooSoft/yomichan/blob/f3024c50186344aa6a6b09500ea02540463ce5c9/ext/js/language/translator.js#L1364
    definitions.sort((a, b) => <Comparator<Vocabulary>>[
          (o1, o2) => o1.expression!.length.compareTo(o2.expression!.length),
          (o1, o2) => o1.getPopularity().compareTo(o2.getPopularity()),
          (o1, o2) => (o1.tags!.contains('P') ? 1 : 0)
              .compareTo((o2.tags!.contains('P') ? 1 : 0)),
          (o1, o2) => (-o1.rules!.length).compareTo(-o2.rules!.length),
          (o1, o2) => o1.expression!.compareTo(o2.expression!)
        ].map((e) => e(a, b)).firstWhere((e) => e != 0, orElse: () => 0));
    definitions = definitions.reversed.toList();
    return definitions;
  }
}
