import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/extensions/context_extension.dart';

// temporary fix for text not rendering in the correct color when not inside cupertino widget on latest flutter
class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool? isDimmed;
  final List<int>? highlightCharacterIndexes;
  final TextOverflow? overflow;

  const AppText(this.data,
      {super.key,
      this.style,
      this.textAlign,
      this.isDimmed,
      this.highlightCharacterIndexes,
      this.overflow});

  @override
  Widget build(BuildContext context) {
    Color textColor = context.color(
        lightMode: CupertinoColors.black,
        darkMode: CupertinoColors.systemGroupedBackground);

    Color dimmedTextColor = context.color(
        lightMode: CupertinoColors.systemGrey,
        darkMode: CupertinoColors.systemGrey2);

    return Text(data,
        textAlign: textAlign,
        overflow: overflow,
        style: TextStyle(
                color: (isDimmed != null && isDimmed!)
                    ? dimmedTextColor
                    : textColor)
            .merge(style));
  }
}
