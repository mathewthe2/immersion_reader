// import 'dart:math';

class ReaderSearchMatch {
  String? chapter;
  int? characterCount;
  int? characterIndex;
  int? characterLength;
  String? sentence;

  ReaderSearchMatch(
      {this.chapter,
      this.characterCount,
      this.characterIndex,
      this.characterLength,
      this.sentence});

  factory ReaderSearchMatch.fromMap(Map<String, Object?> map) =>
      ReaderSearchMatch(
          chapter: map['chapter'] as String?,
          characterCount: map['characterCount'] as int?,
          characterIndex: map['characterIndex'] as int?,
          characterLength: map['characterLength'] as int?,
          sentence: map['sentence'] as String?);
  // List<(int, int)> matchStarts; // originalStart, adjustedStart
  // // List<int> matches;
  // String text;

  // ReaderSearchResult({required this.matchStarts, required this.text});

  // List<String> get textMatches => matchStarts
  //     .map((match) => text.substring(match.$1, min(match.$1 + 10, text.length)))
  //     .toList();

  // List<(int, String)> get displayMatches => matchStarts
  //     .map((match) =>
  //         (match.$2, text.substring(match.$1, min(match.$1 + 10, text.length))))
  //     .toList();
}
