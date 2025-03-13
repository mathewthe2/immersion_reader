import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/managers/dictionary/dictionary_manager.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:lean_file_picker/lean_file_picker.dart';
import 'package:immersion_reader/data/settings/dictionary_setting.dart';
import 'package:immersion_reader/dictionary/dictionary_parser.dart';
import 'package:immersion_reader/dictionary/user_dictionary.dart';
import 'package:immersion_reader/utils/system_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class DictionarySettings extends StatefulWidget {
  const DictionarySettings({super.key});

  @override
  State<DictionarySettings> createState() => _DictionarySettingsState();
}

enum DictionaryImportStage {
  extracting,
  parsing,
  dictionaryCreation,
  vocabInsertion,
  frequencyInsertion,
  pitchInsertion,
  savingData,
}

String importStageToString(DictionaryImportStage progress) {
  switch (progress) {
    case DictionaryImportStage.extracting:
      return "Extracting dictionary";
    case DictionaryImportStage.parsing:
      return "Parsing dictionary";
    case DictionaryImportStage.dictionaryCreation:
      return "Creating dictionary";
    case DictionaryImportStage.vocabInsertion:
      return "Inserting vocab data";
    case DictionaryImportStage.frequencyInsertion:
      return "Inserting frequency data";
    case DictionaryImportStage.pitchInsertion:
      return "Inserting pitch data";
    case DictionaryImportStage.savingData:
      return "Saving to database...";
  }
}

class _DictionarySettingsState extends State<DictionarySettings> {
  List<bool> enabledDictionaries = [];
  bool editMode = false;

  StreamController<(DictionaryImportStage, double)> progressController =
      StreamController<(DictionaryImportStage, double)>();

  void getEnabledDictionaries(List<DictionarySetting> dictSettings) {
    enabledDictionaries = dictSettings
        .map((DictionarySetting dictSetting) => dictSetting.enabled)
        .toList();
  }

  void resetProgressController() {
    progressController = StreamController<(DictionaryImportStage, double)>();
  }

  void requestDictionaryZipFile() async {
    final file = await pickFile(
      allowedExtensions: ['zip'],
    );

    if (file != null) {
      File zipFile = File(file.path);
      UserDictionary userDictionary = await parseDictionary(
          zipFile: zipFile, progressController: progressController);

      await SettingsManager().settingsStorage!.addDictionary(
          userDictionary: userDictionary,
          progressController: progressController);
      resetProgressController();
      setState(() {
        editMode = false;
      });
    } else {
      // User canceled the picker
    }
  }

  void removeDictionary(int dictionaryId) async {
    SmartDialog.showLoading(msg: "Removing dictionary");
    await SettingsManager().settingsStorage!.removeDictionary(dictionaryId);
    setState(() {
      editMode = false;
    });
    SmartDialog.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
            color: CupertinoColors.systemGroupedBackground,
            darkColor: CupertinoColors.black),
        context);

    return CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Dictionaries'),
          leading: editMode
              ? GestureDetector(
                  onTap: requestDictionaryZipFile,
                  child: const Icon(CupertinoIcons.plus))
              : GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(CupertinoIcons.left_chevron),
                ),
          trailing: CupertinoButton(
              onPressed: () {
                setState(() {
                  editMode = !editMode;
                });
              },
              padding: const EdgeInsets.all(0.0),
              child: editMode
                  ? const Text('Done',
                      style: TextStyle(fontWeight: FontWeight.bold))
                  : const Text('Edit')),
        ),
        child: FutureBuilder<List<DictionarySetting>>(
            future: SettingsManager().settingsStorage!.getDictionarySettings(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                getEnabledDictionaries(snapshot.data!);
                return SafeArea(
                    child: SingleChildScrollView(
                        child: Column(children: [
                  StreamBuilder<(DictionaryImportStage, double)>(
                    stream: progressController.stream,
                    builder: (context, streamSnapshot) {
                      if (streamSnapshot.connectionState ==
                          ConnectionState.active) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 20),
                            streamSnapshot.data!.$2 >=
                                    0 // stages with no progress value have negative progress
                                ? Text(
                                    '${importStageToString(streamSnapshot.data!.$1)}: ${streamSnapshot.data!.$2.round()}%')
                                : Text(importStageToString(
                                    streamSnapshot.data!.$1))
                          ],
                        );
                      } else {
                        return Container(); // No progress to show initially
                      }
                    },
                  ),
                  CupertinoListSection(
                      header: const Text('Dictionary'),
                      children: [
                        ...snapshot.data!.asMap().entries.map((entry) {
                          int index = entry.key;
                          DictionarySetting dictionarySetting = entry.value;
                          return CupertinoListTile(
                              title: Text(dictionarySetting.title),
                              leading: !editMode
                                  ? null
                                  : GestureDetector(
                                      onTap: () => {
                                        showAlertDialog(context,
                                            "Do you want to delete ${dictionarySetting.title}?",
                                            onConfirmCallback: () =>
                                                removeDictionary(
                                                    dictionarySetting.id))
                                      },
                                      child: const Icon(
                                          CupertinoIcons.minus_circle_fill,
                                          color:
                                              CupertinoColors.destructiveRed),
                                    ),
                              trailing: editMode
                                  ? const SizedBox()
                                  : CupertinoSwitch(
                                      value: enabledDictionaries[index],
                                      onChanged: (bool? value) {
                                        DictionaryManager()
                                            .toggleDictionaryEnabled(
                                                dictionarySetting);
                                        setState(() {});
                                      }));
                        }),
                      ]),
                ])));
              } else {
                return const CupertinoActivityIndicator(
                  animating: true,
                  radius: 24,
                );
              }
            }));
  }
}
