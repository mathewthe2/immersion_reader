// import 'package:flutter/foundation.dart';
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

  // static int frequencyLimit = 150;

  Future<List<List<FrequencyTag>>> getFrequencyBatch(
      List<SearchTerm> searchTerms) async {
    Batch batch = settingsStorage!.database!.batch();
    if (settingsStorage == null) {
      return [];
    }
    List<List<FrequencyTag>> totalTags = [];
    for (SearchTerm searchTerm in searchTerms) {
      if (searchTerm.reading.isNotEmpty) {
        batch.rawQuery("""
            SELECT VocabFreq.*, Dictionary.title AS dictionaryName FROM VocabFreq
            INNER JOIN Dictionary ON VocabFreq.dictionaryId = Dictionary.id
            WHERE Dictionary.enabled = 1 AND
            ((expression = ? AND (reading IS NULL OR reading = ''))
            OR (expression = ? AND reading = ?))""",
            [searchTerm.text, searchTerm.text, searchTerm.reading]);
      } else {
        batch.rawQuery("""
            SELECT VocabFreq.*, Dictionary.title AS dictionaryName FROM VocabFreq
            INNER JOIN Dictionary ON VocabFreq.dictionaryId = Dictionary.id 
            WHERE Dictionary.enabled = 1 AND
            expression = ?
            """, [searchTerm.text]);
      }
    }
    List<Object?> results = await batch.commit();
    for (int i = 0; i < results.length; i++) {
      List<Map<String, Object?>> rows =
          results[i] as List<Map<String, Object?>>;
      List<FrequencyTag> frequencyTags = [];
      for (Map<String, Object?> row in rows) {
        FrequencyTag frequencyTag = FrequencyTag.fromMap(row);
        frequencyTags.add(frequencyTag);
      }
      totalTags.add(frequencyTags);
    }
    return totalTags;
  }

  // Future<List<FrequencyTag>> getFrequency(String text,
  //     {String reading = ''}) async {
  //   if (settingsStorage == null) {
  //     return [];
  //   }
  //   List<Map<String, Object?>> rows = [];
  //   try {
  //     if (reading.isNotEmpty) {
  //       rows = await settingsStorage!.database!.rawQuery("""
  //           SELECT * FROM VocabFreq WHERE
  //           (expression = ? AND (reading IS NULL OR reading = ''))
  //           OR (expression = ? AND reading = ?)""", [text, text, reading]);
  //     } else {
  //       rows = await settingsStorage!.database!
  //           .rawQuery('SELECT * FROM VocabFreq WHERE expression = ?', [
  //         text,
  //       ]);
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  //   if (rows.isNotEmpty) {
  //     List<FrequencyTag> result =
  //         rows.map((row) => FrequencyTag.fromMap(row)).toList();
  //     return result;
  //   }
  //   return [];
  // }
}
