import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/widgets/browser/settings/dark_reader/browser_dark_reader_page.dart';
import 'package:immersion_reader/widgets/common/icon_list_tile.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:immersion_reader/widgets/browser/settings/browser_ad_block_page.dart';
import 'package:immersion_reader/widgets/browser/settings/cookies/browser_cookie_manager_page.dart';

class BrowserSettingsSheet extends StatefulWidget {
  final ValueNotifier notifier;
  final InAppWebViewController? webViewController;
  const BrowserSettingsSheet(
      {super.key, required this.notifier, required this.webViewController});

  @override
  State<BrowserSettingsSheet> createState() => _BrowserSettingsSheetState();
}

class _BrowserSettingsSheetState extends State<BrowserSettingsSheet> {
  @override
  Widget build(BuildContext context) {
    Color textColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.black,
            darkColor: CupertinoColors.systemBackground),
        context);
    return Column(children: [
      Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(children: [
            Text('Settings', style: TextStyle(color: textColor, fontSize: 20))
          ])),
      CupertinoListSection(children: [
        IconListTile(
          title: "Ad Block",
          iconData: CupertinoIcons.bars,
          iconBackgroundColor: CupertinoColors.systemPurple,
          onTap: () {
            Navigator.push(context, SwipeablePageRoute(builder: (context) {
              return BrowserAdBlockPage(notifier: widget.notifier);
            }));
          },
        ),
        IconListTile(
          title: "Cookies",
          iconData: CupertinoIcons.archivebox,
          iconBackgroundColor: CupertinoColors.systemOrange,
          onTap: () {
            Navigator.push(context, SwipeablePageRoute(builder: (context) {
              return BrowserCookieManagerPage(
                webViewController: widget.webViewController,
              );
            }));
          },
        ),
        IconListTile(
          title: "Dark Reader",
          iconData: CupertinoIcons.moon,
          iconBackgroundColor: CupertinoColors.systemIndigo,
          onTap: () {
            Navigator.push(context, SwipeablePageRoute(builder: (context) {
              return BrowserDarkReaderPage(notifier: widget.notifier);
            }));
          },
        ),
      ])
    ]);
  }
}
