// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NodeBinding _$NodeBindingFromJson(Map<String, dynamic> json) => _NodeBinding(
  front: json['front'] as String?,
  groups:
      (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  all: json['all'] as bool? ?? false,
);

Map<String, dynamic> _$NodeBindingToJson(_NodeBinding instance) =>
    <String, dynamic>{
      'front': instance.front,
      'groups': instance.groups,
      'all': instance.all,
    };

_ProxyNode _$ProxyNodeFromJson(Map<String, dynamic> json) => _ProxyNode(
  id: json['id'] as String,
  proxy: json['proxy'] as Map<String, dynamic>,
  enable: json['enable'] as bool? ?? true,
  role:
      $enumDecodeNullable(
        _$NodeRoleEnumMap,
        json['role'],
        unknownValue: NodeRole.landing,
      ) ??
      NodeRole.landing,
  managedEnable: json['managedEnable'] as bool? ?? true,
  managed: json['managed'] == null
      ? const NodeBinding(all: true)
      : NodeBinding.fromJson(json['managed'] as Map<String, dynamic>),
  bindings:
      (json['bindings'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, NodeBinding.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  warpId: json['warpId'] as String?,
  warpToken: json['warpToken'] as String?,
);

Map<String, dynamic> _$ProxyNodeToJson(_ProxyNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'proxy': instance.proxy,
      'enable': instance.enable,
      'role': _$NodeRoleEnumMap[instance.role]!,
      'managedEnable': instance.managedEnable,
      'managed': instance.managed,
      'bindings': instance.bindings,
      'warpId': instance.warpId,
      'warpToken': instance.warpToken,
    };

const _$NodeRoleEnumMap = {
  NodeRole.landing: 'landing',
  NodeRole.regular: 'regular',
};
