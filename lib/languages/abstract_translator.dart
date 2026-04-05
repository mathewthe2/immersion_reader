import 'package:immersion_reader/data/search/search_result.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/languages/chinese/chinese_translator.dart';
import 'package:immersion_reader/languages/japanese/japanese_translator.dart';
import 'package:immersion_reader/languages/common/vocabulary.dart';
import 'package:immersion_reader/languages/english/english_translator.dart';
import 'package:immersion_reader/storage/settings_storage.dart';

abstract class AbstractTranslator {
  static AbstractTranslator create({
    required LookupLanguage lookupLanguage,
    required SettingsStorage settingsStorage,
  }) {
    AbstractTranslator translator;
    switch (lookupLanguage) {
      case const (LookupLanguage.zh):
        translator = ChineseTranslator.create(settingsStorage);
        break;
      case const (LookupLanguage.en):
        translator = EnglishTranslator.create(settingsStorage);
        break;
      case const (LookupLanguage.ja):
        translator = JapaneseTranslator.create(settingsStorage);
        break;
    }
    translator.init();
    return translator;
  }

  Future<SearchResult> findTermForUserSearch(
    String text, {
    DictionaryOptions? options,
  });

  Future<List<Vocabulary>> findTerm(
    String text, {
    bool wildcards = false,
    String reading = '',
    DictionaryOptions? options,
  });

  Future<void> init();
}
