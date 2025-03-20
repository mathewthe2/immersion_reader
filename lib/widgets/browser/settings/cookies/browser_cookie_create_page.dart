import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/extensions/string_extension.dart';

enum CookieCreateInformationKey { name, value, url }

class BrowserCookieCreatePage extends StatefulWidget {
  final Uri? url;
  final CookieManager cookieManager;
  final VoidCallback refreshCookieListScreen;
  const BrowserCookieCreatePage(
      {super.key,
      required this.url,
      required this.cookieManager,
      required this.refreshCookieListScreen});

  @override
  State<BrowserCookieCreatePage> createState() =>
      _BrowserCookieCreatePageState();
}

class _BrowserCookieCreatePageState extends State<BrowserCookieCreatePage> {
  final Map<CookieCreateInformationKey, TextEditingController>
      _textControllerMap = {};
  bool canCreate = false;

  @override
  void initState() {
    super.initState();
    _textControllerMap[CookieCreateInformationKey.name] =
        TextEditingController(text: '');
    _textControllerMap[CookieCreateInformationKey.value] =
        TextEditingController(text: '');
    _textControllerMap[CookieCreateInformationKey.url] = TextEditingController(
        text: widget.url == null ? '' : widget.url.toString());
  }

  void checkIfCanCreate() {
    String name = _textControllerMap[CookieCreateInformationKey.name]!.text;
    setState(() {
      canCreate = name.isNotEmpty;
    });
  }

  void onCreateCookie() async {
    String url = _textControllerMap[CookieCreateInformationKey.url]!.text;
    String name = _textControllerMap[CookieCreateInformationKey.name]!.text;
    String value = _textControllerMap[CookieCreateInformationKey.value]!.text;
    await widget.cookieManager.setCookie(
      url: WebUri(url),
      name: name,
      value: value.isEmpty ? ' ' : value, // value cannot be empty
      // expiresDate: ,
      isSecure: true,
    );
    widget.refreshCookieListScreen();
  }

  Widget cookieEditField(
      {required CookieCreateInformationKey key, required String value}) {
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
                              darkColor: CupertinoColors.systemGrey),
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
              onChanged: (_) => checkIfCanCreate(),
              maxLines: 10,
              minLines: 1,
              keyboardType: TextInputType.multiline))
    ]);
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
            middle: const Text('Create Cookie'),
            trailing: CupertinoButton(
                onPressed: canCreate ? () => onCreateCookie() : null,
                padding: const EdgeInsets.all(0.0),
                child: const Text('Create'))),
        child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(children: [
                  ...CookieCreateInformationKey.values
                      .map((value) => cookieEditField(key: value, value: '')),
                ]))));
  }
}
