import 'package:immersion_reader/data/search/search_result.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:immersion_reader/japanese/translator.dart';

class DictionaryProvider {
  List<int>? disabledDictionaryIds;
  SettingsStorage? settingsStorage;
  Translator? translator;

  DictionaryProvider._create() {
    // print("_create() (private constructor)");
  }

  static Future<DictionaryProvider> create() async {
    DictionaryProvider provider = DictionaryProvider._create();
    provider.settingsStorage = await SettingsStorage.create();
    provider.translator = Translator.create(provider.settingsStorage!);
    return provider;
  }

  Future<List<Vocabulary>> findTerm(String text) async {
    if (settingsStorage != null) {
      return await translator!.findTerm(text,
          disabledDictionaryIds: await getDisabledDictionaryIds());
    } else {
      return [];
    }
  }

  Future<SearchResult> findTermForUserSearch(String text) async {
    if (settingsStorage != null) {
      return await translator!.findTermForUserSearch(text,
          disabledDictionaryIds: await getDisabledDictionaryIds());
    } else {
      return SearchResult(additionalMatches: [], exactMatches: []);
    }
  }

  Future<void> toggleDictionaryEnabled(dictionarySetting) async {
    if (settingsStorage != null) {
      await settingsStorage!.toggleDictionaryEnabled(dictionarySetting);
      disabledDictionaryIds = await settingsStorage!.getDisabledDictionaryIds();
    }
  }

  Future<List<int>> getDisabledDictionaryIds() async {
    if (disabledDictionaryIds != null) {
      return disabledDictionaryIds!;
    } else if (settingsStorage != null) {
      disabledDictionaryIds = await settingsStorage!.getDisabledDictionaryIds();
      return disabledDictionaryIds!;
    } else {
      return [];
    }
  }
}
