// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettingProps _$AppSettingPropsFromJson(Map<String, dynamic> json) =>
    _AppSettingProps(
      locale: json['locale'] as String?,
      dashboardWidgets: json['dashboardWidgets'] == null
          ? defaultDashboardWidgets
          : dashboardWidgetsSafeFormJson(json['dashboardWidgets'] as List?),
      onlyStatisticsProxy: json['onlyStatisticsProxy'] as bool? ?? false,
      autoLaunch: json['autoLaunch'] as bool? ?? false,
      silentLaunch: json['silentLaunch'] as bool? ?? false,
      smartDelayLaunch: json['smartDelayLaunch'] as bool? ?? true,
      autoRun: json['autoRun'] as bool? ?? false,
      openLogs: json['openLogs'] as bool? ?? true,
      closeConnections: json['closeConnections'] as bool? ?? true,
      testUrl: json['testUrl'] as String? ?? defaultTestUrl,
      isAnimateToPage: json['isAnimateToPage'] as bool? ?? true,
      enableNavBarHapticFeedback:
          json['enableNavBarHapticFeedback'] as bool? ?? false,
      autoCheckUpdate: json['autoCheckUpdate'] as bool? ?? true,
      showLabel: json['showLabel'] as bool? ?? false,
      disclaimerAccepted: json['disclaimerAccepted'] as bool? ?? false,
      minimizeOnExit: json['minimizeOnExit'] as bool? ?? true,
      hidden: json['hidden'] as bool? ?? false,
      developerMode: json['developerMode'] as bool? ?? false,
      enableHighRefreshRate: json['enableHighRefreshRate'] as bool? ?? false,
      recoveryStrategy:
          $enumDecodeNullable(
            _$RecoveryStrategyEnumMap,
            json['recoveryStrategy'],
          ) ??
          RecoveryStrategy.compatible,
      enableHighPriority: json['enableHighPriority'] as bool? ?? false,
    );

Map<String, dynamic> _$AppSettingPropsToJson(_AppSettingProps instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'dashboardWidgets': instance.dashboardWidgets
          .map((e) => _$DashboardWidgetEnumMap[e]!)
          .toList(),
      'onlyStatisticsProxy': instance.onlyStatisticsProxy,
      'autoLaunch': instance.autoLaunch,
      'silentLaunch': instance.silentLaunch,
      'smartDelayLaunch': instance.smartDelayLaunch,
      'autoRun': instance.autoRun,
      'openLogs': instance.openLogs,
      'closeConnections': instance.closeConnections,
      'testUrl': instance.testUrl,
      'isAnimateToPage': instance.isAnimateToPage,
      'enableNavBarHapticFeedback': instance.enableNavBarHapticFeedback,
      'autoCheckUpdate': instance.autoCheckUpdate,
      'showLabel': instance.showLabel,
      'disclaimerAccepted': instance.disclaimerAccepted,
      'minimizeOnExit': instance.minimizeOnExit,
      'hidden': instance.hidden,
      'developerMode': instance.developerMode,
      'enableHighRefreshRate': instance.enableHighRefreshRate,
      'recoveryStrategy': _$RecoveryStrategyEnumMap[instance.recoveryStrategy]!,
      'enableHighPriority': instance.enableHighPriority,
    };

const _$RecoveryStrategyEnumMap = {
  RecoveryStrategy.compatible: 'compatible',
  RecoveryStrategy.override: 'override',
};

const _$DashboardWidgetEnumMap = {
  DashboardWidget.networkSpeed: 'networkSpeed',
  DashboardWidget.networkSpeedSmall: 'networkSpeedSmall',
  DashboardWidget.outboundModeV2: 'outboundModeV2',
  DashboardWidget.outboundMode: 'outboundMode',
  DashboardWidget.trafficUsage: 'trafficUsage',
  DashboardWidget.networkDetection: 'networkDetection',
  DashboardWidget.tunButton: 'tunButton',
  DashboardWidget.vpnButton: 'vpnButton',
  DashboardWidget.systemProxyButton: 'systemProxyButton',
  DashboardWidget.intranetIp: 'intranetIp',
  DashboardWidget.memoryInfo: 'memoryInfo',
  DashboardWidget.connectionsCount: 'connectionsCount',
  DashboardWidget.ipv6Switch: 'ipv6Switch',
  DashboardWidget.wakelockSwitch: 'wakelockSwitch',
  DashboardWidget.dnsOverride: 'dnsOverride',
  DashboardWidget.snifferOverride: 'snifferOverride',
  DashboardWidget.ntpOverride: 'ntpOverride',
  DashboardWidget.providersInfo: 'providersInfo',
  DashboardWidget.fcmStatus: 'fcmStatus',
  DashboardWidget.onlinePanel: 'onlinePanel',
  DashboardWidget.startButton: 'startButton',
};

_AccessControl _$AccessControlFromJson(Map<String, dynamic> json) =>
    _AccessControl(
      enable: json['enable'] as bool? ?? false,
      mode:
          $enumDecodeNullable(_$AccessControlModeEnumMap, json['mode']) ??
          AccessControlMode.rejectSelected,
      acceptList:
          (json['acceptList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rejectList:
          (json['rejectList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sort:
          $enumDecodeNullable(_$AccessSortTypeEnumMap, json['sort']) ??
          AccessSortType.none,
      isFilterSystemApp: json['isFilterSystemApp'] as bool? ?? true,
      isFilterNonInternetApp: json['isFilterNonInternetApp'] as bool? ?? true,
    );

Map<String, dynamic> _$AccessControlToJson(_AccessControl instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'mode': _$AccessControlModeEnumMap[instance.mode]!,
      'acceptList': instance.acceptList,
      'rejectList': instance.rejectList,
      'sort': _$AccessSortTypeEnumMap[instance.sort]!,
      'isFilterSystemApp': instance.isFilterSystemApp,
      'isFilterNonInternetApp': instance.isFilterNonInternetApp,
    };

const _$AccessControlModeEnumMap = {
  AccessControlMode.acceptSelected: 'acceptSelected',
  AccessControlMode.rejectSelected: 'rejectSelected',
};

const _$AccessSortTypeEnumMap = {
  AccessSortType.none: 'none',
  AccessSortType.name: 'name',
  AccessSortType.time: 'time',
};

_WindowProps _$WindowPropsFromJson(Map<String, dynamic> json) => _WindowProps(
  width: (json['width'] as num?)?.toDouble() ?? 750,
  height: (json['height'] as num?)?.toDouble() ?? 600,
  top: (json['top'] as num?)?.toDouble(),
  left: (json['left'] as num?)?.toDouble(),
);

Map<String, dynamic> _$WindowPropsToJson(_WindowProps instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'top': instance.top,
      'left': instance.left,
    };

_VpnProps _$VpnPropsFromJson(Map<String, dynamic> json) => _VpnProps(
  enable: json['enable'] as bool? ?? true,
  systemProxy: json['systemProxy'] as bool? ?? false,
  allowBypass: json['allowBypass'] as bool? ?? false,
  bypassPrivateRoute: json['bypassPrivateRoute'] as bool? ?? true,
  dozeSuspend: json['dozeSuspend'] as bool? ?? true,
  smartAutoStop: json['smartAutoStop'] as bool? ?? false,
  smartAutoStopNetworks: json['smartAutoStopNetworks'] as String? ?? '',
  storeFix: json['storeFix'] as bool? ?? false,
  networkFix: json['networkFix'] as bool? ?? false,
  disableQuic: json['disableQuic'] as bool? ?? false,
  networkSpeedNotification: json['networkSpeedNotification'] as bool? ?? false,
  excludeChina: json['excludeChina'] as bool? ?? false,
  trayEnhancement: json['trayEnhancement'] as bool? ?? true,
  alwaysShowTitleBar: json['alwaysShowTitleBar'] as bool? ?? false,
  quickResponse: json['quickResponse'] as bool? ?? true,
  accessControl: json['accessControl'] == null
      ? defaultAccessControl
      : AccessControl.fromJson(json['accessControl'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VpnPropsToJson(_VpnProps instance) => <String, dynamic>{
  'enable': instance.enable,
  'systemProxy': instance.systemProxy,
  'allowBypass': instance.allowBypass,
  'bypassPrivateRoute': instance.bypassPrivateRoute,
  'dozeSuspend': instance.dozeSuspend,
  'smartAutoStop': instance.smartAutoStop,
  'smartAutoStopNetworks': instance.smartAutoStopNetworks,
  'storeFix': instance.storeFix,
  'networkFix': instance.networkFix,
  'disableQuic': instance.disableQuic,
  'networkSpeedNotification': instance.networkSpeedNotification,
  'excludeChina': instance.excludeChina,
  'trayEnhancement': instance.trayEnhancement,
  'alwaysShowTitleBar': instance.alwaysShowTitleBar,
  'quickResponse': instance.quickResponse,
  'accessControl': instance.accessControl,
};

_NetworkProps _$NetworkPropsFromJson(Map<String, dynamic> json) =>
    _NetworkProps(
      systemProxy: json['systemProxy'] as bool? ?? false,
      bypassDomain:
          (json['bypassDomain'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          defaultBypassDomain,
      bypassPrivateRoute: json['bypassPrivateRoute'] as bool? ?? true,
      autoSetSystemDns: json['autoSetSystemDns'] as bool? ?? true,
    );

Map<String, dynamic> _$NetworkPropsToJson(_NetworkProps instance) =>
    <String, dynamic>{
      'systemProxy': instance.systemProxy,
      'bypassDomain': instance.bypassDomain,
      'bypassPrivateRoute': instance.bypassPrivateRoute,
      'autoSetSystemDns': instance.autoSetSystemDns,
    };

_ProxiesStyle _$ProxiesStyleFromJson(Map<String, dynamic> json) =>
    _ProxiesStyle(
      type:
          $enumDecodeNullable(_$ProxiesTypeEnumMap, json['type']) ??
          ProxiesType.tab,
      sortType:
          $enumDecodeNullable(_$ProxiesSortTypeEnumMap, json['sortType']) ??
          ProxiesSortType.none,
      layout:
          $enumDecodeNullable(_$ProxiesLayoutEnumMap, json['layout']) ??
          ProxiesLayout.standard,
      iconStyle:
          $enumDecodeNullable(_$ProxiesIconStyleEnumMap, json['iconStyle']) ??
          ProxiesIconStyle.none,
      cardType:
          $enumDecodeNullable(_$ProxyCardTypeEnumMap, json['cardType']) ??
          ProxyCardType.shrink,
      delayAnimation:
          $enumDecodeNullable(
            _$DelayAnimationTypeEnumMap,
            json['delayAnimation'],
          ) ??
          DelayAnimationType.none,
      iconMap:
          (json['iconMap'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      concurrencyLimit: (json['concurrencyLimit'] as num?)?.toInt() ?? 100,
    );

Map<String, dynamic> _$ProxiesStyleToJson(_ProxiesStyle instance) =>
    <String, dynamic>{
      'type': _$ProxiesTypeEnumMap[instance.type]!,
      'sortType': _$ProxiesSortTypeEnumMap[instance.sortType]!,
      'layout': _$ProxiesLayoutEnumMap[instance.layout]!,
      'iconStyle': _$ProxiesIconStyleEnumMap[instance.iconStyle]!,
      'cardType': _$ProxyCardTypeEnumMap[instance.cardType]!,
      'delayAnimation': _$DelayAnimationTypeEnumMap[instance.delayAnimation]!,
      'iconMap': instance.iconMap,
      'concurrencyLimit': instance.concurrencyLimit,
    };

const _$ProxiesTypeEnumMap = {ProxiesType.tab: 'tab', ProxiesType.list: 'list'};

const _$ProxiesSortTypeEnumMap = {
  ProxiesSortType.none: 'none',
  ProxiesSortType.delay: 'delay',
  ProxiesSortType.name: 'name',
};

const _$ProxiesLayoutEnumMap = {
  ProxiesLayout.loose: 'loose',
  ProxiesLayout.standard: 'standard',
  ProxiesLayout.tight: 'tight',
};

const _$ProxiesIconStyleEnumMap = {
  ProxiesIconStyle.standard: 'standard',
  ProxiesIconStyle.none: 'none',
  ProxiesIconStyle.icon: 'icon',
};

const _$ProxyCardTypeEnumMap = {
  ProxyCardType.expand: 'expand',
  ProxyCardType.shrink: 'shrink',
  ProxyCardType.min: 'min',
};

const _$DelayAnimationTypeEnumMap = {
  DelayAnimationType.none: 'none',
  DelayAnimationType.rotatingCircle: 'rotatingCircle',
  DelayAnimationType.pulse: 'pulse',
  DelayAnimationType.spinningLines: 'spinningLines',
  DelayAnimationType.threeInOut: 'threeInOut',
  DelayAnimationType.threeBounce: 'threeBounce',
  DelayAnimationType.circle: 'circle',
  DelayAnimationType.fadingCircle: 'fadingCircle',
  DelayAnimationType.fadingFour: 'fadingFour',
  DelayAnimationType.wave: 'wave',
  DelayAnimationType.doubleBounce: 'doubleBounce',
};

_TextScale _$TextScaleFromJson(Map<String, dynamic> json) => _TextScale(
  enable: json['enable'] as bool? ?? false,
  scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$TextScaleToJson(_TextScale instance) =>
    <String, dynamic>{'enable': instance.enable, 'scale': instance.scale};

_ThemeProps _$ThemePropsFromJson(Map<String, dynamic> json) => _ThemeProps(
  primaryColor: (json['primaryColor'] as num?)?.toInt(),
  primaryColors:
      (json['primaryColors'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      defaultPrimaryColors,
  themeMode:
      $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
      ThemeMode.system,
  schemeVariant:
      $enumDecodeNullable(
        _$DynamicSchemeVariantEnumMap,
        json['schemeVariant'],
      ) ??
      DynamicSchemeVariant.content,
  pureBlack: json['pureBlack'] as bool? ?? false,
  textScale: json['textScale'] == null
      ? const TextScale()
      : TextScale.fromJson(json['textScale'] as Map<String, dynamic>),
  useLightIcon: json['useLightIcon'] as bool? ?? false,
  useHarmonyFont: json['useHarmonyFont'] as bool? ?? false,
);

Map<String, dynamic> _$ThemePropsToJson(_ThemeProps instance) =>
    <String, dynamic>{
      'primaryColor': instance.primaryColor,
      'primaryColors': instance.primaryColors,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'schemeVariant': _$DynamicSchemeVariantEnumMap[instance.schemeVariant]!,
      'pureBlack': instance.pureBlack,
      'textScale': instance.textScale,
      'useLightIcon': instance.useLightIcon,
      'useHarmonyFont': instance.useHarmonyFont,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$DynamicSchemeVariantEnumMap = {
  DynamicSchemeVariant.tonalSpot: 'tonalSpot',
  DynamicSchemeVariant.fidelity: 'fidelity',
  DynamicSchemeVariant.monochrome: 'monochrome',
  DynamicSchemeVariant.neutral: 'neutral',
  DynamicSchemeVariant.vibrant: 'vibrant',
  DynamicSchemeVariant.expressive: 'expressive',
  DynamicSchemeVariant.content: 'content',
  DynamicSchemeVariant.rainbow: 'rainbow',
  DynamicSchemeVariant.fruitSalad: 'fruitSalad',
};

_ScriptProps _$ScriptPropsFromJson(Map<String, dynamic> json) => _ScriptProps(
  currentId: json['currentId'] as String?,
  scripts:
      (json['scripts'] as List<dynamic>?)
          ?.map((e) => Script.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ScriptPropsToJson(_ScriptProps instance) =>
    <String, dynamic>{
      'currentId': instance.currentId,
      'scripts': instance.scripts,
    };

_Config _$ConfigFromJson(Map<String, dynamic> json) => _Config(
  appSetting: json['appSetting'] == null
      ? defaultAppSettingProps
      : AppSettingProps.safeFromJson(
          json['appSetting'] as Map<String, Object?>?,
        ),
  profiles:
      (json['profiles'] as List<dynamic>?)
          ?.map((e) => Profile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  hotKeyActions:
      (json['hotKeyActions'] as List<dynamic>?)
          ?.map((e) => HotKeyAction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  currentProfileId: json['currentProfileId'] as String?,
  overrideDns: json['overrideDns'] as bool? ?? false,
  overrideNtp: json['overrideNtp'] as bool? ?? false,
  overrideSniffer: json['overrideSniffer'] as bool? ?? false,
  overrideTunnel: json['overrideTunnel'] as bool? ?? false,
  overrideExperimental: json['overrideExperimental'] as bool? ?? false,
  overrideTestUrl: json['overrideTestUrl'] as bool? ?? true,
  dav: json['dav'] == null
      ? null
      : DAV.fromJson(json['dav'] as Map<String, dynamic>),
  networkProps: json['networkProps'] == null
      ? defaultNetworkProps
      : NetworkProps.fromJson(json['networkProps'] as Map<String, dynamic>?),
  vpnProps: json['vpnProps'] == null
      ? defaultVpnProps
      : VpnProps.safeFromJson(json['vpnProps'] as Map<String, Object?>?),
  themeProps: ThemeProps.safeFromJson(
    json['themeProps'] as Map<String, Object?>?,
  ),
  proxiesStyle: json['proxiesStyle'] == null
      ? defaultProxiesStyle
      : ProxiesStyle.fromJson(json['proxiesStyle'] as Map<String, dynamic>?),
  windowProps: json['windowProps'] == null
      ? defaultWindowProps
      : WindowProps.fromJson(json['windowProps'] as Map<String, dynamic>?),
  patchClashConfig: json['patchClashConfig'] == null
      ? defaultClashConfig
      : ClashConfig.fromJson(json['patchClashConfig'] as Map<String, dynamic>),
  scriptProps: json['scriptProps'] == null
      ? const ScriptProps()
      : ScriptProps.fromJson(json['scriptProps'] as Map<String, dynamic>),
  nodeExcludeFilter: json['nodeExcludeFilter'] as String? ?? '',
  healthCheckTimeout: (json['healthCheckTimeout'] as num?)?.toInt() ?? 5000,
);

Map<String, dynamic> _$ConfigToJson(_Config instance) => <String, dynamic>{
  'appSetting': instance.appSetting,
  'profiles': instance.profiles,
  'hotKeyActions': instance.hotKeyActions,
  'currentProfileId': instance.currentProfileId,
  'overrideDns': instance.overrideDns,
  'overrideNtp': instance.overrideNtp,
  'overrideSniffer': instance.overrideSniffer,
  'overrideTunnel': instance.overrideTunnel,
  'overrideExperimental': instance.overrideExperimental,
  'overrideTestUrl': instance.overrideTestUrl,
  'dav': instance.dav,
  'networkProps': instance.networkProps,
  'vpnProps': instance.vpnProps,
  'themeProps': instance.themeProps,
  'proxiesStyle': instance.proxiesStyle,
  'windowProps': instance.windowProps,
  'patchClashConfig': instance.patchClashConfig,
  'scriptProps': instance.scriptProps,
  'nodeExcludeFilter': instance.nodeExcludeFilter,
  'healthCheckTimeout': instance.healthCheckTimeout,
};
