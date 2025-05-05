import 'package:flutter/cupertino.dart';

// temporary fix for text not rendering in the correct color when not inside cupertino widget on latest flutter
class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool? isDimmed;
  final List<int>? highlightCharacterIndexes;

  const AppText(this.data,
      {super.key,
      this.style,
      this.textAlign,
      this.isDimmed,
      this.highlightCharacterIndexes});

  @override
  Widget build(BuildContext context) {
    Color textColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.black,
            darkColor: CupertinoColors.systemGroupedBackground),
        context);

    Color dimmedTextColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.systemGrey,
            darkColor: CupertinoColors.systemGrey2),
        context);

    return Text(data,
        textAlign: textAlign,
        style: TextStyle(
                color: (isDimmed != null && isDimmed!)
                    ? dimmedTextColor
                    : textColor)
            .merge(style));
  }
}
