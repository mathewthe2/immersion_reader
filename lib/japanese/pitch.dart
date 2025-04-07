import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/japanese/draw_pitch.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/storage/settings_storage.dart';
import 'package:sqflite/sqflite.dart';

class Pitch {
  Database? pitchAccentsDictionary;
  SettingsStorage? settingsStorage;

  static final Pitch _singleton = Pitch._internal();
  Pitch._internal();

  factory Pitch.create(SettingsStorage settingsStorage) {
    _singleton.settingsStorage = settingsStorage;
    return _singleton;
  }

  Future<List<List<String>>> getPitchesBatch(
      List<Vocabulary> definitions) async {
    if (settingsStorage == null || definitions.isEmpty) {
      return List.filled(definitions.length, []);
    }
    final List<String> whereClauses = [];
    final List<String> values = [];
    Map<String, int> pitchMap = {};

    for (final (int i, Vocabulary definition) in definitions.indexed) {
      if (definition.reading != null && definition.reading!.isNotEmpty) {
        whereClauses.add('(expression = ? AND reading = ?)');
        values.addAll([definition.expression ?? "", definition.reading!]);
        pitchMap['${definition.expression}-${definition.reading}'] = i;
      } else if (definition.expression != null &&
          definition.expression!.isNotEmpty) {
        whereClauses
            .add('(expression = ? AND (reading IS NULL OR reading = ""))');
        values.add(definition.expression!);
        pitchMap[definition.expression!] = i;
      }
    }

    final rows = await settingsStorage!.database!.rawQuery(
        'SELECT expression, reading, pitch FROM VocabPitch WHERE ${whereClauses.join(' OR ')}',
        values);

    List<List<String>> pitches = List.generate(definitions.length, (_) => []);
    for (final row in rows) {
      final expression = row['expression'] as String;
      final reading = row['reading'] as String?;
      final pitch = row['pitch'] as String;
      if (reading != null &&
          reading.isNotEmpty &&
          pitchMap.containsKey('$expression-$reading')) {
        pitches[pitchMap['$expression-$reading']!].add(pitch);
      } else if (pitchMap.containsKey(expression)) {
        pitches[pitchMap[expression]!].add(pitch);
      }
    }
    return pitches;
  }

  Future<List<List<String>>> makePitchesBatch(List<Vocabulary> definitions,
      {PitchAccentDisplayStyle pitchAccentDisplayStyle =
          PitchAccentDisplayStyle.graph}) async {
    List<List<String>> result = List.generate(definitions.length, (_) => []);
    List<List<String>> pitchesBatch = await getPitchesBatch(definitions);
    // call _parseRawPitchStrings() here for older pitch dictionaries
    for (final (int i, List<String> pitches) in pitchesBatch.indexed) {
      Set<int> parsedPitches = {};
      for (String rawPitch in pitches) {
        bool isPitchNumeric = int.tryParse(rawPitch) != null;
        if (isPitchNumeric) {
          for (int i = 0; i < rawPitch.length; i++) {
            parsedPitches.add(int.parse(rawPitch[i]));
          }
        }
      }
      String reading =
          definitions[i].reading ?? definitions[i].expression ?? "";
      if (reading.isEmpty) {
        continue;
      }
      for (int pitchValue in parsedPitches) {
        switch (pitchAccentDisplayStyle) {
          case PitchAccentDisplayStyle.graph:
            {
              String svg =
                  pitchSvg(reading, pitchValueToPatt(reading, pitchValue));
              result[i].add(svg);
              break;
            }
          case PitchAccentDisplayStyle.number:
            {
              result[i].add(pitchValue.toString());
              break;
            }
          default:
            break;
        }
      }
    }
    return result;
  }
}
