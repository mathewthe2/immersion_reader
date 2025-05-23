import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/managers/settings/settings_manager.dart';
import 'package:immersion_reader/widgets/settings/popup_dictionary_theme_settings.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import "package:immersion_reader/extensions/string_extension.dart";
import 'package:immersion_reader/widgets/settings/pitch_accent_style_settings.dart';

class AppearanceSettings extends StatefulWidget {
  const AppearanceSettings({super.key});

  @override
  State<AppearanceSettings> createState() => _AppearanceSettingsState();
}

class _AppearanceSettingsState extends State<AppearanceSettings> {
  final ValueNotifier<bool> _pitchAccentValueNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _popupDictionaryThemeValueNotifier =
      ValueNotifier(false);
  static const String dictionaryAppearanceLabel = 'Dictionary Appearance';
  static const String readerAppearanceLabel = 'Reader Appearance';
  bool _showFrequencyTags =
      SettingsManager().cachedAppearanceSettings().showFrequencyTags;
  bool _enableFullScreen =
      SettingsManager().cachedAppearanceSettings().enableReaderFullScreen;
  bool _enableSlideAnimation =
      SettingsManager().cachedAppearanceSettings().enableSlideAnimation;
  bool _enableLookupHighlight =
      SettingsManager().cachedAppearanceSettings().enableLookupHighlight;
  bool _allowLookupWhilePopupActive =
      SettingsManager().cachedAppearanceSettings().allowLookupWhilePopupActive;
  bool _isKeepScreenOn =
      SettingsManager().cachedAppearanceSettings().isKeepScreenOn;
  bool _isShowDeviceStatusBar =
      SettingsManager().cachedAppearanceSettings().isShowDeviceStatusBar;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Appearance')),
        backgroundColor:
            CupertinoColors.systemGroupedBackground.resolveFrom(context),
        child: SafeArea(
            child: Column(children: [
          CupertinoListSection(
            header: const Text(dictionaryAppearanceLabel),
            children: [
              CupertinoListTile(
                  title: const Text('Dictionary Theme'),
                  onTap: () {
                    Navigator.push(context,
                        SwipeablePageRoute(builder: (context) {
                      return PopupDictionaryThemeSettings(
                          popupDictionaryThemeValueNotifier:
                              _popupDictionaryThemeValueNotifier,
                          popupDictionaryThemeString: SettingsManager()
                              .settingsStorage!
                              .settingsCache!
                              .appearanceSetting
                              .popupDictionaryThemeString);
                    }));
                  },
                  additionalInfo: ValueListenableBuilder(
                      valueListenable: _popupDictionaryThemeValueNotifier,
                      builder: (context, val, child) => Text(SettingsManager()
                          .settingsStorage!
                          .settingsCache!
                          .appearanceSetting
                          .popupDictionaryThemeString
                          .capitalize())),
                  trailing: const Icon(CupertinoIcons.forward)),
              CupertinoListTile(
                  title: const Text('Pitch Accent Style'),
                  onTap: () {
                    Navigator.push(context,
                        SwipeablePageRoute(builder: (context) {
                      return PitchAccentStyleSettings(
                          pitchAccentValueNotifier: _pitchAccentValueNotifier,
                          pitchAccentStyleString: SettingsManager()
                              .settingsStorage!
                              .settingsCache!
                              .appearanceSetting
                              .pitchAccentStyleString);
                    }));
                  },
                  additionalInfo: ValueListenableBuilder(
                      valueListenable: _pitchAccentValueNotifier,
                      builder: (context, val, child) => Text(SettingsManager()
                          .settingsStorage!
                          .settingsCache!
                          .appearanceSetting
                          .pitchAccentStyleString
                          .capitalize())),
                  trailing: const Icon(CupertinoIcons.forward)),
              CupertinoListTile(
                  title: const Text('Show Frequency Tags'),
                  trailing: CupertinoSwitch(
                      onChanged: (bool? value) {
                        SettingsManager().toggleShowFrequencyTags(value!);
                        setState(() {
                          _showFrequencyTags = value;
                        });
                      },
                      value: _showFrequencyTags)),
              CupertinoListTile(
                  title: const Text('Allow Lookup while Popup Active'),
                  trailing: CupertinoSwitch(
                      onChanged: (bool? value) {
                        SettingsManager()
                            .toggleAllowLookupWhilePopupActive(value!);
                        setState(() {
                          _allowLookupWhilePopupActive = value;
                        });
                      },
                      value: _allowLookupWhilePopupActive)),
              Platform.isIOS
                  ? CupertinoListTile(
                      title: const Text('Enable Slide Animation'),
                      trailing: CupertinoSwitch(
                          onChanged: (bool? value) {
                            SettingsManager()
                                .toggleEnableSlideAnimation(value!);
                            setState(() {
                              _enableSlideAnimation = value;
                            });
                          },
                          value: _enableSlideAnimation))
                  : Container(),
              CupertinoListTile(
                  title: const Text('Enable Highlights (Beta)'),
                  trailing: CupertinoSwitch(
                      onChanged: (bool? value) {
                        SettingsManager().toggleEnableLookupHighlight(value!);
                        setState(() {
                          _enableLookupHighlight = value;
                        });
                      },
                      value: _enableLookupHighlight))
            ],
          ),
          CupertinoListSection(
              header: const Text(readerAppearanceLabel),
              children: [
                CupertinoListTile(
                    title: const Text('Enable Full Screen'),
                    trailing: CupertinoSwitch(
                        onChanged: (bool? value) {
                          SettingsManager()
                              .toggleEnableReaderFullScreen(value!);
                          setState(() {
                            _enableFullScreen = value;
                          });
                        },
                        value: _enableFullScreen)),
                CupertinoListTile(
                    title: const Text('Keep Screen On'),
                    trailing: CupertinoSwitch(
                        onChanged: (bool? value) {
                          SettingsManager().toggleKeepScreenOn(value!);
                          setState(() {
                            _isKeepScreenOn = value;
                          });
                        },
                        value: _isKeepScreenOn)),
                CupertinoListTile(
                    title: const Text('Show Top Status Bar'),
                    trailing: CupertinoSwitch(
                        onChanged: (bool? value) {
                          SettingsManager().toggleShowDeviceStatusBar(value!);
                          setState(() {
                            _isShowDeviceStatusBar = value;
                          });
                        },
                        value: _isShowDeviceStatusBar)),
              ])
        ])));
  }
}
