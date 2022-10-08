import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<Directory> getWorkingFolder() async {
  Directory tempDirectory = await getTemporaryDirectory();
  Directory workingDirectory =
      Directory(p.join(tempDirectory.path, 'workingDirectory'));
  // If the working area exists, clean it up.
  if (workingDirectory.existsSync()) {
    workingDirectory.deleteSync(recursive: true);
  }
  return workingDirectory;
}
