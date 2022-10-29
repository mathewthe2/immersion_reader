import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/japanese/vocabulary.dart';
import "package:immersion_reader/extensions/string_extension.dart";

class VocabularyDetailEditPage extends StatefulWidget {
  final Vocabulary vocabulary;
  const VocabularyDetailEditPage({super.key, required this.vocabulary});

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
                              darkColor: CupertinoColors.inactiveGray),
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
        maxLines: 10,
        minLines: 1,
      ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: CupertinoDynamicColor.resolve(
            const CupertinoDynamicColor.withBrightness(
                color: CupertinoColors.lightBackgroundGray,
                darkColor: CupertinoColors.label),
            context),
        navigationBar: const CupertinoNavigationBar(middle: Text('Edit')),
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
                                .toList()))))));
  }
}
