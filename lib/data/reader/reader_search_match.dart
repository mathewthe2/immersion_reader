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
}
