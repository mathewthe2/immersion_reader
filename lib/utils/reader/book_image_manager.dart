import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BookImageManager {

  // gets file path of base64 image data
  static Future<String> _getImageFilePath(
      {required String key, required String title}) async {
    Directory applicationDir = await getApplicationDocumentsDirectory();
    String filePath = '${applicationDir.path}/media/books/${key}_$title';
    return filePath;
  }

  static Future<String?> getImageBase64(
      {required String key, required String title}) async {
    String filePath = await _getImageFilePath(key: key, title: title);
    File f = File(filePath);
    await f.exists();
    if (f.existsSync()) {
      return f.readAsString();
    } else {
      return null;
    }
  }

  static Future<String> saveImageIfNotExists(
      {required String base64Image,
      required String key,
      required String title}) async {
    String filePath = await _getImageFilePath(key: key, title: title);
    File f = File(filePath);
    await f.exists();
    if (!f.existsSync()) {
      f.createSync(recursive: true); // create intermediate folders if necessary
      f.writeAsString(base64Image);
    }
    return filePath;
  }
}
