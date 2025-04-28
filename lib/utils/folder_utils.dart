import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:immersion_reader/data/reader/audio_book_files.dart';
import 'package:immersion_reader/extensions/file_extension.dart';
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

  static const List<String> audioExtensions = [".mp3", ".m4a", ".m4b"];
  static const List<String> subtitleExtensions = [".srt", ".txt"];

  static Future<void> cleanUpBookFolder(int bookId) async {
    String folderPath = await _getBookMediaFolderPath(bookId.toString());
    Directory directory = Directory(folderPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }

  static Future<void> _removeFilesForBookWithExtension(
      {required int bookId, required List<String> extensions}) async {
    String folderPath = await _getBookMediaFolderPath(bookId.toString());
    Directory directory = Directory(folderPath);
    if (directory.existsSync()) {
      final files = Directory(folderPath).listSync();

      // Create a regex pattern like: \.(srt|vtt|ass)$
      final pattern = extensions
          .map((ext) => ext.replaceFirst('.', '')) // remove the dot
          .join('|');
      final regex = RegExp(r'\.(' + pattern + r')$');

      for (final file in files) {
        if (regex.hasMatch(file.path)) {
          File(file.path).deleteSync();
        }
      }
    }
  }

  static Future<void> removeSubtitleFilesForBook(int bookId) async {
    _removeFilesForBookWithExtension(
        bookId: bookId, extensions: subtitleExtensions);
  }

  static Future<void> removeAudioFilesForBook(int bookId) async {
    _removeFilesForBookWithExtension(
        bookId: bookId, extensions: audioExtensions);
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
    if (Directory(folderPath).existsSync()) {
      var files = Directory(folderPath).listSync();
      return files.map((file) => File(file.path)).toList();
    }
    return [];
  }

  static Future<AudioBookFiles> getAudioBook(int bookId) async {
    final files = await getFilesinBookFolder(bookId);
    List<File> subtitleFiles = [];
    List<File> audioFiles = [];
    for (final file in files) {
      if (subtitleExtensions.contains(file.ext)) {
        subtitleFiles.add(file);
      } else if (audioExtensions.contains(file.ext)) {
        audioFiles.add(file);
      }
    }
    return AudioBookFiles(subtitleFiles: subtitleFiles, audioFiles: audioFiles);
  }

  static Future<String?> addAudioFile(int bookId) async {
    File? audioFile = await addSingleFile(allowedExtensions: audioExtensions);

    if (audioFile != null) {
      String newFilePath = await saveToBookFolder(
          bookId: bookId, file: audioFile, fileName: audioFile.name);
      return newFilePath;
    }
    return null;
  }

  static Future<String?> addSubtitleFile(int bookId) async {
    File? subtitleFile =
        await addSingleFile(allowedExtensions: subtitleExtensions);

    if (subtitleFile != null) {
      String newFilePath = await saveToBookFolder(
          bookId: bookId, file: subtitleFile, fileName: subtitleFile.name);
      return newFilePath;
    }
    return null;
  }

  static Future<File?> addSingleFile(
      {required List<String> allowedExtensions}) async {
    final files = await FilePicker.platform.pickFiles();

    if (files != null && files.isSinglePick) {
      final fileName = files.names.first;
      final filePath = files.paths.first;
      String fileExtension = ".${fileName?.split(".")[1] ?? ""}";
      if (fileName == null || filePath == null) {
        SmartDialog.showNotify(
            msg: "Error reading file", notifyType: NotifyType.error);
      } else if (!allowedExtensions.contains(fileExtension)) {
        SmartDialog.showNotify(
            msg: "${allowedExtensions.join(", ")} file required",
            notifyType: NotifyType.error);
      } else {
        return File(filePath);
      }
    }
    return null;
  }
}
