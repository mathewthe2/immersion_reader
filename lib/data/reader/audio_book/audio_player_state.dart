import 'package:audioplayers/audioplayers.dart';

class AudioPlayerState {
  Duration currentPosition;
  Duration timeRemaining;
  PlayerState playerState;
  int currentSubtitleIndex;

  AudioPlayerState(
      {required this.currentPosition,
      required this.timeRemaining,
      required this.playerState,
      required this.currentSubtitleIndex});

  double? get playbackPercentage {
    final totalTime =
        currentPosition.inMilliseconds + timeRemaining.inMilliseconds;
    if (totalTime == 0) {
      return null;
    }
    return currentPosition.inMilliseconds / totalTime;
  }
}
