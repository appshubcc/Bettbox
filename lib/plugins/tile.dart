import 'package:bett_box/common/system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract mixin class TileListener {
  void onStart() {}

  void onStop() {}

  void onDetached() {}

  void onReconnectIpc() {}
}

class Tile {
  static final Tile instance = Tile._();

  final _channel = const MethodChannel('tile');
  final _listeners = ObserverList<TileListener>();

  Tile._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'start':
        for (final l in _listeners) {
          l.onStart();
        }
      case 'stop':
        for (final l in _listeners) {
          l.onStop();
        }
      case 'detached':
        for (final l in _listeners) {
          l.onDetached();
        }
      case 'reconnectIpc':
        for (final l in _listeners) {
          l.onReconnectIpc();
        }
    }
  }

  bool get hasListeners => _listeners.isNotEmpty;

  void addListener(TileListener listener) => _listeners.add(listener);

  void removeListener(TileListener listener) => _listeners.remove(listener);
}

final tile = system.isAndroid ? Tile.instance : null;
