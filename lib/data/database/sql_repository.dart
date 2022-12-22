import 'package:immersion_reader/data/database/settings_storage_sql.dart';
import 'package:immersion_reader/storage/settings_storage.dart';

class SqlRepository {
  static List<String> getSqlCommands(String databaseName) {
    switch (databaseName) {
      case SettingsStorage.databaseName:
        return settingsStorageSQLString.split('\n').map((l) => l.trim()).toList();
      default:
        return [];
    }
  }
}
