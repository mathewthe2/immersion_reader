import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_files.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_lookup_subtitle.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_player_state.dart';
import 'package:immersion_reader/data/reader/audio_book/subtitle/subtitles_data.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/audio_book/subtitle/subtitle.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation_type.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_player_manager.dart';
import 'package:immersion_reader/managers/reader/reader_js_manager.dart';
import 'package:immersion_reader/widgets/audiobook/controls/playback_speed_picker.dart';
import 'package:immersion_reader/widgets/common/safe_state.dart';
import 'package:immersion_reader/widgets/common/text/app_text.dart';
import 'package:immersion_reader/widgets/common/text/multi_style_text.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AudioBookSubtitles extends StatefulWidget {
  final Book book;
  final String? lookupSubtitleId;
  const AudioBookSubtitles(
      {super.key, required this.book, this.lookupSubtitleId});

  @override
  State<AudioBookSubtitles> createState() => _AudioBookSubtitlesState();
}

class _AudioBookSubtitlesState extends SafeState<AudioBookSubtitles> {
  late Book book;
  AudioBookFiles? audioBookFiles;
  SubtitlesData subtitlesData =
      SubtitlesData(subtitles: [], indexToSubIndexMap: {});
  bool isFetchingSubtitles = false;
  bool isScrolling = false;
  bool isPlaying = false;

  AudioLookupSubtitle? lookupSubtitle;

  int? initialSubtitleIndex;
  bool isScrollToInitialSubtitle = false;
  int? currentSubtitleIndex;

  bool isScrollAnimation = Platform.isIOS;

  late Color textColor;
  late Color dimmedTextColor;
  late Color highlightBackgroundColor;

  static const double subtitleFontSize = 20;

  // scroll list
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  int? getRelativeSubtitleIndex(String rawSubtitleIndex) {
    return subtitlesData.getSubIndexByIndex(rawSubtitleIndex);
  }

  Widget subtitleText({required Subtitle subtitle, required int index}) {
    if (initialSubtitleIndex == index &&
        lookupSubtitle != null &&
        lookupSubtitle!.highlightedText.isNotEmpty) {
      lookupSubtitle!.textIndex + lookupSubtitle!.textLength!;
      String prefix = lookupSubtitle!.textIndex > 0
          ? subtitle.text.substring(0, lookupSubtitle!.textIndex)
          : "";
      String suffix = lookupSubtitle!.textIndex + lookupSubtitle!.textLength! <
              (subtitle.text.length - 1)
          ? subtitle.text.substring(
              lookupSubtitle!.textIndex + lookupSubtitle!.textLength!,
              subtitle.text.length)
          : "";

      return MultiStyleText([
        (prefix, TextStyle(color: textColor, fontSize: subtitleFontSize)),
        (
          lookupSubtitle!.highlightedText,
          TextStyle(
              color: textColor,
              backgroundColor: highlightBackgroundColor,
              fontSize: subtitleFontSize),
        ),
        (suffix, TextStyle(color: textColor, fontSize: subtitleFontSize)),
      ]);
    }
    final isDimmed = (initialSubtitleIndex != index) &&
        (!isPlaying || currentSubtitleIndex != index);
    return MultiStyleText([
      (
        subtitle.text,
        TextStyle(
            color: isDimmed ? dimmedTextColor : textColor,
            fontSize: subtitleFontSize)
      )
    ]);
  }

  Widget item({required Subtitle subtitle, required int index}) {
    return SizedBox(
        child: Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: GestureDetector(
                onTap: () async {
                  isScrollToInitialSubtitle = false;
                  if (index != initialSubtitleIndex) {
                    initialSubtitleIndex = null; // reset initial subtitle
                  }
                  await AudioPlayerManager().playSubtitleByIndex(index);
                  if (AudioPlayerManager().currentState?.playerState !=
                      PlayerState.playing) {
                    await AudioPlayerManager().audioService.play();
                  }
                },
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: subtitleText(subtitle: subtitle, index: index)))));
  }

  Widget list({required List<Subtitle> subtitles}) =>
      ScrollablePositionedList.builder(
          itemCount: subtitles.length,
          itemBuilder: (context, index) =>
              index >= 0 && index < subtitles.length
                  ? item(subtitle: subtitles[index], index: index)
                  : Container(),
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          scrollOffsetController: scrollOffsetController,
          reverse: false,
          scrollDirection: Axis.vertical);

  @override
  void initState() {
    super.initState();
    book = widget.book;
    if (widget.lookupSubtitleId != null) {
      if (ReaderJsManager().lastLookupSubtitleData?.subtitleId ==
          widget.lookupSubtitleId) {
        lookupSubtitle = ReaderJsManager().lastLookupSubtitleData;
      }
      isScrollToInitialSubtitle = true;
    }
    initSubtitles(book);
    listenToBookIsPlaying();
    listenToBookOperations();
  }

  Future<void> initSubtitles(Book book) async {
    if (book.id == null && !book.isHaveSubtitles) return;
    setState(() {
      audioBookFiles = book.audioBookFiles;
      subtitlesData = AudioPlayerManager().getSubtitlesData(book.id!);
    });
  }

  void scrollToSubtitle(int subtitleIndex) {
    if (itemScrollController.isAttached &&
        !isScrolling &&
        subtitleIndex < subtitlesData.subtitles.length) {
      if (isScrollAnimation) {
        // scroll to subtitle on ios
        setState(() {
          isScrolling = true;
        });
        itemScrollController.scrollTo(
            index: subtitleIndex,
            duration: Duration(milliseconds: 1500),
            curve: Curves.easeInOutCubic);
        Future.delayed(const Duration(milliseconds: 1500), () {
          setState(() {
            isScrolling = false;
          });
        });
      } else {
        // on android, skip scroll animation
        itemScrollController.jumpTo(index: subtitleIndex);
      }
    }
  }

  void listenToBookIsPlaying() {
    AudioPlayerManager()
        .onPositionChanged
        .listen((AudioPlayerState playerState) {
      if (!isScrollToInitialSubtitle && playerState.currentSubtitleIndex >= 0) {
        setState(() {
          currentSubtitleIndex = playerState.currentSubtitleIndex;
          isPlaying = playerState.playerState == PlayerState.playing;
        });
        if (AudioPlayerManager().isAutoPlay) {
          scrollToSubtitle(playerState.currentSubtitleIndex);
        }
      }
    });
  }

  void listenToBookOperations() {
    AudioPlayerManager()
        .onBookOperation
        .listen((AudioBookOperation operation) async {
      switch (operation.type) {
        case AudioBookOperationType.addSubtitleFile:
          if (operation.subtitlesData != null) {
            setState(() {
              subtitlesData = operation.subtitlesData!;
              currentSubtitleIndex = operation.currentSubtitleIndex;
              isFetchingSubtitles = false;
            });
            if (isScrollToInitialSubtitle && widget.lookupSubtitleId != null) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                final subtitleIndex =
                    getRelativeSubtitleIndex(widget.lookupSubtitleId!);
                if (subtitleIndex != null) {
                  late Timer jumpToSubtitleTimer;
                  jumpToSubtitleTimer = Timer(Duration(milliseconds: 100), () {
                    if (itemScrollController.isAttached) {
                      itemScrollController.jumpTo(index: subtitleIndex);
                      jumpToSubtitleTimer.cancel();
                    }
                  });
                }

                initialSubtitleIndex = subtitleIndex;
              });
            }
          }
          break;
        case AudioBookOperationType.removeSubtitleFile:
          setState(() {
            subtitlesData.reset();
            currentSubtitleIndex = null;
            isFetchingSubtitles = false;
          });
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    textColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.black,
            darkColor: CupertinoColors.systemGroupedBackground),
        context);

    dimmedTextColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.systemGrey,
            darkColor: CupertinoColors.systemGrey2),
        context);

    highlightBackgroundColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: Color(0xffffe694), darkColor: Color(0xff254d4c)),
        context);

    if (isFetchingSubtitles) {
      return Container();
    }
    if (subtitlesData.subtitles.isEmpty) {
      return Center(child: AppText("No subtitles"));
    }
    return Padding(
        padding: context.verticalPadding(),
        child: Column(
          children: [
            Padding(
                padding: context.horizontalPadding(),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [PlaybackSpeedPicker()])),
            Expanded(
                child: Padding(
                    padding: context.verticalPadding(),
                    child: list(subtitles: subtitlesData.subtitles))),
          ],
        ));
  }
}
