import 'dart:async';
import 'package:flutter/cupertino.dart';
// import 'package:immersion_reader/pages/browser.dart';
import 'package:immersion_reader/pages/discover.dart';
import 'package:immersion_reader/pages/reader/reader_page.dart';
import 'package:immersion_reader/providers/browser_provider.dart';
import 'package:immersion_reader/providers/payment_provider.dart';
import 'package:immersion_reader/providers/profile_provider.dart';
import 'package:immersion_reader/managers/dictionary/dictionary_manager.dart';
import 'package:immersion_reader/utils/reader/local_asset_server_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:immersion_reader/providers/settings_provider.dart';
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
  final int readerPageIndex = 1;
  final int vocabularyListPageIndex = 2;
  int currentIndex = 0;
  SharedPreferences? sharedPreferences;
  VocabularyListProvider? vocabularyListProvider;
  BrowserProvider? browserProvider;
  SettingsStorage? _settingsStorage;
  ProfileProvider? profileProvider;
  SettingsProvider? settingsProvider;
  PaymentProvider? paymentProvider;
  bool isLocalAssetsServerReady = false;
  bool isProvidersReady = false;

  final Map<String, IconData> navigationItems = {
    'Discover': CupertinoIcons.compass,
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
    vocabularyListProvider = await VocabularyListProvider.create();
    _settingsStorage = await SettingsStorage.create();
    profileProvider = await ProfileProvider.create();
    browserProvider = await BrowserProvider.create(_settingsStorage!);
    settingsProvider = SettingsProvider.create(_settingsStorage!);
    DictionaryManager.createDictionary(settingsProvider!);
    setState(() {
      isProvidersReady = true;
    });
  }

  Future<void> startLocalAssetsServer() async {
    await LocalAssetsServerManager().server!.serve();
    setState(() {
      isLocalAssetsServerReady = true;
    });
  }

  Future<void> stopLocalAssetsServer() async {
    await LocalAssetsServerManager().server!.stop();
    setState(() {
      isLocalAssetsServerReady = true;
    });
  }

  Future<void> handleAppResume() async {
    startLocalAssetsServer();
    profileProvider?.restartSession();
  }

  Future<void> handleAppSleep() async {
    stopLocalAssetsServer();
    profileProvider?.endSession();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        handleAppResume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        handleAppSleep();
        break;
    }
  }

  bool isReady() {
    return isProvidersReady && isLocalAssetsServerReady;
  }

  void handleSwitchNavigation(int index) async {
    if (index != readerPageIndex || currentIndex == index) {
      // exclude reader tab
      tabNavKeys[index]
          .currentState
          ?.popUntil((r) => r.isFirst); // pop to root of each page
    }

    if (index == vocabularyListPageIndex && vocabularyListProvider != null) {
      await vocabularyListProvider!.getVocabularyList();
    }

    // handle leave reader session
    if (currentIndex == readerPageIndex) {
      profileProvider?.endSession();
    } else if (index == readerPageIndex && currentIndex != index) {
      profileProvider?.restartSession();
    }

    currentIndex = index;
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
    paymentProvider?.dispose();
    profileProvider?.dispose();
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
          sharedPreferences: sharedPreferences!),
      ReaderPage(
          browserProvider: browserProvider,
          paymentProvider: paymentProvider!,
          profileProvider: profileProvider!,
          settingsProvider: settingsProvider!),
      //  Browser(
      //     browserProvider: browserProvider,
      //     dictionaryProvider: dictionaryProvider!),
      ValueListenableBuilder(
          valueListenable: _notifier,
          builder: (context, val, child) => VocabularyListPage(
              vocabularyListProvider: vocabularyListProvider!,
              notifier: _notifier)),
      const SearchPage(),
      SettingsPage(settingsProvider: settingsProvider)
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
