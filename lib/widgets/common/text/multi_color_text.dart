import 'package:flutter/cupertino.dart';

class MultiColorText extends StatelessWidget {
  final List<(String, Color)> textColorList;

  const MultiColorText(this.textColorList, {super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            children: List<InlineSpan>.from(textColorList.map((textColor) =>
                TextSpan(
                    text: textColor.$1,
                    style: TextStyle(color: textColor.$2))))));
  }
}
