import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/managers/reader/reader_session_manager.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/pages/reader/reader_stats_page.dart';
import 'package:immersion_reader/managers/reader/local_asset_server_manager.dart';
import 'package:immersion_reader/utils/system_ui.dart';
import 'package:immersion_reader/widgets/my_books/book_goal/book_goal_widget.dart';
import 'package:immersion_reader/widgets/popup_dictionary/popup_dictionary.dart';
import 'package:immersion_reader/widgets/reader/reader.dart';
import 'package:immersion_reader/utils/reader/ttu_source.dart';
import 'package:immersion_reader/widgets/my_books/book_widget.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyBooksWidget extends StatefulWidget {
  static const String contentType = 'book';
  const MyBooksWidget({super.key});

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

  void onExitReader() {
    ReaderSessionManager().stop();
    PopupDictionary().dismissPopupDictionary();
    showSystemUI();
    setState(() {
      // refresh state
    });
  }

  @override
  Widget build(BuildContext context) {
    ReaderSessionManager.createSession(MyBooksWidget.contentType);
    void navigateToBook(
        {required String mediaIdentifier,
        bool isFullScreen = false,
        bool isShowDeviceStatusBar = false}) {
      Navigator.of(context, rootNavigator: isFullScreen)
          .push(SwipeablePageRoute(
              canOnlySwipeFromEdge: true,
              builder: (context) {
                return Reader(
                  initialUrl: mediaIdentifier,
                  isShowDeviceStatusBar: isShowDeviceStatusBar,
                );
              }))
          .then((_) => onExitReader());
    }

    return Column(children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 20),
          child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(SwipeablePageRoute(
                    canOnlySwipeFromEdge: true,
                    backGestureDetectionWidth: 25,
                    builder: (context) {
                      return const ReaderStatsPage();
                    }));
              },
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(
                  'View Stats',
                  style: TextStyle(
                      color: CupertinoColors.label.resolveFrom(context)),
                ),
                const Icon(
                    size: 18,
                    CupertinoIcons.forward,
                    color: CupertinoColors.inactiveGray),
              ]))),
      BookGoalWidget(
          onTapBook: (String mediaIdentifier) => navigateToBook(
              mediaIdentifier: mediaIdentifier,
              isFullScreen: SettingsManager()
                  .cachedAppearanceSettings()
                  .enableReaderFullScreen,
              isShowDeviceStatusBar: SettingsManager()
                  .cachedAppearanceSettings()
                  .isShowDeviceStatusBar)),
      headlineWidget(
          title: "EPUB Reader",
          iconData: FontAwesomeIcons.bookOpen,
          textColor: CupertinoColors.label.resolveFrom(context),
          onTap: () {
            Navigator.of(context,
                    rootNavigator: SettingsManager()
                        .cachedAppearanceSettings()
                        .enableReaderFullScreen)
                .push(SwipeablePageRoute(
                    canOnlySwipeFromEdge: true,
                    backGestureDetectionWidth: 25,
                    builder: (context) {
                      return Reader(
                          isAddBook: true,
                          isShowDeviceStatusBar: SettingsManager()
                              .cachedAppearanceSettings()
                              .isShowDeviceStatusBar,
                          initialUrl:
                              'http://localhost:${LocalAssetsServerManager.port}');
                    }))
                .then((_) => onExitReader());
          }),
      FutureBuilder<List<Book>>(
          future: TtuSource.getBooksHistory(LocalAssetsServerManager().server!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return SizedBox(
                    height: MediaQuery.of(context).size.width / 2.15,
                    child: Column(children: [
                      const SizedBox(height: 80),
                      Text('No Books Added',
                          style: TextStyle(
                              color:
                                  CupertinoColors.label.resolveFrom(context)))
                    ]));
              }
              return SizedBox(
                  height: MediaQuery.of(context).size.width / 2.15,
                  child: ListView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      children: [
                        ...snapshot.data!.asMap().entries.map((entry) =>
                            BookWidget(
                                width: 130,
                                book: entry.value,
                                onTap: (mediaIdentifier) => navigateToBook(
                                    mediaIdentifier: mediaIdentifier,
                                    isFullScreen:
                                        SettingsManager()
                                            .cachedAppearanceSettings()
                                            .enableReaderFullScreen,
                                    isShowDeviceStatusBar: SettingsManager()
                                        .cachedAppearanceSettings()
                                        .isShowDeviceStatusBar)))
                      ]));
            } else {
              return SizedBox(
                height: MediaQuery.of(context).size.width / 2.15,
              );
            }
          }),
    ]);
  }
}
