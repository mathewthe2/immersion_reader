import 'package:immersion_reader/data/settings/appearance_setting.dart';
import 'package:immersion_reader/data/settings/browser_setting.dart';
import 'package:immersion_reader/data/settings/profile_setting.dart';

class SettingsData {
  AppearanceSetting appearanceSetting;
  BrowserSetting browserSetting;
  ProfileSetting profileSetting;

  static const String appearanceSettingKey = 'appearance';
  static const String browserSettingKey = 'browser';
  static const String profileSettingKey = 'profile';

  SettingsData(
      {required this.appearanceSetting,
      required this.browserSetting,
      required this.profileSetting});

  factory SettingsData.fromMap(Map<String, Object?> map) => SettingsData(
        appearanceSetting: AppearanceSetting.fromMap(
            map[appearanceSettingKey] as Map<String, Object?>),
        browserSetting: BrowserSetting.fromMap(
            map[browserSettingKey] as Map<String, Object?>),
        profileSetting: ProfileSetting.fromMap(
            map[profileSettingKey] as Map<String, Object?>),
      );
}
