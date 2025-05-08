import 'dart:io';

class AudioBookFiles {
  List<File> subtitleFiles;
  List<File> audioFiles;

  AudioBookFiles({required this.subtitleFiles, required this.audioFiles});

  bool get isHaveAudio => audioFiles.isNotEmpty;
  bool get isHaveSubtitles => subtitleFiles.isNotEmpty;

  File? get audioFile =>
      isHaveAudio ? audioFiles.first : null; // assume only one audio file
}
