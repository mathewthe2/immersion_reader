import 'package:flutter/cupertino.dart';

class ActionDialog {
  static const String doneLabel = 'Done';

  static void show(
      {required String title,
      required Widget child,
      required VoidCallback whenComplete,
      required BuildContext context}) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => Container(
            height: MediaQuery.of(context).size.height * .40,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: Column(children: [
              Container(
                alignment: Alignment.topCenter,
                height: 50,
                decoration: BoxDecoration(
                    color:
                        CupertinoColors.systemBackground.resolveFrom(context),
                    border: Border(
                        bottom: BorderSide(
                            color: CupertinoColors.tertiarySystemFill
                                .resolveFrom(context)))),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.label.resolveFrom(context)),
                      ),
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: CupertinoButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(doneLabel,
                              style: TextStyle(
                                  color: CupertinoColors.label
                                      .resolveFrom(context))),
                        ))
                  ],
                ),
              ),
              Expanded(child: child)
            ]))).whenComplete(whenComplete);
  }
}
