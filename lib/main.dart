import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/pages/discover.dart';
import 'package:immersion_reader/pages/reader/reader_page.dart';
import 'package:immersion_reader/providers/browser_provider.dart';
import 'package:immersion_reader/providers/payment_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';
import 'package:immersion_reader/providers/settings_provider.dart';
import 'package:immersion_reader/providers/local_asset_server_provider.dart';
import 'package:immersion_reader/providers/vocabulary_list_provider.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
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

class _AppState extends State<App> with WidgetsBindingObserver {
  final ValueNotifier<bool> _notifier = ValueNotifier(false);
  final int vocabularyListPageIndex = 2;
  SharedPreferences? sharedPreferences;
  LocalAssetsServerProvider? localAssetsServerProvider;
  VocabularyListProvider? vocabularyListProvider;
  BrowserProvider? browserProvider;
  SettingsStorage? _settingsStorage;
  DictionaryProvider? dictionaryProvider;
  SettingsProvider? settingsProvider;
  PaymentProvider? paymentProvider;
  bool isLocalAssetsServerReady = false;
  bool isProvidersReady = false;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setupApp();
  }

  Future<void> setupApp() async {
    await setupProviders();
    await startLocalAssetsServer();
  }

  Future<void> setupProviders() async {
    sharedPreferences = await SharedPreferences.getInstance();
    paymentProvider = await PaymentProvider.create(sharedPreferences!);
    localAssetsServerProvider = await LocalAssetsServerProvider.create();
    vocabularyListProvider = await VocabularyListProvider.create();
    browserProvider = await BrowserProvider.create();
    _settingsStorage = await SettingsStorage.create();
    settingsProvider = SettingsProvider.create(_settingsStorage!);
    dictionaryProvider = DictionaryProvider.create(settingsProvider!);
    setState(() {
      isProvidersReady = true;
    });
  }

  Future<void> startLocalAssetsServer() async {
    await localAssetsServerProvider!.server!.serve();
    setState(() {
      isLocalAssetsServerReady = true;
    });
  }

  Future<void> stopLocalAssetsServer() async {
    await localAssetsServerProvider!.server!.stop();
    setState(() {
      isLocalAssetsServerReady = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        startLocalAssetsServer();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        stopLocalAssetsServer();
        break;
    }
  }

  bool isReady() {
    return isProvidersReady && isLocalAssetsServerReady;
  }

  void handleSwitchNavigation(int index) async {
    tabNavKeys[index]
        .currentState
        ?.popUntil((r) => r.isFirst); // pop to root of each page
    if (index == vocabularyListPageIndex && vocabularyListProvider != null) {
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget progressIndicator() {
    return const CupertinoActivityIndicator(
      animating: true,
      radius: 24,
    );
  }

  Widget getViewWidget(int index) {
    List<Widget> viewWidgets = [
      Discover(
          sharedPreferences: sharedPreferences!,
          localAssetsServer: localAssetsServerProvider!.server,
          dictionaryProvider: dictionaryProvider!),
      ReaderPage(
          browserProvider: browserProvider,
          paymentProvider: paymentProvider!,
          localAssetsServer: localAssetsServerProvider!.server,
          dictionaryProvider: dictionaryProvider!),
      ValueListenableBuilder(
          valueListenable: _notifier,
          builder: (context, val, child) => VocabularyListPage(
              vocabularyListProvider: vocabularyListProvider!,
              notifier: _notifier)),
      SearchPage(
        dictionaryProvider: dictionaryProvider,
      ),
      SettingsPage(
        dictionaryProvider: dictionaryProvider,
        settingsProvider: settingsProvider,
      )
    ];
    return viewWidgets[index];
  }

  Widget buildViews(int index) {
    return CupertinoTabView(
        navigatorKey: tabNavKeys[index],
        builder: (BuildContext context) {
          return isReady() ? getViewWidget(index) : progressIndicator();
        });
  }
}
