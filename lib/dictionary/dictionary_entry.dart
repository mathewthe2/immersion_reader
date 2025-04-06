// https://github.com/lrorpilla/jidoujisho/blob/1ef19254b67fb766fa49fa12a82b009f31ec5419/chisa/lib/dictionary/dictionary_entry.dart

class DictionaryEntry {
  /// Initialise a dictionary entry with given details of a certain term.
  DictionaryEntry(
      {required this.term,
      required this.meanings,
      this.reading = '',
      this.id,
      this.dictionaryId,
      this.extra,
      this.meaningTags = const [],
      this.termTags = const [],
      this.popularity,
      this.sequence,
      this.index,
      this.transformedText,
      this.sourceTermExactMatchCount = 0});

  factory DictionaryEntry.fromMap(Map<String, Object?> map) => DictionaryEntry(
      id: map['id'] as int?,
      dictionaryId: map['dictionaryId'] as int,
      meanings:
          map['meanings'] != null ? (map['glossary'] as String).split(';') : [],
      term: map['expression'] as String,
      reading: map['reading'] as String,
      popularity: map['popularity'] as double,
      sequence: map['sequence'] as int,
      meaningTags: (map['meaningTags'] as String).split(' '),
      termTags: (map['termTags'] as String).split(' '));

  /// A unique identifier for the purposes of database storage.
  int? id;

  // for batch search
  int? index;

  // for highlighting the original word
  String? transformedText;

  int sourceTermExactMatchCount;

  /// The term represented by this dictionary entry.
  final String term;

  int? dictionaryId;

  /// The pronunciation of the term represented by this dictionary entry.
  final String reading;

  /// A list of definitions for a term. If there is only a single [String] item,
  /// this should be a single item list.
  List<String> meanings;

  /// A bonus field for storing any additional kind of information. For example,
  /// if there are any grammar rules related to this term.
  final String? extra;

  /// Tags that are used to indicate a certain trait to the definitions of
  /// this term.
  final List<String> meaningTags;

  /// Tags that are used to indicate a certain trait to this particular term.
  final List<String> termTags;

  /// A value that can be used to sort entries when performing a database
  /// search.
  final double? popularity;

  /// A value that can be used to group similar entries with the same value
  /// together.
  final int? sequence;

  /// The length of term is used as an index.
  int get termLength => term.length;

  /// The length of reading is used as an index.
  int get readingLength => reading.length;

  @override
  operator ==(Object other) => other is DictionaryEntry && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
