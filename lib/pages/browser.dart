import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/data/browser/browser_dark_reader_control.dart';
import 'package:immersion_reader/managers/browser/browser_manager.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/utils/browser/browser_content_blockers.dart';
import 'package:immersion_reader/utils/browser/browser_js.dart';
import 'package:immersion_reader/widgets/browser/browser_bottom_bar.dart';
import 'package:immersion_reader/widgets/browser/browser_top_bar.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary.dart';
import 'package:immersion_reader/widgets/reader/message_controller.dart';

class Browser extends StatefulWidget {
  final bool hasUserControls;
  final String? initialUrl;

  const Browser({super.key, this.initialUrl, this.hasUserControls = true});

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  final ValueNotifier<bool> _notifier = ValueNotifier(false);
  InAppWebViewController? webViewController;
  VocabularyListStorage? vocabularyListStorage;
  late PopupDictionary popupDictionary;
  late MessageController messageController;
  late String initialUrl;
  List<ContentBlocker> contentBlockers = [];
  bool scriptsLoaded = false;

  @override
  void initState() {
    super.initState();
    initialUrl = widget.initialUrl ?? 'https://syosetu.com/';
  }

  Future<void> getDictionaryAndBookmarks() async {
    popupDictionary = PopupDictionary(parentContext: context);
    messageController = MessageController(popupDictionary: popupDictionary);
    BrowserManager().getBookmarks();
  }

  Future<void> setupDarkReader() async {
    if (SettingsManager().cachedSettings() == null ||
        webViewController == null) {
      return;
    }
    if (SettingsManager().cachedSettings()!.browserSetting.enableDarkReader) {
      await webViewController!.evaluateJavascript(
          source: BrowserDarkReaderControl.enableDarkMode(SettingsManager()
              .cachedSettings()!
              .browserSetting
              .darkReaderSetting));
    } else {
      await webViewController!
          .evaluateJavascript(source: BrowserDarkReaderControl.disableDarkMode);
    }
  }

  void setupContentBlockers() {
    if (SettingsManager().cachedSettings() == null) {
      return;
    }
    if (SettingsManager().cachedSettings()!.browserSetting.enableAdBlock) {
      List<String> urlFilters =
          SettingsManager().cachedSettings()!.browserSetting.urlFilters;
      contentBlockers = BrowserContentBlockers.getContentBlockers(urlFilters);
    } else {
      contentBlockers = [];
    }
    if (webViewController != null) {
      webViewController!.setOptions(
          options: InAppWebViewGroupOptions(
              crossPlatform:
                  InAppWebViewOptions(contentBlockers: contentBlockers)));
    }
  }

  void onScriptsLoaded() {
    setupContentBlockers();
    setupDarkReader();
    scriptsLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _notifier,
        builder: (context, val, _) {
          bool hasNoUserControls =
              webViewController == null || !widget.hasUserControls;
          if (scriptsLoaded) {
            setupContentBlockers();
            setupDarkReader();
          }
          return SafeArea(
              child: FutureBuilder(
                  future: getDictionaryAndBookmarks(),
                  builder: ((context, snapshot) {
                    return Column(children: [
                      hasNoUserControls
                          ? Container()
                          : BrowserTopBar(
                              webViewController: webViewController!),
                      Expanded(
                          child: Stack(children: [
                        InAppWebView(
                          initialOptions: InAppWebViewGroupOptions(
                              crossPlatform: InAppWebViewOptions(
                                  contentBlockers: contentBlockers,
                                  cacheEnabled: true,
                                  incognito: false)),
                          initialUrlRequest: URLRequest(
                            url: Uri.parse(initialUrl),
                          ),
                          onWebViewCreated: (controller) {
                            setState(() {
                              webViewController = controller;
                            });
                          },
                          onLoadStop: (controller, uri) async {
                            await Future.wait([
                              controller.evaluateJavascript(source: browserJs),
                              controller.injectJavascriptFileFromAsset(
                                  assetFilePath:
                                      "assets/browser/darkreader.min.js")
                            ]);
                            onScriptsLoaded();
                          },
                          onTitleChanged: (controller, title) async {
                            await controller.evaluateJavascript(
                                source: browserJs);
                          },
                          onConsoleMessage: (controller, message) {
                            messageController.execute(message);
                          },
                        ),
                        hasNoUserControls
                            ? Container()
                            : BrowserBottomBar(
                                webViewController: webViewController,
                                notifier: _notifier),
                      ]))
                    ]);
                  })));
        });
  }
}
