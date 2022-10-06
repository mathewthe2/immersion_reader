import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/providers/local_asset_server_provider.dart';
import './reader.dart';
import 'pages/settings/settings_page.dart';
import './search.dart';
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
  var _currentIndex = 0;
  LocalAssetsServerProvider? localAssetsServerProvider;

  Future<void> setupProviders() async {
    localAssetsServerProvider = await LocalAssetsServerProvider.create();
  }

  @override
  void initState() {
    super.initState();
    setupProviders();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        // backgroundColor: Colors.transparent,
        onTap: (i) => setState(() => _currentIndex = i),
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
            return buildBody();
          },
        );
      },
    ));
  }

  Widget buildBody() {
    switch (_currentIndex) {
      case 0:
        return const VocabularyListPage();
      case 1:
        if (localAssetsServerProvider != null) {
          return Reader(localAssetsServer: localAssetsServerProvider!.server);
        } else {
          return const CupertinoActivityIndicator(
            animating: true,
            radius: 24,
          );
        }
      case 2:
        return const Search();
      case 3:
        return const SettingsPage();
    }
    return const Text('no page');
  }
}
