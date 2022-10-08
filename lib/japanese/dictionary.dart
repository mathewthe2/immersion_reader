import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'vocabulary.dart';
import 'package:immersion_reader/dictionary/dictionary_entry.dart';

class Dictionary {
  Database? japaneseDictionary;

  Dictionary._create() {
    // print("_create() (private constructor)");
  }

  static Future<Dictionary> create() async {
    Dictionary dictionary = Dictionary._create();
    String databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, "data.db");

    // delete existing if any
    // await deleteDatabase(path);

    // Make sure the parent directory exists
    try {
      await Directory(p.dirname(path)).create(recursive: true);
    } catch (_) {}

    // Copy from asset
    // ByteData data =
    //     await rootBundle.load(p.join("assets", "japanese", "dictionary.db"));
    // List<int> bytes =
    //     data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    // await File(path).writeAsBytes(bytes, flush: true);

    // open the database
    dictionary.japaneseDictionary = await openDatabase(path, readOnly: true);
    return dictionary;
  }

  Future<List<Vocabulary>> findTerm(String text,
      {wildcards = false, String reading = ''}) async {
    if (japaneseDictionary == null) {
      return [];
    }
    List<Map<String, Object?>> rows = [];

    if (reading.isNotEmpty) {
      rows = await japaneseDictionary!.rawQuery(
          'SELECT * FROM Vocab WHERE expression ${wildcards ? 'LIKE' : '='} ? AND reading = ?',
          [text, reading]);
    } else {
      rows = await japaneseDictionary!.rawQuery(
          'SELECT * FROM Vocab WHERE expression ${wildcards ? 'LIKE' : '='} ? OR reading = ?',
          [text, text]);
    }

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
      vocabulary.id = vocabulary.getIdentifier();
      vocabulary.expression = dictionaryEntry.term;
      vocabulary.reading = dictionaryEntry.reading;

      String vocabularyKey = vocabulary.getIdentifier();
      if (vocabularyMap.containsKey(vocabularyKey)) {
        vocabularyMap[vocabularyKey]!.entries = [
          ...vocabularyMap[vocabularyKey]!.entries!,
          dictionaryEntry
        ];
      } else {
        vocabularyMap[vocabularyKey] = vocabulary;
      }
    }
    return vocabularyMap.values.toList();
  }
}
