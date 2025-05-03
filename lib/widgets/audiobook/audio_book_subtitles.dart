import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/audio_book/audio_book_files.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/data/reader/subtitle.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_book_operation_type.dart';
import 'package:immersion_reader/managers/reader/audio_book/audio_player_manager.dart';
import 'package:immersion_reader/widgets/common/text/app_text.dart';

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
  bool isFetchingSubtitles = false;

  @override
  void initState() {
    book = widget.book;
    initSubtitles(book);
    listenToBookOperations();
    super.initState();
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
    setState(() {
      isFetchingSubtitles = false;
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
    return Column(
      children: [
        SizedBox(height: context.spacer()),
        AppText("Beta: This feature is still work in progress"),
        SizedBox(height: context.spacer()),
        SizedBox(
            height: context.hero(),
            child: CupertinoScrollbar(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  ...subtitles.map((subtitle) => Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: AppText(
                        subtitle.text,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )))
                ],
              ),
            ))),
      ],
    );
  }
}
