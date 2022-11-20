import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/utils/browser/browser_js.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';
import 'package:immersion_reader/widgets/browser/browser_bar.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary.dart';

class Browser extends StatefulWidget {
  final DictionaryProvider dictionaryProvider;

  const Browser({super.key, required this.dictionaryProvider});

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  InAppWebViewController? webViewController;
  VocabularyListStorage? vocabularyListStorage;
  late PopupDictionary popupDictionary;
  int? lastTimestamp;
  static int timeStampDiff = 20; // recently opened

  @override
  void initState() {
    super.initState();
    Future(() async {
      vocabularyListStorage = await VocabularyListStorage.create();
      popupDictionary = PopupDictionary(
          parentContext: context,
          dictionaryProvider: widget.dictionaryProvider,
          vocabularyListStorage: vocabularyListStorage!);
    });
  }

  void handleMessage(ConsoleMessage message) {
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
          popupDictionary.showVocabularyList(text, index);
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(children: [
      webViewController == null
          ? Container()
          : BrowserBar(webViewController: webViewController!),
      Expanded(
          child: Stack(children: [
        InAppWebView(
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform:
                  InAppWebViewOptions(cacheEnabled: true, incognito: false)),
          initialUrlRequest: URLRequest(
            url: Uri.parse(
              'https://syosetu.com/',
            ),
          ),
          onWebViewCreated: (controller) {
            setState(() {
              webViewController = controller;
            });
          },
          onLoadStop: (controller, uri) async {
            await controller.evaluateJavascript(source: browserJs);
          },
          onTitleChanged: (controller, title) async {
            await controller.evaluateJavascript(source: browserJs);
          },
          onConsoleMessage: (controller, message) {
            handleMessage(message);
          },
        )
      ]))
    ]));
  }
}
