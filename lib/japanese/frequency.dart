import 'package:flutter/foundation.dart';
import 'package:immersion_reader/dictionary/frequency_tag.dart';
import 'package:immersion_reader/japanese/search_term.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:sqflite/sqflite.dart';

class Frequency {
  Database? pitchAccentsDictionary;
  SettingsStorage? settingsStorage;

  Frequency._create() {
    // print("_create() (private constructor)");
  }

  static int frequencyLimit = 150;

  static Frequency create(SettingsStorage settingsStorage) {
    Frequency frequency = Frequency._create();
    frequency.settingsStorage = settingsStorage;
    return frequency;
  }

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
            SELECT * FROM VocabFreq WHERE
            (expression = ? AND (reading IS NULL OR reading = ''))
            OR (expression = ? AND reading = ?)""",
            [searchTerm.text, searchTerm.text, searchTerm.reading]);
      } else {
        batch.rawQuery(
            'SELECT * FROM VocabFreq WHERE expression = ?', [searchTerm.text]);
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
        // return result;
      }
      totalTags.add(frequencyTags);
    }
    return totalTags;
  }

  Future<List<FrequencyTag>> getFrequency(String text,
      {String reading = ''}) async {
    if (settingsStorage == null) {
      return [];
    }
    List<Map<String, Object?>> rows = [];
    try {
      if (reading.isNotEmpty) {
        rows = await settingsStorage!.database!.rawQuery("""
            SELECT * FROM VocabFreq WHERE
            (expression = ? AND (reading IS NULL OR reading = ''))
            OR (expression = ? AND reading = ?)""", [text, text, reading]);
      } else {
        rows = await settingsStorage!.database!
            .rawQuery('SELECT * FROM VocabFreq WHERE expression = ?', [
          text,
        ]);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    if (rows.isNotEmpty) {
      List<FrequencyTag> result =
          rows.map((row) => FrequencyTag.fromMap(row)).toList();
      return result;
    }
    return [];
  }
}
