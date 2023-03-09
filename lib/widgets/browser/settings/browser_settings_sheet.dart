import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/widgets/browser/settings/browser_ad_block_page.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

class BrowserSettingsSheet extends StatefulWidget {
  final ValueNotifier notifier;
  const BrowserSettingsSheet(
      {super.key, required this.notifier});

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
                })
      ])
    ]);
  }
}
