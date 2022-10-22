import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';
import 'package:immersion_reader/providers/settings_provider.dart';
import 'package:immersion_reader/providers/local_asset_server_provider.dart';
import 'package:immersion_reader/providers/vocabulary_list_provider.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import './reader.dart';
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

  Future<void> setupProviders() async {
    localAssetsServerProvider = await LocalAssetsServerProvider.create();
    vocabularyListProvider = await VocabularyListProvider.create();
    _settingsStorage = await SettingsStorage.create();
    dictionaryProvider = DictionaryProvider.create(_settingsStorage!);
    settingsProvider = SettingsProvider.create(_settingsStorage!);
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
    if (index == 0 && vocabularyListProvider != null) {
      await vocabularyListProvider!.getVocabularyList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        onTap: handleSwitchNavigation,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.star_fill),
            label: 'My Words',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            label: 'Reader',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            return buildBody(index);
          },
        );
      },
    ));
  }

  Widget progressIndicator() {
    return const CupertinoActivityIndicator(
      animating: true,
      radius: 24,
    );
  }

  Widget buildBody(int index) {
    switch (index) {
      case 0:
        return isReady
            ? ValueListenableBuilder(
                valueListenable: _notifier,
                builder: (context, val, child) => VocabularyListPage(
                    vocabularyListProvider: vocabularyListProvider!,
                    notifier: _notifier))
            : progressIndicator();
      case 1:
        return isReady
            ? Reader(
                localAssetsServer: localAssetsServerProvider!.server,
                dictionaryProvider: dictionaryProvider!)
            : progressIndicator();
      case 2:
        return SearchPage(dictionaryProvider: dictionaryProvider);
      case 3:
        return isReady
            ? SettingsPage(
                dictionaryProvider: dictionaryProvider,
                settingsProvider: settingsProvider,
              )
            : progressIndicator();
    }
    return const Text('no page');
  }
}
