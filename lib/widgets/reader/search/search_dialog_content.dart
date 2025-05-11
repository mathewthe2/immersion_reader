import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:immersion_reader/extensions/context_extension.dart';
import 'package:immersion_reader/managers/reader/reader_js_manager.dart';
import 'package:immersion_reader/widgets/common/text/multi_color_text.dart';

class SearchDialogContent extends StatefulWidget {
  const SearchDialogContent({super.key});

  @override
  State<SearchDialogContent> createState() => _SearchDialogContentState();
}

class _SearchDialogContentState extends State<SearchDialogContent> {
  late TextEditingController textController;
  List<String> results = [];

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  // TODO: use raw content parser in js
  String getRawContent(String elementHtml) {
    // Remove <script> and <style> blocks entirely
    var htmlContent = elementHtml.replaceAll(
        RegExp(r'<script[^>]*>[\s\S]*?<\/script>', caseSensitive: false), '');
    htmlContent = htmlContent.replaceAll(
        RegExp(r'<style[^>]*>[\s\S]*?<\/style>', caseSensitive: false), '');

    // Remove all remaining HTML tags
    htmlContent = htmlContent.replaceAll(RegExp(r'<[^>]+>'), '');

    // Trim and optionally collapse whitespace
    htmlContent = htmlContent.replaceAll(RegExp(r'\s+'), ' ').trim();
    return htmlContent;
  }

  void handleSearchSubmission(String input) async {
    if (input.isNotEmpty) {
      await ReaderJsManager().searchInBook(input);
    }
  }

  Color getColorForTextNodeSelection(int index) {
    if (index % 2 == 0) {
      return CupertinoColors.extraLightBackgroundGray;
    } else {
      return CupertinoColors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        direction: DismissDirection.down,
        key: UniqueKey(),
        resizeDuration: Duration(milliseconds: 100),
        onDismissed: (_) => SmartDialog.dismiss(),
        child: Container(
            height: context.popupFull(),
            width: context.screenWidth,
            color: CupertinoColors.white,
            child: Column(
              children: [
                SizedBox(height: context.spacer()),
                Text("Search (work in progress)",
                    style: TextStyle(fontSize: 20)),
                CupertinoSearchTextField(
                    style: TextStyle(color: CupertinoColors.black),
                    controller: textController,
                    onSubmitted: handleSearchSubmission),
                SizedBox(height: context.spacer()),
                ValueListenableBuilder(
                    valueListenable: ReaderJsManager().searchResultsNotifier,
                    builder: (context, val, _) {
                      return Expanded(
                          child: CupertinoScrollbar(
                              child: SingleChildScrollView(
                                  child: Column(children: [
                        ...val.mapIndexed((index, result) => CupertinoListTile(
                            title: MultiColorText([
                              (
                                '${result.characterCount}',
                                CupertinoColors.inactiveGray
                              ),
                              (result.sentence ?? "", CupertinoColors.black),
                            ]),
                            onTap: () {
                              if (result.characterCount != null) {
                                ReaderJsManager()
                                    .cueToCharacter(result.characterCount!);
                              }
                            },
                            backgroundColor:
                                getColorForTextNodeSelection(index)))
                      ]))));
                    })
              ],
            )));
  }
}
