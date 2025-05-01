import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_match_result.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_files.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_operation.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/subtitle.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/extensions/file_extension.dart';
import 'package:immersion_reader/extensions/list_extension.dart';
import 'package:immersion_reader/extensions/string_extension.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_player_manager.dart';
import 'package:immersion_reader/managers/reader/book_manager.dart';
import 'package:immersion_reader/managers/reader/reader_js_manager.dart';
import 'package:immersion_reader/utils/book/book_files.dart';
import 'package:immersion_reader/utils/folder_utils.dart';
import 'package:immersion_reader/utils/reader/match_js.dart';
import 'package:immersion_reader/widgets/common/buttons/app_button.dart';
import 'package:immersion_reader/widgets/common/buttons/app_secondary_button.dart';
import 'package:immersion_reader/widgets/common/text/app_text.dart';
import 'package:immersion_reader/widgets/common/buttons/app_icon_button.dart';
import 'package:immersion_reader/widgets/common/text/multi_color_text.dart';

class AudioBookMatching extends StatefulWidget {
  final Book book;
  final StreamController<int> matchProgressController;
  const AudioBookMatching({
    super.key,
    required this.matchProgressController,
    required this.book,
  });

  @override
  State<AudioBookMatching> createState() => _AudioBookMatchingState();
}

class _AudioBookMatchingState extends State<AudioBookMatching> {
  late Book book;
  List<String> textNodes = [];
  bool alignBeginningVisible = false;
  int selectedTextNodeIndex = 0;
  AudioBookFiles? audioBook;
  bool isFetchingAudioBook = true;

  bool isMatching = false;
  AudioBookMatchResult? matchResult;
  int previouslyMatchedSubtitles = 0;

  StreamController<int>? matchProgressController;

  static const int maxTextNodesToSelect = 300;
  static const int maxTextLengthToShow = 20;
  static const int textNodeWindow = 10;

  @override
  void initState() {
    super.initState();
    book = widget.book;
    matchProgressController = widget.matchProgressController;
    init();
  }

  Future<void> onAddSubtitle() async {
    if (book.id == null) return;
    String? newFilePath = await FolderUtils.addSubtitleFile(book.id!);
    if (newFilePath != null) {
      await getAudioBook();
    }
    AudioPlayerManager().broadcastOperation(AudioBookOperation.addSubtitleFile);
  }

  Future<void> onAddAudioFile() async {
    if (book.id == null) return;
    String? newFilePath = await FolderUtils.addAudioFile(book.id!);
    if (newFilePath != null) {
      await getAudioBook();
      AudioPlayerManager().broadcastOperation(AudioBookOperation.addAudioFile);
    }
  }

  Future<void> init() async {
    if (book.matchedSubtitles != null && book.matchedSubtitles! > 0) {
      previouslyMatchedSubtitles = book.matchedSubtitles!;
    } else {
      await getAudioBook();
    }
  }

  // get existing audio files if exist
  Future<void> getAudioBook() async {
    if (book.id == null) return;
    final newAudioBook = await FolderUtils.getAudioBook(book.id!);
    setState(() {
      audioBook = newAudioBook;
      isFetchingAudioBook = false;
    });
  }

  Future<void> onAlignTextBeginning() async {
    if (alignBeginningVisible) {
      setState(() {
        alignBeginningVisible = false;
      });
    } else {
      final result = await ReaderJsManager()
          .webController
          .evaluateJavascript(source: getTextNodes);
      if (result != null) {
        setState(() {
          textNodes = List<String>.from(result);
          alignBeginningVisible = true;
        });
      }
    }
  }

  Future<void> removeSubtitleFiles() async {
    if (book.id == null) return;
    await FolderUtils.removeSubtitleFilesForBook(book.id!);
    if (audioBook != null) {
      setState(() {
        audioBook = AudioBookFiles(
            subtitleFiles: [], audioFiles: audioBook!.audioFiles);
      });
    }
    AudioPlayerManager()
        .broadcastOperation(AudioBookOperation.removeSubtitleFile);
  }

  Future<void> removeAudioFiles() async {
    if (book.id == null) return;
    await FolderUtils.removeAudioFilesForBook(book.id!);
    await BookManager()
        .setBookPlayBackPositionInMs(bookId: book.id!, playBackPositionInMs: 0);
    if (audioBook != null) {
      setState(() {
        audioBook = AudioBookFiles(
            subtitleFiles: audioBook!.subtitleFiles, audioFiles: []);
      });
    }
    AudioPlayerManager().broadcastOperation(AudioBookOperation.removeAudioFile);
  }

  Future<void> onStartMatching() async {
    if (audioBook == null) {
      return;
    }

    setState(() {
      isMatching = true;
      alignBeginningVisible = false;
    });

    List<Subtitle> subtitles = await Subtitle.readSubtitlesFromFile(
        file: audioBook!.subtitleFiles.first,
        webController: ReaderJsManager().webController);

    final result = await ReaderJsManager().callAsyncJavaScript(
        functionBody: startMatch(
            nodeIndex: selectedTextNodeIndex,
            subtitles: subtitles,
            elementHtml: book.originalHtmlContent));
    setState(() {
      isMatching = false;
    });

    if (result != null && result.value != null && book.id != null) {
      setState(() {
        matchResult = AudioBookMatchResult(
            bookId: book.id!,
            elementHtml: result.value["elementHtml"] ?? "",
            htmlBackup: result.value["htmlBackup"] ?? "",
            matchedSubtitles: result.value["matchedSubtitles"]?.round() ?? 0,
            lineMatchRate: result.value["lineMatchRate"] ?? "",
            bookSubtitleDiffRate: result.value["bookSubtitleDiffRate"] ?? "");
      });
    }
  }

  Future<void> applyMatches() async {
    if (matchResult != null) {
      await Future.wait([
        BookFiles.updateBookContentHtml(matchResult!),
        BookManager().updateBookMatchedSubtitles(
            matchedSubtitles: matchResult!.matchedSubtitles,
            bookId: matchResult!.bookId)
      ]);
      await ReaderJsManager().reloadReader();
      setState(() {
        previouslyMatchedSubtitles = matchResult!.matchedSubtitles;
      });
      book.matchedSubtitles = matchResult!.matchedSubtitles;
    }
  }

  Future<void> resetMatches() async {
    if (book.id != null) {
      await BookFiles.restoreBookContentHtmlFromBackup(book.id!);
      await ReaderJsManager().reloadReader();
      await getAudioBook();
      await resetSubtitles();
    }
  }

  Future<void> resetSubtitles() async {
    previouslyMatchedSubtitles = 0;
    if (book.matchedSubtitles != null) {
      book.matchedSubtitles = 0;
    }
    if (book.id != null) {
      await BookManager()
          .updateBookMatchedSubtitles(bookId: book.id!, matchedSubtitles: 0);
    }
  }

  Color getColorForTextNodeSelection(int index) {
    if (index % 2 == 0) {
      return CupertinoColors.extraLightBackgroundGray;
    } else {
      return CupertinoColors.white;
    }
  }

  selectTextNode(int index) {
    setState(() {
      selectedTextNodeIndex = index;
    });
  }

  Widget formatTextNode(index) {
    if (textNodes[index].length < maxTextLengthToShow &&
        index < textNodes.length - textNodeWindow) {
      return MultiColorText([
        (
          textNodes[index].truncateTo(maxTextLengthToShow),
          CupertinoColors.black
        ),
        (
          textNodes
              .sublist(index + 1, index + textNodeWindow)
              .join("")
              .truncateTo(maxTextLengthToShow - textNodes[index].length),
          CupertinoColors.inactiveGray
        ),
      ]);
    }
    return MultiColorText([
      (textNodes[index].truncateTo(maxTextLengthToShow), CupertinoColors.black)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: context.spacer()),
      AppText("Audio Book Matching (Beta)", style: TextStyle(fontSize: 20)),
      if (previouslyMatchedSubtitles > 0)
        Column(
          children: [
            SizedBox(height: context.epic()),
            AppText('Matched lines: $previouslyMatchedSubtitles'),
            SizedBox(height: context.spacer()),
            AppSecondaryButton(
              label: 'Reset',
              onPressed: resetMatches,
            ),
          ],
        ),
      if (previouslyMatchedSubtitles == 0)
        Column(
          children: [
            if ((audioBook == null && !isFetchingAudioBook) ||
                (audioBook != null && audioBook!.audioFiles.isEmpty))
              AppButton(
                  label: 'Add audio file (.mp3/.m4a)',
                  onPressed: onAddAudioFile),
            if (audioBook != null && audioBook!.audioFiles.isNotEmpty)
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                AppText(
                    audioBook!.audioFiles.map((file) => file.name).join("")),
                AppIconButton(
                  CupertinoIcons.trash,
                  onPressed: removeAudioFiles,
                ),
              ]),
            if ((audioBook == null && !isFetchingAudioBook) ||
                (audioBook != null && audioBook!.subtitleFiles.isEmpty))
              AppButton(
                label: 'Add subtitle file (.srt)',
                onPressed: onAddSubtitle,
              ),
            if (audioBook != null && audioBook!.subtitleFiles.isNotEmpty)
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                AppText(
                    audioBook!.subtitleFiles.map((file) => file.name).join("")),
                AppIconButton(CupertinoIcons.trash,
                    onPressed: removeSubtitleFiles),
              ]),
            AppButton(
                label: 'Align beginning of text',
                onPressed: onAlignTextBeginning),
            if (alignBeginningVisible && textNodes.isNotEmpty)
              SizedBox(
                  height: context.epic(),
                  child: CupertinoScrollbar(
                      child: SingleChildScrollView(
                          child: Column(
                    children: [
                      ...textNodes.truncateTo(maxTextNodesToSelect).mapIndexed((
                            index,
                            textNode,
                          ) =>
                              CupertinoListTile(
                                  title: formatTextNode(index),
                                  onTap: () => selectTextNode(index),
                                  trailing: index == selectedTextNodeIndex
                                      ? Icon(
                                          size: 22,
                                          CupertinoIcons.check_mark,
                                          color: CupertinoColors.activeBlue)
                                      : null,
                                  backgroundColor:
                                      getColorForTextNodeSelection(index)))
                    ],
                  )))),
            if (!alignBeginningVisible &&
                textNodes.isNotEmpty &&
                selectedTextNodeIndex > 0)
              AppText("Beginning aligned"),
            AppButton(
              label: 'Start matching',
              onPressed: onStartMatching,
            ),
            if (isMatching && matchProgressController != null)
              StreamBuilder<int>(
                  stream: matchProgressController!.stream,
                  builder: (context, streamSnapshot) {
                    if (streamSnapshot.connectionState ==
                        ConnectionState.active) {
                      return AppText('${streamSnapshot.data!}%');
                    }
                    return Container();
                  }),
            if (!isMatching &&
                matchResult != null &&
                matchResult!.lineMatchRate.isNotEmpty &&
                matchResult!.bookSubtitleDiffRate.isNotEmpty)
              Column(
                children: [
                  AppText("Line match rate: ${matchResult!.lineMatchRate}"),
                  AppText(
                      "Book diff rate ${matchResult!.bookSubtitleDiffRate}"),
                  AppButton(label: 'Apply matches', onPressed: applyMatches),
                ],
              )
          ],
        )
    ]);
  }
}
