import 'dart:math';
import 'package:immersion_reader/dictionary/dictionary_entry.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/dictionary/frequency_tag.dart';

enum VocabularyInformationKey {
  expression,
  reading,
  definition,
  sentence,
}

class Vocabulary {
  String? id;
  int folderId = 1; // default folder id
  String? expression;
  String? reading;
  List<String>? tags;
  List<String>? addons;
  // for search
  String? source;
  List<String> rules = [];
  // pitch
  PitchAccentDisplayStyle? pitchAccentDisplayStyle;
  List<String> pitchValues = [];
  // frequency tags
  List<FrequencyTag> frequencyTags = [];
  // for export
  String sentence = '';
  String glossary = ''; // grouped meanings from all entries
  // dictionaryEntries
  List<DictionaryEntry> entries = [];

  Vocabulary(
      {this.id,
      this.expression,
      this.folderId = 1,
      this.reading,
      this.tags,
      this.glossary = '',
      this.addons,
      this.entries = const [],
      this.sentence = ''});

  factory Vocabulary.fromMap(Map<String, Object?> map) => Vocabulary(
      id: map['id'] as String?,
      folderId: map['folderId'] as int,
      expression: map['expression'] as String?,
      reading: map['reading'] as String?,
      glossary: map['glossary'] as String,
      tags: (map['tags'] as String).split(' '),
      sentence: map['sentence'] != null ? map['sentence'] as String : '');

  String getFirstGlossary() {
    return getCompleteGlossary().split('\n')[0];
  }

  List<String> getAllMeanings() {
    List<String> meanings = [];
    for (DictionaryEntry entry in entries) {
      meanings = [...meanings, ...entry.meanings];
    }
    return _removeDuplicates(meanings);
  }

  String getCompleteGlossary() {
    if (entries.isNotEmpty) {
      return _removeDuplicates([
        for (DictionaryEntry entry in entries) entry.meanings.join('; ')
      ]).join('\n');
    } else {
      return glossary;
    }
  }

  List<String> _removeDuplicates(List<String> list) {
    return [
      ...{...list}
    ];
  }

  String getIdentifier() {
    return '${expression}_$reading';
  }

  double getPopularity() {
    return entries
        .map((DictionaryEntry entry) => entry.popularity ?? 0)
        .reduce(max);
  }

  String getValueByInformationKey(VocabularyInformationKey key) {
    switch (key) {
      case VocabularyInformationKey.definition:
        {
          return getCompleteGlossary();
        }
      case VocabularyInformationKey.expression:
        {
          return expression ?? '';
        }
      case VocabularyInformationKey.reading:
        {
          return reading ?? '';
        }
      case VocabularyInformationKey.sentence:
        {
          return sentence;
        }
    }
  }

  void setWithInformationKey(VocabularyInformationKey key, String value) {
    switch (key) {
      case VocabularyInformationKey.definition:
        {
          glossary = value;
          break;
        }
      case VocabularyInformationKey.expression:
        {
          expression = value;
          break;
        }
      case VocabularyInformationKey.reading:
        {
          reading = value;
          break;
        }
      case VocabularyInformationKey.sentence:
        {
          sentence = value;
          break;
        }
    }
  }

  static Map<VocabularyInformationKey, String> vocabularyDatabaseMap = {
    VocabularyInformationKey.expression: 'expression',
    VocabularyInformationKey.reading: 'reading',
    VocabularyInformationKey.sentence: 'sentence',
    VocabularyInformationKey.definition: 'glossary'
  };
}
