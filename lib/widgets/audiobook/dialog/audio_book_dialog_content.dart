import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_files.dart';
import 'package:immersion_reader/data/reader/audio_book/subtitle/subtitles_data.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation_type.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_player_manager.dart';
import 'package:immersion_reader/managers/reader/book_manager.dart';
import 'package:immersion_reader/utils/folder_utils.dart';
import 'package:immersion_reader/widgets/audiobook/dialog/audio_book_matching.dart';
import 'package:immersion_reader/widgets/audiobook/dialog/audio_book_player.dart';
import 'package:immersion_reader/widgets/audiobook/dialog/audio_book_subtitles.dart';
import 'package:immersion_reader/widgets/common/safe_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioBookDialogContent extends StatefulWidget {
  final SharedPreferences? sharedPreferences;
  final int? initialTabIndex;
  final StreamController<int> matchProgressController;
  final Book book;
  const AudioBookDialogContent({
    super.key,
    this.sharedPreferences,
    this.initialTabIndex,
    required this.book,
    required this.matchProgressController,
  });

  @override
  State<AudioBookDialogContent> createState() => _AudioBookDialogContentState();
}

class _AudioBookDialogContentState extends SafeState<AudioBookDialogContent> {
  static const String audioBookDialogTag = "audio_book_dialog_tag";
  static const String tabPreferenceKey = 'audio_book_dialog_tab';

  late Book book;
  bool isFetchingAudioBook = false;
  bool isPlaying = false;
  AudioBookFiles? audioBookFiles;
  Metadata? audioFileMetadata;
  SubtitlesData? subtitlesData;
  int? subtitleIndex;

  @override
  void initState() {
    super.initState();
    book = widget.book;
    listenToBookOperations();
    init();
  }

  Future<void> init() async {
    if (book.id == null) return;
    final updatedBook = await BookManager().getBookById(book.id!);
    if (updatedBook == null) return;
    setState(() {
      book = updatedBook;
      audioBookFiles = updatedBook.audioBookFiles;
      audioFileMetadata = updatedBook.audioFileMetadata;
      subtitlesData = updatedBook.subtitlesData;
    });
  }

  // get existing audio files if exist
  Future<AudioBookFiles?> getAudioBook() async {
    if (book.id == null) return null;
    setState(() {
      isFetchingAudioBook = true;
    });
    final newAudioBook = await FolderUtils.getAudioBook(book.id!);
    setState(() {
      audioBookFiles = newAudioBook;
      isFetchingAudioBook = false;
    });
    return newAudioBook;
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
          if (operation.subtitlesData != null) {
            setState(() {
              audioBookFiles = operation.audioBookFiles;
              subtitlesData = operation.subtitlesData!;
              subtitleIndex = operation.currentSubtitleIndex;
            });
          }
          break;
        case AudioBookOperationType.removeAudioFile:
          setState(() {
            audioBookFiles = null;
            audioFileMetadata = null;
          });
          break;
        case AudioBookOperationType.removeSubtitleFile:
          setState(() {
            subtitlesData?.reset();
            subtitleIndex = null;
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        direction: DismissDirection.down,
        key: UniqueKey(),
        resizeDuration: Duration(milliseconds: 100),
        onDismissed: (_) => SmartDialog.dismiss(tag: audioBookDialogTag),
        child: Container(
            height: context.popupFull(),
            width: context.screenWidth,
            color: CupertinoColors.white,
            child: HeroControllerScope.none(
                child: CupertinoTabScaffold(
              backgroundColor: context.color(
                  lightMode: CupertinoColors.extraLightBackgroundGray,
                  darkMode: CupertinoColors.darkBackgroundGray),
              tabBar: CupertinoTabBar(
                activeColor: context.color(
                    lightMode: CupertinoColors.darkBackgroundGray,
                    darkMode: CupertinoColors.white),
                onTap: (newIndex) => widget.sharedPreferences
                    ?.setInt(tabPreferenceKey, newIndex),
                currentIndex: widget.initialTabIndex ??
                    widget.sharedPreferences?.getInt(tabPreferenceKey) ??
                    0,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.folder_open),
                      label: 'Subtitle Matcher'),
                  BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.headphones), label: 'Player'),
                  BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.doc_text_search),
                      label: 'Subtitles'),
                ],
              ),
              tabBuilder: (BuildContext context, int index) {
                return CupertinoTabView(
                  builder: (BuildContext context) {
                    switch (index) {
                      case 0:
                        return AudioBookMatching(
                            audioBookFiles: audioBookFiles,
                            matchProgressController:
                                widget.matchProgressController,
                            book: book);
                      case 1:
                        return AudioBookPlayer(
                          book: book,
                          audioBookFiles: audioBookFiles,
                          audioFileMetadata: audioFileMetadata,
                          isPlaying: isPlaying,
                        );
                      case 2:
                        return AudioBookSubtitles(
                            book: book,
                            subtitlesData: subtitlesData,
                            subtitleIndex: subtitleIndex);
                      default:
                        return Container();
                    }
                  },
                );
              },
            ))));
  }
}
