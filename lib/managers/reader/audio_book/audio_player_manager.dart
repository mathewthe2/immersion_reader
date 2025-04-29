import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_player_state.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/subtitle.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_player_handler.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_service_handler.dart';
import 'package:immersion_reader/managers/reader/book_manager.dart';
import 'package:immersion_reader/managers/reader/reader_js_manager.dart';
import 'package:immersion_reader/utils/folder_utils.dart';
import 'package:immersion_reader/utils/reader/highlight_js.dart';

class AudioPlayerManager {
  final StreamController<AudioPlayerState> _positionController =
      StreamController<AudioPlayerState>.broadcast();
  AudioPlayerState? currentState;
  StreamSubscription<PlayerState>? playerStateSubscription;
  Metadata? audioFileMetadata;

  // update book's playback position
  Timer? updateBookPlayBackTimer;
  int? lastPlayBackPositionInMs;

  // subtitles
  List<Subtitle> currentSubtitles = [];
  int? playBackPositionInMs;
  int currentSubtitleIndex = 0;
  bool isRequireSearchSubtitle = true;

  static const int updateBookIntervalInMs =
      1000; // save playBackPosition to db every second

  static final AudioPlayerManager _singleton = AudioPlayerManager._internal();

  factory AudioPlayerManager() => _singleton;
  AudioPlayerManager._internal();

  Stream<AudioPlayerState> get onPositionChanged => _positionController.stream;

  AudioServiceHandler get audioService =>
      AudioPlayerHandler().audioServiceHandler;

  Future<Metadata> setSourceFromDevice(
      {required File audioFile, required Book book}) async {
    if (audioFileMetadata != null) {
      return audioFileMetadata!;
    }
    audioFileMetadata = await MetadataRetriever.fromFile(audioFile);
    // final imageFile = File.fromRawPath(audioFileMetadata!.albumArt!);
    final imageUri = await FolderUtils()
        .createImageUriFromBytes(audioFileMetadata!.albumArt!);

    audioService.setSource(DeviceFileSource(audioFile.path),
        customMediaItem: MediaItem(
            id: audioFileMetadata!.trackName ?? "",
            title: audioFileMetadata!.trackName ?? "",
            artist: audioFileMetadata!.authorName ?? "",
            displayDescription: "description here",
            displaySubtitle: "Subtitle here",
            displayTitle: "title here",
            artUri: imageUri));

    if (playBackPositionInMs == null && book.playBackPositionInMs != null) {
      playBackPositionInMs = book.playBackPositionInMs!;
      lastPlayBackPositionInMs = book.playBackPositionInMs!;
      await _seek(Duration(milliseconds: book.playBackPositionInMs!));
    }
    if (book.id != null) {
      initTimer(book.id!);
    }
    _listenPlayerPosition();
    return audioFileMetadata!;
  }

  void initTimer(int bookId) {
    updateBookPlayBackTimer = Timer.periodic(
        const Duration(milliseconds: updateBookIntervalInMs), (_) {
      if (playBackPositionInMs != null &&
          (lastPlayBackPositionInMs == null ||
              playBackPositionInMs != lastPlayBackPositionInMs)) {
        BookManager().setBookPlayBackPositionInMs(
            bookId: bookId, playBackPositionInMs: playBackPositionInMs!);
        lastPlayBackPositionInMs = playBackPositionInMs;
      }
    });
  }

  // free up resources as audioplayer is resource-intensive
  Future<void> dispose() async {
    await playerStateSubscription?.cancel();
    updateBookPlayBackTimer?.cancel();
    // await audioPlayer.dispose();
  }

  void setSubtitles(List<Subtitle> subtitles) {
    currentSubtitles = subtitles;
  }

  int _binarySearchSubtitle(List<Subtitle> subtitles, Duration p) {
    int low = 0;
    int high = subtitles.length - 1;

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      final subtitle = subtitles[mid];
      if (p < subtitle.startDuration) {
        high = mid - 1;
      } else if (p > subtitle.endDuration) {
        low = mid + 1;
      } else {
        return mid;
      }
    }
    return -1;
  }

  void _listenPlayerPosition() {
    audioService.onPositionChanged.listen((Duration p) async {
      playBackPositionInMs = p.inMilliseconds;

      final timeRemaining = audioService.maxDuration != null
          ? Duration(
              seconds: audioService.maxDuration!.inSeconds -
                  p.inSeconds) // use seconds as millisecond diff will cause precision issue in UI
          : p;

      currentState = AudioPlayerState(
          currentPosition: p,
          timeRemaining: timeRemaining,
          playerState: audioService.playerState == null
              ? PlayerState.stopped
              : audioService.playerState!);

      _positionController.add(currentState!);

      if (currentSubtitles.isNotEmpty) {
        if (isRequireSearchSubtitle) {
          if (p >= currentSubtitles.first.startDuration &&
              p <= currentSubtitles.last.endDuration) {
            currentSubtitleIndex = _binarySearchSubtitle(currentSubtitles, p);
            if (currentSubtitleIndex != -1) {
              isRequireSearchSubtitle = false;
              final subtitleToHighlight =
                  currentSubtitles[currentSubtitleIndex];
              await Future.wait([
                ReaderJsManager()
                    .evaluateJavascript(source: removeAllHighlights()),
                ReaderJsManager().evaluateJavascript(
                    source: addNodeHighlight(subtitleToHighlight.id))
              ]);
            }
          }
        } else {
          final activeSubtitle = currentSubtitles[currentSubtitleIndex];
          if (p >= activeSubtitle.endDuration) {
            ReaderJsManager().evaluateJavascript(
                source: removeNodeHighlight(activeSubtitle.id));
          }
          if (currentSubtitleIndex + 1 < currentSubtitles.length &&
              p >= currentSubtitles[currentSubtitleIndex + 1].startDuration) {
            final nextActiveSubtitle =
                currentSubtitles[currentSubtitleIndex + 1];
            ReaderJsManager().evaluateJavascript(
                source: addNodeHighlight(nextActiveSubtitle.id));
            currentSubtitleIndex += 1;
          }
        }
      }
    });
  }

  Future<void> resetSubtitles() async {
    isRequireSearchSubtitle = true;
    await ReaderJsManager().evaluateJavascript(source: removeAllHighlights());
  }

  Future<void> _seek(Duration duration) async {
    // await Future.wait([audioPlayer.seek(duration), resetSubtitles()]);
    await Future.wait([audioService.seek(duration), resetSubtitles()]);
  }

  Future<void> seekByPercentage(double percentage) async {
    if (audioService.maxDuration != null) {
      await _seek(Duration(
          milliseconds: ((audioService.maxDuration!.inMilliseconds * percentage)
              .round())));
    }
  }

  Future<void> seekBeginning() async {
    await _seek(Duration(milliseconds: 0));
  }

  Future<void> fastForward(int seconds) async {
    if (playBackPositionInMs == null) {
      return;
    }
    await _seek(Duration(
        milliseconds: min(audioService.maxDuration?.inMilliseconds ?? 0,
            playBackPositionInMs! + seconds * 1000)));
  }

  Future<void> rewind(int seconds) async {
    if (playBackPositionInMs == null) {
      return;
    }
    await _seek(
        Duration(milliseconds: max(0, playBackPositionInMs! - seconds * 1000)));
  }
}
