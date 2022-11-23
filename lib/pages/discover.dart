import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/widgets/discover/category_box.dart';
import 'package:immersion_reader/widgets/discover/recommended_widget.dart';
import 'package:immersion_reader/widgets/my_books/my_books_widget.dart';

class Discover extends StatefulWidget {
  const Discover({super.key});

  @override
  State<Discover> createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  int selectedTab = 1;
  static List<String> discoverCategories = [
    "We Recommend",
    "My Books",
    // "Audio Books"
  ];

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.white, darkColor: CupertinoColors.black),
        context);
    late Widget activeWidget;
    switch (selectedTab) {
      case 0:
        activeWidget = const RecommendedWidget();
        break;
      case 1:
        activeWidget = const MyBooksWidget();
        break;
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
          SliverFillRemaining(
              child: Container(
                  color: backgroundColor,
                  child: SafeArea(
                      child: Column(children: [
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
                                        onPressed: () => setState(() {
                                          selectedTab = entry.key;
                                        }),
                                        isSelected: selectedTab == entry.key,
                                      )),
                            ])),
                    activeWidget
                  ]))))
        ]));
  }
}
