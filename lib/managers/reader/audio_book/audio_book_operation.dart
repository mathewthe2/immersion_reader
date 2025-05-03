import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_files.dart';
import 'package:immersion_reader/data/reader/subtitle.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation_type.dart';

class AudioBookOperation {
  AudioBookOperationType type;
  List<Subtitle>? subtitles;
  AudioBookFiles? audioBookFiles;
  int? currentSubtitleIndex;
  Metadata? metadata;

  AudioBookOperation(
      {required this.type,
      this.subtitles,
      this.audioBookFiles,
      this.metadata,
      this.currentSubtitleIndex});

  static AudioBookOperation addAudioFile(
          {required Metadata metadata,
          required AudioBookFiles audioBookFiles}) =>
      AudioBookOperation(
          type: AudioBookOperationType.addAudioFile,
          metadata: metadata,
          audioBookFiles: audioBookFiles);

  static AudioBookOperation addSubtitleFile(
          {required List<Subtitle> subtitles,
          required int currentSubtitleIndex}) =>
      AudioBookOperation(
          type: AudioBookOperationType.addSubtitleFile,
          subtitles: subtitles,
          currentSubtitleIndex: currentSubtitleIndex);

  static AudioBookOperation get removeAudioFile =>
      AudioBookOperation(type: AudioBookOperationType.removeAudioFile);

  static AudioBookOperation get removeSubtitleFile =>
      AudioBookOperation(type: AudioBookOperationType.removeSubtitleFile);
}
