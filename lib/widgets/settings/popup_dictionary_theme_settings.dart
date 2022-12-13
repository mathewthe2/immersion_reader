import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import "package:immersion_reader/extensions/string_extension.dart";
import 'package:immersion_reader/providers/settings_provider.dart';

class PopupDictionaryThemeSettings extends StatefulWidget {
  final String popupDictionaryThemeString;
  final SettingsProvider settingsProvider;
  final ValueNotifier popupDictionaryThemeValueNotifier;
  const PopupDictionaryThemeSettings(
      {super.key,
      required this.popupDictionaryThemeString,
      required this.settingsProvider,
      required this.popupDictionaryThemeValueNotifier});

  @override
  State<PopupDictionaryThemeSettings> createState() =>
      _PopupDictionaryThemeSettingsState();
}

class _PopupDictionaryThemeSettingsState
    extends State<PopupDictionaryThemeSettings> {
  String? popupDictionaryThemeString;

  @override
  void initState() {
    super.initState();
    popupDictionaryThemeString = widget.popupDictionaryThemeString;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar:
            const CupertinoNavigationBar(middle: Text('Dictionary Theme')),
        child: SafeArea(
            child: CupertinoListSection(children: [
          ...PopupDictionaryTheme.values.map((theme) =>
              CupertinoListTile(
                  title: Text(theme.name.capitalize()),
                  onTap: () async {
                    setState(() {
                      popupDictionaryThemeString = theme.name;
                    });
                    await widget.settingsProvider
                        .updatePopupDictionaryTheme(theme);
                    widget.popupDictionaryThemeValueNotifier.value =
                        !widget.popupDictionaryThemeValueNotifier.value;
                  },
                  trailing: popupDictionaryThemeString! == theme.name
                      ? const Icon(CupertinoIcons.check_mark)
                      : null))
        ])));
  }
}
