import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/clash/interface.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:intl/intl.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

@visibleForTesting
List<Group> buildGroups(String proxiesRaw, List<ExternalProvider> providers) {
  final decoded = json.decode(proxiesRaw);
  if (decoded is! Map) return [];
  final names = (decoded['names'] as List? ?? const []).cast<String>();
  final types = (decoded['types'] as List? ?? const []).cast<String>();
  final allProxies = <String, dynamic>{
    for (var i = 0; i < names.length; i++)
      names[i]: <String, dynamic>{'name': names[i], 'type': types[i]},
  };
  for (final entry in (decoded['groups'] as Map? ?? const {}).entries) {
    final group = Map<String, dynamic>.from(entry.value as Map);
    group['all'] = [
      for (final member in (group['all'] ?? const []) as List)
        member is int ? names[member] : member,
    ];
    allProxies[entry.key as String] = group;
  }
  for (final provider in providers) {
    if (provider.proxies != null) {
      for (final proxy in provider.proxies!) {
        if (proxy is Map) {
          final proxyMap = Map<String, dynamic>.from(proxy);
          final name = proxyMap['name'];
          if (name != null) {
            allProxies[name] = proxyMap;
            final suffix = '[${provider.name}]';
            if (!name.endsWith(suffix)) {
              allProxies['$name$suffix'] = proxyMap;
            }
          }
        }
      }
    }
  }

  final globalProxy = allProxies[UsedProxy.GLOBAL.name];
  final groupNames = <String>[];
  final seenGroupNames = <String>{};

  if (globalProxy != null) {
    groupNames.add(UsedProxy.GLOBAL.name);
    seenGroupNames.add(UsedProxy.GLOBAL.name);

    final allList = globalProxy['all'] as List?;
    if (allList != null) {
      for (final item in allList) {
        final name = item.toString();
        final proxy = allProxies[name];
        if (proxy is Map &&
            GroupTypeExtension.valueList.contains(proxy['type'])) {
          if (seenGroupNames.add(name)) {
            groupNames.add(name);
          }
        }
      }
    }
  }

  for (final entry in allProxies.entries) {
    final proxy = entry.value;
    if (proxy is Map && GroupTypeExtension.valueList.contains(proxy['type'])) {
      final name = entry.key;
      if (seenGroupNames.add(name)) {
        groupNames.add(name);
      }
    }
  }

  final members = <Object?, Proxy>{};
  final groups = <Group>[];
  for (final groupName in groupNames) {
    final proxyData = allProxies[groupName];
    if (proxyData is! Map) continue;
    final all = <Proxy>[];
    for (final name in (proxyData['all'] ?? const []) as List) {
      final data = allProxies[name];
      if (data is! Map) continue;
      all.add(
        members[name] ??= Proxy.fromJson(Map<String, dynamic>.from(data)),
      );
    }
    groups.add(
      Group.fromJson({
        ...proxyData.cast<String, dynamic>(),
        'all': const <dynamic>[],
      }).copyWith(all: all),
    );
  }
  return groups;
}

class ClashCore {
  static ClashCore? _instance;
  late ClashHandlerInterface clashInterface;

  ClashCore._internal() {
    if (system.isAndroid) {
      clashInterface = clashLib!;
    } else {
      clashInterface = clashService!;
    }
  }

  factory ClashCore() {
    _instance ??= ClashCore._internal();
    return _instance!;
  }

  Future<bool> preload() {
    return clashInterface.preload();
  }

  static Future<void> initGeo() async {
    final homePath = await appPath.homeDirPath;
    final homeDir = Directory(homePath);
    if (!await homeDir.exists()) {
      await homeDir.create(recursive: true);
    }
    const geoFileNameList = [mmdbFileName, geoSiteFileName, asnFileName];
    try {
      for (final geoFileName in geoFileNameList) {
        final geoFile = File(join(homePath, geoFileName));
        if (await geoFile.exists()) continue;
        final data = await rootBundle.load('assets/data/$geoFileName');
        await geoFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
      }
      await syncBundleMRS(homePath);
    } catch (e) {
      exit(0);
    }
    try {
      final legacyConfigFile = File(join(homePath, 'config.yaml'));
      if (await legacyConfigFile.exists()) {
        await legacyConfigFile.delete();
      }
    } catch (_) {}
  }

  @visibleForTesting
  static Future<void> syncBundleMRS(String homePath) async {
    final bundleFile = File(join(homePath, bundleMRSFileName));
    final versionFile = File(join(homePath, '$bundleMRSFileName.version'));
    final packageInfo = globalState.packageInfo;
    final version = '${packageInfo.version}+${packageInfo.buildNumber}';
    final exists = await bundleFile.exists();
    if (exists &&
        await versionFile.exists() &&
        await versionFile.readAsString() == version) {
      return;
    }
    final tempFile = File(
      '${bundleFile.path}.${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    try {
      final data = await rootBundle.load('assets/data/$bundleMRSFileName');
      await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
      await tempFile.rename(bundleFile.path);
      await versionFile.writeAsString(version, flush: true);
    } catch (e) {
      if (!exists) rethrow;
      commonPrint.warn('Failed to refresh $bundleMRSFileName: $e');
    } finally {
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }
  }

  Future<bool> init() async {
    await initGeo();
    final homeDirPath = await appPath.homeDirPath;
    return await clashInterface.init(
      InitParams(homeDir: homeDirPath, version: globalState.appState.version),
    );
  }

  Future<bool> setState(CoreState state) async {
    return await clashInterface.setState(state);
  }

  Future<void> shutdown() async {
    await clashInterface.shutdown();
  }

  FutureOr<bool> get isInit => clashInterface.isInit;

  FutureOr<String> validateConfig(
    String data, {
    String? ageSecretKey,
    SetupParams? setup,
  }) {
    return clashInterface.validateConfig(
      data,
      ageSecretKey: ageSecretKey,
      setup: setup,
    );
  }

  Future<String> getRuntimeConfig(SetupParams setupParams) async {
    final res = await clashInterface.getRuntimeConfig(setupParams);
    if (res.isError) {
      throw res.message;
    }
    return res.data?.toString() ?? '';
  }

  Future<void> exportConfig(
    String id,
    String output, {
    String? ageSecretKey,
  }) async {
    final res = await clashInterface.exportConfig(
      await appPath.getProfilePath(id),
      output,
      ageSecretKey: ageSecretKey,
    );
    if (res.isError) {
      throw res.message;
    }
  }

  FutureOr<String> decryptAgeConfig(String data, String ageSecretKey) {
    return clashInterface.decryptAgeConfig(data, ageSecretKey);
  }

  Future<String> updateConfig(UpdateParams updateParams) async {
    return await clashInterface.updateConfig(updateParams);
  }

  Future<SetupResult> setupConfig(SetupParams setupParams) async {
    return await clashInterface.setupConfig(setupParams);
  }

  Future<List<Group>> getProxiesGroups({
    List<ExternalProvider>? preloadedProviders,
  }) async {
    final proxiesRaw = await clashInterface.getProxies();
    if (proxiesRaw.isEmpty) return [];

    final providers = preloadedProviders ?? await getExternalProviders();

    return Isolate.run<List<Group>>(() => buildGroups(proxiesRaw, providers));
  }

  FutureOr<String> changeProxy(ChangeProxyParams changeProxyParams) async {
    return await clashInterface.changeProxy(changeProxyParams);
  }

  Future<Mode> getMode() async {
    final modeStr = await clashInterface.getMode();
    return Mode.values.firstWhere(
      (m) => m.name == modeStr.toLowerCase(),
      orElse: () => Mode.rule,
    );
  }

  Future<List<TrackerInfo>> getConnections() async {
    final res = await clashInterface.getConnections();
    if (res.isEmpty) {
      return [];
    }
    try {
      return await Isolate.run<List<TrackerInfo>>(() {
        final connectionsData = json.decode(res) as Map;
        final connectionsRaw = connectionsData['connections'] as List? ?? [];
        return connectionsRaw.map((e) => TrackerInfo.fromJson(e)).toList();
      });
    } catch (e) {
      commonPrint.warn('Failed to parse connections: $e');
      return [];
    }
  }

  void _forget(FutureOr<Object?> request, String name) {
    Future.value(request).then<void>(
      (_) {},
      onError: (Object e) => commonPrint.debug('$name ignored: $e'),
    );
  }

  void closeConnection(String id) {
    _forget(clashInterface.closeConnection(id), 'closeConnection');
  }

  Future<void> closeConnections() async {
    await clashInterface.closeConnections();
  }

  void resetConnections() {
    _forget(clashInterface.resetConnections(), 'resetConnections');
  }

  Future<List<ExternalProvider>> getExternalProviders() async {
    final externalProvidersRawString = await clashInterface
        .getExternalProviders();
    if (externalProvidersRawString.isEmpty) {
      return [];
    }
    try {
      return await Isolate.run<List<ExternalProvider>>(() {
        final externalProviders =
            (json.decode(externalProvidersRawString) as List<dynamic>)
                .map((item) => ExternalProvider.fromJson(item))
                .toList();
        return externalProviders;
      });
    } catch (e) {
      commonPrint.warn('Failed to parse external providers: $e');
      return [];
    }
  }

  Future<ExternalProvider?> getExternalProvider(
    String externalProviderName,
  ) async {
    final externalProvidersRawString = await clashInterface.getExternalProvider(
      externalProviderName,
    );
    if (externalProvidersRawString.isEmpty) {
      return null;
    }
    try {
      return ExternalProvider.fromJson(json.decode(externalProvidersRawString));
    } catch (e) {
      commonPrint.warn('Failed to parse external provider: $e');
      return null;
    }
  }

  Future<String> updateGeoData(UpdateGeoDataParams params) {
    return clashInterface.updateGeoData(params);
  }

  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) {
    return clashInterface.sideLoadExternalProvider(
      providerName: providerName,
      data: data,
    );
  }

  Future<String> updateExternalProvider({required String providerName}) async {
    return clashInterface.updateExternalProvider(providerName);
  }

  Future<String> parseExternalProviderContent(String providerName) {
    return clashInterface.parseExternalProviderContent(providerName);
  }

  Future<void> startListener() async {
    await clashInterface.startListener();
  }

  Future<void> stopListener() async {
    await clashInterface.stopListener();
  }

  Future<Delay> getDelay(String url, String proxyName) async {
    final data = await clashInterface.asyncTestDelay(url, proxyName);
    if (data.isEmpty) {
      throw Exception('Empty delay response');
    }
    try {
      return Delay.fromJson(json.decode(data));
    } catch (e) {
      commonPrint.warn('Failed to parse delay: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getConfig(
    String id, {
    String? ageSecretKey,
    List<String> disabledGroups = const [],
  }) async {
    final profilePath = await appPath.getProfilePath(id);
    final res = await clashInterface.getConfig(
      profilePath,
      ageSecretKey: ageSecretKey,
      disabledGroups: disabledGroups,
    );
    if (res.isSuccess) {
      final data = res.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return <String, dynamic>{};
    } else {
      throw res.message;
    }
  }

  Future<Traffic> getTraffic() async {
    final trafficString = await clashInterface.getTraffic();
    if (trafficString.isEmpty) {
      return Traffic();
    }
    try {
      return Traffic.fromMap(json.decode(trafficString));
    } catch (e) {
      commonPrint.warn('Failed to parse traffic: $e');
      return Traffic();
    }
  }

  Future<IpInfo?> getCountryCode(String ip) async {
    final countryCode = await clashInterface.getCountryCode(ip);
    if (countryCode.isEmpty) {
      return null;
    }
    return IpInfo(ip: ip, countryCode: countryCode);
  }

  Future<Traffic> getTotalTraffic() async {
    final totalTrafficString = await clashInterface.getTotalTraffic();
    if (totalTrafficString.isEmpty) {
      return Traffic();
    }
    try {
      return Traffic.fromMap(json.decode(totalTrafficString));
    } catch (e) {
      commonPrint.warn('Failed to parse total traffic: $e');
      return Traffic();
    }
  }

  Future<int> getMemory() async {
    final value = await clashInterface.getMemory();
    if (value.isEmpty) {
      return 0;
    }
    return int.parse(value);
  }

  Future<CoreStatus?> getCoreStatus() async {
    final value = await clashInterface.getCoreStatus();
    if (value.isEmpty) {
      return null;
    }
    final decoded = json.decode(value);
    if (decoded is! Map) {
      return null;
    }
    return CoreStatus.fromJson(Map<String, dynamic>.from(decoded));
  }

  /// Status of the app's Tailscale node; null when none is configured.
  Future<TailscaleStatus?> getTailscaleStatus() async {
    final value = await clashInterface.getTailscaleStatus();
    if (value.isEmpty) return null;
    final decoded = json.decode(value);
    if (decoded is! Map) return null;
    return TailscaleStatus.fromJson(Map<String, dynamic>.from(decoded));
  }

  /// Starts the app's Tailscale node (a no-op if running); a login URL then
  /// arrives as a tailscaleAuth message.
  Future<void> startTailscale() async {
    await clashInterface.startTailscale();
  }

  SpeedTestState? _decodeSpeedTestState(String value) {
    if (value.isEmpty) {
      return null;
    }
    final decoded = json.decode(value);
    if (decoded is! Map) {
      return null;
    }
    return SpeedTestState.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<SpeedTestState?> startSpeedTest({
    required SpeedTestSettings settings,
    required String proxy,
  }) async {
    final value = await clashInterface.startSpeedTest(
      json.encode(settings.toParams(proxy)),
    );
    return _decodeSpeedTestState(value);
  }

  Future<SpeedTestState?> probeSpeedTest({
    required SpeedTestSettings settings,
    required String proxy,
  }) async {
    final isZh = Intl.getCurrentLocale().toLowerCase().startsWith('zh');
    final value = await clashInterface.probeSpeedTest(
      json.encode({...settings.toParams(proxy), 'lang': isZh ? 'zh-CN' : ''}),
    );
    return _decodeSpeedTestState(value);
  }

  Future<List<SpeedTestNode>> getSpeedTestServers({
    required String proxy,
    String search = '',
  }) async {
    final value = await clashInterface.getSpeedTestServers(
      json.encode({'proxy': proxy, 'search': search}),
    );
    if (value.isEmpty) return const [];
    final decoded = json.decode(value);
    if (decoded is! List) return const [];
    return [
      for (final item in decoded)
        if (item is Map)
          SpeedTestNode.fromJson(Map<String, Object?>.from(item)),
    ];
  }

  Future<void> cancelSpeedTest() async {
    await clashInterface.cancelSpeedTest();
  }

  Future<StunTestState?> startStunTest({
    required String server,
    required String proxy,
  }) async {
    final value = await clashInterface.startStunTest(
      json.encode({'server': server, 'proxy': proxy}),
    );
    if (value.isEmpty) {
      return null;
    }
    final decoded = json.decode(value);
    if (decoded is! Map) {
      return null;
    }
    return StunTestState.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> cancelStunTest() async {
    await clashInterface.cancelStunTest();
  }

  Future<IperfServerInfo> startIperfServer(int port) async {
    final value = await clashInterface.startIperfServer(
      json.encode({'port': port}),
    );
    final decoded = value.isEmpty ? null : json.decode(value);
    if (decoded is! Map) return const IperfServerInfo(error: 'listen');
    return IperfServerInfo.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> stopIperfServer() async {
    await clashInterface.stopIperfServer();
  }

  Future<IperfState?> startIperfClient({
    required List<String> hosts,
    required int port,
    required IperfOptions options,
  }) async {
    final value = await clashInterface.startIperfClient(
      json.encode({
        'hosts': hosts,
        'port': port,
        'protocol': options.protocol.name,
        'direction': options.direction.name,
        'parallel': options.parallel,
        'duration': options.duration,
        'bandwidth': options.protocol == IperfProtocol.udp
            ? options.bandwidth * 1e6
            : 0,
      }),
      Duration(seconds: options.duration + 45),
    );
    final decoded = value.isEmpty ? null : json.decode(value);
    if (decoded is! Map) return null;
    return IperfState.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> cancelIperfClient() async {
    await clashInterface.cancelIperfClient();
  }

  Future<LocalPingState?> startLocalPing({
    required String target,
    required LocalPingOptions options,
  }) async {
    final value = await clashInterface.startLocalPing(
      json.encode({
        'target': target,
        'protocol': options.protocol.name,
        'port': options.port,
        'count': options.count,
        'interval': options.interval,
        'size': options.size,
      }),
      Duration(milliseconds: options.count * options.interval) +
          const Duration(seconds: 30),
    );
    final decoded = value.isEmpty ? null : json.decode(value);
    if (decoded is! Map) return null;
    return LocalPingState.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> cancelLocalPing() async {
    await clashInterface.cancelLocalPing();
  }

  Future<Map<String, Object?>> _toolboxJson(
    ActionMethod method, {
    String data = '',
  }) async {
    final value = await clashInterface.toolboxInvoke(method, data: data);
    if (value.isEmpty) return {};
    final decoded = json.decode(value);
    return decoded is Map ? Map<String, Object?>.from(decoded) : {};
  }

  Future<RouteTraceResult> routeTrace({
    required String target,
    required String network,
    required int port,
  }) async => RouteTraceResult.fromJson(
    await _toolboxJson(
      ActionMethod.routeTrace,
      data: json.encode({'target': target, 'network': network, 'port': port}),
    ),
  );

  Future<DnsQueryResult> dnsQuery({
    required String domain,
    required String type,
    required String mode,
    String server = '',
  }) async => DnsQueryResult.fromJson(
    await _toolboxJson(
      ActionMethod.dnsQuery,
      data: json.encode({
        'domain': domain,
        'type': type,
        'mode': mode,
        'server': server,
      }),
    ),
  );

  Future<MrsPrepareResult> mrsPrepare() async =>
      MrsPrepareResult.fromJson(await _toolboxJson(ActionMethod.mrsPrepare));

  Future<MrsLookupResult> mrsLookup(
    String target, {
    bool resolve = true,
  }) async => MrsLookupResult.fromJson(
    await _toolboxJson(
      ActionMethod.mrsLookup,
      data: json.encode({'target': target, 'resolve': resolve}),
    ),
  );

  Future<void> cancelMrsLookup() async {
    await clashInterface.toolboxInvoke(ActionMethod.cancelMrsLookup);
  }

  Future<int> startToolProxy() async {
    final value = await clashInterface.toolboxInvoke(
      ActionMethod.startToolProxy,
    );
    return int.tryParse(value) ?? 0;
  }

  Future<void> stopToolProxy() async {
    await clashInterface.toolboxInvoke(ActionMethod.stopToolProxy);
  }

  Future<AgeCryptResult> ageCrypt({
    required bool encrypt,
    required String data,
    required List<String> keys,
  }) async => AgeCryptResult.fromJson(
    await _toolboxJson(
      ActionMethod.ageCrypt,
      data: json.encode({
        'mode': encrypt ? 'encrypt' : 'decrypt',
        'data': data,
        'keys': keys,
      }),
    ),
  );

  void resetTraffic() {
    clashInterface.resetTraffic();
  }

  void startLog() {
    clashInterface.startLog();
  }

  void stopLog() {
    clashInterface.stopLog();
  }

  Future<List<Log>> getLogs() async {
    final res = await clashInterface.getLogs();
    if (res.isEmpty) {
      return [];
    }
    try {
      return await Isolate.run<List<Log>>(() {
        final logsRaw = json.decode(res) as List? ?? [];
        return logsRaw.map((e) => Log.core(e)).toList();
      });
    } catch (e) {
      commonPrint.warn('Failed to parse logs: $e');
      return [];
    }
  }

  void clearLogs() {
    _forget(clashInterface.clearLogs(), 'clearLogs');
  }

  Future<List<TrackerInfo>> getRequests() async {
    final res = await clashInterface.getRequests();
    if (res.isEmpty) {
      return [];
    }
    try {
      return await Isolate.run<List<TrackerInfo>>(() {
        final requestsRaw = json.decode(res) as List? ?? [];
        return requestsRaw.map((e) => TrackerInfo.fromJson(e)).toList();
      });
    } catch (e) {
      commonPrint.warn('Failed to parse requests: $e');
      return [];
    }
  }

  void startTrackRequests() {
    clashInterface.startTrackRequests();
  }

  void stopTrackRequests() {
    clashInterface.stopTrackRequests();
  }

  void clearRequests() {
    _forget(clashInterface.clearRequests(), 'clearRequests');
  }

  Future<void> requestGc({bool forceFreeOSMemory = false}) async {
    await clashInterface.forceGc(forceFreeOSMemory: forceFreeOSMemory);
  }

  Future<void> flushFakeIP() async {
    await clashInterface.flushFakeIP();
  }

  Future<void> flushDnsCache() async {
    await clashInterface.flushDnsCache();
  }

  Future<Map<String, String>> generateAgeKeyPair({bool hybrid = false}) {
    return clashInterface.generateAgeKeyPair(hybrid: hybrid);
  }

  Future<Result<String>> convertAgeSecretKeyToPublicKey(String secretKey) {
    return clashInterface.convertAgeSecretKeyToPublicKey(secretKey);
  }

  Future<void> destroy() async {
    await clashInterface.destroy();
  }
}

final clashCore = ClashCore();
