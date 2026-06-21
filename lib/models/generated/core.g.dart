// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../core.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SetupParams _$SetupParamsFromJson(Map<String, dynamic> json) => _SetupParams(
  config: json['config'] as Map<String, dynamic>,
  selectedMap: Map<String, String>.from(json['selected-map'] as Map),
  testUrl: json['test-url'] as String,
  overrideTestUrl: json['override-test-url'] as bool? ?? true,
);

Map<String, dynamic> _$SetupParamsToJson(_SetupParams instance) =>
    <String, dynamic>{
      'config': instance.config,
      'selected-map': instance.selectedMap,
      'test-url': instance.testUrl,
      'override-test-url': instance.overrideTestUrl,
    };

_UpdateParams _$UpdateParamsFromJson(Map<String, dynamic> json) =>
    _UpdateParams(
      tun: Tun.fromJson(json['tun'] as Map<String, dynamic>),
      mixedPort: (json['mixed-port'] as num).toInt(),
      allowLan: json['allow-lan'] as bool,
      findProcessMode: $enumDecode(
        _$FindProcessModeEnumMap,
        json['find-process-mode'],
      ),
      mode: $enumDecode(_$ModeEnumMap, json['mode']),
      logLevel: $enumDecode(_$LogLevelEnumMap, json['log-level']),
      ipv6: json['ipv6'] as bool,
      tcpConcurrent: json['tcp-concurrent'] as bool,
      externalController: $enumDecode(
        _$ExternalControllerStatusEnumMap,
        json['external-controller'],
      ),
      unifiedDelay: json['unified-delay'] as bool,
    );

Map<String, dynamic> _$UpdateParamsToJson(_UpdateParams instance) =>
    <String, dynamic>{
      'tun': instance.tun,
      'mixed-port': instance.mixedPort,
      'allow-lan': instance.allowLan,
      'find-process-mode': _$FindProcessModeEnumMap[instance.findProcessMode]!,
      'mode': _$ModeEnumMap[instance.mode]!,
      'log-level': _$LogLevelEnumMap[instance.logLevel]!,
      'ipv6': instance.ipv6,
      'tcp-concurrent': instance.tcpConcurrent,
      'external-controller':
          _$ExternalControllerStatusEnumMap[instance.externalController]!,
      'unified-delay': instance.unifiedDelay,
    };

const _$FindProcessModeEnumMap = {
  FindProcessMode.always: 'always',
  FindProcessMode.off: 'off',
};

const _$ModeEnumMap = {
  Mode.rule: 'rule',
  Mode.global: 'global',
  Mode.direct: 'direct',
};

const _$LogLevelEnumMap = {
  LogLevel.debug: 'debug',
  LogLevel.info: 'info',
  LogLevel.warning: 'warning',
  LogLevel.error: 'error',
  LogLevel.silent: 'silent',
};

const _$ExternalControllerStatusEnumMap = {
  ExternalControllerStatus.close: '',
  ExternalControllerStatus.open: '127.0.0.1:9090',
};

_CoreState _$CoreStateFromJson(Map<String, dynamic> json) => _CoreState(
  vpnProps: VpnProps.fromJson(json['vpn-props'] as Map<String, dynamic>),
  onlyStatisticsProxy: json['only-statistics-proxy'] as bool,
  currentProfileName: json['current-profile-name'] as String,
  bypassDomain:
      (json['bypass-domain'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$CoreStateToJson(_CoreState instance) =>
    <String, dynamic>{
      'vpn-props': instance.vpnProps,
      'only-statistics-proxy': instance.onlyStatisticsProxy,
      'current-profile-name': instance.currentProfileName,
      'bypass-domain': instance.bypassDomain,
    };

_AndroidVpnOptions _$AndroidVpnOptionsFromJson(Map<String, dynamic> json) =>
    _AndroidVpnOptions(
      enable: json['enable'] as bool,
      port: (json['port'] as num).toInt(),
      accessControl: json['accessControl'] == null
          ? null
          : AccessControl.fromJson(
              json['accessControl'] as Map<String, dynamic>,
            ),
      allowBypass: json['allowBypass'] as bool,
      systemProxy: json['systemProxy'] as bool,
      bypassDomain: (json['bypassDomain'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      ipv4Address: json['ipv4Address'] as String,
      ipv6Address: json['ipv6Address'] as String,
      routeAddress:
          (json['routeAddress'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      routeMode: json['routeMode'] as String? ?? 'config',
      dnsServerAddress: json['dnsServerAddress'] as String,
      dozeSuspend: json['dozeSuspend'] as bool? ?? false,
    );

Map<String, dynamic> _$AndroidVpnOptionsToJson(_AndroidVpnOptions instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'port': instance.port,
      'accessControl': instance.accessControl,
      'allowBypass': instance.allowBypass,
      'systemProxy': instance.systemProxy,
      'bypassDomain': instance.bypassDomain,
      'ipv4Address': instance.ipv4Address,
      'ipv6Address': instance.ipv6Address,
      'routeAddress': instance.routeAddress,
      'routeMode': instance.routeMode,
      'dnsServerAddress': instance.dnsServerAddress,
      'dozeSuspend': instance.dozeSuspend,
    };

_InitParams _$InitParamsFromJson(Map<String, dynamic> json) => _InitParams(
  homeDir: json['home-dir'] as String,
  version: (json['version'] as num).toInt(),
);

Map<String, dynamic> _$InitParamsToJson(_InitParams instance) =>
    <String, dynamic>{
      'home-dir': instance.homeDir,
      'version': instance.version,
    };

_ChangeProxyParams _$ChangeProxyParamsFromJson(Map<String, dynamic> json) =>
    _ChangeProxyParams(
      groupName: json['group-name'] as String,
      proxyName: json['proxy-name'] as String,
    );

Map<String, dynamic> _$ChangeProxyParamsToJson(_ChangeProxyParams instance) =>
    <String, dynamic>{
      'group-name': instance.groupName,
      'proxy-name': instance.proxyName,
    };

_UpdateGeoDataParams _$UpdateGeoDataParamsFromJson(Map<String, dynamic> json) =>
    _UpdateGeoDataParams(
      geoType: json['geo-type'] as String,
      geoName: json['geo-name'] as String,
    );

Map<String, dynamic> _$UpdateGeoDataParamsToJson(
  _UpdateGeoDataParams instance,
) => <String, dynamic>{
  'geo-type': instance.geoType,
  'geo-name': instance.geoName,
};

_AppMessage _$AppMessageFromJson(Map<String, dynamic> json) => _AppMessage(
  type: $enumDecode(_$AppMessageTypeEnumMap, json['type']),
  data: json['data'],
);

Map<String, dynamic> _$AppMessageToJson(_AppMessage instance) =>
    <String, dynamic>{
      'type': _$AppMessageTypeEnumMap[instance.type]!,
      'data': instance.data,
    };

const _$AppMessageTypeEnumMap = {
  AppMessageType.log: 'log',
  AppMessageType.delay: 'delay',
  AppMessageType.request: 'request',
  AppMessageType.loaded: 'loaded',
};

_InvokeMessage _$InvokeMessageFromJson(Map<String, dynamic> json) =>
    _InvokeMessage(
      type: $enumDecode(_$InvokeMessageTypeEnumMap, json['type']),
      data: json['data'],
    );

Map<String, dynamic> _$InvokeMessageToJson(_InvokeMessage instance) =>
    <String, dynamic>{
      'type': _$InvokeMessageTypeEnumMap[instance.type]!,
      'data': instance.data,
    };

const _$InvokeMessageTypeEnumMap = {
  InvokeMessageType.protect: 'protect',
  InvokeMessageType.process: 'process',
};

_Delay _$DelayFromJson(Map<String, dynamic> json) => _Delay(
  name: json['name'] as String,
  url: json['url'] as String,
  value: (json['value'] as num?)?.toInt(),
);

Map<String, dynamic> _$DelayToJson(_Delay instance) => <String, dynamic>{
  'name': instance.name,
  'url': instance.url,
  'value': instance.value,
};

_Now _$NowFromJson(Map<String, dynamic> json) =>
    _Now(name: json['name'] as String, value: json['value'] as String);

Map<String, dynamic> _$NowToJson(_Now instance) => <String, dynamic>{
  'name': instance.name,
  'value': instance.value,
};

_ProviderSubscriptionInfo _$ProviderSubscriptionInfoFromJson(
  Map<String, dynamic> json,
) => _ProviderSubscriptionInfo(
  upload: (json['UPLOAD'] as num?)?.toInt() ?? 0,
  download: (json['DOWNLOAD'] as num?)?.toInt() ?? 0,
  total: (json['TOTAL'] as num?)?.toInt() ?? 0,
  expire: (json['EXPIRE'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ProviderSubscriptionInfoToJson(
  _ProviderSubscriptionInfo instance,
) => <String, dynamic>{
  'UPLOAD': instance.upload,
  'DOWNLOAD': instance.download,
  'TOTAL': instance.total,
  'EXPIRE': instance.expire,
};

_ExternalProvider _$ExternalProviderFromJson(Map<String, dynamic> json) =>
    _ExternalProvider(
      name: json['name'] as String,
      type: json['type'] as String,
      path: json['path'] as String?,
      count: (json['count'] as num).toInt(),
      subscriptionInfo: subscriptionInfoFormCore(
        json['subscription-info'] as Map<String, Object?>?,
      ),
      isUpdating: json['isUpdating'] as bool? ?? false,
      vehicleType: json['vehicle-type'] as String,
      updateAt: DateTime.parse(json['update-at'] as String),
    );

Map<String, dynamic> _$ExternalProviderToJson(_ExternalProvider instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'path': instance.path,
      'count': instance.count,
      'subscription-info': instance.subscriptionInfo,
      'isUpdating': instance.isUpdating,
      'vehicle-type': instance.vehicleType,
      'update-at': instance.updateAt.toIso8601String(),
    };

_Action _$ActionFromJson(Map<String, dynamic> json) => _Action(
  method: $enumDecode(_$ActionMethodEnumMap, json['method']),
  data: json['data'],
  id: json['id'] as String,
);

Map<String, dynamic> _$ActionToJson(_Action instance) => <String, dynamic>{
  'method': _$ActionMethodEnumMap[instance.method]!,
  'data': instance.data,
  'id': instance.id,
};

const _$ActionMethodEnumMap = {
  ActionMethod.message: 'message',
  ActionMethod.initClash: 'initClash',
  ActionMethod.getIsInit: 'getIsInit',
  ActionMethod.forceGc: 'forceGc',
  ActionMethod.shutdown: 'shutdown',
  ActionMethod.validateConfig: 'validateConfig',
  ActionMethod.updateConfig: 'updateConfig',
  ActionMethod.getConfig: 'getConfig',
  ActionMethod.getProxies: 'getProxies',
  ActionMethod.changeProxy: 'changeProxy',
  ActionMethod.getTraffic: 'getTraffic',
  ActionMethod.getTotalTraffic: 'getTotalTraffic',
  ActionMethod.resetTraffic: 'resetTraffic',
  ActionMethod.asyncTestDelay: 'asyncTestDelay',
  ActionMethod.getConnections: 'getConnections',
  ActionMethod.closeConnections: 'closeConnections',
  ActionMethod.resetConnections: 'resetConnections',
  ActionMethod.closeConnection: 'closeConnection',
  ActionMethod.getExternalProviders: 'getExternalProviders',
  ActionMethod.getExternalProvider: 'getExternalProvider',
  ActionMethod.updateGeoData: 'updateGeoData',
  ActionMethod.updateExternalProvider: 'updateExternalProvider',
  ActionMethod.sideLoadExternalProvider: 'sideLoadExternalProvider',
  ActionMethod.startLog: 'startLog',
  ActionMethod.stopLog: 'stopLog',
  ActionMethod.startListener: 'startListener',
  ActionMethod.stopListener: 'stopListener',
  ActionMethod.getCountryCode: 'getCountryCode',
  ActionMethod.getMemory: 'getMemory',
  ActionMethod.crash: 'crash',
  ActionMethod.setupConfig: 'setupConfig',
  ActionMethod.flushFakeIP: 'flushFakeIP',
  ActionMethod.flushDnsCache: 'flushDnsCache',
  ActionMethod.generateAgeKeyPair: 'generateAgeKeyPair',
  ActionMethod.convertAgeSecretKeyToPublicKey: 'convertAgeSecretKeyToPublicKey',
  ActionMethod.setState: 'setState',
  ActionMethod.startTun: 'startTun',
  ActionMethod.stopTun: 'stopTun',
  ActionMethod.getRunTime: 'getRunTime',
  ActionMethod.updateDns: 'updateDns',
  ActionMethod.getAndroidVpnOptions: 'getAndroidVpnOptions',
  ActionMethod.getCurrentProfileName: 'getCurrentProfileName',
};

_ActionResult _$ActionResultFromJson(Map<String, dynamic> json) =>
    _ActionResult(
      method: $enumDecode(_$ActionMethodEnumMap, json['method']),
      data: json['data'],
      id: json['id'] as String?,
      code:
          $enumDecodeNullable(_$ResultTypeEnumMap, json['code']) ??
          ResultType.success,
    );

Map<String, dynamic> _$ActionResultToJson(_ActionResult instance) =>
    <String, dynamic>{
      'method': _$ActionMethodEnumMap[instance.method]!,
      'data': instance.data,
      'id': instance.id,
      'code': _$ResultTypeEnumMap[instance.code]!,
    };

const _$ResultTypeEnumMap = {ResultType.success: 0, ResultType.error: -1};
