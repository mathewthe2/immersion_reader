import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/providers/browser_provider.dart';

class BrowserShareSheet extends StatefulWidget {
  final BrowserProvider? browserProvider;
  const BrowserShareSheet({super.key, required this.browserProvider});

  @override
  State<BrowserShareSheet> createState() => _BrowserShareSheetState();
}

class _BrowserShareSheetState extends State<BrowserShareSheet> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
