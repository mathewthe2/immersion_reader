class AudioLookupSubtitle {
  String subtitleId;
  String text;
  int textIndex;
  int? textLength; // text length to highlight

  AudioLookupSubtitle(
      {required this.textIndex,
      required this.text,
      required this.subtitleId,
      this.textLength});

  factory AudioLookupSubtitle.fromMap(Map<String, Object?> map) =>
      AudioLookupSubtitle(
          subtitleId: map['subtitleId'] as String,
          text: map['text'] as String,
          textIndex: map['textIndex'] as int);

  String get highlightedText {
    if (textLength != null &&
        textIndex >= 0 &&
        textIndex + textLength! - 1 < text.length) {
      return text.substring(textIndex, textIndex + textLength!);
    }
    return "";
  }
}
