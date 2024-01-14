import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAssetsServerManager {
  LocalAssetsServer? server;
  SharedPreferences? _sharedPreferences;
  String domain = "localhost";

  /// This port should ideally not conflict but should remain the same for
  /// caching purposes.
  static int get port => 52062;
  static String get preferencesDomain => 'localAssetsDomain';
  static List<String> get _testDomains => [
        "localhost",
        "127.0.0.1"
      ]; // some phones only work with 127.0.0.1, but working domain should work throughout lifecycle of app

  static final LocalAssetsServerManager _singleton =
      LocalAssetsServerManager._internal();
  LocalAssetsServerManager._internal();

  factory LocalAssetsServerManager() => _singleton;

  factory LocalAssetsServerManager.create(SharedPreferences sharedPreferences) {
    _singleton._sharedPreferences = sharedPreferences;
    // create has to be called first to init server
    _singleton.server = LocalAssetsServer(
      address: InternetAddress.loopbackIPv4,
      assetsBasePath: 'assets/ttu-ebook-reader',
      logger: const DebugLogger(),
      port: port,
    );
    return _singleton;
  }

  String getAssetUrl() {
    if (_sharedPreferences != null &&
        _sharedPreferences?.getString(preferencesDomain) != null) {
      String localAssetsDomain =
          _sharedPreferences!.getString(preferencesDomain)!;
      return 'http://$localAssetsDomain:$port';
    }
    return 'http://$domain:$port';
  }

  Future<bool?> testRun(String domain) async {
    bool iWebViewLoaded = false;
    bool isManagerLoaded = false;
    HeadlessInAppWebView webView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
          url: Uri.parse(
        'http://$domain:$port',
      )),
      onLoadStop: (controller, url) async {
        iWebViewLoaded = true;
      },
      onConsoleMessage: (controller, message) {
        if (message.toString().contains("manager")) {
          isManagerLoaded = true;
        }
      },
    );

    try {
      await webView.run();
      await Future.delayed(
          const Duration(seconds: 1)); // wait for web view to load
      if (!iWebViewLoaded) {
        await Future.delayed(
            const Duration(seconds: 3)); // wait again...exponential backoff?
      }
      if (iWebViewLoaded) {
        return isManagerLoaded;
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> start() async {
    try {
      await server?.serve();
      bool? canTestRun = await testRun(_testDomains[0]);
      if (canTestRun != null) {
        if (canTestRun) {
          domain = _testDomains[0];
          _sharedPreferences?.setString(preferencesDomain, _testDomains[0]);
        } else {
          canTestRun = await testRun(_testDomains[1]);
          if (canTestRun == true) {
            // not null and true
            domain = _testDomains[1];
            _sharedPreferences?.setString(preferencesDomain, _testDomains[1]);
          }
        }
      }
    } catch (e) {
      debugPrint(
          'Failed to serve. Error: ${e.toString()}'); // may occur if port is already binded
    }
  }

  Future<void> stop() async {
    await server?.stop();
  }
}
