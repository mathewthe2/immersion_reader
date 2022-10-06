import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:share_plus/share_plus.dart';
import 'package:immersion_reader/utils/exporter.dart';
import 'package:immersion_reader/utils/system_dialog.dart';

class VocabularyListPage extends StatefulWidget {
  const VocabularyListPage({super.key});

  @override
  State<VocabularyListPage> createState() => _VocabularyListPageState();
}

class _VocabularyListPageState extends State<VocabularyListPage> {
  VocabularyListStorage? vocabularyListStorage;
  List<Vocabulary> vocabularyList = [];

  Future<List<Vocabulary>> getVocabularyList() async {
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

  Future<void> deleteAllVocabulary() async {
    if (vocabularyListStorage != null) {
      await vocabularyListStorage!.deleteAllVocabularyItems();
      setState(() {
        vocabularyList = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: FutureBuilder<List<Vocabulary>>(
      future: getVocabularyList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CustomScrollView(slivers: [
            (CupertinoSliverNavigationBar(
              largeTitle: const Text('My Words'),
              trailing: GestureDetector(
                  onTap: () => showCupertinoModalPopup(
                        context: context,
                        builder: _modalBuilder,
                      ),
                  child: const Icon(CupertinoIcons.ellipsis)),
            )),
            SliverFillRemaining(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(children: [
                      ...ListTile.divideTiles(
                          context: context,
                          color: Colors.black54,
                          tiles: vocabularyList.map((Vocabulary vocabulary) {
                            return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(vocabulary.expression!,
                                      style: const TextStyle(fontSize: 20)),
                                  Text(vocabulary.getFirstGlossary(),
                                      style: const TextStyle(fontSize: 15),
                                      overflow: TextOverflow.ellipsis),
                                  IconButton(
                                      icon: const Icon(CupertinoIcons.clear),
                                      tooltip: 'Increase volume by 10',
                                      onPressed: () =>
                                          deleteVocabulary(vocabulary))
                                ]);
                          }).toList())
                    ])))
          ]);
        } else if (snapshot.hasError) {
          return const Text('cannot load storage data.');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    ));
  }

  Widget _modalBuilder(BuildContext context) {
    // return CupertinoModalPopupRoute<void>(
    //   builder: (BuildContext context) {
    return CupertinoActionSheet(
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Icon(CupertinoIcons.arrow_down),
            SizedBox(width: 10),
            Text('Export for AnkiDojo')
          ]),
          onPressed: () async {
            Navigator.pop(context);
            String filePath = await exportToAnkiDojoCSV(vocabularyList);
            Share.shareFiles([filePath]);
          },
        ),
        CupertinoActionSheetAction(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(CupertinoIcons.trash),
                SizedBox(width: 10),
                Text('Clear All')
              ]),
          onPressed: () async {
            Navigator.pop(context);
            showAlertDialog(context, "Do you want to delete all your words?",
                deleteAllVocabulary);
          },
        ),
      ],
    );
    //   },
    // );
  }
}
