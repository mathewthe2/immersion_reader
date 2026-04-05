import 'dart:math';
import 'package:immersion_reader/data/search/search_result.dart';
import 'package:immersion_reader/dictionary/dictionary_entry.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/languages/abstract_translator.dart';
import 'package:immersion_reader/languages/common/translator_deinflection.dart';
import 'package:immersion_reader/languages/common/dictionary.dart';
import 'package:immersion_reader/languages/common/vocabulary.dart';
import 'package:immersion_reader/languages/korean/korean_deinflector.dart';
import 'package:immersion_reader/storage/settings_storage.dart';

class KoreanTranslator extends AbstractTranslator {
  late Dictionary dictionary;
  late KoreanDeinflector deinflector;

  SettingsStorage? settingsStorage;

  static final KoreanTranslator _singleton = KoreanTranslator._internal();
  KoreanTranslator._internal();

  static KoreanTranslator create(SettingsStorage settingsStorage) {
    _singleton.dictionary = Dictionary.create(settingsStorage);
    _singleton.deinflector = KoreanDeinflector();
    _singleton.settingsStorage = settingsStorage;
    return _singleton;
  }

  static const int longestScanLength = 20;

  @override
  Future<void> init() async {}

  @override
  Future<SearchResult> findTermForUserSearch(
    String text, {
    DictionaryOptions? options,
  }) async {
    final parsedText = text.trim().toLowerCase();

    List<Vocabulary> results = await findTerm(parsedText, options: options);
    List<Vocabulary> exactMatches = [];
    List<Vocabulary> additionalMatches = [];

    for (Vocabulary result in results) {
      if (result.reading == parsedText || result.expression == parsedText) {
        exactMatches.add(result);
      } else {
        additionalMatches.add(result);
      }
    }

    return SearchResult(
      exactMatches: exactMatches,
      additionalMatches: additionalMatches,
    );
  }

  @override
  Future<List<Vocabulary>> findTerm(
    String text, {
    bool wildcards = false,
    String reading = '',
    DictionaryOptions? options,
  }) async {
    options ??= DictionaryOptions();
    List<TranslatorDeinflection> deinflections = [];
    text = text.substring(0, min(longestScanLength, text.length));
    for (int i = text.length; i > 0; i--) {
      String term = text.substring(0, i);
      List<KoreanDeinflection> dfs = deinflector.deinflect(term);
      for (KoreanDeinflection df in dfs) {
        deinflections.add(
          TranslatorDeinflection(
            originalText: text,
            transformedText: term,
            deinflectedText: df.term,
            rules: df.rules,
            reasons: df.reasons,
            databaseEntries: [],
          ),
        );
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
      isHaveDisabledDictionaries: options.disabledDictionaryIds.isNotEmpty,
    );

    List<DictionaryEntry> finalEntries = [];
    for (DictionaryEntry entry in entries) {
      for (TranslatorDeinflection deinflection
          in uniqueDeinflectionArrays[entry.index!]) {
        // TODO: do some filtering with deinflection rules here
        deinflection.databaseEntries.add(entry);
        if ([
              entry.term,
              entry.reading,
            ].contains(deinflection.deinflectedText) &&
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

    var ids = <int>{};
    for (TranslatorDeinflection deinflection in deinflections) {
      if (deinflection.databaseEntries.isEmpty) {
        continue;
      }
      for (DictionaryEntry databaseEntry in deinflection.databaseEntries) {
        int id = databaseEntry.id!;
        if (ids.contains(id)) {
          continue;
        }
        finalEntries.add(databaseEntry);
        ids.add(id);
      }
    }

    List<Vocabulary> definitions = await dictionary.getVocabularyBatch(
      finalEntries,
    );
    return definitions;
  }
}
