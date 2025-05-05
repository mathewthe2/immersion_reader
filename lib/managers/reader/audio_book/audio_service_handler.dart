import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

// Defines the audioplayer and how it extends audio_service, for interfacing with the device's system player
class AudioServiceHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  PlayerState? playerState;
  Duration? currentPosition;

  Duration? maxDuration;

  Future<void> setup() async {
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> setSource(Source source, {MediaItem? customMediaItem}) async {
    await _player.setSource(source);
    if (customMediaItem?.duration != null) {
      maxDuration = customMediaItem!.duration!;
    }
    mediaItem.add(customMediaItem);
    queue.add([customMediaItem!]);

    onPlayerStateChanged.listen((PlayerState newPlayerState) {
      playerState = newPlayerState;
      playbackState.add(PlaybackState(
          controls: [
            MediaControl.fastForward,
            MediaControl.rewind,
            newPlayerState == PlayerState.playing
                ? MediaControl.pause
                : MediaControl.play,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [
            0,
            1,
            3
          ],
          updatePosition:
              currentPosition != null ? currentPosition! : Duration(seconds: 0),
          processingState: AudioProcessingState.ready, // TODO: change later
          queueIndex: 0,
          playing: newPlayerState == PlayerState.playing));
    });
    onPositionChanged.listen((position) {
      currentPosition = position;
    });
  }

  double getPlaybackRate() {
    return _player.playbackRate;
  }

  Future<void> setPlaybackRate(double playbackRate) async {
    await _player.setPlaybackRate(playbackRate);
  }

  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;

  void _updateDevicePlayerPosition() {
    if (currentPosition != null) {
      playbackState
          .add(playbackState.value.copyWith(updatePosition: currentPosition!));
    }
  }

  @override
  Future<void> play() => _player.resume();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    currentPosition = position;
    _updateDevicePlayerPosition();
  }

  @override
  Future<void> skipToPrevious() => seek(Duration.zero);

  // Future<void> skipToQueueItem(int i) => _player.seek(Duration.zero);
}
