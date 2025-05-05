import 'package:flutter/cupertino.dart';

class MultiStyleText extends StatelessWidget {
  final List<(String, TextStyle)> textStyleList;

  const MultiStyleText(this.textStyleList, {super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            children: List<InlineSpan>.from(textStyleList.map((textStyle) =>
                TextSpan(text: textStyle.$1, style: textStyle.$2)))));
  }
}
