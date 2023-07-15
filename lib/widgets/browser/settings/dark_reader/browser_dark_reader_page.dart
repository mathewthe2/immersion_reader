import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/settings/browser/browser_setting.dart';
import 'package:immersion_reader/data/settings/browser/dark_reader_setting.dart';
import 'package:immersion_reader/managers/browser/browser_manager.dart';
import 'package:immersion_reader/widgets/browser/settings/dark_reader/browser_dark_reader_option.dart';

class BrowserDarkReaderPage extends StatefulWidget {
  final ValueNotifier notifier;
  const BrowserDarkReaderPage({super.key, required this.notifier});

  @override
  State<BrowserDarkReaderPage> createState() => _BrowserDarkReaderPageState();
}

class _BrowserDarkReaderPageState extends State<BrowserDarkReaderPage> {
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
            middle: const Text('Dark Reader'),
            trailing: CupertinoButton(
              padding: const EdgeInsets.all(0.0),
              child: const Text('Reset'),
              onPressed: () async {
                // reset dark reader options to default
                await BrowserManager().updateDarkReaderSettings(
                    DarkReaderSetting.defaultSetting());
                widget.notifier.value = !widget.notifier.value;
                setState(() {});
              },
            )),
        child: SafeArea(
            child: FutureBuilder<BrowserSetting>(
                future: BrowserManager().getBrowserSettings(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    BrowserSetting browserSetting = snapshot.data!;
                    return Column(children: [
                      CupertinoListSection(children: [
                        CupertinoListTile(
                            title: const Text('Enable Dark Reader'),
                            trailing: CupertinoSwitch(
                                onChanged: (bool? value) async {
                                  await BrowserManager()
                                      .toggleEnableDarkReader(value!);
                                  widget.notifier.value =
                                      !widget.notifier.value;
                                  setState(() {});
                                },
                                value: browserSetting.enableDarkReader)),
                      ]),
                      CupertinoListSection(
                          header: const Text('Options'),
                          children: [
                            BrowserDarkReaderOption(
                                title: 'Brightness',
                                value:
                                    browserSetting.darkReaderSetting.brightness,
                                onSelectedItemChanged:
                                    (int selectedItem) async {
                                  browserSetting.darkReaderSetting.brightness =
                                      selectedItem;
                                  await BrowserManager()
                                      .updateDarkReaderSettings(
                                          browserSetting.darkReaderSetting);
                                  widget.notifier.value =
                                      !widget.notifier.value;
                                  setState(() {});
                                }),
                            BrowserDarkReaderOption(
                                title: 'Contrast',
                                value:
                                    browserSetting.darkReaderSetting.contrast,
                                onSelectedItemChanged:
                                    (int selectedItem) async {
                                  browserSetting.darkReaderSetting.contrast =
                                      selectedItem;
                                  await BrowserManager()
                                      .updateDarkReaderSettings(
                                          browserSetting.darkReaderSetting);
                                  widget.notifier.value =
                                      !widget.notifier.value;
                                  setState(() {});
                                }),
                            BrowserDarkReaderOption(
                                title: 'Sepia',
                                value: browserSetting.darkReaderSetting.sepia,
                                onSelectedItemChanged:
                                    (int selectedItem) async {
                                  browserSetting.darkReaderSetting.sepia =
                                      selectedItem;
                                  await BrowserManager()
                                      .updateDarkReaderSettings(
                                          browserSetting.darkReaderSetting);
                                  widget.notifier.value =
                                      !widget.notifier.value;
                                  setState(() {});
                                }),
                          ])
                    ]);
                  }
                  return const Center(
                      child: CupertinoActivityIndicator(
                    animating: true,
                    radius: 24,
                  ));
                })));
  }
}
