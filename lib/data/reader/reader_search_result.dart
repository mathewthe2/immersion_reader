import 'dart:math';

class ReaderSearchResult {
  List<int> matches;
  String text;

  ReaderSearchResult({required this.matches, required this.text});

  List<String> get textMatches => matches
      .map((match) => text.substring(match, min(match + 10, text.length)))
      .toList();

  List<(int, String)> get displayMatches => matches
      .map((match) =>
          (match, text.substring(match, min(match + 10, text.length))))
      .toList();
}
