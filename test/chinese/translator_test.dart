import 'package:flutter_test/flutter_test.dart';
import 'package:immersion_reader/data/database/sql_repository.dart';
import 'package:immersion_reader/languages/chinese/chinese_translator.dart';
import 'package:immersion_reader/languages/common/vocabulary.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../common/vocabulary_entry.dart';
import 'vocab_bank.dart';

// To run tests on Window/Mac:
// flutter test test/chinese/translator_test.dart
Future main() async {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  Future<Database> createDictionary() async {
    var db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        Batch batch = await SqlRepository.insertTablesForDatabase(
          db,
          SettingsStorage.databaseName,
        );
        await batch.commit();
      },
    );
    await db.insert('Dictionary', {'id': 1, 'title': '中日大辞典', 'enabled': 1});
    return db;
  }

  test('Compound Noun Test', () async {
    var db = await createDictionary();
    VocabularyEntry entry = VocabBank().noun1;

    await db.insert('Vocab', entry.vocab);
    for (Map<String, dynamic> gloss in entry.vocabGlosses) {
      await db.insert('VocabGloss', gloss);
    }

    List<VocabularyEntry> lowPriorityEntries = [
      VocabBank().noun2, // 电力站 (not matched)
      VocabBank().noun3, // 电力
      VocabBank().noun4, // 电
    ];

    for (VocabularyEntry entry in lowPriorityEntries) {
      await db.insert('Vocab', entry.vocab);
      for (Map<String, dynamic> gloss in entry.vocabGlosses) {
        await db.insert('VocabGloss', gloss);
      }
    }

    SettingsStorage settingsStorage = SettingsStorage();
    settingsStorage.database = db;

    var text = '电力戽水站';
    ChineseTranslator translator = ChineseTranslator.create(settingsStorage);
    List<Vocabulary> vocabularyListResult = await translator.findTerm(text);
    expect(vocabularyListResult.length, 3);
    expect(vocabularyListResult.first.expression, entry.expression);
    expect(vocabularyListResult.first.reading, entry.reading);
    await db.close();
  });
}
