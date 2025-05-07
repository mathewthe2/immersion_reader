import 'dart:async';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class LoadingDialog {
  static final LoadingDialog _singleton = LoadingDialog._internal();
  LoadingDialog._internal();
  factory LoadingDialog() => _singleton;
  bool isCompleted = false;

  void showLoadingDialog(
      {required String msg,
      Duration delay = const Duration(milliseconds: 300)}) {
    isCompleted = false;
    late Timer timer;
    timer = Timer(delay, () {
      if (!isCompleted) {
        SmartDialog.showLoading(msg: msg);
      }
      timer.cancel();
    });
  }

  void dismissLoadingDialog() {
    isCompleted = true;
    SmartDialog.dismiss();
  }
}
