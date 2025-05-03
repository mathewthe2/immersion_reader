import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_operation.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_player_state.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/subtitle.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_player_handler.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_service_handler.dart';
import 'package:immersion_reader/managers/reader/book_manager.dart';
import 'package:immersion_reader/managers/reader/reader_js_manager.dart';
import 'package:immersion_reader/utils/folder_utils.dart';
import 'package:immersion_reader/utils/reader/highlight_js.dart';

// Flutter UI should only interface with this manager for audio
class AudioPlayerManager {
  final StreamController<AudioPlayerState> _positionController =
      StreamController<AudioPlayerState>.broadcast();
  final StreamController<AudioBookOperation> _audioBookOperationController =
      StreamController<
          AudioBookOperation>.broadcast(); // broadcast book operations
  AudioPlayerState? currentState;
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

  Stream<AudioBookOperation> get onBookOperation =>
      _audioBookOperationController.stream;

  AudioServiceHandler get audioService =>
      AudioPlayerHandler().audioServiceHandler;

  Future<void> loadAudioBookIfExists(Book book) async {
    if (book.id != null &&
        book.playBackPositionInMs != null &&
        book.playBackPositionInMs! > 0) {
      final audioBookFiles = await FolderUtils.getAudioBook(book.id!);

      if (audioBookFiles.subtitleFiles.isNotEmpty) {
        currentSubtitles = await Subtitle.readSubtitlesFromFile(
            file: audioBookFiles.subtitleFiles.first,
            webController: ReaderJsManager().webController);
        isRequireSearchSubtitle = true;
        await _insertSubtitleHighlight(
            p: Duration(milliseconds: book.playBackPositionInMs!),
            isCueToElement: false);
      }
    }
  }

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
            duration: audioFileMetadata!.trackDuration != null
                ? Duration(milliseconds: audioFileMetadata!.trackDuration!)
                : null,
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

  Future<void> dispose() async {
    updateBookPlayBackTimer?.cancel();
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

  Future<void> _insertSubtitleHighlight(
      {required Duration p, isCueToElement = true}) async {
    if (currentSubtitles.isNotEmpty) {
      if (isRequireSearchSubtitle) {
        if (p >= currentSubtitles.first.startDuration &&
            p <= currentSubtitles.last.endDuration) {
          currentSubtitleIndex = _binarySearchSubtitle(currentSubtitles, p);
          if (currentSubtitleIndex != -1) {
            isRequireSearchSubtitle = false;
            final subtitleToHighlight = currentSubtitles[currentSubtitleIndex];
            await Future.wait([
              ReaderJsManager()
                  .evaluateJavascript(source: removeAllHighlights()),
              ReaderJsManager().evaluateJavascript(
                  source: addNodeHighlight(
                      id: subtitleToHighlight.id,
                      isCueToElement: isCueToElement))
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
          final nextActiveSubtitle = currentSubtitles[currentSubtitleIndex + 1];
          ReaderJsManager().evaluateJavascript(
              source: addNodeHighlight(
                  id: nextActiveSubtitle.id, isCueToElement: isCueToElement));
          currentSubtitleIndex += 1;
        }
      }
    }
  }

  void _listenPlayerPosition() {
    audioService.onPositionChanged.listen((Duration p) async {
      updatePlayerState(p);
      playBackPositionInMs = p.inMilliseconds;
      await _insertSubtitleHighlight(p: p);
    });
  }

  void updatePlayerState(Duration p) {
    final timeRemaining = audioService.maxDuration != null
        ? Duration(
            seconds: audioService.maxDuration!.inSeconds -
                p.inSeconds) // use seconds as millisecond diff will cause precision issue in UI
        : Duration.zero;
    currentState = AudioPlayerState(
        currentPosition: p,
        timeRemaining: timeRemaining,
        playerState: audioService.playerState == null
            ? PlayerState.stopped
            : audioService.playerState!);

    _positionController.add(currentState!);
  }

  Future<void> resetSubtitles() async {
    isRequireSearchSubtitle = true;
    await ReaderJsManager().evaluateJavascript(source: removeAllHighlights());
  }

  Future<void> _seek(Duration duration) async {
    await Future.wait([audioService.seek(duration), resetSubtitles()]);
    updatePlayerState(duration);
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

  void broadcastOperation(AudioBookOperation operation) =>
      _audioBookOperationController.add(operation);
}
