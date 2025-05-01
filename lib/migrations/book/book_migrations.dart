import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/book_blob.dart';
import 'package:immersion_reader/managers/reader/book_manager.dart';
import 'package:immersion_reader/utils/book/book_files.dart';

class BookMigrations {
  static List<Function(Book)> migrations = [migrateContentHtmlFromDatabase];

  static int latestVersion = 2;

  // migration operation for each version
  // version 1->2 will run first item in migrations
  static migrate(Book book) async {
    if (book.version == null || book.version == latestVersion) {
      return book;
    } else {
      for (final (int index, Function(Book) migration) in migrations.indexed) {
        if (index + 1 >= book.version!) {
          book = await migration.call(book);
        }
      }
      book.version = latestVersion;
      if (BookManager().database != null) {
        await BookManager().database!.update(
            "Books", {"version": latestVersion},
            where: "id = ?", whereArgs: [book.id]);
      }
    }
  }

  static Future<Book> migrateContentHtmlFromDatabase(Book book) async {
    final List<String> columnsToMigrateForContentHtml = [
      'elementHtml',
      'styleSheet',
      'coverImageData',
      'coverImagePrefix' // not deprecated but needed for migration
    ];
    if (BookManager().database == null) return book;
    var blobRows = await BookManager()
        .database!
        .rawQuery('SELECT * FROM BookBlobs WHERE bookId = ?', [book.id]);
    book.blobs = blobRows.map((row) => BookBlob.fromMap(row)).toList();
    final rows = await BookManager().database!.query('Books',
        where: 'id = ?',
        whereArgs: [book.id],
        columns: columnsToMigrateForContentHtml);
    if (rows.isNotEmpty) {
      Map<String, Object?> map = rows.first;
      book.elementHtml = map['elementHtml'] as String?;
      book.styleSheet = map['styleSheet'] as String?;
      book.coverImage = Book.getCoverImageFromDatabaseResult(map);
    }
    await BookFiles.saveBookContent(book);
    return book;
  }
}
