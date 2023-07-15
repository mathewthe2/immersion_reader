import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/widgets/common/action_dialog.dart';
import 'package:immersion_reader/widgets/common/number_picker.dart';

class BrowserDarkReaderOption extends StatelessWidget {
  final String title;
  final int value;
  final Function(int) onSelectedItemChanged;
  const BrowserDarkReaderOption(
      {super.key,
      required this.title,
      required this.value,
      required this.onSelectedItemChanged});

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
        title: Text(title),
        trailing: Text(value.toString()),
        onTap: () {
          ActionDialog.show(
              title: 'Adjust $title',
              context: context,
              whenComplete: () {},
              child: NumberPicker(
                  initialValue: value,
                  maxValue: 100,
                  onSelectedItemChanged: onSelectedItemChanged));
        });
  }
}
