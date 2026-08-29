import 'dart:async';
import 'dart:convert';

import 'package:bett_box/common/system.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/services.dart';

import '../clash/lib.dart';

typedef NativeEventCallback =
    Future<void> Function(String method, dynamic arguments);

class Service {
  static final Service _instance = Service._internal();
  final MethodChannel methodChannel = const MethodChannel('service');

  final List<NativeEventCallback> _nativeEventCallbacks = [];

  Service._internal() {
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  factory Service() => _instance;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'runStateChanged') {
      final state = call.arguments as String?;
      if (state == 'STOP') {
        globalState.startTime = null;
        globalState.appState = globalState.appState.copyWith(runTime: null);
      }
    }
    for (final callback in _nativeEventCallbacks) {
      await callback(call.method, call.arguments);
    }
  }

  void addNativeEventCallback(NativeEventCallback callback) {
    _nativeEventCallbacks.add(callback);
  }

  void removeNativeEventCallback(NativeEventCallback callback) {
    _nativeEventCallbacks.remove(callback);
  }

  Future<bool?> init() => methodChannel.invokeMethod<bool>('init');

  Future<bool?> destroy() => methodChannel.invokeMethod<bool>('destroy');

  Future<bool?> startVpn() async {
    final options = system.isOhos
        ? await clashOhos?.getAndroidVpnOptions()
        : await clashLib?.getAndroidVpnOptions();
    if (system.isOhos) {
      if (options == null) return false;
      if (!options.enable) return clashOhos?.startTun(0) ?? false;
      final fd = await methodChannel.invokeMethod<int>('startVpn', {
        'data': json.encode(options),
      });
      if (fd == null || fd <= 0) return false;
      try {
        return clashOhos?.startTun(fd) ?? false;
      } catch (_) {
        await methodChannel.invokeMethod<bool>('stopVpn');
        rethrow;
      }
    }
    return methodChannel.invokeMethod<bool>('startVpn', {
      'data': json.encode(options),
    });
  }

  Future<bool?> stopVpn() async {
    if (system.isOhos) clashOhos?.stopTun();
    return methodChannel.invokeMethod<bool>('stopVpn');
  }

  Future<bool?> smartStop() => methodChannel.invokeMethod<bool>('smartStop');

  Future<bool?> smartResume() async {
    final options = await clashLib?.getAndroidVpnOptions();
    return await methodChannel.invokeMethod<bool>('smartResume', {
      'data': json.encode(options),
    });
  }

  Future<void> setSmartStopped(bool value) async {
    await methodChannel.invokeMethod<bool>('setSmartStopped', {'value': value});
  }

  Future<bool> isSmartStopped() async {
    return await methodChannel.invokeMethod<bool>('isSmartStopped') ?? false;
  }

  Future<List<String>> getLocalIpAddresses() async {
    return await methodChannel.invokeListMethod<String>(
          'getLocalIpAddresses',
        ) ??
        const [];
  }

  Future<bool?> setQuickResponse(bool enabled) async {
    return await methodChannel.invokeMethod<bool>('setQuickResponse', {
      'enabled': enabled,
    });
  }

  Future<bool> isServiceEngineRunning() async {
    return await methodChannel.invokeMethod<bool>('isServiceEngineRunning') ??
        false;
  }

  Future<bool> getStatus() async {
    return await methodChannel.invokeMethod<bool>('status') ?? false;
  }

  Future<void> updateNotificationSpeed(
    String profileName,
    String speedInfo,
  ) async {
    await methodChannel.invokeMethod<void>('updateNotificationSpeed', {
      'profileName': profileName,
      'speedInfo': speedInfo,
    });
  }

  Future<void> restoreNotification() async {
    await methodChannel.invokeMethod<void>('restoreNotification');
  }

  Future<bool?> reconnectIpc() =>
      methodChannel.invokeMethod<bool>('reconnectIpc');
}

Service? get service =>
    (system.isAndroid || system.isOhos) && !globalState.isService
    ? Service()
    : null;
