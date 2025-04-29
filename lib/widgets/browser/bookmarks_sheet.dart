import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:immersion_reader/data/browser/browser_bookmark.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/managers/browser/browser_manager.dart';

class BookmarksSheet extends StatefulWidget {
  final InAppWebViewController? webViewController;
  const BookmarksSheet({super.key, required this.webViewController});

  @override
  State<BookmarksSheet> createState() => _BookmarksSheetState();
}

class _BookmarksSheetState extends State<BookmarksSheet> {
  bool isEditMode = false;
  bool isConfirmDelete = false;
  late List<BrowserBookmark> bookmarks;

  void handleTapBookmark(BrowserBookmark bookmark, BuildContext context) {
    switch (bookmark.type) {
      case BrowserBookMarkType.link:
        widget.webViewController!
            .loadUrl(urlRequest: URLRequest(url: WebUri(bookmark.url)));
        SmartDialog.dismiss();
        break;
      case BrowserBookMarkType.folder:
        break;
    }
  }

  Future<void> handleDeleteBookmark(BrowserBookmark bookmark) async {
    await BrowserManager().deleteBookmark(bookmark.id);
    setState(() {
      bookmarks.removeWhere((element) => element.id == bookmark.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.black,
            darkColor: CupertinoColors.systemBackground),
        context);
    return CupertinoScrollbar(
        child: SingleChildScrollView(
            child: Column(children: [
      Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text('Bookmarks',
              style: TextStyle(color: textColor, fontSize: 20))),
      FutureBuilder<List<BrowserBookmark>>(
          future: BrowserManager().getBookmarks(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              bookmarks = snapshot.data!;
              if (bookmarks.isEmpty) {
                return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text("No bookmarks",
                        style: TextStyle(color: textColor)));
              }
              return CupertinoListSection(children: [
                ...bookmarks.map((BrowserBookmark bookmark) => Slidable(
                    endActionPane:
                        ActionPane(motion: const ScrollMotion(), children: [
                      SlidableAction(
                        onPressed: (context) => handleDeleteBookmark(bookmark),
                        backgroundColor: CupertinoColors.destructiveRed,
                        foregroundColor: CupertinoColors.white,
                        label: 'Delete',
                      ),
                    ]),
                    child: CupertinoListTile(
                        title: SizedBox(
                            width: context.screenWidth * 0.8,
                            child: Text(bookmark.name,
                                overflow: TextOverflow.ellipsis)),
                        leading: Container(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                              size: 22,
                              bookmark.isFolder()
                                  ? CupertinoIcons.folder
                                  : CupertinoIcons.book),
                        ),
                        trailing: bookmark.isFolder()
                            ? const Icon(CupertinoIcons.forward)
                            : null,
                        onTap: () => handleTapBookmark(bookmark, context))))
              ]);
            } else {
              return const CupertinoActivityIndicator(
                animating: true,
                radius: 24,
              );
            }
          }),
      // Align(
      //     alignment: Alignment.bottomLeft,
      //     child: CupertinoButton(
      //         child: const Text('Add folder'), onPressed: () {

      //         }))
    ])));
  }
}
