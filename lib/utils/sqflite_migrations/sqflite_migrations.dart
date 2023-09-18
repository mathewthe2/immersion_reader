import 'dart:async';

import 'package:immersion_reader/utils/sqflite_migrations/migration_config.dart';
import 'package:immersion_reader/utils/sqflite_migrations/migrator.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteMigrations {
  ///
  /// Open the database at a given path, while running the provided migration
  /// scripts.
  ///
  /// [path] (required) specifies the path to the database file.
  /// [config] (required) specifies the migration configuration.
  /// [openDatabase] (optional) do not override this. It is used for testing
  /// purposes.
  ///
  static Future<Database> openDatabaseWithMigration(
      String path, MigrationConfig config,
      {openDatabase = openDatabase, Function? onCreateCallback}) async {
    final migrator = Migrator(config, onCreateCallback: onCreateCallback);
    return await openDatabase(path,
        version: config.migrationScripts.length + 1,
        onCreate: migrator.executeInitialization,
        onUpgrade: migrator.executeMigration);
  }
}
