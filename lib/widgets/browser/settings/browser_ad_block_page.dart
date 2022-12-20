import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/settings/browser_setting.dart';
import 'package:immersion_reader/providers/browser_provider.dart';

class BrowserAdBlockPage extends StatefulWidget {
  final BrowserProvider? browserProvider;
  final ValueNotifier notifier;
  const BrowserAdBlockPage(
      {super.key, required this.browserProvider, required this.notifier});

  @override
  State<BrowserAdBlockPage> createState() => _BrowserAdBlockPageState();
}

class _BrowserAdBlockPageState extends State<BrowserAdBlockPage> {
  late TextEditingController _textController;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
        navigationBar: const CupertinoNavigationBar(middle: Text('Ad Block')),
        child: SafeArea(
            child: FutureBuilder<BrowserSetting>(
          future: widget.browserProvider!.getBrowserSettings(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              BrowserSetting browserSetting = snapshot.data!;
              _textController = TextEditingController(
                  text: browserSetting.urlFilters.join('\n'));
              return Column(children: [
                // CupertinoListTile(title: Text('studddff'))
                CupertinoListSection(children: [
                  CupertinoListTile(
                      title: const Text('Enable Ad Block'),
                      trailing: CupertinoSwitch(
                          onChanged: (bool? value) async {
                            await widget.browserProvider?.toggleEnableAdBlock(value!);
                            widget.notifier.value = !widget.notifier.value;
                            setState(() {});
                          },
                          value: browserSetting.enableAdBlock))
                ]),
                CupertinoListSection(
                    header: const Text('Url Filters'),
                    children: [
                      CupertinoTextField(
                          maxLines: 20,
                          minLines: 1,
                          controller: _textController,
                          onChanged: (value) async {
                            await widget.browserProvider
                                ?.updateUrlFilters(value.split('\n'));
                            widget.notifier.value = !widget.notifier.value;
                          },
                          decoration: BoxDecoration(
                              color: CupertinoDynamicColor.resolve(
                                  const CupertinoDynamicColor.withBrightness(
                                      color: CupertinoColors.white,
                                      darkColor: CupertinoColors.systemFill),
                                  context),
                              border: Border.all(
                                  color: CupertinoDynamicColor.resolve(
                                      const CupertinoDynamicColor
                                              .withBrightness(
                                          color: CupertinoColors
                                              .lightBackgroundGray,
                                          darkColor: CupertinoColors.white),
                                      context))))
                    ])
              ]);
            }
            return const Center(
                child: CupertinoActivityIndicator(
              animating: true,
              radius: 24,
            ));
          },
        )));
  }
}
