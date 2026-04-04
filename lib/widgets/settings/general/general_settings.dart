import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/widgets/settings/general/lookup_language_settings.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  final ValueNotifier<bool> _lookupLanguageValueNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('General')),
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(
        context,
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoListSection(
              children: [
                CupertinoListTile(
                  title: const Text('Lookup Language'),
                  onTap: () {
                    Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) {
                          return LookupLanguageSettings(
                            lookupLanguageValueNotifier:
                                _lookupLanguageValueNotifier,
                            lookupLanguage: SettingsManager()
                                .settingsStorage!
                                .settingsCache!
                                .generalSetting
                                .lookupLanguage,
                          );
                        },
                      ),
                    );
                  },
                  additionalInfo: ValueListenableBuilder(
                    valueListenable: _lookupLanguageValueNotifier,
                    builder: (context, val, child) => Text(
                      DictionaryOptions.lookupLanguageToString(
                        SettingsManager()
                            .settingsStorage!
                            .settingsCache!
                            .generalSetting
                            .lookupLanguage,
                      ),
                    ),
                  ),
                  trailing: const Icon(CupertinoIcons.forward),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
