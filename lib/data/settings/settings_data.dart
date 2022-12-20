import 'package:immersion_reader/data/settings/appearance_setting.dart';
import 'package:immersion_reader/data/settings/browser_setting.dart';

class SettingsData {
  AppearanceSetting appearanceSetting;
  BrowserSetting browserSetting;

  static const String appearanceSettingKey = 'appearance';
  static const String browserSettingKey = 'browser';

  SettingsData({required this.appearanceSetting, required this.browserSetting});
}
