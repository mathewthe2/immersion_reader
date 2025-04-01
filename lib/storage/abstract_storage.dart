import 'package:flutter_archive/flutter_archive.dart';
import 'package:immersion_reader/storage/browser_storage.dart';
import 'package:immersion_reader/storage/profile_storage.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/utils/folder_utils.dart';
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

  static Future<AbstractStorage?> create(Type? storageType) async {
    AbstractStorage? storage;
    switch (storageType) {
      case const (BrowserStorage):
        storage = BrowserStorage();
        break;
      case const (ProfileStorage):
        storage = ProfileStorage();
        break;
      case const (SettingsStorage):
        storage = SettingsStorage();
        break;
      case const (VocabularyListStorage):
        storage = VocabularyListStorage();
        break;
    }
    await storage?.initDatabase();
    return storage;
  }

  Future<void> initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, databaseStorageName);
    debugPrint(path);
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}

    if (databasePrototypePath != null) {
      await File(path).exists();
      // clone database if no existing database
      if (!File(path).existsSync()) {
        ByteData data = await rootBundle.load(databasePrototypePath!);
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        final tempFile =
            await FolderUtils.createTempFile('$databaseStorageName.zip');
        await tempFile.writeAsBytes(
          bytes,
          flush: true,
        );
        try {
          await ZipFile.extractToDirectory(
              zipFile: tempFile, destinationDir: Directory(databasesPath));
          await tempFile.delete();
        } catch (e) {
          debugPrint(e.toString());
        }
        if (onCreateCallback != null) {
          await onCreateCallback!();
        }
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
