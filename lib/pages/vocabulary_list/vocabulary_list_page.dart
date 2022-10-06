import 'package:flutter/cupertino.dart';
// import 'package:cupertino_lists/cupertino_lists.dart' as cupertino_list;
import 'package:flutter_slidable/flutter_slidable.dart';
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
    return FutureBuilder<List<Vocabulary>>(
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
                    child: CupertinoListSection.insetGrouped(
                        // header: const Text('My Words'),
                        children: [
                          ...vocabularyList.map((Vocabulary vocabulary) {
                            return Slidable(
                                key: ValueKey<int>(vocabulary.vocabularyId!),
                                // The start action pane is the one at the left or the top side.
                                // startActionPane: ActionPane(
                                //   motion: const ScrollMotion(),
                                //   dismissible:
                                //       DismissiblePane(onDismissed: () {}),
                                //   // All actions are defined in the children parameter.
                                //   children: [
                                //     // A SlidableAction can have an icon and/or a label.
                                //   ],
                                // ),

                                // The end action pane is the one at the right or the bottom side.
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) {},
                                      backgroundColor:
                                          CupertinoColors.systemBlue,
                                      foregroundColor: CupertinoColors.white,
                                      icon: CupertinoIcons.share,
                                    ),
                                    SlidableAction(
                                      onPressed: (context) {},
                                      backgroundColor:
                                          CupertinoColors.systemPurple,
                                      foregroundColor: CupertinoColors.white,
                                      icon: CupertinoIcons.folder_fill,
                                    ),
                                    SlidableAction(
                                      onPressed: (context) =>
                                          deleteVocabulary(vocabulary),
                                      backgroundColor:
                                          CupertinoColors.destructiveRed,
                                      foregroundColor: CupertinoColors.white,
                                      icon: CupertinoIcons.delete,
                                      // label: 'Delete',
                                    ),
                                  ],
                                ),
                                child: CupertinoListTile.notched(
                                  title: Text(vocabulary.expression ?? ""),
                                  subtitle: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: Text(
                                        vocabulary.getFirstGlossary(),
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                ));
                          }).toList()
                        ])))
          ]);
        } else if (snapshot.hasError) {
          return const Text('cannot load storage data.');
        } else {
          return const CupertinoActivityIndicator(
            animating: true,
            radius: 24,
          );
        }
      },
    );
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
