// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/traffic_stats.freezed.dart';
part 'generated/traffic_stats.g.dart';

const defaultTrafficStatsProps = TrafficStatsProps();

const trafficStatsRetentionOptions = [7, 14, 30];

@freezed
abstract class TrafficStatsProps with _$TrafficStatsProps {
  const factory TrafficStatsProps({
    @Default(false) bool enable,
    @Default(true) bool detail,
    @Default(7) int retentionDays,
    @Default(true) bool siteIcon,
  }) = _TrafficStatsProps;

  factory TrafficStatsProps.fromJson(Map<String, Object?> json) =>
      _$TrafficStatsPropsFromJson(json);
}

@freezed
abstract class TrafficStatsOptions with _$TrafficStatsOptions {
  const factory TrafficStatsOptions({
    required bool enable,
    required bool detail,
    @JsonKey(name: 'retention-days') required int retentionDays,
    @JsonKey(name: 'tz-offset') required int tzOffset,
  }) = _TrafficStatsOptions;

  factory TrafficStatsOptions.fromProps(TrafficStatsProps props) =>
      TrafficStatsOptions(
        enable: props.enable,
        detail: props.detail,
        retentionDays: props.retentionDays,
        tzOffset: DateTime.now().timeZoneOffset.inMinutes,
      );

  factory TrafficStatsOptions.fromJson(Map<String, Object?> json) =>
      _$TrafficStatsOptionsFromJson(json);
}

@freezed
abstract class TrafficStatsItem with _$TrafficStatsItem {
  const factory TrafficStatsItem({
    @Default('') String name,
    @Default(0) int up,
    @Default(0) int down,
    @Default(0) int hits,
    @Default('') String path,
    @Default([]) List<TrafficStatsItem> subs,
  }) = _TrafficStatsItem;

  factory TrafficStatsItem.fromJson(Map<String, Object?> json) =>
      _$TrafficStatsItemFromJson(json);
}

@freezed
abstract class TrafficStatsPoint with _$TrafficStatsPoint {
  const factory TrafficStatsPoint({
    @Default('') String label,
    @Default(0) int up,
    @Default(0) int down,
  }) = _TrafficStatsPoint;

  factory TrafficStatsPoint.fromJson(Map<String, Object?> json) =>
      _$TrafficStatsPointFromJson(json);
}

@freezed
abstract class TrafficStatsResult with _$TrafficStatsResult {
  const factory TrafficStatsResult({
    @Default(0) int up,
    @Default(0) int down,
    @JsonKey(name: 'proxy-up') @Default(0) int proxyUp,
    @JsonKey(name: 'proxy-down') @Default(0) int proxyDown,
    @Default([]) List<TrafficStatsPoint> series,
    @Default([]) List<TrafficStatsItem> hosts,
    @Default([]) List<TrafficStatsItem> processes,
    @Default([]) List<TrafficStatsItem> nodes,
    @Default([]) List<TrafficStatsItem> profiles,
    @Default([]) List<TrafficStatsItem> rules,
    @JsonKey(name: 'rule-hits') @Default(0) int ruleHits,
    @Default('') String since,
  }) = _TrafficStatsResult;

  factory TrafficStatsResult.fromJson(Map<String, Object?> json) =>
      _$TrafficStatsResultFromJson(json);
}

extension TrafficStatsItemExt on TrafficStatsItem {
  int get total => up + down;
}

extension TrafficStatsResultExt on TrafficStatsResult {
  int get total => up + down;

  int get proxyTotal => proxyUp + proxyDown;
}
