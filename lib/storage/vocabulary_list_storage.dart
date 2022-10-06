import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'dart:convert';
import 'package:immersion_reader/japanese/vocabulary.dart';

class VocabularyListStorage {
  Database? database;

  VocabularyListStorage._create() {
    // print("_create() (private constructor)");
  }

  static Future<VocabularyListStorage> create() async {
    VocabularyListStorage vocabularyListStorage =
        VocabularyListStorage._create();
    String databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, "vocabulary_list.db");
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}

    // delete existing if any
    // await deleteDatabase(path);

    // opening the database
    // Database db = await openDatabase(path);
    vocabularyListStorage.database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute('''
            CREATE TABLE Vocabulary (
            id INTEGER PRIMARY KEY, vocabulary_id INTEGER, expression TEXT, reading TEXT, 
            tags TEXT, glossary TEXT, pitch TEXT, pitch_svg TEXT, sentence TEXT)
          ''');
    });

    return vocabularyListStorage;
  }

  // Future<void> addSampleItems() async {
  //   if (database != null) {
  //     await database!.rawInsert(
  //         'INSERT INTO Vocabulary(expression, reading, tags) VALUES(?, ?, ?)', [
  //       '走る',
  //       'はしる',
  //       ['yomi', 'anki'].join(' ')
  //     ]);
  //     await database!.rawInsert(
  //         'INSERT INTO Vocabulary(expression, reading, tags) VALUES(?, ?, ?)', [
  //       'これ',
  //       'これ',
  //       ['yomi', 'anki'].join(' ')
  //     ]);
  //   }
  // }

  Future<List<int>> getExistsVocabularyList(List<int> vocabularyIdList) async {
    if (vocabularyIdList.length <= 0) {
      return [];
    }
    print('''
        with cte(vocab_id) as 
        (values (?)${',(?)' * (vocabularyIdList.length - 1)})
      select vocab_id from cte
      where vocab_id in (SELECT vocabulary_id FROM Vocabulary)
        ''');
    List<Map> list = await database!.rawQuery('''
        with cte(vocab_id) as 
        (values (?)${',(?)' * (vocabularyIdList.length - 1)})
      select vocab_id from cte
      where vocab_id in (SELECT vocabulary_id FROM Vocabulary)
        ''', vocabularyIdList);
    if (list.isNotEmpty) {
      return list.map((e) => e['vocab_id'] as int).toList();
    }
    return [];
  }

  Future<int> addVocabularyItem(Vocabulary vocabulary) async {
    vocabulary.vocabularyId = vocabulary.vocabularyId ?? vocabulary.id;
    int id = await database!.rawInsert(
        'INSERT INTO Vocabulary(vocabulary_id, expression, reading, tags, sentence) VALUES(?, ?, ?, ?, ?)',
        [
          vocabulary.vocabularyId,
          vocabulary.expression,
          vocabulary.reading,
          (vocabulary.tags ?? []).join(' '),
          vocabulary.sentence
        ]);
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
    print(vocabularyList);
    return vocabularyList;
  }

  Future<int> deleteVocabularyItem(int vocabularyId) async {
    if (database == null) {
      return 0;
    }
    int count = await database!.rawDelete(
        'DELETE FROM Vocabulary WHERE vocabulary_id = ?', [vocabularyId]);
    return count;
  }
}
