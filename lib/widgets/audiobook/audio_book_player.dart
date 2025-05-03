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
import 'package:immersion_reader/widgets/common/text/app_text.dart';
import 'package:transparent_image/transparent_image.dart';

class AudioBookPlayer extends StatefulWidget {
  final Book book;
  const AudioBookPlayer({super.key, required this.book});

  @override
  State<AudioBookPlayer> createState() => _AudioBookPlayerState();
}

class _AudioBookPlayerState extends State<AudioBookPlayer> {
  late Book book;
  AudioBookFiles? audioBookFiles;
  Metadata? audioFileMetadata = AudioPlayerManager().audioFileMetadata;
  int currentSubtitleIndex = 0;
  double sliderValue = 0;
  bool isFetchingAudioBook = true;
  bool isPlaying = false;

  int _selectedSpeed = 2;

  static const List<double> playBackRates = [0.5, 0.7, 1.0, 1.2, 1.5, 1.7, 2.0];

  static const double _kItemExtent = 32.0;

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
    // final audioBookFromStorage = await loadAudioBook(book.id!);
    final audioBookFromStorage =
        await AudioPlayerManager().getAudioBook(book.id!);
    if (mounted) {
      setState(() {
        audioBookFiles = audioBookFromStorage;
      });
    }
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
      if (mounted) {
        setState(() {
          isPlaying = (playerState.playerState == PlayerState.playing);
        });
      }
    });
  }

  void listenToBookOperations() {
    AudioPlayerManager()
        .onBookOperation
        .listen((AudioBookOperation operation) async {
      switch (operation.type) {
        case AudioBookOperationType.addAudioFile:
          if (mounted && operation.metadata != null) {
            setState(() {
              audioBookFiles = operation.audioBookFiles;
              audioFileMetadata = operation.metadata;
            });
          }
          break;
        case AudioBookOperationType.addSubtitleFile:
          break;
        case AudioBookOperationType.removeAudioFile:
          if (mounted) {
            setState(() {
              audioBookFiles = null;
              audioFileMetadata = null;
            });
          }
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
            AudioPlayerManager().audioService.pause();
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
            AudioPlayerManager().audioService.play();
          },
          child: Icon(
            size: 36,
            CupertinoIcons.play_arrow_solid,
          ));
    }
  }

  Widget _buildProgress(AudioPlayerState? playerState) {
    if (playerState == null || playerState.playbackPercentage == null) {
      return Slider(value: 0, onChanged: (_) {});
    }
    return Slider(
        value: playerState.playbackPercentage!,
        onChanged: (value) => AudioPlayerManager().seekByPercentage(value));
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(top: false, child: child),
      ),
    );
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
      Row(
        children: [
          Padding(
              padding: context.horizontalPadding(),
              child: GestureDetector(
                  onTap: () => _showDialog(CupertinoPicker(
                        magnification: 1.22,
                        squeeze: 1.2,
                        useMagnifier: true,
                        itemExtent: _kItemExtent,
                        scrollController: FixedExtentScrollController(
                            initialItem: _selectedSpeed),
                        onSelectedItemChanged: (int selectedItem) {
                          setState(() {
                            _selectedSpeed = selectedItem;
                          });
                          AudioPlayerManager()
                              .audioService
                              .setPlaybackRate(playBackRates[selectedItem]);
                        },
                        children: playBackRates
                            .map((rate) => Text(rate.toString()))
                            .toList(),
                      )),
                  child: Column(
                    children: [
                      AppText("Speed: ${playBackRates[_selectedSpeed]}",
                          style: TextStyle(fontSize: 12))
                    ],
                  )))
        ],
      ),
    ])));
  }
}
