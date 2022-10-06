import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ruby_text/ruby_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:immersion_reader/util/language_utils.dart';

class VocabularyTile extends StatefulWidget {
  final Vocabulary vocabulary;
  final Function addOrRemoveVocabulary;
  final bool added;
  const VocabularyTile(
      {super.key,
      required this.vocabulary,
      required this.addOrRemoveVocabulary,
      this.added = false});

  @override
  State<VocabularyTile> createState() => _VocabularyTileState();
}

class _VocabularyTileState extends State<VocabularyTile> {
  String colorCorrectedPitch(String pitchSvg) {
    const String pitchGraphStrokeColor = '#FFF0F5';
    const String pitchGraphContrastColor = '#4B0082';
    pitchSvg = pitchSvg
        .replaceAll(RegExp(r'#000'), pitchGraphStrokeColor)
        .replaceAll(RegExp(r'#fff'), pitchGraphContrastColor);
    return pitchSvg;
  }

  Widget vocabularyPitch(Vocabulary vocabulary) {
    return (vocabulary.pitchSvg ?? []).isEmpty
        ? const Text('')
        : SvgPicture.string(colorCorrectedPitch(vocabulary.pitchSvg![0]),
            height: 30);
  }

  bool hasPitch(Vocabulary vocabulary) {
    return widget.vocabulary.pitchSvg != null &&
        widget.vocabulary.pitchSvg!.isNotEmpty;
  }

  Widget vocabularyExpression(Vocabulary vocabulary) {
    String? expression = vocabulary.expression;
    if (expression == null) {
      return const Text('');
    }
    String reading = vocabulary.reading ?? '';
    TextStyle expressionStyle = const TextStyle(
        fontWeight: FontWeight.w400, fontSize: 22, color: Colors.white70);
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
        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
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
                          ? vocabularyPitch(widget.vocabulary)
                          : Container()
                    ]),
                  ],
                ),
                CupertinoButton(
                    onPressed: () =>
                        widget.addOrRemoveVocabulary(widget.vocabulary),
                    child: Icon(
                      widget.added
                          ? CupertinoIcons.star_fill
                          : CupertinoIcons.star,
                      size: 20,
                    )),
                // IconButton(
                //     color: Colors.white70,
                //     icon: Icon(
                //         widget.added ? Icons.star : Icons.star_border_outlined),
                //     tooltip: 'Add to list',
                //     onPressed: () =>
                //         widget.addOrRemoveVocabulary(widget.vocabulary)),
              ]),
              Text(
                (widget.vocabulary.glossary ?? []).isEmpty
                    ? ''
                    : widget.vocabulary.glossary?.first ?? '',
                style: const TextStyle(color: Colors.white70),
              )
            ])));
  }
}
