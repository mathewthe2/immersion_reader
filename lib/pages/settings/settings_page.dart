import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/widgets/settings/dictionary_settings.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';

class SettingsPage extends StatefulWidget {
  final DictionaryProvider? dictionaryProvider;
  const SettingsPage({super.key, required this.dictionaryProvider});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DictionarySettings(dictionaryProvider: widget.dictionaryProvider!);
  }
}
