import 'package:flutter/cupertino.dart';
import 'package:cupertino_lists/cupertino_lists.dart' as cupertino_lists;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/data/browser/browser_bookmark.dart';
import 'package:immersion_reader/providers/browser_provider.dart';

class BookmarksSheet extends StatefulWidget {
  final BrowserProvider? browserProider;
  final InAppWebViewController? webViewController;
  const BookmarksSheet({super.key, required this.browserProider, required this.webViewController});

  @override
  State<BookmarksSheet> createState() => _BookmarksSheetState();
}

class _BookmarksSheetState extends State<BookmarksSheet> {
  bool isEditMode = false;
  bool isConfirmDelete = false;

  void handleTapBookmark(BrowserBookmark bookmark, BuildContext context ) {
    switch (bookmark.type) {
      case BrowserBookMarkType.link:
        widget.webViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(bookmark.url)));
        Navigator.pop(context);
        break;
      case BrowserBookMarkType.folder:
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.black,
            darkColor: CupertinoColors.systemBackground),
        context);
    return Column(children: [
      Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text('Bookmarks',
              style: TextStyle(color: textColor, fontSize: 20))),
      FutureBuilder<List<BrowserBookmark>>(
          future: widget.browserProider?.getBookmarks(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Align(
                  alignment: Alignment.centerLeft,
                  child: cupertino_lists.CupertinoListSection(children: [
                    ...snapshot.data!.map((BrowserBookmark bookmark) =>
                        cupertino_lists.CupertinoListTile(
                            title: Text(bookmark.name),
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
                            onTap: () => handleTapBookmark(bookmark, context)))
                  ]));
            } else {
              return const CupertinoActivityIndicator(
                animating: true,
                radius: 24,
              );
            }
          })
    ]);
  }
}
