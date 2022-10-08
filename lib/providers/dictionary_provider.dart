import 'package:immersion_reader/storage/settings_storage.dart';

class DictionaryProvider {
  List<int>? disabledDictionaryIds;
  SettingsStorage? settingsStorage;

  DictionaryProvider._create() {
    // print("_create() (private constructor)");
  }

  static Future<DictionaryProvider> create() async {
    DictionaryProvider provider = DictionaryProvider._create();
    provider.settingsStorage = await SettingsStorage.create();
    return provider;
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
