import 'package:local_assets_server/local_assets_server.dart';
import 'dart:io';

class LocalAssetsServerManager {
  LocalAssetsServer? server;

  /// This port should ideally not conflict but should remain the same for
  /// caching purposes.
  static int get port => 52062;

  static final LocalAssetsServerManager _singleton =
      LocalAssetsServerManager._internal();
  factory LocalAssetsServerManager() {
    _singleton.server = LocalAssetsServer(
      address: InternetAddress.loopbackIPv4,
      assetsBasePath: 'assets/ttu-ebook-reader',
      logger: const DebugLogger(),
      port: port,
    );
    return _singleton;
  }
  LocalAssetsServerManager._internal();
}
