import 'dart:async';

import 'package:immersion_reader/utils/sqflite_migrations/migration_config.dart';
import 'package:sqflite/sqflite.dart';

///
/// An internal class which contains methods to execute the initial and
/// migration scripts.
///
/// [config] (required) the migration configuration to execute.
///
class Migrator {
  final MigrationConfig config;
  final Function? onCreateCallback;

  Migrator(this.config, {this.onCreateCallback});

  Future<void> executeInitialization(DatabaseExecutor db, int version) async {
    for (String script in config.initializationScript) {
      await db.execute(script);
    }

    for (String script in config.migrationScripts) {
      await db.execute(script);
    }
    if (onCreateCallback != null) {
      onCreateCallback!();
    }
  }

  Future<void> executeMigration(
      DatabaseExecutor db, int oldVersion, int newVersion) async {
    assert(oldVersion < newVersion,
        'The newVersion($newVersion) should always be greater than the oldVersion($oldVersion).');
    assert(config.migrationScripts.length == newVersion - 1,
    'New version ($newVersion) requires exact ${newVersion - config.migrationScripts.length} migrations.');

    for (var i = oldVersion - 1; i < newVersion - 1; i++) {
      await db.execute(config.migrationScripts[i]);
    }
  }
}
