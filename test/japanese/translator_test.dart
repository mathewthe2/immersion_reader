import 'package:flutter_test/flutter_test.dart';
import 'package:immersion_reader/data/database/sql_repository.dart';
import 'package:immersion_reader/japanese/translator.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'vocab_bank.dart';

// To run tests on Window/Mac:
// flutter test test/japanese/translator_test.dart
Future main() async {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  Future<Database> createDictionary() async {
    var db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
      Batch batch = await SqlRepository.insertTablesForDatabase(
          db, SettingsStorage.databaseName);
      await batch.commit();
    });
    await db.insert('Dictionary', {'id': 1, 'title': 'JMDict', 'enabled': 1});
    return db;
  }

  test('Basic Verb Test', () async {
    var db = await createDictionary();
    VocabularyEntry entry = VocabBank().noun1;

    await db.insert('Vocab', entry.vocab);
    for (Map<String, dynamic> gloss in entry.vocabGlosses) {
      await db.insert('VocabGloss', gloss);
    }
    SettingsStorage settingsStorage = SettingsStorage();
    settingsStorage.database = db;

    var text = 'あくびをした';
    Translator translator = Translator.create(settingsStorage);
    List<Vocabulary> vocabularyListResult = await translator.findTerm(text);
    expect(vocabularyListResult.length, 1);
    expect(vocabularyListResult.first.expression, entry.expression);
    expect(vocabularyListResult.first.reading, entry.reading);
    await db.close();
  });

  test('Verb Inflection Test', () async {
    var db = await createDictionary();
    // Add Vocabulary
    VocabularyEntry entry = VocabBank().verb1;
    await db.insert('Vocab', entry.vocab);
    for (Map<String, dynamic> gloss in entry.vocabGlosses) {
      await db.insert('VocabGloss', gloss);
    }
    SettingsStorage settingsStorage = SettingsStorage();
    settingsStorage.database = db;

    var text = '呑んだ';
    Translator translator = Translator.create(settingsStorage);
    List<Vocabulary> vocabularyListResult = await translator.findTerm(text);
    expect(vocabularyListResult.length, 1);
    expect(vocabularyListResult.first.expression, entry.expression);
    expect(vocabularyListResult.first.reading, entry.reading);
    await db.close();
  });

  test('Verb Inflection Test 2', () async {
    var db = await createDictionary();
    // Add Vocabulary
    VocabularyEntry entry = VocabBank().adverb1;
    await db.insert('Vocab', entry.vocab);
    List<Future> insertFutures = [];
    for (Map<String, dynamic> gloss in entry.vocabGlosses) {
      insertFutures.add(db.insert('VocabGloss', gloss));
    }
    await Future.wait(insertFutures);
    // Add Distraction
    VocabularyEntry distractionEntry = VocabBank().verb2;
    await db.insert('Vocab', distractionEntry.vocab);
    insertFutures = [];
    for (Map<String, dynamic> gloss in distractionEntry.vocabGlosses) {
      insertFutures.add(db.insert('VocabGloss', gloss));
    }
    await Future.wait(insertFutures);
    SettingsStorage settingsStorage = SettingsStorage();
    settingsStorage.database = db;

    var text = 'とても気になっていたはずなのに';
    Translator translator = Translator.create(settingsStorage);
    List<Vocabulary> vocabularyListResult = await translator.findTerm(text);
    expect(vocabularyListResult.length, 1);
    expect(vocabularyListResult.first.expression, entry.expression);
    expect(vocabularyListResult.first.reading, entry.reading);
    await db.close();
  });

  // ["反芻","はんすう","n vs vt","",-201,["turning over in one's mind","thinking over (something)","pondering","musing","rumination (about a subject)"],1481160,""],
  // ["反すう","はんすう","n vs vt","",-10200,["rumination","regurgitation","chewing the cud"],1481160,""],
  //["反すう","はんすう","n vs vt","",-10201,["turning over in one's mind","thinking over (something)","pondering","musing","rumination (about a subject)"],1481160,""]
  test('Repeated Glossary Test', () async {
    var db = await createDictionary();

    VocabularyEntry entry = VocabBank().noun2;
    await db.insert('Vocab', entry.vocab);
    for (Map<String, dynamic> gloss in entry.vocabGlosses) {
      await db.insert('VocabGloss', gloss);
    }
    VocabularyEntry entry2 = VocabBank().noun3;
    await db.insert('Vocab', entry2.vocab);
    for (Map<String, dynamic> gloss in entry2.vocabGlosses) {
      await db.insert('VocabGloss', gloss);
    }
    VocabularyEntry distractionEntry1 = VocabBank().noun4;
    await db.insert('Vocab', distractionEntry1.vocab);
    for (Map<String, dynamic> gloss in distractionEntry1.vocabGlosses) {
      await db.insert('VocabGloss', gloss);
    }
    VocabularyEntry distractionEntry2 = VocabBank().noun5;
    await db.insert('Vocab', distractionEntry2.vocab);
    for (Map<String, dynamic> gloss in distractionEntry2.vocabGlosses) {
      await db.insert('VocabGloss', gloss);
    }

    SettingsStorage settingsStorage = SettingsStorage();
    settingsStorage.database = db;

    var text = '反芻';
    Translator translator = Translator.create(settingsStorage);
    List<Vocabulary> vocabularyListResult = await translator.findTerm(text);
    expect(vocabularyListResult.first.entries.length, 2);
    await db.close();
  });

  test('Frequency Test', () async {
    var db = await createDictionary();
    VocabularyEntry entry = VocabBank().noun6;

    await db.insert('Vocab', entry.vocab);
    for (Map<String, dynamic> gloss in entry.vocabGlosses) {
      await db.insert('VocabGloss', gloss);
    }
    VocabularyEntry distractionEntry = VocabBank().noun7;

    await db.insert('Vocab', distractionEntry.vocab);
    for (Map<String, dynamic> gloss in distractionEntry.vocabGlosses) {
      await db.insert('VocabGloss', gloss);
    }
    SettingsStorage settingsStorage = SettingsStorage();
    settingsStorage.database = db;

    var text = '彼';
    Translator translator = Translator.create(settingsStorage);
    List<Vocabulary> vocabularyListResult = await translator.findTerm(text);
    expect(vocabularyListResult.length, 2);
    expect(vocabularyListResult.first.expression, entry.expression);
    expect(vocabularyListResult.first.reading, entry.reading);
    await db.close();
  });
}
