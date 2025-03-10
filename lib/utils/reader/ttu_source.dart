import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/managers/reader/book_image_manager.dart';
import 'package:immersion_reader/utils/reader/get_history_js.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:immersion_reader/managers/reader/local_asset_server_manager.dart';
import 'package:local_assets_server/local_assets_server.dart';

class TtuSource {
  static Future<List<Book>> getBooksHistory(
      LocalAssetsServer localAssetsServer) async {
    // final prefs = await SharedPreferences.getInstance();
    // final int? bookCounter = prefs.getInt('has_books');
    // if (bookCounter == null) {
    //   return [];
    // }
    List<Book>? books;
    HeadlessInAppWebView webView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
          url: WebUri(
        LocalAssetsServerManager().getAssetUrl(),
      )),
      onLoadStop: (controller, url) async {
        controller.evaluateJavascript(source: getHistoryJs);
      },
      onReceivedError: (controller, request, error) {
        debugPrint(error.description);
      },
      onReceivedHttpError: (controller, request, errorResponse) {
        debugPrint('${errorResponse.statusCode}:${errorResponse.data}');
      },
      onConsoleMessage: (controller, message) {
        late Map<String, dynamic> messageJson;
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

  static List<Book> getBooksFromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> bookmarks =
        List<Map<String, dynamic>>.from(jsonDecode(json['bookmark']));
    List<Map<String, dynamic>> datas =
        List<Map<String, dynamic>>.from(jsonDecode(json['data']));
    Map<int, Map<String, dynamic>> bookmarksById =
        Map<int, Map<String, dynamic>>.fromEntries(
            bookmarks.map((e) => MapEntry(e['dataId'] as int, e)));

    List<Book> items = datas.mapIndexed((index, data) {
      int position = 0;
      int duration = 1;

      Map<String, dynamic>? bookmark = bookmarksById[data['id']];

      if (bookmark != null) {
        position = bookmark['exploredCharCount'] as int;
        double progress = double.parse(bookmark['progress'].toString());
        if (progress == 0) {
          duration = 1;
        } else {
          duration = position ~/ progress;
        }
      }

      int totalCharacters = 0;
      for (dynamic section in data['sections']) {
        totalCharacters += section['characters'] as int? ?? 0;
      }

      String id = data['id'].toString();
      String title = data['title'] as String? ?? ' ';
      String? base64Image;
      try {
        Uri.parse(data['coverImage']);
        base64Image = data['coverImage'];
        BookImageManager().saveImageIfNotExists(
            base64Image: base64Image!, key: id, title: title);
      } catch (e) {
        base64Image = null;
      }
      return Book(
        mediaIdentifier:
            '${LocalAssetsServerManager().getAssetUrl()}/b.html?id=$id',
        title: title,
        base64Image: base64Image,
        position: position,
        duration: duration,
        totalCharacters: totalCharacters,
      );
    }).toList();

    return items;
  }
}
