import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/settings/settings_data.dart';
import 'package:immersion_reader/providers/settings_provider.dart';

class AppearanceSettings extends StatefulWidget {
  final SettingsProvider settingsProvider;

  const AppearanceSettings({super.key, required this.settingsProvider});

  @override
  State<AppearanceSettings> createState() => _AppearanceSettingsState();
}

class _AppearanceSettingsState extends State<AppearanceSettings> {
  @override
  Widget build(BuildContext context) {
    // return Container();
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Appearance')),
        child: FutureBuilder<SettingsData>(
            future:
                widget.settingsProvider.settingsStorage!.getConfigSettings(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SafeArea(
                    child: CupertinoListSection(
                  header: const Text('Dictionary Popup'),
                  children: [
                    CupertinoListTile(
                        title: const Text('Show Frequency Tags'),
                        trailing: CupertinoSwitch(
                            onChanged: (bool? value) {
                              widget.settingsProvider
                                  .toggleShowFrequencyTags(value!);
                              setState(() {});
                            },
                            value: snapshot
                                .data!.appearanceSetting.showFrequencyTags))
                  ],
                ));
              } else {
                return const Text('loading');
              }
            }));
  }
}
