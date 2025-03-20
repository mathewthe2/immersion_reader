import 'package:immersion_reader/data/settings/appearance_setting.dart';
import 'package:immersion_reader/data/settings/browser/browser_setting.dart';
import 'package:immersion_reader/data/settings/profile_setting.dart';
import 'package:immersion_reader/data/settings/reader_setting.dart';

class SettingsData {
  AppearanceSetting appearanceSetting;
  BrowserSetting browserSetting;
  ProfileSetting profileSetting;
  ReaderSetting readerSetting;

  static const String appearanceSettingKey = 'appearance';
  static const String browserSettingKey = 'browser';
  static const String profileSettingKey = 'profile';
  static const String readerSettingKey = 'reader';

  SettingsData(
      {required this.appearanceSetting,
      required this.browserSetting,
      required this.profileSetting,
      required this.readerSetting});

  factory SettingsData.fromMap(Map<String, Object?> map) => SettingsData(
        appearanceSetting: AppearanceSetting.fromMap(
            map[appearanceSettingKey] as Map<String, Object?>),
        browserSetting: BrowserSetting.fromMap(
            map[browserSettingKey] as Map<String, Object?>),
        profileSetting: ProfileSetting.fromMap(
            map[profileSettingKey] as Map<String, Object?>),
        readerSetting: ReaderSetting.fromMap(
            map[readerSettingKey] as Map<String, Object?>),
      );
}
