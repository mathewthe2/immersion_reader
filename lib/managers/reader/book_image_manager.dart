import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BookImageManager {
  Map<String, String> imageCache = {};
  
  static final BookImageManager _singleton = BookImageManager._internal();
  factory BookImageManager() => _singleton;
  BookImageManager._internal();
  
  static String _uniqueKey({required String key, required String title}) {
    return '${key}_$title';
  }

  // gets file path of base64 image data
  static Future<String> _getImageFilePath(String uniqueKey) async {
    Directory applicationDir = await getApplicationDocumentsDirectory();
    String filePath = '${applicationDir.path}/media/books/$uniqueKey';
    return filePath;
  }

  Future<String?> getImageBase64(
      {required String key, required String title}) async {
    String uniqueKey = _uniqueKey(key: key, title: title);
    if (imageCache.containsKey(uniqueKey)) {
      return imageCache[uniqueKey];
    }
    String filePath = await _getImageFilePath(uniqueKey);
    File f = File(filePath);
    await f.exists();
    if (f.existsSync()) {
      String imageBase64 = await f.readAsString();
      imageCache[uniqueKey] = imageBase64;
      return imageBase64;
    } else {
      return null;
    }
  }

  Future<void> saveImageIfNotExists(
      {required String base64Image,
      required String key,
      required String title}) async {
    String uniqueKey = _uniqueKey(key: key, title: title);
    if (imageCache.containsKey(uniqueKey)) {
      return;
    }
    String filePath = await _getImageFilePath(uniqueKey);
    File f = File(filePath);
    await f.exists();
    if (!f.existsSync()) {
      f.createSync(recursive: true); // create intermediate folders if necessary
      f.writeAsString(base64Image);
    } 
    if (!imageCache.containsKey(uniqueKey)) {
      imageCache[uniqueKey] = base64Image;
    }
  }
}
