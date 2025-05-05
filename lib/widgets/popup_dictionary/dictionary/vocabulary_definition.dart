import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/popup_dictionary_theme_data.dart';
import 'package:immersion_reader/dictionary/dictionary_entry.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';

class VocabularyDefinition extends StatefulWidget {
  final Vocabulary vocabulary;
  final PopupDictionaryThemeData popupDictionaryThemeData;
  const VocabularyDefinition(
      {super.key,
      required this.vocabulary,
      required this.popupDictionaryThemeData});

  @override
  State<VocabularyDefinition> createState() => _VocabularyDefinitionState();
}

class _VocabularyDefinitionState extends State<VocabularyDefinition> {
  Map<DictionaryEntry, bool> definitionsExpanded = {};

  @override
  void initState() {
    super.initState();
    resetExpandedDefinitions();
  }

  void resetExpandedDefinitions() {
    for (DictionaryEntry entry in widget.vocabulary.entries) {
      definitionsExpanded[entry] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ...widget.vocabulary.entries.map((DictionaryEntry entry) =>
          GestureDetector(
              onTap: () {
                if (definitionsExpanded[entry] == null) {
                  // workaround when widget.vocabulary is updated but definitionExpanded is stall
                  resetExpandedDefinitions();
                }
                if (definitionsExpanded[entry] != null) {
                  setState(() {
                    definitionsExpanded[entry] = !definitionsExpanded[entry]!;
                  });
                }
              },
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(entry.meanings.join('; '),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: widget.popupDictionaryThemeData
                              .getColor(DictionaryColor.secondaryTextColor),
                          fontSize: 15,
                          overflow: definitionsExpanded.containsKey(entry) &&
                                  definitionsExpanded[entry]!
                              ? null
                              : TextOverflow.ellipsis)))))
    ]);
  }
}
