import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/popup_dictionary_theme_data.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';
import 'package:immersion_reader/providers/local_asset_server_provider.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../reader_js.dart';
import '../widgets/reader/vocabulary_tile_list.dart';

class Reader extends StatefulWidget {
  final LocalAssetsServer? localAssetsServer;
  final DictionaryProvider dictionaryProvider;

  const Reader(
      {super.key,
      required this.localAssetsServer,
      required this.dictionaryProvider});

  @override
  State<Reader> createState() => _ReaderState();
}

class _ReaderState extends State<Reader> {
  VocabularyListStorage? vocabularyListStorage;
  InAppWebViewController? webViewController;
  late ContextMenu contextMenu;

  @override
  void initState() {
    super.initState();
    // _initServer();
    // server = widget.localAssetsServer;
    Future(() async {
      vocabularyListStorage = await VocabularyListStorage.create();
      // translator = await Translator.create();
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
    switch (messageJson['message-type']) {
      case 'lookup':
        {
          int index = messageJson['index'];
          String text = messageJson['text'];
          // print(message.message);
          showVocabularyList(text, index);
          break;
        }
    }
  }

  Future<void> showVocabularyList(String text, int index) async {
    if (index < 0 || index >= text.length) {
      return;
    }
    // move index by one if initial click on space
    if (text[index].trim().isEmpty && text.length > index) {
      index += 1;
    }
    PopupDictionaryTheme popupDictionaryTheme = await widget
        .dictionaryProvider.settingsProvider!
        .getPopupDictionaryTheme();
    PopupDictionaryThemeData popupDictionaryThemeData =
        PopupDictionaryThemeData(popupDictionaryTheme: popupDictionaryTheme);
    showCupertinoModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
              child: Container(
                  height: MediaQuery.of(context).size.height * .40,
                  color: popupDictionaryThemeData
                      .getColor(DictionaryColor.backgroundColor),
                  child: CupertinoScrollbar(
                      child: SingleChildScrollView(
                          controller: ModalScrollController.of(context),
                          child: VocabularyTileList(
                              text: text,
                              targetIndex: index,
                              popupDictionaryThemeData:
                                  popupDictionaryThemeData,
                              dictionaryProvider: widget.dictionaryProvider,
                              vocabularyList: const [],
                              vocabularyListStorage: vocabularyListStorage)))));
        });
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
