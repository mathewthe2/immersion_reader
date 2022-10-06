import 'dictionary.dart';
import 'vocabulary.dart';
import 'deinflector.dart';
import 'pitch.dart';
// import 'dart:developer';

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

  Future<List<List<String>>> getTags(String term, String reading) async {
    List<Vocabulary> vocabs = await dictionary.findTerm(term, reading: reading);
    return vocabs
        .map((Vocabulary vocabulary) => vocabulary.tags ?? [])
        .toList();
  }

  Future<List<Vocabulary>> findTerm(String text,
      {wildcards = false, reading = '', getPitch = true}) async {
    if (wildcards) {
      // do sth here
    }
    Map<int, Vocabulary> groups = {};
    for (int i = text.length; i > 0; i--) {
      String term = text.substring(0, i);
      List<DeinflectedTerm> dfs = await deinflector.deinflect(
          term, (String customTerm) => getTags(customTerm, reading));
      for (DeinflectedTerm df in dfs) {
        groups = await processTerm(groups,
            source: df.source,
            root: df.root,
            rules: df.rules,
            tags: df.tags,
            wildcards: wildcards,
            reading: reading);
      }
    }
    List<Vocabulary> definitions = groups.values.toList();

    // get pitch svg
    if (getPitch) {
      for (Vocabulary definition in definitions) {
        definition.pitchSvg = await pitch.getSvg(definition.expression ?? '',
            reading: definition.reading ?? '');
      }
    }

    definitions.sort((a, b) => <Comparator<Vocabulary>>[
          (o1, o2) => o1.source!.length.compareTo(o2.source!.length),
          (o1, o2) => (o1.tags!.contains('P') ? 1 : 0)
              .compareTo((o2.tags!.contains('P') ? 1 : 0)),
          (o1, o2) => (-o1.rules!.length).compareTo(-o2.rules!.length),
          (o1, o2) => o1.expression!.compareTo(o2.expression!)
        ].map((e) => e(a, b)).firstWhere((e) => e != 0, orElse: () => 0));
    definitions = definitions.reversed.toList();
    return definitions;
  }

  Future<Map<int, Vocabulary>> processTerm(Map<int, Vocabulary> groups,
      {source,
      List<String> tags = const [],
      rules,
      root = '',
      reading = '',
      wildcards = false}) async {
    List<Vocabulary> entries =
        await dictionary.findTerm(root, wildcards: wildcards, reading: reading);
    for (Vocabulary entry in entries) {
      if (groups.containsKey(entry.id)) {
        continue;
      }
      bool matched = tags.isEmpty;
      for (String tag in tags) {
        if (entry.tags != null && entry.tags!.contains(tag)) {
          matched = true;
          break;
        }
      }
      if (matched) {
        entry.source = source;
        entry.rules = rules;
        groups[entry.id!] = entry;
      }
    }
    // inspect(groups);
    return groups;
  }
}
