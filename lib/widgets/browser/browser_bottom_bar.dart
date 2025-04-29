import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/widgets/browser/bookmarks_sheet.dart';
import 'package:immersion_reader/widgets/browser/settings/browser_settings_sheet.dart';
import 'package:immersion_reader/widgets/browser/browser_share_sheet.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

class BrowserBottomBar extends StatefulWidget {
  final InAppWebViewController? webViewController;
  final ValueNotifier notifier;
  const BrowserBottomBar(
      {super.key, required this.webViewController, required this.notifier});

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
          color: CupertinoColors.black.withValues(alpha: 0.25),
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
                  color: CupertinoColors.black.withValues(alpha: 0.25),
                )
              ],
              border: Border.all(
                  color: CupertinoColors.white.withValues(alpha: 0.2),
                  width: 1.0),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CupertinoColors.white.withValues(alpha: 0.9),
                  CupertinoColors.white.withValues(alpha: 0.6)
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
                  () => SmartDialog.show(
                      alignment: Alignment.bottomCenter,
                      builder: (context) => Container(
                          color: backgroundColor,
                          height: context.screenHeight * .40,
                          child: BrowserShareSheet(
                              webViewController: widget.webViewController)))),
              toolbarIconButton(
                  CupertinoIcons.book,
                  () => SmartDialog.show(
                      alignment: Alignment.bottomCenter,
                      builder: (context) => Container(
                          color: backgroundColor,
                          width: context.screenWidth,
                          height: context.screenHeight * .40,
                          child: BookmarksSheet(
                              webViewController: widget.webViewController)))),
              toolbarIconButton(
                  CupertinoIcons.settings_solid,
                  () => SmartDialog.show(
                      alignment: Alignment.bottomCenter,
                      builder: (context) => SizedBox(
                          height: context.screenHeight * .70,
                          child: Navigator(
                              onGenerateRoute: (_) => SwipeablePageRoute(
                                  builder: (context2) => Builder(
                                      builder: (context3) =>
                                          CupertinoPageScaffold(
                                              backgroundColor: backgroundColor,
                                              child: GestureDetector(
                                                child: BrowserSettingsSheet(
                                                    webViewController: widget
                                                        .webViewController,
                                                    notifier: widget.notifier),
                                              ))))))))
            ],
          )
        ]));
  }
}
