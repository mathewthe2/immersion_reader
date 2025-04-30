class AudioBookMatchResult {
  int bookId;
  String elementHtml; // with matched results
  String htmlBackup;
  String lineMatchRate;
  String bookSubtitleDiffRate;
  int matchedSubtitles;

  AudioBookMatchResult(
      {required this.bookId,
      required this.elementHtml,
      required this.htmlBackup,
      this.matchedSubtitles = 0,
      this.lineMatchRate = "",
      this.bookSubtitleDiffRate = ""});
}
