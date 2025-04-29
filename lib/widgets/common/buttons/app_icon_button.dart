import 'package:flutter/cupertino.dart';

class AppIconButton extends StatelessWidget {
  final IconData iconData;
  final VoidCallback? onPressed;

  const AppIconButton(
    this.iconData, {
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor = CupertinoDynamicColor.resolve(
        CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.black.withValues(alpha: 0.25),
            darkColor:
                CupertinoColors.systemGroupedBackground.withValues(alpha: 0.7)),
        context);

    return CupertinoButton(
        onPressed: onPressed,
        child: Icon(
          iconData,
          color: iconColor,
        ));
  }
}
