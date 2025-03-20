import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/book_bookmark.dart';
import 'package:immersion_reader/managers/reader/book_manager.dart';
import 'package:immersion_reader/managers/reader/reader_session_manager.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary.dart';

class ReaderJsManager {
  static setupController(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
        handlerName: 'getBooks',
        callback: (_) async {
          final List<Book> books = await BookManager().getBooks();
          return books.map((book) => book.toMap()).toList();
        });
    controller.addJavaScriptHandler(
        handlerName: 'getBookById',
        callback: (args) async {
          final int bookId = args.first;
          final Book? book = await BookManager().getBookById(bookId);
          return book?.toMap() ?? {};
        });
    controller.addJavaScriptHandler(
        handlerName: 'setBook',
        callback: (args) async {
          final bookData = args.first;
          final Book book = Book.fromMap(bookData);
          final int newId = await BookManager().setBook(book);
          return newId;
        });
    controller.addJavaScriptHandler(
        handlerName: 'deleteBooksByIds',
        callback: (args) async {
          final List<int> bookIds = List<int>.from(args.first);
          await BookManager().deleteBooksByIds(bookIds);
        });
    controller.addJavaScriptHandler(
        handlerName: 'getBookmarks',
        callback: (_) async {
          final List<BookBookmark> bookmarks =
              await BookManager().getBookmarks();
          return bookmarks.map((bookmark) => bookmark.toMap()).toList();
        });
    controller.addJavaScriptHandler(
        handlerName: 'getBookmarkByBookId',
        callback: (args) async {
          final int bookId = args.first;
          final BookBookmark? bookmark =
              await BookManager().getBookmarkByBookId(bookId);
          return bookmark?.toMap() ?? {};
        });
    controller.addJavaScriptHandler(
        handlerName: 'setBookmark',
        callback: (args) {
          final bookmark = args.first;
          BookManager().setBookmark(BookBookmark.fromMap(bookmark));
        });
    controller.addJavaScriptHandler(
        handlerName: 'onLoadBook',
        callback: (args) {
          final bookData = args.first;
          final Book book = Book.fromMap(bookData);
          book.lastReadTime = DateTime.now();
          ReaderSessionManager().start(
              key: book.id.toString(),
              title: book.title,
              contentLength: book.totalCharacters);
          BookManager().setLastReadTime(book);
        });
    controller.addJavaScriptHandler(
        handlerName: 'onLoadManager',
        callback: (_) {
          ReaderSessionManager().stop();
          PopupDictionary.create().dismissPopupDictionary();
        });
  }
}
