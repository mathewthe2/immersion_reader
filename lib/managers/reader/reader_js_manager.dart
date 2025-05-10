import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_load_params.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_lookup_subtitle.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/book_bookmark.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_player_handler.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_player_manager.dart';
import 'package:immersion_reader/managers/reader/book_manager.dart';
import 'package:immersion_reader/managers/reader/reader_session_manager.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/utils/reader/highlight_js.dart';
import 'package:immersion_reader/widgets/audiobook/dialog/audio_book_dialog.dart';
import 'package:immersion_reader/widgets/popup_dictionary/dialog/popup_dictionary.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderJsManager {
  late InAppWebViewController webController;
  PieMenuController? pieMenuController;
  StreamController<int> matchProgressController =
      StreamController<int>.broadcast();

  static final ReaderJsManager _singleton = ReaderJsManager._internal();
  ReaderJsManager._internal();

  factory ReaderJsManager.create(
      {required InAppWebViewController webController,
      PieMenuController? pieMenuController}) {
    _singleton.webController = webController;
    _singleton.pieMenuController = pieMenuController;
    _singleton.setupController();
    _singleton.isReaderActive = true;
    return _singleton;
  }

  factory ReaderJsManager() =>
      _singleton; // should only be called once it is created with a controller

  ValueNotifier<bool> readerSettingsUpdateNotifier = ValueNotifier(false);
  AudioLookupSubtitle? lastLookupSubtitleData;
  VoidCallback? exitCallback;
  int? currentBookId;
  bool hasShownAddedDialog = false;
  late bool isReaderResized;
  late bool isReaderActive;

  void setupController() {
    webController.addJavaScriptHandler(
        handlerName: 'lookup',
        callback: (args) {
          final Map<String, dynamic> arg = args.first;
          int index = arg['index'];
          String text = arg['text'];
          if (arg.containsKey('subtitleData')) {
            lastLookupSubtitleData =
                AudioLookupSubtitle.fromMap(arg['subtitleData']);
          } else {
            lastLookupSubtitleData = null;
          }
          ReaderJsManager().defocusReader();
          PopupDictionary().showVocabularyList(
              text: text,
              subtitleId: lastLookupSubtitleData?.subtitleId,
              characterIndex: index,
              onDismiss: ReaderJsManager().focusReader);
        });
    webController.addJavaScriptHandler(
        handlerName: 'onTapCanvas',
        callback: (_) {
          pieMenuController?.openMenu(
            menuAlignment: Alignment.center,
          );
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
        handlerName: "onReaderResize",
        callback: (_) {
          isReaderResized = true;
        });
    webController.addJavaScriptHandler(
        handlerName: 'onReaderReady', // called when a book is opened and ready
        callback: (args) async {
          final bookId = args.first["bookId"];
          currentBookId = bookId;
          final playBackPositionInMs = args.first["playBackPositionInMs"];
          isReaderResized = false;
          Book? book = await BookManager().getBookById(bookId);
          if (book?.audioBookFiles != null &&
              book!.audioBookFiles!.isHaveAudio) {
            await AudioPlayerHandler.setup();
            await AudioPlayerManager().loadAudioBookIfExists(
                AudioBookLoadParams(
                    bookId: book.id,
                    bookTitle: book.title,
                    playBackPositionInMs: playBackPositionInMs));
          } else {
            // for removing bottom bar and audio player when switching books
            AudioPlayerManager().pause();
            AudioPlayerManager()
                .broadcastOperation(AudioBookOperation.removeAudioFile);
          }
        });
    webController.addJavaScriptHandler(
        handlerName: 'launchImmersionReader',
        callback: (args) async {
          if (exitCallback != null) {
            exitCallback!();
          }
        });
    webController.addJavaScriptHandler(
        handlerName: 'settingsChange',
        callback: (args) {
          final data = args.first;
          String optionKey = data['optionKey'];
          String optionValue = data['optionValue'];
          if (optionKey == 'selectedTheme') {
            SettingsManager().setReaderBackgroundColor(optionValue);
            readerSettingsUpdateNotifier.value =
                !readerSettingsUpdateNotifier.value; // toggle update
          }
        });
    webController.addJavaScriptHandler(
        handlerName: 'injectedOpenFile',
        callback: (_) {
          hasShownAddedDialog = true;
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
          // final int bookId = args.first;
          await openAudioBookDialog();
        });
    webController.addJavaScriptHandler(
        handlerName: 'sendMatchSubtitleProgress',
        callback: (args) async {
          if (args.first != null) {
            matchProgressController.add(args.first);
          }
        });
  }

  Future<void> openAudioBookDialog({int? initialTabIndex}) async {
    if (currentBookId == null) return;
    ReaderSessionManager().stop();
    final Book? book = await BookManager().getBookById(currentBookId!);
    if (book != null) {
      final sharedPreferences = await SharedPreferences.getInstance();
      defocusReader();
      AudioBookDialog.showDialog(
          book: book,
          initialTabIndex: initialTabIndex,
          matchProgressController: matchProgressController,
          sharedPreferences: sharedPreferences,
          onDismiss: () {
            focusReader();
            ReaderSessionManager().startReadingBook(book);
          });
    }
  }

  void setExitCallback(VoidCallback callback) {
    exitCallback = callback;
  }

  void allowShowAddFileDialog() {
    hasShownAddedDialog = false;
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
    await webController.evaluateJavascript(source: """
      document.dispatchEvent(
        new CustomEvent('ttu-action', {
          detail: {
            type: 'highlightLast',
            initialOffset: $initialOffset,
            textLength: $textLength,
          },
        }),
		);
    """);
  }

  void setLastSubtitleTextLength(int textLength) {
    lastLookupSubtitleData?.textLength = textLength;
  }

  Future<void> removeHighlight() async {
    await webController.evaluateJavascript(source: """
      document.dispatchEvent(
        new CustomEvent('ttu-action', {
          detail: {
            type: 'removeHighlight',
          },
        }),
		);
    """);
  }

  Future<void> cueToCharacter(int characterCount) async {
    await webController.evaluateJavascript(source: """
      document.dispatchEvent(
        new CustomEvent('ttu-action', {
          detail: {
            type: 'cueToCharacter',
            characterCount: $characterCount
          },
        }),
		);
    """);
  }

  void onExitReader() {
    isReaderActive = false;
    AudioPlayerManager().disposeIfNotRunning();
  }

  Future<dynamic> evaluateJavascript({required String source}) async {
    if (isReaderActive) {
      return await webController.evaluateJavascript(source: source);
    }
  }

  Future<dynamic> callAsyncJavaScript({required String functionBody}) async {
    if (isReaderActive) {
      return await webController.callAsyncJavaScript(
          functionBody: functionBody);
    }
  }
}
