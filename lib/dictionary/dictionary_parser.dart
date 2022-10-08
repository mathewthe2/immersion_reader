import 'dart:io';
import 'dart:convert';
// import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_archive/flutter_archive.dart';
import 'package:immersion_reader/utils/folder_utils.dart';
import './user_dictionary.dart';
import './dictionary_entry.dart';
import './dictionary_meta_entry.dart';
import './pitch_data.dart';

// https://github.com/lrorpilla/jidoujisho/blob/e445b09ea8fa5df2bfae8a0d405aa1ba5fc32767/yuuna/lib/src/dictionary/formats/yomichan_dictionary_format.dart
Future<UserDictionary> parseDictionary(File zipFile) async {
  Directory workingDirectory = await getWorkingFolder();
  try {
    await ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: workingDirectory,
        onExtracting: (zipEntry, progress) {
          print('progress: ${progress.toStringAsFixed(1)}%');
          return ZipFileOperation.includeItem;
        });
    final List<FileSystemEntity> entities = workingDirectory.listSync();
    final Iterable<File> files = entities.whereType<File>();

    List<File> termFiles = List.from(
        files.where((file) => p.basename(file.path).startsWith('term_bank')));
    List<File> metaFiles = List.from(files
        .where((file) => p.basename(file.path).startsWith('term_meta_bank')));
    String dictionaryName = getDictionaryName(workingDirectory);

    List<DictionaryEntry> dictionaryEntries =
        parseTerms(termFiles, dictionaryName);
    List<DictionaryMetaEntry> dictionaryMetaEntries =
        parseMetaTerms(metaFiles, dictionaryName);
    return UserDictionary(
        dictionaryName: dictionaryName,
        dictionaryEntries: dictionaryEntries,
        dictionaryMetaEntries: dictionaryMetaEntries);
  } catch (e) {
    print(e);
  }
  throw Exception('Unable to produce dictionary');
}

List<DictionaryEntry> parseTerms(List<File> files, String dictionaryName) {
  List<DictionaryEntry> entries = [];
  for (File file in files) {
    List<dynamic> items = jsonDecode(file.readAsStringSync());

    for (List<dynamic> item in items) {
      String term = item[0] as String;
      String reading = item[1] as String;

      double popularity = (item[4] as num).toDouble();
      List<String> meaningTags = (item[2] as String).split(' ');
      List<String> termTags = (item[7] as String).split(' ');

      List<String> meanings = [];
      int? sequence = item[6] as int?;

      if (item[5] is List) {
        List<dynamic> meaningsList = List.from(item[5]);
        meanings = meaningsList.map((e) => e.toString()).toList();
      } else {
        meanings.add(item[5].toString());
      }
      entries.add(
        DictionaryEntry(
          term: term,
          reading: reading,
          meanings: meanings,
          popularity: popularity,
          meaningTags: meaningTags,
          termTags: termTags,
          sequence: sequence,
        ),
      );
    }
  }
  return entries;
}

List<DictionaryMetaEntry> parseMetaTerms(
    List<File> files, String dictionaryName) {
  List<DictionaryMetaEntry> metaEntries = [];
  for (File file in files) {
    String json = file.readAsStringSync();
    List<dynamic> items = jsonDecode(json);

    for (List<dynamic> item in items) {
      String term = item[0] as String;
      String type = item[1] as String;

      String? frequency;
      List<PitchData>? pitches;

      if (type == 'pitch') {
        pitches = [];

        Map<String, dynamic> data = Map<String, dynamic>.from(item[2]);
        String reading = data['reading'];

        List<Map<String, dynamic>> distinctPitchJsons =
            List<Map<String, dynamic>>.from(data['pitches']);
        for (Map<String, dynamic> distinctPitch in distinctPitchJsons) {
          int downstep = distinctPitch['position'];
          PitchData pitch = PitchData(
            reading: reading,
            downstep: downstep,
          );
          pitches.add(pitch);
        }
      } else if (type == 'freq') {
        if (item[2] is double) {
          double number = item[2] as double;
          if (number % 1 == 0) {
            frequency = '${number.toInt()}';
          } else {
            frequency = '$number';
          }
        } else if (item[2] is int) {
          int number = item[2] as int;
          frequency = '$number';
        } else {
          frequency = item[2].toString();
        }
      } else {
        continue;
      }

      DictionaryMetaEntry metaEntry = DictionaryMetaEntry(
        dictionaryName: dictionaryName,
        term: term,
        frequency: frequency,
        pitches: pitches,
      );

      metaEntries.add(metaEntry);
    }
  }
  return metaEntries;
}

String getDictionaryName(Directory workingDirectory) {
  try {
    /// Get the index, which contains the name of the dictionary contained by
    /// the archive.
    String indexFilePath = p.join(workingDirectory.path, 'index.json');
    File indexFile = File(indexFilePath);
    String indexJson = indexFile.readAsStringSync();
    Map<String, dynamic> index = jsonDecode(indexJson);

    String dictionaryName = (index['title'] as String).trim();
    return dictionaryName;
  } catch (e) {
    print(e);
  }
  throw Exception('Unable to get name');
}
