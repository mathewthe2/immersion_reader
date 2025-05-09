import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_files.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_load_params.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_player_state.dart';
import 'package:immersion_reader/data/reader/audio_book/subtitle/subtitles_data.dart';
import 'package:immersion_reader/data/reader/audio_book/subtitle/subtitle.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_player_handler.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_service_handler.dart';
import 'package:immersion_reader/managers/reader/book_manager.dart';
import 'package:immersion_reader/managers/reader/reader_js_manager.dart';
import 'package:immersion_reader/utils/common/loading_dialog.dart';
import 'package:immersion_reader/utils/common/repeat_timer.dart';
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

  // update book's playback position
  int? currentBookId;
  Timer? updateBookPlayBackTimer;
  int? lastPlayBackPositionInMs;

  // subtitles
  SubtitlesData currentSubtitlesData = SubtitlesData.empty;
  int? playBackPositionInMs;
  int currentSubtitleIndex = 0;
  bool isRequireSearchSubtitle = true;
  bool isAutoPlay = true;
  Duration? playerEndDuration;
  bool isHighlightedInitialSubtitle = false;

  final Map<int, AudioBookOperation> _cachedBookOperationData = {};
  final Map<int, AudioBookFiles> _cachedAudioBooks =
      {}; // subtitle and audio files for books

  List<Subtitle> get currentSubtitles => currentSubtitlesData.subtitles;

  Metadata? getAudioMetadata(int? bookId) =>
      _cachedBookOperationData[bookId]?.metadata;

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

  // invoked when book is loaded
  // loads both audio files and subtitle files
  Future<void> loadAudioBookIfExists(AudioBookLoadParams params) async {
    // remove existing audio book files
    broadcastOperation(AudioBookOperation.removeAudioFile);
    broadcastOperation(AudioBookOperation.removeSubtitleFile);

    isHighlightedInitialSubtitle = false;

    if (params.bookId != null && params.playBackPositionInMs != null) {
      LoadingDialog().showLoadingDialog(msg: "Loading audiobok...");

      // fetch audiobook data
      final audioBookFiles = await FolderUtils.getAudioBook(params.bookId!);
      await Future.wait([
        loadSubtitlesFromFiles(
            audioBookFiles: audioBookFiles, bookId: params.bookId!),
        loadAudioFromFiles(
            audioBookFiles: audioBookFiles,
            bookId: params.bookId,
            bookTitle: params.bookTitle,
            playBackPositionInMs: params.playBackPositionInMs),
      ]);

      // set up manager with new data
      currentBookId = params.bookId;
      lastPlayBackPositionInMs = params.playBackPositionInMs!;
      updatePlayerState(Duration(milliseconds: params.playBackPositionInMs!));
      initTimer();
      isRequireSearchSubtitle = true;
      // wait for reader to resize before inserting initial subtitle
      repeatTimer(
          frequency: Duration(milliseconds: 100),
          timeout: Duration(seconds: 2),
          fireOnce: true,
          callback: (timer) async {
            if (ReaderJsManager().isReaderResized) {
              await _insertSubtitleHighlight(
                  p: Duration(milliseconds: params.playBackPositionInMs!),
                  isCueToElement:
                      false); // bookmarks are more accurate than subtitles, so we don't have to cue intially
              isHighlightedInitialSubtitle = true;
              LoadingDialog().dismissLoadingDialog();
            }
          },
          timeoutCallback: () => LoadingDialog().dismissLoadingDialog());
    }
  }

  AudioBookOperation _cachedOperationData(int bookId) {
    if (!_cachedBookOperationData.containsKey(bookId)) {
      _cachedBookOperationData[bookId] = AudioBookOperation.addDummyAudioFile();
    }
    return _cachedBookOperationData[bookId]!;
  }

  Future<Metadata> setSourceFromDevice(
      {required AudioBookFiles audioBookFiles,
      required int bookId,
      String? bookTitle,
      int? newPlaybackPosition}) async {
    if (_cachedBookOperationData[bookId]?.metadata == null &&
        audioBookFiles.isHaveAudio) {
      final metadata =
          await MetadataRetriever.fromFile(audioBookFiles.audioFile!);
      _cachedOperationData(bookId).metadata = metadata;
      _cachedOperationData(bookId).audioBookFiles = audioBookFiles;
    }
    final cachedMetadata = _cachedBookOperationData[bookId]!.metadata!;
    if (currentBookId == bookId) {
      return cachedMetadata;
    }
    currentBookId = bookId;

    final imageUri =
        await FolderUtils().createImageUriFromBytes(cachedMetadata.albumArt!);

    if (audioBookFiles.isHaveAudio) {
      audioService.setSource(DeviceFileSource(audioBookFiles.audioFile!.path),
          customMediaItem: MediaItem(
              id: cachedMetadata.trackName ?? bookTitle ?? "",
              title: cachedMetadata.trackName ?? bookTitle ?? "",
              artist: cachedMetadata.authorName ?? bookTitle ?? "",
              duration: cachedMetadata.trackDuration != null
                  ? Duration(milliseconds: cachedMetadata.trackDuration!)
                  : null,
              artUri: imageUri));
    }

    if (newPlaybackPosition != null) {
      playBackPositionInMs = newPlaybackPosition;
      lastPlayBackPositionInMs = newPlaybackPosition;
      await _seek(Duration(milliseconds: newPlaybackPosition));
    }

    return cachedMetadata;
  }

  void initTimer() {
    if (updateBookPlayBackTimer != null) {
      updateBookPlayBackTimer!.cancel(); // cancel existing timer
    }
    updateBookPlayBackTimer = Timer.periodic(
        const Duration(milliseconds: updateBookIntervalInMs), (_) {
      if (currentBookId != null &&
          playBackPositionInMs != null &&
          (lastPlayBackPositionInMs == null ||
              playBackPositionInMs != lastPlayBackPositionInMs)) {
        BookManager().setBookPlayBackPositionInMs(
            bookId: currentBookId!,
            playBackPositionInMs: playBackPositionInMs!);
        lastPlayBackPositionInMs = playBackPositionInMs;
      }
    });
  }

  void disposeIfNotRunning() async {
    if (AudioPlayerHandler().isInitialized &&
        audioService.playerState != PlayerState.playing) {
      _dispose();
    }
  }

  void _dispose() {
    updateBookPlayBackTimer?.cancel();
    audioService.dispose();
    currentBookId = null;
    currentState = null;
    lastPlayBackPositionInMs = null;
    currentSubtitlesData = SubtitlesData.empty;
    playBackPositionInMs = null;
    // retain book data cache
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
    if (currentSubtitlesData.subtitles.isNotEmpty) {
      if (isRequireSearchSubtitle) {
        if (p >= currentSubtitles.first.startDuration &&
            p <= currentSubtitles.last.endDuration) {
          currentSubtitleIndex = _binarySearchSubtitle(currentSubtitles, p);
          if (currentSubtitleIndex != -1) {
            isRequireSearchSubtitle = false;
            final subtitleToHighlight = currentSubtitles[currentSubtitleIndex];
            await ReaderJsManager().evaluateJavascript(
                source: addNodeHighlight(
                    id: subtitleToHighlight.id,
                    isCueToElement: isCueToElement));
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

  void _listenPlayerPosition(int bookId) {
    late StreamSubscription playerPositionSubscription;
    playerPositionSubscription =
        audioService.onPositionChanged.listen((Duration p) async {
      if (bookId != currentBookId) {
        playerPositionSubscription.cancel();
        return;
      }
      if (playerEndDuration != null && p >= playerEndDuration! && !isAutoPlay) {
        await audioService.pause();
        playerEndDuration = null;
        return;
      }
      updatePlayerState(p);
      playBackPositionInMs = p.inMilliseconds;
      if (isHighlightedInitialSubtitle) {
        await _insertSubtitleHighlight(p: p);
      }
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

  Metadata? getAudioBookMetadata(int bookId) {
    if (_cachedBookOperationData.containsKey(bookId)) {
      return _cachedBookOperationData[bookId]!.metadata;
    }
    return null;
  }

  SubtitlesData getSubtitlesData(int bookId) {
    if (_cachedBookOperationData.containsKey(bookId)) {
      return _cachedBookOperationData[bookId]!.subtitlesData ??
          SubtitlesData.empty;
    }
    return SubtitlesData.empty;
  }

  void onResetMatches() {
    isRequireSearchSubtitle = true;
  }

  Future<void> loadSubtitlesFromFiles(
      {required AudioBookFiles audioBookFiles,
      required int bookId,
      isRefetch = false}) async {
    SubtitlesData subtitlesData = SubtitlesData.empty;
    if (!isRefetch &&
        _cachedBookOperationData.containsKey(bookId) &&
        _cachedBookOperationData[bookId]!.subtitlesData != null) {
      subtitlesData = _cachedBookOperationData[bookId]!.subtitlesData!;
      currentSubtitlesData = subtitlesData;
    } else if (audioBookFiles.subtitleFiles.isNotEmpty) {
      subtitlesData = await SubtitlesData.readSubtitlesFromFile(
          file: audioBookFiles
              .subtitleFiles.first, // assume only one subtitle file for now
          webController: ReaderJsManager().webController);
      currentSubtitlesData = subtitlesData;
      _cachedOperationData(bookId).subtitlesData = subtitlesData;
    }
    _cachedAudioBooks[bookId] = audioBookFiles;
    broadcastOperation(AudioBookOperation.addSubtitleFile(
        subtitlesData: subtitlesData,
        currentSubtitleIndex: currentSubtitleIndex));
  }

  Future<void> removeSubtitlesFromFiles() async {
    await resetActiveSubtitle();
    _cachedBookOperationData.updateAll(
        (_, op) => op.cleanup(AudioBookDataRemovalType.subtitleData));
    _cachedAudioBooks.updateAll((_, bookFiles) =>
        AudioBookFiles(subtitleFiles: [], audioFiles: bookFiles.audioFiles));
    broadcastOperation(AudioBookOperation.removeSubtitleFile);
  }

  Future<void> loadAudioFromFiles(
      {required AudioBookFiles audioBookFiles,
      required int? bookId,
      required int? playBackPositionInMs,
      String? bookTitle,
      isRefetch = false}) async {
    if (bookId == null) return;
    // use cache
    if (!isRefetch &&
        bookId == currentBookId &&
        _cachedBookOperationData.containsKey(bookId) &&
        _cachedBookOperationData[bookId]!.metadata != null &&
        _cachedBookOperationData[bookId]!.audioBookFiles != null) {
      broadcastOperation(AudioBookOperation.addAudioFile(
          metadata: _cachedBookOperationData[bookId]!.metadata!,
          bookTitle: bookTitle,
          audioBookFiles: _cachedBookOperationData[bookId]!.audioBookFiles!));
    } else {
      if (audioBookFiles.audioFiles.isNotEmpty) {
        Metadata metadata = await setSourceFromDevice(
            audioBookFiles: audioBookFiles,
            bookId: bookId,
            bookTitle: bookTitle,
            newPlaybackPosition: playBackPositionInMs);

        _cachedOperationData(bookId).metadata = metadata;
        _cachedOperationData(bookId).audioBookFiles = audioBookFiles;
        _cachedAudioBooks[bookId] = audioBookFiles;

        broadcastOperation(AudioBookOperation.addAudioFile(
            metadata: metadata,
            audioBookFiles: audioBookFiles,
            bookId: bookId,
            bookTitle: bookTitle));
      }
    }
    initTimer();
    _listenPlayerPosition(bookId);
  }

  Future<void> removeAudioFromFiles() async {
    _cachedBookOperationData
        .updateAll((_, op) => op.cleanup(AudioBookDataRemovalType.audioData));
    _cachedAudioBooks.updateAll((_, bookFiles) =>
        AudioBookFiles(subtitleFiles: bookFiles.subtitleFiles, audioFiles: []));
    broadcastOperation(AudioBookOperation.removeSubtitleFile);
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
    if (currentState?.playerState == PlayerState.playing) {
      await audioService.pause();
    }
  }

  Future<void> _seek(Duration duration) async {
    await resetActiveSubtitle();
    await audioService.seek(duration);
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
