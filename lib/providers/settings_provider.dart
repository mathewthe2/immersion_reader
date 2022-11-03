import 'package:immersion_reader/data/settings/settings_data.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/storage/settings_storage.dart';

class SettingsProvider {
  SettingsStorage? settingsStorage;
  SettingsData? settingsCache;

  SettingsProvider._create() {
    // print("_create() (private constructor)");
  }

  static SettingsProvider create(SettingsStorage settingsStorage) {
    SettingsProvider provider = SettingsProvider._create();
    provider.settingsStorage = settingsStorage;
    provider.settingsCache = settingsStorage.settingsCache;
    return provider;
  }

  Future<void> toggleShowFrequencyTags(bool isShowFrequencyTags) async {
    if (settingsCache != null) {
      settingsCache!.appearanceSetting.showFrequencyTags =
          !settingsCache!.appearanceSetting.showFrequencyTags;
    }
    await settingsStorage!.changeConfigSettings(
        "show_frequency_tags", isShowFrequencyTags ? "1" : "0",
        newSettingsCache: settingsCache);
  }

  Future<bool> getIsShowFrequencyTags() async {
    settingsCache ??= await settingsStorage!.getConfigSettings();
    return settingsCache!.appearanceSetting.showFrequencyTags;
  }

  Future<void> updatePitchAccentStyle(
      PitchAccentDisplayStyle pitchAccentDisplayStyle) async {
    if (settingsCache != null) {
      settingsCache!.appearanceSetting.pitchAccentStyleString =
          pitchAccentDisplayStyle.name;
    }
    await settingsStorage!.changeConfigSettings(
        "pitch_accent_display_style", pitchAccentDisplayStyle.name,
        newSettingsCache: settingsCache);
  }

  Future<PitchAccentDisplayStyle> getPitchAccentStyle() async {
    settingsCache ??= await settingsStorage!.getConfigSettings();
    String pitchAccentString =
        settingsCache!.appearanceSetting.pitchAccentStyleString;
    return PitchAccentDisplayStyle.values
        .firstWhere((e) => e.name == pitchAccentString);
  }
}
