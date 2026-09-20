// ignore_for_file: invalid_annotation_target

import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/core.freezed.dart';
part 'generated/core.g.dart';

abstract mixin class AppMessageListener {
  void onLog(Log log) {}

  void onDelay(Delay delay) {}

  void onRequest(TrackerInfo connection) {}

  void onLoaded(String providerName) {}
}

// abstract mixin class ServiceMessageListener {
//   onProtect(Fd fd) {}
//
//   onProcess(ProcessData process) {}
// }

@freezed
abstract class SetupParams with _$SetupParams {
  const factory SetupParams({
    @JsonKey(name: 'selected-map') required Map<String, String> selectedMap,
    @JsonKey(name: 'test-url') required String testUrl,
    @JsonKey(name: 'override-test-url') @Default(true) bool overrideTestUrl,
  }) = _SetupParams;

  factory SetupParams.fromJson(Map<String, dynamic> json) =>
      _$SetupParamsFromJson(json);
}

@freezed
abstract class UpdateParams with _$UpdateParams {
  const factory UpdateParams({
    required Tun tun,
    @JsonKey(name: 'mixed-port') required int mixedPort,
    @JsonKey(name: 'allow-lan') required bool allowLan,
    @JsonKey(name: 'find-process-mode')
    required FindProcessMode findProcessMode,
    required Mode mode,
    @JsonKey(name: 'log-level') required LogLevel logLevel,
    required bool ipv6,
    @JsonKey(name: 'tcp-concurrent') required bool tcpConcurrent,
    @JsonKey(name: 'external-controller')
    required ExternalControllerStatus externalController,
    @JsonKey(name: 'unified-delay') required bool unifiedDelay,
  }) = _UpdateParams;

  factory UpdateParams.fromJson(Map<String, dynamic> json) =>
      _$UpdateParamsFromJson(json);
}

@freezed
abstract class CoreState with _$CoreState {
  const factory CoreState({
    @JsonKey(name: 'vpn-props') required VpnProps vpnProps,
    @JsonKey(name: 'only-statistics-proxy') required bool onlyStatisticsProxy,
    @JsonKey(name: 'current-profile-name') required String currentProfileName,
    @JsonKey(name: 'bypass-domain') @Default([]) List<String> bypassDomain,
  }) = _CoreState;

  factory CoreState.fromJson(Map<String, Object?> json) =>
      _$CoreStateFromJson(json);
}

@freezed
abstract class AndroidVpnOptions with _$AndroidVpnOptions {
  const factory AndroidVpnOptions({
    required bool enable,
    required int port,
    required AccessControl? accessControl,
    required bool allowBypass,
    required bool systemProxy,
    required List<String> bypassDomain,
    required String ipv4Address,
    required String ipv6Address,
    @Default([]) List<String> routeAddress,
    @Default('config') String routeMode,
    required String dnsServerAddress,
    @Default(false) bool dozeSuspend,
    @Default(9000) int mtu,
  }) = _AndroidVpnOptions;

  factory AndroidVpnOptions.fromJson(Map<String, Object?> json) =>
      _$AndroidVpnOptionsFromJson(json);
}

@freezed
abstract class InitParams with _$InitParams {
  const factory InitParams({
    @JsonKey(name: 'home-dir') required String homeDir,
    required int version,
  }) = _InitParams;

  factory InitParams.fromJson(Map<String, Object?> json) =>
      _$InitParamsFromJson(json);
}

@freezed
abstract class ChangeProxyParams with _$ChangeProxyParams {
  const factory ChangeProxyParams({
    @JsonKey(name: 'group-name') required String groupName,
    @JsonKey(name: 'proxy-name') required String proxyName,
  }) = _ChangeProxyParams;

  factory ChangeProxyParams.fromJson(Map<String, Object?> json) =>
      _$ChangeProxyParamsFromJson(json);
}

@freezed
abstract class UpdateGeoDataParams with _$UpdateGeoDataParams {
  const factory UpdateGeoDataParams({
    @JsonKey(name: 'geo-type') required String geoType,
    @JsonKey(name: 'geo-name') required String geoName,
  }) = _UpdateGeoDataParams;

  factory UpdateGeoDataParams.fromJson(Map<String, Object?> json) =>
      _$UpdateGeoDataParamsFromJson(json);
}

@freezed
abstract class AppMessage with _$AppMessage {
  const factory AppMessage({required AppMessageType type, dynamic data}) =
      _AppMessage;

  factory AppMessage.fromJson(Map<String, Object?> json) =>
      _$AppMessageFromJson(json);
}

@freezed
abstract class InvokeMessage with _$InvokeMessage {
  const factory InvokeMessage({required InvokeMessageType type, dynamic data}) =
      _InvokeMessage;

  factory InvokeMessage.fromJson(Map<String, Object?> json) =>
      _$InvokeMessageFromJson(json);
}

@freezed
abstract class Delay with _$Delay {
  const factory Delay({required String name, required String url, int? value}) =
      _Delay;

  factory Delay.fromJson(Map<String, Object?> json) => _$DelayFromJson(json);
}

@freezed
abstract class Now with _$Now {
  const factory Now({required String name, required String value}) = _Now;

  factory Now.fromJson(Map<String, Object?> json) => _$NowFromJson(json);
}

// @freezed
// class ProcessData with _$ProcessData {
//   const factory ProcessData({
//     required String id,
//     required Metadata metadata,
//   }) = _ProcessData;
//
//   factory ProcessData.fromJson(Map<String, Object?> json) =>
//       _$ProcessDataFromJson(json);
// }
//
// @freezed
// class Fd with _$Fd {
//   const factory Fd({
//     required String id,
//     required int value,
//   }) = _Fd;
//
//   factory Fd.fromJson(Map<String, Object?> json) => _$FdFromJson(json);
// }

@freezed
abstract class ProviderSubscriptionInfo with _$ProviderSubscriptionInfo {
  const factory ProviderSubscriptionInfo({
    @JsonKey(name: 'UPLOAD') @Default(0) int upload,
    @JsonKey(name: 'DOWNLOAD') @Default(0) int download,
    @JsonKey(name: 'TOTAL') @Default(0) int total,
    @JsonKey(name: 'EXPIRE') @Default(0) int expire,
  }) = _ProviderSubscriptionInfo;

  factory ProviderSubscriptionInfo.fromJson(Map<String, Object?> json) =>
      _$ProviderSubscriptionInfoFromJson(json);
}

SubscriptionInfo? subscriptionInfoFormCore(Map<String, Object?>? json) {
  if (json == null) return null;
  return SubscriptionInfo(
    upload: (json['Upload'] as num?)?.toInt() ?? 0,
    download: (json['Download'] as num?)?.toInt() ?? 0,
    total: (json['Total'] as num?)?.toInt() ?? 0,
    expire: (json['Expire'] as num?)?.toInt() ?? 0,
  );
}

@freezed
abstract class ExternalProvider with _$ExternalProvider {
  const factory ExternalProvider({
    required String name,
    required String type,
    String? path,
    required int count,
    @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)
    SubscriptionInfo? subscriptionInfo,
    @Default(false) bool isUpdating,
    @JsonKey(name: 'vehicle-type') required String vehicleType,
    @JsonKey(name: 'update-at') required DateTime updateAt,
    List<dynamic>? proxies,
  }) = _ExternalProvider;

  factory ExternalProvider.fromJson(Map<String, Object?> json) =>
      _$ExternalProviderFromJson(json);
}

@freezed
abstract class Action with _$Action {
  const factory Action({
    required ActionMethod method,
    required dynamic data,
    required String id,
  }) = _Action;

  factory Action.fromJson(Map<String, Object?> json) => _$ActionFromJson(json);
}

@freezed
abstract class ActionResult with _$ActionResult {
  const factory ActionResult({
    required ActionMethod method,
    required dynamic data,
    String? id,
    @Default(ResultType.success) ResultType code,
  }) = _ActionResult;

  factory ActionResult.fromJson(Map<String, Object?> json) =>
      _$ActionResultFromJson(json);
}

extension ActionResultExt on ActionResult {
  Result get toResult {
    if (code == ResultType.success) {
      return Result.success(data);
    } else {
      return Result.error(data);
    }
  }
}

@freezed
abstract class CoreStatus with _$CoreStatus {
  const factory CoreStatus({
    @Default(0) int physical,
    @JsonKey(name: 'in-use') @Default(0) int inUse,
    @Default(0) int reclaimable,
    @Default(0) int goroutines,
    @JsonKey(name: 'heap-objects') @Default(0) int heapObjects,
    @JsonKey(name: 'last-gc') @Default(0) int lastGC,
    @Default(0) int rules,
    @Default(0) int proxies,
    @JsonKey(name: 'proxy-groups') @Default(0) int proxyGroups,
    @JsonKey(name: 'rule-providers') @Default(0) int ruleProviders,
    @JsonKey(name: 'proxy-providers') @Default(0) int proxyProviders,
    @JsonKey(name: 'geodata-use') @Default('None') String geodataUse,
  }) = _CoreStatus;

  factory CoreStatus.fromJson(Map<String, Object?> json) =>
      _$CoreStatusFromJson(json);
}
