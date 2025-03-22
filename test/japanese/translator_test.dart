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

  test('Verb Inflection Test 2', () async {
    var db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
      Batch batch = await SqlRepository.insertTablesForDatabase(
          db, SettingsStorage.databaseName);
      await batch.commit();
    });
    // Setup Dictionary
    await db.insert('Dictionary', {'id': 1, 'title': 'JMDict', 'enabled': 1});
    // Add Vocabulary
    const sampleWord = 'とても';
    const sampleWordId = 1;
    const sampleReading = 'とても';
    const sampleMeanings = ["very", "awfully", "exceedingly"];
    const Map<String, dynamic> sampleVocab = {
      'id': sampleWordId,
      'dictionaryId': 1,
      'expression': sampleWord,
      'reading': sampleReading,
      'sequence': 1008630,
      'popularity': 999800,
      'meaningTags': 'adv uk',
      'termTags': '',
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
    const distractionWord = '取る';
    const distractionId = 2;
    const distractionReading = 'とる';
    const distractionMeanings = [
      "to take",
      "to pick up",
      "to grab",
      "to catch",
      "to hold"
    ];
    const Map<String, dynamic> distractionVocab = {
      'id': distractionId,
      'dictionaryId': 1,
      'expression': distractionWord,
      'reading': distractionReading,
      'sequence': 1326980,
      'popularity': 1999800,
      'meaningTags': 'v5r vt',
      'termTags': '',
    };
    List<Map<String, dynamic>> distractionVocabGlosses = distractionMeanings
        .map((meaning) => {
              'vocabId': sampleWordId,
              'glossary': meaning,
              'dictionaryId': 1,
            })
        .toList();
    await db.insert('Vocab', distractionVocab);
    for (Map<String, dynamic> gloss in distractionVocabGlosses) {
      await db.insert('VocabGloss', gloss);
    }
    SettingsStorage settingsStorage = SettingsStorage();
    settingsStorage.database = db;

    var text = 'とても気になっていたはずなのに';
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

  // ["反芻","はんすう","n vs vt","",-201,["turning over in one's mind","thinking over (something)","pondering","musing","rumination (about a subject)"],1481160,""],
  // ["反すう","はんすう","n vs vt","",-10200,["rumination","regurgitation","chewing the cud"],1481160,""],
  //["反すう","はんすう","n vs vt","",-10201,["turning over in one's mind","thinking over (something)","pondering","musing","rumination (about a subject)"],1481160,""]
  test('Repeated Glossary Test', () async {
    var db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
      Batch batch = await SqlRepository.insertTablesForDatabase(
          db, SettingsStorage.databaseName);
      await batch.commit();
    });
    // Setup Dictionary
    await db.insert('Dictionary', {'id': 1, 'title': 'JMDict', 'enabled': 1});
    // Add Vocabulary
    const Map<String, dynamic> vocab1 = {
      'id': 1,
      'dictionaryId': 1,
      'expression': '反芻',
      'reading': 'はんすう',
      'sequence': 1481160,
      'popularity': -200,
      'meaningTags': 'n vs vt',
      'termTags': '',
    };

    // Meanings
    const meanings1 = ['rumination', 'regurgitation', 'chewing the cud'];

    List<Map<String, dynamic>> vocabGlosses1 = meanings1
        .map((meaning) => {
              'vocabId': vocab1["id"],
              'glossary': meaning,
              'dictionaryId': 1,
            })
        .toList();
    await db.insert('Vocab', vocab1);
    for (Map<String, dynamic> gloss in vocabGlosses1) {
      await db.insert('VocabGloss', gloss);
    }

    const Map<String, dynamic> vocab2 = {
      'id': 2,
      'dictionaryId': 1,
      'expression': '反芻',
      'reading': 'はんすう',
      'sequence': 1481160,
      'popularity': -201,
      'meaningTags': 'n vs vt',
      'termTags': '',
    };

    // Meanings
    const meanings2 = [
      'turning over in one\'s mind',
      'thinking over (something)',
      'pondering',
      'musing',
      'rumination (about a subject)'
    ];

    List<Map<String, dynamic>> vocabGlosses2 = meanings2
        .map((meaning) => {
              'vocabId': vocab2["id"],
              'glossary': meaning,
              'dictionaryId': 1,
            })
        .toList();
    await db.insert('Vocab', vocab2);
    for (Map<String, dynamic> gloss in vocabGlosses2) {
      await db.insert('VocabGloss', gloss);
    }

    const Map<String, dynamic> vocab3 = {
      'id': 3,
      'dictionaryId': 1,
      'expression': '反すう',
      'reading': 'はんすう',
      'sequence': 1481160,
      'popularity': -10200,
      'meaningTags': 'n vs vt',
      'termTags': '',
    };

    // Meanings
    const meanings3 = ['rumination', 'regurgitation', 'chewing the cud'];

    List<Map<String, dynamic>> vocabGlosses3 = meanings3
        .map((meaning) => {
              'vocabId': vocab3["id"],
              'glossary': meaning,
              'dictionaryId': 1,
            })
        .toList();
    await db.insert('Vocab', vocab3);
    for (Map<String, dynamic> gloss in vocabGlosses3) {
      await db.insert('VocabGloss', gloss);
    }

    const Map<String, dynamic> vocab4 = {
      'id': 4,
      'dictionaryId': 1,
      'expression': '反すう',
      'reading': 'はんすう',
      'sequence': 1481160,
      'popularity': -10201,
      'meaningTags': 'n vs vt',
      'termTags': '',
    };

    // Meanings
    const meanings4 = [
      'turning over in one\'s mind',
      'thinking over (something)',
      'pondering',
      'musing',
      'rumination (about a subject)'
    ];

    List<Map<String, dynamic>> vocabGlosses4 = meanings4
        .map((meaning) => {
              'vocabId': vocab4["id"],
              'glossary': meaning,
              'dictionaryId': 1,
            })
        .toList();
    await db.insert('Vocab', vocab4);
    for (Map<String, dynamic> gloss in vocabGlosses4) {
      await db.insert('VocabGloss', gloss);
    }

    SettingsStorage settingsStorage = SettingsStorage();
    settingsStorage.database = db;

    var text = '反芻';
    Translator translator = Translator.create(settingsStorage);
    List<Vocabulary> vocabularyListResult = await translator.findTerm(text);
    expect(vocabularyListResult.first.entries.length,
        2); // 2 repeated entries are skipped
    await db.close();
  });
}
