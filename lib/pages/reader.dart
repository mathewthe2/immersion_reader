import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';
import 'package:immersion_reader/providers/local_asset_server_provider.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../utils/reader/reader_js.dart';

class Reader extends StatefulWidget {
  final LocalAssetsServer? localAssetsServer;
  final DictionaryProvider dictionaryProvider;
  final String? initialUrl;

  const Reader(
      {super.key,
      required this.localAssetsServer,
      required this.dictionaryProvider,
      this.initialUrl});

  @override
  State<Reader> createState() => _ReaderState();
}

class _ReaderState extends State<Reader> {
  VocabularyListStorage? vocabularyListStorage;
  InAppWebViewController? webViewController;
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
          vocabularyListStorage: vocabularyListStorage!,
          dictionaryProvider: widget.dictionaryProvider);
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
          // print(message.message);
          popupDictionary.showVocabularyList(text, index);
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return (widget.localAssetsServer != null)
        ? SafeArea(
            child: InAppWebView(
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform:
                    InAppWebViewOptions(cacheEnabled: true, incognito: false)),
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
              await controller.evaluateJavascript(source: readerJs);
            },
            onTitleChanged: (controller, title) async {
              await controller.evaluateJavascript(source: readerJs);
            },
            onConsoleMessage: (controller, message) {
              handleMessage(message);
            },
          ))
        : const Center(
            child: CupertinoActivityIndicator(
            animating: true,
            radius: 24,
          ));
  }
}
