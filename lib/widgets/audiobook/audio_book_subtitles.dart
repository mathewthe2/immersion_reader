import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_files.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_player_state.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/subtitle.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation_type.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_player_manager.dart';
import 'package:immersion_reader/widgets/common/text/app_text.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AudioBookSubtitles extends StatefulWidget {
  final Book book;
  const AudioBookSubtitles({super.key, required this.book});

  @override
  State<AudioBookSubtitles> createState() => _AudioBookSubtitlesState();
}

class _AudioBookSubtitlesState extends State<AudioBookSubtitles> {
  late Book book;
  AudioBookFiles? audioBookFiles;
  List<Subtitle> subtitles = [];
  bool isFetchingSubtitles = true;
  bool isScrolling = false;
  bool isPlaying = false;
  int? currentSubtitleIndex;
  int? lastClickedSubtitleIndex;

  // scroll list
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();

  Widget item({required Subtitle subtitle, required int index}) {
    return SizedBox(
        child: Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: GestureDetector(
                onTap: () async {
                  lastClickedSubtitleIndex = index;
                  scrollToSubtitle(index);
                  await AudioPlayerManager().playSubtitleByIndex(index);
                  await AudioPlayerManager().audioService.play();
                },
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppText(
                      subtitle.text,
                      textAlign: TextAlign.left,
                      isHighlight: isPlaying && currentSubtitleIndex == index,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    )))));
  }

  Widget list({required List<Subtitle> subtitles}) =>
      ScrollablePositionedList.builder(
          itemCount: subtitles.length,
          itemBuilder: (context, index) =>
              item(subtitle: subtitles[index], index: index),
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          scrollOffsetController: scrollOffsetController,
          reverse: false,
          scrollDirection: Axis.vertical);

  @override
  void initState() {
    super.initState();
    book = widget.book;
    initSubtitles(book);
    listenToBookIsPlaying();
    listenToBookOperations();
  }

  Future<void> initSubtitles(Book book) async {
    if (book.id == null) return;
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
  }

  void scrollToSubtitle(int subtitleIndex) {
    if (mounted &&
        itemScrollController.isAttached &&
        !isScrolling &&
        subtitleIndex < subtitles.length) {
      setState(() {
        isScrolling = true;
      });
      itemScrollController.scrollTo(
          index: subtitleIndex,
          duration: Duration(milliseconds: 1500),
          curve: Curves.easeInOutCubic);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            isScrolling = false;
          });
        }
      });
    }
  }

  void listenToBookIsPlaying() {
    AudioPlayerManager()
        .onPositionChanged
        .listen((AudioPlayerState playerState) {
      if (mounted) {
        setState(() {
          currentSubtitleIndex = playerState.currentSubtitleIndex;
          isPlaying = playerState.playerState == PlayerState.playing;
        });
        scrollToSubtitle(playerState.currentSubtitleIndex);
      }
    });
  }

  void listenToBookOperations() {
    AudioPlayerManager()
        .onBookOperation
        .listen((AudioBookOperation operation) async {
      switch (operation.type) {
        case AudioBookOperationType.addSubtitleFile:
          if (mounted) {
            setState(() {
              subtitles = operation.subtitles ?? [];
              currentSubtitleIndex = operation.currentSubtitleIndex;
              isFetchingSubtitles = false;
            });
          }
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isFetchingSubtitles) {
      return Container();
    }
    if (!isFetchingSubtitles && subtitles.isEmpty) {
      return Center(child: AppText("No subtitles"));
    }
    return Column(
      children: [
        SizedBox(height: context.spacer()),
        AppText("Beta: This feature is still work in progress"),
        SizedBox(height: context.spacer()),
        SizedBox(
          height: context.hero(),
          child: list(subtitles: subtitles),
        )
      ],
    );
  }
}
