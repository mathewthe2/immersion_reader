import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/widgets/settings/popup_dictionary_theme_settings.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import "package:immersion_reader/extensions/string_extension.dart";
import 'package:immersion_reader/providers/settings_provider.dart';
import 'package:immersion_reader/widgets/settings/pitch_accent_style_settings.dart';

class AppearanceSettings extends StatefulWidget {
  final SettingsProvider settingsProvider;

  const AppearanceSettings({super.key, required this.settingsProvider});

  @override
  State<AppearanceSettings> createState() => _AppearanceSettingsState();
}

class _AppearanceSettingsState extends State<AppearanceSettings> {
  final ValueNotifier<bool> _pitchAccentValueNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _popupDictionaryThemeValueNotifier =
      ValueNotifier(false);
  static const String dictionaryAppearanceLabel = 'Dictionary Appearance';
  static const String readerAppearanceLabel = 'Reader Appearance';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Appearance')),
        backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
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
                          settingsProvider: widget.settingsProvider,
                          popupDictionaryThemeString: widget
                              .settingsProvider
                              .settingsStorage!
                              .settingsCache!
                              .appearanceSetting
                              .popupDictionaryThemeString);
                    }));
                  },
                  additionalInfo: ValueListenableBuilder(
                      valueListenable: _popupDictionaryThemeValueNotifier,
                      builder: (context, val, child) => Text(widget
                          .settingsProvider
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
                          settingsProvider: widget.settingsProvider,
                          pitchAccentStyleString: widget
                              .settingsProvider
                              .settingsStorage!
                              .settingsCache!
                              .appearanceSetting
                              .pitchAccentStyleString);
                    }));
                  },
                  additionalInfo: ValueListenableBuilder(
                      valueListenable: _pitchAccentValueNotifier,
                      builder: (context, val, child) => Text(widget
                          .settingsProvider
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
                        widget.settingsProvider.toggleShowFrequencyTags(value!);
                        setState(() {});
                      },
                      value: widget.settingsProvider.settingsStorage!
                          .settingsCache!.appearanceSetting.showFrequencyTags)),
              CupertinoListTile(
                  title: const Text('Enable Slide Animation'),
                  trailing: CupertinoSwitch(
                      onChanged: (bool? value) {
                        widget.settingsProvider
                            .toggleEnableSlideAnimation(value!);
                        setState(() {});
                      },
                      value: widget
                          .settingsProvider
                          .settingsStorage!
                          .settingsCache!
                          .appearanceSetting
                          .enableSlideAnimation))
            ],
          ),
          CupertinoListSection(
              header: const Text(readerAppearanceLabel),
              children: [
                CupertinoListTile(
                    title: const Text('Enable Full Screen'),
                    onTap: () {
                      Navigator.push(context,
                          SwipeablePageRoute(builder: (context) {
                        return PopupDictionaryThemeSettings(
                            popupDictionaryThemeValueNotifier:
                                _popupDictionaryThemeValueNotifier,
                            settingsProvider: widget.settingsProvider,
                            popupDictionaryThemeString: widget
                                .settingsProvider
                                .settingsStorage!
                                .settingsCache!
                                .appearanceSetting
                                .popupDictionaryThemeString);
                      }));
                    },
                    trailing: CupertinoSwitch(
                        onChanged: (bool? value) {
                          widget.settingsProvider
                              .toggleEnableReaderFullScreen(value!);
                          setState(() {});
                        },
                        value: widget
                            .settingsProvider
                            .settingsStorage!
                            .settingsCache!
                            .appearanceSetting
                            .enableReaderFullScreen)),
              ])
        ])));
  }
}
