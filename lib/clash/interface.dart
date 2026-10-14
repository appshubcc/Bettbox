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

  Future<bool> forceGc({bool forceFreeOSMemory = false});

  FutureOr<String> validateConfig(
    String data, {
    String? ageSecretKey,
    SetupParams? setup,
  });

  Future<Result> getRuntimeConfig(SetupParams setupParams);

  Future<Result> exportConfig(
    String path,
    String output, {
    String? ageSecretKey,
  });

  FutureOr<String> decryptAgeConfig(String data, String ageSecretKey);

  FutureOr<Result> getConfig(
    String path, {
    String? ageSecretKey,
    List<String> disabledGroups,
  });

  Future<Map<String, String>> generateAgeKeyPair();

  Future<Result<String>> convertAgeSecretKeyToPublicKey(String secretKey);

  Future<String> asyncTestDelay(String url, String proxyName);

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

  FutureOr<String> getTotalTraffic();

  FutureOr<String> getCountryCode(String ip);

  FutureOr<String> getMemory();

  FutureOr<String> getCoreStatus();

  FutureOr<String> getTailscaleStatus();

  FutureOr<bool> startTailscale();

  FutureOr<void> resetTraffic();

  FutureOr<void> startLog();

  FutureOr<void> stopLog();

  FutureOr<String> getLogs();

  FutureOr<bool> clearLogs();

  Future<bool> crash();

  FutureOr<String> getConnections();

  FutureOr<bool> closeConnection(String id);

  FutureOr<bool> closeConnections();

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
        case ActionMethod.convertAgeSecretKeyToPublicKey:
          completer?.complete(result.toResult);
          return;
        case ActionMethod.generateAgeKeyPair:
          completer?.complete(result.data);
          return;
        default:
          completer?.complete(result.data);
          return;
      }
    } catch (e) {
      commonPrint.warn('${result.id} error $e');
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
  Future<bool> forceGc({bool forceFreeOSMemory = false}) {
    return invoke<bool>(
      method: ActionMethod.forceGc,
      data: forceFreeOSMemory ? 'true' : 'false',
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
  }) {
    return invoke<Result>(
      method: ActionMethod.exportConfig,
      data: json.encode({
        'path': path,
        'age-secret-key': ageSecretKey ?? '',
        'output': output,
      }),
      timeout: const Duration(seconds: 60),
      defaultValue: Result.error('exportConfig timeout'),
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
  }) async {
    final params = {
      'path': path,
      'age-secret-key': ageSecretKey ?? '',
      'disabled-groups': disabledGroups,
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
  Future<bool> closeConnections() {
    return invoke<bool>(method: ActionMethod.closeConnections);
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
  FutureOr<String> getTotalTraffic() {
    return invoke<String>(method: ActionMethod.getTotalTraffic);
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
  FutureOr<String> getTailscaleStatus() {
    return invoke<String>(method: ActionMethod.getTailscaleStatus);
  }

  @override
  FutureOr<bool> startTailscale() {
    return invoke<bool>(method: ActionMethod.startTailscale);
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
  Future<Map<String, String>> generateAgeKeyPair() async {
    final res = await invoke<Map>(method: ActionMethod.generateAgeKeyPair);
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
