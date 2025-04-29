import 'package:flutter/cupertino.dart';

// temporary fix for text not rendering in the correct color when not inside cupertino widget on latest flutter
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TextStyle? style;

  const AppButton({
    super.key,
    this.style,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.link, darkColor: CupertinoColors.systemCyan),
        context);

    return CupertinoButton(
      onPressed: onPressed,
      child: Text(label, style: TextStyle(color: textColor)),
    );
  }
}
