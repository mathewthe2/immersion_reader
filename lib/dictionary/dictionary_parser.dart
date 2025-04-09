import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:immersion_reader/widgets/settings/dictionary_settings.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:immersion_reader/utils/folder_utils.dart';
import './user_dictionary.dart';
import './dictionary_entry.dart';
import './dictionary_meta_entry.dart';
import './pitch_data.dart';

// https://github.com/lrorpilla/jidoujisho/blob/e445b09ea8fa5df2bfae8a0d405aa1ba5fc32767/yuuna/lib/src/dictionary/formats/yomichan_dictionary_format.dart
Future<UserDictionary> parseDictionary(
    {required File zipFile,
    StreamController<(DictionaryImportStage, double)>? progressController,
    String dictionaryVersion = '1.0.0'}) async {
  Directory workingDirectory = await FolderUtils.getWorkingFolder(
      cleanup: false); // our zip files may also be in working folder
  try {
    await ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: workingDirectory,
        onExtracting: (zipEntry, progress) {
          progressController?.add((DictionaryImportStage.extracting, progress));
          return ZipFileOperation.includeItem;
        });
    progressController?.add((DictionaryImportStage.parsing, -1));
    final List<FileSystemEntity> entities = workingDirectory.listSync();
    final Iterable<File> files = entities.whereType<File>();

    List<File> termFiles = List.from(
        files.where((file) => p.basename(file.path).startsWith('term_bank')));
    List<File> metaFiles = List.from(files
        .where((file) => p.basename(file.path).startsWith('term_meta_bank')));
    // List<File> tagFiles = List.from(
    //     files.where((file) => p.basename(file.path).startsWith('tag_bank')));

    String dictionaryName = getDictionaryName(workingDirectory);

    List<DictionaryEntry> dictionaryEntries =
        parseTerms(termFiles, dictionaryName);
    List<DictionaryMetaEntry> dictionaryMetaEntries =
        parseMetaTerms(metaFiles, dictionaryName);
    // List<DictionaryTag> dictionaryTags = parseTags(tagFiles, dictionaryName);
    await FolderUtils.cleanUpWorkingFolder();
    return UserDictionary(
        dictionaryName: dictionaryName,
        dictionaryEntries: dictionaryEntries,
        dictionaryMetaEntries: dictionaryMetaEntries,
        dictionaryTags: [],
        dictionaryVersion: dictionaryVersion);
  } catch (e) {
    debugPrint(e.toString());
  }
  await FolderUtils.cleanUpWorkingFolder();
  throw Exception('Unable to produce dictionary');
}

// List<DictionaryTag> parseTags(List<File> files, String dictionaryName) {
//   List<DictionaryTag> tags = [];
//   for (File file in files) {
//     List<dynamic> items = jsonDecode(file.readAsStringSync());
//     for (List<dynamic> item in items) {
//       String name = item[0] as String;
//       String category = item[1] as String;
//       int sortingOrder = item[2] as int;
//       String notes = item[3] as String;
//       double popularity = (item[4] as num).toDouble();

//       DictionaryTag tag = DictionaryTag(
//         dictionaryName: dictionaryName,
//         name: name,
//         category: category,
//         sortingOrder: sortingOrder,
//         notes: notes,
//         popularity: popularity,
//       );

//       tags.add(tag);
//     }
//   }
//   return tags;
// }

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

// returns reading:frequency
(String, String) _parseFrequency(dynamic rawFrequency) {
  String reading = '';
  String frequency = '';

  switch (rawFrequency) {
    case double d when d % 1 == 0:
      frequency = '${d.toInt()}';
      break;
    case double d:
      frequency = '$d';
      break;
    case int i:
      frequency = '$i';
      break;
    case Map<String, dynamic> obj:
      if (obj['frequency'] != null) {
        (_, frequency) = _parseFrequency(obj['frequency']);
      }
      if (obj['reading'] != null) {
        reading = obj['reading'];
      }
      break;
    default:
      frequency = rawFrequency.toString();
  }

  return (reading, frequency);
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
      String reading = '';

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
        (reading, frequency) = _parseFrequency(item[2]);
      } else {
        continue;
      }

      DictionaryMetaEntry metaEntry = DictionaryMetaEntry(
        dictionaryName: dictionaryName,
        term: term,
        reading: reading,
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
    debugPrint(e.toString());
  }
  throw Exception('Unable to get name');
}
