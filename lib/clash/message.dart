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
      List<Delay>? delays;
      for (final AppMessageListener listener in _listeners) {
        switch (m.type) {
          case AppMessageType.log:
            listener.onLog(Log.core(m.data));
          case AppMessageType.delays:
            listener.onDelays(delays ??= _decodeDelays(m.data));
          case AppMessageType.groupsChanged:
            listener.onGroupsChanged();
          case AppMessageType.request:
            listener.onRequest(TrackerInfo.fromJson(m.data));
          case AppMessageType.speedTest:
            listener.onSpeedTest(SpeedTestState.fromJson(m.data));
          case AppMessageType.stunTest:
            listener.onStunTest(StunTestState.fromJson(m.data));
          case AppMessageType.iperf:
            listener.onIperf(IperfState.fromJson(m.data));
          case AppMessageType.localPing:
            listener.onLocalPing(LocalPingState.fromJson(m.data));
        }
      }
    });
  }

  static List<Delay> _decodeDelays(Object? data) => [
    if (data is List)
      for (final item in data)
        if (item is Map) Delay.fromJson(Map<String, Object?>.from(item)),
  ];

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
