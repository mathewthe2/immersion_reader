import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:immersion_reader/data/reader/audio_player_state.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/subtitle.dart';
import 'package:immersion_reader/managers/reader/book_manager.dart';
import 'package:immersion_reader/managers/reader/reader_js_manager.dart';
import 'package:immersion_reader/utils/reader/highlight_js.dart';

class AudioPlayerManager {
  final AudioPlayer audioPlayer = AudioPlayer();
  final StreamController<AudioPlayerState> _positionController =
      StreamController<AudioPlayerState>.broadcast();
  AudioPlayerState? currentState;
  StreamSubscription<PlayerState>? playerStateSubscription;
  PlayerState? _internalPlayerState;
  Metadata? audioFileMetadata;
  Duration? maxDuration;

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
  factory AudioPlayerManager() {
    if (_singleton.playerStateSubscription == null) {
      _singleton._listenInternalPlayerState();
    }
    return _singleton;
  }
  AudioPlayerManager._internal();

  Stream<AudioPlayerState> get onPositionChanged => _positionController.stream;

  Future<Metadata> setSourceFromDevice(
      {required File audioFile, required Book book}) async {
    if (audioFileMetadata != null) {
      return audioFileMetadata!;
    }
    await audioPlayer.setReleaseMode(ReleaseMode.stop);
    audioPlayer.setSource(DeviceFileSource(audioFile.path));

    if (playBackPositionInMs == null && book.playBackPositionInMs != null) {
      playBackPositionInMs = book.playBackPositionInMs!;
      lastPlayBackPositionInMs = book.playBackPositionInMs!;
      await _seek(Duration(milliseconds: book.playBackPositionInMs!));
    }
    if (book.id != null) {
      initTimer(book.id!);
    }
    _listenPlayerPosition();
    _getDuration();
    audioFileMetadata = await MetadataRetriever.fromFile(audioFile);
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
    await audioPlayer.dispose();
  }

  void setSubtitles(List<Subtitle> subtitles) {
    currentSubtitles = subtitles;
  }

  void resume() {
    audioPlayer.resume();
  }

  void _getDuration() {
    late StreamSubscription durationSubscription;
    durationSubscription = audioPlayer.onDurationChanged.listen((Duration p) {
      maxDuration = p;
      durationSubscription.cancel();
    });
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
    audioPlayer.onPositionChanged.listen((Duration p) async {
      playBackPositionInMs = p.inMilliseconds;

      final timeRemaining = maxDuration != null
          ? Duration(
              seconds: maxDuration!.inSeconds -
                  p.inSeconds) // use seconds as millisecond diff will cause precision issue in UI
          : p;

      currentState = AudioPlayerState(
          currentPosition: p,
          timeRemaining: timeRemaining,
          playerState: _internalPlayerState == null
              ? PlayerState.stopped
              : _internalPlayerState!);

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
    await Future.wait([audioPlayer.seek(duration), resetSubtitles()]);
  }

  Future<void> seekByPercentage(double percentage) async {
    if (maxDuration != null) {
      await _seek(Duration(
          milliseconds: ((maxDuration!.inMilliseconds * percentage).round())));
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
        milliseconds: min(maxDuration?.inMilliseconds ?? 0,
            playBackPositionInMs! + seconds * 1000)));
  }

  Future<void> rewind(int seconds) async {
    if (playBackPositionInMs == null) {
      return;
    }
    await _seek(
        Duration(milliseconds: max(0, playBackPositionInMs! - seconds * 1000)));
  }

  void _listenInternalPlayerState() {
    playerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((PlayerState newPlayerState) {
      _internalPlayerState = newPlayerState;
    });
  }

  bool isPlaying() {
    if (_internalPlayerState == null) {
      return false;
    } else {
      return _internalPlayerState == PlayerState.playing;
    }
  }
}
