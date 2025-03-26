class VocabularyEntry {
  Map<String, dynamic> vocab;
  List<Map<String, dynamic>> vocabGlosses;

  VocabularyEntry({required this.vocab, required this.vocabGlosses});

  static int _idCounter = 0;
  static const int dictionaryId = 1;

  factory VocabularyEntry.create(
      {required Map<String, dynamic> vocab, required List<String> meanings}) {
    _idCounter += 1;
    return VocabularyEntry(
        vocab: {...vocab, 'id': _idCounter, 'dictionaryId': dictionaryId},
        vocabGlosses: meanings
            .map((meaning) => {
                  'vocabId': _idCounter,
                  'glossary': meaning,
                  'dictionaryId': dictionaryId,
                })
            .toList());
  }

  String get expression => vocab['expression'];
  String get reading => vocab['reading'];
}

class VocabBank {
  VocabularyEntry verb1 = VocabularyEntry.create(vocab: {
    'expression': '呑む',
    'reading': 'のむ',
    'sequence': 1169870,
    'popularity': 741.0,
    'meaningTags': 'v5m vt',
    'termTags': 'news P spec',
  }, meanings: [
    'to drink',
    'to gulp',
    'to swallow',
    'to take (medicine)'
  ]);
  VocabularyEntry verb2 = VocabularyEntry.create(vocab: {
    'expression': '取る',
    'reading': 'とる',
    'sequence': 1326980,
    'popularity': 1999800,
    'meaningTags': 'v5r vt',
    'termTags': '',
  }, meanings: [
    "to take",
    "to pick up",
    "to grab",
    "to catch",
    "to hold"
  ]);
  VocabularyEntry adverb1 = VocabularyEntry.create(vocab: {
    'expression': 'とても',
    'reading': 'とても',
    'sequence': 1008630,
    'popularity': 999800,
    'meaningTags': 'adv uk',
    'termTags': '',
  }, meanings: [
    "very",
    "awfully",
    "exceedingly"
  ]);
  VocabularyEntry noun1 = VocabularyEntry.create(vocab: {
    'expression': '欠伸',
    'reading': 'あくび',
    'sequence': 1254010,
    'popularity': 609.0,
    'meaningTags': 'n uk',
    'termTags': 'P ichi',
  }, meanings: [
    'yawn',
    'yawning',
  ]);
  VocabularyEntry noun2 = VocabularyEntry.create(vocab: {
    'expression': '反芻',
    'reading': 'はんすう',
    'sequence': 1481160,
    'popularity': -200,
    'meaningTags': 'n vs vt',
    'termTags': '',
  }, meanings: [
    'rumination',
    'regurgitation',
    'chewing the cud'
  ]);
  VocabularyEntry noun3 = VocabularyEntry.create(vocab: {
    'expression': '反芻',
    'reading': 'はんすう',
    'sequence': 1481160,
    'popularity': -200,
    'meaningTags': 'n vs vt',
    'termTags': '',
  }, meanings: [
    'turning over in one\'s mind',
    'thinking over (something)',
    'pondering',
    'musing',
    'rumination (about a subject)'
  ]);
  VocabularyEntry noun4 = VocabularyEntry.create(vocab: {
    'expression': '反すう',
    'reading': 'はんすう',
    'sequence': 1481160,
    'popularity': -10200,
    'meaningTags': 'n vs vt',
    'termTags': '',
  }, meanings: [
    'rumination',
    'regurgitation',
    'chewing the cud'
  ]);
  VocabularyEntry noun5 = VocabularyEntry.create(vocab: {
    'expression': '反すう',
    'reading': 'はんすう',
    'sequence': 1481160,
    'popularity': -10200,
    'meaningTags': 'n vs vt',
    'termTags': '',
  }, meanings: [
    'turning over in one\'s mind',
    'thinking over (something)',
    'pondering',
    'musing',
    'rumination (about a subject)'
  ]);
  VocabularyEntry noun6 = VocabularyEntry.create(vocab: {
    'expression': '彼',
    'reading': 'かれ',
    'sequence': 1483070,
    'popularity': 999800,
    'meaningTags': 'pn',
    'termTags': '⭐ ichi',
  }, meanings: [
    'he',
    'him'
  ]);
  VocabularyEntry noun7 = VocabularyEntry.create(vocab: {
    'expression': '彼',
    'reading': 'あれ',
    'sequence': 1000580,
    'popularity': -5020200,
    'meaningTags': 'pn uk',
    'termTags': 'R',
  }, meanings: [
    'that',
    'that thing'
  ]);
}
