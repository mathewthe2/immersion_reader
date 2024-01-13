import 'package:flutter/cupertino.dart';

class PopupDictionaryToolBar extends StatelessWidget {
  final Color backgroundColor;
  final VoidCallback dismissPopupDictionary;
  const PopupDictionaryToolBar(
      {super.key,
      required this.backgroundColor,
      required this.dismissPopupDictionary});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        height: 25,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 2.5, 10, 2.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                    onTap: dismissPopupDictionary,
                    child: const SizedBox(
                      width: 25,
                      child: Icon(CupertinoIcons.clear_thick,
                          size: 18, color: CupertinoColors.systemGrey),
                    ))
              ],
            )));
  }
}
