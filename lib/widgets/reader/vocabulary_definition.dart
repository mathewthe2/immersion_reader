import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/dictionary/dictionary_entry.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';

class VocabularyDefinition extends StatefulWidget {
  final Vocabulary vocabulary;
  const VocabularyDefinition({super.key, required this.vocabulary});

  @override
  State<VocabularyDefinition> createState() => _VocabularyDefinitionState();
}

class _VocabularyDefinitionState extends State<VocabularyDefinition> {
  Map<DictionaryEntry, bool> definitionsExpanded = {};

  @override
  void initState() {
    super.initState();
    for (DictionaryEntry entry in widget.vocabulary.entries) {
      definitionsExpanded[entry] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ...widget.vocabulary.entries
          .map((DictionaryEntry entry) => GestureDetector(
              onTap: () {
                setState(() {
                  definitionsExpanded[entry] = !definitionsExpanded[entry]!;
                });
              },
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(entry.meanings.join('; '),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: CupertinoColors.inactiveGray,
                          fontSize: 15,
                          overflow: definitionsExpanded[entry]!
                              ? null
                              : TextOverflow.ellipsis)))))
          .toList()
    ]);
  }
}
