import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/providers/local_asset_server_provider.dart';
import 'package:immersion_reader/providers/profile_provider.dart';
import 'package:immersion_reader/providers/reader_session_provider.dart';
import 'package:immersion_reader/widgets/my_books/book_goal/book_goal_widget.dart';
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
  final ProfileProvider profileProvider;
  static const String contentType = 'book';
  const MyBooksWidget(
      {super.key,
      required this.localAssetsServer,
      required this.dictionaryProvider,
      required this.profileProvider});

  @override
  State<MyBooksWidget> createState() => _MyBooksWidgetState();
}

class _MyBooksWidgetState extends State<MyBooksWidget> {
  Widget headlineWidget(
      {required String title,
      required IconData iconData,
      required Color textColor,
      required VoidCallback onTap}) {
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
                      onPressed: onTap,
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
    ReaderSessionProvider readerSessionProvider = ReaderSessionProvider.create(
        widget.profileProvider, MyBooksWidget.contentType);
    void navigateToBook(String mediaIdentifier) {
      Navigator.push(
          context,
          SwipeablePageRoute(
              canOnlySwipeFromEdge: true,
              backGestureDetectionWidth: 25,
              builder: (context) {
                return Reader(
                    initialUrl: mediaIdentifier,
                    localAssetsServer: widget.localAssetsServer,
                    dictionaryProvider: widget.dictionaryProvider,
                    readerSessionProvider: readerSessionProvider);
              })).then((value) {
        setState(() {
          // refresh state
        });
      });
    }

    return Column(children: [
      BookGoalWidget(
          profileProvider: widget.profileProvider,
          onTapBook: (String mediaIdentifier) =>
              navigateToBook(mediaIdentifier)),
      headlineWidget(
          title: "EPUB Reader",
          iconData: FontAwesomeIcons.bookOpen,
          textColor: textColor,
          onTap: () {
            Navigator.push(
                context,
                SwipeablePageRoute(
                    canOnlySwipeFromEdge: true,
                    backGestureDetectionWidth: 25,
                    builder: (context) {
                      return Reader(
                          isAddBook: true,
                          initialUrl:
                              'http://localhost:${LocalAssetsServerProvider.port}',
                          localAssetsServer: widget.localAssetsServer,
                          dictionaryProvider: widget.dictionaryProvider,
                          readerSessionProvider: readerSessionProvider);
                    })).then((value) {
              setState(() {
                // refresh state
              });
            });
          }),
      FutureBuilder<List<Book>>(
          future: TtuSource.getBooksHistory(widget.localAssetsServer!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return SizedBox(
                    height: 200,
                    child: Column(children: [
                      const SizedBox(height: 80),
                      Text('No Books Added', style: TextStyle(color: textColor))
                    ]));
              }
              return SizedBox(
                  height: 200,
                  child: ListView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      children: [
                        ...snapshot.data!.asMap().entries.map((entry) =>
                            BookWidget(
                                width: 130,
                                book: entry.value,
                                onTap: (mediaIdentifier) =>
                                    navigateToBook(mediaIdentifier)))
                      ]));
            } else {
              return const SizedBox(height: 200);
            }
          }),
    ]);
  }
}
