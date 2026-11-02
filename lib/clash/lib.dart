import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/plugins/service.dart';
import 'package:bett_box/state.dart';

import 'generated/clash_ffi.dart';
import 'interface.dart';

class ClashLib extends ClashHandlerInterface with AndroidClashInterface {
  static ClashLib? _instance;
  Completer<bool> _canSendCompleter = Completer();
  SendPort? sendPort;
  final receiverPort = ReceivePort();

  ClashLib._internal() {
    _initService();
  }

  @override
  preload() {
    return _canSendCompleter.future;
  }

  bool _isListening = false;

  Future<void> _initService() async {
    _registerMainPort(receiverPort.sendPort);
    if (!_isListening) {
      _isListening = true;
      receiverPort.listen((message) {
        if (message is SendPort) {
          sendPort = message;
          if (!_canSendCompleter.isCompleted) {
            _canSendCompleter.complete(true);
          }
        } else if (message is String) {
          handleResultMessage(message);
        }
      });
    }
    final alreadyRunning = await service?.isServiceEngineRunning() ?? false;
    if (alreadyRunning) {
      await service?.reconnectIpc();
    } else {
      await service?.destroy();
      await service?.init();
    }
    await _waitForIpc();
  }

  Future<void> _waitForIpc() async {
    for (var attempt = 1; ; attempt++) {
      if (sendPort != null && _canSendCompleter.isCompleted) return;
      final connected = await _canSendCompleter.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
      if (connected && sendPort != null) return;
      if (attempt <= 3) {
        commonPrint.warn('ClashLib: IPC attempt $attempt failed, retrying...');
      }
      if (_canSendCompleter.isCompleted) {
        _canSendCompleter = Completer();
      }
      await service?.reconnectIpc();
    }
  }

  void _registerMainPort(SendPort sendPort) {
    IsolateNameServer.removePortNameMapping(mainIsolate);
    IsolateNameServer.registerPortWithName(sendPort, mainIsolate);
  }

  factory ClashLib() {
    _instance ??= ClashLib._internal();
    return _instance!;
  }

  @override
  destroy() async {
    await service?.destroy();
    return true;
  }

  @override
  reStart() {
    _initService();
  }

  @override
  Future<bool> shutdown() async {
    await super.shutdown();
    destroy();
    return true;
  }

  @override
  sendMessage(String message) async {
    final canSend = await _canSendCompleter.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => false,
    );
    if (!canSend || sendPort == null) {
      commonPrint.error('ClashLib: IPC not ready after 5s');
      throw TimeoutException('Android IPC SendPort unavailable');
    }
    try {
      sendPort?.send(message);
    } catch (e) {
      commonPrint.warn('ClashLib: sendMessage failed: $e, reconnecting IPC');
      sendPort = null;
      _canSendCompleter = Completer();
      await service?.reconnectIpc();
      await _waitForIpc();
      sendPort?.send(message);
    }
    return null;
  }

  // @override
  // Future<bool> stopTun() {
  //   return invoke<bool>(
  //     method: ActionMethod.stopTun,
  //   );
  // }

  @override
  Future<AndroidVpnOptions?> getAndroidVpnOptions() async {
    final res = await invoke<String>(method: ActionMethod.getAndroidVpnOptions);
    if (res.isEmpty) return null;
    return AndroidVpnOptions.fromJson(json.decode(res));
  }

  @override
  Future<bool> updateDns(String value) {
    return invoke<bool>(method: ActionMethod.updateDns, data: value);
  }

  @override
  Future<DateTime?> getRunTime() async {
    final runTimeString = await invoke<String>(method: ActionMethod.getRunTime);
    if (runTimeString.isEmpty) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(runTimeString));
  }

  @override
  Future<String> getCurrentProfileName() {
    return invoke<String>(method: ActionMethod.getCurrentProfileName);
  }
}

class ClashLibHandler {
  static ClashLibHandler? _instance;

  late final ClashFFI clashFFI;

  late final DynamicLibrary lib;

  ClashLibHandler._internal() {
    lib = DynamicLibrary.open('libmeta.so');
    clashFFI = ClashFFI(lib);
    clashFFI.initNativeApiBridge(NativeApi.initializeApiDLData);
  }

  factory ClashLibHandler() {
    _instance ??= ClashLibHandler._internal();
    return _instance!;
  }

  Future<String> invokeAction(String actionParams) {
    final completer = Completer<String>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(message);
        receiver.close();
      }
    });
    final actionParamsChar = actionParams.toNativeUtf8().cast<Char>();
    clashFFI.invokeAction(actionParamsChar, receiver.sendPort.nativePort);
    malloc.free(actionParamsChar);
    return completer.future;
  }

  Future<void> freeOSMemory() async {
    final action = Action(
      id: '${ActionMethod.forceGc.name}#${utils.id}',
      method: ActionMethod.forceGc,
      data: 'true',
    );
    await invokeAction(json.encode(action));
  }

  Future<void> exportConfig(
    String id,
    String output, {
    String? ageSecretKey,
    String? providersPath,
  }) async {
    final action = Action(
      id: '${ActionMethod.exportConfig.name}#${utils.id}',
      method: ActionMethod.exportConfig,
      data: json.encode({
        'path': await appPath.getProfilePath(id),
        'age-secret-key': ageSecretKey ?? '',
        'output': output,
        'expand-providers': providersPath != null,
        'providers-path': providersPath ?? '',
      }),
    );
    final result = decodeActionResult(
      await invokeAction(json.encode(action)),
    )?.toResult;
    if (result == null) {
      throw 'Invalid core result';
    }
    if (result.isError) {
      throw result.message;
    }
  }

  void attachMessagePort(int messagePort) {
    clashFFI.attachMessagePort(messagePort);
  }

  void updateDns(String dns) {
    final dnsChar = dns.toNativeUtf8().cast<Char>();
    clashFFI.updateDns(dnsChar);
    malloc.free(dnsChar);
  }

  void setState(CoreState state) {
    final stateChar = json.encode(state).toNativeUtf8().cast<Char>();
    clashFFI.setState(stateChar);
    malloc.free(stateChar);
  }

  String getCurrentProfileName() {
    final currentProfileRaw = clashFFI.getCurrentProfileName();
    final currentProfile = currentProfileRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(currentProfileRaw);
    return currentProfile;
  }

  AndroidVpnOptions getAndroidVpnOptions() {
    final vpnOptionsRaw = clashFFI.getAndroidVpnOptions();
    final vpnOptions = json.decode(vpnOptionsRaw.cast<Utf8>().toDartString());
    clashFFI.freeCString(vpnOptionsRaw);
    return AndroidVpnOptions.fromJson(vpnOptions);
  }

  Traffic getTraffic() {
    final trafficRaw = clashFFI.getTraffic();
    final trafficString = trafficRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(trafficRaw);
    if (trafficString.isEmpty) return Traffic();
    return Traffic.fromMap(json.decode(trafficString));
  }

  Traffic getTotalTraffic(bool value) {
    final trafficRaw = clashFFI.getTotalTraffic();
    final trafficString = trafficRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(trafficRaw);
    if (trafficString.isEmpty) return Traffic();
    return Traffic.fromMap(json.decode(trafficString));
  }

  Future<bool> startListener() async {
    clashFFI.startListener();
    return true;
  }

  Future<bool> stopListener() async {
    clashFFI.stopListener();
    return true;
  }

  DateTime? getRunTime() {
    final runTimeRaw = clashFFI.getRunTime();
    final runTimeString = runTimeRaw.cast<Utf8>().toDartString();
    clashFFI.freeCString(runTimeRaw);
    if (runTimeString.isEmpty) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(int.parse(runTimeString));
  }

  Future<Map<String, dynamic>> getConfig(
    String id, {
    String? ageSecretKey,
    List<String> disabledGroups = const [],
    bool snippet = false,
  }) async {
    final path = await appPath.getProfilePath(id);
    final params = {
      'path': path,
      'age-secret-key': ageSecretKey ?? '',
      'disabled-groups': disabledGroups,
      'snippet': snippet,
    };
    return using((arena) {
      final pathChar = json
          .encode(params)
          .toNativeUtf8(allocator: arena)
          .cast<Char>();
      final configRaw = clashFFI.getConfig(pathChar);
      if (configRaw == nullptr) return <String, dynamic>{};
      try {
        final configString = configRaw.cast<Utf8>().toDartString();
        final decoded = json.decode(configString);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
        return <String, dynamic>{};
      } finally {
        clashFFI.freeCString(configRaw);
      }
    });
  }

  Future<SetupResult> quickStart(
    InitParams initParams,
    SetupParams setupParams,
    CoreState state,
  ) {
    final completer = Completer<SetupResult>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        dynamic data = message;
        try {
          data = json.decode(message);
        } catch (_) {}
        completer.complete(SetupResult.fromData(data));
        receiver.close();
      }
    });
    final params = json.encode(setupParams);
    final initValue = json.encode(initParams);
    final stateParams = json.encode(state);
    final initParamsChar = initValue.toNativeUtf8().cast<Char>();
    final paramsChar = params.toNativeUtf8().cast<Char>();
    final stateParamsChar = stateParams.toNativeUtf8().cast<Char>();
    clashFFI.quickStart(
      initParamsChar,
      paramsChar,
      stateParamsChar,
      receiver.sendPort.nativePort,
    );
    malloc.free(initParamsChar);
    malloc.free(paramsChar);
    malloc.free(stateParamsChar);
    return completer.future;
  }
}

ClashLib? get clashLib =>
    system.isAndroid && !globalState.isService ? ClashLib() : null;

ClashLibHandler? get clashLibHandler =>
    system.isAndroid && globalState.isService ? ClashLibHandler() : null;
