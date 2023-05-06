import 'package:flutter_test/flutter_test.dart';
import 'package:immersion_reader/data/database/sql_repository.dart';
import 'package:immersion_reader/dictionary/dictionary_entry.dart';
import 'package:immersion_reader/japanese/dictionary.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

// To run tests on Window/Mac:
// flutter test test/japanese/dictionary_test.dart
Future main() async {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  test('Dictionary Test', () async {
    var db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
      Batch batch = await SqlRepository.insertTablesForDatabase(
          db, SettingsStorage.databaseName);
      await batch.commit();
    });
    // Setup Dictionary
    await db.insert('Dictionary', {'id': 1, 'title': 'JMDict', 'enabled': 1});
    // Check Dictionary
    expect(await db.query('Dictionary'), [
      {'id': 1, 'title': 'JMDict', 'enabled': 1}
    ]);
    // Add Vocabulary
    const sampleWord = '男性';
    const sampleWordId = 103051;
    const sampleReading = 'だんせい';
    const sampleMeanings = ['man', 'male'];
    const Map<String, dynamic> sampleVocab = {
      'id': sampleWordId,
      'dictionaryId': 1,
      'expression': sampleWord,
      'reading': sampleReading,
      'sequence': 1420160,
      'popularity': 713.0,
      'meaningTags': 'n adj-no',
      'termTags': 'P ichi news',
    };
    List<Map<String, dynamic>> sampleVocabGlosses = sampleMeanings
        .map((meaning) => {
              'vocabId': sampleWordId,
              'glossary': meaning,
              'dictionaryId': 1,
            })
        .toList();
    await db.insert('Vocab', sampleVocab);
    for (Map<String, dynamic> gloss in sampleVocabGlosses) {
      await db.insert('VocabGloss', gloss);
    }
    // Check Vocabulary
    expect(await db.query('Vocab'), [sampleVocab]);
    expect(await db.query('VocabGloss'), sampleVocabGlosses);

    SettingsStorage settingsStorage = SettingsStorage();
    settingsStorage.database = db;

    Dictionary dictionary = Dictionary.create(settingsStorage);

    List<DictionaryEntry> singleTermResult =
        await dictionary.findTermsBulk([sampleWord]);
    expect(singleTermResult.first.reading, sampleReading);

    var vocabularyBatchResult =
        await dictionary.getVocabularyBatch(singleTermResult);
    expect(vocabularyBatchResult.first.getAllMeanings(), sampleMeanings);
    await db.close();
  });
}
