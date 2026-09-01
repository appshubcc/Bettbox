import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Bridges native paste commands that never reach the framework.
///
/// Windows clipboard history (Win+V) delivers its selection as a `WM_PASTE`
/// window message instead of a Ctrl+V key event. The Flutter engine has no
/// handler for that message, so the runner forwards it here.
class ClipboardExt {
  ClipboardExt._internal() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'paste':
          await _handlePaste();
          return null;
        default:
          throw MissingPluginException();
      }
    });
  }

  static ClipboardExt? _instance;

  factory ClipboardExt() => _instance ??= ClipboardExt._internal();

  /// Starts listening for native paste commands.
  void init() {}

  final MethodChannel _channel = const MethodChannel('clipboard_ext');

  final List<Future<bool> Function()> _handlers = [];

  /// Registers a paste handler. It returns true once it consumed the paste.
  ///
  /// Handlers are consulted most-recently-registered first, so a focused
  /// editor takes precedence over the generic text field fallback.
  VoidCallback addHandler(Future<bool> Function() handler) {
    _handlers.add(handler);
    return () => _handlers.remove(handler);
  }

  Future<void> _handlePaste() async {
    for (final handler in _handlers.reversed.toList(growable: false)) {
      if (await handler()) return;
    }
    _pasteIntoFocusedField();
  }

  void _pasteIntoFocusedField() {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) return;
    Actions.maybeInvoke(
      context,
      const PasteTextIntent(SelectionChangedCause.keyboard),
    );
  }
}

final clipboardExt = ClipboardExt();
