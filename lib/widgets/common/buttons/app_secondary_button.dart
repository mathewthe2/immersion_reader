import 'package:flutter/cupertino.dart';

// temporary fix for text not rendering in the correct color when not inside cupertino widget on latest flutter
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TextStyle? style;

  const AppSecondaryButton({
    super.key,
    this.style,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.darkBackgroundGray,
            darkColor: CupertinoColors.inactiveGray),
        context);

    return CupertinoButton.tinted(
      onPressed: onPressed,
      color: CupertinoColors.secondarySystemFill,
      child: Text(label, style: TextStyle(color: textColor)),
    );
  }
}
