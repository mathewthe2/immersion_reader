import 'package:immersion_reader/data/browser/browser_bookmark.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class BrowserStorage {
    Database? database;

  BrowserStorage._create() {
    // print("_create() (private constructor)");
  }

  static Future<BrowserStorage> create() async {
    BrowserStorage browserStorage = BrowserStorage._create();
     String databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath,
        "browser.db"); // separate database file so we keep the definition data even if dictionary is removed
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}

    // delete existing if any
    // await deleteDatabase(path);

    // opening the database
    browserStorage.database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table\
      Batch batch = db.batch();
      batch.execute('''
            CREATE TABLE Bookmarks (
            id INTEGER PRIMARY KEY, name TEXT, url TEXT, parent INTEGER, 
            type INTEGER)
          ''');
      batch.rawQuery(
          "CREATE INDEX index_Bookmarks_parent ON Bookmarks(parent)");
      await batch.commit();
    });
    return browserStorage;
  }

  Future<List<BrowserBookmark>> getBookmarks() async {
    if (database == null) {
      return [];
    }
    List<Map<String, Object?>> rows = await database!
        .rawQuery('SELECT * FROM Bookmarks'); // to do: add limit
    List<BrowserBookmark> bookmarks =
        rows.map((row) => BrowserBookmark.fromMap(row)).toList();
    return bookmarks;
  }

}