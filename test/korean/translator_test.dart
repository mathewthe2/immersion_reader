import 'package:flutter_test/flutter_test.dart';
import 'package:immersion_reader/data/database/sql_repository.dart';
import 'package:immersion_reader/languages/common/vocabulary.dart';
import 'package:immersion_reader/languages/korean/korean_translator.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../common/vocabulary_entry.dart';
import 'vocab_bank.dart';

// To run tests on Window/Mac:
// flutter test test/korean/translator_test.dart
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
    await db.insert('Dictionary', {
      'id': 1,
      'title': 'Vicon_Kor_to_Eng',
      'enabled': 1,
    });
    return db;
  }

  test('Verb Test', () async {
    var db = await createDictionary();
    VocabularyEntry entry = VocabBank().verb1;

    await db.insert('Vocab', entry.vocab);
    for (Map<String, dynamic> gloss in entry.vocabGlosses) {
      await db.insert('VocabGloss', gloss);
    }
    SettingsStorage settingsStorage = SettingsStorage();
    settingsStorage.database = db;

    var text = '봐요';
    KoreanTranslator translator = KoreanTranslator.create(settingsStorage);
    List<Vocabulary> vocabularyListResult = await translator.findTerm(text);
    expect(vocabularyListResult.length, 1);
    expect(vocabularyListResult.first.expression, entry.expression);
    expect(vocabularyListResult.first.reading, entry.reading);
    await db.close();
  });
}
