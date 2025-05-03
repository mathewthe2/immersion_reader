import 'package:flutter/cupertino.dart';

// temporary fix for text not rendering in the correct color when not inside cupertino widget on latest flutter
class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool? isHighlight;

  const AppText(this.data,
      {super.key, this.style, this.textAlign, this.isHighlight});

  @override
  Widget build(BuildContext context) {
    Color textColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.black,
            darkColor: CupertinoColors.systemGroupedBackground),
        context);

    Color backgroundColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
          color: Color(0xffffe694),
          darkColor: Color(0xff395a4f),
        ),
        context);

    return Text(data,
        textAlign: textAlign,
        style: TextStyle(
                color: textColor,
                backgroundColor: (isHighlight != null && isHighlight!)
                    ? backgroundColor
                    : null)
            .merge(style));
  }
}
