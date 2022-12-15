import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/providers/browser_provider.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/utils/browser/browser_js.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';
import 'package:immersion_reader/widgets/browser/browser_bottom_bar.dart';
import 'package:immersion_reader/widgets/browser/browser_top_bar.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary.dart';
import 'package:immersion_reader/widgets/reader/message_controller.dart';

class Browser extends StatefulWidget {
  final BrowserProvider? browserProvider;
  final DictionaryProvider dictionaryProvider;
  final bool hasUserControls;
  final String? initialUrl;

  const Browser(
      {super.key,
      this.browserProvider,
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
  late MessageController messageController;
  late String initialUrl;

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
    messageController = MessageController(popupDictionary: popupDictionary);
    if (widget.browserProvider != null) {
      widget.browserProvider!.getBookmarks();
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
                      messageController.execute(message);
                    },
                  ),
                  hasNoUserControls
                      ? Container()
                      : BrowserBottomBar(
                          browserProvider: widget.browserProvider,
                          webViewController: webViewController)
                ]))
              ]);
            })));
  }
}
