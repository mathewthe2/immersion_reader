import 'package:immersion_reader/utils/verions.dart';

class UpdateEntity {
  String version;
  String source;

  UpdateEntity({required this.version, required this.source});

  factory UpdateEntity.fromMap(Map<String, Object?> map) => UpdateEntity(
      version: map['version'] as String, source: map['source'] as String);

  int get extendedVersion => getExtendedVersionNumber(version);
}
