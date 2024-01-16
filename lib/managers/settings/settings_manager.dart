import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:immersion_reader/data/settings/appearance_setting.dart';
import 'package:immersion_reader/data/settings/settings_data.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/storage/settings_storage.dart';

class SettingsManager {
  SettingsStorage? settingsStorage;
  SettingsData? defaultConfigCache;
  static String appearanceConfigKey = 'appearance';

  static final SettingsManager _singleton = SettingsManager._internal();
  SettingsManager._internal();

  factory SettingsManager.create(SettingsStorage settingsStorage) {
    _singleton.settingsStorage = settingsStorage;
    return _singleton;
  }

  factory SettingsManager() => _singleton;

  SettingsData? cachedSettings() {
    return settingsStorage?.settingsCache;
  }

  AppearanceSetting cachedAppearanceSettings() {
    if (cachedSettings() != null) {
      return cachedSettings()!.appearanceSetting;
    } else {
      return defaultConfigCache!.appearanceSetting;
    }
  }

  Future<SettingsData> _getSettingsData() async {
    return settingsStorage == null
        ? await _getDefaultConfig()
        : await settingsStorage!.getConfigSettings();
  }

  Future<SettingsData> _getDefaultConfig() async {
    if (defaultConfigCache != null) {
      return defaultConfigCache!;
    }
    ByteData bytes = await rootBundle
        .load(p.join("assets", "settings", "defaultConfig.json"));
    String jsonStr = const Utf8Decoder().convert(bytes.buffer.asUint8List());
    Map<String, Object?> json = jsonDecode(jsonStr);
    defaultConfigCache = SettingsData.fromMap(json);
    return defaultConfigCache!;
  }

  Future<void> toggleShowFrequencyTags(bool isShowFrequencyTags) async {
    await settingsStorage?.changeConfigSettings(
        AppearanceSetting.showFrequencyTagsKey, isShowFrequencyTags ? "1" : "0",
        onSuccessCallback: () => settingsStorage!.settingsCache!
            .appearanceSetting.showFrequencyTags = isShowFrequencyTags);
  }

  Future<bool> getIsShowFrequencyTags() async {
    SettingsData data = await _getSettingsData();
    return data.appearanceSetting.showFrequencyTags;
  }

  Future<void> toggleEnableReaderFullScreen(bool enableReaderFullScreen) async {
    await settingsStorage?.changeConfigSettings(
        AppearanceSetting.enableReaderFullScreenKey,
        enableReaderFullScreen ? "1" : "0",
        onSuccessCallback: () => settingsStorage!.settingsCache!
            .appearanceSetting.enableReaderFullScreen = enableReaderFullScreen);
  }

  Future<bool> getIsEnabledReaderFullScreen() async {
    SettingsData data = await _getSettingsData();
    return data.appearanceSetting.enableReaderFullScreen;
  }

  Future<void> toggleKeepScreenOn(bool isKeepScreenOn) async {
    await settingsStorage?.changeConfigSettings(
        AppearanceSetting.isKeepScreenOnKey, isKeepScreenOn ? "1" : "0",
        onSuccessCallback: () => settingsStorage!
            .settingsCache!.appearanceSetting.isKeepScreenOn = isKeepScreenOn);
  }

  Future<void> toggleShowDeviceStatusBar(bool isShowDeviceStatusBar) async {
    await settingsStorage?.changeConfigSettings(
        AppearanceSetting.isShowDeviceStatusBarKey,
        isShowDeviceStatusBar ? "1" : "0",
        onSuccessCallback: () => settingsStorage!.settingsCache!
            .appearanceSetting.isShowDeviceStatusBar = isShowDeviceStatusBar);
  }

  Future<bool> getIsKeepScreenOn() async {
    SettingsData data = await _getSettingsData();
    return data.appearanceSetting.isKeepScreenOn;
  }

  Future<void> toggleEnableSlideAnimation(bool enableSlideAnimation) async {
    await settingsStorage?.changeConfigSettings(
        AppearanceSetting.enableSlideAnimationKey,
        enableSlideAnimation ? "1" : "0",
        onSuccessCallback: () => settingsStorage!.settingsCache!
            .appearanceSetting.enableSlideAnimation = enableSlideAnimation);
  }

  Future<bool> getIsEnabledSlideAnimation() async {
    SettingsData data = await _getSettingsData();
    return data.appearanceSetting.enableSlideAnimation;
  }

  Future<void> toggleAllowLookupWhilePopupActive(
      bool allowLookupWhilePopupActive) async {
    await settingsStorage?.changeConfigSettings(
        AppearanceSetting.allowLookupWhilePopupActiveKey,
        allowLookupWhilePopupActive ? "1" : "0",
        onSuccessCallback: () => settingsStorage!
            .settingsCache!
            .appearanceSetting
            .allowLookupWhilePopupActive = allowLookupWhilePopupActive);
  }

  Future<bool> getAllowLookupWhilePopupActive() async {
    SettingsData data = await _getSettingsData();
    return data.appearanceSetting.allowLookupWhilePopupActive;
  }

  Future<void> updatePitchAccentStyle(
      PitchAccentDisplayStyle pitchAccentDisplayStyle) async {
    await settingsStorage?.changeConfigSettings(
        AppearanceSetting.pitchAccentStyleKey, pitchAccentDisplayStyle.name,
        onSuccessCallback: () => settingsStorage!
            .settingsCache!
            .appearanceSetting
            .pitchAccentStyleString = pitchAccentDisplayStyle.name);
  }

  Future<PitchAccentDisplayStyle> getPitchAccentStyle() async {
    SettingsData data = await _getSettingsData();
    String pitchAccentString = data.appearanceSetting.pitchAccentStyleString;
    return PitchAccentDisplayStyle.values
            .firstWhereOrNull((e) => e.name == pitchAccentString) ??
        PitchAccentDisplayStyle.none;
  }

  Future<void> updatePopupDictionaryTheme(
      PopupDictionaryTheme popupDictionaryTheme) async {
    await settingsStorage?.changeConfigSettings(
        AppearanceSetting.popupDictionaryThemeKey, popupDictionaryTheme.name,
        onSuccessCallback: () => settingsStorage!
            .settingsCache!
            .appearanceSetting
            .popupDictionaryThemeString = popupDictionaryTheme.name);
  }

  Future<PopupDictionaryTheme> getPopupDictionaryTheme() async {
    SettingsData data = await _getSettingsData();
    String popupDictionaryThemeString =
        data.appearanceSetting.popupDictionaryThemeString;
    return PopupDictionaryTheme.values
        .firstWhere((e) => e.name == popupDictionaryThemeString);
  }

  Future<Color> getReaderBackgroundColor() async {
    SettingsData data = await _getSettingsData();
    return data.appearanceSetting.readerBackgroundColor;
  }

  Future<void> setReaderBackgroundColor(String readerBackgroundColor) async {
    await settingsStorage?.changeConfigSettings(
        AppearanceSetting.readerThemeKey, readerBackgroundColor,
        onSuccessCallback: () => settingsStorage!.settingsCache!
            .appearanceSetting.readerThemeString = readerBackgroundColor);
  }
}
