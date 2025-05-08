import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_player_state.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation_type.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_player_manager.dart';
import 'package:immersion_reader/managers/reader/reader_js_manager.dart';
import 'package:immersion_reader/widgets/common/safe_state.dart';
import 'package:immersion_reader/widgets/common/text/app_text.dart';
import 'package:transparent_image/transparent_image.dart';

class BottomPlaybackControls extends StatefulWidget {
  final Color backgroundColor;
  const BottomPlaybackControls({super.key, required this.backgroundColor});

  @override
  State<BottomPlaybackControls> createState() => _BottomPlaybackControlsState();
}

class _BottomPlaybackControlsState extends SafeState<BottomPlaybackControls> {
  Metadata? audioFileMetadata;
  int? bookId;
  String? bookTitle;
  bool isPlaying = false;

  static const int fastForwardSeconds = 10;
  static const int rewindSeconds = 10;

  @override
  void initState() {
    super.initState();
    listenToBookIsPlaying();
    listenToBookOperations();
  }

  void listenToBookIsPlaying() {
    AudioPlayerManager()
        .onPositionChanged
        .listen((AudioPlayerState playerState) {
      setState(() {
        isPlaying = (playerState.playerState == PlayerState.playing);
      });
    });
  }

  void listenToBookOperations() {
    AudioPlayerManager()
        .onBookOperation
        .listen((AudioBookOperation operation) async {
      switch (operation.type) {
        case AudioBookOperationType.addAudioFile:
          if (operation.metadata != null) {
            setState(() {
              audioFileMetadata = operation.metadata;
              bookTitle = operation.bookTitle;
            });
          }
          if (operation.bookId != null) {
            setState(() {
              bookId = operation.bookId;
            });
          }
          break;
        case AudioBookOperationType.removeAudioFile:
          setState(() {
            audioFileMetadata = null;
          });
          break;
        default:
          break;
      }
    });
  }

  Widget _buildPlayButton({required Color color}) {
    if (isPlaying) {
      return CupertinoButton(
          padding: EdgeInsets.symmetric(vertical: 0),
          onPressed: () {
            setState(() {
              isPlaying = false;
            });
            AudioPlayerManager().pause();
          },
          child: Icon(
            size: 36,
            color: color,
            CupertinoIcons.pause_solid,
          ));
    } else {
      return CupertinoButton(
          padding: EdgeInsets.symmetric(vertical: 0),
          onPressed: () {
            setState(() {
              isPlaying = true;
            });
            AudioPlayerManager().autoPlay();
          },
          child: Icon(
            size: 36,
            color: color,
            CupertinoIcons.play_arrow_solid,
          ));
    }
  }

  Widget _buildProgress(
      {AudioPlayerState? playerState, Color? color, Color? backgroundColor}) {
    if (playerState == null ||
        playerState.playbackPercentage == null ||
        playerState.playbackPercentage! > 1) {
      return LinearProgressIndicator(
          value: 0, color: color, backgroundColor: backgroundColor);
    }
    return LinearProgressIndicator(
        value: playerState.playbackPercentage!,
        color: color,
        backgroundColor: backgroundColor);
  }

  @override
  Widget build(BuildContext context) {
    if (audioFileMetadata == null) {
      return Container();
    }

    Color backgroundColor = context.color(
        lightMode: CupertinoColors.extraLightBackgroundGray,
        darkMode: CupertinoColors.darkBackgroundGray);

    Color controlColor = context.color(
        lightMode: CupertinoColors.darkBackgroundGray,
        darkMode: CupertinoColors.systemGroupedBackground);

    Color progressColor = context.color(
        lightMode: CupertinoColors.activeOrange,
        darkMode: CupertinoColors.activeOrange);

    Color progressBackgroundColor = context.color(
        lightMode: CupertinoColors.tertiaryLabel,
        darkMode: CupertinoColors.secondarySystemFill);

    return GestureDetector(
        onTap: () {
          if (bookId != null) {
            ReaderJsManager().openAudioBookDialog(bookId: bookId!);
          }
        },
        child: Container(
            height: context.bar(),
            color: backgroundColor,
            child: Column(children: [
              Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    Row(children: [
                      Row(children: [
                        Padding(
                            padding: EdgeInsets.only(top: 5, bottom: 5),
                            child: SizedBox(
                                child: Image.memory(
                                    audioFileMetadata?.albumArt != null
                                        ? audioFileMetadata!.albumArt!
                                        : kTransparentImage))),
                        Padding(
                            padding: EdgeInsets.only(left: context.spacer()),
                            child: Container(
                                constraints: BoxConstraints(maxWidth: 100),
                                child: AppText(
                                  audioFileMetadata?.trackName ??
                                      bookTitle ??
                                      "",
                                  overflow: TextOverflow.ellipsis,
                                )))
                      ])
                    ]),
                    Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: SizedBox(
                            width: context.epic(),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CupertinoButton(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 0),
                                      onPressed: () => AudioPlayerManager()
                                          .rewind(rewindSeconds),
                                      child: Icon(
                                        CupertinoIcons.backward_fill,
                                        color: controlColor,
                                      )),
                                  _buildPlayButton(color: controlColor),
                                  CupertinoButton(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 0),
                                      onPressed: () => AudioPlayerManager()
                                          .fastForward(fastForwardSeconds),
                                      child: Icon(CupertinoIcons.forward_fill,
                                          color: controlColor)),
                                ]))),
                  ])),
              StreamBuilder<AudioPlayerState>(
                  stream: AudioPlayerManager().onPositionChanged,
                  builder: (context, streamSnapshot) {
                    if (streamSnapshot.connectionState ==
                        ConnectionState.active) {
                      return _buildProgress(
                          playerState: streamSnapshot.data!,
                          color: progressColor,
                          backgroundColor: progressBackgroundColor);
                    } else {
                      return _buildProgress(
                          playerState: AudioPlayerManager().currentState,
                          color: progressColor,
                          backgroundColor: progressBackgroundColor);
                    }
                  }),
            ])));
  }
}
