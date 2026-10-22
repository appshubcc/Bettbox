import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'window_ext_listener.dart';

class WindowExtManager {
  WindowExtManager._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  static final WindowExtManager instance = WindowExtManager._();

  final MethodChannel _channel = const MethodChannel('window_ext');

  final ObserverList<WindowExtListener> _listeners =
      ObserverList<WindowExtListener>();

  Future<void> _methodCallHandler(MethodCall call) async {
    for (final WindowExtListener listener in _listeners) {
      switch (call.method) {
        case "taskbarCreated":
          listener.onTaskbarCreated();
          break;
        case "shouldTerminate":
          listener.onShouldTerminate();
          break;
      }
    }
  }

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void addListener(WindowExtListener listener) {
    _listeners.add(listener);
  }

  void removeListener(WindowExtListener listener) {
    _listeners.remove(listener);
  }

  Future<void> setDockIconVisible(bool visible) {
    return _channel.invokeMethod('setDockIconVisible', visible);
  }

  Future<Uint8List?> getFileIcon(String path, int size) {
    return _channel.invokeMethod<Uint8List>('getFileIcon', {
      'path': path,
      'size': size,
    });
  }

  /// Resolves an icon name with the running GTK icon theme.
  ///
  /// The returned path is the file GTK would use, which may be an SVG. Returns
  /// null when the theme and its fallbacks do not contain the icon.
  ///
  /// Linux only; the macOS and Windows implementations do not provide this.
  Future<String?> getIconPath(String name, {int size = 96}) {
    return _channel.invokeMethod<String>('getIconPath', {
      'name': name,
      'size': size,
    });
  }
}

final windowExtManager = WindowExtManager.instance;
