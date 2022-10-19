import 'package:immersion_reader/widgets/settings/appearance_settings.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:immersion_reader/storage/settings_storage.dart';

class SettingsProvider {
  SettingsStorage? settingsStorage;
  AppearanceSettings? appearanceSettingsCache;

  SettingsProvider._create() {}

  static SettingsProvider create(SettingsStorage settingsStorage) {
    SettingsProvider provider = SettingsProvider._create();
    provider.settingsStorage = settingsStorage;
    return provider;
  }

  // Future<String> _getConfigValue(String configKey) async {
  //   if (settingsCache.containsKey(configKey)) {
  //     return settingsCache[configKey]!;
  //   } else {
  //     // todo: fetch settings here
  //     settingsCache = await settingsStorage!.getConfigMap();
  //     if (settingsCache.containsKey(configKey)) {
  //       return settingsCache[configKey]!;
  //     } else {
  //       throw Exception("Unable to get config key");
  //     }
  //   }
  // }

  // Future<bool> getShowFrequencyTags() async {
  //   String show = await _getConfigValue("show_frequency_tags");
  //   if (show.isEmpty) {
  //     show = await getDefaultConfig("show_frequency_tags");
  //   }
  //   return show == "1";
  // }

  // Future<String> getDefaultConfig(String configKey) async {
  //   ByteData bytes = await rootBundle
  //       .load(p.join("assets", "settings", "defaultConfig.json"));
  //   String jsonStr = const Utf8Decoder().convert(bytes.buffer.asUint8List());
  //   Map<String, Object?> json = jsonDecode(jsonStr);
  //   return json[configKey] as String;
  // }
}
