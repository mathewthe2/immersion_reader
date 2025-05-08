import 'dart:async';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class LoadingDialog {
  static final LoadingDialog _singleton = LoadingDialog._internal();
  LoadingDialog._internal();
  factory LoadingDialog() {
    _singleton.isCompleted = false;
    return _singleton;
  }
  bool isCompleted = false;

  Future<void> showLoadingDialog(
      {required String msg,
      Duration delay = const Duration(milliseconds: 300)}) async {
    await Future.delayed(delay);
    if (!isCompleted) {
      SmartDialog.showLoading(msg: msg);
    }
  }

  void dismissLoadingDialog() {
    isCompleted = true;
    SmartDialog.dismiss();
  }
}
