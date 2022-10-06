class Vocabulary {
  int? id;
  int? vocabularyId; // same as id when parsing from dictionary
  String? expression;
  String? reading;
  List<String>? tags;
  List<String>? glossary;
  List<String>? addons;
  // for search
  String? source;
  List<String>? rules;
  // pitch
  List<String>? pitchSvg;
  String sentence = '';

  Vocabulary(
      {this.id,
      this.vocabularyId,
      this.expression,
      this.reading,
      this.tags,
      this.glossary,
      this.addons,
      this.sentence = ''});

  factory Vocabulary.fromMap(Map<String, Object?> map) => Vocabulary(
      id: map['id'] as int?,
      vocabularyId: map['vocabulary_id'] as int?,
      expression: map['expression'] as String?,
      reading: map['reading'] as String?,
      glossary:
          map['glossary'] != null ? (map['glossary'] as String).split(';') : [],
      tags: (map['tags'] as String).split(' '),
      sentence: map['sentence'] != null ? map['sentence'] as String : '');

  String getFirstGlossary() {
    return (glossary ?? []).isEmpty ? '' : glossary?.first ?? '';
  }
}
