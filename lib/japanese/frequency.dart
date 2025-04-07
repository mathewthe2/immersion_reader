import 'package:immersion_reader/dictionary/frequency_tag.dart';
import 'package:immersion_reader/japanese/search_term.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:sqflite/sqflite.dart';

class Frequency {
  Database? pitchAccentsDictionary;
  SettingsStorage? settingsStorage;

  static final Frequency _singleton = Frequency._internal();
  Frequency._internal();

  factory Frequency.create(SettingsStorage settingsStorage) {
    _singleton.settingsStorage = settingsStorage;
    return _singleton;
  }

  static int frequencyLimit = 1000;

  Future<List<List<FrequencyTag>>> getFrequencyBatch(
      List<SearchTerm> searchTerms) async {
    if (settingsStorage == null || searchTerms.isEmpty) {
      return List.filled(searchTerms.length, []);
    }
    final List<String> whereClauses = [];
    final List<Object?> values = [];

    for (SearchTerm term in searchTerms) {
      if (term.reading.isNotEmpty) {
        whereClauses.add("""
        (
          (expression = ? AND (reading IS NULL OR reading = ''))
          OR (expression = ? AND reading = ?)
        )
      """);
        values.addAll([term.text, term.text, term.reading]);
      } else {
        whereClauses.add("(expression = ?)");
        values.add(term.text);
      }
    }
    values.add(frequencyLimit);
    final rows = await settingsStorage!.database!.rawQuery("""
    SELECT VocabFreq.*, Dictionary.title AS dictionaryName
    FROM VocabFreq
    INNER JOIN Dictionary ON VocabFreq.dictionaryId = Dictionary.id
    WHERE Dictionary.enabled = 1 AND (${whereClauses.join(' OR ')})
    LIMIT ?
  """, values);
    Map<String, Set<String>> frequencyTagMap = {};
    // Unlike pitches, frequency tags in database may have no readings
    for (Map<String, Object?> row in rows) {
      final expression = row['expression'] as String;
      final reading = row['reading'] as String?;
      FrequencyTag frequencyTag = FrequencyTag.fromMap(row);
      if (reading != null && reading.isNotEmpty) {
        frequencyTagMap
            .putIfAbsent('$expression-$reading', () => {})
            .add(frequencyTag.toString());
      } else {
        frequencyTagMap
            .putIfAbsent(expression, () => {})
            .add(frequencyTag.toString());
      }
    }

    List<List<FrequencyTag>> frequencyTags = [];

    for (final term in searchTerms) {
      if (frequencyTagMap.containsKey(term.text)) {
        frequencyTags.add(frequencyTagMap[term.text]!
            .map((freq) => FrequencyTag.fromString(freq))
            .toList());
      } else if (frequencyTagMap.containsKey('${term.text}-${term.reading}')) {
        frequencyTags.add(frequencyTagMap['${term.text}-${term.reading}']!
            .map((freq) => FrequencyTag.fromString(freq))
            .toList());
      } else {
        frequencyTags.add([]);
      }
    }
    return frequencyTags;
  }
}
