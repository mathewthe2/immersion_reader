import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/search/search_history_item.dart';
import 'package:immersion_reader/managers/dictionary/dictionary_manager.dart';
import 'package:immersion_reader/utils/system_dialog.dart';

class SearchHistorySection extends StatefulWidget {
  final Function(String) handleSearchWithRedirect;
  final VoidCallback clearDictionaryHistory;
  const SearchHistorySection(
      {super.key,
      required this.handleSearchWithRedirect,
      required this.clearDictionaryHistory});

  @override
  State<SearchHistorySection> createState() => _SearchHistorySectionState();
}

class _SearchHistorySectionState extends State<SearchHistorySection> {
  List<SearchHistoryItem> searchHistoryItems = [];

  Future<void> getSearchHistoryItems() async {
    List<SearchHistoryItem> historyItems =
        await DictionaryManager().getDictionaryHistory();
    setState(() {
      searchHistoryItems = historyItems;
    });
  }

  @override
  void initState() {
    super.initState();
    getSearchHistoryItems();
  }

  void clearSearchDictionaryHistory() {
    setState(() {
      searchHistoryItems = [];
    });
    widget.clearDictionaryHistory();
  }

  @override
  Widget build(BuildContext context) {
    if (searchHistoryItems.isNotEmpty) {
      return Column(children: [
        CupertinoListSection(
          children: [
            ...searchHistoryItems.map((searchHistoryItem) => CupertinoListTile(
                onTap: () =>
                    widget.handleSearchWithRedirect(searchHistoryItem.query),
                title: Text(searchHistoryItem.query)))
          ],
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 120),
            child: GestureDetector(
                child: const Text("Clear search history"),
                onTap: () {
                  showAlertDialog(
                      context, "Do you want to clear search history?",
                      onConfirmCallback: clearSearchDictionaryHistory);
                })),
      ]);
    }
    return Container();
  }
}
