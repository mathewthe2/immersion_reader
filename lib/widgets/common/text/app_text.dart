import 'package:flutter/cupertino.dart';

// temporary fix for text not rendering in the correct color when not inside cupertino widget on latest flutter
class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;

  const AppText(
    this.data, {
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.black,
            darkColor: CupertinoColors.systemGroupedBackground),
        context);

    return Text(data, style: TextStyle(color: textColor).merge(style));
  }
}
