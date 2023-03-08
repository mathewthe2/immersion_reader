import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/pages/reader/reader_stats_page.dart';
import 'package:immersion_reader/providers/profile_provider.dart';
import 'package:immersion_reader/providers/reader_session_provider.dart';
import 'package:immersion_reader/providers/settings_provider.dart';
import 'package:immersion_reader/utils/reader/local_asset_server_manager.dart';
import 'package:immersion_reader/widgets/my_books/book_goal/book_goal_widget.dart';
import 'package:immersion_reader/widgets/reader/reader.dart';
import 'package:immersion_reader/utils/reader/ttu_source.dart';
import 'package:immersion_reader/widgets/my_books/book_widget.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyBooksWidget extends StatefulWidget {
  final ProfileProvider profileProvider;
  final SettingsProvider settingsProvider;
  static const String contentType = 'book';
  const MyBooksWidget(
      {super.key,
      required this.profileProvider,
      required this.settingsProvider});

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
    ReaderSessionProvider readerSessionProvider = ReaderSessionProvider.create(
        widget.profileProvider, MyBooksWidget.contentType);
    // bool rootNavigator = widget.settingsProvider.getIsEnabledReaderFullScreen();
    void navigateToBook(
        {required String mediaIdentifier, bool isFullScreen = false}) {
      Navigator.of(context, rootNavigator: isFullScreen)
          .push(SwipeablePageRoute(
              canOnlySwipeFromEdge: true,
              builder: (context) {
                return Reader(
                    initialUrl: mediaIdentifier,
                    readerSessionProvider: readerSessionProvider);
              }))
          .then((value) {
        readerSessionProvider.stop();
        setState(() {
          // refresh state
        });
      });
    }

    return FutureBuilder<bool>(
        future: widget.settingsProvider.getIsEnabledReaderFullScreen(),
        builder: ((context, snapshot) {
          bool isEnabledReaderFullScreen =
              snapshot.hasData ? snapshot.data! : false;
          return Column(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(SwipeablePageRoute(
                          canOnlySwipeFromEdge: true,
                          backGestureDetectionWidth: 25,
                          builder: (context) {
                            return ReaderStatsPage(profileProvider: widget.profileProvider);
                          }));
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'View Stats',
                            style: TextStyle(
                                color:
                                    CupertinoColors.label.resolveFrom(context)),
                          ),
                          const Icon(
                              size: 18,
                              CupertinoIcons.forward,
                              color: CupertinoColors.inactiveGray),
                        ]))),
            BookGoalWidget(
                profileProvider: widget.profileProvider,
                onTapBook: (String mediaIdentifier) => navigateToBook(
                    mediaIdentifier: mediaIdentifier,
                    isFullScreen: isEnabledReaderFullScreen)),
            headlineWidget(
                title: "EPUB Reader",
                iconData: FontAwesomeIcons.bookOpen,
                textColor: CupertinoColors.label.resolveFrom(context),
                onTap: () {
                  Navigator.of(context,
                          rootNavigator: isEnabledReaderFullScreen)
                      .push(SwipeablePageRoute(
                          canOnlySwipeFromEdge: true,
                          backGestureDetectionWidth: 25,
                          builder: (context) {
                            return Reader(
                                isAddBook: true,
                                initialUrl:
                                    'http://localhost:${LocalAssetsServerManager.port}',

                                readerSessionProvider: readerSessionProvider);
                          }))
                      .then((value) {
                    readerSessionProvider.stop();
                    setState(() {
                      // refresh state
                    });
                  });
                }),
            FutureBuilder<List<Book>>(
                future: TtuSource.getBooksHistory(LocalAssetsServerManager().server!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return SizedBox(
                          height: 200,
                          child: Column(children: [
                            const SizedBox(height: 80),
                            Text('No Books Added',
                                style: TextStyle(
                                    color: CupertinoColors.label
                                        .resolveFrom(context)))
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
                                          navigateToBook(
                                              mediaIdentifier: mediaIdentifier,
                                              isFullScreen:
                                                  isEnabledReaderFullScreen)))
                            ]));
                  } else {
                    return const SizedBox(height: 200);
                  }
                }),
          ]);
        }));
  }
}
