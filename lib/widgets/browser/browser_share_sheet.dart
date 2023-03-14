import 'dart:io';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/utils/system_dialog.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/data/browser/browser_bookmark.dart';
import 'package:immersion_reader/managers/browser/browser_manager.dart';
import 'package:immersion_reader/utils/folder_utils.dart';
import 'package:lean_file_picker/lean_file_picker.dart';

class BrowserShareSheet extends StatefulWidget {
  final InAppWebViewController? webViewController;
  const BrowserShareSheet({super.key, required this.webViewController});

  @override
  State<BrowserShareSheet> createState() => _BrowserShareSheetState();
}

class _BrowserShareSheetState extends State<BrowserShareSheet> {
  List<String> _htmlFiles = [];
  // late String _selectedHtmlFile;
  Directory? _workingDirectoryCache;

  static const String pdfViewerUrl =
      'https://mozilla.github.io/pdf.js/web/viewer.html';

  Future<void> handleAddBookmark() async {
    Uri? url = await widget.webViewController!.getUrl();
    if (url != null) {
      String name =
          await widget.webViewController!.getTitle() ?? url.toString();
      // List<Favicon> icons = await widget.webViewController!.getFavicons();
      // print(icons);
      await BrowserManager()
          .addBookmarkWithUrl(BrowserBookmark.fromLink(name, url));
    }
  }

  Future<void> handleLoadFiles() async {
    final file = await pickFile(
      allowedExtensions: ['zip'],
    );

    if (file != null) {
      File zipFile = File(file.path);
      _workingDirectoryCache ??= await FolderUtils.getWorkingFolder();
      _htmlFiles = [];
      try {
        await ZipFile.extractToDirectory(
            zipFile: zipFile,
            destinationDir: _workingDirectoryCache!,
            onExtracting: (zipEntry, progress) {
              debugPrint('progress: ${progress.toStringAsFixed(1)}%');
              if (zipEntry.name.contains('html') &&
                  !zipEntry.name.contains('__MACOSX')) {
                // find html files and ignore MACOS utility files
                _htmlFiles.add(zipEntry.name);
              }
              return ZipFileOperation.includeItem;
            });
      } catch (e) {
        debugPrint(e.toString());
      }
      if (context.mounted) {
        if (_htmlFiles.isEmpty) {
          showInfoDialog(context, 'No HTML files founds in zipped file.');
        } else {
          if (_htmlFiles.length == 1) {
            loadHTMLFile(_htmlFiles.first);
          } else {
            showCupertinoModalPopup(
              context: context,
              builder: _selectHTMLModalBuilder,
            );
          }
        }
      }
    }
  }

  Future<void> loadHTMLFile(String htmlFile) async {
    String path = p.join(_workingDirectoryCache!.path, htmlFile);
    await widget.webViewController
        ?.loadUrl(urlRequest: URLRequest(url: Uri(scheme: 'file', path: path)));
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> handleLoadPDF() async {
    Navigator.pop(context);
    await widget.webViewController
        ?.loadUrl(urlRequest: URLRequest(url: Uri.parse(pdfViewerUrl)));
  }

  Widget _selectHTMLModalBuilder(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text('Select HTML file'),
      actions: [
        ..._htmlFiles.map((String htmlPath) => CupertinoActionSheetAction(
              child: Text(htmlPath),
              onPressed: () {
                loadHTMLFile(htmlPath);
                Navigator.pop(context);
              },
            ))
      ],
    );
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
        CupertinoListSection(children: [
          CupertinoListTile(
            title: const Text("Add Bookmark"),
            onTap: () {
              handleAddBookmark();
              Navigator.pop(context);
            },
            trailing: Icon(CupertinoIcons.book, color: textColor),
          ),
          CupertinoListTile(
            title: const Text("Load Local Files (*.zip)"),
            onTap: () {
              handleLoadFiles();
            },
            trailing: Icon(CupertinoIcons.folder, color: textColor),
          ),
          CupertinoListTile(
            title: const Text("PDF Viewer"),
            onTap: () {
              handleLoadPDF();
            },
            trailing: Icon(CupertinoIcons.book_circle, color: textColor),
          ),
        ])
      ],
    );
  }
}
