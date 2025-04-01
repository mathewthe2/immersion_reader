import 'package:immersion_reader/utils/verions.dart';

class DictionarySetting {
  int id;
  String title;
  bool enabled;
  String version;

  DictionarySetting(
      {required this.id,
      required this.title,
      required this.enabled,
      this.version = "1.0.0"});

  factory DictionarySetting.fromMap(Map<String, Object?> map) =>
      DictionarySetting(
          id: map['id'] as int,
          title: map['title'] as String,
          enabled: (map['enabled'] as int?) == 1,
          version: map['version'] as String);

  int get extendedVersion => getExtendedVersionNumber(version);
}
