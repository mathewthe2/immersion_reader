import 'package:flutter/cupertino.dart';

void showAlertDialog(
    BuildContext context, String message, VoidCallback onConfirmCallback) {
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
                  onConfirmCallback();
                },
                child: const Text('Yes'),
              ),
            ],
          ));
}
