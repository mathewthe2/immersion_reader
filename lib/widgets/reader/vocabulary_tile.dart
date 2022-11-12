import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/popup_dictionary_theme_data.dart';
import 'package:immersion_reader/widgets/vocabulary/pitch_widget.dart';
import 'package:ruby_text/ruby_text.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/utils/language_utils.dart';

class VocabularyTile extends StatefulWidget {
  final Vocabulary vocabulary;
  final PopupDictionaryThemeData popupDictionaryThemeData;
  final Function addOrRemoveVocabulary;
  final bool added;
  const VocabularyTile(
      {super.key,
      required this.vocabulary,
      required this.popupDictionaryThemeData,
      required this.addOrRemoveVocabulary,
      this.added = false});

  @override
  State<VocabularyTile> createState() => _VocabularyTileState();
}

class _VocabularyTileState extends State<VocabularyTile> {
  bool hasPitch(Vocabulary vocabulary) {
    return vocabulary.pitchValues.isNotEmpty;
  }

  Widget vocabularyExpression(Vocabulary vocabulary) {
    String? expression = vocabulary.expression;
    if (expression == null) {
      return const Text('');
    }
    String reading = vocabulary.reading ?? '';
    TextStyle expressionStyle = TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 20,
        color: widget.popupDictionaryThemeData
            .getColor(DictionaryColor.primaryTextColor));
    if (reading.isEmpty) {
      return Text(expression, style: expressionStyle);
    }
    List<RubyTextData> furigana =
        LanguageUtils.distributeFurigana(term: expression, reading: reading);
    return RubyText(furigana, style: expressionStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Align(
            alignment: Alignment.centerLeft,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      vocabularyExpression(widget.vocabulary),
                      const SizedBox(width: 20),
                      hasPitch(widget.vocabulary)
                          ? PitchWidget(
                              vocabulary: widget.vocabulary,
                              themeData: widget.popupDictionaryThemeData)
                          : Container()
                    ]),
                  ],
                ),
              ]),
            ])));
  }
}
