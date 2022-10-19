import 'package:immersion_reader/data/settings/appearance_setting.dart';
import 'package:immersion_reader/data/settings/settings_data.dart';
import 'package:immersion_reader/dictionary/dictionary_meta_entry.dart';
import 'package:immersion_reader/dictionary/user_dictionary.dart';
import 'package:immersion_reader/dictionary/pitch_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:immersion_reader/data/settings/dictionary_setting.dart';
import 'package:immersion_reader/dictionary/dictionary_entry.dart';

class SettingsStorage {
  Database? database;
  List<DictionarySetting>? dictionarySettingCache;

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
    // await File(path).exists();
    // if (!File(path).existsSync()) {
    //   // Copy from asset
    //   ByteData data =
    //       await rootBundle.load(p.join("assets", "japanese", "data.db"));
    //   List<int> bytes =
    //       data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    //   await File(path).writeAsBytes(bytes, flush: true);
    // }

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
    if (dictionarySettingCache != null) {
      return dictionarySettingCache!;
    }
    List<Map<String, Object?>> rows = await database!
        .rawQuery('SELECT * FROM Dictionary'); // to do: add limit

    List<DictionarySetting> dictionarySettingList =
        rows.map((row) => DictionarySetting.fromMap(row)).toList();
    dictionarySettingCache = dictionarySettingList;
    return dictionarySettingList;
  }

  Future<String> getDictionaryNameFromId(int dictionaryId) async {
    List<DictionarySetting> dictionarySettings = await getDictionarySettings();
    return dictionarySettings
        .firstWhere((dictionarySetting) => dictionarySetting.id == dictionaryId)
        .title;
  }

  Future<SettingsData> getConfigSettings() async {
    List<Map<String, Object?>> rows =
        await database!.rawQuery('SELECT * FROM Config');
    Map<String, String> appearanceConfigMap = {};
    for (Map<String, Object?> row in rows) {
      if (row["category"] as String == "appearance") {
        appearanceConfigMap[row["title"] as String] =
            row["customValue"] as String;
      }
      // configMap[row["title"] as String] = row["customValue"] as String;
    }
    AppearanceSetting appearanceSetting =
        AppearanceSetting.fromMap(appearanceConfigMap);
    return SettingsData(appearanceSetting: appearanceSetting);
  }

  Future<int> changeConfigSettings(
      String settingKey, String settingValue) async {
    int count = await database!.rawUpdate(
        'UPDATE Config SET customvalue = ? WHERE title = ?',
        [settingValue, settingKey]);
    return count;
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
      if (dictionarySettingCache != null) {
        dictionarySettingCache!
            .firstWhere(
                (settingCache) => settingCache.id == dictionarySetting.id)
            .enabled = !dictionarySetting.enabled;
      }
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
    batch.rawDelete(
        'DELETE FROM VocabFreq WHERE dictionaryId = ?', [dictionaryId]);
    batch.rawDelete(
        'DELETE FROM VocabPitch WHERE dictionaryId = ?', [dictionaryId]);
    await batch.commit();
    if (dictionarySettingCache != null) {
      dictionarySettingCache!.removeWhere(
          (dictionarySetting) => dictionarySetting.id == dictionaryId);
    }
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
    for (DictionaryMetaEntry metaEntry
        in userDictionary.dictionaryMetaEntries) {
      if (metaEntry.frequency != null) {
        batch.rawInsert(
            'INSERT INTO VocabFreq(expression, reading, frequency, dictionaryId) VALUES(?, ?, ?, ?)',
            [
              metaEntry.term,
              metaEntry.reading ?? '',
              metaEntry.frequency,
              dictionaryId
            ]);
      }
      if (metaEntry.pitches != null) {
        for (PitchData pitch in metaEntry.pitches!) {
          batch.rawInsert(
              'INSERT INTO VocabPitch(expression, reading, pitch, dictionaryId) VALUES(?, ?, ?, ?)',
              [
                metaEntry.term,
                pitch.reading,
                pitch.downstep.toString(),
                dictionaryId
              ]);
        }
      }
    }
    await batch.commit();
    if (dictionarySettingCache != null) {
      dictionarySettingCache!.add(DictionarySetting(
          id: dictionaryId,
          title: userDictionary.dictionaryName,
          enabled: true));
    }
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
  batch.rawQuery(
      "CREATE TABLE VocabFreq(expression TEXT, reading TEXT, frequency TEXT, dictionaryId INTEGER)");
  batch.rawQuery(
      "CREATE TABLE VocabPitch(expression TEXT, reading TEXT, pitch TEXT, dictionaryId INTEGER)");

  // Create Config Table
  batch.rawQuery(
      "CREATE TABLE Config(title TEXT, customValue TEXT, category TEXT)");

  // Indexes
  batch
      .rawQuery("CREATE INDEX index_VocabGloss_vocabId ON VocabGloss(vocabId)");
  batch.rawQuery("CREATE INDEX index_Vocab_expression ON Vocab(expression)");
  batch.rawQuery("CREATE INDEX index_Vocab_reading ON Vocab(reading)");
  batch.rawQuery(
      "CREATE INDEX index_VocabFreq_expression ON VocabFreq(expression)");
  batch.rawQuery("CREATE INDEX index_VocabFreq_reading ON VocabFreq(reading)");
  batch.rawQuery(
      "CREATE INDEX index_VocabPitch_expression ON VocabPitch(expression ASC)");
  batch.rawQuery(
      "CREATE INDEX index_VocabPitch_reading ON VocabPitch(reading ASC)");

  batch = await insertDefaultSettings(batch);
  await batch.commit();
}

Future<Batch> insertDefaultSettings(Batch batch) async {
  ByteData bytes =
      await rootBundle.load(p.join("assets", "settings", "defaultConfig.json"));
  String jsonStr = const Utf8Decoder().convert(bytes.buffer.asUint8List());
  Map<String, Object?> json = jsonDecode(jsonStr);
  for (MapEntry<String, Object?> categoryEntry in json.entries) {
    Map<String, Object?> map = categoryEntry.value as Map<String, Object?>;
    for (MapEntry<String, Object?> entry in map.entries) {
      batch.rawInsert(
          "INSERT INTO Config(title, customValue, category) VALUES(?, ?, ?)",
          [entry.key, entry.value as String, categoryEntry.key]);
    }
  }
  return batch;
}
