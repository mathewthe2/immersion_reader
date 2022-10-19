import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';
import 'package:immersion_reader/providers/local_asset_server_provider.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import './reader_js.dart';
import 'japanese/vocabulary.dart';
import 'widgets/reader/vocabulary_tile_list.dart';
import 'package:immersion_reader/utils/language_utils.dart';

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

  void showVocabularyList(String text, int index) async {
    String sentence = text.substring(index, text.length);
    List<Vocabulary> vocabs =
        await widget.dictionaryProvider.findTerm(sentence);
    if (vocabs.isNotEmpty) {
      for (Vocabulary vocab in vocabs) {
        vocab.sentence = LanguageUtils.findSentence(text, index);
      }
      showCupertinoModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return SafeArea(
                child: Container(
                    height: MediaQuery.of(context).size.height * .40,
                    color: CupertinoColors.darkBackgroundGray,
                    child: CupertinoScrollbar(
                        child: SingleChildScrollView(
                            controller: ModalScrollController.of(context),
                            child: VocabularyTileList(
                                vocabularyList: vocabs,
                                vocabularyListStorage:
                                    vocabularyListStorage)))));
          });
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
