import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';
import "package:immersion_reader/storage/settings_storage.dart";
import 'package:immersion_reader/data/settings/dictionary_setting.dart';
import 'package:immersion_reader/dictionary/dictionary_parser.dart';
import 'package:immersion_reader/dictionary/user_dictionary.dart';

class DictionarySettings extends StatefulWidget {
  final SettingsStorage storage;

  const DictionarySettings({super.key, required this.storage});

  @override
  State<DictionarySettings> createState() => _DictionarySettingsState();
}

class _DictionarySettingsState extends State<DictionarySettings> {
  List<bool> enabledDictionaries = [];
  bool isAddingDictionary = false;

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
        isAddingDictionary = true;
      });
      File zipFile = File(result.files.single.path!);
      UserDictionary userDictionary = await parseDictionary(zipFile);
      await widget.storage.addDictionary(userDictionary);
      setState(() {
        isAddingDictionary = false;
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Dictionary Settings'),
          trailing: GestureDetector(
              onTap: requestDictionaryZipFile,
              child: const Icon(CupertinoIcons.plus)),
        ),
        child: FutureBuilder<List<DictionarySetting>>(
            future: widget.storage.getDictionarySettings(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                getEnabledDictionaries(snapshot.data!);
                return Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.05),
                    child: Column(children: [
                      CupertinoListSection(
                          header: const Text('Dictionary'),
                          children: <CupertinoListTile>[
                            ...snapshot.data!.asMap().entries.map((entry) {
                              int index = entry.key;
                              DictionarySetting dictionarySetting = entry.value;
                              return CupertinoListTile(
                                  title: Text(dictionarySetting.title),
                                  trailing: CupertinoSwitch(
                                      value: enabledDictionaries[index],
                                      onChanged: (bool? value) {
                                        widget.storage.toggleDictionaryEnabled(
                                            dictionarySetting);
                                        setState(() {});
                                      }));
                            }).toList()
                          ]),
                      if (isAddingDictionary)
                        const CupertinoActivityIndicator(
                          animating: true,
                          radius: 24,
                        )
                    ]));
              } else {
                return const CupertinoActivityIndicator(
                  animating: true,
                  radius: 24,
                );
              }
            }));
  }
}
