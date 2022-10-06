import 'package:immersion_reader/japanese/draw_pitch.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class Pitch {
  Database? pitchAccentsDictionary;

  Pitch._create() {
    // print("_create() (private constructor)");
  }

  static Future<Pitch> create() async {
    Pitch pitch = Pitch._create();
    String databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, "pitch_accents.db");

    // delete existing if any
    await deleteDatabase(path);

    // Make sure the parent directory exists
    try {
      await Directory(p.dirname(path)).create(recursive: true);
    } catch (_) {}

    // Copy from asset
    ByteData data =
        await rootBundle.load(p.join("assets", "japanese", "pitch_accents.db"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);

    // open the database
    pitch.pitchAccentsDictionary = await openDatabase(path, readOnly: true);
    return pitch;
  }

  Future<String> getPitch(String text,
      {wildcards = false, String reading = ''}) async {
    if (pitchAccentsDictionary == null) {
      return '';
    }
    List<Map<String, Object?>> rows = [];
    if (reading.isNotEmpty) {
      rows = await pitchAccentsDictionary!.rawQuery(
          'SELECT pitch FROM Dict WHERE expression = ? AND reading = ?',
          [text, reading]);
    } else {
      rows = await pitchAccentsDictionary!
          .rawQuery('SELECT pitch FROM Dict WHERE expression = ?', [
        text,
      ]);
    }
    if (rows.isNotEmpty) {
      return rows[0]['pitch'] as String;
    }
    return '';
  }

  Future<List<String>> getSvg(String expression, {String reading = ''}) async {
    List<String> result = [];
    if (expression.isEmpty) {
      return result;
    }
    String pitch = await getPitch(expression, reading: reading);
    if (pitch.isEmpty) {
      return result;
    }
    pitch = pitch.replaceAll(
        RegExp(r'\((.*?)\)'), ''); // remove paranthesis content
    List<String> pitches = [];
    if (pitch.contains(',')) {
      List<String> pitchesByWord = pitch.split(',');
      for (String pitchByWord in pitchesByWord) {
        pitchByWord =
            pitchByWord.replaceAll(RegExp(r'[^\w]'), ''); // remove symbols
        pitches.add(pitchByWord);
      }
    } else {
      pitch = pitch.replaceAll(RegExp(r'[^\w]'), ''); // remove symbols
      pitches = [pitch];
    }
    Set<int> parsedPitches = {};
    for (String rawPitch in pitches) {
      bool isPitchNumeric = int.tryParse(rawPitch) != null;
      if (isPitchNumeric) {
        for (int i = 0; i < rawPitch.length; i++) {
          parsedPitches.add(int.parse(rawPitch[i]));
        }
      }
    }
    if (reading.isEmpty) {
      reading = expression;
    }
    for (int pitchValue in parsedPitches) {
      String svg = pitchSvg(reading, pitchValueToPatt(reading, pitchValue));
      result.add(svg);
    }
    return result;
  }
}
