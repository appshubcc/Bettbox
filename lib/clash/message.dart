import 'dart:async';

import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter/foundation.dart';

class ClashMessage {
  final controller = StreamController<Map<String, Object?>>.broadcast();

  ClashMessage._() {
    controller.stream.listen((message) {
      if (message.isEmpty) return;
      final m = AppMessage.fromJson(message);
      for (final AppMessageListener listener in _listeners) {
        switch (m.type) {
          case AppMessageType.log:
            listener.onLog(Log.core(m.data));
          case AppMessageType.delay:
            listener.onDelay(Delay.fromJson(m.data));
          case AppMessageType.request:
            listener.onRequest(TrackerInfo.fromJson(m.data));
          case AppMessageType.loaded:
            listener.onLoaded(m.data);
          case AppMessageType.tailscaleAuth:
            final data = m.data is Map ? m.data as Map : const {};
            listener.onTailscaleAuth(
              dir: data['dir'] as String? ?? '',
              url: data['url'] as String? ?? '',
              state: data['state'] as String? ?? '',
            );
        }
      }
    });
  }

  static final ClashMessage instance = ClashMessage._();

  final ObserverList<AppMessageListener> _listeners =
      ObserverList<AppMessageListener>();

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void addListener(AppMessageListener listener) {
    _listeners.add(listener);
  }

  void removeListener(AppMessageListener listener) {
    _listeners.remove(listener);
  }
}

final clashMessage = ClashMessage.instance;
