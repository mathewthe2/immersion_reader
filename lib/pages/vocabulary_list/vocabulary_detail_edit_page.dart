import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import "package:immersion_reader/extensions/string_extension.dart";
import 'package:immersion_reader/managers/navigation/navigation_manager.dart';
import 'package:immersion_reader/managers/vocabulary_list/vocabulary_list_manager.dart';
import 'package:immersion_reader/utils/system_dialog.dart';

class VocabularyDetailEditPage extends StatefulWidget {
  final Vocabulary vocabulary;
  const VocabularyDetailEditPage(
      {super.key, required this.vocabulary});

  @override
  State<VocabularyDetailEditPage> createState() =>
      _VocabularyDetailEditPageState();
}

class _VocabularyDetailEditPageState extends State<VocabularyDetailEditPage> {
  final Map<VocabularyInformationKey, TextEditingController>
      _textControllerMap = {};

  @override
  void initState() {
    super.initState();
    for (VocabularyInformationKey key in VocabularyInformationKey.values) {
      _textControllerMap[key] = TextEditingController(
          text: widget.vocabulary.getValueByInformationKey(key));
    }
  }

  @override
  void dispose() {
    for (TextEditingController controller in _textControllerMap.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget vocabularyEditField(
      VocabularyInformationKey key, BuildContext context) {
    return Column(children: [
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Align(
              alignment: Alignment.topLeft,
              child: Text(key.name.capitalize(),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoDynamicColor.resolve(
                          const CupertinoDynamicColor.withBrightness(
                              color: CupertinoColors.inactiveGray,
                              darkColor: CupertinoColors.systemGrey),
                          context))))),
      CupertinoScrollbar(
          child: CupertinoTextField(
              controller: _textControllerMap[key],
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                    const CupertinoDynamicColor.withBrightness(
                        color: CupertinoColors.white,
                        darkColor: CupertinoColors.systemFill),
                    context),
                border: Border.all(
                    color: CupertinoDynamicColor.resolve(
                        const CupertinoDynamicColor.withBrightness(
                            color: CupertinoColors.lightBackgroundGray,
                            darkColor: CupertinoColors.white),
                        context)),
              ),
              onChanged: (value) async {
                await VocabularyListManager()
                    .updateVocabularyItem(widget.vocabulary, key, value);
                NavigationManager().notifyVocabularyListPage();
              },
              maxLines: 10,
              minLines: 1,
              keyboardType: TextInputType.multiline))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: CupertinoPageScaffold(
            backgroundColor: CupertinoDynamicColor.resolve(
                const CupertinoDynamicColor.withBrightness(
                    color: CupertinoColors.systemGroupedBackground,
                    darkColor: CupertinoColors.label),
                context),
            navigationBar: CupertinoNavigationBar(
                middle: const Text('Edit'),
                trailing: CupertinoButton(
                    onPressed: () {
                      showAlertDialog(context,
                          "Do you want to delete ${widget.vocabulary.getValueByInformationKey(VocabularyInformationKey.expression)}?",
                          onConfirmCallback: () {
                        VocabularyListManager()
                            .deleteVocabularyItem(widget.vocabulary);
                        Navigator.pop(context);
                      });
                    },
                    padding: const EdgeInsets.all(0.0),
                    child: const Icon(CupertinoIcons.delete,
                        color: CupertinoColors.inactiveGray))),
            child: SafeArea(
                child: CupertinoScrollbar(
                    child: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                                children: VocabularyInformationKey.values
                                    .map(
                                      (value) =>
                                          vocabularyEditField(value, context),
                                    )
                                    .toList())))))));
  }
}
