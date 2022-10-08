import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/dictionary/dictionary_entry.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';

class VocabularyDefinition extends StatelessWidget {
  final Vocabulary vocabulary;

  const VocabularyDefinition({super.key, required this.vocabulary});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ...vocabulary.entries
          .map((DictionaryEntry entry) => Align(
              alignment: Alignment.centerLeft,
              child: Text(entry.meanings.join('; '),
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: CupertinoColors.inactiveGray,
                      fontSize: 15,
                      overflow: TextOverflow.ellipsis))))
          .toList()
    ]);
  }
}
