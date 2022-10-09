import 'package:immersion_reader/dictionary/user_dictionary.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:immersion_reader/data/settings/dictionary_setting.dart';
import 'package:immersion_reader/dictionary/dictionary_entry.dart';

class SettingsStorage {
  Database? database;

  SettingsStorage._create() {
    // print("_create() (private constructor)");
  }

  static Future<SettingsStorage> create() async {
    SettingsStorage settingsStorage = SettingsStorage._create();
    String databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, "data.db");
    print('path; $path');
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}

    // delete existing if any
    // await deleteDatabase(path);

    // copy from resources if data doesn't exist
    await File(path).exists();
    if (!File(path).existsSync()) {
      // Copy from asset
      ByteData data =
          await rootBundle.load(p.join("assets", "japanese", "data.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    // opening the database
    settingsStorage.database = await openDatabase(
      path,
      version: 1,
      onCreate: onCreateStorageData,
    );

    return settingsStorage;
  }

  Future<List<DictionarySetting>> getDictionarySettings() async {
    if (database == null) {
      return [];
    }
    List<Map<String, Object?>> rows = await database!
        .rawQuery('SELECT * FROM Dictionary'); // to do: add limit

    List<DictionarySetting> dictionarySettingList =
        rows.map((row) => DictionarySetting.fromMap(row)).toList();
    return dictionarySettingList;
  }

  Future<List<int>> getDisabledDictionaryIds() async {
    List<DictionarySetting> dictionarySettings = await getDictionarySettings();
    return List.from(dictionarySettings
        .where(
            (DictionarySetting dictionarySetting) => !dictionarySetting.enabled)
        .map((DictionarySetting dictionarySetting) => dictionarySetting.id));
  }

  Future<int> toggleDictionaryEnabled(
      DictionarySetting dictionarySetting) async {
    if (database != null) {
      int count = await database!.rawUpdate(
          'UPDATE Dictionary SET enabled = ? WHERE id = ?',
          [dictionarySetting.enabled ? 0 : 1, dictionarySetting.id]);
      return count;
    }
    return 0;
  }

  Future<int> getLastRecordId() async {
    List<Map> mapData = await database!
        .rawQuery('SELECT id FROM Vocab ORDER BY id DESC LIMIT 1;');
    if (mapData.isEmpty) {
      return 0;
    } else {
      int lastRecordId = mapData.first['id'];
      return lastRecordId;
    }
  }

  Future<void> removeDictionary(int dictionaryId) async {
    Batch batch = database!.batch();
    batch.rawDelete('DELETE FROM Dictionary WHERE id = ?', [dictionaryId]);
    batch.rawDelete('DELETE FROM Vocab WHERE dictionaryId = ?', [dictionaryId]);
    batch.rawDelete(
        'DELETE FROM VocabGloss WHERE dictionaryId = ?', [dictionaryId]);
    await batch.commit();
  }

  Future<void> addDictionary(UserDictionary userDictionary) async {
    int dictionaryId = await database!
        .rawInsert('INSERT INTO Dictionary(title, enabled) VALUES(?, ?)', [
      userDictionary.dictionaryName,
      1, // enabled
    ]);
    int lastRecordId = await getLastRecordId();
    Batch batch = database!.batch();
    for (DictionaryEntry entry in userDictionary.dictionaryEntries) {
      lastRecordId += 1;
      batch.rawInsert(
          'INSERT INTO Vocab(id, dictionaryId, expression, reading, meaningTags, termTags, popularity, sequence) VALUES(?, ?, ?, ?, ?, ?, ?, ?)',
          [
            lastRecordId,
            dictionaryId,
            entry.term,
            entry.reading,
            entry.meaningTags.join(' '),
            entry.termTags.join(' '),
            entry.popularity,
            entry.sequence
          ]);
      for (String meaning in entry.meanings) {
        batch.rawInsert(
            'INSERT INTO VocabGloss(glossary, vocabId, dictionaryId) VALUES(?, ?, ?)',
            [meaning, lastRecordId, dictionaryId]);
      }
    }
    await batch.commit();
  }
}

void onCreateStorageData(Database db, int version) async {
  Batch batch = db.batch();
  // Create Dictionary table
  batch.execute('''
            CREATE TABLE Dictionary (
            id INTEGER PRIMARY KEY, title TEXT, enabled INTEGER)
          ''');

  // Create Japanese Dictionary
  batch.rawQuery(
      "CREATE TABLE Kanji(id INTEGER PRIMARY KEY, dictionaryId INTEGER, character TEXT, kunyomi TEXT, onyomi TEXT)");
  batch.rawQuery(
      "CREATE TABLE KanjiGloss(glossary TEXT, kanjiId INTEGER, dictionaryId INTEGER, FOREIGN KEY(kanjiId) REFERENCES Kanji(id))");
  batch.rawQuery(
      "CREATE TABLE Vocab(id INTEGER PRIMARY KEY, dictionaryId INTEGER, expression TEXT, reading TEXT, sequence INTEGER, popularity REAL,  meaningTags TEXT, termTags TEXT)");
  batch.rawQuery(
      "CREATE TABLE VocabGloss(glossary TEXT, vocabId INTEGER, dictionaryId INTEGER, FOREIGN KEY(vocabId) REFERENCES Vocab(id))");
  batch
      .rawQuery("CREATE INDEX index_VocabGloss_vocabId ON VocabGloss(vocabId)");
  batch.rawQuery("CREATE INDEX index_Vocab_expression ON Vocab(expression)");
  batch.rawQuery("CREATE INDEX index_Vocab_reading ON Vocab(reading)");
  await batch.commit();
}
