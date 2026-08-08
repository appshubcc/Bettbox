import 'dart:io';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';

class BettboxHttpOverrides extends HttpOverrides {
  static String handleFindProxy(Uri url) {
    if ([localhost].contains(url.host)) {
      return 'DIRECT';
    }
    final port = globalState.effectiveMixedPort;
    final isStart = globalState.appState.runTime != null;
    if (!isStart) return 'DIRECT';
    return 'PROXY localhost:$port';
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (_, _, _) => true;
    client.findProxy = handleFindProxy;
    return client;
  }
}
