import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/book_blob.dart';
import 'package:immersion_reader/data/reader/book_bookmark.dart';
import 'package:immersion_reader/data/reader/book_section.dart';
import 'package:immersion_reader/managers/reader/book_image_manager.dart';
import 'package:immersion_reader/managers/reader/book_manager.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/utils/reader/get_history_js.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:immersion_reader/managers/reader/local_asset_server_manager.dart';
import 'package:local_assets_server/local_assets_server.dart';

class TtuSource {
  static Future<List<Book>> getBooksHistory(
      LocalAssetsServer localAssetsServer) async {
    List<Book>? books;

    HeadlessInAppWebView webView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
          url: WebUri(
        LocalAssetsServerManager().getAssetUrl(),
      )),
      onLoadStop: (controller, url) async {
        var isMigrated = await SettingsManager().getIsMigratedFromIndexedDb();
        if (isMigrated) {
          books = await BookManager().getBooks();
        } else {
          controller.evaluateJavascript(
              source:
                  getHistoryJs); // deprecated way of fetching book data from ttu but still needed for migration
        }
      },
      onReceivedError: (controller, request, error) {
        debugPrint(error.description);
      },
      onReceivedHttpError: (controller, request, errorResponse) {
        debugPrint('${errorResponse.statusCode}:${errorResponse.data}');
      },
      onConsoleMessage: (controller, message) {
        late Map<String, dynamic> messageJson;
        debugPrint(message.message);
        try {
          if (message.messageLevel == ConsoleMessageLevel.ERROR) {
            debugPrint("Error while fetching books: ${message.message}");
            return;
          }
          messageJson = jsonDecode(message.message);

          if (messageJson.containsKey('messageType') &&
              messageJson['messageType'] == 'history') {
            try {
              books = getBooksFromJson(messageJson);
              migrateBookDataToDatabase(books);
            } catch (error, stack) {
              books = [];
              debugPrint('$error');
              debugPrint('$stack');
            }
          } else {
            debugPrint(message.message);
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      },
    );

    try {
      await webView.run();
      while (books == null) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } finally {
      await webView.dispose();
    }
    return books ?? [];
  }

  // run only if books have not been migrated yet
  static migrateBookDataToDatabase(List<Book>? books) async {
    if (books != null) {
      SmartDialog.showLoading(msg: "Migrating books from ttu to app.");
      bool isSuccess = await BookManager().bulkLoadBooksWithId(books);
      SettingsManager().setIsMigratedFromIndexedDb(isSuccess);
      SmartDialog.dismiss();
    }
  }

  static List<Book> getBooksFromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> bookmarks =
        List<Map<String, dynamic>>.from(jsonDecode(json['bookmark']));
    List<Map<String, dynamic>> datas =
        List<Map<String, dynamic>>.from(jsonDecode(json['data']));
    Map<int, Map<String, dynamic>> bookmarksById =
        Map<int, Map<String, dynamic>>.fromEntries(
            bookmarks.map((e) => MapEntry(e['dataId'] as int, e)));

    List<Book> items = datas.mapIndexed((index, data) {
      BookBookmark? bookmark = bookmarksById.containsKey(data["id"])
          ? BookBookmark.fromMap(
              {"id": data["id"], ...bookmarksById[data['id']]!})
          : null;

      String id = data['id'].toString();
      String title = data['title'] as String? ?? ' ';
      String elementHtml = data['elementHtml'] as String? ?? '';
      String styleSheet = data['styleSheet'] as String? ?? '';
      String? base64Image;
      List<BookSection> sections = (data['sections'] as List)
          .map((section) => BookSection.fromMap(section))
          .toList();
      List<BookBlob> blobs = (data['blobs'].keys.toList() as List)
          .map((blobKey) =>
              BookBlob(key: blobKey, base64Data: data["blobs"][blobKey]))
          .toList();
      try {
        Uri.parse(data['coverImage']);
        base64Image = data['coverImage'];
        BookImageManager().saveImageIfNotExists(
            base64Image: base64Image!, key: id, title: title);
      } catch (e) {
        base64Image = null;
      }
      return Book(
          id: int.parse(id),
          sections: sections,
          title: title,
          blobs: blobs,
          coverImage: base64Image,
          elementHtml: elementHtml,
          styleSheet: styleSheet,
          bookmark: bookmark,
          hasThumb: base64Image != null);
    }).toList();

    return items;
  }
}
