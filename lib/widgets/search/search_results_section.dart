import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/popup_dictionary_theme_data.dart';
import 'package:immersion_reader/data/search/search_result.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/utils/system_theme.dart';
import 'package:immersion_reader/widgets/vocabulary/frequency_widget.dart';
import 'package:immersion_reader/widgets/vocabulary/pitch_widget.dart';

class SearchResultsSection extends StatefulWidget {
  final SearchResult searchResult;
  final BuildContext parentContext;
  const SearchResultsSection(
      {super.key, required this.searchResult, required this.parentContext});

  @override
  State<SearchResultsSection> createState() => _SearchResultsSectionState();
}

class _SearchResultsSectionState extends State<SearchResultsSection> {
  final textColor = const CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.darkBackgroundGray,
    darkColor: CupertinoColors.lightBackgroundGray,
  );

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CupertinoListSection(
          header: const Text('Exact Matches'),
          children: [
            ...widget.searchResult.exactMatches.map((Vocabulary vocabulary) {
              return VocabularyTile(
                  vocabulary: vocabulary,
                  parentContext: widget.parentContext,
                  textColor: textColor);
            })
          ]),
      CupertinoListSection(
          header: const Text('Additional Matches'),
          children: [
            ...widget.searchResult.additionalMatches
                .map((Vocabulary vocabulary) {
              return VocabularyTile(
                  vocabulary: vocabulary,
                  parentContext: widget.parentContext,
                  textColor: textColor);
            })
          ])
    ]);
  }
}

class VocabularyTile extends StatelessWidget {
  final Vocabulary vocabulary;
  final CupertinoDynamicColor textColor;
  final BuildContext parentContext;
  const VocabularyTile(
      {super.key,
      required this.vocabulary,
      required this.textColor,
      required this.parentContext});

  bool hasPitch(Vocabulary vocabulary) {
    return vocabulary.pitchValues.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CupertinoListTile(
          title: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                      text: vocabulary.expression ?? '',
                      style: TextStyle(
                          fontSize: 20,
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
                                : const SizedBox()),
                        // TextSpan(
                        //     text: vocabulary.reading ?? '',
                        //     style: const TextStyle(
                        //         color: CupertinoColors.inactiveGray))
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
                  child: Text(vocabulary.getCompleteGlossary(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: CupertinoDynamicColor.resolve(
                            textColor, parentContext),
                      )))))
    ]);
  }
}
