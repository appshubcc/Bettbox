import 'dart:convert';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract mixin class VpnListener {
  void onDnsChanged(String dns) {}
}

class Vpn {
  static final Vpn _instance = Vpn._internal();
  final MethodChannel methodChannel = const MethodChannel('vpn');

  Vpn._internal() {
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'gc':
          clashCore.requestGc(forceFreeOSMemory: true);
          break;
        case 'closeConnections':
          clashCore.closeConnections();
          break;
        case 'status':
          return clashLibHandler?.getRunTime() != null;
        case 'dnsChanged':
          for (final listener in _listeners) {
            listener.onDnsChanged(call.arguments as String);
          }
          break;
        case 'screenStateChanged':
          globalState.appState = globalState.appState.copyWith(
            isScreenOn: call.arguments as bool,
          );
          break;
        default:
      }
    });
  }

  factory Vpn() => _instance;

  final ObserverList<VpnListener> _listeners = ObserverList<VpnListener>();

  Future<bool?> start(AndroidVpnOptions options) async {
    return await methodChannel.invokeMethod<bool>('start', {
      'data': jsonEncode(options),
    });
  }

  Future<bool?> stop() => methodChannel.invokeMethod<bool>('stop');

  Future<List<String>> getLocalIpAddresses() async {
    return await methodChannel.invokeListMethod<String>(
          'getLocalIpAddresses',
        ) ??
        const [];
  }

  Future<void> setSmartStopped(bool value) async {
    await methodChannel.invokeMethod<bool>('setSmartStopped', {'value': value});
  }

  Future<bool> isSmartStopped() async {
    return await methodChannel.invokeMethod<bool>('isSmartStopped') ?? false;
  }

  Future<bool?> smartStop() => methodChannel.invokeMethod<bool>('smartStop');

  Future<bool?> smartResume(AndroidVpnOptions options) async {
    return await methodChannel.invokeMethod<bool>('smartResume', {
      'data': jsonEncode(options),
    });
  }

  Future<bool> getStatus() async {
    return await methodChannel.invokeMethod<bool>('status') ?? false;
  }

  void addListener(VpnListener listener) => _listeners.add(listener);

  void removeListener(VpnListener listener) => _listeners.remove(listener);
}

Vpn? get vpn => globalState.isService ? Vpn() : null;
