import 'package:flutter/cupertino.dart';

class NumberPicker extends StatelessWidget {
  final int initialValue;
  final int maxValue;
  final Function(int) onSelectedItemChanged;
  const NumberPicker(
      {super.key,
      required this.initialValue,
      required this.maxValue,
      required this.onSelectedItemChanged});

  static const double _kItemExtent = 32.0;
  static const double _magnification = 1.22;
  static const double _squeeze = 1.2;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      magnification: _magnification,
      squeeze: _squeeze,
      useMagnifier: true,
      itemExtent: _kItemExtent,
      scrollController: FixedExtentScrollController(initialItem: initialValue),
      onSelectedItemChanged: onSelectedItemChanged,
      children: List<Widget>.generate(maxValue + 1, (int index) {
        return Center(
          child: Text(
            index.toString(),
          ),
        );
      }),
    );
  }
}
