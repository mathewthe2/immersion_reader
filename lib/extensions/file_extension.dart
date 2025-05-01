import 'dart:io';
import 'package:path/path.dart';

extension FileExtension on File {
  String get name => basename(path);
  String get ext => extension(path);
}

extension FileSystemEntityExtension on FileSystemEntity {
  String get name => basename(path);
  String get ext => extension(path);
}
