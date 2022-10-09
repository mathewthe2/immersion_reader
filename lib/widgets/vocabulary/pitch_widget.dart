import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import 'package:flutter_svg/flutter_svg.dart';

String colorToHex(Color color) {
  return '#${color.value.toRadixString(16)}';
}

class PitchWidget extends StatelessWidget {
  final BuildContext parentContext;
  final Vocabulary vocabulary;
  const PitchWidget(
      {super.key, required this.parentContext, required this.vocabulary});

  String colorCorrectedPitch(String pitchSvg) {
    final pitchGraphStrokeColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.darkBackgroundGray,
            darkColor: CupertinoColors.lightBackgroundGray),
        parentContext);

    final pitchGraphContrastColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.lightBackgroundGray,
            darkColor: CupertinoColors.darkBackgroundGray),
        parentContext);

    pitchSvg = pitchSvg
        .replaceAll(RegExp(r'#000'), colorToHex(pitchGraphStrokeColor))
        .replaceAll(RegExp(r'#fff'), colorToHex(pitchGraphContrastColor));
    return pitchSvg;
  }

  @override
  Widget build(BuildContext context) {
    return (vocabulary.pitchSvg ?? []).isEmpty
        ? const Text('')
        : SvgPicture.string(colorCorrectedPitch(vocabulary.pitchSvg![0]),
            height: 30);
  }
}
