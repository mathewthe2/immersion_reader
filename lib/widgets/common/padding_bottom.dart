import 'package:flutter/cupertino.dart';

class PaddingBottom extends StatelessWidget {
  final Widget? child;
  const PaddingBottom({super.key, this.child});
  static double bottomPaddingFactor = 0.1;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * bottomPaddingFactor),
        child: child);
  }
}
