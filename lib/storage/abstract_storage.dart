import 'package:sqflite/sqflite.dart';
import 'package:sqflite_migration/sqflite_migration.dart';
import 'package:immersion_reader/data/database/sql_repository.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

abstract class AbstractStorage {
  late String databaseStorageName;
  Database? database;

  Future<void> initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, databaseStorageName);
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}

    database = await openDatabaseWithMigration(
        path, SqlRepository.getDatabaseConfig(databaseStorageName)!);
  }
}
