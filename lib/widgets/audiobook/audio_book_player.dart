import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_files.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_player_state.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/extensions/duration_extension.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation_type.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_player_manager.dart';
import 'package:immersion_reader/widgets/audiobook/controls/playback_speed_picker.dart';
import 'package:immersion_reader/widgets/common/safe_state.dart';
import 'package:immersion_reader/widgets/common/text/app_text.dart';
import 'package:transparent_image/transparent_image.dart';

class AudioBookPlayer extends StatefulWidget {
  final Book book;
  const AudioBookPlayer({super.key, required this.book});

  @override
  State<AudioBookPlayer> createState() => _AudioBookPlayerState();
}

class _AudioBookPlayerState extends SafeState<AudioBookPlayer> {
  late Book book;
  AudioBookFiles? audioBookFiles;
  Metadata? audioFileMetadata;
  int currentSubtitleIndex = 0;
  double sliderValue = 0;
  bool isFetchingAudioBook = true;
  bool isPlaying = false;

  static const int fastForwardSeconds = 10;
  static const int rewindSeconds = 10;

  @override
  void initState() {
    super.initState();
    book = widget.book;
    if (book.id != null) {
      initAudioBook(book);
    }

    listenToBookIsPlaying();
    listenToBookOperations();
  }

  Future<void> initAudioBook(Book book) async {
    if (book.id == null) return;
    final audioBookFromStorage =
        await AudioPlayerManager().getAudioBook(book.id!);
    setState(() {
      audioBookFiles = audioBookFromStorage;
    });
    await Future.wait([
      AudioPlayerManager().loadSubtitlesFromFiles(
          audioBookFiles: audioBookFromStorage, bookId: book.id!),
      AudioPlayerManager()
          .loadAudioFromFiles(audioBookFiles: audioBookFromStorage, book: book),
    ]);
    setState(() {
      isFetchingAudioBook = false;
    });
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
              audioBookFiles = operation.audioBookFiles;
              audioFileMetadata = operation.metadata;
            });
          }
          break;
        case AudioBookOperationType.addSubtitleFile:
          break;
        case AudioBookOperationType.removeAudioFile:
          setState(() {
            audioBookFiles = null;
            audioFileMetadata = null;
          });
          break;
        case AudioBookOperationType.removeSubtitleFile:
          break;
      }
    });
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

  Widget _buildPlayButton() {
    if (isPlaying) {
      return CupertinoButton(
          onPressed: () {
            setState(() {
              isPlaying = false;
            });
            AudioPlayerManager().pause();
          },
          child: Icon(
            size: 36,
            CupertinoIcons.pause_solid,
          ));
    } else {
      return CupertinoButton(
          onPressed: () {
            setState(() {
              isPlaying = true;
            });
            AudioPlayerManager().autoPlay();
          },
          child: Icon(
            size: 36,
            CupertinoIcons.play_arrow_solid,
          ));
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
    if (isFetchingAudioBook) {
      return Container();
    }
    if (audioBookFiles == null || audioBookFiles!.audioFiles.isEmpty) {
      return Center(child: AppText("No audio file selected"));
    }
    return CupertinoScrollbar(
        child: SingleChildScrollView(
            child: Column(children: [
      SizedBox(height: context.spacer()),
      AppText("Beta: This feature is still work in progress"),
      SizedBox(height: context.spacer()),
      SizedBox(
          height: context.epic(),
          child: Image.memory(audioFileMetadata?.albumArt != null
              ? audioFileMetadata!.albumArt!
              : kTransparentImage)),
      SizedBox(height: context.spacer()),
      AppText(audioFileMetadata?.trackName ?? ""),
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
      if (audioBookFiles != null && audioBookFiles!.audioFiles.isNotEmpty)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
                onPressed: AudioPlayerManager().seekBeginning,
                child: Icon(
                  CupertinoIcons.backward_end_fill,
                )),
            CupertinoButton(
                onPressed: () => AudioPlayerManager().rewind(rewindSeconds),
                child: Icon(
                  CupertinoIcons.refresh_bold,
                )),
            _buildPlayButton(),
            CupertinoButton(
                onPressed: () =>
                    AudioPlayerManager().fastForward(fastForwardSeconds),
                child: Icon(
                  CupertinoIcons.refresh,
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
