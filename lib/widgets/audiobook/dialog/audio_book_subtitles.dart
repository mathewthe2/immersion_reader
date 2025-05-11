import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_lookup_subtitle.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_player_state.dart';
import 'package:immersion_reader/data/reader/audio_book/subtitle/subtitles_data.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/audio_book/subtitle/subtitle.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
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
  final int? subtitleIndex;
  final SubtitlesData? subtitlesData;
  const AudioBookSubtitles(
      {super.key,
      required this.book,
      this.subtitlesData,
      this.lookupSubtitleId,
      this.subtitleIndex});

  @override
  State<AudioBookSubtitles> createState() => _AudioBookSubtitlesState();
}

class _AudioBookSubtitlesState extends SafeState<AudioBookSubtitles> {
  late Book book;
  bool isScrolling = false;
  bool isPlaying = false;

  AudioLookupSubtitle? lookupSubtitle;

  int? initialSubtitleIndex;
  bool isScrollToInitialSubtitle = false;
  bool isHighlightInitialSubtitle = true;

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

  List<Subtitle> get subtitles =>
      widget.subtitlesData == null ? [] : widget.subtitlesData!.subtitles;

  int? getRelativeSubtitleIndex(String rawSubtitleIndex) {
    return widget.subtitlesData?.getSubIndexByIndex(rawSubtitleIndex);
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

    final isHighlightedSubtitle =
        (initialSubtitleIndex == index && isHighlightInitialSubtitle) ||
            (isPlaying && currentSubtitleIndex == index);
    return MultiStyleText([
      (
        subtitle.text,
        TextStyle(
            color: isHighlightedSubtitle ? textColor : dimmedTextColor,
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
                  isHighlightInitialSubtitle = false;
                  if (index != initialSubtitleIndex) {
                    initialSubtitleIndex = null; // reset initial subtitle
                  }
                  await AudioPlayerManager().playSubtitleByIndex(index);
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

    currentSubtitleIndex = widget.subtitleIndex;
    if (widget.lookupSubtitleId != null) {
      if (ReaderJsManager().lastLookupSubtitleData?.subtitleId ==
          widget.lookupSubtitleId) {
        lookupSubtitle = ReaderJsManager().lastLookupSubtitleData;
      }
      isScrollToInitialSubtitle = true;
    }
    initSubtitles(book);
    listenToBookIsPlaying();
  }

  Future<void> initSubtitles(Book book) async {
    if (book.id == null && !book.isHaveSubtitles) return;
    scrollToInitialSubtitleIfExists();
  }

  void scrollToInitialSubtitleIfExists() {
    initialSubtitleIndex = AudioPlayerManager().currentSubtitleIndex;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final bool isHaveLookupFromSubtitle = isScrollToInitialSubtitle &&
          widget.lookupSubtitleId != null &&
          getRelativeSubtitleIndex(widget.lookupSubtitleId!) != null;
      if (isHaveLookupFromSubtitle) {
        initialSubtitleIndex =
            getRelativeSubtitleIndex(widget.lookupSubtitleId!)!;
      }
      late Timer jumpToSubtitleTimer;
      jumpToSubtitleTimer = Timer(Duration(milliseconds: 100), () {
        if (itemScrollController.isAttached && initialSubtitleIndex! >= 0) {
          itemScrollController.jumpTo(index: initialSubtitleIndex!);
          jumpToSubtitleTimer.cancel();
        }
      });
    });
  }

  void scrollToSubtitle(int subtitleIndex) {
    if (itemScrollController.isAttached &&
        !isScrolling &&
        widget.subtitlesData != null &&
        subtitleIndex < widget.subtitlesData!.subtitles.length) {
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
          isHighlightInitialSubtitle = false;
          scrollToSubtitle(playerState.currentSubtitleIndex);
        }
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

    if (subtitles.isEmpty) {
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
                    padding: context.horizontalPadding(),
                    child: list(subtitles: subtitles))),
          ],
        ));
  }
}
