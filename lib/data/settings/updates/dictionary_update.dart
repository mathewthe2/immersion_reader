import 'package:immersion_reader/data/settings/updates/update_entity.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:immersion_reader/utils/folder_utils.dart';

class DictionaryUpdate {
  UpdateEntity jmdictEnglish;
  String dictionaryKey;
  DictionaryUpdate({required this.jmdictEnglish, required this.dictionaryKey});

  factory DictionaryUpdate.fromMap(
          Map<String, Object?> map, String dictionaryKey) =>
      DictionaryUpdate(
          jmdictEnglish:
              UpdateEntity.fromMap(map[dictionaryKey] as Map<String, Object?>),
          dictionaryKey: dictionaryKey);

  String get version => jmdictEnglish.version;
  int get extendedVersion => jmdictEnglish.extendedVersion;
  String get source => jmdictEnglish.source;

  Future<File?> getUpdatedDictionary() async {
    final response = await http.get(Uri.parse(source));
    if (response.statusCode == 200) {
      final tempFile = await FolderUtils.createTempFile('dict.zip');
      await tempFile.writeAsBytes(response.bodyBytes);
      return tempFile;
    }
    return null;
  }
}
