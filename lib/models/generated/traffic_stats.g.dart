// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../traffic_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrafficStatsProps _$TrafficStatsPropsFromJson(Map<String, dynamic> json) =>
    _TrafficStatsProps(
      enable: json['enable'] as bool? ?? false,
      detail: json['detail'] as bool? ?? true,
      retentionDays: (json['retentionDays'] as num?)?.toInt() ?? 7,
      siteIcon: json['siteIcon'] as bool? ?? true,
    );

Map<String, dynamic> _$TrafficStatsPropsToJson(_TrafficStatsProps instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'detail': instance.detail,
      'retentionDays': instance.retentionDays,
      'siteIcon': instance.siteIcon,
    };

_TrafficStatsOptions _$TrafficStatsOptionsFromJson(Map<String, dynamic> json) =>
    _TrafficStatsOptions(
      enable: json['enable'] as bool,
      detail: json['detail'] as bool,
      retentionDays: (json['retention-days'] as num).toInt(),
      tzOffset: (json['tz-offset'] as num).toInt(),
    );

Map<String, dynamic> _$TrafficStatsOptionsToJson(
  _TrafficStatsOptions instance,
) => <String, dynamic>{
  'enable': instance.enable,
  'detail': instance.detail,
  'retention-days': instance.retentionDays,
  'tz-offset': instance.tzOffset,
};

_TrafficStatsItem _$TrafficStatsItemFromJson(Map<String, dynamic> json) =>
    _TrafficStatsItem(
      name: json['name'] as String? ?? '',
      up: (json['up'] as num?)?.toInt() ?? 0,
      down: (json['down'] as num?)?.toInt() ?? 0,
      hits: (json['hits'] as num?)?.toInt() ?? 0,
      path: json['path'] as String? ?? '',
      subs:
          (json['subs'] as List<dynamic>?)
              ?.map((e) => TrafficStatsItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TrafficStatsItemToJson(_TrafficStatsItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'up': instance.up,
      'down': instance.down,
      'hits': instance.hits,
      'path': instance.path,
      'subs': instance.subs,
    };

_TrafficStatsPoint _$TrafficStatsPointFromJson(Map<String, dynamic> json) =>
    _TrafficStatsPoint(
      label: json['label'] as String? ?? '',
      up: (json['up'] as num?)?.toInt() ?? 0,
      down: (json['down'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TrafficStatsPointToJson(_TrafficStatsPoint instance) =>
    <String, dynamic>{
      'label': instance.label,
      'up': instance.up,
      'down': instance.down,
    };

_TrafficStatsResult _$TrafficStatsResultFromJson(Map<String, dynamic> json) =>
    _TrafficStatsResult(
      up: (json['up'] as num?)?.toInt() ?? 0,
      down: (json['down'] as num?)?.toInt() ?? 0,
      proxyUp: (json['proxy-up'] as num?)?.toInt() ?? 0,
      proxyDown: (json['proxy-down'] as num?)?.toInt() ?? 0,
      series:
          (json['series'] as List<dynamic>?)
              ?.map(
                (e) => TrafficStatsPoint.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      hosts:
          (json['hosts'] as List<dynamic>?)
              ?.map((e) => TrafficStatsItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      processes:
          (json['processes'] as List<dynamic>?)
              ?.map((e) => TrafficStatsItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nodes:
          (json['nodes'] as List<dynamic>?)
              ?.map((e) => TrafficStatsItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      profiles:
          (json['profiles'] as List<dynamic>?)
              ?.map((e) => TrafficStatsItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      rules:
          (json['rules'] as List<dynamic>?)
              ?.map((e) => TrafficStatsItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      ruleHits: (json['rule-hits'] as num?)?.toInt() ?? 0,
      since: json['since'] as String? ?? '',
    );

Map<String, dynamic> _$TrafficStatsResultToJson(_TrafficStatsResult instance) =>
    <String, dynamic>{
      'up': instance.up,
      'down': instance.down,
      'proxy-up': instance.proxyUp,
      'proxy-down': instance.proxyDown,
      'series': instance.series,
      'hosts': instance.hosts,
      'processes': instance.processes,
      'nodes': instance.nodes,
      'profiles': instance.profiles,
      'rules': instance.rules,
      'rule-hits': instance.ruleHits,
      'since': instance.since,
    };
