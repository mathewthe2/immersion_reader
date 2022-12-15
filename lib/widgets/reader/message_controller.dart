import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary.dart';

class MessageController {
  static int timeStampDiff = 20; // recently opened
  int? lastTimestamp;
  bool hasShownAddedDialog = false;
  bool hasInjectedPopupJs = false;
  PopupDictionary popupDictionary;

  MessageController._internal({required this.popupDictionary});

  factory MessageController({required PopupDictionary popupDictionary}) =>
      MessageController._internal(popupDictionary: popupDictionary);

  void execute(ConsoleMessage message) {
    switch (message.message) {
      case "injected-open-file":
        {
          hasShownAddedDialog = true;
          return;
        }
      case "injected-popup-js":
        {
          hasInjectedPopupJs = true;
          return;
        }
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
          }
        }
    }
  }
}
