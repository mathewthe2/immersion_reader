import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/widgets/common/padding_bottom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:immersion_reader/widgets/discover/category_box.dart';
import 'package:immersion_reader/widgets/discover/recommended_widget.dart';
// import 'package:immersion_reader/widgets/my_books/my_books_widget.dart';

class Discover extends StatefulWidget {
  final SharedPreferences sharedPreferences;

  const Discover({
    super.key,
    required this.sharedPreferences,
  });

  @override
  State<Discover> createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  int? selectedTab;
  static List<String> discoverCategories = [
    "We Recommend",
    "Graded",
    // "Audio Books"
  ];

  @override
  void initState() {
    selectedTab = widget.sharedPreferences.getInt('discover_selected_tab') ?? 0;
    super.initState();
  }

  void setSelectedTab(int selectedTab) async {
    widget.sharedPreferences.setInt('discover_selected_tab', selectedTab);
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.systemBackground,
            darkColor: CupertinoColors.black),
        context);
    late Widget activeWidget;
    switch (selectedTab) {
      case 0:
        activeWidget = const RecommendedWidget();
        break;
      // case 1:
      //   activeWidget = MyBooksWidget(
      //       localAssetsServer: widget.localAssetsServer,
      //       dictionaryProvider: widget.dictionaryProvider);
      //   break;
      default:
        activeWidget = Container();
    }
    return CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        child: CustomScrollView(slivers: [
          (CupertinoSliverNavigationBar(
              largeTitle: const Text('Discover'),
              backgroundColor: backgroundColor,
              border: const Border())),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(
                height: 80,
                child: ListView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    children: [
                      const SizedBox(
                        width: 18,
                      ),
                      ...discoverCategories
                          .asMap()
                          .entries
                          .map((entry) => CategoryBox(
                                text: entry.value,
                                onPressed: () {
                                  setState(() {
                                    selectedTab = entry.key;
                                  });
                                  setSelectedTab(selectedTab!);
                                },
                                isSelected: selectedTab == entry.key,
                              )),
                    ])),
            activeWidget,
            const PaddingBottom()
          ]))
        ]));
  }
}
