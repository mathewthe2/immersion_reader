import 'dart:io';

import 'package:immersion_reader/data/reader/audio_book/audio_book_files.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_match_result.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/book_blob.dart';
import 'package:immersion_reader/extensions/directory_extension.dart';
import 'package:immersion_reader/extensions/file_extension.dart';
import 'package:immersion_reader/utils/folder_utils.dart';
import 'package:path_provider/path_provider.dart';

class BookFiles {
  static const String elementHtmlFileName = 'elementHtml';
  static const String elementHtmlBackupFileName = 'elementHtmlBackup';
  static const String styleSheetFileName = 'styleSheet';
  static const String coverImageFileName = 'coverImage';

  static Future<Directory> _getBookMediaDirectory(String uniqueKey) async {
    Directory applicationDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${applicationDir.path}/media/books/$uniqueKey')
        .create(recursive: true);
    return dir;
  }

  static Future<void> updateBookContentHtml(AudioBookMatchResult result) async {
    Directory dir = await _getBookMediaDirectory(result.bookId.toString());
    List<Future> futures = [];
    final elementHtmlFile = File('${dir.path}/$elementHtmlFileName');
    if (elementHtmlFile.existsSync()) {
      elementHtmlFile.deleteSync();
    }
    futures.add(dir.addTextFile(
        data: result.elementHtml, filename: elementHtmlFileName));
    final elementHtmlBackupFile =
        File('${dir.path}/$elementHtmlBackupFileName');
    if (elementHtmlBackupFile.existsSync()) {
      elementHtmlBackupFile.deleteSync();
    }
    futures.add(dir.addTextFile(
        data: result.htmlBackup, filename: elementHtmlBackupFileName));
    await Future.wait(futures);
  }

  static Future<void> restoreBookContentHtmlFromBackup(int bookId) async {
    Directory dir = await _getBookMediaDirectory(bookId.toString());
    final elementHtmlBackupFile =
        File('${dir.path}/$elementHtmlBackupFileName');
    if (elementHtmlBackupFile.existsSync()) {
      final elementHtmlFile = File('${dir.path}/$elementHtmlFileName');
      if (elementHtmlFile.existsSync()) {
        elementHtmlFile.deleteSync();
      }
      final backupData = await elementHtmlBackupFile.readAsString();
      await dir.addTextFile(data: backupData, filename: elementHtmlFileName);
    }
  }

  static Future<void> saveBookContent(Book book) async {
    if (book.id == null) return;
    Directory dir = await _getBookMediaDirectory(book.id!.toString());
    List<Future> futures = [];
    if (book.elementHtml != null) {
      futures.add(dir.addTextFile(
          data: book.elementHtml!, filename: elementHtmlFileName));
    }
    if (book.elementHtmlBackup != null) {
      futures.add(dir.addTextFile(
          data: book.elementHtmlBackup!, filename: elementHtmlBackupFileName));
    }
    if (book.styleSheet != null) {
      futures
          .add(dir.addTextFile(data: book.styleSheet!, filename: "styleSheet"));
    }
    if (book.coverImage != null) {
      // base64 as txt
      futures
          .add(dir.addTextFile(data: book.coverImage!, filename: "coverImage"));
    }
    if (book.blobs != null && book.blobs!.isNotEmpty) {
      // base64 as txt
      Directory blobFolder =
          await Directory('${dir.path}/blobs').create(recursive: true);
      for (final blob in book.blobs!) {
        if (blob.base64Data != null) {
          futures.add(blobFolder.addTextFile(
              data: blob.base64Data!, filename: blob.fileName));
        }
      }
    }
    await Future.wait(futures);
  }

  static Future<Book> getBookContent(Book book,
      {Set<String>? requiredFileNames}) async {
    if (book.id == null) return book;
    Directory dir = await _getBookMediaDirectory(book.id!.toString());
    List<Future> futures = [];
    List<BookBlob> bookBlobs = [];
    List<File> subtitleFiles = [];
    List<File> audioFiles = [];
    final files = dir.listSync();
    for (final file in files) {
      if (requiredFileNames != null && !requiredFileNames.contains(file.name)) {
        continue;
      }
      switch (file.name) {
        case elementHtmlFileName:
          futures.add(File(file.path)
              .readAsString()
              .then((result) => book.elementHtml = result));
        case elementHtmlBackupFileName:
          futures.add(File(file.path)
              .readAsString()
              .then((result) => book.elementHtmlBackup = result));
        case styleSheetFileName:
          futures.add(File(file.path)
              .readAsString()
              .then((result) => book.styleSheet = result));
        case coverImageFileName:
          futures.add(File(file.path)
              .readAsString()
              .then((result) => book.coverImage = result));
        default:
          if (FolderUtils.subtitleExtensions.contains(file.ext)) {
            subtitleFiles.add(File(file.path));
          } else if (FolderUtils.audioExtensions.contains(file.ext)) {
            audioFiles.add(File(file.path));
          }
      }
    }
    Directory blobFolder = Directory('${dir.path}/blobs');
    if (blobFolder.existsSync()) {
      final blobFiles = blobFolder.listSync();
      for (final blobFile in blobFiles) {
        futures.add(File(blobFile.path).readAsString().then((result) =>
            bookBlobs.add(BookBlob(
                key: BookBlob.keyFromFileName(blobFile.name),
                base64Data: result))));
      }
    }
    await Future.wait(futures);
    book.blobs = bookBlobs;
    book.audioBookFiles =
        AudioBookFiles(subtitleFiles: subtitleFiles, audioFiles: audioFiles);
    return book;
  }

  static Future<void> removeBookContent(
      {required int bookId, required Set<String> fileNames}) async {
    Directory dir = await _getBookMediaDirectory(bookId.toString());
    for (final fileName in fileNames) {
      final elementHtmlFile = File('$dir/$fileName');
      if (elementHtmlFile.existsSync()) {
        elementHtmlFile.deleteSync();
      }
    }
  }
}
