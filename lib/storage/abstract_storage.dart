import 'package:immersion_reader/utils/sqflite_migrations/sqflite_migrations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:immersion_reader/data/database/sql_repository.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:flutter/foundation.dart';

abstract class AbstractStorage {
  late String databaseStorageName;
  Database? database;
  Function? onCreateCallback; // callback after database is created
  Function? onOpenCallback; // callback after database is open
  String? databasePrototypePath; // clone from existing database file if exists

  Future<void> initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, databaseStorageName);
    debugPrint(path);
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}

    if (databasePrototypePath != null) {
      await File(path).exists();
      if (!File(path).existsSync()) {
        ByteData data = await rootBundle.load(databasePrototypePath!);
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      }
      database = await openDatabase(path);
      if (onCreateCallback != null) {
        await onCreateCallback!();
      }
    }

    database = await SqfliteMigrations.openDatabaseWithMigration(
        path, SqlRepository.getDatabaseConfig(databaseStorageName)!,
        onCreateCallback: onCreateCallback);
    if (onOpenCallback != null) {
      onOpenCallback!();
    }
  }
}
