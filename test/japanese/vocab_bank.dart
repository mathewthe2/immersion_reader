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
  VocabularyEntry noun8 = VocabularyEntry.create(vocab: {
    'expression': 'それ',
    'reading': 'それ',
    'sequence': 1006970,
    'popularity': 999800,
    'meaningTags': 'pn uk',
    'termTags': '⭐ ichi',
  }, meanings: [
    "that",
    "it"
  ]);
  VocabularyEntry verb3 = VocabularyEntry.create(vocab: {
    'expression': '逸れる',
    'reading': 'それる',
    'sequence': 1576360,
    'popularity': 999800,
    'meaningTags': 'v1 vi uk',
    'termTags': '⭐ ichi',
  }, meanings: [
    "to turn away",
    "to bear off",
    "to veer away",
    "to swerve from",
    "to miss (e.g. a target)"
  ]);
  VocabularyEntry adj1 = VocabularyEntry.create(vocab: {
    'expression': 'その',
    'reading': 'その',
    'sequence': 1006830,
    'popularity': 999800,
    'meaningTags': 'adj-pn uk',
    'termTags': '⭐ spec',
  }, meanings: [
    "that",
    "the"
  ]);
  VocabularyEntry noun9 = VocabularyEntry.create(vocab: {
    'expression': '園',
    'reading': 'その',
    'sequence': 1176240,
    'popularity': 1999800,
    'meaningTags': 'n',
    'termTags': '⭐ ichi news5k',
  }, meanings: [
    "garden",
    "orchard",
    "park"
  ]);
  VocabularyEntry noun10 = VocabularyEntry.create(vocab: {
    'expression': '私',
    'reading': 'わたし',
    'sequence': 1311110,
    'popularity': 1999800,
    'meaningTags': 'pn',
    'termTags': '⭐ ichi news1k',
  }, meanings: [
    "I",
    "me"
  ]);
  VocabularyEntry noun11 = VocabularyEntry.create(vocab: {
    'expression': '私',
    'reading': 'し',
    'sequence': 2728300,
    'popularity': -200,
    'meaningTags': 'n',
    'termTags': '',
  }, meanings: [
    "private affairs",
    "personal matter"
  ]);
  VocabularyEntry noun12 = VocabularyEntry.create(vocab: {
    'expression': '私',
    'reading': 'あたし',
    'sequence': 1311125,
    'popularity': 999800,
    'meaningTags': 'pn fem uk',
    'termTags': '⭐ spec',
  }, meanings: [
    "I",
    "me"
  ]);
  VocabularyEntry noun13 = VocabularyEntry.create(vocab: {
    'expression': '私',
    'reading': 'あたくし',
    'sequence': 1311125,
    'popularity': -10200,
    'meaningTags': 'pn fem uk',
    'termTags': '',
  }, meanings: [
    "I",
    "me"
  ]);
  VocabularyEntry noun14 = VocabularyEntry.create(vocab: {
    'expression': '私',
    'reading': 'わい',
    'sequence': 2217330,
    'popularity': -200,
    'meaningTags': 'pn dated ksb',
    'termTags': '',
  }, meanings: [
    "I",
    "me"
  ]);
  VocabularyEntry noun15 = VocabularyEntry.create(vocab: {
    'expression': '私',
    'reading': 'わちき',
    'sequence': 2864027,
    'popularity': -5010200,
    'meaningTags': 'pn arch fem',
    'termTags': '',
  }, meanings: [
    "I",
    "me"
  ]);
  VocabularyEntry noun16 = VocabularyEntry.create(vocab: {
    'expression': '隣り',
    'reading': 'となり',
    'sequence': 1555830,
    'popularity': -5010200,
    'meaningTags': 'adj-no n',
    'termTags': '⚠️',
  }, meanings: [
    "next (to)",
    "adjoining",
    "adjacent"
  ]);
  VocabularyEntry verb4 = VocabularyEntry.create(vocab: {
    'expression': '隣る',
    'reading': 'となる',
    'sequence': 2163190,
    'popularity': -200,
    'meaningTags': 'v5r vi arch',
    'termTags': '⚠️',
  }, meanings: [
    "to neighbor (neighbour)",
    "to be adjacent to",
    "to be next to",
    "to border"
  ]);
}
