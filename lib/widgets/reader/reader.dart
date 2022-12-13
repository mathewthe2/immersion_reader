import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';
import 'package:immersion_reader/providers/local_asset_server_provider.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../utils/reader/reader_js.dart';

class Reader extends StatefulWidget {
  final LocalAssetsServer? localAssetsServer;
  final DictionaryProvider dictionaryProvider;
  final String? initialUrl;
  final bool isAddBook;

  const Reader(
      {super.key,
      required this.localAssetsServer,
      required this.dictionaryProvider,
      this.initialUrl,
      this.isAddBook = false});

  @override
  State<Reader> createState() => _ReaderState();
}

class _ReaderState extends State<Reader> {
  VocabularyListStorage? vocabularyListStorage;
  InAppWebViewController? webViewController;
  late PopupDictionary popupDictionary;
  int? lastTimestamp;
  static int timeStampDiff = 20; // recently opened
  bool hasShownAddedDialog = false;
  bool hasInjectedReaderJs = false;

  Future<void> createPopupDictionary() async {
    vocabularyListStorage = await VocabularyListStorage.create();
    popupDictionary = PopupDictionary(
        parentContext: context,
        vocabularyListStorage: vocabularyListStorage!,
        dictionaryProvider: widget.dictionaryProvider);
  }

  static String addFileJs = """
      try {
        document.getElementsByClassName('xl:mr-1')[0].click();
        console.log("injected-open-file")
      } catch {}
      """;

  void handleMessage(ConsoleMessage message) {
    if (message.message == "injected-open-file") {
      hasShownAddedDialog = true;
      return;
    }
    if (message.message == "injected-reader-js") {
      hasInjectedReaderJs = true;
      return;
    }
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

// @override
//   void initState() {
//     super.initState();
//     isAddBook = widget.isAddBook;
//   }

  @override
  Widget build(BuildContext context) {
    if (widget.localAssetsServer == null) {
      return const Center(
          child: CupertinoActivityIndicator(
        animating: true,
        radius: 24,
      ));
    }
    return SafeArea(
        child: FutureBuilder(
            future: createPopupDictionary(),
            builder: ((context, snapshot) {
              return InAppWebView(
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        cacheEnabled: true, incognito: false)),
                initialUrlRequest: URLRequest(
                  url: Uri.parse(
                    widget.initialUrl ??
                        'http://localhost:${LocalAssetsServerProvider.port}',
                  ),
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStop: (controller, uri) async {
                  if (!hasInjectedReaderJs) {
                    await controller.evaluateJavascript(source: readerJs);
                  }
                  if (widget.isAddBook && !hasShownAddedDialog) {
                    await controller.evaluateJavascript(source: addFileJs);
                  }
                },
                onLoadError: (controller, url, code, message) {
                  debugPrint(message);
                },
                onLoadHttpError: (controller, url, statusCode, description) {
                  debugPrint('$statusCode:$description');
                },
                onTitleChanged: (controller, title) async {
                  await controller.evaluateJavascript(source: readerJs);
                  if (widget.isAddBook && !hasShownAddedDialog) {
                    await controller.evaluateJavascript(source: addFileJs);
                  }
                },
                onConsoleMessage: (controller, message) {
                  handleMessage(message);
                },
              );
            })));
  }
}
