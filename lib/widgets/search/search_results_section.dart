import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/search/search_result.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/widgets/search/search_vocabulary_tile.dart';

class SearchResultsSection extends StatefulWidget {
  final SearchResult searchResult;
  final Function(Vocabulary) addOrRemoveFromVocabularyList;
  final BuildContext parentContext;
  const SearchResultsSection(
      {super.key,
      required this.searchResult,
      required this.addOrRemoveFromVocabularyList,
      required this.parentContext});

  @override
  State<SearchResultsSection> createState() => _SearchResultsSectionState();
}

class _SearchResultsSectionState extends State<SearchResultsSection> {
  final textColor = const CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.darkBackgroundGray,
    darkColor: CupertinoColors.lightBackgroundGray,
  );

  bool _vocabularyIsExists(Vocabulary vocabulary) {
    return widget.searchResult.existingVocabularyIds
        .contains(vocabulary.uniqueId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (widget.searchResult.exactMatches.isNotEmpty)
        CupertinoListSection(header: const Text('Exact Matches'), children: [
          ...widget.searchResult.exactMatches.map((Vocabulary vocabulary) {
            return SearchVocabularyTile(
                vocabulary: vocabulary,
                vocabularyIsExists: _vocabularyIsExists(vocabulary),
                addOrRemoveFromVocabularyList:
                    widget.addOrRemoveFromVocabularyList,
                parentContext: widget.parentContext,
                textColor: textColor);
          })
        ]),
      if (widget.searchResult.additionalMatches.isNotEmpty)
        CupertinoListSection(
            header: const Text('Additional Matches'),
            children: [
              ...widget.searchResult.additionalMatches
                  .map((Vocabulary vocabulary) {
                return SearchVocabularyTile(
                    vocabulary: vocabulary,
                    vocabularyIsExists: _vocabularyIsExists(vocabulary),
                    addOrRemoveFromVocabularyList:
                        widget.addOrRemoveFromVocabularyList,
                    parentContext: widget.parentContext,
                    textColor: textColor);
              })
            ])
    ]);
  }
}
