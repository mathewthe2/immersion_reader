import 'package:immersion_reader/data/search/search_history_item.dart';
import 'package:immersion_reader/data/search/search_result.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/languages/abstract_translator.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/storage/settings_storage.dart';

class DictionaryManager {
  late SettingsStorage settingsStorage;
  List<int>? disabledDictionaryIds;
  bool? isShowFrequencyTags;
  AbstractTranslator? translator;

  static final DictionaryManager _singleton = DictionaryManager._internal();
  DictionaryManager._internal();

  factory DictionaryManager.create(SettingsStorage settingsStorage) {
    _singleton.translator = AbstractTranslator.create(
      lookupLanguage:
          settingsStorage.settingsCache!.generalSetting.lookupLanguage,
      settingsStorage: settingsStorage,
    );
    _singleton.settingsStorage = settingsStorage;
    return _singleton;
  }

  factory DictionaryManager() => _singleton;

  void updateLookupLanguage(LookupLanguage lookupLanguage) {
    translator = AbstractTranslator.create(
      lookupLanguage: lookupLanguage,
      settingsStorage: settingsStorage,
    );
  }

  Future<DictionaryOptions> getOptions() async {
    return DictionaryOptions(
      disabledDictionaryIds: await getDisabledDictionaryIds(),
      pitchAccentDisplayStyle: await SettingsManager().getPitchAccentStyle(),
      isGetFrequencyTags: await SettingsManager().getIsShowFrequencyTags(),
    );
  }

  Future<List<Vocabulary>> findTerm(String text) async {
    return await translator!.findTerm(text, options: await getOptions());
  }

  Future<SearchResult> findTermForUserSearch(String text) async {
    return await translator!.findTermForUserSearch(
      text,
      options: await getOptions(),
    );
  }

  Future<void> addQueryToDictionaryHistory(String query) async {
    await SettingsManager().settingsStorage!.addQueryToDictionaryHistory(query);
  }

  Future<void> clearDictionaryHistory() async {
    await SettingsManager().settingsStorage!.clearDictionaryHistory();
  }

  Future<List<SearchHistoryItem>> getDictionaryHistory() async {
    return await SettingsManager().settingsStorage!
        .getDictionarySearchHistory();
  }

  Future<void> toggleDictionaryEnabled(dictionarySetting) async {
    await SettingsManager().settingsStorage!.toggleDictionaryEnabled(
      dictionarySetting,
    );
    disabledDictionaryIds = await SettingsManager().settingsStorage!
        .getDisabledDictionaryIds();
  }

  Future<List<int>> getDisabledDictionaryIds() async {
    if (disabledDictionaryIds != null) {
      return disabledDictionaryIds!;
    } else {
      disabledDictionaryIds = await SettingsManager().settingsStorage!
          .getDisabledDictionaryIds();
      return disabledDictionaryIds!;
    }
  }
}
