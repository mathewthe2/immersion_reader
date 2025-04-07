import 'dart:math';

import 'package:immersion_reader/dictionary/frequency_tag.dart';
import 'package:immersion_reader/japanese/frequency.dart';
import 'package:immersion_reader/japanese/search_term.dart';
import 'package:kana_kit/kana_kit.dart';
import 'dictionary.dart';
import 'vocabulary.dart';
import 'deinflector.dart';
import 'pitch.dart';
import 'package:immersion_reader/dictionary/dictionary_entry.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/data/search/search_result.dart';
import 'package:immersion_reader/storage/settings_storage.dart';

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
  late Dictionary dictionary;
  late Deinflector deinflector;
  late Pitch pitch;
  late Frequency frequency;
  SettingsStorage? settingsStorage;

  static final Translator _singleton = Translator._internal();
  Translator._internal();

  static Translator create(SettingsStorage settingsStorage) {
    _singleton.dictionary = Dictionary.create(settingsStorage);
    _singleton.pitch = Pitch.create(settingsStorage);
    _singleton.frequency = Frequency.create(settingsStorage);
    _singleton.deinflector = Deinflector();
    _singleton.settingsStorage = settingsStorage;
    return _singleton;
  }

  static const int longestScanLength =
      20; // assuming longest deinflected entry is < 20 characters

  Future<List<Vocabulary>> _findGlossaryTerms(String text,
      {DictionaryOptions? options}) async {
    options ??= DictionaryOptions();
    List<Vocabulary> glossaryTerms = await findTermFromGlossary(text);
    if (glossaryTerms.isNotEmpty) {
      if (options.pitchAccentDisplayStyle != PitchAccentDisplayStyle.none) {
        glossaryTerms = await _batchAddPitch(
            glossaryTerms, options.pitchAccentDisplayStyle);
      }
      if (options.isGetFrequencyTags) {
        glossaryTerms = await _batchAddFrequencyTags(glossaryTerms);
      }
      return glossaryTerms;
    } else {
      return [];
    }
  }

  Future<SearchResult> findTermForUserSearch(String text,
      {DictionaryOptions? options}) async {
    options ??= DictionaryOptions();
    List<Vocabulary> exactMatches = [];
    List<Vocabulary> additionalMatches = [];
    List<Vocabulary> glossaryExactMatches =
        []; // translated matches from bilingual dictionaries
    List<Vocabulary> glossaryAdditionalMatches =
        []; // translated matches from bilingual dictionaries
    KanaKit kanaKit = const KanaKit();
    String parsedText = text.trim(); // to do: handle half width characters
    if (!kanaKit.isJapanese(parsedText)) {
      List<Vocabulary> glossaryTerms =
          await _findGlossaryTerms(parsedText.toLowerCase(), options: options);
      for (Vocabulary definition in glossaryTerms) {
        if (definition.getAllMeanings().contains(parsedText.toLowerCase())) {
          glossaryExactMatches.add(definition);
        } else {
          glossaryAdditionalMatches.add(definition);
        }
        glossaryExactMatches =
            _sortDefinitionsForUserSearch(glossaryExactMatches);
        glossaryAdditionalMatches =
            _sortDefinitionsForUserSearch(glossaryAdditionalMatches);
      }
      parsedText = kanaKit.toHiragana(parsedText);
    }
    options.sorted = false; // custom sort later
    List<Vocabulary> results = await findTerm(parsedText, options: options);
    results = _sortDefinitionsForUserSearch(results);
    for (Vocabulary result in results) {
      if (result.reading == parsedText || result.expression == parsedText) {
        exactMatches.add(result);
      } else {
        additionalMatches.add(result);
      }
    }

    return SearchResult(exactMatches: [
      ...exactMatches,
      ...glossaryExactMatches
    ], additionalMatches: [
      ...glossaryAdditionalMatches,
      ...additionalMatches
    ]);
  }

  Future<List<Vocabulary>> findTermFromGlossary(String text) async {
    return await dictionary.getVocabularyFromMeaning(text);
  }

  Future<List<Vocabulary>> findTerm(String text,
      {bool wildcards = false,
      String reading = '',
      DictionaryOptions? options}) async {
    options ??= DictionaryOptions();
    List<TranslatorDeinflection> deinflections = [];
    text = text.substring(0, min(longestScanLength, text.length));
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
        uniqueDeinflectionTerms.add(term);
        uniqueDeinflectionArrays.add(deinflectionArray);
        uniqueDeinflectionsMap[term] = deinflectionArray;
      }
      deinflectionArray.add(deinflection);
    }

    List<DictionaryEntry> entries = await dictionary.findTermsBulk(
        uniqueDeinflectionTerms,
        isHaveDisabledDictionaries: options.disabledDictionaryIds.isNotEmpty);

    List<DictionaryEntry> finalEntries = [];
    for (DictionaryEntry entry in entries) {
      int definitionRules = deinflector.rulesToRuleFlags(entry.meaningTags);
      for (TranslatorDeinflection deinflection
          in uniqueDeinflectionArrays[entry.index!]) {
        int deinflectionRules = deinflection.rules;
        if (deinflectionRules == 0 ||
            (definitionRules & deinflectionRules) != 0) {
          deinflection.databaseEntries.add(entry);
          // match corresponding deinflector with transformed text here
          // take the longest transformed text
          // further improvement: still edge cases to be fixed
          if ([entry.term, entry.reading]
                  .contains(deinflection.deinflectedText) &&
              (entry.transformedText == null ||
                  deinflection.transformedText.length >
                      entry.transformedText!.length)) {
            if (entry.term == deinflection.transformedText) {
              entry.sourceTermExactMatchCount += 1;
            }
            entry.transformedText = deinflection.transformedText;
          }
          finalEntries.add(entry);
        }
      }
    }

    // int originalTextLength = 0;
    var ids = <int>{};
    for (TranslatorDeinflection deinflection in deinflections) {
      if (deinflection.databaseEntries.isEmpty) {
        continue;
      }
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

    List<Vocabulary> definitions =
        await dictionary.getVocabularyBatch(finalEntries);

    // get pitch svg
    if (options.pitchAccentDisplayStyle != PitchAccentDisplayStyle.none) {
      definitions =
          await _batchAddPitch(definitions, options.pitchAccentDisplayStyle);
    }
    if (options.isGetFrequencyTags) {
      definitions = await _batchAddFrequencyTags(definitions);
    }
    if (options.sorted) {
      definitions = _sortDefinitionsForTermSearch(definitions);
    }
    return definitions;
  }

  Future<List<Vocabulary>> _batchAddPitch(List<Vocabulary> definitions,
      PitchAccentDisplayStyle pitchAccentDisplayStyle) async {
    final pitchesBatch = await pitch.makePitchesBatch(definitions,
        pitchAccentDisplayStyle: pitchAccentDisplayStyle);
    for (final (int i, Vocabulary definition) in definitions.indexed) {
      definition.pitchAccentDisplayStyle = pitchAccentDisplayStyle;
      definition.pitchValues = pitchesBatch[i];
    }
    return definitions;
  }

  Future<List<Vocabulary>> _batchAddFrequencyTags(
      List<Vocabulary> definitions) async {
    List<SearchTerm> searchTerms = definitions
        .map((definition) => SearchTerm(
            text: definition.expression ?? '',
            reading: definition.reading ?? ''))
        .toList();
    List<List<FrequencyTag>> frequencyTagsResult =
        await frequency.getFrequencyBatch(searchTerms);
    for (int i = 0; i < definitions.length; i++) {
      definitions[i].frequencyTags = frequencyTagsResult[i];
    }
    return definitions;
  }

  List<Vocabulary> _sortDefinitionsForTermSearch(List<Vocabulary> definitions) {
    // to do: update sorting based on yomichan:
    // https://github.com/FooSoft/yomichan/blob/f3024c50186344aa6a6b09500ea02540463ce5c9/ext/js/language/translator.js#L1364
    definitions.sort((a, b) => <Comparator<Vocabulary>>[
          (o1, o2) => o1.maxTransformedTextLength
              .compareTo(o2.maxTransformedTextLength),
          (o1, o2) => o1.sourceTermExactMatchCount
              .compareTo(o2.sourceTermExactMatchCount),
          (o1, o2) => o1.getPopularity().compareTo(o2.getPopularity()),
          (o1, o2) => (o1.tags!.contains('P') ? 1 : 0)
              .compareTo((o2.tags!.contains('P') ? 1 : 0)),
          (o1, o2) => (-o1.rules.length).compareTo(-o2.rules.length),
          (o1, o2) => o1.expression!.compareTo(o2.expression!)
        ].map((e) => e(a, b)).firstWhere((e) => e != 0, orElse: () => 0));
    definitions = definitions.reversed.toList();
    return definitions;
  }

  List<Vocabulary> _sortDefinitionsForUserSearch(List<Vocabulary> definitions) {
    // ranking based on popularity first then length
    definitions.sort((a, b) => <Comparator<Vocabulary>>[
          (o1, o2) => o1.sourceTermExactMatchCount
              .compareTo(o2.sourceTermExactMatchCount),
          (o1, o2) => o1.getPopularity().compareTo(o2.getPopularity()),
          (o1, o2) => (o1.tags!.contains('P') ? 1 : 0)
              .compareTo((o2.tags!.contains('P') ? 1 : 0)),
          (o1, o2) => (-o1.rules.length).compareTo(-o2.rules.length),
          (o1, o2) => o1.expression!.compareTo(o2.expression!),
          (o1, o2) => o1.expression!.length.compareTo(o2.expression!.length)
        ].map((e) => e(a, b)).firstWhere((e) => e != 0, orElse: () => 0));
    definitions = definitions.reversed.toList();
    return definitions;
  }
}
