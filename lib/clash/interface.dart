import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:bett_box/clash/message.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';

mixin ClashInterface {
  Future<bool> init(InitParams params);

  Future<bool> preload();

  Future<bool> shutdown();

  Future<bool> get isInit;

  Future<bool> forceGc({bool forceFreeOSMemory = false, bool purge = true});

  FutureOr<String> validateConfig(
    String data, {
    String? ageSecretKey,
    SetupParams? setup,
  });

  Future<String> importProfile(String params);

  Future<Result> getRuntimeConfig(SetupParams setupParams);

  Future<Result> exportConfig(
    String path,
    String output, {
    String? ageSecretKey,
    String? providersPath,
    bool refresh,
  });

  Future<Result> mergeProfiles(String params);

  FutureOr<String> decryptAgeConfig(String data, String ageSecretKey);

  FutureOr<Result> getConfig(
    String path, {
    String? ageSecretKey,
    List<String> disabledGroups,
    bool snippet,
  });

  Future<Map<String, String>> generateAgeKeyPair({bool hybrid = false});

  Future<Result<String>> convertAgeSecretKeyToPublicKey(String secretKey);

  Future<String> asyncTestDelay(String url, String proxyName);

  Future<String> asyncTestDelays(String params, Duration timeout);

  Future<bool> setForeground(bool value);

  FutureOr<String> updateConfig(UpdateParams updateParams);

  FutureOr<SetupResult> setupConfig(SetupParams setupParams);

  FutureOr<String> getProxies();

  FutureOr<String> changeProxy(ChangeProxyParams changeProxyParams);

  Future<bool> startListener();

  Future<bool> stopListener();

  FutureOr<String> getExternalProviders();

  FutureOr<String>? getExternalProvider(String externalProviderName);

  Future<String> updateGeoData(UpdateGeoDataParams params);

  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  });

  Future<String> updateExternalProvider(String providerName);

  FutureOr<String> parseExternalProviderContent(String providerName);

  FutureOr<String> getTraffic();

  FutureOr<String> getTrafficSnapshot();

  FutureOr<String> getCountryCode(String ip);

  FutureOr<String> getMemory();

  FutureOr<String> getCoreStatus();

  FutureOr<String> getInterfaces();

  Future<String> startSpeedTest(String params);

  FutureOr<bool> cancelSpeedTest();

  Future<String> probeSpeedTest(String params);

  Future<String> getSpeedTestServers(String params);

  Future<String> startStunTest(String params);

  FutureOr<bool> cancelStunTest();

  Future<String> startIperfServer(String params);

  FutureOr<bool> stopIperfServer();

  Future<String> startIperfClient(String params, Duration timeout);

  FutureOr<bool> cancelIperfClient();

  Future<String> startLocalPing(String params, Duration timeout);

  FutureOr<bool> cancelLocalPing();

  Future<String> toolboxInvoke(ActionMethod method, {String data = ''});

  FutureOr<void> resetTraffic();

  FutureOr<void> startLog();

  FutureOr<void> stopLog();

  FutureOr<String> getLogs();

  FutureOr<bool> clearLogs();

  Future<bool> crash();

  FutureOr<String> getConnections();

  FutureOr<String> getConnectionsSummary();

  FutureOr<bool> closeConnection(String id);

  FutureOr<bool> closeConnections();

  FutureOr<bool> closeGroupConnections(String groupName);

  FutureOr<bool> resetConnections();

  FutureOr<void> startTrackRequests();

  FutureOr<void> stopTrackRequests();

  FutureOr<String> getRequests();

  FutureOr<bool> clearRequests();

  Future<bool> setState(CoreState state);

  FutureOr<bool> flushFakeIP();

  FutureOr<bool> flushDnsCache();

  Future<String> getMode();
}

mixin AndroidClashInterface {
  Future<bool> updateDns(String value);

  Future<AndroidVpnOptions?> getAndroidVpnOptions();

  Future<String> getCurrentProfileName();

  Future<DateTime?> getRunTime();
}

class CoreDisconnectedException implements Exception {
  const CoreDisconnectedException();
}

const _isolateDecodeThreshold = 64 * 1024;

({Map<String, Object?> header, String payload})? _splitActionResult(
  String message,
) {
  final index = message.indexOf('\n');
  if (index == -1) return null;
  final header = json.decode(message.substring(0, index));
  if (header is! Map<String, Object?>) return null;
  return (header: header, payload: message.substring(index + 1));
}

ActionResult _toActionResult(Map<String, Object?> header, Object? data) {
  return ActionResult.fromJson({...header, 'data': data});
}

ActionResult? decodeActionResult(String message) {
  final parts = _splitActionResult(message);
  if (parts == null) return null;
  final (:header, :payload) = parts;
  return _toActionResult(
    header,
    header['raw'] == true ? payload : json.decode(payload),
  );
}

abstract class ClashHandlerInterface with ClashInterface {
  Map<String, Completer> callbackCompleterMap = {};
  final Map<String, Object> _requestChannels = {};

  Future<void> handleResult(ActionResult result) async {
    final completer = callbackCompleterMap.remove(result.id);
    _requestChannels.remove(result.id);
    try {
      switch (result.method) {
        case ActionMethod.message:
          clashMessage.controller.add(result.data);
          completer?.complete(true);
          return;
        case ActionMethod.getConfig:
        case ActionMethod.getRuntimeConfig:
        case ActionMethod.exportConfig:
        case ActionMethod.mergeProfiles:
        case ActionMethod.convertAgeSecretKeyToPublicKey:
          completer?.complete(result.toResult);
          return;
        case ActionMethod.generateAgeKeyPair:
          completer?.complete(result.data);
          return;
        default:
          final data = result.data;
          completer?.complete(
            completer is Completer<String> && data is! String
                ? json.encode(data)
                : data,
          );
          return;
      }
    } catch (e) {
      commonPrint.warn('${result.id} error $e');
    }
  }

  Future<void> handleResultMessage(String message) async {
    try {
      final parts = _splitActionResult(message);
      if (parts == null) {
        commonPrint.warn('Ignored malformed core result');
        return;
      }
      final (:header, :payload) = parts;
      final data = header['raw'] == true
          ? payload
          : payload.length >= _isolateDecodeThreshold &&
                header['method'] != ActionMethod.message.name
          ? await Isolate.run(() => json.decode(payload))
          : json.decode(payload);
      await handleResult(_toActionResult(header, data));
    } catch (e) {
      commonPrint.warn('Failed to decode core result: $e');
    }
  }

  FutureOr<Object?> sendMessage(String message);

  void abortRequests(Object channel) {
    final ids = _requestChannels.entries
        .where((entry) => identical(entry.value, channel))
        .map((entry) => entry.key)
        .toList();
    for (final id in ids) {
      _requestChannels.remove(id);
      final completer = callbackCompleterMap.remove(id);
      if (completer != null && !completer.isCompleted) {
        completer.completeError(const CoreDisconnectedException());
      }
    }
  }

  FutureOr<void> reStart();

  FutureOr<bool> destroy();

  Future<T> invoke<T>({
    required ActionMethod method,
    dynamic data,
    Duration? timeout,
    FutureOr<T> Function()? onTimeout,
    T? defaultValue,
  }) async {
    final id = '${method.name}#${utils.id}';

    final completer = Completer<T>();
    callbackCompleterMap[id] = completer;

    dynamic mDefaultValue = defaultValue;
    if (mDefaultValue == null) {
      if (T == String) {
        mDefaultValue = '';
      } else if (T == bool) {
        mDefaultValue = false;
      } else if (T == Map) {
        mDefaultValue = <String, dynamic>{};
      }
    }
    final FutureOr<T> Function() fallback = onTimeout ?? () => mDefaultValue;

    try {
      final channel = await sendMessage(
        json.encode(Action(id: id, method: method, data: data)),
      );
      if (channel != null && !completer.isCompleted) {
        _requestChannels[id] = channel;
      }
    } on CoreDisconnectedException {
      callbackCompleterMap.remove(id);
      return fallback();
    } catch (e) {
      callbackCompleterMap.remove(id);
      rethrow;
    }

    try {
      return await completer.safeFuture(
        timeout: timeout,
        onLast: () {
          callbackCompleterMap.remove(id);
          _requestChannels.remove(id);
        },
        onTimeout: fallback,
        functionName: id,
      );
    } on CoreDisconnectedException {
      return fallback();
    }
  }

  void _invokeAndForget(ActionMethod method, {dynamic data}) {
    invoke(method: method, data: data).then<void>(
      (_) {},
      onError: (Object e) => commonPrint.debug('${method.name} ignored: $e'),
    );
  }

  @override
  Future<bool> init(InitParams params) {
    return invoke<bool>(
      method: ActionMethod.initClash,
      data: json.encode(params),
    );
  }

  @override
  Future<bool> setState(CoreState state) {
    return invoke<bool>(
      method: ActionMethod.setState,
      data: json.encode(state),
    );
  }

  @override
  shutdown() async {
    return await invoke<bool>(
      method: ActionMethod.shutdown,
      timeout: Duration(seconds: 1),
    );
  }

  @override
  Future<bool> get isInit {
    return invoke<bool>(method: ActionMethod.getIsInit);
  }

  @override
  Future<bool> forceGc({bool forceFreeOSMemory = false, bool purge = true}) {
    return invoke<bool>(
      method: ActionMethod.forceGc,
      data: forceFreeOSMemory ? (purge ? 'true' : 'free') : 'false',
    );
  }

  @override
  FutureOr<String> validateConfig(
    String data, {
    String? ageSecretKey,
    SetupParams? setup,
  }) {
    final params = {
      'data': data,
      'age-secret-key': ageSecretKey ?? '',
      'setup': ?setup,
    };
    return invoke<String>(
      method: ActionMethod.validateConfig,
      data: json.encode(params),
    );
  }

  @override
  Future<String> importProfile(String params) {
    return invoke<String>(
      method: ActionMethod.importProfile,
      data: params,
      timeout: const Duration(minutes: 3),
      onTimeout: () => throw TimeoutException('importProfile timeout'),
    );
  }

  @override
  Future<Result> getRuntimeConfig(SetupParams setupParams) {
    return invoke<Result>(
      method: ActionMethod.getRuntimeConfig,
      data: json.encode(setupParams),
      timeout: const Duration(seconds: 60),
      defaultValue: Result.success(''),
    );
  }

  @override
  Future<Result> exportConfig(
    String path,
    String output, {
    String? ageSecretKey,
    String? providersPath,
    bool refresh = false,
  }) {
    return invoke<Result>(
      method: ActionMethod.exportConfig,
      data: json.encode({
        'path': path,
        'age-secret-key': ageSecretKey ?? '',
        'output': output,
        'expand-providers': providersPath != null,
        'providers-path': providersPath ?? '',
        'refresh': refresh,
      }),
      timeout: const Duration(seconds: 60),
      defaultValue: Result.error('exportConfig timeout'),
    );
  }

  @override
  Future<Result> mergeProfiles(String params) {
    return invoke<Result>(
      method: ActionMethod.mergeProfiles,
      data: params,
      timeout: const Duration(seconds: 120),
      defaultValue: Result.error('mergeProfiles timeout'),
    );
  }

  @override
  FutureOr<String> decryptAgeConfig(String data, String ageSecretKey) {
    final params = {'data': data, 'age-secret-key': ageSecretKey};
    return invoke<String>(
      method: ActionMethod.decryptAgeConfig,
      data: json.encode(params),
    );
  }

  @override
  Future<String> updateConfig(UpdateParams updateParams) async {
    return await invoke<String>(
      method: ActionMethod.updateConfig,
      data: json.encode(updateParams),
      timeout: const Duration(seconds: 60),
    );
  }

  @override
  Future<Result> getConfig(
    String path, {
    String? ageSecretKey,
    List<String> disabledGroups = const [],
    bool snippet = false,
  }) async {
    final params = {
      'path': path,
      'age-secret-key': ageSecretKey ?? '',
      'disabled-groups': disabledGroups,
      'snippet': snippet,
    };
    final res = await invoke<Result>(
      method: ActionMethod.getConfig,
      data: json.encode(params),
      timeout: const Duration(seconds: 60),
      defaultValue: Result.success(<String, dynamic>{}),
    );
    return res;
  }

  @override
  Future<SetupResult> setupConfig(SetupParams setupParams) async {
    final params = await Isolate.run(() => json.encode(setupParams));
    final data = await invoke<dynamic>(
      method: ActionMethod.setupConfig,
      data: params,
      timeout: const Duration(seconds: 15),
      onTimeout: () => throw TimeoutException('setupConfig timeout'),
    );
    return SetupResult.fromData(data);
  }

  @override
  Future<bool> crash() {
    return invoke<bool>(method: ActionMethod.crash);
  }

  @override
  Future<String> getProxies() {
    return invoke<String>(
      method: ActionMethod.getProxies,
      timeout: Duration(seconds: 5),
    );
  }

  @override
  FutureOr<String> changeProxy(ChangeProxyParams changeProxyParams) {
    return invoke<String>(
      method: ActionMethod.changeProxy,
      data: json.encode(changeProxyParams),
    );
  }

  @override
  FutureOr<String> getExternalProviders() {
    return invoke<String>(method: ActionMethod.getExternalProviders);
  }

  @override
  FutureOr<String> getExternalProvider(String externalProviderName) {
    return invoke<String>(
      method: ActionMethod.getExternalProvider,
      data: externalProviderName,
    );
  }

  @override
  Future<String> updateGeoData(UpdateGeoDataParams params) {
    return invoke<String>(
      method: ActionMethod.updateGeoData,
      data: json.encode(params),
      timeout: Duration(minutes: 1),
    );
  }

  @override
  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) {
    return invoke<String>(
      method: ActionMethod.sideLoadExternalProvider,
      data: json.encode({'providerName': providerName, 'data': data}),
    );
  }

  @override
  Future<String> updateExternalProvider(String providerName) {
    return invoke<String>(
      method: ActionMethod.updateExternalProvider,
      data: providerName,
      timeout: Duration(minutes: 1),
    );
  }

  @override
  Future<String> parseExternalProviderContent(String providerName) {
    return invoke<String>(
      method: ActionMethod.parseExternalProviderContent,
      data: providerName,
    );
  }

  @override
  FutureOr<String> getConnections() {
    return invoke<String>(method: ActionMethod.getConnections);
  }

  @override
  FutureOr<String> getConnectionsSummary() {
    return invoke<String>(method: ActionMethod.getConnectionsSummary);
  }

  @override
  Future<bool> closeConnections() {
    return invoke<bool>(method: ActionMethod.closeConnections);
  }

  @override
  Future<bool> closeGroupConnections(String groupName) {
    return invoke<bool>(
      method: ActionMethod.closeGroupConnections,
      data: groupName,
    );
  }

  @override
  Future<bool> resetConnections() {
    return invoke<bool>(method: ActionMethod.resetConnections);
  }

  @override
  Future<bool> closeConnection(String id) {
    return invoke<bool>(method: ActionMethod.closeConnection, data: id);
  }

  @override
  FutureOr<String> getTrafficSnapshot() {
    return invoke<String>(method: ActionMethod.getTrafficSnapshot);
  }

  @override
  FutureOr<String> getTraffic() {
    return invoke<String>(method: ActionMethod.getTraffic);
  }

  @override
  resetTraffic() {
    _invokeAndForget(ActionMethod.resetTraffic);
  }

  @override
  startLog() {
    _invokeAndForget(ActionMethod.startLog);
  }

  @override
  stopLog() {
    _invokeAndForget(ActionMethod.stopLog);
  }

  @override
  FutureOr<String> getLogs() {
    return invoke<String>(method: ActionMethod.getLogs);
  }

  @override
  FutureOr<bool> clearLogs() {
    return invoke<bool>(method: ActionMethod.clearLogs);
  }

  @override
  startTrackRequests() {
    _invokeAndForget(ActionMethod.startTrackRequests);
  }

  @override
  stopTrackRequests() {
    _invokeAndForget(ActionMethod.stopTrackRequests);
  }

  @override
  FutureOr<String> getRequests() {
    return invoke<String>(method: ActionMethod.getRequests);
  }

  @override
  FutureOr<bool> clearRequests() {
    return invoke<bool>(method: ActionMethod.clearRequests);
  }

  @override
  Future<bool> startListener() {
    return invoke<bool>(method: ActionMethod.startListener);
  }

  @override
  stopListener() {
    return invoke<bool>(method: ActionMethod.stopListener);
  }

  @override
  Future<String> asyncTestDelay(String url, String proxyName) {
    final delayParams = {
      'proxy-name': proxyName,
      'timeout': httpTimeoutDuration.inMilliseconds,
      'test-url': url,
    };
    return invoke<String>(
      method: ActionMethod.asyncTestDelay,
      data: json.encode(delayParams),
      timeout: Duration(milliseconds: 6000),
      onTimeout: () {
        return json.encode(Delay(name: proxyName, value: -1, url: url));
      },
    );
  }

  @override
  Future<String> asyncTestDelays(String params, Duration timeout) {
    return invoke<String>(
      method: ActionMethod.asyncTestDelays,
      data: params,
      timeout: timeout,
    );
  }

  @override
  Future<bool> setForeground(bool value) {
    return invoke<bool>(
      method: ActionMethod.setForeground,
      data: value ? 'true' : 'false',
    );
  }

  @override
  FutureOr<String> getCountryCode(String ip) {
    return invoke<String>(method: ActionMethod.getCountryCode, data: ip);
  }

  @override
  FutureOr<String> getMemory() {
    return invoke<String>(method: ActionMethod.getMemory);
  }

  @override
  FutureOr<String> getCoreStatus() {
    return invoke<String>(method: ActionMethod.getCoreStatus);
  }

  @override
  FutureOr<String> getInterfaces() {
    return invoke<String>(method: ActionMethod.getInterfaces);
  }

  @override
  Future<String> startSpeedTest(String params) {
    return invoke<String>(
      method: ActionMethod.startSpeedTest,
      data: params,
      timeout: const Duration(minutes: 3),
    );
  }

  @override
  FutureOr<bool> cancelSpeedTest() {
    return invoke<bool>(method: ActionMethod.cancelSpeedTest);
  }

  @override
  Future<String> probeSpeedTest(String params) {
    return invoke<String>(
      method: ActionMethod.probeSpeedTest,
      data: params,
      timeout: const Duration(seconds: 30),
    );
  }

  @override
  Future<String> getSpeedTestServers(String params) {
    return invoke<String>(
      method: ActionMethod.getSpeedTestServers,
      data: params,
      timeout: const Duration(seconds: 30),
    );
  }

  @override
  Future<String> startStunTest(String params) {
    return invoke<String>(
      method: ActionMethod.startStunTest,
      data: params,
      timeout: const Duration(seconds: 60),
    );
  }

  @override
  FutureOr<bool> cancelStunTest() {
    return invoke<bool>(method: ActionMethod.cancelStunTest);
  }

  @override
  Future<String> startIperfServer(String params) {
    return invoke<String>(
      method: ActionMethod.startIperfServer,
      data: params,
      timeout: const Duration(seconds: 15),
    );
  }

  @override
  FutureOr<bool> stopIperfServer() {
    return invoke<bool>(
      method: ActionMethod.stopIperfServer,
      timeout: const Duration(seconds: 15),
    );
  }

  @override
  Future<String> startIperfClient(String params, Duration timeout) {
    return invoke<String>(
      method: ActionMethod.startIperfClient,
      data: params,
      timeout: timeout,
    );
  }

  @override
  FutureOr<bool> cancelIperfClient() {
    return invoke<bool>(method: ActionMethod.cancelIperfClient);
  }

  @override
  Future<String> startLocalPing(String params, Duration timeout) {
    return invoke<String>(
      method: ActionMethod.startLocalPing,
      data: params,
      timeout: timeout,
    );
  }

  @override
  FutureOr<bool> cancelLocalPing() {
    return invoke<bool>(method: ActionMethod.cancelLocalPing);
  }

  @override
  Future<String> toolboxInvoke(ActionMethod method, {String data = ''}) {
    return invoke<String>(
      method: method,
      data: data,
      timeout: const Duration(seconds: 90),
    );
  }

  @override
  FutureOr<bool> flushFakeIP() {
    return invoke<bool>(method: ActionMethod.flushFakeIP);
  }

  @override
  FutureOr<bool> flushDnsCache() {
    return invoke<bool>(method: ActionMethod.flushDnsCache);
  }

  @override
  Future<String> getMode() {
    return invoke<String>(method: ActionMethod.getMode);
  }

  @override
  Future<Map<String, String>> generateAgeKeyPair({bool hybrid = false}) async {
    final res = await invoke<Map>(
      method: ActionMethod.generateAgeKeyPair,
      data: hybrid ? 'mlkem768x25519' : 'x25519',
    );
    return res.map((key, value) => MapEntry(key.toString(), value.toString()));
  }

  @override
  Future<Result<String>> convertAgeSecretKeyToPublicKey(
    String secretKey,
  ) async {
    final res = await invoke<Result>(
      method: ActionMethod.convertAgeSecretKeyToPublicKey,
      data: secretKey,
      defaultValue: Result.error('error'),
    );
    return Result<String>(
      data: res.data?.toString(),
      type: res.type,
      message: res.message,
    );
  }
}
