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

typedef _GetTunErrorNative = Pointer<Char> Function();
typedef _GetTunErrorDart = Pointer<Char> Function();

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

  Future<void> _initService() async {
    _registerMainPort(receiverPort.sendPort);
    receiverPort.listen((message) {
      if (message is SendPort) {
        if (_canSendCompleter.isCompleted) {
          sendPort = null;
          _canSendCompleter = Completer();
        }
        sendPort = message;
        _canSendCompleter.complete(true);
      } else {
        handleResult(ActionResult.fromJson(json.decode(message)));
      }
    });
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
    for (var attempt = 0; attempt < 3; attempt++) {
      final connected = await _canSendCompleter.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
      if (connected) return;
      commonPrint.log(
        'ClashLib: IPC attempt ${attempt + 1}/3 failed, retrying...',
      );
      _canSendCompleter = Completer();
      await service?.reconnectIpc();
    }
    commonPrint.log('ClashLib: IPC failed after 3 attempts');
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
    await _canSendCompleter.future;
    try {
      sendPort?.send(message);
    } catch (e) {
      commonPrint.log('ClashLib: sendMessage failed: $e, reconnecting IPC');
      sendPort = null;
      _canSendCompleter = Completer();
      await service?.reconnectIpc();
      await _waitForIpc();
      sendPort?.send(message);
    }
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

class ClashOhos extends ClashHandlerInterface with AndroidClashInterface {
  final ClashLibHandler _handler = ClashLibHandler();

  @override
  Future<bool> preload() async => true;

  @override
  void sendMessage(String message) {
    unawaited(
      _handler
          .invokeAction(message)
          .then((response) {
            final result = ActionResult.fromJson(json.decode(response));
            return handleResult(result);
          })
          .catchError((Object error, StackTrace stackTrace) {
            commonPrint.log('OHOS core action failed: $error');
          }),
    );
  }

  @override
  Future<void> reStart() async {}

  @override
  Future<bool> destroy() async {
    _handler.stopTun();
    return true;
  }

  @override
  Future<bool> updateDns(String value) async {
    _handler.updateDns(value);
    return true;
  }

  @override
  Future<AndroidVpnOptions?> getAndroidVpnOptions() async {
    return _handler.getAndroidVpnOptions();
  }

  @override
  Future<String> getCurrentProfileName() async {
    return _handler.getCurrentProfileName();
  }

  @override
  Future<DateTime?> getRunTime() async => _handler.getRunTime();

  bool startTun(int fd) {
    final started = _handler.startTun(fd);
    if (!started) {
      throw StateError('OHOS TUN startup failed: ${_handler.getTunError()}');
    }
    return true;
  }

  void stopTun() => _handler.stopTun();
}

class ClashLibHandler {
  static ClashLibHandler? _instance;

  late final ClashFFI clashFFI;

  late final DynamicLibrary lib;

  ClashLibHandler._internal() {
    lib = DynamicLibrary.open('libclash.so');
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
  }) async {
    final path = await appPath.getProfilePath(id);
    final params = {'path': path, 'age-secret-key': ageSecretKey ?? ''};
    return using((arena) {
      final pathChar = json
          .encode(params)
          .toNativeUtf8(allocator: arena)
          .cast<Char>();
      final configRaw = clashFFI.getConfig(pathChar);
      if (configRaw == nullptr) return <String, dynamic>{};
      try {
        final configString = configRaw.cast<Utf8>().toDartString();
        if (configString.isEmpty) return <String, dynamic>{};
        return json.decode(configString) as Map<String, dynamic>;
      } finally {
        clashFFI.freeCString(configRaw);
      }
    });
  }

  Future<String> quickStart(
    InitParams initParams,
    SetupParams setupParams,
    CoreState state,
  ) {
    final completer = Completer<String>();
    final receiver = ReceivePort();
    receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(message);
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

  bool startTun(int fd) => clashFFI.startTUN(fd, nullptr) != 0;

  String getTunError() {
    final getTunError = lib
        .lookup<NativeFunction<_GetTunErrorNative>>('getTunError')
        .asFunction<_GetTunErrorDart>();
    final rawError = getTunError();
    if (rawError == nullptr) return 'unknown error';
    try {
      return rawError.cast<Utf8>().toDartString();
    } finally {
      clashFFI.freeCString(rawError);
    }
  }

  void stopTun() => clashFFI.stopTun();
}

ClashLib? get clashLib =>
    system.isAndroid && !globalState.isService ? ClashLib() : null;

ClashLibHandler? get clashLibHandler =>
    system.isAndroid && globalState.isService ? ClashLibHandler() : null;

ClashOhos? get clashOhos => system.isOhos ? ClashOhos() : null;
