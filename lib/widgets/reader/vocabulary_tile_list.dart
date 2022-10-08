import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'vocabulary_tile.dart';
import 'vocabulary_definition.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';

class VocabularyTileList extends StatefulWidget {
  final List<Vocabulary> vocabularyList;
  final VocabularyListStorage? vocabularyListStorage;
  const VocabularyTileList(
      {super.key,
      required this.vocabularyList,
      required this.vocabularyListStorage});

  @override
  State<VocabularyTileList> createState() => _VocabularyTileListState();
}

class _VocabularyTileListState extends State<VocabularyTileList> {
  List<String> existingVocabularyIds = [];

  @override
  void initState() {
    super.initState();
    _checkExistsVocabulary();
  }

  Future<void> _checkExistsVocabulary() async {
    if (widget.vocabularyListStorage != null) {
      existingVocabularyIds = await widget.vocabularyListStorage!
          .getExistsVocabularyList(widget.vocabularyList);
      setState(() {});
    }
  }

  Future<void> addOrRemoveFromVocabularyList(Vocabulary vocabulary) async {
    if (widget.vocabularyListStorage != null) {
      if (ifVocabularyExists(vocabulary)) {
        // remove vocabulary
        await widget.vocabularyListStorage!
            .deleteVocabularyItem(vocabulary.getIdentifier());
        existingVocabularyIds.remove(vocabulary.getIdentifier());
      } else {
        // add vocabulary
        await widget.vocabularyListStorage!.addVocabularyItem(vocabulary);
        existingVocabularyIds.add(vocabulary.getIdentifier());
      }
      setState(() {});
    }
  }

  bool ifVocabularyExists(Vocabulary vocabulary) {
    return existingVocabularyIds.contains(vocabulary.getIdentifier());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.vocabularyList
              .map(
                (Vocabulary vocabulary) => Column(children: [
                  CupertinoListTile(
                      title: VocabularyTile(
                          vocabulary: vocabulary,
                          added: ifVocabularyExists(vocabulary),
                          addOrRemoveVocabulary: addOrRemoveFromVocabularyList),
                      trailing: CupertinoButton(
                          onPressed: () =>
                              addOrRemoveFromVocabularyList(vocabulary),
                          child: Icon(
                            ifVocabularyExists(vocabulary)
                                ? CupertinoIcons.star_fill
                                : CupertinoIcons.star,
                            size: 20,
                          ))),
                  Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 20.0, end: 14.0),
                      child: VocabularyDefinition(vocabulary: vocabulary)),
                ]),
              )
              .toList(),
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.05) // Safe Space
        ]);
  }
}
