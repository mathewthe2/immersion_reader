import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/utils/reader/srt_parser_js.dart';

List<double> getTimeParts(double s) {
  // Calculate hours, minutes, seconds, and milliseconds
  double hours = (s / 3600).floorToDouble();
  double hoursDiff = s - hours * 3600;
  double minutes = (hoursDiff / 60).floorToDouble();
  double minutesDiff = hoursDiff - minutes * 60;
  double seconds = minutesDiff.floorToDouble();
  double ms = ((minutesDiff - seconds) * 1000).roundToDouble();

  // Return the time parts as a list
  return [hours, minutes, seconds, ms];
}

String toTimeStamp(double s) {
  // Get time parts from the given seconds
  List<double> timeParts = getTimeParts(s);

  // Format the parts into a timestamp string
  return '${timeParts[0].toStringAsFixed(0).padLeft(2, '0')}:${timeParts[1].toStringAsFixed(0).padLeft(2, '0')}:${timeParts[2].toStringAsFixed(0).padLeft(2, '0')},${timeParts[3].toStringAsFixed(0).padLeft(3, '0')}';
}

double between(double minimum, double maximum, double value) {
  return min(maximum, max(minimum, value));
}

class Subtitle {
  String id;
  double originalStartSeconds;
  double? adjustedStartSeconds;
  double startSeconds;
  String startTime;
  double originalEndSeconds;
  double? adjustedEndSeconds;
  double endSeconds;
  String endTime;
  String originalText;
  String text;
  int subIndex;

  Subtitle(
      {required this.id,
      required this.originalStartSeconds,
      this.adjustedStartSeconds,
      required this.startSeconds,
      required this.startTime,
      required this.originalEndSeconds,
      this.adjustedEndSeconds,
      required this.endSeconds,
      required this.endTime,
      required this.originalText,
      required this.text,
      required this.subIndex});

  // to be configurable
  static int subtitlesGlobalStartPadding = 0;
  static int subtitlesGlobalEndPadding = 0;
  static double duration = 0;

  factory Subtitle.fromMap(Map<String, Object?> map, int index) {
    double startSeconds =
        max(0, (map['startSeconds'] as double) + subtitlesGlobalStartPadding);
    double endSeconds = duration > 0
        ? between(0, duration,
            (map['endSeconds'] as double) + subtitlesGlobalEndPadding)
        : max(0, (map['endSeconds'] as double) + subtitlesGlobalEndPadding);
    String text = (map['text'] as String).trim();

    return Subtitle(
        id: map["id"] as String,
        originalStartSeconds: map['startSeconds'] as double,
        startSeconds: startSeconds,
        startTime: toTimeStamp(startSeconds),
        originalEndSeconds: map['endSeconds'] as double,
        endSeconds: endSeconds,
        endTime: toTimeStamp(endSeconds),
        originalText: map['text'] as String,
        text: text,
        subIndex: index);
  }

  @override
  String toString() {
    return json.encode({
      'id': id,
      'originalStartSeconds': originalStartSeconds,
      'adjustedStartSeconds': adjustedStartSeconds,
      'startSeconds': startSeconds,
      'startTime': startTime,
      'originalEndSeconds': originalEndSeconds,
      'adjustedEndSeconds': adjustedEndSeconds,
      'endSeconds': endSeconds,
      'endTime': endTime,
      'originalText': originalText,
      'text': text,
      'subIndex': subIndex
    });
  }

  Duration get startDuration =>
      Duration(milliseconds: (originalStartSeconds * 1000).round());

  Duration get endDuration =>
      Duration(milliseconds: (originalEndSeconds * 1000).round());

  static String subtitleListToString(List<Subtitle> subtitles) {
    return '[${subtitles.map((subtitle) => subtitle.toString()).toList().join(", ")}]';
  }

  static Future<List<Subtitle>> readSubtitlesFromFile(
      {required File file,
      required InAppWebViewController webController}) async {
    final content = await file.readAsString();
    final result =
        await webController.evaluateJavascript(source: parseSubtitle(content));
    List<Subtitle> subtitles = [];
    if (result != null) {
      for (int i = 0; i < result.length; i++) {
        subtitles
            .add(Subtitle.fromMap(Map<String, dynamic>.from(result[i]), i));
      }
    }
    return subtitles;
  }
}
