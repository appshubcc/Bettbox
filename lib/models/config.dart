// ignore_for_file: invalid_annotation_target

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'models.dart';

part 'generated/config.freezed.dart';
part 'generated/config.g.dart';

const defaultBypassDomain = [
  '*jd.com',
  '*zhihu.com',
  '*zhimg.com',
  '*360buyimg.com',
  'localhost',
  '*.local',
  '127.*',
  '10.*',
  '172.16.*',
  '172.17.*',
  '172.18.*',
  '172.19.*',
  '172.2*',
  '172.30.*',
  '172.31.*',
  '192.168.*',
];

const defaultAppSettingProps = AppSettingProps();
const defaultVpnProps = VpnProps();
const defaultNetworkProps = NetworkProps();
const defaultProxiesStyle = ProxiesStyle();
const defaultWindowProps = WindowProps();
const defaultAccessControl = AccessControl();
final defaultThemeProps = ThemeProps(primaryColor: defaultPrimaryColor);

const List<DashboardWidget> defaultDashboardWidgets = [
  DashboardWidget.networkSpeed,
  DashboardWidget.systemProxyButton,
  DashboardWidget.tunButton,
  DashboardWidget.outboundMode,
  DashboardWidget.networkDetection,
  DashboardWidget.trafficUsage,
  DashboardWidget.intranetIp,
  DashboardWidget.memoryInfo,
  DashboardWidget.startButton,
];

List<DashboardWidget> dashboardWidgetsSafeFormJson(
  List<dynamic>? dashboardWidgets,
) {
  try {
    return dashboardWidgets
            ?.map((e) => $enumDecode(_$DashboardWidgetEnumMap, e))
            .toList() ??
        defaultDashboardWidgets;
  } catch (_) {
    return defaultDashboardWidgets;
  }
}

@freezed
abstract class AppSettingProps with _$AppSettingProps {
  const factory AppSettingProps({
    String? locale,
    @Default(defaultDashboardWidgets)
    @JsonKey(fromJson: dashboardWidgetsSafeFormJson)
    List<DashboardWidget> dashboardWidgets,
    @Default(false) bool onlyStatisticsProxy,
    @Default(false) bool autoLaunch,
    @Default(false) bool silentLaunch,
    @Default(true) bool smartDelayLaunch,
    @Default(false) bool autoRun,
    @Default(true) bool openLogs,
    @Default(true) bool closeConnections,
    @Default(defaultTestUrl) String testUrl,
    @Default(true) bool isAnimateToPage,
    @Default(false) bool enableNavBarHapticFeedback,
    @Default(true) bool autoCheckUpdate,
    @Default(false) bool showLabel,
    @Default(false) bool disclaimerAccepted,
    @Default(true) bool minimizeOnExit,
    @Default(false) bool hidden,
    @Default(false) bool developerMode,
    @Default(false) bool enableHighRefreshRate,
    @Default(RecoveryStrategy.compatible) RecoveryStrategy recoveryStrategy,
    @Default(false) bool enableHighPriority,
  }) = _AppSettingProps;

  factory AppSettingProps.fromJson(Map<String, Object?> json) =>
      _$AppSettingPropsFromJson(json);

  factory AppSettingProps.safeFromJson(Map<String, Object?>? json) {
    final props = json == null
        ? defaultAppSettingProps
        : AppSettingProps.fromJson(json);

    return props.copyWith(
      minimizeOnExit: true,
      openLogs: true,
    );
  }
}

@freezed
abstract class AccessControl with _$AccessControl {
  const factory AccessControl({
    @Default(false) bool enable,
    @Default(AccessControlMode.rejectSelected) AccessControlMode mode,
    @Default([]) List<String> acceptList,
    @Default([]) List<String> rejectList,
    @Default(AccessSortType.none) AccessSortType sort,
    @Default(true) bool isFilterSystemApp,
    @Default(true) bool isFilterNonInternetApp,
  }) = _AccessControl;

  factory AccessControl.fromJson(Map<String, Object?> json) =>
      _$AccessControlFromJson(json);
}

extension AccessControlExt on AccessControl {
  List<String> get currentList => switch (mode) {
    AccessControlMode.acceptSelected => acceptList,
    AccessControlMode.rejectSelected => rejectList,
  };
}

@freezed
abstract class WindowProps with _$WindowProps {
  const factory WindowProps({
    @Default(750) double width,
    @Default(600) double height,
    double? top,
    double? left,
  }) = _WindowProps;

  factory WindowProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const WindowProps() : _$WindowPropsFromJson(json);
}

@freezed
abstract class VpnProps with _$VpnProps {
  const factory VpnProps({
    @Default(true) bool enable,
    @Default(false) bool systemProxy,
    @Default(false) bool allowBypass,
    @Default(true) bool bypassPrivateRoute,
    @Default(true) bool dozeSuspend,
    @Default(false) bool smartAutoStop,
    @Default('') String smartAutoStopNetworks,
    @Default(false) bool storeFix,
    @Default(false) bool networkFix,
    @Default(false) bool disableQuic,
    @Default(false) bool networkSpeedNotification,
    @Default(false) bool excludeChina,
    @Default(true) bool trayEnhancement,
    @Default(false) bool alwaysShowTitleBar,
    @Default(true) bool quickResponse,
    @Default(defaultAccessControl) AccessControl accessControl,
  }) = _VpnProps;

  factory VpnProps.fromJson(Map<String, Object?> json) =>
      _$VpnPropsFromJson(json);

  factory VpnProps.safeFromJson(Map<String, Object?>? json) {
    final props = json == null ? defaultVpnProps : VpnProps.fromJson(json);
    var safeProps = props;

    if (system.isAndroid) {
      safeProps = safeProps.copyWith(systemProxy: false);
    }

    if (safeProps.smartAutoStop && safeProps.quickResponse) {
      safeProps = safeProps.copyWith(quickResponse: false);
    }

    return safeProps;
  }
}

@freezed
abstract class NetworkProps with _$NetworkProps {
  const factory NetworkProps({
    @Default(false) bool systemProxy,
    @Default(defaultBypassDomain) List<String> bypassDomain,
    @Default(true) bool bypassPrivateRoute,
    @Default(true) bool autoSetSystemDns,
  }) = _NetworkProps;

  factory NetworkProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const NetworkProps() : _$NetworkPropsFromJson(json);
}

@freezed
abstract class ProxiesStyle with _$ProxiesStyle {
  const factory ProxiesStyle({
    @Default(ProxiesType.tab) ProxiesType type,
    @Default(ProxiesSortType.none) ProxiesSortType sortType,
    @Default(ProxiesLayout.standard) ProxiesLayout layout,
    @Default(ProxiesIconStyle.none) ProxiesIconStyle iconStyle,
    @Default(ProxyCardType.shrink) ProxyCardType cardType,
    @Default(DelayAnimationType.none) DelayAnimationType delayAnimation,
    @Default({}) Map<String, String> iconMap,
    @Default(100) int concurrencyLimit,
  }) = _ProxiesStyle;

  factory ProxiesStyle.fromJson(Map<String, Object?>? json) =>
      json == null ? defaultProxiesStyle : _$ProxiesStyleFromJson(json);
}

@freezed
abstract class TextScale with _$TextScale {
  const factory TextScale({
    @Default(false) bool enable,
    @Default(1.0) double scale,
  }) = _TextScale;

  factory TextScale.fromJson(Map<String, Object?> json) =>
      _$TextScaleFromJson(json);
}

@freezed
abstract class ThemeProps with _$ThemeProps {
  const factory ThemeProps({
    int? primaryColor,
    @Default(defaultPrimaryColors) List<int> primaryColors,
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(DynamicSchemeVariant.content) DynamicSchemeVariant schemeVariant,
    @Default(false) bool pureBlack,
    @Default(TextScale()) TextScale textScale,
    @Default(false) bool useLightIcon,
    @Default(false) bool useHarmonyFont,
  }) = _ThemeProps;

  factory ThemeProps.fromJson(Map<String, Object?> json) =>
      _$ThemePropsFromJson(json);

  factory ThemeProps.safeFromJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultThemeProps;
    }
    try {
      return ThemeProps.fromJson(json);
    } catch (_) {
      return defaultThemeProps;
    }
  }
}

@freezed
abstract class ScriptProps with _$ScriptProps {
  const factory ScriptProps({
    String? currentId,
    @Default([]) List<Script> scripts,
  }) = _ScriptProps;

  factory ScriptProps.fromJson(Map<String, Object?> json) =>
      _$ScriptPropsFromJson(json);
}

extension ScriptPropsExt on ScriptProps {
  String? get realId {
    final index = scripts.indexWhere((script) => script.id == currentId);
    if (index != -1) {
      return currentId;
    }
    return null;
  }

  Script? get currentScript {
    final index = scripts.indexWhere((script) => script.id == currentId);
    if (index != -1) {
      return scripts[index];
    }
    return null;
  }
}

@freezed
abstract class Config with _$Config {
  const factory Config({
    @JsonKey(fromJson: AppSettingProps.safeFromJson)
    @Default(defaultAppSettingProps)
    AppSettingProps appSetting,
    @Default([]) List<Profile> profiles,
    @Default([]) List<HotKeyAction> hotKeyActions,
    String? currentProfileId,
    @Default(false) bool overrideDns,
    @Default(false) bool overrideNtp,
    @Default(false) bool overrideSniffer,
    @Default(false) bool overrideTunnel,
    @Default(false) bool overrideExperimental,
    @Default(true) bool overrideTestUrl,
    DAV? dav,
    @Default(defaultNetworkProps) NetworkProps networkProps,
    @JsonKey(fromJson: VpnProps.safeFromJson)
    @Default(defaultVpnProps)
    VpnProps vpnProps,
    @JsonKey(fromJson: ThemeProps.safeFromJson) required ThemeProps themeProps,
    @Default(defaultProxiesStyle) ProxiesStyle proxiesStyle,
    @Default(defaultWindowProps) WindowProps windowProps,
    @Default(defaultClashConfig) ClashConfig patchClashConfig,
    @Default(ScriptProps()) ScriptProps scriptProps,
    @Default('') String nodeExcludeFilter,
    @Default(5000) int healthCheckTimeout,
  }) = _Config;

  factory Config.fromJson(Map<String, Object?> json) => _$ConfigFromJson(json);

  factory Config.compatibleFromJson(Map<String, Object?> json) {
    try {
      final accessControlMap = json['accessControl'];
      final isAccessControl = json['isAccessControl'];
      if (accessControlMap != null) {
        (accessControlMap as Map)['enable'] = isAccessControl;
        if (json['vpnProps'] != null) {
          (json['vpnProps'] as Map)['accessControl'] = accessControlMap;
        }
      }
    } catch (_) {}

    // 兼容 FlClash：currentProfileId 可能是 int 类型，需要转换为 String
    try {
      final currentProfileId = json['currentProfileId'];
      if (currentProfileId != null && currentProfileId is int) {
        json['currentProfileId'] = currentProfileId.toString();
      }
    } catch (_) {}

    // 兼容 FlClash：profiles 中的 id 可能是 int 类型，需要转换为 String
    try {
      final profiles = json['profiles'];
      if (profiles != null && profiles is List) {
        for (final profile in profiles) {
          if (profile is Map) {
            final id = profile['id'];
            if (id != null && id is int) {
              profile['id'] = id.toString();
            }
          }
        }
      }
    } catch (_) {}

    return Config.fromJson(json);
  }
}

extension ConfigExt on Config {
  Profile? get currentProfile {
    return profiles.getProfile(currentProfileId);
  }
}
