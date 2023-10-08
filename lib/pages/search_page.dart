import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/search/search_result.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/managers/dictionary/dictionary_manager.dart';
import 'package:immersion_reader/managers/vocabulary_list/vocabulary_list_manager.dart';
import 'package:immersion_reader/widgets/common/padding_bottom.dart';
import 'package:immersion_reader/widgets/search/search_history_section.dart';
import 'package:immersion_reader/widgets/search/search_no_results_section.dart';
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

  /// Save query to DB as dictionary history
  void logQueryToHistory(String query) {
    DictionaryManager().addQueryToDictionaryHistory(query);
  }

  void clearDictionaryHistory() {
    DictionaryManager().clearDictionaryHistory();
  }

  void handleSearchChange(String? input) async {
    print("hello?");
    setState(() {
      searchResult = null;
    });
  }

  void handleSearchWithRedirect(String input) async {
    textController = TextEditingController(text: input);
    handleSearchSubmission(input);
  }

  void handleSearchSubmission(String input) async {
    if (input.isEmpty) {
      searchResult = SearchResult(exactMatches: [], additionalMatches: []);
    } else {
      logQueryToHistory(input);
      searchResult = await DictionaryManager().findTermForUserSearch(input);
      searchResult!.existingVocabularyIds = await VocabularyListManager()
          .vocabularyListStorage!
          .getExistsVocabularyList([
        ...searchResult!.exactMatches,
        ...searchResult!.additionalMatches
      ]);
    }
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
                      onChanged: handleSearchChange,
                      onSubmitted: handleSearchSubmission)),
            ]),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            if (searchResult == null)
              SearchHistorySection(
                  handleSearchWithRedirect: handleSearchWithRedirect,
                  clearDictionaryHistory: clearDictionaryHistory)
            else if (searchResult!.exactMatches.isEmpty &&
                searchResult!.additionalMatches.isEmpty)
              const SearchNoResultsSection()
            else
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
