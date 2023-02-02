import 'package:flutter/cupertino.dart';

class Divider extends StatelessWidget {
  final double? indent;
  final double? endIndent;
  final Color? color;
  const Divider({super.key, this.indent, this.endIndent, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 1,
        width: MediaQuery.of(context).size.width,
        color: color ?? CupertinoColors.systemBackground,
        margin: EdgeInsets.only(left: indent ?? 10.0, right: endIndent ?? 10.0),
      );
  }
}