import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/pages/discover.dart';
// import 'package:immersion_reader/pages/browser.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';
import 'package:immersion_reader/providers/settings_provider.dart';
import 'package:immersion_reader/providers/local_asset_server_provider.dart';
import 'package:immersion_reader/providers/vocabulary_list_provider.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'pages/reader.dart';
import 'pages/settings/settings_page.dart';
import 'pages/search_page.dart';
import 'pages/vocabulary_list/vocabulary_list_page.dart';

void main() {
  runApp(const CupertinoApp(home: App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final ValueNotifier<bool> _notifier = ValueNotifier(false);
  LocalAssetsServerProvider? localAssetsServerProvider;
  VocabularyListProvider? vocabularyListProvider;
  SettingsStorage? _settingsStorage;
  DictionaryProvider? dictionaryProvider;
  SettingsProvider? settingsProvider;
  bool isReady = false;

  final Map<String, IconData> navigationItems = {
    'Discover': CupertinoIcons.home,
    'Reader': CupertinoIcons.book,
    'My Words': CupertinoIcons.star_fill,
    'Search': CupertinoIcons.search,
    // 'Browse': CupertinoIcons.globe,
    'Settings': CupertinoIcons.settings
  };

  final List<GlobalKey<NavigatorState>> tabNavKeys =
      List.generate(5, (_) => GlobalKey<NavigatorState>()); // 4 tabs

  Future<void> setupProviders() async {
    localAssetsServerProvider = await LocalAssetsServerProvider.create();
    vocabularyListProvider = await VocabularyListProvider.create();
    _settingsStorage = await SettingsStorage.create();
    settingsProvider = SettingsProvider.create(_settingsStorage!);
    dictionaryProvider = DictionaryProvider.create(settingsProvider!);
    setState(() {
      isReady = true;
    });
  }

  @override
  void initState() {
    super.initState();
    setupProviders();
  }

  void handleSwitchNavigation(int index) async {
    tabNavKeys[index]
        .currentState
        ?.popUntil((r) => r.isFirst); // pop to root of each page
    if (index == 0 && vocabularyListProvider != null) {
      await vocabularyListProvider!.getVocabularyList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: CupertinoTabScaffold(
      tabBar: CupertinoTabBar(onTap: handleSwitchNavigation, items: [
        ...navigationItems.entries.map((entry) =>
            BottomNavigationBarItem(icon: Icon(entry.value), label: entry.key))
      ]),
      tabBuilder: (BuildContext context, int index) {
        return buildViews(index);
      },
    ));
  }

  Widget progressIndicator() {
    return const CupertinoActivityIndicator(
      animating: true,
      radius: 24,
    );
  }

  Widget buildViews(int index) {
    switch (index) {
      case 0:
        return CupertinoTabView(
            navigatorKey: tabNavKeys[index],
            builder: (BuildContext context) {
              return const Discover();
            });
      case 1:
        return CupertinoTabView(
            navigatorKey: tabNavKeys[index],
            builder: (BuildContext context) {
              return isReady
                  ? Reader(
                      localAssetsServer: localAssetsServerProvider!.server,
                      dictionaryProvider: dictionaryProvider!)
                  : progressIndicator();
            });
      case 2:
        return CupertinoTabView(
            navigatorKey: tabNavKeys[index],
            builder: (BuildContext context) {
              return isReady
                  ? ValueListenableBuilder(
                      valueListenable: _notifier,
                      builder: (context, val, child) => VocabularyListPage(
                          vocabularyListProvider: vocabularyListProvider!,
                          notifier: _notifier))
                  : progressIndicator();
            });
      case 3:
        return CupertinoTabView(
            navigatorKey: tabNavKeys[index],
            builder: (BuildContext context) =>
                SearchPage(dictionaryProvider: dictionaryProvider));
      // case 2:
      //   return CupertinoTabView(
      //       navigatorKey: tabNavKeys[index],
      //       builder: (BuildContext context) => isReady
      //           ? Browser(dictionaryProvider: dictionaryProvider!)
      //           : progressIndicator());
      case 4:
        return CupertinoTabView(
            navigatorKey: tabNavKeys[index],
            builder: (BuildContext context) {
              return isReady
                  ? SettingsPage(
                      dictionaryProvider: dictionaryProvider,
                      settingsProvider: settingsProvider,
                    )
                  : progressIndicator();
            });
    }
    return const Text('no page');
  }
}
