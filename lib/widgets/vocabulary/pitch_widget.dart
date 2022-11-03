import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/dictionary/dictionary_options.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:flutter_svg/flutter_svg.dart';

String colorToHex(Color color) {
  return '#${color.value.toRadixString(16)}';
}

class PitchWidget extends StatelessWidget {
  final Vocabulary vocabulary;
  const PitchWidget({super.key, required this.vocabulary});

  String colorCorrectedPitch(String pitchSvg, BuildContext context) {
    final pitchGraphStrokeColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.darkBackgroundGray,
            darkColor: CupertinoColors.lightBackgroundGray),
        context);

    final pitchGraphContrastColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.lightBackgroundGray,
            darkColor: CupertinoColors.darkBackgroundGray),
        context);

    pitchSvg = pitchSvg
        .replaceAll(RegExp(r'#000'), colorToHex(pitchGraphStrokeColor))
        .replaceAll(RegExp(r'#fff'), colorToHex(pitchGraphContrastColor));
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
          return SvgPicture.string(
              colorCorrectedPitch(vocabulary.pitchValues[0], context),
              height: 30);
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
                style: const TextStyle(color: CupertinoColors.white),
              ));
        }
      default:
        {
          return const Text('');
        }
    }
  }
}
