import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/profile/profile_content.dart';
import 'package:immersion_reader/managers/reader/local_asset_server_manager.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/utils/system_ui.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary.dart';
import 'package:immersion_reader/widgets/reader/message_controller.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../utils/reader/reader_js.dart';

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
  late PopupDictionary popupDictionary;
  late MessageController messageController;

  void createPopupDictionary() {
    messageController =
        MessageController(exitCallback: () => Navigator.of(context).pop());
  }

  static const String addFileJs = """
      try {
        document.getElementsByClassName('xl:mr-1')[0].click();
        console.log("injected-open-file")
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
        valueListenable: messageController.messageControllerNotifier,
        builder: (context, val, child) => FutureBuilder<Color>(
            future: SettingsManager().getReaderBackgroundColor(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                    color: snapshot.data!, // sync with reader color
                    child: SafeArea(
                        child: InAppWebView(
                      initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                              cacheEnabled: true, incognito: false)),
                      initialUrlRequest: URLRequest(
                        url: Uri.parse(
                          widget.initialUrl ??
                              LocalAssetsServerManager().getAssetUrl(),
                        ),
                      ),
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      onLoadStop: (controller, uri) async {
                        if (!messageController.hasInjectedPopupJs) {
                          await controller.evaluateJavascript(source: readerJs);
                        }
                        if (widget.isAddBook &&
                            !messageController.hasShownAddedDialog) {
                          await controller.evaluateJavascript(
                              source: addFileJs);
                        }
                      },
                      onLoadError: (controller, url, code, message) {
                        debugPrint(message);
                      },
                      onLoadHttpError:
                          (controller, url, statusCode, description) {
                        debugPrint('$statusCode:$description');
                      },
                      onTitleChanged: (controller, title) async {
                        await controller.evaluateJavascript(source: readerJs);
                        if (widget.isAddBook &&
                            !messageController.hasShownAddedDialog) {
                          await controller.evaluateJavascript(
                              source: addFileJs);
                        }
                      },
                      onConsoleMessage: (controller, message) {
                        messageController.execute(message);
                      },
                    )));
              } else {
                return Container();
              }
            }));
  }
}
