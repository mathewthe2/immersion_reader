import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:immersion_reader/data/settings/dictionary_setting.dart';
import 'package:immersion_reader/dictionary/dictionary_parser.dart';
import 'package:immersion_reader/dictionary/user_dictionary.dart';
import 'package:immersion_reader/utils/system_dialog.dart';
import 'package:immersion_reader/providers/dictionary_provider.dart';

class DictionarySettings extends StatefulWidget {
  final DictionaryProvider dictionaryProvider;

  const DictionarySettings({super.key, required this.dictionaryProvider});

  @override
  State<DictionarySettings> createState() => _DictionarySettingsState();
}

class _DictionarySettingsState extends State<DictionarySettings> {
  List<bool> enabledDictionaries = [];
  bool isProcessingDictionary = false;
  bool editMode = false;

  void getEnabledDictionaries(List<DictionarySetting> dictSettings) {
    enabledDictionaries = dictSettings
        .map((DictionarySetting dictSetting) => dictSetting.enabled)
        .toList();
  }

  void requestDictionaryZipFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result != null) {
      setState(() {
        isProcessingDictionary = true;
      });
      File zipFile = File(result.files.single.path!);
      UserDictionary userDictionary = await parseDictionary(zipFile);
      await widget.dictionaryProvider.settingsProvider!.settingsStorage!
          .addDictionary(userDictionary);
      setState(() {
        isProcessingDictionary = false;
        editMode = false;
      });
    } else {
      // User canceled the picker
    }
  }

  void removeDictionary(int dictionaryId) async {
    setState(() {
      isProcessingDictionary = true;
    });
    await widget.dictionaryProvider.settingsProvider!.settingsStorage!
        .removeDictionary(dictionaryId);
    setState(() {
      isProcessingDictionary = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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
            future: widget.dictionaryProvider.settingsProvider!.settingsStorage!
                .getDictionarySettings(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                getEnabledDictionaries(snapshot.data!);
                return SafeArea(
                  child: CupertinoListSection(
                      header: const Text('Dictionary'),
                      children: [
                        ...snapshot.data!.asMap().entries.map((entry) {
                          int index = entry.key;
                          DictionarySetting dictionarySetting = entry.value;
                          return CupertinoListTile(
                              title: Text(dictionarySetting.title),
                              leading: editMode
                                  ? GestureDetector(
                                      onTap: () => {
                                        showAlertDialog(
                                            context,
                                            "Do you want to delete ${dictionarySetting.title}?",
                                            () => removeDictionary(
                                                dictionarySetting.id))
                                      },
                                      child: const Icon(
                                          CupertinoIcons.minus_circle_fill,
                                          color:
                                              CupertinoColors.destructiveRed),
                                    )
                                  : const SizedBox(),
                              trailing: editMode
                                  ? const SizedBox()
                                  : CupertinoSwitch(
                                      value: enabledDictionaries[index],
                                      onChanged: (bool? value) {
                                        widget.dictionaryProvider
                                            .toggleDictionaryEnabled(
                                                dictionarySetting);
                                        setState(() {});
                                      }));
                        }).toList(),
                        if (isProcessingDictionary)
                          const CupertinoActivityIndicator(
                            animating: true,
                            radius: 24,
                          )
                      ]),
                );
              } else {
                return const CupertinoActivityIndicator(
                  animating: true,
                  radius: 24,
                );
              }
            }));
  }
}
