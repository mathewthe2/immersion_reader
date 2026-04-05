class VocabularyEntry {
  Map<String, dynamic> vocab;
  List<Map<String, dynamic>> vocabGlosses;

  VocabularyEntry({required this.vocab, required this.vocabGlosses});

  static int _idCounter = 0;
  static const int dictionaryId = 1;

  factory VocabularyEntry.create({
    required Map<String, dynamic> vocab,
    required List<String> meanings,
  }) {
    _idCounter += 1;
    return VocabularyEntry(
      vocab: {...vocab, 'id': _idCounter, 'dictionaryId': dictionaryId},
      vocabGlosses: meanings
          .map(
            (meaning) => {
              'vocabId': _idCounter,
              'glossary': meaning,
              'dictionaryId': dictionaryId,
            },
          )
          .toList(),
    );
  }

  String get expression => vocab['expression'];
  String get reading => vocab['reading'];
}
