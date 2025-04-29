import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_match_result.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_files.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/subtitle.dart';
import 'package:immersion_reader/extensions/file_extension.dart';
import 'package:immersion_reader/extensions/list_extension.dart';
import 'package:immersion_reader/extensions/string_extension.dart';
import 'package:immersion_reader/managers/reader/book_manager.dart';
import 'package:immersion_reader/managers/reader/reader_js_manager.dart';
import 'package:immersion_reader/utils/folder_utils.dart';
import 'package:immersion_reader/utils/reader/match_js.dart';
import 'package:immersion_reader/widgets/common/buttons/app_button.dart';
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

  StreamController<int>? matchProgressController;

  static const int maxTextNodesToSelect = 300;
  static const int maxTextLengthToShow = 20;
  static const int textNodeWindow = 10;

  @override
  void initState() {
    super.initState();
    book = widget.book;
    matchProgressController = widget.matchProgressController;
    getAudioBook();
  }

  Future<void> onAddSubtitle() async {
    if (book.id == null) return;
    String? newFilePath = await FolderUtils.addSubtitleFile(book.id!);
    if (newFilePath != null) {
      getAudioBook();
    }
  }

  Future<void> onAddAudioFile() async {
    if (book.id == null) return;
    String? newFilePath = await FolderUtils.addAudioFile(book.id!);
    if (newFilePath != null) {
      getAudioBook();
    }
  }

  // get existing audio files if exist
  Future<void> getAudioBook() async {
    if (book.id == null) return;
    final files = await FolderUtils.getFilesinBookFolder(book.id!);
    List<File> subtitleFiles = [];
    List<File> audioFiles = [];
    for (final file in files) {
      if (file.path.endsWith(".srt")) {
        subtitleFiles.add(file);
      } else if (file.path.endsWith(".mp3") ||
          file.path.endsWith(".m4a") ||
          file.path.endsWith(".m4b")) {
        audioFiles.add(file);
      }
    }
    setState(() {
      audioBook =
          AudioBookFiles(subtitleFiles: subtitleFiles, audioFiles: audioFiles);
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
  }

  Future<void> removeAudioFiles() async {
    if (book.id == null) return;
    await FolderUtils.removeAudioFilesForBook(book.id!);
    if (audioBook != null) {
      setState(() {
        audioBook = AudioBookFiles(
            subtitleFiles: audioBook!.subtitleFiles, audioFiles: []);
      });
    }
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
            lineMatchRate: result.value["lineMatchRate"] ?? "",
            bookSubtitleDiffRate: result.value["bookSubtitleDiffRate"] ?? "");
      });
    }
  }

  Future<void> applyMatches() async {
    if (matchResult != null) {
      await BookManager().updateBookContentHtml(matchResult!);
      await ReaderJsManager().reloadReader();
    }
  }

  Future<void> resetMatches() async {
    if (book.id != null) {
      await BookManager().resetElementHtmlFromBackup(book.id!);
      await ReaderJsManager().reloadReader();
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
    return Column(
      children: [
        SizedBox(height: 20),
        AppText("Audio Book Matching (Beta)", style: TextStyle(fontSize: 20)),
        if ((audioBook == null && !isFetchingAudioBook) ||
            (audioBook != null && audioBook!.audioFiles.isEmpty))
          AppButton(
              label: 'Add audio file (.mp3/.m4a)', onPressed: onAddAudioFile),
        if (audioBook != null && audioBook!.audioFiles.isNotEmpty)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            AppText(audioBook!.audioFiles.map((file) => file.name).join("")),
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
            AppText(audioBook!.subtitleFiles.map((file) => file.name).join("")),
            AppIconButton(CupertinoIcons.trash, onPressed: removeSubtitleFiles),
          ]),
        AppButton(
            label: 'Align beginning of text', onPressed: onAlignTextBeginning),
        if (alignBeginningVisible && textNodes.isNotEmpty)
          SizedBox(
              height: 200,
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
              ))),
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
                if (streamSnapshot.connectionState == ConnectionState.active) {
                  return Text('${streamSnapshot.data!}%');
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
              AppText("Book diff rate ${matchResult!.bookSubtitleDiffRate}"),
              AppButton(label: 'Apply matches', onPressed: applyMatches),
              AppButton(
                label: 'Reset',
                onPressed: resetMatches,
              ),
            ],
          )
      ],
    );
  }
}
