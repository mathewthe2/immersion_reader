import 'package:flutter/cupertino.dart';

extension ContextExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double spacer() => screenHeight * 0.02;
  double epic() => screenHeight * 0.2;
  double hero() => screenHeight * 0.4;
  double popup() => screenHeight * 0.6;
  double popupFull() => screenHeight * 0.7;
  EdgeInsets horizontalPadding() => EdgeInsets.only(left: 24, right: 24);
  EdgeInsets verticalPadding() =>
      EdgeInsets.only(top: spacer(), bottom: spacer());
}
