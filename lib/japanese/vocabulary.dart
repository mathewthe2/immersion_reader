import 'dart:math';
import 'package:immersion_reader/dictionary/dictionary_entry.dart';

class Vocabulary {
  String? id;
  String? expression;
  String? reading;
  List<String>? tags;
  List<String>? addons;
  // for search
  String? source;
  List<String> rules = [];
  // pitch
  List<String>? pitchSvg = [];
  // for export
  String sentence = '';
  String glossary = ''; // grouped meanings from all entries
  // dictionaryEntries
  List<DictionaryEntry> entries = [];

  Vocabulary(
      {this.id,
      this.expression,
      this.reading,
      this.tags,
      this.glossary = '',
      this.addons,
      this.entries = const [],
      this.sentence = ''});

  factory Vocabulary.fromMap(Map<String, Object?> map) => Vocabulary(
      id: map['id'] as String?,
      expression: map['expression'] as String?,
      reading: map['reading'] as String?,
      glossary: map['glossary'] as String,
      tags: (map['tags'] as String).split(' '),
      sentence: map['sentence'] != null ? map['sentence'] as String : '');

  String getFirstGlossary() {
    return getCompleteGlossary().split('\n')[0];
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
}
