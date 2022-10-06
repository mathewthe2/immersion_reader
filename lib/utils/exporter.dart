import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:math';

Future<String> exportToAnkiDojoCSV(List<Vocabulary> vocabularyList,
    {fileName = ''}) async {
  if (vocabularyList.isNotEmpty) {
    // var rows = [
    //   ['expression', 'reading', 'glossary'],
    //   ['走る', 'はしる', 'to run; to dash']
    // ];
    List<List<String>> rows = [
      ['Expression', 'Reading', 'Glossary', 'Sentence']
    ];
    for (Vocabulary vocabulary in vocabularyList) {
      rows.add([
        vocabulary.expression ?? '',
        vocabulary.reading ?? '',
        vocabulary.getFirstGlossary(),
        vocabulary.sentence
      ]);
    }
    String csv = const ListToCsvConverter().convert(rows);
    if (fileName.isEmpty) {
      String firstThreeExpressions = vocabularyList
          .take(min(3, vocabularyList.length))
          .map((Vocabulary vocab) => vocab.expression)
          .join('_');
      fileName = '[AnkiDojo]$firstThreeExpressions.csv';
    }
    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/$fileName';
    File f = File(filePath);
    f.writeAsString(csv);
    return filePath;
  }
  return '';
}
