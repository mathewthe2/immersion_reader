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

  static Future<File> createTempFile(String filename) async {
    final dir = await getWorkingFolder();
    final tempFile = File('${dir.path}/$filename');
    if (!tempFile.existsSync()) {
      tempFile.createSync(
          recursive: true); // create intermediate folders if necessary
    }
    return tempFile;
  }
}
