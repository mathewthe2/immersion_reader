import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/popup_dictionary_theme_data.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PitchWidget extends StatelessWidget {
  final Vocabulary vocabulary;
  final PopupDictionaryThemeData themeData;
  const PitchWidget(
      {super.key, required this.vocabulary, required this.themeData});
  static const double _widgetHeight = 34;
  static const double _widgetHeightOffset = 8;
  static const double _widgetHeightOffsetWithFurigana = 5;
  static const double _widgetWidthFactor = 0.5;

  String colorCorrectedPitch(String pitchSvg, BuildContext context) {
    pitchSvg = pitchSvg
        .replaceAll(RegExp(r'#000'), themeData.getPitchStrokeColorHex())
        .replaceAll(RegExp(r'#fff'), themeData.getPitchGraphContrastColorHex());
    return pitchSvg;
  }

  @override
  Widget build(BuildContext context) {
    if (vocabulary.pitchValues.isEmpty) {
      return const Text('');
    }
    switch (vocabulary.pitchAccentDisplayStyle) {
      case PitchAccentDisplayStyle.graph:
        {
          return SizedBox(
              height: _widgetHeight +
                  (vocabulary.reading!.isEmpty
                      ? _widgetHeightOffset
                      : _widgetHeightOffsetWithFurigana),
              width: MediaQuery.of(context).size.width * _widgetWidthFactor,
              child: ListView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...vocabulary.pitchValues.map((String pitchValue) =>
                        SvgPicture.string(
                            colorCorrectedPitch(pitchValue, context),
                            height: _widgetHeight))
                  ]));
        }
      case PitchAccentDisplayStyle.number:
        {
          return Padding(
              padding: EdgeInsets.only(
                  top: vocabulary.reading!.isEmpty
                      ? 0
                      : 20), // adjust for furigana height
              child: Text(
                vocabulary.pitchValues.map((value) => '[$value]').join(', '),
                style: TextStyle(
                    color:
                        themeData.getColor(DictionaryColor.pitchNumberColor)),
              ));
        }
      default:
        {
          return const Text('');
        }
    }
  }
}
