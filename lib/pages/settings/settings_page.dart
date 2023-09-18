import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/widgets/common/icon_list_tile.dart';
import 'package:immersion_reader/widgets/settings/experimental_settings.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:immersion_reader/pages/settings/about/about_page.dart';
import 'package:immersion_reader/widgets/settings/dictionary_settings.dart';
import 'package:immersion_reader/widgets/settings/appearance_settings.dart';

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
    return CupertinoPageScaffold(
        backgroundColor:
            CupertinoColors.systemGroupedBackground.resolveFrom(context),
        child: CustomScrollView(slivers: [
          (const CupertinoSliverNavigationBar(
            largeTitle: Text('Settings'),
          )),
          SliverFillRemaining(
              child: Container(
                  color: CupertinoColors.systemGroupedBackground
                      .resolveFrom(context),
                  child: Column(children: [
                    CupertinoListSection(children: [
                      IconListTile(
                        title: "Appearance",
                        iconData: CupertinoIcons.textformat_size,
                        iconBackgroundColor: CupertinoColors.systemBlue,
                        onTap: () {
                          Navigator.push(context,
                              SwipeablePageRoute(builder: (context) {
                            return const AppearanceSettings();
                          }));
                        },
                      ),
                      IconListTile(
                        title: "Dictionaries",
                        iconData: CupertinoIcons.book_fill,
                        iconBackgroundColor: CupertinoColors.systemOrange,
                        onTap: () {
                          Navigator.push(context,
                              SwipeablePageRoute(builder: (context) {
                            return const DictionarySettings();
                          }));
                        },
                      ),
                      IconListTile(
                        title: "Experimental",
                        iconData: CupertinoIcons.lab_flask_solid,
                        iconBackgroundColor: CupertinoColors.systemCyan,
                        onTap: () {
                          Navigator.push(context,
                              SwipeablePageRoute(builder: (context) {
                            return const ExperimentalSettings();
                          }));
                        },
                      ),
                    ]),
                    CupertinoListSection(children: [
                      IconListTile(
                        title: "About",
                        iconData: CupertinoIcons.at,
                        iconBackgroundColor: CupertinoColors.systemBlue,
                        onTap: () {
                          Navigator.push(context,
                              SwipeablePageRoute(builder: (context) {
                            return const AboutPage();
                          }));
                        },
                      ),
                    ])
                  ])))
        ]));
  }
}
