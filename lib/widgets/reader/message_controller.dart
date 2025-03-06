import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/managers/reader/reader_session_manager.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary.dart';
import 'package:immersion_reader/widgets/reader/highlight_controller.dart';

class MessageController {
  static int timeStampDiff = 20; // recently opened
  int? lastTimestamp;
  bool hasShownAddedDialog = false;
  bool hasInjectedPopupJs = false;
  bool isReadingBook = false;
  VoidCallback? exitCallback;
  VoidCallback? readerAudioCallback;
  Function(String javascript)? evaluateJavascript;

  ValueNotifier<bool> messageControllerNotifier = ValueNotifier(false);

  MessageController._internal(
      {this.exitCallback, this.readerAudioCallback, this.evaluateJavascript});

  factory MessageController(
          {VoidCallback? exitCallback,
          VoidCallback? readerAudioCallback,
          Function(String javascript)? evaluateJavascript}) =>
      MessageController._internal(
          exitCallback: exitCallback,
          readerAudioCallback: readerAudioCallback,
          evaluateJavascript: evaluateJavascript);

  void evaluate(String javascript) {
    if (evaluateJavascript != null) {
      evaluateJavascript!(javascript);
    }
  }

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
      case 'launch-immersion-reader-audio':
        if (readerAudioCallback != null) {
          readerAudioCallback!();
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
              messageJson.containsKey('timestamp') &&
              messageJson['timestamp'] - lastTimestamp < timeStampDiff;
          lastTimestamp = messageJson['timestamp'] ?? lastTimestamp;
          if (isRecentMessage) {
            return;
          }
          switch (messageJson['messageType']) {
            case 'lookup':
              {
                int index = messageJson['index'];
                String text = messageJson['text'];
                // print(message.message);
                PopupDictionary.create(
                        highlightController: HighlightController(
                            evaluateJavascript: evaluateJavascript))
                    .showVocabularyList(text, index);
                break;
              }
            case 'load-book':
              {
                int bookId = messageJson['bookId'];
                String title = messageJson['title'];
                int? totalCharacters = messageJson['bookCharCount'];
                ReaderSessionManager().start(
                    key: bookId.toString(),
                    title: title,
                    contentLength: totalCharacters);
                isReadingBook = true;
                break;
              }
            case 'load-manager':
              {
                ReaderSessionManager().stop();
                PopupDictionary.create().dismissPopupDictionary();
                isReadingBook = false;
                break;
              }
            case 'content-display-change':
              {
                int? readCharacters = messageJson['exploredCharCount'];
                if (readCharacters != null) {
                  ReaderSessionManager()
                      .updateProgressOfCurrentContent(readCharacters);
                }
                break;
              }
            case 'settings-change':
              {
                String optionKey = messageJson['optionKey'];
                String optionValue = messageJson['optionValue'];
                if (optionKey == 'selectedTheme') {
                  SettingsManager().setReaderBackgroundColor(optionValue);
                  messageControllerNotifier.value =
                      !messageControllerNotifier.value;
                }
                break;
              }
          }
        }
    }
  }
}
