import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/managers/reader/book_manager.dart';
import 'package:immersion_reader/widgets/audiobook/audio_book_subtitles.dart';

class PopupDictionarySubtitles extends StatefulWidget {
  final String? subtitleId;
  const PopupDictionarySubtitles({super.key, this.subtitleId});

  @override
  State<PopupDictionarySubtitles> createState() =>
      _PopupDictionarySubtitlesState();
}

class _PopupDictionarySubtitlesState extends State<PopupDictionarySubtitles> {
  Book? book;
  bool isFetchingBook = true;

  @override
  void initState() {
    super.initState();
    getBook();
  }

  Future<void> getBook() async {
    final currentBook = await BookManager().getCurrentBook();
    setState(() {
      book = currentBook;
      isFetchingBook = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isFetchingBook || book == null) {
      return Container();
    }
    // workaround as audio book subtitles do not handle theme colors yet
    Color backgroundColor = context.color(
        lightMode: CupertinoColors.lightBackgroundGray,
        darkMode: CupertinoColors.darkBackgroundGray);
    return Container(
        color: backgroundColor,
        child: AudioBookSubtitles(
            book: book!, lookupSubtitleId: widget.subtitleId));
  }
}
