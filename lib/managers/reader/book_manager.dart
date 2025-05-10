import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_files.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_match_result.dart';
import 'package:immersion_reader/data/reader/audio_book/subtitle/subtitles_data.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/book_bookmark.dart';
import 'package:immersion_reader/data/reader/book_section.dart';
import 'package:immersion_reader/migrations/book/book_migrations.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:immersion_reader/utils/book/book_files.dart';
import 'package:immersion_reader/utils/folder_utils.dart';
import 'package:sqflite/sqflite.dart';

enum BookSortColumn { title, lastReadTime }

class BookManager {
  SettingsStorage? settingsStorage;
  final Map<int, Book> _cachedBooks = {}; // books with sections and blobs
  final Map<int, Book> _cachedBooksBasicInfo = {}; // only basic info of books
  final Map<int, BookBookmark> _cachedBookmarks =
      {}; // using bookid, not bookmarkid
  int? currentBookId;

  static final BookManager _singleton = BookManager._internal();
  BookManager._internal();

  factory BookManager.create(SettingsStorage settingsStorage) {
    _singleton.settingsStorage = settingsStorage;
    return _singleton;
  }

  factory BookManager() => _singleton;

  Database? get database => settingsStorage?.database;

  static const List<String> bookColumnsToQuery = [
    'id',
    'version',
    'title',
    'lastReadTime',
    'authorId',
    'coverImagePrefix',
    'hasThumb',
    'playBackPositionInMs',
    'matchedSubtitles'
  ];

  Future<Book?> getBookById(int bookId) async {
    if (_cachedBooks.containsKey(bookId)) {
      return _cachedBooks[bookId];
    }
    final rows = await database!.query("Books",
        columns: bookColumnsToQuery, where: "id = ?", whereArgs: [bookId]);
    if (rows.isNotEmpty) {
      Book book = Book.fromMap(rows.first);
      var sectionRows = await database!
          .rawQuery('SELECT * FROM BookSections WHERE bookId = ?', [book.id]);
      book.sections =
          sectionRows.map((row) => BookSection.fromMap(row)).toList();
      var bookmarkRows = await database!
          .rawQuery('SELECT * FROM BookBookmarks WHERE bookId = ?', [book.id]);
      if (bookmarkRows.isNotEmpty) {
        book.bookmark = BookBookmark.fromMap(bookmarkRows.first);
      }
      book = await BookMigrations.migrate(book);
      book = await BookFiles.getBookContent(book);

      _cachedBooks[bookId] = book;
      return book;
    }
    return null;
  }

  // get all books and their basic info
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
      final rows = await database!
          .query('Books', columns: bookColumnsToQuery, orderBy: sortValue);
      if (rows.isNotEmpty) {
        List<Book> books = rows.map((row) => Book.fromMap(row)).toList();
        List<Future> futures = [];
        for (final book in books) {
          futures.add(BookMigrations.migrate(book).then((result) async {
            _cachedBooksBasicInfo[book.id!] = await BookFiles.getBookContent(
                book,
                requiredFileNames: {BookFiles.coverImageFileName});
          }));
        }
        await Future.wait(futures);
        return _cachedBooksBasicInfo.values.toList();
      }
    }
    return [];
  }

  Future<void> updateBookMatchedSubtitles(
      AudioBookMatchResult matchResult) async {
    await database?.update(
        "Books",
        {
          "matchedSubtitles": matchResult.matchedSubtitles,
        },
        where: "id = ?",
        whereArgs: [matchResult.bookId]);
    // update cache
    if (_cachedBooks.containsKey(matchResult.bookId)) {
      _cachedBooks[matchResult.bookId]!.elementHtml = matchResult.elementHtml;
      _cachedBooks[matchResult.bookId]!.elementHtmlBackup =
          matchResult.htmlBackup;
      _cachedBooks[matchResult.bookId]!.matchedSubtitles =
          matchResult.matchedSubtitles;
    }
    if (_cachedBooksBasicInfo.containsKey(matchResult.bookId)) {
      _cachedBooksBasicInfo[matchResult.bookId]!.elementHtml =
          matchResult.elementHtml;
      _cachedBooksBasicInfo[matchResult.bookId]!.elementHtmlBackup =
          matchResult.htmlBackup;
      _cachedBooksBasicInfo[matchResult.bookId]!.matchedSubtitles =
          matchResult.matchedSubtitles;
    }
  }

  Future<void> setBookPlayBackPositionInMs(
      {required int bookId, required int playBackPositionInMs}) async {
    await database?.update(
        "Books", {"playBackPositionInMs": playBackPositionInMs},
        where: "id = ?", whereArgs: [bookId]);
    // update cache
    if (_cachedBooks.containsKey(bookId)) {
      _cachedBooks[bookId]!.playBackPositionInMs = playBackPositionInMs;
    }
    if (_cachedBooksBasicInfo.containsKey(bookId)) {
      _cachedBooksBasicInfo[bookId]!.playBackPositionInMs =
          playBackPositionInMs;
    }
  }

  void cacheBookAudioData(
      {required int bookId,
      AudioBookFiles? audioBookFiles,
      Metadata? audioFileMetadata}) {
    if (_cachedBooks.containsKey(bookId)) {
      _cachedBooks[bookId]!.audioBookFiles = audioBookFiles;
      _cachedBooks[bookId]!.audioFileMetadata = audioFileMetadata;
    }
  }

  void cacheBookSubtitleData(
      {required int bookId,
      AudioBookFiles? audioBookFiles,
      SubtitlesData? subtitlesData}) {
    if (_cachedBooks.containsKey(bookId)) {
      _cachedBooks[bookId]!.subtitlesData = subtitlesData;
      _cachedBooks[bookId]!.audioBookFiles =
          audioBookFiles; // audiobookfiles contain subtitle files
    }
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
      book.version = BookMigrations.latestVersion;
      final int bookId = await database!.insert("Books", {
        "title": book.title,
        "version": book.version,
        "authorId": book.authorIdentifier,
        "hasThumb": book.hasThumbInt,
        "coverImagePrefix": book.coverImagePrefix,
      });
      Batch batch = database!.batch();
      book.id = bookId;
      batch = addBookRelatedDataBatch(batch, [book]);
      await Future.wait([BookFiles.saveBookContent(book), batch.commit()]);
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

  Future<Book?> getCurrentBook() async {
    if (currentBookId != null) {
      return await getBookById(currentBookId!);
    }
    return null;
  }

  void setCurrentBookId(int bookId) async {
    currentBookId = bookId;
  }

  Future<void> setLastReadTime(
      {required int bookId, required DateTime lastReadTime}) async {
    await database?.rawUpdate('UPDATE Books SET lastReadTime = ? WHERE id = ?',
        [lastReadTime.toIso8601String(), bookId]);
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

  // load books with id for migration from indexeddb
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

  Future<void> removeAudioBookMatchesCache(int bookId) async {
    _cachedBooks[bookId]?.clearMatchesData();
  }

  Future<void> removeBookAudioCache(int bookId) async {
    _cachedBooks[bookId]?.clearAudioData();
  }

  Future<void> removeBookSubtitlesCache(int bookId) async {
    _cachedBooks[bookId]?.clearSubtitlesData();
  }
}
