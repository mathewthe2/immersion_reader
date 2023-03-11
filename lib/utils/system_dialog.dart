import 'package:flutter/cupertino.dart';

void showInfoDialog(BuildContext context, String message,
    {VoidCallback? onConfirmCallback}) {
  showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text('Information'),
            content: Text(message),
          ));
}

void showAlertDialog(BuildContext context, String message,
    {VoidCallback? onConfirmCallback}) {
  showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text('Alert'),
            content: Text(message),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('No'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                  if (onConfirmCallback != null) {
                    onConfirmCallback();
                  }
                },
                child: const Text('Yes'),
              ),
            ],
          ));
}
