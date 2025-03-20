class ReaderSetting {
  bool isMigratedFromIndexedDb;

  // keys for Database
  static const String isMigratedFromIndexedDbKey =
      'is_migrated_from_indexed_db';

  ReaderSetting({required this.isMigratedFromIndexedDb});

  factory ReaderSetting.fromMap(Map<String, Object?> map) => ReaderSetting(
      isMigratedFromIndexedDb:
          (map[isMigratedFromIndexedDbKey] as String) == "1");
}
