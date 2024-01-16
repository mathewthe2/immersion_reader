import 'package:flutter_test/flutter_test.dart';
import 'package:immersion_reader/data/database/sql_repository.dart';
import 'package:immersion_reader/japanese/translator.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// To run tests on Window/Mac:
// flutter test test/japanese/translator_test.dart
Future main() async {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  test('Verb Inflection Test', () async {
    var db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
      Batch batch = await SqlRepository.insertTablesForDatabase(
          db, SettingsStorage.databaseName);
      await batch.commit();
    });
    // Setup Dictionary
    await db.insert('Dictionary', {'id': 1, 'title': 'JMDict', 'enabled': 1});
    // Add Vocabulary
    const sampleWord = '呑む';
    const sampleWordId = 39598;
    const sampleReading = 'のむ';
    const sampleMeanings = [
      'to drink',
      'to gulp',
      'to swallow',
      'to take (medicine)'
    ];
    const Map<String, dynamic> sampleVocab = {
      'id': sampleWordId,
      'dictionaryId': 1,
      'expression': sampleWord,
      'reading': sampleReading,
      'sequence': 1169870,
      'popularity': 741.0,
      'meaningTags': 'v5m vt',
      'termTags': 'news P spec',
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
    SettingsStorage settingsStorage = SettingsStorage();
    settingsStorage.database = db;

    // var text = '挿さっている';
    var text = '呑んだ';
    Translator translator = Translator.create(settingsStorage);
    List<Vocabulary> vocabularyListResult = await translator.findTerm(text);
    expect(vocabularyListResult.length, 1);
    expect(vocabularyListResult.first.expression, sampleWord);
    expect(vocabularyListResult.first.reading, sampleReading);
    await db.close();
  });

  test('Frequency Test', () async {
    var db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
      Batch batch = await SqlRepository.insertTablesForDatabase(
          db, SettingsStorage.databaseName);
      await batch.commit();
    });
    // Setup Dictionary
    await db.insert('Dictionary', {'id': 1, 'title': 'JMDict', 'enabled': 1});
    // Add Vocabulary
    const sampleWord = '欠伸';
    const sampleWordId = 143764;
    const sampleReading = 'あくび';
    const sampleMeanings = [
      'yawn',
      'yawning',
    ];
    const Map<String, dynamic> sampleVocab = {
      'id': sampleWordId,
      'dictionaryId': 1,
      'expression': sampleWord,
      'reading': sampleReading,
      'sequence': 1254010,
      'popularity': 609.0,
      'meaningTags': 'n uk',
      'termTags': 'P ichi',
    };
    // Add distractions
    // 開く, 空く, 明く, 灰汁, 飽く, 合い, 厭く

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
    SettingsStorage settingsStorage = SettingsStorage();
    settingsStorage.database = db;

    // var text = '挿さっている';
    var text = 'あくびをした';
    Translator translator = Translator.create(settingsStorage);
    List<Vocabulary> vocabularyListResult = await translator.findTerm(text);
    expect(vocabularyListResult.length, 1);
    expect(vocabularyListResult.first.expression, sampleWord);
    expect(vocabularyListResult.first.reading, sampleReading);
    await db.close();
  });
}
