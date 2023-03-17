import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/managers/navigation/navigation_manager.dart';
import 'package:immersion_reader/managers/vocabulary_list/vocabulary_list_manager.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:immersion_reader/pages/vocabulary_list/vocabulary_detail_edit_page.dart';
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
  Future<void> deleteVocabulary(Vocabulary vocabulary) async {
    await VocabularyListManager().deleteVocabularyItem(vocabulary);
    NavigationManager().notifyVocabularyListPage();
  }

  Future<void> deleteAllVocabulary() async {
    await VocabularyListManager().deleteAllVocabularyItems();
    NavigationManager().notifyVocabularyListPage();
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
          child: ValueListenableBuilder(
              valueListenable: NavigationManager().vocabularyListNotifier,
              builder: (context, val, child) => VocabularyListManager()
                      .vocabularyList
                      .isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SafeArea(
                          child: Container(
                              color: CupertinoDynamicColor.resolve(
                                  const CupertinoDynamicColor.withBrightness(
                                      color: CupertinoColors
                                          .systemGroupedBackground,
                                      darkColor: CupertinoColors.black),
                                  context),
                              child: CupertinoScrollbar(
                                  child: SingleChildScrollView(
                                      child: CupertinoListSection.insetGrouped(
                                          // header: const Text('My Words'),
                                          children: [
                                    ...VocabularyListManager()
                                        .vocabularyList
                                        .map((Vocabulary vocabulary) {
                                      return GestureDetector(
                                          onTap: () {
                                            Navigator.push(context,
                                                SwipeablePageRoute(
                                                    builder: (context) {
                                              return VocabularyDetailEditPage(
                                                  vocabulary: vocabulary);
                                            }));
                                          },
                                          child: Slidable(
                                              key: ValueKey<String>(
                                                  vocabulary.uniqueId),
                                              // The end action pane is the one at the right or the bottom side.
                                              endActionPane: ActionPane(
                                                dismissible: DismissiblePane(
                                                    onDismissed: () {},
                                                    motion:
                                                        const BehindMotion()),
                                                motion: const ScrollMotion(),
                                                children: [
                                                  // SlidableAction(
                                                  //   onPressed: (context) {},
                                                  //   backgroundColor:
                                                  //       CupertinoColors.systemBlue,
                                                  //   foregroundColor:
                                                  //       CupertinoColors.white,
                                                  //   icon: CupertinoIcons.share,
                                                  // ),
                                                  // SlidableAction(
                                                  //   onPressed: (context) {},
                                                  //   backgroundColor:
                                                  //       CupertinoColors.systemPurple,
                                                  //   foregroundColor:
                                                  //       CupertinoColors.white,
                                                  //   icon: CupertinoIcons.folder_fill,
                                                  // ),
                                                  SlidableAction(
                                                    autoClose: false,
                                                    onPressed: (context) async {
                                                      var state =
                                                          Slidable.of(context);
                                                      await state?.dismiss(
                                                          ResizeRequest(
                                                              const Duration(
                                                                  milliseconds:
                                                                      300),
                                                              () {}));
                                                      deleteVocabulary(
                                                          vocabulary);
                                                    },
                                                    backgroundColor:
                                                        CupertinoColors
                                                            .destructiveRed,
                                                    foregroundColor:
                                                        CupertinoColors.white,
                                                    icon: CupertinoIcons.delete,
                                                    // label: 'Delete',
                                                  ),
                                                ],
                                              ),
                                              child: CupertinoListTile.notched(
                                                title: Text(
                                                    vocabulary.expression ??
                                                        ""),
                                                subtitle: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                    child: Text(
                                                      vocabulary
                                                          .getFirstGlossary(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                              )));
                                    }).toList()
                                  ]))))))
                  : Container())),
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
                VocabularyListManager().vocabularyList);
            if (filePath.isNotEmpty) {
              if (filePath.isNotEmpty && context.mounted) {
                final box = context.findRenderObject() as RenderBox?;
                Share.shareFiles([filePath],
                    sharePositionOrigin:
                        box!.localToGlobal(Offset.zero) & box.size);
              }
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
                onConfirmCallback: deleteAllVocabulary);
          },
        ),
      ],
    );
    //   },
    // );
  }
}
