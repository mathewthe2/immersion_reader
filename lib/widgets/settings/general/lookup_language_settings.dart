import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/managers/dictionary/dictionary_manager.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';

class LookupLanguageSettings extends StatefulWidget {
  final LookupLanguage lookupLanguage;
  final ValueNotifier lookupLanguageValueNotifier;
  const LookupLanguageSettings({
    super.key,
    required this.lookupLanguage,
    required this.lookupLanguageValueNotifier,
  });

  @override
  State<LookupLanguageSettings> createState() => _LookupLanguageSettingsState();
}

class _LookupLanguageSettingsState extends State<LookupLanguageSettings> {
  LookupLanguage lookupLanguage = LookupLanguage.ja;

  @override
  void initState() {
    super.initState();
    lookupLanguage = widget.lookupLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Lookup Language'),
      ),
      child: SafeArea(
        child: CupertinoListSection(
          children: [
            ...DictionaryOptions.lookupLanguageOptions.map(
              (option) => CupertinoListTile(
                title: Text(option),
                onTap: () async {
                  setState(() {
                    lookupLanguage = DictionaryOptions.lookupLanguagefromString(
                      option,
                    );
                  });
                  DictionaryManager().updateLookupLanguage(lookupLanguage);
                  await SettingsManager().updateLookupLanguage(lookupLanguage);
                  widget.lookupLanguageValueNotifier.value =
                      !widget.lookupLanguageValueNotifier.value;
                },
                trailing:
                    DictionaryOptions.lookupLanguageToString(lookupLanguage) ==
                        option
                    ? const Icon(CupertinoIcons.check_mark)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
