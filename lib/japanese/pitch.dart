import 'package:flutter/foundation.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
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

  Future<List<String>> getPitches(String text,
      {wildcards = false, String reading = ''}) async {
    if (settingsStorage == null) {
      return [];
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
      debugPrint(e.toString());
    }
    if (rows.isNotEmpty) {
      return rows.map((row) => row['pitch'] as String).toList();
    }
    return [];
  }

  Future<List<String>> makePitch(String expression,
      {String reading = '',
      PitchAccentDisplayStyle pitchAccentDisplayStyle =
          PitchAccentDisplayStyle.graph}) async {
    List<String> result = [];
    if (expression.isEmpty) {
      return result;
    }
    List<String> pitches = await getPitches(expression, reading: reading);
    if (pitches.isEmpty) {
      return result;
    }
    // call _parseRawPitchStrings() here for older pitch dictionaries
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
      switch (pitchAccentDisplayStyle) {
        case PitchAccentDisplayStyle.graph:
          {
            String svg =
                pitchSvg(reading, pitchValueToPatt(reading, pitchValue));
            result.add(svg);
            break;
          }
        case PitchAccentDisplayStyle.number:
          {
            result.add(pitchValue.toString());
            break;
          }
          default:
          break;
      }
    }
    return result;
  }
}

// not necessary for newer pitch dictionaries
// List<String> _parseRawPitchStrings(String pitch) {
//     pitch = pitch.replaceAll(
//         RegExp(r'\((.*?)\)'), ''); // remove paranthesis content
//     List<String> pitches = [];
//     if (pitch.contains(',')) {
//       List<String> pitchesByWord = pitch.split(',');
//       for (String pitchByWord in pitchesByWord) {
//         pitchByWord =
//             pitchByWord.replaceAll(RegExp(r'[^\w]'), ''); // remove symbols
//         pitches.add(pitchByWord);
//       }
//     } else {
//       pitch = pitch.replaceAll(RegExp(r'[^\w]'), ''); // remove symbols
//       pitches = [pitch];
//     }
//     return pitches;
// }
