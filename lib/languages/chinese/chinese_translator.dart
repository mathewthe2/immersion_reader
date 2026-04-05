import 'dart:math';
import 'package:immersion_reader/data/search/search_result.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/languages/abstract_translator.dart';
import 'package:immersion_reader/languages/common/dictionary.dart';
import 'package:immersion_reader/languages/common/vocabulary.dart';
import 'package:immersion_reader/storage/settings_storage.dart';

class ChineseTranslator extends AbstractTranslator {
  late Dictionary dictionary;

  SettingsStorage? settingsStorage;

  static final ChineseTranslator _singleton = ChineseTranslator._internal();
  ChineseTranslator._internal();

  static ChineseTranslator create(SettingsStorage settingsStorage) {
    _singleton.dictionary = Dictionary.create(settingsStorage);
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
    // TODO: to implement
    return SearchResult(exactMatches: [], additionalMatches: []);
  }

  List<String> _generateCandidates(String text, int longestScanLength) {
    List<String> terms = [];

    for (int start = 0; start < text.length; start++) {
      int maxLen = min(longestScanLength, text.length - start);

      for (int len = maxLen; len > 0; len--) {
        terms.add(text.substring(start, start + len));
      }
    }

    return terms;
  }

  @override
  Future<List<Vocabulary>> findTerm(
    String text, {
    bool wildcards = false,
    String reading = '',
    DictionaryOptions? options,
  }) async {
    options ??= DictionaryOptions();

    final terms = _generateCandidates(text, longestScanLength);

    final entries = await dictionary.findTermsBulk(
      terms,
      isHaveDisabledDictionaries: options.disabledDictionaryIds.isNotEmpty,
      isOrdered: true,
    );
    final definitions = await dictionary.getVocabularyBatch(entries);
    return definitions;
  }
}
