import 'package:bett_box/common/print.dart';
import 'package:code_forge/script.dart';

Future<bool>? _rustLibReady;

bool get isRustLibInitialized => isCodeForgeRustInitialized;

Future<bool> ensureRustLib() {
  if (isRustLibInitialized) {
    return Future.value(true);
  }
  return _rustLibReady ??= _initRustLib();
}

Future<bool> _initRustLib() async {
  try {
    await RustLib.init();
    return true;
  } catch (e) {
    commonPrint.error('Failed to initialize RustLib: $e');
    _rustLibReady = null;
    return false;
  }
}
