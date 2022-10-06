import 'package:flutter/cupertino.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings',
          style: TextStyle(
            color: CupertinoDynamicColor.withBrightness(
              color: CupertinoColors.white,
              darkColor: CupertinoColors.black,
            ),
          )),
    );
  }
}
