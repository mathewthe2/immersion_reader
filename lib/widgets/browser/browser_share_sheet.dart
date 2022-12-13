import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/data/browser/browser_bookmark.dart';
import 'package:immersion_reader/providers/browser_provider.dart';
import 'package:cupertino_lists/cupertino_lists.dart' as cupertino_lists;

class BrowserShareSheet extends StatefulWidget {
  final BrowserProvider? browserProvider;
  final InAppWebViewController? webViewController;
  const BrowserShareSheet(
      {super.key,
      required this.browserProvider,
      required this.webViewController});

  @override
  State<BrowserShareSheet> createState() => _BrowserShareSheetState();
}

class _BrowserShareSheetState extends State<BrowserShareSheet> {

  Future<void> handleAddBookmark() async {
    Uri? url = await widget.webViewController!.getUrl();
    if (url != null) {
      String name =
          await widget.webViewController!.getTitle() ?? url.toString();
      await widget.browserProvider!.addBookmarkWithUrl(BrowserBookmark.fromLink(name, url));
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.black,
            darkColor: CupertinoColors.systemBackground),
        context);
    return Column(
      children: [
        cupertino_lists.CupertinoListSection(children: [
          cupertino_lists.CupertinoListTile(
            title: const Text("Add Bookmark"),
            onTap: () {
              handleAddBookmark();
              Navigator.pop(context);
            },
            trailing: Icon(CupertinoIcons.book, color: textColor),
          ),
        ])
      ],
    );
  }
}
