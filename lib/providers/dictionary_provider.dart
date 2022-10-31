import 'package:immersion_reader/data/search/search_result.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/japanese/translator.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/providers/settings_provider.dart';

class DictionaryProvider {
  List<int>? disabledDictionaryIds;
  bool? isShowFrequencyTags;
  SettingsProvider? settingsProvider;
  Translator? translator;

  DictionaryProvider._create() {
    // print("_create() (private constructor)");
  }

  static DictionaryProvider create(SettingsProvider settingsProvider) {
    DictionaryProvider provider = DictionaryProvider._create();
    provider.settingsProvider = settingsProvider;
    provider.translator = Translator.create(settingsProvider.settingsStorage!);
    return provider;
  }

  Future<List<Vocabulary>> findTerm(String text) async {
    if (settingsProvider != null) {
      return await translator!.findTerm(text,
          options: DictionaryOptions(
              disabledDictionaryIds: await getDisabledDictionaryIds(),
              isGetFrequencyTags:
                  await settingsProvider!.getIsShowFrequencyTags()));
    } else {
      return [];
    }
  }

  Future<SearchResult> findTermForUserSearch(String text) async {
    if (settingsProvider != null) {
      return await translator!.findTermForUserSearch(text,
          options: DictionaryOptions(
              disabledDictionaryIds: await getDisabledDictionaryIds(),
              isGetFrequencyTags:
                  await settingsProvider!.getIsShowFrequencyTags()));
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
