import 'src/rust/frb_generated.dart' show RustLib;

export 'src/rust/api/script.dart';
export 'src/rust/frb_generated.dart' show RustLib;

bool get isCodeForgeRustInitialized => RustLib.instance.initialized;
