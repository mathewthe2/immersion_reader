import 'package:immersion_reader/storage/abstract_storage.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';

class VocabularyListStorage extends AbstractStorage {
  @override
  String get databaseStorageName => databaseName;

  @override
  Function get onOpenCallback => (() => initCache());

  static const String databaseName = 'vocabulary_list.db';

  static final VocabularyListStorage _singleton =
      VocabularyListStorage._internal();
  VocabularyListStorage._internal();
  factory VocabularyListStorage() => _singleton;

  List<Vocabulary> vocabularyListCache = [];

  Future<void> initCache() async {
    vocabularyListCache = await getVocabularyItems();
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
    vocabulary.entries =
        []; // remove dictionary entries and only keep glossary; temporary patch for getCompleteGlossary() as glossary updates not showing
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
    vocabularyListCache = List.from(vocabularyListCache)
      ..removeWhere((vocabulary) => vocabulary.uniqueId == vocabularyId);
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
