import 'package:flutter/cupertino.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:immersion_reader/pages/settings/about/about_page.dart';
import 'package:immersion_reader/providers/settings_provider.dart';
import 'package:immersion_reader/widgets/settings/dictionary_settings.dart';
import 'package:immersion_reader/widgets/settings/appearance_settings.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';

class SettingsPage extends StatefulWidget {
  final DictionaryProvider? dictionaryProvider;
  final SettingsProvider? settingsProvider;
  const SettingsPage(
      {super.key,
      required this.dictionaryProvider,
      required this.settingsProvider});

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
    return CupertinoPageScaffold(
        child: CustomScrollView(slivers: [
      (const CupertinoSliverNavigationBar(
        largeTitle: Text('Settings'),
      )),
      SliverFillRemaining(
          child: Container(
              color: CupertinoDynamicColor.resolve(
                  const CupertinoDynamicColor.withBrightness(
                      color: CupertinoColors.systemGroupedBackground,
                      darkColor: CupertinoColors.black),
                  context),
              child: Column(children: [
                CupertinoListSection(children: [
                  CupertinoListTile(
                    title: const Text("Appearance"),
                    onTap: () => {
                      Navigator.push(context,
                          SwipeablePageRoute(builder: (context) {
                        return AppearanceSettings(
                            settingsProvider: widget.settingsProvider!);
                      }))
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const Icon(
                          size: 22,
                          CupertinoIcons.textformat_size,
                          color: CupertinoColors.white),
                    ),
                    trailing: const Icon(CupertinoIcons.forward),
                  ),
                  CupertinoListTile(
                    title: const Text("Dictionaries"),
                    onTap: () => {
                      Navigator.push(context,
                          SwipeablePageRoute(builder: (context) {
                        return DictionarySettings(
                            dictionaryProvider: widget.dictionaryProvider!);
                      }))
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemOrange,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const Icon(
                          size: 22,
                          CupertinoIcons.book_fill,
                          color: CupertinoColors.white),
                    ),
                    trailing: const Icon(CupertinoIcons.forward),
                  ),
                ]),
                CupertinoListSection(children: [
                  CupertinoListTile(
                    title: const Text("About"),
                    onTap: () => {
                      Navigator.push(context,
                          SwipeablePageRoute(builder: (context) {
                        return const AboutPage();
                      }))
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const Icon(
                          size: 22,
                          CupertinoIcons.at,
                          color: CupertinoColors.white),
                    ),
                    trailing: const Icon(CupertinoIcons.forward),
                  )
                ])
              ])))
    ]));
  }
}
