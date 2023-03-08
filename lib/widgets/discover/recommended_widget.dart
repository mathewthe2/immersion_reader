import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:immersion_reader/data/discover/recommended_catalog.dart';
// import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/pages/browser.dart';
import 'package:immersion_reader/widgets/my_books/book_widget.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

class RecommendedWidget extends StatelessWidget {
  const RecommendedWidget(
      {super.key});

  Widget headlineWidget(String title, IconData iconData, Color textColor) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 10, 10),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Row(children: [
              FaIcon(
                iconData,
                color: textColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: textColor))
            ])));
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.black, darkColor: CupertinoColors.white),
        context);
    return Column(children: [
      headlineWidget("Read Along", FontAwesomeIcons.headphones, textColor),
      SizedBox(
          height: 200,
          child: ListView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                ...readAlongCatalog.asMap().entries.map((entry) => BookWidget(
                    width: 130,
                    book: entry.value,
                    onTap: (mediaIdentifier) {
                      Navigator.push(
                          context,
                          SwipeablePageRoute(
                              canOnlySwipeFromEdge: true,
                              backGestureDetectionWidth: 25,
                              builder: (context) {
                                return Browser(
                                    initialUrl: mediaIdentifier,
                                    hasUserControls: false);
                              }));
                    }))
              ])),
      headlineWidget("Audio Books", FontAwesomeIcons.headphones, textColor),
      SizedBox(
          height: 200,
          child: ListView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                ...audioBookCatalog.asMap().entries.map((entry) => BookWidget(
                    width: 130,
                    book: entry.value,
                    onTap: (mediaIdentifier) {
                      Navigator.push(
                          context,
                          SwipeablePageRoute(
                              canOnlySwipeFromEdge: true,
                              backGestureDetectionWidth: 25,
                              builder: (context) {
                                return Browser(
                                    initialUrl: mediaIdentifier,
                                    hasUserControls: false);
                              }));
                    }))
              ])),
      // const DiscoverBox(title: "あひるさん と 時計")
    ]);
  }
}
