import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FolderUtils {
  static Future<Directory> getWorkingFolder({cleanup = true}) async {
    Directory tempDirectory = await getTemporaryDirectory();
    Directory workingDirectory =
        Directory(p.join(tempDirectory.path, 'workingDirectory'));
    // If the working area exists, clean it up.
    if (cleanup && workingDirectory.existsSync()) {
      workingDirectory.deleteSync(recursive: true);
    }
    return workingDirectory;
  }

  static Future<void> cleanUpWorkingFolder() async {
    await getWorkingFolder(cleanup: true);
  }

  static Future<File> createTempFile(String filename) async {
    final dir = await getWorkingFolder();
    final tempFile = File('${dir.path}/$filename');
    if (!tempFile.existsSync()) {
      tempFile.createSync(
          recursive: true); // create intermediate folders if necessary
    }
    return tempFile;
  }

  static Future<String> _getBookMediaFolderPath(String uniqueKey) async {
    Directory applicationDir = await getApplicationDocumentsDirectory();
    String folderPath = '${applicationDir.path}/media/books/$uniqueKey';
    return folderPath;
  }

  static Future<void> cleanUpBookFolder(int bookId) async {
    String folderPath = await _getBookMediaFolderPath(bookId.toString());
    Directory directory = Directory(folderPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }

  static Future<String> saveToBookFolder(
      {required int bookId,
      required File file,
      required String fileName}) async {
    String folderPath = await _getBookMediaFolderPath(bookId.toString());
    String filePath = '$folderPath/$fileName';
    File f = File(filePath);
    f.createSync(recursive: true); // create intermediate folders if necessary
    file.copy(filePath); // copy file to new file path
    return filePath;
  }

  static Future<List<File>> getFilesinBookFolder(int bookId) async {
    String folderPath = await _getBookMediaFolderPath(bookId.toString());
    var files = Directory(folderPath).listSync();
    return files.map((file) => File(file.path)).toList();
  }
}
