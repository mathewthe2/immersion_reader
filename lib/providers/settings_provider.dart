import 'package:immersion_reader/data/settings/settings_data.dart';
import 'package:immersion_reader/storage/settings_storage.dart';

class SettingsProvider {
  SettingsStorage? settingsStorage;
  // SettingsData? settingsCache;

  SettingsProvider._create() {
    // print("_create() (private constructor)");
  }

  static SettingsProvider create(SettingsStorage settingsStorage) {
    SettingsProvider provider = SettingsProvider._create();
    provider.settingsStorage = settingsStorage;
    return provider;
  }

  Future<void> toggleShowFrequencyTags(bool isShowFrequencyTags) async {
    await settingsStorage!.changeConfigSettings(
        "show_frequency_tags", isShowFrequencyTags ? "1" : "0");
  }
}
