import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'vocabulary.dart';

class Dictionary {
  Database? japaneseDictionary;

  Dictionary._create() {
    // print("_create() (private constructor)");
  }

  static Future<Dictionary> create() async {
    Dictionary dictionary = Dictionary._create();
    String databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, "dictionary.db");

    // delete existing if any
    await deleteDatabase(path);

    // Make sure the parent directory exists
    try {
      await Directory(p.dirname(path)).create(recursive: true);
    } catch (_) {}

    // Copy from asset
    ByteData data =
        await rootBundle.load(p.join("assets", "japanese", "dictionary.db"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);

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
    List<Vocabulary> vocabularyList = [];
    if (reading.isNotEmpty) {
      rows = await japaneseDictionary!.rawQuery(
          'SELECT * FROM Vocab WHERE expression ${wildcards ? 'LIKE' : '='} ? AND reading = ?',
          [text, reading]);
    } else {
      rows = await japaneseDictionary!.rawQuery(
          'SELECT * FROM Vocab WHERE expression ${wildcards ? 'LIKE' : '='} ? OR reading = ?',
          [text, text]);
    }
    vocabularyList = rows.map((row) => Vocabulary.fromMap(row)).toList();
    for (Vocabulary vocabulary in vocabularyList) {
      List<Map<String, Object?>> rows = await japaneseDictionary!
          .rawQuery('SELECT glossary From VocabGloss WHERE vocabId=?', [
        vocabulary.id,
      ]);
      List<String> glossaryList =
          rows.map((obj) => obj['glossary'] as String).toList();
      vocabulary.glossary = glossaryList;
      List<String> addons = [];
      for (String tag in vocabulary.tags ?? []) {
        if (tag.startsWith('v5') && tag != 'v5') {
          addons.add('v5');
        } else if (tag.startsWith('vs-')) {
          addons.add('vs');
        }
      }
      vocabulary.tags = vocabulary.tags! + addons;
      vocabulary.vocabularyId =
          vocabulary.id; // in dictionary.db, vocab id column is simply named id
    }
    return vocabularyList;
  }
}
