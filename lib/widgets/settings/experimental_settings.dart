import 'package:flutter/cupertino.dart';

class ExperimentalSettings extends StatefulWidget {
  const ExperimentalSettings({super.key});

  @override
  State<ExperimentalSettings> createState() => _ExperimentalSettingsState();
}

class _ExperimentalSettingsState extends State<ExperimentalSettings> {
  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Experimental'),
        ),
        child: SafeArea(child: Center(child: Text('Nothing here yet.'))));
  }
}
