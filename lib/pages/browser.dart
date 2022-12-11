import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/providers/browser_provider.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/utils/browser/browser_js.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';
import 'package:immersion_reader/widgets/browser/browser_bottom_bar.dart';
import 'package:immersion_reader/widgets/browser/browser_top_bar.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary.dart';

class Browser extends StatefulWidget {
  final BrowserProvider? browserProider;
  final DictionaryProvider dictionaryProvider;
  final bool hasUserControls;
  final String? initialUrl;

  const Browser(
      {super.key,
      this.browserProider,
      required this.dictionaryProvider,
      this.initialUrl,
      this.hasUserControls = true});

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  InAppWebViewController? webViewController;
  VocabularyListStorage? vocabularyListStorage;
  late PopupDictionary popupDictionary;
  int? lastTimestamp;
  late String initialUrl;
  static int timeStampDiff = 20; // recently opened

  @override
  void initState() {
    super.initState();
    initialUrl = widget.initialUrl ?? 'https://syosetu.com/';
  }

  Future<void> getDictionaryAndBookmarks() async {
    vocabularyListStorage = await VocabularyListStorage.create();
    popupDictionary = PopupDictionary(
        parentContext: context,
        dictionaryProvider: widget.dictionaryProvider,
        vocabularyListStorage: vocabularyListStorage!);
    if (widget.browserProider != null) {
      widget.browserProider!.getBookmarks();
    }
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
    bool hasNoUserControls =
        webViewController == null || !widget.hasUserControls;
    return SafeArea(
        child: FutureBuilder(
            future: getDictionaryAndBookmarks(),
            builder: ((context, snapshot) {
              return Column(children: [
                hasNoUserControls
                    ? Container()
                    : BrowserTopBar(webViewController: webViewController!),
                Expanded(
                    child: Stack(children: [
                  InAppWebView(
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                            cacheEnabled: true, incognito: false)),
                    initialUrlRequest: URLRequest(
                      url: Uri.parse(initialUrl),
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
                  ),
                  hasNoUserControls
                      ? Container()
                      : BrowserBottomBar(
                          browserProider: widget.browserProider,
                          webViewController: webViewController)
                ]))
              ]);
            })));
  }
}
