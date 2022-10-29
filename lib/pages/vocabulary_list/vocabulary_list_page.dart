import 'package:flutter/cupertino.dart';
// import 'package:cupertino_lists/cupertino_lists.dart' as cupertino_list;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:immersion_reader/pages/vocabulary_list/vocabulary_detail_edit_page.dart';
import 'package:immersion_reader/providers/vocabulary_list_provider.dart';
// import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:share_plus/share_plus.dart';
import 'package:immersion_reader/utils/exporter.dart';
import 'package:immersion_reader/utils/system_dialog.dart';

class VocabularyListPage extends StatefulWidget {
  final VocabularyListProvider vocabularyListProvider;
  final ValueNotifier notifier;

  const VocabularyListPage(
      {super.key,
      required this.vocabularyListProvider,
      required this.notifier});

  @override
  State<VocabularyListPage> createState() => _VocabularyListPageState();
}

class _VocabularyListPageState extends State<VocabularyListPage> {
  Future<void> deleteVocabulary(Vocabulary vocabulary) async {
    await widget.vocabularyListProvider.deleteVocabularyItem(vocabulary);
    widget.notifier.value = !widget.notifier.value;
  }

  Future<void> deleteAllVocabulary() async {
    await widget.vocabularyListProvider.deleteAllVocabularyItems();
    widget.notifier.value = !widget.notifier.value;
  }

  @override
  Widget build(BuildContext context) {
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
          child: widget.vocabularyListProvider.vocabularyList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                      color: CupertinoDynamicColor.resolve(
                          const CupertinoDynamicColor.withBrightness(
                              color: CupertinoColors.systemGroupedBackground,
                              darkColor: CupertinoColors.black),
                          context),
                      child: SingleChildScrollView(
                          child: SafeArea(
                              child: CupertinoListSection.insetGrouped(
                                  // header: const Text('My Words'),
                                  children: [
                            ...widget.vocabularyListProvider.vocabularyList
                                .map((Vocabulary vocabulary) {
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.push(context,
                                        CupertinoPageRoute(builder: (context) {
                                      return VocabularyDetailEditPage(
                                          vocabularyListProvider:
                                              widget.vocabularyListProvider,
                                          vocabulary: vocabulary,
                                          notifier: widget.notifier);
                                    }));
                                  },
                                  child: Slidable(
                                      key: ValueKey<String>(
                                          vocabulary.getIdentifier()),

                                      // The end action pane is the one at the right or the bottom side.
                                      endActionPane: ActionPane(
                                        motion: const ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) {},
                                            backgroundColor:
                                                CupertinoColors.systemBlue,
                                            foregroundColor:
                                                CupertinoColors.white,
                                            icon: CupertinoIcons.share,
                                          ),
                                          SlidableAction(
                                            onPressed: (context) {},
                                            backgroundColor:
                                                CupertinoColors.systemPurple,
                                            foregroundColor:
                                                CupertinoColors.white,
                                            icon: CupertinoIcons.folder_fill,
                                          ),
                                          SlidableAction(
                                            onPressed: (context) =>
                                                deleteVocabulary(vocabulary),
                                            backgroundColor:
                                                CupertinoColors.destructiveRed,
                                            foregroundColor:
                                                CupertinoColors.white,
                                            icon: CupertinoIcons.delete,
                                            // label: 'Delete',
                                          ),
                                        ],
                                      ),
                                      child: CupertinoListTile.notched(
                                        title:
                                            Text(vocabulary.expression ?? ""),
                                        subtitle: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            child: Text(
                                              vocabulary.getFirstGlossary(),
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                      )));
                            }).toList()
                          ])))))
              : Container())
    ]);
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
            String filePath = await exportToAnkiDojoCSV(
                widget.vocabularyListProvider.vocabularyList);
            if (filePath.isNotEmpty) {
              Share.shareFiles([filePath]);
            }
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
