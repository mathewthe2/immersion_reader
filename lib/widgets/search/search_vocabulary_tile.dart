import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/popup_dictionary_theme_data.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/utils/system_theme.dart';
import 'package:immersion_reader/widgets/popup_dictionary/vocabulary_definition.dart';
import 'package:immersion_reader/widgets/vocabulary/frequency_widget.dart';
import 'package:immersion_reader/widgets/vocabulary/pitch_widget.dart';

// refactor: shares repetitive code with vocabulary_tile.dart
// this is used for search results while VocabularyTile is used in the context of a popup dictionary
class SearchVocabularyTile extends StatelessWidget {
  final Vocabulary vocabulary;
  final CupertinoDynamicColor textColor;
  final bool vocabularyIsExists;
  final Function(Vocabulary) addOrRemoveFromVocabularyList;
  final BuildContext parentContext;
  const SearchVocabularyTile(
      {super.key,
      required this.vocabulary,
      required this.textColor,
      required this.vocabularyIsExists,
      required this.addOrRemoveFromVocabularyList,
      required this.parentContext});

  bool hasPitch(Vocabulary vocabulary) {
    return vocabulary.pitchValues.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CupertinoListTile(
          trailing: CupertinoButton(
              onPressed: () => addOrRemoveFromVocabularyList(vocabulary),
              child: Icon(
                color:
                    dictionaryColorDataMap[DictionaryColor.primaryActionColor]?[
                        isDarkMode()
                            ? PopupDictionaryTheme.dark
                            : PopupDictionaryTheme.light],
                vocabularyIsExists
                    ? CupertinoIcons.star_fill
                    : CupertinoIcons.star,
                size: 20,
              )),
          title: SizedBox(
              width:
                  MediaQuery.of(context).size.width * 0.9, // space for padding
              child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textHeightBehavior:
                      const TextHeightBehavior(applyHeightToLastDescent: false),
                  text: TextSpan(
                      text: vocabulary.expression ?? '',
                      style: TextStyle(
                          fontSize: 20,
                          height: 1.8, // spacing for second line
                          color: CupertinoDynamicColor.resolve(
                              textColor, parentContext)),
                      children: [
                        const WidgetSpan(
                            child: SizedBox(
                          width: 20,
                        )),
                        WidgetSpan(
                            child: hasPitch(vocabulary)
                                ? PitchWidget(
                                    vocabulary: vocabulary,
                                    themeData: PopupDictionaryThemeData(
                                        popupDictionaryTheme: isDarkMode()
                                            ? PopupDictionaryTheme.dark
                                            : PopupDictionaryTheme.light))
                                : const SizedBox())
                      ])))),
      if (vocabulary.frequencyTags.isNotEmpty)
        Padding(
            padding: const EdgeInsetsDirectional.only(
                start: 20.0, end: 14.0, bottom: 5.0),
            child: FrequencyWidget(
                parentContext: parentContext, vocabulary: vocabulary)),
      Padding(
          padding: const EdgeInsetsDirectional.only(
              start: 20.0, end: 14.0, bottom: 5.0),
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: VocabularyDefinition(
                      vocabulary: vocabulary,
                      popupDictionaryThemeData: PopupDictionaryThemeData(
                          popupDictionaryTheme: PopupDictionaryTheme.dark)))))
    ]);
  }
}
