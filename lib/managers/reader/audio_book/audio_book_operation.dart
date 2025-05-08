import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_files.dart';
import 'package:immersion_reader/data/reader/audio_book/subtitle/subtitles_data.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation_type.dart';

class AudioBookOperation {
  AudioBookOperationType type;
  SubtitlesData? subtitlesData;
  AudioBookFiles? audioBookFiles;
  int? currentSubtitleIndex;
  Metadata? metadata;
  int? bookId;

  AudioBookOperation(
      {required this.type,
      this.subtitlesData,
      this.audioBookFiles,
      this.metadata,
      this.currentSubtitleIndex,
      this.bookId});

  static AudioBookOperation addAudioFile(
          {required Metadata metadata,
          required AudioBookFiles audioBookFiles,
          int? bookId}) =>
      AudioBookOperation(
          type: AudioBookOperationType.addAudioFile,
          metadata: metadata,
          audioBookFiles: audioBookFiles,
          bookId: bookId);

  static AudioBookOperation addDummyAudioFile() => AudioBookOperation(
      type: AudioBookOperationType.addAudioFile,
      subtitlesData: SubtitlesData.empty);

  static AudioBookOperation addSubtitleFile(
          {required SubtitlesData subtitlesData,
          required int currentSubtitleIndex}) =>
      AudioBookOperation(
          type: AudioBookOperationType.addSubtitleFile,
          subtitlesData: subtitlesData,
          currentSubtitleIndex: currentSubtitleIndex);

  static AudioBookOperation get removeAudioFile => AudioBookOperation(
        type: AudioBookOperationType.removeAudioFile,
        subtitlesData: SubtitlesData.empty,
      );

  static AudioBookOperation get removeSubtitleFile => AudioBookOperation(
        type: AudioBookOperationType.removeSubtitleFile,
        subtitlesData: SubtitlesData.empty,
      );
}
