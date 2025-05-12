import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:immersion_reader/managers/navigation/navigation_manager.dart';
import 'package:immersion_reader/managers/manager_service.dart';
import 'package:immersion_reader/managers/profile/profile_manager.dart';
import 'package:immersion_reader/pages/discover.dart';
import 'package:immersion_reader/pages/reader/reader_page.dart';
import 'package:immersion_reader/providers/payment_provider.dart';
import 'package:immersion_reader/managers/reader/local_asset_server_manager.dart';
import 'package:immersion_reader/storage/storage_provider.dart';
import 'package:immersion_reader/widgets/popup_dictionary/dialog/popup_dictionary.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/settings/settings_page.dart';
import 'pages/search_page.dart';
import 'pages/vocabulary_list/vocabulary_list_page.dart';

void main() {
  runApp(CupertinoApp(
    home: const App(),
    navigatorObservers: [FlutterSmartDialog.observer],
    builder: FlutterSmartDialog.init(),
  ));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final int readerPageIndex = 1;
  final int vocabularyListPageIndex = 2;
  int currentIndex = 0;
  SharedPreferences? sharedPreferences;
  PaymentProvider? paymentProvider;
  LocalAssetsServerManager? localAssetsServerManager;
  late StorageProvider storageProvider;
  bool isLocalAssetsServerReady = false;
  bool isProvidersReady = false;

  final Map<String, IconData> navigationItems = {
    'Reader': CupertinoIcons.book,
    'Discover': CupertinoIcons.compass,
    'My Words': CupertinoIcons.star_fill,
    'Search': CupertinoIcons.search,
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
    localAssetsServerManager =
        LocalAssetsServerManager.create(sharedPreferences!);
    List<dynamic> asyncData = await Future.wait([
      PaymentProvider.create(sharedPreferences!),
      StorageProvider.create(),
      PopupDictionary.warmUp(), // warm up popup dictionary
    ]);
    paymentProvider = asyncData[0];
    storageProvider = asyncData[1];
    ManagerService.setupAll(storageProvider);
    setState(() {
      isProvidersReady = true;
    });
  }

  Future<void> startLocalAssetsServer() async {
    await localAssetsServerManager?.start();
    setState(() {
      isLocalAssetsServerReady = true;
    });
  }

  void handleAppResume() {
    ProfileManager().restartSession();
    localAssetsServerManager?.start();
  }

  void handleAppSleep() {
    ProfileManager().endSession();
    localAssetsServerManager?.stop();
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
      default:
        break;
    }
  }

  bool isReady() {
    return isProvidersReady && isLocalAssetsServerReady;
  }

  void handleSwitchNavigation(int index) {
    if (index != readerPageIndex || currentIndex == index) {
      // exclude reader tab
      tabNavKeys[index]
          .currentState
          ?.popUntil((r) => r.isFirst); // pop to root of each page
    }

    if (index == vocabularyListPageIndex && isReady()) {
      NavigationManager().notifyVocabularyListPage();
    }

    NavigationManager().handleReaderSession(
        isStartSession: (index == readerPageIndex && currentIndex != index),
        isSamePage:
            (currentIndex == readerPageIndex && index == readerPageIndex),
        isTerminateSession: (currentIndex ==
            readerPageIndex)); // if user exits the reader and stays on the reader page, that still triggers termination
    currentIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      resizeToAvoidBottomInset: false,
      tabBar: CupertinoTabBar(onTap: handleSwitchNavigation, items: [
        ...navigationItems.entries.map((entry) =>
            BottomNavigationBarItem(icon: Icon(entry.value), label: entry.key))
      ]),
      tabBuilder: (BuildContext context, int index) {
        return buildViews(index);
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    paymentProvider?.dispose();
    ProfileManager().dispose();
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
      ReaderPage(paymentProvider: paymentProvider!),
      Discover(sharedPreferences: sharedPreferences!),
      const VocabularyListPage(),
      const SearchPage(),
      const SettingsPage()
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
