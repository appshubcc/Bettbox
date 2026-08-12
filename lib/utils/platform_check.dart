import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;

enum TransportType {
  unixSocket,
  tcp,
}

class PlatformChecker {
  static bool? _udsSupport;

  static Future<bool> checkUnixSocketSupport() async {
    if (_udsSupport != null) return _udsSupport!;

    if (!Platform.isWindows) {
      _udsSupport = true;
      return true;
    }

    try {
      final testDir = Directory.systemTemp.path;
      final testPath = p.join(
        testDir,
        'bettbox_test_${DateTime.now().millisecondsSinceEpoch}.sock',
      );
      final address = InternetAddress(testPath, type: InternetAddressType.unix);
      final server = await ServerSocket.bind(address, 0);
      await server.close();

      final testFile = File(testPath);
      if (await testFile.exists()) {
        await testFile.delete();
      }

      _udsSupport = true;
      return true;
    } catch (_) {
      _udsSupport = false;
      return false;
    }
  }

  static Future<TransportType> getRecommendedTransport() async {
    if (await checkUnixSocketSupport()) {
      return TransportType.unixSocket;
    }
    return TransportType.tcp;
  }

  static int getRandomPort() {
    return 10000 + Random().nextInt(35000);
  }
}
