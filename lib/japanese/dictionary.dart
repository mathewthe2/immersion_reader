import 'package:sqflite/sqflite.dart';
import 'vocabulary.dart';
import 'package:immersion_reader/dictionary/dictionary_entry.dart';
import 'package:immersion_reader/storage/settings_storage.dart';

class Dictionary {
  Database? japaneseDictionary;

  static int termLimit = 1000;

  static final Dictionary _singleton = Dictionary._internal();
  Dictionary._internal();

  factory Dictionary.create(SettingsStorage settingsStorage) {
    _singleton.japaneseDictionary = settingsStorage.database;
    return _singleton;
  }

  Future<List<DictionaryEntry>> findTermsBulk(List<String> terms,
      {List<int> disabledDictionaryIds = const []}) async {
    // List<DictionaryEntry> result = [];
    Batch batch = japaneseDictionary!.batch();
    for (String term in terms) {
      batch.rawQuery(
          'SELECT * FROM Vocab WHERE expression = ? OR reading = ? LIMIT $termLimit',
          [term, term]);
    }
    List<Object?> results = await batch.commit();
    List<DictionaryEntry> dictionaryEntries = [];
    for (int i = 0; i < results.length; i++) {
      List<Map<String, Object?>> rows =
          results[i] as List<Map<String, Object?>>;
      for (Map<String, Object?> row in rows) {
        DictionaryEntry entry = DictionaryEntry.fromMap(row);
        entry.index = i;
        dictionaryEntries.add(entry);
      }
    }

    if (disabledDictionaryIds.isNotEmpty) {
      dictionaryEntries = List.from(dictionaryEntries.where(
          (DictionaryEntry entry) =>
              !disabledDictionaryIds.contains(entry.dictionaryId)));
    }
    return dictionaryEntries;
  }

  Future<List<Vocabulary>> getVocabularyFromMeaning(String word) async {
    List<Map<String, Object?>> rows = await japaneseDictionary!.query(
        'VocabGloss',
        columns: ['vocabId'],
        where:
            'glossary LIKE ? OR glossary LIKE ? OR glossary LIKE ? OR lower(glossary) = ?',
        whereArgs: ['% $word', '$word %', '% $word %', word],
        limit: termLimit);

    Batch batch = japaneseDictionary!.batch();
    for (Map<String, Object?> row in rows) {
      batch.rawQuery("SELECT * FROM Vocab WHERE id = ? LIMIT $termLimit",
          [row["vocabId"] as int]);
    }
    List<DictionaryEntry> dictionaryEntries = [];
    List<Object?> results = await batch.commit();
    for (int i = 0; i < results.length; i++) {
      List<Map<String, Object?>> rows =
          results[i] as List<Map<String, Object?>>;
      for (Map<String, Object?> row in rows) {
        DictionaryEntry entry = DictionaryEntry.fromMap(row);
        dictionaryEntries.add(entry);
      }
    }
    return await getVocabularyBatch(dictionaryEntries);
  }

  Future<List<Vocabulary>> getVocabularyBatch(
      List<DictionaryEntry> dictionaryEntries) async {
    Map<String, Vocabulary> vocabularyMap = {};
    for (DictionaryEntry dictionaryEntry in dictionaryEntries) {
      List<Map<String, Object?>> rows = await japaneseDictionary!.rawQuery(
          'SELECT glossary From VocabGloss WHERE vocabId=? LIMIT $termLimit', [
        dictionaryEntry.id,
      ]);

      dictionaryEntry.meanings =
          rows.map((obj) => obj['glossary'] as String).toList();
      Vocabulary vocabulary = Vocabulary(entries: [dictionaryEntry]);
      // to do: refactor to remove extra data in vocabulary
      vocabulary.tags = dictionaryEntry.meaningTags;
      vocabulary.id = vocabulary.uniqueId;
      vocabulary.expression = dictionaryEntry.term;
      vocabulary.reading = dictionaryEntry.reading;
      String vocabularyKey = vocabulary.uniqueId;
      if (vocabularyMap.containsKey(vocabularyKey)) {
        vocabularyMap[vocabularyKey]!.entries = [
          ...vocabularyMap[vocabularyKey]!.entries,
          dictionaryEntry
        ];
      } else {
        vocabularyMap[vocabularyKey] = vocabulary;
      }
    }
    return vocabularyMap.values.toList();
  }

  Future<List<Vocabulary>> findTerm(String text,
      {wildcards = false, String reading = ''}) async {
    if (japaneseDictionary == null) {
      return [];
    }
    List<Map<String, Object?>> rows = [];

    if (reading.isNotEmpty) {
      rows = await japaneseDictionary!.rawQuery(
          'SELECT * FROM Vocab WHERE expression ${wildcards ? 'LIKE' : '='} ? AND reading = ? LIMIT $termLimit',
          [text, reading]);
    } else {
      rows = await japaneseDictionary!.rawQuery(
          'SELECT * FROM Vocab WHERE expression ${wildcards ? 'LIKE' : '='} ? OR reading = ? LIMIT $termLimit',
          [text, text]);
    }
    // print(rows);

    List<DictionaryEntry> dictionaryEntries =
        rows.map((row) => DictionaryEntry.fromMap(row)).toList();

    Map<String, Vocabulary> vocabularyMap = {};
    for (DictionaryEntry dictionaryEntry in dictionaryEntries) {
      List<Map<String, Object?>> rows = await japaneseDictionary!
          .rawQuery('SELECT glossary From VocabGloss WHERE vocabId=?', [
        dictionaryEntry.id,
      ]);

      dictionaryEntry.meanings =
          rows.map((obj) => obj['glossary'] as String).toList();
      Vocabulary vocabulary = Vocabulary(entries: [dictionaryEntry]);

      List<String> addons = [];
      for (String tag in dictionaryEntry.meaningTags) {
        if (tag.startsWith('v5') && tag != 'v5') {
          addons.add('v5');
        } else if (tag.startsWith('vs-')) {
          addons.add('vs');
        }
      }

      // to do: refactor to remove extra data in vocabulary
      vocabulary.tags = dictionaryEntry.meaningTags + addons;
      vocabulary.id = vocabulary.uniqueId;
      vocabulary.expression = dictionaryEntry.term;
      vocabulary.reading = dictionaryEntry.reading;

      String vocabularyKey = vocabulary.uniqueId;
      if (vocabularyMap.containsKey(vocabularyKey)) {
        vocabularyMap[vocabularyKey]!.entries = [
          ...vocabularyMap[vocabularyKey]!.entries,
          dictionaryEntry
        ];
      } else {
        vocabularyMap[vocabularyKey] = vocabulary;
      }
    }
    return vocabularyMap.values.toList();
  }
}
