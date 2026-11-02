// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionInfo _$SubscriptionInfoFromJson(Map<String, dynamic> json) =>
    _SubscriptionInfo(
      upload: (json['upload'] as num?)?.toInt() ?? 0,
      download: (json['download'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      expire: (json['expire'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SubscriptionInfoToJson(_SubscriptionInfo instance) =>
    <String, dynamic>{
      'upload': instance.upload,
      'download': instance.download,
      'total': instance.total,
      'expire': instance.expire,
    };

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  label: json['label'] as String?,
  currentGroupName: json['currentGroupName'] as String?,
  url: json['url'] as String? ?? '',
  lastUpdateDate: json['lastUpdateDate'] == null
      ? null
      : DateTime.parse(json['lastUpdateDate'] as String),
  autoUpdateDuration: Duration(
    microseconds: (json['autoUpdateDuration'] as num).toInt(),
  ),
  subscriptionInfo: json['subscriptionInfo'] == null
      ? null
      : SubscriptionInfo.fromJson(
          json['subscriptionInfo'] as Map<String, dynamic>,
        ),
  providerSubscriptions:
      (json['providerSubscriptions'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, SubscriptionInfo.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  autoUpdate: json['autoUpdate'] as bool? ?? true,
  selectedMap:
      (json['selectedMap'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  unfoldSet:
      (json['unfoldSet'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
      const {},
  overrideData: json['overrideData'] == null
      ? const OverrideData()
      : OverrideData.fromJson(json['overrideData'] as Map<String, dynamic>),
  scriptId: json['scriptId'] as String?,
  managed: json['managed'] as bool? ?? false,
  managedStyleApplied: json['managedStyleApplied'] as bool? ?? false,
  ageSecretKey: json['ageSecretKey'] as String?,
  groupSwitches:
      (json['group-switches'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const {},
  usageStyle:
      $enumDecodeNullable(_$ProfileUsageStyleEnumMap, json['usageStyle']) ??
      ProfileUsageStyle.bar,
  bundle: json['bundle'] == null
      ? null
      : ProfileBundle.fromJson(json['bundle'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'currentGroupName': instance.currentGroupName,
  'url': instance.url,
  'lastUpdateDate': instance.lastUpdateDate?.toIso8601String(),
  'autoUpdateDuration': instance.autoUpdateDuration.inMicroseconds,
  'subscriptionInfo': instance.subscriptionInfo,
  'providerSubscriptions': instance.providerSubscriptions,
  'autoUpdate': instance.autoUpdate,
  'selectedMap': instance.selectedMap,
  'unfoldSet': instance.unfoldSet.toList(),
  'overrideData': instance.overrideData,
  'scriptId': instance.scriptId,
  'managed': instance.managed,
  'managedStyleApplied': instance.managedStyleApplied,
  'ageSecretKey': instance.ageSecretKey,
  'group-switches': instance.groupSwitches,
  'usageStyle': _$ProfileUsageStyleEnumMap[instance.usageStyle]!,
  'bundle': instance.bundle,
};

const _$ProfileUsageStyleEnumMap = {
  ProfileUsageStyle.bar: 'bar',
  ProfileUsageStyle.ring: 'ring',
  ProfileUsageStyle.concentric: 'concentric',
};

_BundleMember _$BundleMemberFromJson(Map<String, dynamic> json) =>
    _BundleMember(id: json['id'] as String, prefix: json['prefix'] as String?);

Map<String, dynamic> _$BundleMemberToJson(_BundleMember instance) =>
    <String, dynamic>{'id': instance.id, 'prefix': instance.prefix};

_BundleReport _$BundleReportFromJson(Map<String, dynamic> json) =>
    _BundleReport(
      proxies: (json['proxies'] as num?)?.toInt() ?? 0,
      duplicates: (json['duplicates'] as num?)?.toInt() ?? 0,
      groups: (json['groups'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BundleReportToJson(_BundleReport instance) =>
    <String, dynamic>{
      'proxies': instance.proxies,
      'duplicates': instance.duplicates,
      'groups': instance.groups,
    };

_ProfileBundle _$ProfileBundleFromJson(Map<String, dynamic> json) =>
    _ProfileBundle(
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => BundleMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      report: json['report'] == null
          ? const BundleReport()
          : BundleReport.fromJson(json['report'] as Map<String, dynamic>),
      failures:
          (json['failures'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      collapsed: json['collapsed'] as bool? ?? false,
    );

Map<String, dynamic> _$ProfileBundleToJson(_ProfileBundle instance) =>
    <String, dynamic>{
      'members': instance.members,
      'report': instance.report,
      'failures': instance.failures,
      'collapsed': instance.collapsed,
    };

_OverrideData _$OverrideDataFromJson(Map<String, dynamic> json) =>
    _OverrideData(
      enable: json['enable'] as bool? ?? false,
      rule: json['rule'] == null
          ? const OverrideRule()
          : OverrideRule.fromJson(json['rule'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OverrideDataToJson(_OverrideData instance) =>
    <String, dynamic>{'enable': instance.enable, 'rule': instance.rule};

_OverrideRule _$OverrideRuleFromJson(Map<String, dynamic> json) =>
    _OverrideRule(
      type:
          $enumDecodeNullable(_$OverrideRuleTypeEnumMap, json['type']) ??
          OverrideRuleType.added,
      overrideRules:
          (json['overrideRules'] as List<dynamic>?)
              ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      addedRules:
          (json['addedRules'] as List<dynamic>?)
              ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$OverrideRuleToJson(_OverrideRule instance) =>
    <String, dynamic>{
      'type': _$OverrideRuleTypeEnumMap[instance.type]!,
      'overrideRules': instance.overrideRules,
      'addedRules': instance.addedRules,
    };

const _$OverrideRuleTypeEnumMap = {
  OverrideRuleType.override: 'override',
  OverrideRuleType.added: 'added',
};
