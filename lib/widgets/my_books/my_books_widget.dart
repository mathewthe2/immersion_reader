import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/providers/local_asset_server_provider.dart';
import 'package:immersion_reader/widgets/reader/reader.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';
import 'package:immersion_reader/utils/reader/ttu_source.dart';
import 'package:immersion_reader/widgets/my_books/book_widget.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyBooksWidget extends StatefulWidget {
  final LocalAssetsServer? localAssetsServer;
  final DictionaryProvider dictionaryProvider;
  const MyBooksWidget(
      {super.key,
      required this.localAssetsServer,
      required this.dictionaryProvider});

  @override
  State<MyBooksWidget> createState() => _MyBooksWidgetState();
}

class _MyBooksWidgetState extends State<MyBooksWidget> {
  Widget headlineWidget(String title, IconData iconData, Color textColor) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 10, 10),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    FaIcon(
                      iconData,
                      color: textColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(title,
                        style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 18)),
                  ]),
                  CupertinoButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            SwipeablePageRoute(
                                canOnlySwipeFromEdge: true,
                                backGestureDetectionWidth: 25,
                                builder: (context) {
                                  return Reader(
                                      isAddBook: true,
                                      initialUrl:
                                          'http://localhost:${LocalAssetsServerProvider.port}/manage.html',
                                      localAssetsServer:
                                          widget.localAssetsServer,
                                      dictionaryProvider:
                                          widget.dictionaryProvider);
                                })).then((value) {
                          setState(() {
                            // refresh state
                          });
                        });
                      },
                      padding: const EdgeInsets.all(0.0),
                      child: const Icon(CupertinoIcons.add))
                ])));
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.black, darkColor: CupertinoColors.white),
        context);
    return Column(children: [
      headlineWidget("EPUB Reader", FontAwesomeIcons.bookOpen, textColor),
      FutureBuilder<List<Book>>(
          future: TtuSource.getBooksHistory(widget.localAssetsServer!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Center(
                    child: Column(children: [
                  const SizedBox(height: 50),
                  Text('No Books Added', style: TextStyle(color: textColor)),
                  const SizedBox(height: 50),
                ]));
              }
              return SizedBox(
                  height: 200,
                  child: ListView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      children: [
                        ...snapshot.data!
                            .asMap()
                            .entries
                            .map((entry) => BookWidget(
                                width: 130,
                                book: entry.value,
                                onTap: (mediaIdentifier) {
                                  Navigator.push(
                                      context,
                                      SwipeablePageRoute(
                                          canOnlySwipeFromEdge: true,
                                          backGestureDetectionWidth: 25,
                                          builder: (context) {
                                            return Reader(
                                                initialUrl: mediaIdentifier,
                                                localAssetsServer:
                                                    widget.localAssetsServer,
                                                dictionaryProvider:
                                                    widget.dictionaryProvider);
                                          }));
                                }))
                      ]));
            } else {
              return Container();
            }
          })
    ]);
  }
}
