import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/utils/reader/get_history_js.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:immersion_reader/providers/local_asset_server_provider.dart';

class TtuSource {
  static Future<List<Book>> getBooksHistory() async {
    // final prefs = await SharedPreferences.getInstance();
    // final int? bookCounter = prefs.getInt('has_books');
    // if (bookCounter == null) {
    //   return [];
    // }
    List<Book>? books;
    HeadlessInAppWebView webView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
          url: Uri.parse(
        'http://localhost:${LocalAssetsServerProvider.port}',
      )),
      onLoadStop: (controller, url) async {
        controller.evaluateJavascript(source: getHistoryJs);
      },
      onConsoleMessage: (controller, message) {
        late Map<String, dynamic> messageJson;
        messageJson = jsonDecode(message.message);

        if (messageJson['messageType'] != null) {
          try {
            books = getBooksFromJson(messageJson);
          } catch (error, stack) {
            books = [];
            // debugPrint('$error');
            // debugPrint('$stack');
          }
        } else {
          debugPrint(message.message);
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

      String id = data['id'].toString();
      String title = data['title'] as String? ?? ' ';
      String? base64Image;
      try {
        Uri.parse(data['coverImage']);
        base64Image = data['coverImage'];
      } catch (e) {
        base64Image = null;
      }

      return Book(
        mediaIdentifier:
            'http://localhost:${LocalAssetsServerProvider.port}/b.html?id=$id&?title=$title',
        title: title,
        base64Image: base64Image,
        position: position,
        duration: duration,
      );
    }).toList();

    return items;
  }
}
