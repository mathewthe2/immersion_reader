import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/providers/reader_session_provider.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary.dart';

class MessageController {
  static int timeStampDiff = 20; // recently opened
  int? lastTimestamp;
  bool hasShownAddedDialog = false;
  bool hasInjectedPopupJs = false;
  bool isReadingBook = false;
  ReaderSessionProvider? readerSessionProvider;
  PopupDictionary popupDictionary;
  VoidCallback? exitCallback;
  VoidCallback? readerSettingsCallback;

  MessageController._internal(
      {required this.popupDictionary,
      this.readerSessionProvider,
      this.exitCallback,
      this.readerSettingsCallback});

  factory MessageController(
          {required PopupDictionary popupDictionary,
          ReaderSessionProvider? readerSessionProvider,
          VoidCallback? exitCallback,
          VoidCallback? readerSettingsCallback}) =>
      MessageController._internal(
          popupDictionary: popupDictionary,
          readerSessionProvider: readerSessionProvider,
          exitCallback: exitCallback,
          readerSettingsCallback: readerSettingsCallback);

  void execute(ConsoleMessage message) {
    debugPrint(message.message);
    switch (message.message) {
      case "injected-open-file":
        hasShownAddedDialog = true;
        break;
      case 'injected-popup-js':
        hasInjectedPopupJs = true;
        break;
      case 'launch-immersion-reader':
        if (exitCallback != null) {
          exitCallback!();
        }
        break;
      case 'launch-immersion-reader-settings':
        if (readerSettingsCallback != null) {
          readerSettingsCallback!();
        }
        break;
      default:
        {
          late Map<String, dynamic> messageJson;
          try {
            messageJson = jsonDecode(message.message);
          } catch (e) {
            debugPrint(message.message);
            return;
          }
          bool isRecentMessage = lastTimestamp != null &&
              messageJson['timestamp'] - lastTimestamp < timeStampDiff;
          lastTimestamp = messageJson['timestamp'];
          if (isRecentMessage) {
            return;
          }
          switch (messageJson['message-type']) {
            case 'lookup':
              {
                int index = messageJson['index'];
                String text = messageJson['text'];
                // print(message.message);
                popupDictionary.showVocabularyList(text, index);
                break;
              }
            case 'load-book':
              {
                int bookId = messageJson['bookId'];
                String title = messageJson['title'];
                int? totalCharacters = messageJson['bookCharCount'];
                readerSessionProvider?.start(
                    key: bookId.toString(),
                    title: title,
                    contentLength: totalCharacters);
                isReadingBook = true;
                break;
              }
            case 'load-manager':
              {
                readerSessionProvider?.stop();
                isReadingBook = false;
                break;
              }
            case 'content-display-change':
            {
              int? readCharacters = messageJson['exploredCharCount'];
              if (readCharacters != null) {
                  readerSessionProvider?.updateProgressOfCurrentContent(readCharacters);
              }
            }
          }
        }
    }
  }
}
