class AudioBookMatchResult {
  int bookId;
  String elementHtml; // with matched results
  String htmlBackup;
  String lineMatchRate;
  String bookSubtitleDiffRate;

  AudioBookMatchResult(
      {required this.bookId,
      required this.elementHtml,
      required this.htmlBackup,
      this.lineMatchRate = "",
      this.bookSubtitleDiffRate = ""});
}
