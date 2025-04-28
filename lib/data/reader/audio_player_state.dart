import 'package:audioplayers/audioplayers.dart';

class AudioPlayerState {
  Duration currentPosition;
  Duration timeRemaining;
  PlayerState playerState;

  AudioPlayerState(
      {required this.currentPosition,
      required this.timeRemaining,
      required this.playerState});

  double get playbackPercentage =>
      currentPosition.inMilliseconds /
      (currentPosition.inMilliseconds + timeRemaining.inMilliseconds);
}
