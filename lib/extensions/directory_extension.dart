import 'dart:io';

extension DirectoryExtension on Directory {
  Future<void> addTextFile(
      {required String data, required String filename}) async {
    File f = File("$path/$filename");
    await f.exists();
    if (!f.existsSync()) {
      f.createSync(recursive: true);
    }
    await f.writeAsString(data);
  }
}
