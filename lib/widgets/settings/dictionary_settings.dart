import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/settings/updates/dictionary_update.dart';
import 'package:immersion_reader/data/settings/updates/settings_update.dart';
import 'package:immersion_reader/managers/dictionary/dictionary_manager.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/data/settings/dictionary_setting.dart';
import 'package:immersion_reader/dictionary/dictionary_parser.dart';
import 'package:immersion_reader/dictionary/user_dictionary.dart';
import 'package:immersion_reader/utils/system_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:file_picker/file_picker.dart';

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
  writingData,
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
    case DictionaryImportStage.writingData:
      return "Writing to database...";
  }
}

class _DictionarySettingsState extends State<DictionarySettings> {
  List<bool> enabledDictionaries = [];
  bool editMode = false;
  bool? hasUpdates;
  DictionaryUpdate? availableDictionaryUpdate;
  int? idOfDictionaryToUpdate;

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
    final files = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (files != null && files.paths.isNotEmpty) {
      File zipFile = File(files.paths.first!);
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

  Future<void> removeDictionary(
      {required int dictionaryId,
      String message = 'Removing dictionary'}) async {
    SmartDialog.showLoading(msg: message);
    await SettingsManager().settingsStorage!.removeDictionary(dictionaryId);
    setState(() {
      editMode = false;
    });
    SmartDialog.dismiss();
  }

  Future<void> checkUpdates() async {
    // get current version
    var currentSettings =
        await SettingsManager().settingsStorage!.getDictionarySettings();
    for (final setting in currentSettings) {
      if (setting.title == SettingsUpdate.jmdictEnglishKey) {
        // check updates
        var updates = await SettingsManager().settingsStorage!.getUpdates();
        if (updates != null) {
          if (updates.dictionaryUpdate.extendedVersion >
              setting.extendedVersion) {
            setState(() {
              hasUpdates = true;
              availableDictionaryUpdate = updates.dictionaryUpdate;
              idOfDictionaryToUpdate = setting.id;
            });
          } else {
            setState(() {
              hasUpdates = false;
            });
          }
        }
      }
    }
  }

  Future<void> updateDictionary() async {
    if (availableDictionaryUpdate != null && idOfDictionaryToUpdate != null) {
      final zipFile = await availableDictionaryUpdate!.getUpdatedDictionary();
      if (zipFile != null) {
        UserDictionary userDictionary = await parseDictionary(
            zipFile: zipFile,
            progressController: progressController,
            dictionaryVersion: availableDictionaryUpdate!.version);
        await SettingsManager().settingsStorage!.addDictionary(
            userDictionary: userDictionary,
            progressController: progressController);
        resetProgressController();
        await removeDictionary(
            dictionaryId: idOfDictionaryToUpdate!,
            message: 'Removing old dictionary');
        setState(() {
          hasUpdates = false;
        });
      }
    }
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
                  switch (hasUpdates) {
                    null => CupertinoButton(
                        onPressed: checkUpdates,
                        child: const Text('Check for updates'),
                      ),
                    true => Column(children: [
                        Text(
                            'Version ${availableDictionaryUpdate!.version} for ${availableDictionaryUpdate!.dictionaryKey} is available.'),
                        CupertinoButton(
                          onPressed: updateDictionary,
                          child: const Text("Update dictionary"),
                        )
                      ]),
                    false => const Text("You're on the latest version!")
                  },
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
                                                    dictionaryId:
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
