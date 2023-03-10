import 'package:immersion_reader/data/browser/browser_bookmark.dart';
import 'package:immersion_reader/storage/abstract_storage.dart';

class BrowserStorage extends AbstractStorage {
  @override
  String get databaseStorageName => databaseName;

  static const String databaseName = 'browser.db';

  static final BrowserStorage _singleton = BrowserStorage._internal();
  BrowserStorage._internal();
  factory BrowserStorage() => _singleton;

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
}
