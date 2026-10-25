// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../home_widget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeWidgetColors _$HomeWidgetColorsFromJson(Map<String, dynamic> json) =>
    _HomeWidgetColors(
      surface: (json['surface'] as num).toInt(),
      tonal: (json['tonal'] as num).toInt(),
      onSurface: (json['onSurface'] as num).toInt(),
      onSurfaceVariant: (json['onSurfaceVariant'] as num).toInt(),
      primary: (json['primary'] as num).toInt(),
      onPrimary: (json['onPrimary'] as num).toInt(),
      active: (json['active'] as num).toInt(),
      onActive: (json['onActive'] as num).toInt(),
    );

Map<String, dynamic> _$HomeWidgetColorsToJson(_HomeWidgetColors instance) =>
    <String, dynamic>{
      'surface': instance.surface,
      'tonal': instance.tonal,
      'onSurface': instance.onSurface,
      'onSurfaceVariant': instance.onSurfaceVariant,
      'primary': instance.primary,
      'onPrimary': instance.onPrimary,
      'active': instance.active,
      'onActive': instance.onActive,
    };

_HomeWidgetSnapshot _$HomeWidgetSnapshotFromJson(Map<String, dynamic> json) =>
    _HomeWidgetSnapshot(
      hasProfile: json['hasProfile'] as bool? ?? false,
      emptyText: json['emptyText'] as String? ?? '',
      name: json['name'] as String? ?? '',
      updated: json['updated'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      expired: json['expired'] as bool? ?? false,
      used: json['used'] as String? ?? '',
      total: json['total'] as String? ?? '',
      usage: json['usage'] as String? ?? '',
      percent: json['percent'] as String? ?? '',
      segments:
          (json['segments'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [0],
      firstLabel: json['firstLabel'] as String? ?? '',
      firstValue: json['firstValue'] as String? ?? '',
      secondLabel: json['secondLabel'] as String? ?? '',
      secondValue: json['secondValue'] as String? ?? '',
      expireShort: json['expireShort'] as String? ?? '',
      nodeLabel: json['nodeLabel'] as String? ?? '',
      node: json['node'] as String? ?? '',
      delay: json['delay'] as String? ?? '',
      delayColor: (json['delayColor'] as num?)?.toInt() ?? 0,
      canRefresh: json['canRefresh'] as bool? ?? false,
      refreshing: json['refreshing'] as bool? ?? false,
      onLabel: json['onLabel'] as String? ?? '',
      offLabel: json['offLabel'] as String? ?? '',
      light: HomeWidgetColors.fromJson(json['light'] as Map<String, dynamic>),
      dark: HomeWidgetColors.fromJson(json['dark'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HomeWidgetSnapshotToJson(_HomeWidgetSnapshot instance) =>
    <String, dynamic>{
      'hasProfile': instance.hasProfile,
      'emptyText': instance.emptyText,
      'name': instance.name,
      'updated': instance.updated,
      'subtitle': instance.subtitle,
      'expired': instance.expired,
      'used': instance.used,
      'total': instance.total,
      'usage': instance.usage,
      'percent': instance.percent,
      'segments': instance.segments,
      'firstLabel': instance.firstLabel,
      'firstValue': instance.firstValue,
      'secondLabel': instance.secondLabel,
      'secondValue': instance.secondValue,
      'expireShort': instance.expireShort,
      'nodeLabel': instance.nodeLabel,
      'node': instance.node,
      'delay': instance.delay,
      'delayColor': instance.delayColor,
      'canRefresh': instance.canRefresh,
      'refreshing': instance.refreshing,
      'onLabel': instance.onLabel,
      'offLabel': instance.offLabel,
      'light': instance.light,
      'dark': instance.dark,
    };
