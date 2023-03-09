import 'package:immersion_reader/data/database/sql_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:immersion_reader/japanese/vocabulary.dart';

class VocabularyListStorage {
  Database? database;
  List<Vocabulary> vocabularyListCache = [];

  static const databaseName = 'vocabulary_list.db';
  static const String defaultFolderName = 'Favorties';
  static const int defaultFolderId = 1;

  VocabularyListStorage._create() {
    // print("_create() (private constructor)");
  }

  static Future<VocabularyListStorage> create() async {
    VocabularyListStorage vocabularyListStorage =
        VocabularyListStorage._create();
    String databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, databaseName);
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}

    // delete existing if any
    // await deleteDatabase(path);

    // opening the database
    vocabularyListStorage.database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table\
      Batch batch = await SqlRepository.insertTablesForDatabase(db, VocabularyListStorage.databaseName);
      batch.rawInsert("INSERT INTO Folder(id, name) VALUES(?, ?)",
          [defaultFolderId, defaultFolderName]);
      await batch.commit();
    });

    vocabularyListStorage.vocabularyListCache = await vocabularyListStorage.getVocabularyItems();
    return vocabularyListStorage;
  }

  Future<List<String>> getExistsVocabularyList(
      List<Vocabulary> vocabularyList) async {
    if (vocabularyList.isEmpty) {
      return [];
    }
    List<String> vocabularyIdentifierList = vocabularyList
        .map((Vocabulary vocabulary) => vocabulary.uniqueId)
        .toList();
    List<Map> list = await database!.rawQuery('''
        with cte(vocab_id) as
        (values (?)${',(?)' * (vocabularyIdentifierList.length - 1)})
      select vocab_id from cte
      where vocab_id in (SELECT id FROM Vocabulary)
        ''', vocabularyIdentifierList);
    if (list.isNotEmpty) {
      return list.map((e) => e['vocab_id'] as String).toList();
    }
    return [];
  }

  Future<int> addVocabularyItem(Vocabulary vocabulary) async {
    int id = await database!.rawInsert(
        'INSERT INTO Vocabulary(id, folderId, expression, reading, glossary, tags, sentence) VALUES(?, ?, ?, ?, ?, ?, ?)',
        [
          vocabulary.uniqueId,
          vocabulary.folderId,
          vocabulary.expression,
          vocabulary.reading,
          vocabulary.getCompleteGlossary(),
          (vocabulary.tags ?? []).join(' '),
          vocabulary.sentence
        ]);
    vocabulary.id = vocabulary.uniqueId;
    vocabularyListCache = [...vocabularyListCache, vocabulary];
    return id;
  }

  Future<List<Vocabulary>> getVocabularyItems() async {
    if (database == null) {
      return [];
    }
    List<Map<String, Object?>> rows = await database!
        .rawQuery('SELECT * FROM Vocabulary'); // to do: add limit
    List<Vocabulary> vocabularyList =
        rows.map((row) => Vocabulary.fromMap(row)).toList();
    vocabularyListCache = vocabularyList;
    return vocabularyList;
  }

  Future<Vocabulary> updateVocabularyItem(
      Vocabulary vocabulary, VocabularyInformationKey key, String value) async {
    if (database == null) {
      return vocabulary;
    }
    String vocabularyId = vocabulary.uniqueId;
    int count = await database!.rawUpdate(
        'UPDATE Vocabulary SET ${Vocabulary.vocabularyDatabaseMap[key]} = ? WHERE id = ?',
        [value, vocabularyId]);
    vocabulary.setWithInformationKey(key, value);
    if (count > 0 &&
        [VocabularyInformationKey.expression, VocabularyInformationKey.reading]
            .contains(key)) {
      String newId = vocabulary.uniqueId;
      await database!.rawUpdate(
          'UPDATE Vocabulary SET id = ? WHERE id = ?', [newId, vocabularyId]);
    }
    vocabulary.entries = []; // remove dictionary entries and only keep glossary; temporary patch for getCompleteGlossary() as glossary updates not showing
    int index = vocabularyListCache.indexOf(vocabulary);
    if (index >= 0 && index < vocabularyListCache.length) {
      vocabularyListCache[index] = vocabulary;
    }
    return vocabulary;
  }

  Future<int> deleteVocabularyItem(String vocabularyId) async {
    if (database == null) {
      return 0;
    }
    int count = await database!
        .rawDelete('DELETE FROM Vocabulary WHERE id = ?', [vocabularyId]);
    vocabularyListCache = List.from(vocabularyListCache)..removeWhere((vocabulary) => vocabulary.uniqueId == vocabularyId);
    return count;
  }

  Future<int> deleteAllVocabularyItems() async {
    if (database == null) {
      return 0;
    }
    int count = await database!.rawDelete('DELETE FROM Vocabulary');
    vocabularyListCache = [];
    return count;
  }
}
