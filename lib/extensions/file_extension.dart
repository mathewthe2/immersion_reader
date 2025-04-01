import 'dart:io';
import 'package:path/path.dart';

extension FileExtension on File {
  String name() => basename(path);
}
