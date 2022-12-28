import 'package:immersion_reader/data/settings/appearance_setting.dart';
import 'package:immersion_reader/data/settings/settings_data.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/storage/settings_storage.dart';

class SettingsProvider {
  SettingsStorage? settingsStorage;

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
        AppearanceSetting.showFrequencyTagsKey, isShowFrequencyTags ? "1" : "0",
        onSuccessCallback: () => settingsStorage!.settingsCache!
            .appearanceSetting.showFrequencyTags = isShowFrequencyTags);
  }

  Future<bool> getIsShowFrequencyTags() async {
    SettingsData data = await settingsStorage!.getConfigSettings();
    return data.appearanceSetting.showFrequencyTags;
  }

  Future<void> toggleEnableReaderFullScreen(bool enableReaderFullScreen) async {
    await settingsStorage!.changeConfigSettings(
        AppearanceSetting.enableReaderFullScreenKey,
        enableReaderFullScreen ? "1" : "0",
        onSuccessCallback: () => settingsStorage!.settingsCache!
            .appearanceSetting.enableReaderFullScreen = enableReaderFullScreen);
  }

  Future<bool> getIsEnabledReaderFullScreen() async {
    return settingsStorage!
        .settingsCache!.appearanceSetting.enableReaderFullScreen;
  }

  Future<void> toggleEnableSlideAnimation(bool enableSlideAnimation) async {
    await settingsStorage!.changeConfigSettings(
        AppearanceSetting.enableSlideAnimationKey,
        enableSlideAnimation ? "1" : "0",
        onSuccessCallback: () => settingsStorage!.settingsCache!
            .appearanceSetting.enableSlideAnimation = enableSlideAnimation);
  }

  Future<bool> getIsEnabledSlideAnimation() async {
    return settingsStorage!
        .settingsCache!.appearanceSetting.enableSlideAnimation;
  }

  Future<void> updatePitchAccentStyle(
      PitchAccentDisplayStyle pitchAccentDisplayStyle) async {
    await settingsStorage!.changeConfigSettings(
        AppearanceSetting.pitchAccentStyleKey, pitchAccentDisplayStyle.name,
        onSuccessCallback: () => settingsStorage!
            .settingsCache!
            .appearanceSetting
            .pitchAccentStyleString = pitchAccentDisplayStyle.name);
  }

  Future<PitchAccentDisplayStyle> getPitchAccentStyle() async {
    SettingsData data = await settingsStorage!.getConfigSettings();
    String pitchAccentString = data.appearanceSetting.pitchAccentStyleString;
    return PitchAccentDisplayStyle.values
        .firstWhere((e) => e.name == pitchAccentString);
  }

  Future<void> updatePopupDictionaryTheme(
      PopupDictionaryTheme popupDictionaryTheme) async {
    await settingsStorage!.changeConfigSettings(
        AppearanceSetting.popupDictionaryThemeKey, popupDictionaryTheme.name,
        onSuccessCallback: () => settingsStorage!
            .settingsCache!
            .appearanceSetting
            .popupDictionaryThemeString = popupDictionaryTheme.name);
  }

  Future<PopupDictionaryTheme> getPopupDictionaryTheme() async {
    SettingsData data = await settingsStorage!.getConfigSettings();
    String popupDictionaryThemeString =
        data.appearanceSetting.popupDictionaryThemeString;
    return PopupDictionaryTheme.values
        .firstWhere((e) => e.name == popupDictionaryThemeString);
  }
}
