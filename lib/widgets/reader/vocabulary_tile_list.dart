import 'package:flutter/material.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'vocabulary_tile.dart';
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
  List<int> existingVocabularyIds = [];

  @override
  void initState() {
    super.initState();
    _checkExistsVocabulary();
  }

  Future<void> _checkExistsVocabulary() async {
    if (widget.vocabularyListStorage != null) {
      existingVocabularyIds = await widget.vocabularyListStorage!
          .getExistsVocabularyList(widget.vocabularyList
              .map((Vocabulary vocabulary) => vocabulary.vocabularyId ?? 0)
              .toList());
      setState(() {});
    }
  }

  Future<void> addOrRemoveFromVocabularyList(Vocabulary vocabulary) async {
    if (widget.vocabularyListStorage != null &&
        vocabulary.vocabularyId != null) {
      if (ifVocabularyExists(vocabulary)) {
        // remove vocabulary
        await widget.vocabularyListStorage!
            .deleteVocabularyItem(vocabulary.vocabularyId!);
        existingVocabularyIds.remove(vocabulary.vocabularyId!);
      } else {
        // add vocabulary
        await widget.vocabularyListStorage!.addVocabularyItem(vocabulary);
        existingVocabularyIds.add(vocabulary.vocabularyId!);
      }
      setState(() {});
    }
  }

  bool ifVocabularyExists(Vocabulary vocabulary) {
    return existingVocabularyIds.contains(vocabulary.vocabularyId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...ListTile.divideTiles(
              context: context,
              color: Colors.white70,
              tiles: widget.vocabularyList.map((Vocabulary vocabulary) =>
                  VocabularyTile(
                      vocabulary: vocabulary,
                      added: ifVocabularyExists(vocabulary),
                      addOrRemoveVocabulary:
                          addOrRemoveFromVocabularyList))).toList(),
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.05) // Safe Space
        ]);
  }
}
