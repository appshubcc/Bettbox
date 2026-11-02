import 'dart:ffi';

import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/state.dart';

import 'system.dart';

class Android {
  Future<void> init() async {
    app.onExit = () async {
      await globalState.appController.savePreferences();
    };
  }

  void purgeMemory() {
    final sdk = globalState.appState.version;
    if (sdk > 0 && sdk < 28) {
      return;
    }
    try {
      final libc = DynamicLibrary.open('libc.so');
      final mallopt = libc
          .lookupFunction<
            Int32 Function(Int32 param, Int32 value),
            int Function(int param, int value)
          >('mallopt');
      mallopt(sdk >= 34 ? -104 : -101, 0);
    } catch (_) {}
  }
}

final android = system.isAndroid ? Android() : null;
