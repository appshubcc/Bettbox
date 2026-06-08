import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/clash/interface.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

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
    const geoFileNameList = [mmdbFileName, geoSiteFileName, asnFileName, bundleMRSFileName];
    try {
      for (final geoFileName in geoFileNameList) {
        final geoFile = File(join(homePath, geoFileName));
        if (await geoFile.exists()) continue;
        final data = await rootBundle.load('assets/data/$geoFileName');
        await geoFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
      }
    } catch (e) {
      exit(0);
    }
  }

  Future<bool> init() async {
    await initGeo();
    if (globalState.config.appSetting.openLogs) {
      clashCore.startLog();
    } else {
      clashCore.stopLog();
    }
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

  FutureOr<String> validateConfig(String data, {String? ageSecretKey}) {
    return clashInterface.validateConfig(data, ageSecretKey: ageSecretKey);
  }

  Future<String> updateConfig(UpdateParams updateParams) async {
    return await clashInterface.updateConfig(updateParams);
  }

  Future<String> setupConfig(SetupParams setupParams) async {
    return await clashInterface.setupConfig(setupParams);
  }

  Future<List<Group>> getProxiesGroups() async {
    final proxies = await clashInterface.getProxies();
    if (proxies.isEmpty) return [];

    return Isolate.run<List<Group>>(() {
      final globalProxy = proxies[UsedProxy.GLOBAL.name];
      if (globalProxy == null) return [];

      final allList = globalProxy['all'] as List?;
      if (allList == null) return [];

      final groupNames = [
        UsedProxy.GLOBAL.name,
        ...allList.where((e) {
          final proxy = proxies[e] as Map<String, dynamic>?;
          return GroupTypeExtension.valueList.contains(proxy?['type']);
        }),
      ];
      final groupsRaw = groupNames.map((groupName) {
        final proxyData = proxies[groupName] as Map?;
        if (proxyData == null) return null;
        final group = Map<String, dynamic>.from(
          proxyData.cast<String, dynamic>(),
        );
        group['all'] = ((group['all'] ?? []) as List)
            .map((name) => proxies[name])
            .whereType<Map<String, dynamic>>()
            .toList();
        return group;
      }).whereType<Map<String, dynamic>>().toList();
      return groupsRaw.map((e) => Group.fromJson(e)).toList();
    });
  }

  FutureOr<String> changeProxy(ChangeProxyParams changeProxyParams) async {
    return await clashInterface.changeProxy(changeProxyParams);
  }

  Future<List<TrackerInfo>> getConnections() async {
    final res = await clashInterface.getConnections();
    if (res.isEmpty) {
      return [];
    }
    try {
      final connectionsData = json.decode(res) as Map;
      final connectionsRaw = connectionsData['connections'] as List? ?? [];
      return connectionsRaw.map((e) => TrackerInfo.fromJson(e)).toList();
    } catch (e) {
      commonPrint.log('Failed to parse connections: $e');
      return [];
    }
  }

  void closeConnection(String id) {
    clashInterface.closeConnection(id);
  }

  void closeConnections() {
    clashInterface.closeConnections();
  }

  void resetConnections() {
    clashInterface.resetConnections();
  }

  Future<List<ExternalProvider>> getExternalProviders() async {
    final externalProvidersRawString = await clashInterface
        .getExternalProviders();
    if (externalProvidersRawString.isEmpty) {
      return [];
    }
    try {
      return Isolate.run<List<ExternalProvider>>(() {
        final externalProviders =
            (json.decode(externalProvidersRawString) as List<dynamic>)
                .map((item) => ExternalProvider.fromJson(item))
                .toList();
        return externalProviders;
      });
    } catch (e) {
      commonPrint.log('Failed to parse external providers: $e');
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
      commonPrint.log('Failed to parse external provider: $e');
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
      commonPrint.log('Failed to parse delay: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getConfig(String id, {String? ageSecretKey}) async {
    final profilePath = await appPath.getProfilePath(id);
    final res = await clashInterface.getConfig(profilePath, ageSecretKey: ageSecretKey);
    if (res.isSuccess) {
      return res.data as Map<String, dynamic>;
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
      commonPrint.log('Failed to parse traffic: $e');
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
      commonPrint.log('Failed to parse total traffic: $e');
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

  void resetTraffic() {
    clashInterface.resetTraffic();
  }

  void startLog() {
    clashInterface.startLog();
  }

  void stopLog() {
    clashInterface.stopLog();
  }

  Future<void> requestGc() async {
    await clashInterface.forceGc();
  }

  Future<void> flushFakeIP() async {
    await clashInterface.flushFakeIP();
  }

  Future<void> flushDnsCache() async {
    await clashInterface.flushDnsCache();
  }

  Future<Map<String, String>> generateAgeKeyPair() {
    return clashInterface.generateAgeKeyPair();
  }

  Future<Result<String>> convertAgeSecretKeyToPublicKey(String secretKey) {
    return clashInterface.convertAgeSecretKeyToPublicKey(secretKey);
  }

  Future<void> destroy() async {
    await clashInterface.destroy();
  }
}

final clashCore = ClashCore();