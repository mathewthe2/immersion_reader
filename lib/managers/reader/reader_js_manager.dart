import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_lookup_subtitle.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/book_bookmark.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_player_manager.dart';
import 'package:immersion_reader/managers/reader/book_manager.dart';
import 'package:immersion_reader/managers/reader/reader_session_manager.dart';
import 'package:immersion_reader/utils/reader/highlight_js.dart';
import 'package:immersion_reader/widgets/audiobook/audio_book_dialog.dart';
import 'package:immersion_reader/widgets/popup_dictionary/dialog/popup_dictionary.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderJsManager {
  late InAppWebViewController webController;
  StreamController<int> matchProgressController =
      StreamController<int>.broadcast();

  static final ReaderJsManager _singleton = ReaderJsManager._internal();
  ReaderJsManager._internal();

  factory ReaderJsManager.create(
      {required InAppWebViewController webController}) {
    _singleton.webController = webController;
    _singleton.setupController();
    return _singleton;
  }

  factory ReaderJsManager() =>
      _singleton; // should only be called once it is created with a controller

  AudioLookupSubtitle? lastLookupSubtitleData;

  void setupController() {
    webController.addJavaScriptHandler(
        handlerName: 'lookup',
        callback: (args) {
          final arg = args.first;
          int index = arg['index'];
          String text = arg['text'];
          lastLookupSubtitleData =
              AudioLookupSubtitle.fromMap(arg['subtitleData']);
          ReaderJsManager().defocusReader();
          PopupDictionary().showVocabularyList(
              text: text,
              subtitleId: lastLookupSubtitleData!.subtitleId,
              characterIndex: index,
              onDismiss: ReaderJsManager().focusReader);
        });
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
          if (book.id != null) {
            BookManager().setCurrentBookId(book.id!);
            if (book.lastReadTime != null) {
              BookManager().setLastReadTime(
                  bookId: book.id!, lastReadTime: book.lastReadTime!);
            }
          }
        });
    webController.addJavaScriptHandler(
        handlerName: "onContentDisplayChange",
        callback: (args) {
          int? readCharacters = args.first;
          if (readCharacters != null) {
            ReaderSessionManager()
                .updateProgressOfCurrentContent(readCharacters);
          }
        });
    webController.addJavaScriptHandler(
        handlerName: 'onReaderReady',
        callback: (args) async {
          final bookData = args.first;
          final Book book = Book.fromMap(bookData);
          AudioPlayerManager().loadAudioBookIfExists(book);
        });
    webController.addJavaScriptHandler(
        handlerName: 'onLoadManager',
        callback: (_) {
          ReaderSessionManager().stop();
          PopupDictionary().dismissPopupDictionary();
        });
    webController.addJavaScriptHandler(
        handlerName: 'openAudioBookDialog',
        callback: (args) async {
          ReaderSessionManager().stop();
          final int bookId = args.first;
          final Book? book = await BookManager().getBookById(bookId);
          if (book != null) {
            final sharedPreferences = await SharedPreferences.getInstance();
            defocusReader();
            AudioBookDialog.showDialog(
                book: book,
                matchProgressController: matchProgressController,
                sharedPreferences: sharedPreferences,
                onDismiss: () {
                  focusReader();
                  ReaderSessionManager().startReadingBook(book);
                });
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

  Future<void> reloadReader() async {
    await webController.evaluateJavascript(source: dispatchReloadEvent);
  }

  Future<void> defocusReader() async {
    await webController.evaluateJavascript(
        source: updateIsEnableSwipeInReader(false));
  }

  Future<void> focusReader() async {
    await webController.evaluateJavascript(
        source: updateIsEnableSwipeInReader(true));
  }

  Future<void> highlightLastSelected(
      {required int initialOffset, required int textLength}) async {
    await webController.evaluateJavascript(
        source: "highlightLast($initialOffset, $textLength)");
  }

  void setLastSubtitleTextLength(int textLength) {
    lastLookupSubtitleData?.textLength = textLength;
  }

  Future<void> removeHighlight() async {
    await webController.evaluateJavascript(source: "removeHighlight()");
  }

  Future<dynamic> evaluateJavascript({required String source}) =>
      webController.evaluateJavascript(source: source);

  Future<dynamic> callAsyncJavaScript({required String functionBody}) =>
      webController.callAsyncJavaScript(functionBody: functionBody);
}
