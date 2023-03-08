import 'package:local_assets_server/local_assets_server.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class LocalAssetsServerManager {
  LocalAssetsServer? server;

  /// This port should ideally not conflict but should remain the same for
  /// caching purposes.
  static int get port => 52062;

  static final LocalAssetsServerManager _singleton =
      LocalAssetsServerManager._internal();
  factory LocalAssetsServerManager() => _singleton;
  factory LocalAssetsServerManager.create() {  // create has to be called first to init server
    _singleton.server = LocalAssetsServer(
      address: InternetAddress.loopbackIPv4,
      assetsBasePath: 'assets/ttu-ebook-reader',
      logger: const DebugLogger(),
      port: port,
    );
    return _singleton;
  }
  LocalAssetsServerManager._internal();

  Future<void> start() async {
    try {
      await server?.serve();
    } catch (e) {
      debugPrint(
          'Failed to serve. Error: ${e.toString()}'); // may occur if port is already binded
    }
  }

  Future<void> stop() async {
    await server?.stop();
  }
}
