import 'package:local_assets_server/local_assets_server.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class LocalAssetsServerProvider {
  LocalAssetsServer? server;

  /// This port should ideally not conflict but should remain the same for
  /// caching purposes.
  static int get port => 52062;

  LocalAssetsServerProvider._create() {
    // print("_create() (private constructor)");
  }

  static Future<LocalAssetsServerProvider> create() async {
    debugPrint('creating');
    LocalAssetsServerProvider provider = LocalAssetsServerProvider._create();
    provider.server = LocalAssetsServer(
      address: InternetAddress.loopbackIPv4,
      assetsBasePath: 'assets/ttu-ebook-reader',
      logger: const DebugLogger(),
      port: port,
    );
    return provider;
  }
}
