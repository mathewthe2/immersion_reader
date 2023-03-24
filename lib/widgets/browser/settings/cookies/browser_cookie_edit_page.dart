import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/extensions/string_extension.dart';
import 'package:immersion_reader/utils/system_dialog.dart';

enum CookieInformationKey { name, value, domain, expiration }

class BrowserCookieEditPage extends StatefulWidget {
  final CookieManager cookieManager;
  final Cookie cookie;
  final Uri url;
  final ValueNotifier<bool> cookieManagerNotifier;
  const BrowserCookieEditPage(
      {super.key,
      required this.cookieManager,
      required this.url,
      required this.cookie,
      required this.cookieManagerNotifier});

  @override
  State<BrowserCookieEditPage> createState() => _BrowserCookieEditPageState();
}

class _BrowserCookieEditPageState extends State<BrowserCookieEditPage> {
  final Map<CookieInformationKey, TextEditingController> _textControllerMap =
      {};
  late Cookie _currentCookie;

  static const List<CookieInformationKey> _nonEditableFields = [
    CookieInformationKey.expiration,
    CookieInformationKey.domain
  ];

  @override
  void initState() {
    super.initState();
    _currentCookie = Cookie(
        name: widget.cookie.name,
        value: widget.cookie.value,
        domain: widget.cookie.domain,
        expiresDate: widget.cookie.expiresDate);
    _textControllerMap[CookieInformationKey.name] =
        TextEditingController(text: widget.cookie.name);
    _textControllerMap[CookieInformationKey.value] =
        TextEditingController(text: widget.cookie.value);
    _textControllerMap[CookieInformationKey.domain] =
        TextEditingController(text: widget.cookie.domain);
    _textControllerMap[CookieInformationKey.expiration] = TextEditingController(
        text: widget.cookie.expiresDate == null
            ? '???'
            : DateTime.fromMillisecondsSinceEpoch(widget.cookie.expiresDate!)
                .toString());
  }

  @override
  void dispose() {
    for (TextEditingController controller in _textControllerMap.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void onChangeCookie(
      {required CookieInformationKey key, required String value}) {
    if (key == CookieInformationKey.name) {
      _currentCookie.name = value;
      widget.cookieManager
          .deleteCookie(name: widget.cookie.name, url: widget.url);
      widget.cookie.name = _currentCookie.name;
    } else if (key == CookieInformationKey.value) {
      _currentCookie.value = value;
    } else {
      return;
    }
    widget.cookieManager.setCookie(
        url: widget.url,
        name: _currentCookie.name,
        value: _currentCookie.value);
    widget.cookieManagerNotifier.value = !widget.cookieManagerNotifier.value;
  }

  Widget cookieEditField(
      {required CookieInformationKey key, required String value}) {
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
                              darkColor: CupertinoColors.inactiveGray),
                          context))))),
      CupertinoScrollbar(
          child: _nonEditableFields.contains(key)
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_textControllerMap[key]?.text ?? ''))
              : CupertinoTextField(
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
                  onChanged: (newValue) =>
                      onChangeCookie(key: key, value: newValue),
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
            middle: const Text('Edit'),
            trailing: CupertinoButton(
                onPressed: () {
                  showAlertDialog(context, "Do you want to delete this cookie?",
                      onConfirmCallback: () {
                    widget.cookieManager.deleteCookie(
                        url: widget.url, name: widget.cookie.name);
                    widget.cookieManagerNotifier.value =
                        !widget.cookieManagerNotifier.value;
                    Navigator.pop(context);
                  });
                },
                padding: const EdgeInsets.all(0.0),
                child: const Icon(CupertinoIcons.delete,
                    color: CupertinoColors.inactiveGray))),
        child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(children: [
                  ...CookieInformationKey.values.map((value) =>
                      cookieEditField(key: value, value: widget.cookie.name)),
                ]))));
  }
}
