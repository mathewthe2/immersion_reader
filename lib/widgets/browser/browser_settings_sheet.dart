import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/providers/browser_provider.dart';

class BrowserSettingsSheet extends StatefulWidget {
  final BrowserProvider? browserProvider;
  const BrowserSettingsSheet({super.key, required this.browserProvider});

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
          child: Text('Settings',
              style: TextStyle(color: textColor, fontSize: 20)))
    ]);
  }
}
