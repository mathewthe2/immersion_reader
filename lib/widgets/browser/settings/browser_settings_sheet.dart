import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
        CupertinoListTile(
            title: const Text('Ad Block'),
            trailing: const Icon(CupertinoIcons.forward),
            onTap: () => {
                  Navigator.push(context,
                      SwipeablePageRoute(builder: (context) {
                    return BrowserAdBlockPage(
                        notifier: widget.notifier);
                  }))
                }),
                 CupertinoListTile(
            title: const Text('Cookie Manager'),
            trailing: const Icon(CupertinoIcons.forward),
            onTap: () {
                  Navigator.push(context,
                      SwipeablePageRoute(builder: (context) {
                    return BrowserCookieManagerPage(webViewController: widget.webViewController,);
                  }));
                })
      ])
    ]);
  }
}
