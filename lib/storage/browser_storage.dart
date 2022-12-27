import 'package:immersion_reader/data/browser/browser_bookmark.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class BrowserStorage {
  Database? database;
  static const databaseName = 'browser.db';

  BrowserStorage._create() {
    // print("_create() (private constructor)");
  }

  static Future<BrowserStorage> create() async {
    BrowserStorage browserStorage = BrowserStorage._create();
    String databasesPath = await getDatabasesPath();
     String path = p.join(databasesPath, databaseName);
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}

    // delete existing if any
    // await deleteDatabase(path);

    // opening the database
    browserStorage.database =
        await openDatabase(path, version: 1, onCreate: _onCreateStorageData);
    return browserStorage;
  }

  Future<List<BrowserBookmark>> getBookmarks() async {
    if (database == null) {
      return [];
    }
    List<Map<String, Object?>> rows =
        await database!.rawQuery('SELECT * FROM Bookmarks'); // to do: add limit
    List<BrowserBookmark> bookmarks =
        rows.map((row) => BrowserBookmark.fromMap(row)).toList();
    return bookmarks;
  }

  Future<void> addBookmark(BrowserBookmark bookmark) async {
    await database!.rawInsert(
        'INSERT INTO Bookmarks(name, url, parent, type) VALUES(?, ?, ?, ?)', [
      bookmark.name,
      bookmark.url,
      bookmark.parent,
      bookmark.getTypeValue()
    ]);
  }

  Future<void> deleteBookmark(int bookmarkId) async {
    await database!
        .rawDelete('DELETE FROM Bookmarks WHERE id = ?', [bookmarkId]);
  }

  static Future<void> _onCreateStorageData(Database db, int version) async {
    Batch batch = db.batch();
    batch.execute('''
            CREATE TABLE Bookmarks (
            id INTEGER PRIMARY KEY, name TEXT, url TEXT, parent INTEGER, 
            type INTEGER)
          ''');
    batch.execute('''
            CREATE TABLE History (
            id INTEGER PRIMARY KEY, name TEXT, url TEXT, timestamp INTEGER)
          ''');

    // indexes
    batch.execute("CREATE INDEX index_Bookmarks_parent ON Bookmarks(parent)");
    await batch.commit();
  }
}
