import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/book_bookmark.dart';
import 'package:immersion_reader/managers/reader/book_manager.dart';
import 'package:immersion_reader/managers/reader/reader_session_manager.dart';
import 'package:immersion_reader/widgets/audiobook/audio_book_dialog.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderJsManager {
  late InAppWebViewController webController;
  late Function(String) reopenReader;
  StreamController<int> matchProgressController =
      StreamController<int>.broadcast();

  static final ReaderJsManager _singleton = ReaderJsManager._internal();
  ReaderJsManager._internal();

  factory ReaderJsManager.create(
      {required InAppWebViewController webController,
      required Function(String) reopenReader}) {
    _singleton.webController = webController;
    _singleton.reopenReader = reopenReader;
    _singleton.setupController();
    return _singleton;
  }

  factory ReaderJsManager() =>
      _singleton; // should only be called once it is created with a controller

  void setupController() {
    webController.addJavaScriptHandler(
        handlerName: 'getBooks',
        callback: (_) async {
          final List<Book> books = await BookManager().getBooks();
          return books.map((book) => book.toMap()).toList();
        });
    webController.addJavaScriptHandler(
        handlerName: 'getBookById',
        callback: (args) async {
          final int bookId = args.first;
          final Book? book = await BookManager().getBookById(bookId);
          return book?.toMap() ?? {};
        });
    webController.addJavaScriptHandler(
        handlerName: 'setBook',
        callback: (args) async {
          final bookData = args.first;
          final Book book = Book.fromMap(bookData);
          final int newId = await BookManager().setBook(book);
          return newId;
        });
    webController.addJavaScriptHandler(
        handlerName: 'deleteBooksByIds',
        callback: (args) async {
          final List<int> bookIds = List<int>.from(args.first);
          await BookManager().deleteBooksByIds(bookIds);
        });
    webController.addJavaScriptHandler(
        handlerName: 'getBookmarks',
        callback: (_) async {
          final List<BookBookmark> bookmarks =
              await BookManager().getBookmarks();
          return bookmarks.map((bookmark) => bookmark.toMap()).toList();
        });
    webController.addJavaScriptHandler(
        handlerName: 'getBookmarkByBookId',
        callback: (args) async {
          final int bookId = args.first;
          final BookBookmark? bookmark =
              await BookManager().getBookmarkByBookId(bookId);
          return bookmark?.toMap() ?? {};
        });
    webController.addJavaScriptHandler(
        handlerName: 'setBookmark',
        callback: (args) {
          final bookmark = args.first;
          BookManager().setBookmark(BookBookmark.fromMap(bookmark));
        });
    webController.addJavaScriptHandler(
        handlerName: 'onLoadBook',
        callback: (args) {
          final bookData = args.first;
          final Book book = Book.fromMap(bookData);
          book.lastReadTime = DateTime.now();
          ReaderSessionManager().startReadingBook(book);
          BookManager().setLastReadTime(book);
        });
    webController.addJavaScriptHandler(
        handlerName: 'onLoadManager',
        callback: (_) {
          ReaderSessionManager().stop();
          PopupDictionary.create().dismissPopupDictionary();
        });
    webController.addJavaScriptHandler(
        handlerName: 'openAudioBookDialog',
        callback: (args) async {
          ReaderSessionManager().stop();
          final int bookId = args.first;
          final Book? book = await BookManager().getBookById(bookId);
          if (book != null) {
            final sharedPreferences = await SharedPreferences.getInstance();
            AudioBookDialog.showDialog(
                book: book,
                matchProgressController: matchProgressController,
                sharedPreferences: sharedPreferences,
                reopenReader: reopenReader,
                onDismiss: () => ReaderSessionManager().startReadingBook(book));
          }
        });
    webController.addJavaScriptHandler(
        handlerName: 'sendMatchSubtitleProgress',
        callback: (args) async {
          if (args.first != null) {
            matchProgressController.add(args.first);
          }
        });
  }

  Future<dynamic> evaluateJavascript({required String source}) =>
      webController.evaluateJavascript(source: source);

  Future<dynamic> callAsyncJavaScript({required String functionBody}) =>
      webController.callAsyncJavaScript(functionBody: functionBody);
}
