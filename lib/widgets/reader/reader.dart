import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:immersion_reader/data/profile/profile_content.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/managers/reader/local_asset_server_manager.dart';
import 'package:immersion_reader/managers/reader/reader_js_manager.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/utils/system_ui.dart';
import 'package:immersion_reader/widgets/audiobook/controls/bottom_playback_controls.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:star_menu/star_menu.dart';

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
  StarMenuController starMenuController = StarMenuController();

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

  Widget menu(int index) {
    return ValueListenableBuilder(
        valueListenable: ReaderJsManager().isTappedCanvasNotifyList[index],
        builder: (context, val, child) {
          if (val != null && val) {
            ReaderJsManager().isTappedCanvasNotifyList[index].value = false;
            return ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                iconSize: 10,
                shape: CircleBorder(),
                backgroundColor: Colors.blue, // <-- Button color
                foregroundColor: Colors.red, // <-- Splash color
              ),
              child: Icon(CupertinoIcons.search, color: Colors.white, size: 20),
            );
          }
          return Visibility(
            visible: false,
            child: Container(),
          );
        });
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
    return ValueListenableBuilder(
        valueListenable: ReaderJsManager().readerSettingsUpdateNotifier,
        builder: (context, val, child) => FutureBuilder<Color>(
            future: SettingsManager().getReaderBackgroundColor(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                    color: snapshot.data!, // sync with reader color
                    child: SafeArea(
                      child: Column(children: [
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
                                starMenuController: starMenuController);
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
                        ).addStarMenu(
                          lazyItems: () async {
                            return [
                              menu(0),
                              menu(1),
                              menu(2),
                            ];
                          },
                          params: StarMenuParameters.arc(ArcType.semiLeft,
                              radiusX: context.arc(), radiusY: context.arc()),
                          controller: starMenuController,
                        )),
                        BottomPlaybackControls(backgroundColor: snapshot.data!),
                      ]),
                    ));
              } else {
                return Container();
              }
            }));
  }
}
