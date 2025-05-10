import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_files.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_player_state.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/extensions/duration_extension.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_player_manager.dart';
import 'package:immersion_reader/widgets/audiobook/controls/playback_speed_picker.dart';
import 'package:immersion_reader/widgets/common/safe_state.dart';
import 'package:immersion_reader/widgets/common/text/app_text.dart';
import 'package:transparent_image/transparent_image.dart';

class AudioBookPlayer extends StatefulWidget {
  final Book book;
  final AudioBookFiles? audioBookFiles;
  final Metadata? audioFileMetadata;
  const AudioBookPlayer(
      {super.key,
      required this.book,
      this.audioBookFiles,
      this.audioFileMetadata});

  @override
  State<AudioBookPlayer> createState() => _AudioBookPlayerState();
}

class _AudioBookPlayerState extends SafeState<AudioBookPlayer> {
  int currentSubtitleIndex = 0;
  double sliderValue = 0;
  late bool isPlaying;

  static const int fastForwardSeconds = 10;
  static const int rewindSeconds = 10;

  @override
  void initState() {
    super.initState();
    isPlaying = AudioPlayerManager().isPlaying;
  }

  Widget _buildTimeDisplay(AudioPlayerState? playerState) {
    if (playerState != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(playerState.currentPosition.toHumanString()),
          AppText(playerState.timeRemaining.toHumanString()),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _buildPlayButton({Color? color}) {
    if (isPlaying) {
      return CupertinoButton(
          onPressed: () {
            setState(() {
              isPlaying = false;
            });
            AudioPlayerManager().pause();
          },
          child: Icon(size: 36, CupertinoIcons.pause_solid, color: color));
    } else {
      return CupertinoButton(
          onPressed: () {
            setState(() {
              isPlaying = true;
            });
            AudioPlayerManager().autoPlay();
          },
          child: Icon(size: 36, CupertinoIcons.play_arrow_solid, color: color));
    }
  }

  Widget _buildProgress(AudioPlayerState? playerState) {
    if (playerState == null ||
        playerState.playbackPercentage == null ||
        playerState.playbackPercentage! > 1) {
      return Slider(value: 0, onChanged: (_) {});
    }
    return Slider(
        value: playerState.playbackPercentage!,
        onChanged: (value) => AudioPlayerManager().seekByPercentage(value));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioBookFiles == null ||
        widget.audioBookFiles!.audioFiles.isEmpty) {
      return Center(child: AppText("No audio file selected"));
    }
    Color controlColor = context.color(
        lightMode: CupertinoColors.darkBackgroundGray,
        darkMode: CupertinoColors.systemGroupedBackground);

    return CupertinoScrollbar(
        child: SingleChildScrollView(
            child: Column(children: [
      SizedBox(height: context.whitespace()),
      SizedBox(
          height: context.epic(),
          child: Image.memory(widget.audioFileMetadata?.albumArt != null
              ? widget.audioFileMetadata!.albumArt!
              : kTransparentImage)),
      SizedBox(height: context.spacer()),
      AppText(widget.audioFileMetadata?.trackName ??
          widget.book.title), // TODO: for long text, animate left displacement
      SizedBox(height: context.spacer()),
      SliderTheme(
          data: SliderThemeData(
              thumbColor: CupertinoColors.activeOrange,
              activeTrackColor: CupertinoColors.activeOrange,
              inactiveTrackColor: CupertinoColors.secondarySystemFill,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5)),
          child: StreamBuilder<AudioPlayerState>(
              stream: AudioPlayerManager().onPositionChanged,
              builder: (context, streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.active) {
                  return _buildProgress(streamSnapshot.data!);
                } else {
                  return _buildProgress(AudioPlayerManager().currentState);
                }
              })),
      Padding(
        padding: context.horizontalPadding(),
        child: StreamBuilder<AudioPlayerState>(
            stream: AudioPlayerManager().onPositionChanged,
            builder: (context, streamSnapshot) {
              if (streamSnapshot.connectionState == ConnectionState.active) {
                return _buildTimeDisplay(streamSnapshot.data!);
              } else {
                return _buildTimeDisplay(AudioPlayerManager().currentState);
              }
            }),
      ),
      if (widget.audioBookFiles != null &&
          widget.audioBookFiles!.audioFiles.isNotEmpty)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
                onPressed: AudioPlayerManager().seekBeginning,
                child: Icon(
                  CupertinoIcons.backward_end_fill,
                  color: controlColor,
                )),
            CupertinoButton(
                onPressed: () => AudioPlayerManager().rewind(rewindSeconds),
                child: Icon(
                  CupertinoIcons.backward_fill,
                  color: controlColor,
                )),
            _buildPlayButton(color: controlColor),
            CupertinoButton(
                onPressed: () =>
                    AudioPlayerManager().fastForward(fastForwardSeconds),
                child: Icon(
                  CupertinoIcons.forward_fill,
                  color: controlColor,
                )),
            CupertinoButton(
                onPressed: () {},
                child: Icon(
                  CupertinoIcons.forward_end_fill,
                  color: CupertinoColors.inactiveGray,
                )),
          ],
        ),
      Row(children: [
        Padding(
            padding: context.horizontalPadding(), child: PlaybackSpeedPicker())
      ]),
    ])));
  }
}
