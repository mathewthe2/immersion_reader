class BookSection {
  String? reference;
  int charactersWeight;
  String? label;
  int? startCharacter;
  int? characters;
  String? parentChapter;

  BookSection(
      {this.reference,
      required this.charactersWeight,
      this.label,
      this.startCharacter,
      this.characters,
      this.parentChapter});

  factory BookSection.fromMap(Map<String, Object?> map) => BookSection(
      reference: map['reference'] as String?,
      charactersWeight: map['charactersWeight'] as int,
      label: map['label'] as String?,
      startCharacter: map['startCharacter'] as int?,
      characters: map['characters'] as int?,
      parentChapter: map['parentChapter'] as String?);

  Map<String, dynamic> toMap() {
    return {
      'reference': reference,
      'charactersWeight': charactersWeight,
      'label': label,
      'startCharacter': startCharacter,
      'characters': characters,
      'parentChapter': parentChapter
    };
  }
}
