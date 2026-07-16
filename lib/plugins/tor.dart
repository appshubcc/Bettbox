import 'dart:convert';

import 'package:bett_box/models/models.dart';
import 'package:flutter/services.dart';

class TorControl {
  const TorControl();

  static const socksPort = 19050;
  static const controlPort = 19051;
  static const dnsPort = 19053;

  static const MethodChannel _channel = MethodChannel('tor');

  Future<Map<String, dynamic>> start({
    required TorProps torProps,
    required int upstreamSocksPort,
  }) async {
    final result = await _channel.invokeMapMethod<String, dynamic>('start', {
      'data': jsonEncode({
        'enabled': torProps.enable,
        'bridgeMode': torProps.bridgeMode.name,
        'customBridgesEnabled': torProps.customBridgesEnabled,
        'customBridges': torProps.bridgeLines,
        'upstreamSocksPort': upstreamSocksPort,
        'socksPort': socksPort,
        'controlPort': controlPort,
        'dnsPort': dnsPort,
      }),
    });
    return result ?? const {};
  }

  Future<void> stop() async {
    await _channel.invokeMethod<bool>('stop');
  }

  Future<Map<String, dynamic>> status() async {
    final result = await _channel.invokeMapMethod<String, dynamic>('status');
    return result ?? const {'status': 'disabled'};
  }

  Future<Map<String, dynamic>> checkExit({
    int socksPort = TorControl.socksPort,
  }) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'checkExit',
      {'socksPort': socksPort},
    );
    return result ?? const {'ok': false};
  }

  Future<Traffic> traffic({int controlPort = TorControl.controlPort}) async {
    final result = await _channel.invokeMapMethod<String, dynamic>('traffic', {
      'controlPort': controlPort,
    });
    if (result?['ok'] != true) return Traffic();
    return Traffic(
      up: (result?['up'] as num?)?.toInt(),
      down: (result?['down'] as num?)?.toInt(),
    );
  }
}
