import 'package:flutter/cupertino.dart';
import 'package:cupertino_lists/cupertino_lists.dart' as cupertino_lists;
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import "package:immersion_reader/extensions/string_extension.dart";
import 'package:immersion_reader/providers/settings_provider.dart';

class PitchAccentStyleSettings extends StatefulWidget {
  final String pitchAccentStyleString;
  final SettingsProvider settingsProvider;
  final ValueNotifier pitchAccentValueNotifier;
  const PitchAccentStyleSettings(
      {super.key,
      required this.pitchAccentStyleString,
      required this.settingsProvider,
      required this.pitchAccentValueNotifier});

  @override
  State<PitchAccentStyleSettings> createState() =>
      _PitchAccentStyleSettingsState();
}

class _PitchAccentStyleSettingsState extends State<PitchAccentStyleSettings> {
  String? pitchAccentStyleString;

  @override
  void initState() {
    super.initState();
    pitchAccentStyleString = widget.pitchAccentStyleString;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar:
            const CupertinoNavigationBar(middle: Text('Pitch Accent Style')),
        child: SafeArea(
            child: cupertino_lists.CupertinoListSection(children: [
          ...PitchAccentDisplayStyle.values.map((style) =>
              cupertino_lists.CupertinoListTile(
                  title: Text(style.name.capitalize()),
                  onTap: () async {
                    setState(() {
                      pitchAccentStyleString = style.name;
                    });
                    await widget.settingsProvider.updatePitchAccentStyle(style);
                    widget.pitchAccentValueNotifier.value =
                        !widget.pitchAccentValueNotifier.value;
                  },
                  trailing: pitchAccentStyleString! == style.name
                      ? const Icon(CupertinoIcons.check_mark)
                      : null))
        ])));
  }
}
