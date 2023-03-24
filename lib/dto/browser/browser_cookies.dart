import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BrowserCookies {
  Uri url;
  List<Cookie> cookies;

  BrowserCookies({required this.cookies, required this.url});
}
