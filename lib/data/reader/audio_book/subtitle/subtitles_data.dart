import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/data/reader/audio_book/subtitle/subtitle.dart';
import 'package:immersion_reader/utils/reader/srt_parser_js.dart';

class SubtitlesData {
  List<Subtitle> subtitles;
  Map<String, int> indexToSubIndexMap;

  SubtitlesData({required this.subtitles, required this.indexToSubIndexMap});

  static final SubtitlesData empty =
      SubtitlesData(subtitles: [], indexToSubIndexMap: {});

  factory SubtitlesData.fromMapList(List<dynamic> mapList) {
    List<Subtitle> subtitles = [];
    Map<String, int> indexMap = {};
    for (int i = 0; i < mapList.length; i++) {
      final subtitle =
          Subtitle.fromMap(Map<String, dynamic>.from(mapList[i]), i);
      subtitles.add(subtitle);
      indexMap[subtitle.id] = i;
    }
    return SubtitlesData(indexToSubIndexMap: indexMap, subtitles: subtitles);
  }

  int? getSubIndexByIndex(String index) {
    return indexToSubIndexMap[index];
  }

  void reset() {
    subtitles = [];
    indexToSubIndexMap = {};
  }

  static Future<SubtitlesData> readSubtitlesFromFile(
      {required File file,
      required InAppWebViewController webController}) async {
    final content = await file.readAsString();
    final result =
        await webController.evaluateJavascript(source: parseSubtitle(content));
    if (result != null) {
      return SubtitlesData.fromMapList(result);
    }
    return SubtitlesData(subtitles: [], indexToSubIndexMap: {});
  }
}
