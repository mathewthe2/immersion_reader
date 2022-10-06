import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';

class VocabularyListPage extends StatefulWidget {
  const VocabularyListPage({super.key});

  @override
  State<VocabularyListPage> createState() => _VocabularyListPageState();
}

class _VocabularyListPageState extends State<VocabularyListPage> {
  VocabularyListStorage? vocabularyListStorage;
  List<Vocabulary> vocabularyList = [];

  // @override
  // void initState() {
  //   super.initState();
  // }

  Future<List<Vocabulary>> getVocabularyList() async {
    print('getting list');
    vocabularyListStorage = await VocabularyListStorage.create();
    if (vocabularyListStorage == null) {
      return [];
    }
    // await vocabularyListStorage!.addVocabularyItem();
    List<Vocabulary> fetchedList =
        await vocabularyListStorage!.getVocabularyItems();
    vocabularyList = fetchedList;
    return fetchedList;
  }

  Future<void> deleteVocabulary(Vocabulary vocabulary) async {
    if (vocabularyListStorage != null && vocabulary.vocabularyId != null) {
      await vocabularyListStorage!
          .deleteVocabularyItem(vocabulary.vocabularyId!);
      setState(() {
        vocabularyList = List.from(vocabularyList)..remove(vocabulary);
      });
    }
  }

  void handleClick(String value) {
    switch (value) {
      case 'Export for AnkiDojo':
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: FutureBuilder<List<Vocabulary>>(
      future: getVocabularyList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              // PopupMenuButton<String>(
              //   onSelected: handleClick,
              //   itemBuilder: (BuildContext context) {
              //     return {
              //       'Export for AnkiDojo',
              //       'Move to known',
              //       'Delete all'
              //     }.map((String choice) {
              //       return PopupMenuItem<String>(
              //         value: choice,
              //         child: Text(choice),
              //       );
              //     }).toList();
              //   },
              // ),
            ]),
            Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: vocabularyList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          color: Colors.black12,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(vocabularyList[index].expression!),
                                IconButton(
                                    icon: const Icon(CupertinoIcons.clear),
                                    tooltip: 'Increase volume by 10',
                                    onPressed: () =>
                                        deleteVocabulary(vocabularyList[index]))
                              ]));
                    }))
          ]);
        } else if (snapshot.hasError) {
          return const Text('cannot load storage data.');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    ));
  }
}
