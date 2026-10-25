import 'dart:io';

import 'package:bett_box/state.dart';

class BettboxHttpOverrides extends HttpOverrides {
  static bool _isLoopback(String host) {
    if (host.isEmpty || host.toLowerCase() == 'localhost') return true;
    return InternetAddress.tryParse(host)?.isLoopback ?? false;
  }

  static String handleFindProxy(Uri url) {
    if (_isLoopback(url.host)) {
      return 'DIRECT';
    }
    final port = globalState.config.patchClashConfig.mixedPort;
    final isStart = globalState.appState.runTime != null;
    if (!isStart) return 'DIRECT';
    return 'PROXY localhost:$port';
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = handleFindProxy;
    return client;
  }
}
