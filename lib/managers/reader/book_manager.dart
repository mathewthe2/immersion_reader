import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/book_blob.dart';
import 'package:immersion_reader/data/reader/book_bookmark.dart';
import 'package:immersion_reader/data/reader/book_section.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:immersion_reader/utils/folder_utils.dart';
import 'package:sqflite/sqflite.dart';

enum BookSortColumn { title, lastReadTime }

class BookManager {
  SettingsStorage? settingsStorage;
  final Map<int, Book> _cachedBooks = {}; // books with sections and blobs
  final Map<int, Book> _cachedBooksBasicInfo = {}; // only basic info of books
  final Map<int, BookBookmark> _cachedBookmarks =
      {}; // using bookid, not bookmarkid

  static final BookManager _singleton = BookManager._internal();
  BookManager._internal();

  factory BookManager.create(SettingsStorage settingsStorage) {
    _singleton.settingsStorage = settingsStorage;
    return _singleton;
  }

  factory BookManager() => _singleton;

  Database? get database => settingsStorage?.database;

  Future<Book?> getBookById(int bookId) async {
    if (_cachedBooks.containsKey(bookId)) {
      return _cachedBooks[bookId];
    }
    final rows =
        await database!.rawQuery('SELECT * FROM Books WHERE id = ?', [bookId]);
    if (rows.isNotEmpty) {
      Book book = Book.fromMap(rows.first);
      var sectionRows = await database!
          .rawQuery('SELECT * FROM BookSections WHERE bookId = ?', [book.id]);
      book.sections =
          sectionRows.map((row) => BookSection.fromMap(row)).toList();
      var blobRows = await database!
          .rawQuery('SELECT * FROM BookBlobs WHERE bookId = ?', [book.id]);
      book.blobs = blobRows.map((row) => BookBlob.fromMap(row)).toList();
      var bookmarkRows = await database!
          .rawQuery('SELECT * FROM BookBookmarks WHERE bookId = ?', [book.id]);
      if (bookmarkRows.isNotEmpty) {
        book.bookmark = BookBookmark.fromMap(bookmarkRows.first);
      }
      _cachedBooks[bookId] = book;
      return book;
    }
    return null;
  }

  Future<List<Book>> getBooks({BookSortColumn? sort}) async {
    if (_cachedBooksBasicInfo.isNotEmpty) {
      return _cachedBooksBasicInfo.values.toList();
    }
    if (database != null) {
      final sortValue = switch (sort) {
        BookSortColumn.title => 'title ASC',
        BookSortColumn.lastReadTime => 'lastReadTime DESC',
        _ => 'id ASC'
      };
      final rows = await database!.query('Books', orderBy: sortValue);
      if (rows.isNotEmpty) {
        List<Book> books = rows.map((row) => Book.fromMap(row)).toList();
        for (final book in books) {
          _cachedBooksBasicInfo[book.id!] = book;
        }
        return books;
      }
    }
    return [];
  }

  Future<int> setBook(Book book) async {
    if (database != null) {
      bool isBookExists = await isBookWithTitleExists(book.title);
      if (isBookExists) {
        // remove book
        if (book.id != null) {
          await deleteBooksByIds([book.id!]);
          if (_cachedBooks.containsKey(book.id)) {
            _cachedBooks.remove(book.id);
            _cachedBooksBasicInfo.remove(book.id);
          }
        }
      }
      final int bookId = await database!.insert("Books", {
        "title": book.title,
        "authorId": book.authorIdentifier,
        "elementHtml": book.elementHtml,
        "styleSheet": book.styleSheet,
        "hasThumb": book.hasThumbInt,
        "coverImageData": book.coverImageData,
        "coverImagePrefix": book.coverImagePrefix,
      });
      Batch batch = database!.batch();
      book.id = bookId;
      batch = addBookRelatedDataBatch(batch, [book]);
      await batch.commit();
      _cachedBooks[bookId] = book;
      _cachedBooksBasicInfo[bookId] = book;
      return bookId;
    }
    return -1;
  }

  Batch addBookRelatedDataBatch(Batch batch, List<Book> books) {
    for (final book in books) {
      if (book.sections != null) {
        for (BookSection section in book.sections!) {
          batch.insert("BookSections", {
            "bookId": book.id,
            "reference": section.reference,
            "charactersWeight": section.charactersWeight,
            "label": section.label,
            "startCharacter": section.startCharacter,
            "characters": section.characters,
            "parentChapter": section.parentChapter
          });
        }
      }
      if (book.blobs != null) {
        for (BookBlob blob in book.blobs!) {
          batch.insert("BookBlobs", {
            "bookId": book.id,
            "key": blob.key,
            "prefix": blob.prefix,
            "data": blob.data
          });
        }
      }
      if (book.bookmark != null) {
        batch.insert("BookBookmarks", {
          "bookId": book.id,
          "exploredCharCount": book.bookmark!.exploredCharCount,
          "progress": book.bookmark!.progress
        });
      }
    }
    return batch;
  }

  Future<bool> isBookWithTitleExists(String title) async {
    if (title.isNotEmpty && database != null) {
      final rows = await database!
          .rawQuery('SELECT * FROM Books WHERE TITLE = ?', [title]);
      return rows.isNotEmpty;
    }
    return false;
  }

  Future<void> deleteBooksByIds(List<int> bookIds) async {
    if (database != null) {
      Batch batch = database!.batch();

      // Convert the list of bookIds to a string for the IN clause
      String placeholders = List.filled(bookIds.length, '?').join(',');

      // Use placeholders for the batch queries
      batch.rawDelete(
          'DELETE FROM BookBookmarks WHERE bookId IN ($placeholders)', bookIds);
      batch.rawDelete(
          'DELETE FROM BookSections WHERE bookId IN ($placeholders)', bookIds);
      batch.rawDelete(
          'DELETE FROM BookBlobs WHERE bookId IN ($placeholders)', bookIds);
      batch.rawDelete('DELETE FROM Books WHERE id IN ($placeholders)', bookIds);

      await batch.commit();
      for (final bookId in bookIds) {
        _cachedBooks.remove(bookId);
        _cachedBooksBasicInfo.remove(bookId);
        FolderUtils.cleanUpBookFolder(
            bookId); // delete book-related media (srt, audio files)
      }
    }
  }

  Future<void> setLastReadTime(Book book) async {
    if (database != null && book.lastReadTime != null) {
      await database!.rawUpdate(
          'UPDATE Books SET lastReadTime = ? WHERE id = ?',
          [book.lastReadTime!.toIso8601String(), book.id]);
    }
  }

  Future<List<BookBookmark>> getBookmarks() async {
    if (_cachedBookmarks.isNotEmpty) {
      return _cachedBookmarks.values.toList();
    }
    if (database != null) {
      final rows =
          await database!.rawQuery('SELECT * FROM BookBookmarks ORDER BY id');
      if (rows.isNotEmpty) {
        final bookmarks = rows.map((row) => BookBookmark.fromMap(row)).toList();
        for (final bookmark in bookmarks) {
          _cachedBookmarks[bookmark.bookId] = bookmark;
        }
        return bookmarks;
      }
    }
    return [];
  }

  Future<BookBookmark?> getBookmarkByBookId(int bookId) async {
    if (_cachedBookmarks.containsKey(bookId)) {
      return _cachedBookmarks[bookId];
    }
    if (database != null) {
      final rows = await database!
          .rawQuery('SELECT * FROM BookBookmarks WHERE bookId = ?', [bookId]);
      if (rows.isNotEmpty) {
        _cachedBookmarks[bookId] = BookBookmark.fromMap(rows.first);
        return _cachedBookmarks[bookId];
      }
    }
    return null;
  }

  Future<int> setBookmark(BookBookmark bookmark) async {
    if (database != null) {
      final bookmarkId = await database!.rawInsert("""
          INSERT INTO BookBookmarks(bookId, exploredCharCount, progress) VALUES(?, ?, ?)
            ON CONFLICT(bookId) DO UPDATE SET
              exploredCharCount = excluded.exploredCharCount,
              progress          = excluded.progress;
            """,
          [bookmark.bookId, bookmark.exploredCharCount, bookmark.progress]);
      _cachedBookmarks[bookmark.bookId] = bookmark;
      return bookmarkId;
    }
    return -1;
  }

  // load books with id for migration
  Future<bool> bulkLoadBooksWithId(List<Book> books) async {
    if (database != null) {
      List<Book> existingBooks = await getBooks();
      Set<int?> existingBookIds = existingBooks.map((book) => book.id).toSet();
      books =
          books.where((book) => !existingBookIds.contains(book.id)).toList();
      Batch batch = database!.batch();
      for (Book book in books) {
        batch.insert("Books", {
          "id": book.id,
          "title": book.title,
          "elementHtml": book.elementHtml,
          "styleSheet": book.styleSheet,
          "coverImageData": book.coverImageData,
          "coverImagePrefix": book.coverImagePrefix,
          "hasThumb": book.hasThumbInt
        });
      }
      addBookRelatedDataBatch(batch, books);
      await batch.commit();
      return true; // successfully loaded
    }
    return false;
  }
}
