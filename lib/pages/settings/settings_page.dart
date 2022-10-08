import 'package:flutter/cupertino.dart';
import "package:immersion_reader/storage/settings_storage.dart";
import 'package:immersion_reader/widgets/settings/dictionary_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

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
    return FutureBuilder<SettingsStorage>(
        future: SettingsStorage.create(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DictionarySettings(storage: snapshot.data!);
          } else {
            return const CupertinoActivityIndicator(
              animating: true,
              radius: 24,
            );
          }
        });
  }
}
