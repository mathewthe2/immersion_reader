import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:immersion_reader/data/reader/audio_book_files.dart';
import 'package:immersion_reader/data/reader/audio_player_state.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/subtitle.dart';
import 'package:immersion_reader/extensions/duration_extension.dart';
import 'package:immersion_reader/managers/reader/audio_player_manager.dart';
import 'package:immersion_reader/managers/reader/reader_js_manager.dart';
import 'package:immersion_reader/utils/folder_utils.dart';
import 'package:transparent_image/transparent_image.dart';

class AudioBookPlayer extends StatefulWidget {
  final Book book;
  const AudioBookPlayer({super.key, required this.book});

  @override
  State<AudioBookPlayer> createState() => _AudioBookPlayerState();
}

class _AudioBookPlayerState extends State<AudioBookPlayer> {
  late Book book;
  List<Subtitle> subtitles = [];
  AudioBookFiles? audioBook;
  Metadata? audioFileMetadata = AudioPlayerManager().audioFileMetadata;
  int currentSubtitleIndex = 0;
  double sliderValue = 0;

  int _selectedSpeed = 2;

  static const List<double> playBackRates = [0.5, 0.7, 1.0, 1.2, 1.5, 1.7, 2.0];

  static const double _kItemExtent = 32.0;

  static const int fastForwardSeconds = 10;
  static const int rewindSeconds = 10;

  @override
  void initState() {
    super.initState();
    book = widget.book;
    initAudioBook();
  }

  Future<void> initAudioBook() async {
    if (book.id != null) {
      final audioBookFromStorage = await FolderUtils.getAudioBook(book.id!);
      setState(() {
        audioBook = audioBookFromStorage;
      });
      if (audioBookFromStorage.audioFiles.isEmpty) {
        return;
      }
      Metadata metadata = await AudioPlayerManager().setSourceFromDevice(
          audioFile: audioBookFromStorage.audioFiles.first, book: book);

      setState(() {
        audioFileMetadata = metadata;
      });

      subtitles = await Subtitle.readSubtitlesFromFile(
          file: audioBookFromStorage
              .subtitleFiles.first, // assume only one subtitle file for now
          webController: ReaderJsManager().webController);

      AudioPlayerManager().setSubtitles(subtitles);
    }
  }

  Widget _buildTimeDisplay(AudioPlayerState? playerState) {
    if (playerState != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(playerState.currentPosition.toHumanString()),
          Text(playerState.timeRemaining.toHumanString()),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _buildPlayButton(PlayerState? playerState) {
    if (playerState != null && playerState == PlayerState.playing) {
      return CupertinoButton(
          onPressed: AudioPlayerManager().audioPlayer.pause,
          child: Icon(
            size: 36,
            CupertinoIcons.pause_solid,
          ));
    } else {
      return CupertinoButton(
          onPressed: AudioPlayerManager().audioPlayer.resume,
          child: Icon(
            size: 36,
            CupertinoIcons.play_arrow_solid,
          ));
    }
  }

  Widget _buildProgress(AudioPlayerState? playerState) {
    if (playerState == null) {
      return Slider(value: 0, onChanged: (_) {});
    }
    return Slider(
        value: playerState.playbackPercentage,
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
    if (audioBook == null || audioBook!.audioFiles.isEmpty) {
      return Center(child: Text("No audio file selected"));
    }
    return Column(children: [
      SizedBox(height: 20),
      Text("Beta: This feature is still work in progress"),
      SizedBox(height: 20),
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 200,
          child: Image.memory(audioFileMetadata?.albumArt != null
              ? audioFileMetadata!.albumArt!
              : kTransparentImage)),
      SizedBox(height: 10),
      Text(audioFileMetadata?.trackName ?? ""),
      SizedBox(height: 30),
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
        padding: EdgeInsets.only(left: 24, right: 24),
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
      if (audioBook != null && audioBook!.audioFiles.isNotEmpty)
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
            StreamBuilder<AudioPlayerState>(
                stream: AudioPlayerManager().onPositionChanged,
                builder: (context, streamSnapshot) {
                  if (streamSnapshot.connectionState ==
                      ConnectionState.active) {
                    return _buildPlayButton(streamSnapshot.data!.playerState);
                  }
                  return _buildPlayButton(
                      AudioPlayerManager().currentState?.playerState);
                }),
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
              padding: EdgeInsets.only(left: 20),
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
                              .audioPlayer
                              .setPlaybackRate(playBackRates[selectedItem]);
                        },
                        children: playBackRates
                            .map((rate) => Text(rate.toString()))
                            .toList(),
                      )),
                  child: Column(
                    children: [
                      Text("Speed: ${playBackRates[_selectedSpeed]}",
                          style: TextStyle(fontSize: 12))
                    ],
                  )))
        ],
      ),
    ]);
  }
}
