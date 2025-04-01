import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:immersion_reader/data/settings/updates/dictionary_update.dart';

class SettingsUpdate {
  String schemaVersion;
  DictionaryUpdate dictionaryUpdate;

  SettingsUpdate({
    required this.schemaVersion,
    required this.dictionaryUpdate,
  });

  static const String updateSourceUrl =
      'https://raw.githubusercontent.com/mathewthe2/immersion_reader/refs/heads/main/versions.json';
  static const String schemaVersionKey = 'schema_version';
  static const String dictionaryUpdateKey = 'Dictionary';
  static const String jmdictEnglishKey = 'JMdict (English)';

  factory SettingsUpdate.fromMap(Map<String, Object?> map) => SettingsUpdate(
      schemaVersion: map[schemaVersionKey] as String,
      dictionaryUpdate: DictionaryUpdate.fromMap(
          map[dictionaryUpdateKey] as Map<String, Object?>, jmdictEnglishKey));

  static Future<SettingsUpdate?> getUpdates() async {
    final response = await http.get(Uri.parse(updateSourceUrl));
    if (response.statusCode == 200) {
      final jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      return SettingsUpdate.fromMap(jsonResponse);
    }
    return null;
  }
}
