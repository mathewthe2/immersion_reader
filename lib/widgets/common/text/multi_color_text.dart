import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/widgets/common/text/multi_style_text.dart';

class MultiColorText extends StatelessWidget {
  final List<(String, Color)> textColorList;

  const MultiColorText(this.textColorList, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiStyleText(textColorList
        .map((textColor) => (textColor.$1, TextStyle(color: textColor.$2)))
        .toList());
  }
}
