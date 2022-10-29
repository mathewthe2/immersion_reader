import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/widgets/vocabulary/frequency_widget.dart';
import 'vocabulary_tile.dart';
import 'vocabulary_definition.dart';
import 'package:immersion_reader/storage/vocabulary_list_storage.dart';
import 'package:immersion_reader/utils/language_utils.dart';

class VocabularyTileList extends StatefulWidget {
  final List<Vocabulary> vocabularyList;
  final VocabularyListStorage? vocabularyListStorage;
  final DictionaryProvider dictionaryProvider;
  final String text;
  final int targetIndex;
  const VocabularyTileList(
      {super.key,
      required this.text,
      required this.targetIndex,
      required this.dictionaryProvider,
      required this.vocabularyList,
      required this.vocabularyListStorage});

  @override
  State<VocabularyTileList> createState() => _VocabularyTileListState();
}

class _VocabularyTileListState extends State<VocabularyTileList> {
  static int selectableCharacters = 5;
  List<String> existingVocabularyIds = [];
  int _selectedSegmentIndex = selectableCharacters ~/ 2;
  List<Vocabulary> vocabularyList = [];
  double initial = 0;
  double distance = 0;

  @override
  void initState() {
    super.initState();
    updateVocabulary(_selectedSegmentIndex);
  }

  Future<void> _checkExistsVocabulary(List<Vocabulary> vocabularyList) async {
    existingVocabularyIds = await widget.vocabularyListStorage!
        .getExistsVocabularyList(vocabularyList);
    setState(() {});
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

  List<String> _getNeighboringText(String text, int index) {
    if (text.isEmpty) {
      return [];
    }
    int halfCharacters = (selectableCharacters - 1) ~/ 2;
    String prefix = text.substring(max(0, index - halfCharacters), index);
    List<String> prefixList = [
      ...(' ' * (halfCharacters - prefix.length)).split(''),
      ...prefix.split('')
    ];
    String suffix = text.substring(min(index + 1, text.length),
        min(text.length, index + 1 + halfCharacters));
    List<String> suffixList = [
      ...suffix.split(''),
      ...(' ' * (halfCharacters - suffix.length)).split('')
    ];
    List<String> result = [
      ...prefixList,
      text[min(index, text.length - 1)],
      ...suffixList
    ];
    return result;
  }

  bool _canSelectIndex(int selectedIndex) {
    int index =
        widget.targetIndex + selectedIndex - ((selectableCharacters - 1) ~/ 2);
    if (index < 0 || index >= widget.text.length) {
      return false;
    }
    return widget.text[index].trim().isNotEmpty;
  }

  Future<void> updateVocabulary(int selectedIndex) async {
    int index =
        widget.targetIndex + selectedIndex - ((selectableCharacters - 1) ~/ 2);
    if (index < 0 || index >= widget.text.length) {
      return;
    }
    String sentence = widget.text.substring(index, widget.text.length);
    List<Vocabulary> vocabs =
        await widget.dictionaryProvider.findTerm(sentence);
    for (Vocabulary vocab in vocabs) {
      vocab.sentence = LanguageUtils.findSentence(widget.text, index);
    }
    setState(() {
      vocabularyList = vocabs;
    });
    _checkExistsVocabulary(vocabs);
  }

  Map<int, Widget> _createSelectableSegments(List<String> neighboringText) {
    return Map.fromIterables(
        [for (var i = 0; i < selectableCharacters; i++) i]
            .map((segmentIndex) => segmentIndex)
            .toList(),
        [for (var i = 0; i < selectableCharacters; i++) i]
            .map(
              (segmentIndex) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  neighboringText[segmentIndex],
                  style: const TextStyle(color: CupertinoColors.white),
                ),
              ),
            )
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    List<String> neighboringText =
        _getNeighboringText(widget.text, widget.targetIndex);
    Map<int, Widget> selectableSegments =
        _createSelectableSegments(neighboringText);
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoSlidingSegmentedControl<int>(
              thumbColor: const Color(
                  0xFF636366), // https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/cupertino/sliding_segmented_control.dart#L32
              groupValue: _selectedSegmentIndex,
              onValueChanged: (int? value) {
                if (value != null && _canSelectIndex(value)) {
                  setState(() {
                    _selectedSegmentIndex = value;
                  });
                  updateVocabulary(value);
                }
              },
              children: selectableSegments),
          GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (DragStartDetails details) {
                initial = details.globalPosition.dx;
              },
              onPanUpdate: (DragUpdateDetails details) {
                distance = details.globalPosition.dx - initial;
              },
              onPanEnd: (DragEndDetails details) {
                initial = 0.0;
                if (distance > 0) {
                  // swipe left
                  int newIndex =
                      min(selectableCharacters - 1, _selectedSegmentIndex + 1);
                  if (_canSelectIndex(newIndex)) {
                    setState(() {
                      _selectedSegmentIndex = newIndex;
                    });
                    updateVocabulary(newIndex);
                  }
                } else {
                  // swipe right
                  int newIndex = max(0, _selectedSegmentIndex - 1);
                  if (_canSelectIndex(newIndex)) {
                    setState(() {
                      _selectedSegmentIndex = newIndex;
                    });
                    updateVocabulary(newIndex);
                  }
                }
              },
              child: Container(
                  constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * .40 -
                          33.0), // approximate content height
                  child: vocabularyList.isEmpty
                      ? Container()
                      : Column(children: [
                          ...vocabularyList
                              .map(
                                (Vocabulary vocabulary) => Column(children: [
                                  CupertinoListTile(
                                      title: VocabularyTile(
                                          vocabulary: vocabulary,
                                          added: ifVocabularyExists(vocabulary),
                                          addOrRemoveVocabulary:
                                              addOrRemoveFromVocabularyList),
                                      trailing: CupertinoButton(
                                          onPressed: () =>
                                              addOrRemoveFromVocabularyList(
                                                  vocabulary),
                                          child: Icon(
                                            ifVocabularyExists(vocabulary)
                                                ? CupertinoIcons.star_fill
                                                : CupertinoIcons.star,
                                            size: 20,
                                          ))),
                                  if (vocabulary.frequencyTags.isNotEmpty)
                                    Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 20.0,
                                                end: 14.0,
                                                top: 5.0,
                                                bottom: 5.0),
                                        child: FrequencyWidget(
                                            parentContext: context,
                                            vocabulary: vocabulary)),
                                  Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          start: 20.0, end: 14.0),
                                      child: VocabularyDefinition(
                                          vocabulary: vocabulary)),
                                ]),
                              )
                              .toList(),
                          const SizedBox(height: 20) // Safe Space
                        ])))
        ]);
  }
}
