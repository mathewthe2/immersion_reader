import 'package:immersion_reader/data/search/search_result.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/japanese/translator.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/providers/settings_provider.dart';

class DictionaryManager {
  List<int>? disabledDictionaryIds;
  bool? isShowFrequencyTags;
  SettingsProvider? settingsProvider;
  Translator? translator;

  static final DictionaryManager _singleton = DictionaryManager._internal();
  DictionaryManager._internal();

  factory DictionaryManager.createDictionary(SettingsProvider settingsProvider) {
    _singleton.settingsProvider = settingsProvider;
    _singleton.translator = Translator.create(settingsProvider.settingsStorage!);
    return _singleton;
  }
  
  factory DictionaryManager() => _singleton;

  Future<DictionaryOptions> getOptions() async {
    return DictionaryOptions(
        disabledDictionaryIds: await getDisabledDictionaryIds(),
        pitchAccentDisplayStyle: await settingsProvider!.getPitchAccentStyle(),
        isGetFrequencyTags: await settingsProvider!.getIsShowFrequencyTags());
  }

  Future<List<Vocabulary>> findTerm(String text) async {
    if (settingsProvider != null) {
      return await translator!.findTerm(text, options: await getOptions());
    } else {
      return [];
    }
  }

  Future<SearchResult> findTermForUserSearch(String text) async {
    if (settingsProvider != null) {
      return await translator!
          .findTermForUserSearch(text, options: await getOptions());
    } else {
      return SearchResult(additionalMatches: [], exactMatches: []);
    }
  }

  Future<void> toggleDictionaryEnabled(dictionarySetting) async {
    if (settingsProvider != null) {
      await settingsProvider!.settingsStorage!
          .toggleDictionaryEnabled(dictionarySetting);
      disabledDictionaryIds =
          await settingsProvider!.settingsStorage!.getDisabledDictionaryIds();
    }
  }

  Future<List<int>> getDisabledDictionaryIds() async {
    if (disabledDictionaryIds != null) {
      return disabledDictionaryIds!;
    } else if (settingsProvider != null) {
      disabledDictionaryIds =
          await settingsProvider!.settingsStorage!.getDisabledDictionaryIds();
      return disabledDictionaryIds!;
    } else {
      return [];
    }
  }
}
