import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:immersion_reader/data/profile/profile_content.dart';
import 'package:immersion_reader/managers/reader/local_asset_server_manager.dart';
import 'package:immersion_reader/managers/reader/reader_js_manager.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/utils/system_ui.dart';
import 'package:immersion_reader/widgets/audiobook/controls/bottom_playback_controls.dart';
import 'package:immersion_reader/widgets/reader/search/search_dialog_content.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pie_menu/pie_menu.dart';

class Reader extends StatefulWidget {
  final String? initialUrl;
  final bool isAddBook;
  final bool isShowDeviceStatusBar;

  const Reader(
      {super.key,
      this.initialUrl,
      this.isAddBook = false,
      this.isShowDeviceStatusBar = false});

  @override
  State<Reader> createState() => _ReaderState();
}

class _ReaderState extends State<Reader> {
  InAppWebViewController? webViewController;
  ProfileContent? currentProfileContent;
  final pieMenuController = PieMenuController();

  void createPopupDictionary() {
    ReaderJsManager().setExitCallback(() => Navigator.of(context).pop());
  }

  static const String addFileJs = """
      try {
        document.getElementsByClassName('xl:mr-1')[0].click();
        if (window.flutter_inappwebview != null) {
          window.flutter_inappwebview.callHandler('injectedOpenFile');
        }
      } catch {}
      """;

  @override
  void initState() {
    super.initState();
    if (!widget.isShowDeviceStatusBar) {
      hideSystemUI();
    }
    createPopupDictionary();
  }

  @override
  void dispose() {
    ReaderJsManager().onExitReader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LocalAssetsServer? localAssetsServer = LocalAssetsServerManager().server;
    if (localAssetsServer == null) {
      return const Center(
          child: CupertinoActivityIndicator(
        animating: true,
        radius: 24,
      ));
    }
    return PieCanvas(
        child: ValueListenableBuilder(
            valueListenable: ReaderJsManager().readerSettingsUpdateNotifier,
            builder: (context, val, child) => FutureBuilder<Color>(
                future: SettingsManager().getReaderBackgroundColor(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                        color: snapshot.data!, // sync with reader color
                        child: SafeArea(
                            child: Stack(fit: StackFit.expand, children: [
                          Column(children: [
                            Expanded(
                                child: InAppWebView(
                              initialSettings: InAppWebViewSettings(
                                  cacheEnabled: true, incognito: false),
                              initialUrlRequest: URLRequest(
                                url: WebUri(
                                  widget.initialUrl ??
                                      LocalAssetsServerManager().getAssetUrl(),
                                ),
                              ),
                              onWebViewCreated: (controller) {
                                ReaderJsManager.create(
                                    webController: controller,
                                    pieMenuController: pieMenuController);
                                webViewController = controller;
                              },
                              onLoadStop: (controller, uri) async {
                                if (widget.isAddBook &&
                                    !ReaderJsManager().hasShownAddedDialog) {
                                  await controller.evaluateJavascript(
                                      source: addFileJs);
                                }
                              },
                              onReceivedError: (controller, request, error) {
                                debugPrint(error.description);
                              },
                              onReceivedHttpError:
                                  (controller, url, errorResponse) {
                                debugPrint(
                                    '${errorResponse.statusCode}:${errorResponse.data}');
                              },
                              onTitleChanged: (controller, title) async {
                                if (widget.isAddBook &&
                                    !ReaderJsManager().hasShownAddedDialog) {
                                  await controller.evaluateJavascript(
                                      source: addFileJs);
                                }
                              },
                              onConsoleMessage: (controller, message) {
                                debugPrint(
                                    "reader stuff: ${message.message}"); // for debug
                              },
                            )),
                            BottomPlaybackControls(
                                backgroundColor: snapshot.data!),
                          ]),
                          Align(
                              alignment: Alignment.centerRight,
                              child: PieMenu(
                                  controller: pieMenuController,
                                  theme: PieTheme.of(context).copyWith(
                                      pointerColor: CupertinoColors.transparent,
                                      buttonTheme: PieButtonTheme(
                                          backgroundColor: CupertinoColors
                                              .darkBackgroundGray,
                                          iconColor: CupertinoColors.white)),
                                  actions: [
                                    PieAction(
                                      tooltip: Container(),
                                      onSelect: () {},
                                      child: const Icon(CupertinoIcons.home),
                                    ),
                                    PieAction(
                                      tooltip: Container(),
                                      onSelect: () => ReaderJsManager()
                                          .openAudioBookDialog(),
                                      child:
                                          const Icon(CupertinoIcons.headphones),
                                    ),
                                    PieAction(
                                      tooltip:
                                          Container(), // display nothing when hovered
                                      onSelect: () => SmartDialog.show(
                                          alignment: Alignment.bottomCenter,
                                          builder: (context) {
                                            return SearchDialogContent();
                                          }),
                                      child: const Icon(CupertinoIcons.search),
                                    ),
                                  ],
                                  child: GestureDetector(
                                      onTap: () => pieMenuController.openMenu(),
                                      child: Container(
                                          width: 0,
                                          height: 0,
                                          color:
                                              CupertinoColors.transparent)))),
                        ])));
                  } else {
                    return Container();
                  }
                })));
  }
}
