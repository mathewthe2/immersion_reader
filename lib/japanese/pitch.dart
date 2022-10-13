import 'package:immersion_reader/japanese/draw_pitch.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:sqflite/sqflite.dart';

class Pitch {
  Database? pitchAccentsDictionary;
  SettingsStorage? settingsStorage;

  Pitch._create() {
    // print("_create() (private constructor)");
  }

  static Pitch create(SettingsStorage settingsStorage) {
    Pitch pitch = Pitch._create();
    pitch.settingsStorage = settingsStorage;
    return pitch;
  }

  Future<String> getPitch(String text,
      {wildcards = false, String reading = ''}) async {
    if (settingsStorage == null) {
      return '';
    }
    List<Map<String, Object?>> rows = [];
    try {
      if (reading.isNotEmpty) {
        rows = await settingsStorage!.database!.rawQuery(
            'SELECT pitch FROM VocabPitch WHERE expression = ? AND reading = ?',
            [text, reading]);
      } else {
        rows = await settingsStorage!.database!
            .rawQuery('SELECT pitch FROM VocabPitch WHERE expression = ?', [
          text,
        ]);
      }
    } catch (e) {
      print(e);
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
