import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/search/search_result.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/managers/dictionary/dictionary_manager.dart';
import 'package:immersion_reader/widgets/search/search_results_section.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController textController;
  SearchResult? searchResult;

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
    searchResult = await DictionaryManager().findTermForUserSearch(input);
    setState(() {
      searchResult = searchResult;
    });
  }

  Widget searchResultSection(SearchResult result) {
    return CupertinoListSection(header: const Text('Exact Matches'), children: [
      ...searchResult!.exactMatches.map((Vocabulary vocabulary) {
        return CupertinoListTile(
            title: Text(vocabulary.expression ?? ''),
            subtitle: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Text(
                vocabulary.getFirstGlossary(),
                overflow: TextOverflow.ellipsis,
              ),
            ));
      })
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: CustomScrollView(slivers: [
      (const CupertinoSliverNavigationBar(
        largeTitle: Text('My Dictionary'),
      )),
      SliverFillRemaining(
          child: CupertinoScrollbar(
              child: SingleChildScrollView(
                  child: Column(children: [
        const SizedBox(height: 20),
        CupertinoSearchTextField(
            autocorrect: false,
            controller: textController,
            placeholder: 'Search',
            onSubmitted: handleSearch),
        if (searchResult != null)
          SearchResultsSection(
              searchResult: searchResult!, parentContext: context),
      ]))))
    ]));
  }
}
