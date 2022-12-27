import 'package:sqflite/sqflite.dart';
import 'package:immersion_reader/data/database/profile_storage_sql.dart';
import 'package:immersion_reader/data/database/settings_storage_sql.dart';
import 'package:immersion_reader/data/database/vocabulary_list_storage_sql.dart';
import 'package:immersion_reader/storage/profile_storage.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';

class SqlRepository {
  static List<String> _sqlStringToList(String sqlCommands) {
    return sqlCommands.split('\n').map((l) => l.trim()).toList();
  }

  static List<String> _getSqlCommands(String databaseName) {
    switch (databaseName) {
      case ProfileStorage.databaseName:
        return _sqlStringToList(profileStorageSQLString);
      case SettingsStorage.databaseName:
        return _sqlStringToList(settingsStorageSQLString);
      case VocabularyListStorage.databaseName:
        return _sqlStringToList(vocablaryListStorageSQLString);
      default:
        return [];
    }
  }

  static Future<Batch> insertTablesForDatabase(Database database, String databaseName) async {
    Batch batch = database.batch();
    for (String sqlCommand in _getSqlCommands(databaseName)) {
      batch.execute(sqlCommand);
    }
    return batch;
  }
}
