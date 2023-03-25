import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:immersion_reader/utils/system_dialog.dart';
import 'package:immersion_reader/widgets/browser/settings/cookies/browser_cookie_create_page.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:immersion_reader/dto/browser/browser_cookies.dart';
import 'package:immersion_reader/widgets/browser/settings/cookies/browser_cookie_edit_page.dart';
import "package:immersion_reader/extensions/string_extension.dart";

class BrowserCookieManagerPage extends StatefulWidget {
  final InAppWebViewController? webViewController;
  const BrowserCookieManagerPage({super.key, required this.webViewController});

  @override
  State<BrowserCookieManagerPage> createState() =>
      _BrowserCookieManagerPageState();
}

class _BrowserCookieManagerPageState extends State<BrowserCookieManagerPage> {
  ValueNotifier<bool> cookieManagerNotifier = ValueNotifier(false);
  CookieManager cookieManager = CookieManager.instance();
  Uri? url;
  bool editMode = false;

  Future<BrowserCookies?> getCookies() async {
    if (widget.webViewController != null) {
      url = await widget.webViewController!.getOriginalUrl();
      if (url != null) {
        List<Cookie> cookies = await cookieManager.getCookies(url: url!);
        return BrowserCookies(cookies: cookies, url: url!);
      }
    }
    return null;
  }

  void refreshCookieListScreen() {
    cookieManagerNotifier.value = !cookieManagerNotifier.value;
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
          middle: const Text('Cookies'),
          leading: !editMode
              ? null
              : CupertinoButton(
                  padding: const EdgeInsets.all(0.0),
                  child: const Icon(CupertinoIcons.plus),
                  onPressed: () {
                    setState(() {
                      editMode = !editMode;
                    });
                    Navigator.push(
                        context,
                        SwipeablePageRoute(
                            builder: (context) => BrowserCookieCreatePage(
                                  url: url,
                                  cookieManager: cookieManager,
                                  cookieManagerNotifier: cookieManagerNotifier,
                                )));
                  }),
          trailing: CupertinoButton(
            padding: const EdgeInsets.all(0.0),
            child: editMode
                ? const Text('Done',
                    style: TextStyle(fontWeight: FontWeight.bold))
                : const Text('Edit'), // const Icon(CupertinoIcons.plus),
            onPressed: () {
              setState(() {
                editMode = !editMode;
              });
            },
          ),
        ),
        child: SafeArea(
            child: ValueListenableBuilder(
                valueListenable: cookieManagerNotifier,
                builder: (context, val, child) {
                  return FutureBuilder<BrowserCookies?>(
                      future: getCookies(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data!.cookies.isNotEmpty) {
                          return SingleChildScrollView(
                              child: Column(children: [
                            CupertinoListSection(children: [
                              if (editMode)
                                CupertinoListTile(
                                  backgroundColor: CupertinoColors.systemFill
                                      .resolveFrom(context),
                                  title: const Center(
                                      child: Text('Clear cookies')),
                                  onTap: () {
                                    showAlertDialog(context,
                                        "Do you want to delete clear all cookies?",
                                        onConfirmCallback: () {
                                      cookieManager.deleteAllCookies();
                                      refreshCookieListScreen();
                                      setState(() {
                                        editMode = false;
                                      });
                                    });
                                  },
                                ),
                              ...snapshot.data!.cookies.map((Cookie cookie) =>
                                  CupertinoListTile(
                                      title: Text(cookie.name),
                                      leading: editMode
                                          ? GestureDetector(
                                              onTap: () => {
                                                showAlertDialog(context,
                                                    "Do you want to delete ${cookie.name}? \n\n Note: some cookies are automatically refetched by the website.",
                                                    onConfirmCallback: () {
                                                  if (url != null) {
                                                    cookieManager.deleteCookie(
                                                        url: url!,
                                                        name: cookie.name);
                                                    refreshCookieListScreen();
                                                  }
                                                })
                                              },
                                              child: const Icon(
                                                  CupertinoIcons
                                                      .minus_circle_fill,
                                                  color: CupertinoColors
                                                      .destructiveRed),
                                            )
                                          : null,
                                      trailing:
                                          const Icon(CupertinoIcons.forward),
                                      additionalInfo: Text(cookie.value
                                          .toString()
                                          .truncateTo(10)),
                                      onTap: () {
                                        Navigator.push(context,
                                            SwipeablePageRoute(
                                                builder: (context) {
                                          return BrowserCookieEditPage(
                                              cookieManager: cookieManager,
                                              cookieManagerNotifier:
                                                  cookieManagerNotifier,
                                              url: snapshot.data!.url,
                                              cookie: cookie);
                                        }));
                                      })),
                            ])
                          ]));
                        } else {
                          return Container();
                        }
                      });
                })));
  }
}
