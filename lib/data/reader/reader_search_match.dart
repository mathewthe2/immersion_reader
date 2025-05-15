class ReaderSearchMatch {
  String? chapter;
  int? characterCount;
  int? characterIndex;
  int? characterLength;
  int? paragraphIndex;
  String? sentence;

  ReaderSearchMatch(
      {this.chapter,
      this.characterCount,
      this.characterIndex,
      this.characterLength,
      this.paragraphIndex,
      this.sentence});

  factory ReaderSearchMatch.fromMap(Map<String, Object?> map) =>
      ReaderSearchMatch(
          chapter: map['chapter'] as String?,
          characterCount: map['characterCount'] as int?,
          characterIndex: map['characterIndex'] as int?,
          characterLength: map['characterLength'] as int?,
          paragraphIndex: map['paragraphIndex'] as int?,
          sentence: map['sentence'] as String?);
}
