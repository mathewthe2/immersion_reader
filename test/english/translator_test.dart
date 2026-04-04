import 'package:flutter_test/flutter_test.dart';
import 'package:immersion_reader/data/database/sql_repository.dart';
import 'package:immersion_reader/languages/common/vocabulary.dart';
import 'package:immersion_reader/languages/english/english_translator.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'vocab_bank.dart';

// To run tests on Window/Mac:
// flutter test test/english/translator_test.dart
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
      'title': 'vicon_eng_to_jp',
      'enabled': 1,
    });
    return db;
  }

  test('Basic Verb Test', () async {
    var db = await createDictionary();
    VocabularyEntry entry = VocabBank().verb1;

    await db.insert('Vocab', entry.vocab);
    for (Map<String, dynamic> gloss in entry.vocabGlosses) {
      await db.insert('VocabGloss', gloss);
    }
    SettingsStorage settingsStorage = SettingsStorage();
    settingsStorage.database = db;

    var text = 'ran';
    EnglishTranslator translator = EnglishTranslator.create(
      settingsStorage,
      wordForms: VocabBank().wordForms,
    );
    List<Vocabulary> vocabularyListResult = await translator.findTerm(text);
    expect(vocabularyListResult.length, 1);
    expect(vocabularyListResult.first.expression, entry.expression);
    expect(vocabularyListResult.first.reading, entry.reading);
    await db.close();
  });

  test('Phrasal Verb Test', () async {
    var db = await createDictionary();
    VocabularyEntry entry = VocabBank().verb2;

    await db.insert('Vocab', entry.vocab);
    for (Map<String, dynamic> gloss in entry.vocabGlosses) {
      await db.insert('VocabGloss', gloss);
    }

    List<VocabularyEntry> lowPriorityEntries = [
      VocabBank().verb3, // carry
      VocabBank().adv1, // over
    ];

    for (VocabularyEntry entry in lowPriorityEntries) {
      await db.insert('Vocab', entry.vocab);
      for (Map<String, dynamic> gloss in entry.vocabGlosses) {
        await db.insert('VocabGloss', gloss);
      }
    }

    SettingsStorage settingsStorage = SettingsStorage();
    settingsStorage.database = db;

    var text = 'carried over';
    EnglishTranslator translator = EnglishTranslator.create(
      settingsStorage,
      wordForms: VocabBank().wordForms,
    );
    List<Vocabulary> vocabularyListResult = await translator.findTerm(text);
    expect(vocabularyListResult.length, 3);
    expect(vocabularyListResult.first.expression, entry.expression);
    expect(vocabularyListResult.first.reading, entry.reading);
    await db.close();
  });
  test('Noun Phrase Test', () async {
    var db = await createDictionary();
    VocabularyEntry entry = VocabBank().noun1;

    await db.insert('Vocab', entry.vocab);
    for (Map<String, dynamic> gloss in entry.vocabGlosses) {
      await db.insert('VocabGloss', gloss);
    }

    List<VocabularyEntry> lowPriorityEntries = [
      VocabBank().noun2, // football
      VocabBank().noun3, // team
    ];

    for (VocabularyEntry entry in lowPriorityEntries) {
      await db.insert('Vocab', entry.vocab);
      for (Map<String, dynamic> gloss in entry.vocabGlosses) {
        await db.insert('VocabGloss', gloss);
      }
    }

    SettingsStorage settingsStorage = SettingsStorage();
    settingsStorage.database = db;

    var text = 'football teams';
    EnglishTranslator translator = EnglishTranslator.create(
      settingsStorage,
      wordForms: VocabBank().wordForms,
    );
    List<Vocabulary> vocabularyListResult = await translator.findTerm(text);
    expect(vocabularyListResult.length, 3);
    expect(vocabularyListResult.first.expression, entry.expression);
    expect(vocabularyListResult.first.reading, entry.reading);
    await db.close();
  });
}
