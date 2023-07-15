import 'package:flutter/cupertino.dart';

class IconListTile extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;
  const IconListTile(
      {super.key,
      required this.title,
      required this.iconData,
      required this.iconBackgroundColor,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
        title: Text(title),
        leading: Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Icon(size: 22, iconData, color: CupertinoColors.white),
        ),
        trailing: onTap == null ? null : const Icon(CupertinoIcons.forward),
        onTap: onTap);
  }
}
