import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/popup_dictionary_theme_data.dart';
import 'package:immersion_reader/managers/reader/reader_js_manager.dart';
import 'package:immersion_reader/widgets/popup_dictionary/dictionary/vocabulary_tile_list.dart';

class PopupDictionaryContent extends StatelessWidget {
  final String text;
  final int characterIndex;
  final bool enableLookupHighlight;
  final PopupDictionaryThemeData popupDictionaryThemeData;
  const PopupDictionaryContent(
      {super.key,
      required this.text,
      required this.characterIndex,
      required this.popupDictionaryThemeData,
      required this.enableLookupHighlight});

  @override
  Widget build(BuildContext context) {
    void onTapCharacterCallback(initialOffset, textLength) {
      if (enableLookupHighlight) {
        ReaderJsManager().highlightLastSelected(
            initialOffset: initialOffset, textLength: textLength);
        ReaderJsManager().setLastSubtitleTextLength(textLength);
      }
    }

    return CupertinoScrollbar(
        child: SingleChildScrollView(
            child: VocabularyTileList(
                text: text,
                targetIndex: characterIndex,
                onTapCharacterCallback: onTapCharacterCallback,
                removeHighlight: ReaderJsManager().removeHighlight,
                popupDictionaryThemeData: popupDictionaryThemeData,
                vocabularyList: const [])));
  }
}
