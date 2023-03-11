import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/widgets/browser/bookmarks_sheet.dart';
import 'package:immersion_reader/widgets/browser/settings/browser_settings_sheet.dart';
import 'package:immersion_reader/widgets/browser/browser_share_sheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

class BrowserBottomBar extends StatefulWidget {
  final InAppWebViewController? webViewController;
  final ValueNotifier notifier;
  const BrowserBottomBar(
      {super.key,
      required this.webViewController,
      required this.notifier});

  @override
  State<BrowserBottomBar> createState() => _BrowserBottomBarState();
}

class _BrowserBottomBarState extends State<BrowserBottomBar> {
  Widget toolbarIconButton(IconData iconData, Function()? onPressed) {
    return CupertinoButton(
        padding: const EdgeInsets.all(0),
        onPressed: onPressed,
        alignment: Alignment.center,
        child: Icon(
          iconData,
          size: 28,
          color: CupertinoColors.black.withOpacity(0.25),
        ));
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.systemGroupedBackground,
            darkColor: CupertinoColors.black),
        context);
    return Align(
        alignment: Alignment.bottomCenter,
        child: Stack(alignment: Alignment.bottomCenter, children: [
          Container(
            height: 40,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.25),
                )
              ],
              border: Border.all(
                  color: CupertinoColors.white.withOpacity(0.2), width: 1.0),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CupertinoColors.white.withOpacity(0.9),
                  CupertinoColors.white.withOpacity(0.6)
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              toolbarIconButton(CupertinoIcons.chevron_back,
                  () => widget.webViewController?.goBack()),
              toolbarIconButton(CupertinoIcons.chevron_forward,
                  () => widget.webViewController?.goForward()),
              toolbarIconButton(
                  CupertinoIcons.tray,
                  () => showCupertinoModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      expand: false,
                      builder: (context) => SafeArea(
                          child: Container(
                              color: backgroundColor,
                              height: MediaQuery.of(context).size.height * .40,
                              child: BrowserShareSheet(
                                  webViewController: widget.webViewController))))),
              toolbarIconButton(
                  CupertinoIcons.book,
                  () => showCupertinoModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      expand: false,
                      builder: (context) => SafeArea(
                          child: Container(
                              color: backgroundColor,
                              height: MediaQuery.of(context).size.height * .40,
                              child: BookmarksSheet(
                                  webViewController:
                                      widget.webViewController))))),
              toolbarIconButton(
                  CupertinoIcons.settings_solid,
                  () => showCupertinoModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      expand: true,
                      builder: (context) => Navigator(
                          onGenerateRoute: (_) => SwipeablePageRoute(
                              builder: (context2) => Builder(
                                  builder: (context3) => CupertinoPageScaffold(
                                      backgroundColor: backgroundColor,
                                      child: GestureDetector(
                                        child: BrowserSettingsSheet(
                                            notifier: widget.notifier),
                                        onTap: () {
                                          // context2 or context3 will return the Navigator inside the modal
                                          Navigator.pop(context);
                                        },
                                      )))))))
            ],
          )
        ]));
  }
}
