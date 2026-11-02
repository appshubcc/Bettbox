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
    final options = await clashLib?.getAndroidVpnOptions();
    return await methodChannel.invokeMethod<bool>('startVpn', {
      'data': json.encode(options),
    });
  }

  Future<bool?> stopVpn() => methodChannel.invokeMethod<bool>('stopVpn');

  Future<bool> isSmartStopped() async {
    return await methodChannel.invokeMethod<bool>('isSmartStopped') ?? false;
  }

  Future<void> requestSmartAutoStopCheck() =>
      methodChannel.invokeMethod<bool>('requestSmartAutoStopCheck');

  Future<String?> getCurrentDns() =>
      methodChannel.invokeMethod<String>('getCurrentDns');

  Future<bool> isServiceEngineRunning() async {
    return await methodChannel.invokeMethod<bool>('isServiceEngineRunning') ??
        false;
  }

  Future<bool> getStatus() async {
    return await methodChannel.invokeMethod<bool>('status') ?? false;
  }

  String? _speedNotificationProfile;

  bool needsSpeedNotificationSync(String profileName) =>
      _speedNotificationProfile != profileName;

  Future<void> updateNotificationSpeed(
    String profileName,
    String speedInfo,
  ) async {
    await methodChannel.invokeMethod<void>('updateNotificationSpeed', {
      'profileName': profileName,
      'speedInfo': speedInfo,
    });
    _speedNotificationProfile = profileName;
  }

  Future<void> restoreNotification() async {
    _speedNotificationProfile = null;
    await methodChannel.invokeMethod<void>('restoreNotification');
  }

  Future<bool?> setHighPriorityNotification(bool enabled) async {
    return await methodChannel.invokeMethod<bool>(
      'setHighPriorityNotification',
      {'enabled': enabled},
    );
  }

  Future<bool?> resumeCore() => methodChannel.invokeMethod<bool>('resumeCore');

  Future<bool?> reconnectIpc() =>
      methodChannel.invokeMethod<bool>('reconnectIpc');
}

Service? get service =>
    system.isAndroid && !globalState.isService ? Service() : null;
