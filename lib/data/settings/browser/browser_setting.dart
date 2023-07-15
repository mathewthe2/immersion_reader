import 'package:immersion_reader/data/settings/browser/dark_reader_setting.dart';
import 'dart:convert';

class BrowserSetting {
  bool enableAdBlock;
  bool enableDarkReader;
  DarkReaderSetting darkReaderSetting;
  List<String> urlFilters;

  // keys for Database
  static const String enableAdBlockKey = 'enable_ad_block';
  static const String enableDarkReaderKey = 'enable_dark_reader';
  static const String darkReaderSettingKey = 'dark_reader_setting';
  static const String urlFiltersKey = 'url_filters';

  BrowserSetting(
      {required this.enableAdBlock,
      required this.enableDarkReader,
      required this.darkReaderSetting,
      required this.urlFilters});

  factory BrowserSetting.fromMap(Map<String, Object?> map) => BrowserSetting(
      enableAdBlock: (map[enableAdBlockKey] as String) == "1",
      enableDarkReader: (map[enableDarkReaderKey] as String) == "1",
      darkReaderSetting: DarkReaderSetting.fromJson(
          json.decode(map[darkReaderSettingKey] as String)),
      urlFilters: (map[urlFiltersKey] as String).split("\n"));

  static String urlFiltersToString(List<String> urlFilters) {
    return urlFilters.join("\n");
  }
}
