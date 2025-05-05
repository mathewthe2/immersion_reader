import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_files.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_player_state.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/subtitle.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation_type.dart';
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
  bool isAutoPlay = true;
  Duration? playerEndDuration;

  final Map<int, AudioBookOperation> _cachedBookOperationData = {};
  final Map<int, AudioBookFiles> _cachedAudioBooks =
      {}; // subtitle and audio files for books

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
      if (playerEndDuration != null && p >= playerEndDuration!) {
        await audioService.pause();
        playerEndDuration = null;
        return;
      }
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
        currentSubtitleIndex: currentSubtitleIndex,
        playerState: audioService.playerState == null
            ? PlayerState.stopped
            : audioService.playerState!);

    _positionController.add(currentState!);
  }

  Future<AudioBookFiles> getAudioBook(int bookId) async {
    if (!_cachedAudioBooks.containsKey(bookId)) {
      _cachedAudioBooks[bookId] = await FolderUtils.getAudioBook(bookId);
    }
    return _cachedAudioBooks[bookId]!;
  }

  Future<void> loadSubtitlesFromFiles(
      {required AudioBookFiles audioBookFiles,
      required int bookId,
      isRefetch = false}) async {
    List<Subtitle> subtitles = [];
    if (!isRefetch &&
        _cachedBookOperationData.containsKey(bookId) &&
        _cachedBookOperationData[bookId]!.subtitles != null) {
      subtitles = _cachedBookOperationData[bookId]!.subtitles!;
      currentSubtitles = subtitles;
    } else if (audioBookFiles.subtitleFiles.isNotEmpty) {
      subtitles = await Subtitle.readSubtitlesFromFile(
          file: audioBookFiles
              .subtitleFiles.first, // assume only one subtitle file for now
          webController: ReaderJsManager().webController);
      currentSubtitles = subtitles;
      if (!_cachedBookOperationData.containsKey(bookId)) {
        _cachedBookOperationData[bookId] = AudioBookOperation(
            type: AudioBookOperationType
                .addSubtitleFile); // type does not matter for cache
      }
      _cachedBookOperationData[bookId]!.subtitles = subtitles;
    }
    _cachedAudioBooks[bookId] = audioBookFiles;
    broadcastOperation(AudioBookOperation.addSubtitleFile(
        subtitles: subtitles, currentSubtitleIndex: currentSubtitleIndex));
  }

  Future<void> removeSubtitlesFromFiles() async {
    await resetActiveSubtitle();
    _cachedBookOperationData.clear();
    _cachedAudioBooks.clear();
    broadcastOperation(AudioBookOperation.removeSubtitleFile);
  }

  Future<void> loadAudioFromFiles(
      {required AudioBookFiles audioBookFiles,
      required Book book,
      isRefetch = false}) async {
    if (book.id == null) return;

    // use cache
    if (!isRefetch &&
        _cachedBookOperationData.containsKey(book.id) &&
        _cachedBookOperationData[book.id]!.metadata != null &&
        _cachedBookOperationData[book.id]!.audioBookFiles != null) {
      broadcastOperation(AudioBookOperation.addAudioFile(
          metadata: _cachedBookOperationData[book.id]!.metadata!,
          audioBookFiles: _cachedBookOperationData[book.id]!.audioBookFiles!));
    } else {
      if (audioBookFiles.audioFiles.isNotEmpty) {
        Metadata metadata = await setSourceFromDevice(
            audioFile: audioBookFiles.audioFiles.first, book: book);

        if (!_cachedBookOperationData.containsKey(book.id)) {
          _cachedBookOperationData[book.id!] = AudioBookOperation(
              type: AudioBookOperationType
                  .addAudioFile); // type does not matter for cache
        }
        _cachedBookOperationData[book.id]!.metadata = metadata;
        _cachedBookOperationData[book.id]!.audioBookFiles = audioBookFiles;
        _cachedAudioBooks[book.id!] = audioBookFiles;

        broadcastOperation(AudioBookOperation.addAudioFile(
            metadata: metadata, audioBookFiles: audioBookFiles));
      }
    }
  }

  Future<void> removeAudioFromFiles() async {
    _cachedBookOperationData.clear();
    _cachedAudioBooks.clear();
    broadcastOperation(AudioBookOperation.removeAudioFile);
  }

  Future<void> resetActiveSubtitle() async {
    isRequireSearchSubtitle = true;
    await ReaderJsManager().evaluateJavascript(source: removeAllHighlights());
  }

  Future<void> autoPlay() async {
    isAutoPlay = true;
    await audioService.play();
  }

  Future<void> pause() async {
    await audioService.pause();
  }

  Future<void> _seek(Duration duration) async {
    await Future.wait([audioService.seek(duration), resetActiveSubtitle()]);
    updatePlayerState(duration);
  }

  Future<void> _seekWithEnd(
      {required Duration startDuration, required Duration endDuration}) async {
    isAutoPlay = false;
    playerEndDuration = endDuration;
    await Future.wait(
        [audioService.seek(startDuration), resetActiveSubtitle()]);
    updatePlayerState(startDuration);
  }

  Future<void> seekByPercentage(double percentage) async {
    if (audioService.maxDuration != null) {
      await _seek(Duration(
          milliseconds: ((audioService.maxDuration!.inMilliseconds * percentage)
              .round())));
    }
  }

  Future<void> playSubtitleByIndex(int subtitleIndex) async {
    if (subtitleIndex < currentSubtitles.length) {
      _seekWithEnd(
          startDuration: currentSubtitles[subtitleIndex].startDuration,
          endDuration: currentSubtitles[subtitleIndex].endDuration);
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
