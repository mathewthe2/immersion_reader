import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/search/search_result.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/managers/dictionary/dictionary_manager.dart';
import 'package:immersion_reader/managers/vocabulary_list/vocabulary_list_manager.dart';
import 'package:immersion_reader/widgets/common/padding_bottom.dart';
import 'package:immersion_reader/widgets/search/search_results_section.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController textController;
  SearchResult? searchResult;
  bool? previousNotifierValue;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void handleSearch(String input) async {
    searchResult = input.isEmpty
        ? SearchResult(exactMatches: [], additionalMatches: [])
        : await DictionaryManager().findTermForUserSearch(input);
    searchResult!.existingVocabularyIds = await VocabularyListManager()
        .vocabularyListStorage!
        .getExistsVocabularyList([
      ...searchResult!.exactMatches,
      ...searchResult!.additionalMatches
    ]);
    setState(() {
      searchResult = searchResult;
    });
  }

  bool _vocabularyIsExists(Vocabulary vocabulary) {
    return searchResult!.existingVocabularyIds.contains(vocabulary.uniqueId);
  }

  Future<void> addOrRemoveFromVocabularyList(Vocabulary vocabulary) async {
    if (VocabularyListManager().vocabularyListStorage != null) {
      if (_vocabularyIsExists(vocabulary)) {
        // remove vocabulary
        await VocabularyListManager()
            .vocabularyListStorage!
            .deleteVocabularyItem(vocabulary.uniqueId);
        searchResult!.existingVocabularyIds.remove(vocabulary.uniqueId);
      } else {
        // add vocabulary
        await VocabularyListManager()
            .vocabularyListStorage!
            .addVocabularyItem(vocabulary);
        searchResult!.existingVocabularyIds.add(vocabulary.uniqueId);
      }
      setState(() {
        searchResult = searchResult;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor:
            CupertinoColors.systemGroupedBackground.resolveFrom(context),
        child: CustomScrollView(slivers: [
          CupertinoSliverNavigationBar(
            middle: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('My Dictionary'))),
            largeTitle: Column(children: [
              Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CupertinoSearchTextField(
                      autocorrect: false,
                      controller: textController,
                      placeholder: 'Search',
                      onSubmitted: handleSearch)),
            ]),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            if (searchResult != null)
              PaddingBottom(
                  child: SearchResultsSection(
                      searchResult: searchResult!,
                      addOrRemoveFromVocabularyList:
                          addOrRemoveFromVocabularyList,
                      parentContext: context))
          ])),
        ]));
  }
}
