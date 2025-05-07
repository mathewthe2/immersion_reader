import 'dart:io';

class AudioBookFiles {
  List<File> subtitleFiles;
  List<File> audioFiles;

  AudioBookFiles({required this.subtitleFiles, required this.audioFiles});

  File get audioFile => audioFiles.first; // assume only one audio file
}
