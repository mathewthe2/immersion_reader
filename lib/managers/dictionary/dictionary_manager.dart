import 'package:immersion_reader/data/search/search_history_item.dart';
import 'package:immersion_reader/data/search/search_result.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/japanese/translator.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/storage/settings_storage.dart';

class DictionaryManager {
  List<int>? disabledDictionaryIds;
  bool? isShowFrequencyTags;
  Translator? translator;

  static final DictionaryManager _singleton = DictionaryManager._internal();
  DictionaryManager._internal();

  factory DictionaryManager.create(SettingsStorage settingsStorage) {
    _singleton.translator = Translator.create(settingsStorage);
    return _singleton;
  }

  factory DictionaryManager() => _singleton;

  Future<DictionaryOptions> getOptions() async {
    return DictionaryOptions(
        disabledDictionaryIds: await getDisabledDictionaryIds(),
        pitchAccentDisplayStyle: await SettingsManager().getPitchAccentStyle(),
        isGetFrequencyTags: await SettingsManager().getIsShowFrequencyTags());
  }

  Future<List<Vocabulary>> findTerm(String text) async {
    return await translator!.findTerm(text, options: await getOptions());
  }

  Future<SearchResult> findTermForUserSearch(String text) async {
    return await translator!
        .findTermForUserSearch(text, options: await getOptions());
  }

  Future<void> addQueryToDictionaryHistory(String query) async {
    await SettingsManager().settingsStorage!.addQueryToDictionaryHistory(query);
  }

  Future<void> clearDictionaryHistory() async {
    await SettingsManager().settingsStorage!.clearDictionaryHistory();
  }

  Future<List<SearchHistoryItem>> getDictionaryHistory() async {
    return await SettingsManager()
        .settingsStorage!
        .getDictionarySearchHistory();
  }

  Future<void> toggleDictionaryEnabled(dictionarySetting) async {
    await SettingsManager()
        .settingsStorage!
        .toggleDictionaryEnabled(dictionarySetting);
    disabledDictionaryIds =
        await SettingsManager().settingsStorage!.getDisabledDictionaryIds();
  }

  Future<List<int>> getDisabledDictionaryIds() async {
    if (disabledDictionaryIds != null) {
      return disabledDictionaryIds!;
    } else {
      disabledDictionaryIds =
          await SettingsManager().settingsStorage!.getDisabledDictionaryIds();
      return disabledDictionaryIds!;
    }
  }
}
