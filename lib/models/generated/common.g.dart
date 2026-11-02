// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Package _$PackageFromJson(Map<String, dynamic> json) => _Package(
  packageName: json['packageName'] as String,
  label: json['label'] as String,
  system: json['system'] as bool,
  internet: json['internet'] as bool,
  firstInstallTime: (json['firstInstallTime'] as num?)?.toInt() ?? 0,
  lastUpdateTime: (json['lastUpdateTime'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PackageToJson(_Package instance) => <String, dynamic>{
  'packageName': instance.packageName,
  'label': instance.label,
  'system': instance.system,
  'internet': instance.internet,
  'firstInstallTime': instance.firstInstallTime,
  'lastUpdateTime': instance.lastUpdateTime,
};

_Metadata _$MetadataFromJson(Map<String, dynamic> json) => _Metadata(
  uid: (json['uid'] as num?)?.toInt() ?? 0,
  network: json['network'] as String? ?? '',
  type: json['type'] as String? ?? '',
  sourceIP: json['sourceIP'] as String? ?? '',
  sourcePort: json['sourcePort'] as String? ?? '',
  destinationIP: json['destinationIP'] as String? ?? '',
  destinationPort: json['destinationPort'] as String? ?? '',
  host: json['host'] as String? ?? '',
  sniffHost: json['sniffHost'] as String? ?? '',
  inboundName: json['inboundName'] as String? ?? '',
  inboundPort: json['inboundPort'] as String? ?? '',
  inboundUser: json['inboundUser'] as String? ?? '',
  dnsMode: $enumDecodeNullable(_$DnsModeEnumMap, json['dnsMode']),
  process: json['process'] as String? ?? '',
  processPath: json['processPath'] as String? ?? '',
  remoteDestination: json['remoteDestination'] as String? ?? '',
  sourceGeoIP:
      (json['sourceGeoIP'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  destinationGeoIP:
      (json['destinationGeoIP'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  destinationIPASN: json['destinationIPASN'] as String? ?? '',
  sourceIPASN: json['sourceIPASN'] as String? ?? '',
  specialRules: json['specialRules'] as String? ?? '',
  specialProxy: json['specialProxy'] as String? ?? '',
);

Map<String, dynamic> _$MetadataToJson(_Metadata instance) => <String, dynamic>{
  'uid': instance.uid,
  'network': instance.network,
  'type': instance.type,
  'sourceIP': instance.sourceIP,
  'sourcePort': instance.sourcePort,
  'destinationIP': instance.destinationIP,
  'destinationPort': instance.destinationPort,
  'host': instance.host,
  'sniffHost': instance.sniffHost,
  'inboundName': instance.inboundName,
  'inboundPort': instance.inboundPort,
  'inboundUser': instance.inboundUser,
  'dnsMode': _$DnsModeEnumMap[instance.dnsMode],
  'process': instance.process,
  'processPath': instance.processPath,
  'remoteDestination': instance.remoteDestination,
  'sourceGeoIP': instance.sourceGeoIP,
  'destinationGeoIP': instance.destinationGeoIP,
  'destinationIPASN': instance.destinationIPASN,
  'sourceIPASN': instance.sourceIPASN,
  'specialRules': instance.specialRules,
  'specialProxy': instance.specialProxy,
};

const _$DnsModeEnumMap = {
  DnsMode.normal: 'normal',
  DnsMode.fakeIp: 'fake-ip',
  DnsMode.redirHost: 'redir-host',
  DnsMode.hosts: 'hosts',
};

_TrackerInfo _$TrackerInfoFromJson(Map<String, dynamic> json) => _TrackerInfo(
  id: json['id'] as String,
  upload: (json['upload'] as num?)?.toInt() ?? 0,
  download: (json['download'] as num?)?.toInt() ?? 0,
  start: DateTime.parse(json['start'] as String),
  metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
  chains: (json['chains'] as List<dynamic>).map((e) => e as String).toList(),
  rule: json['rule'] as String,
  rulePayload: json['rulePayload'] as String,
  downloadSpeed: (json['downloadSpeed'] as num?)?.toInt(),
  uploadSpeed: (json['uploadSpeed'] as num?)?.toInt(),
);

Map<String, dynamic> _$TrackerInfoToJson(_TrackerInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'upload': instance.upload,
      'download': instance.download,
      'start': instance.start.toIso8601String(),
      'metadata': instance.metadata,
      'chains': instance.chains,
      'rule': instance.rule,
      'rulePayload': instance.rulePayload,
      'downloadSpeed': instance.downloadSpeed,
      'uploadSpeed': instance.uploadSpeed,
    };

_Log _$LogFromJson(Map<String, dynamic> json) => _Log(
  logLevel:
      $enumDecodeNullable(_$LogLevelEnumMap, json['LogLevel']) ??
      LogLevel.error,
  payload: json['Payload'] as String? ?? '',
  time: _logTime(json['time']),
);

Map<String, dynamic> _$LogToJson(_Log instance) => <String, dynamic>{
  'LogLevel': _$LogLevelEnumMap[instance.logLevel]!,
  'Payload': instance.payload,
  'time': instance.time.toIso8601String(),
};

const _$LogLevelEnumMap = {
  LogLevel.debug: 'debug',
  LogLevel.info: 'info',
  LogLevel.warning: 'warning',
  LogLevel.error: 'error',
  LogLevel.silent: 'silent',
};

_DAV _$DAVFromJson(Map<String, dynamic> json) => _DAV(
  uri: json['uri'] as String,
  user: json['user'] as String,
  password: json['password'] as String,
  fileName: json['fileName'] as String? ?? defaultDavFileName,
  autoBackup: json['autoBackup'] as bool? ?? false,
);

Map<String, dynamic> _$DAVToJson(_DAV instance) => <String, dynamic>{
  'uri': instance.uri,
  'user': instance.user,
  'password': instance.password,
  'fileName': instance.fileName,
  'autoBackup': instance.autoBackup,
};

_NetworkInfo _$NetworkInfoFromJson(Map<String, dynamic> json) => _NetworkInfo(
  type: json['type'] as String? ?? '',
  interfaceName: json['interface'] as String? ?? '',
  ip: json['ip'] as String? ?? '',
  gateway: json['gateway'] as String? ?? '',
  dns:
      (json['dns'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$NetworkInfoToJson(_NetworkInfo instance) =>
    <String, dynamic>{
      'type': instance.type,
      'interface': instance.interfaceName,
      'ip': instance.ip,
      'gateway': instance.gateway,
      'dns': instance.dns,
    };

_VersionInfo _$VersionInfoFromJson(Map<String, dynamic> json) => _VersionInfo(
  clashName: json['clashName'] as String? ?? '',
  version: json['version'] as String? ?? '',
);

Map<String, dynamic> _$VersionInfoToJson(_VersionInfo instance) =>
    <String, dynamic>{
      'clashName': instance.clashName,
      'version': instance.version,
    };

_Proxy _$ProxyFromJson(Map<String, dynamic> json) => _Proxy(
  name: json['name'] as String,
  type: json['type'] as String,
  now: json['now'] as String?,
);

Map<String, dynamic> _$ProxyToJson(_Proxy instance) => <String, dynamic>{
  'name': instance.name,
  'type': instance.type,
  'now': instance.now,
};

_Group _$GroupFromJson(Map<String, dynamic> json) => _Group(
  type: $enumDecode(_$GroupTypeEnumMap, json['type']),
  all:
      (json['all'] as List<dynamic>?)
          ?.map((e) => Proxy.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  now: json['now'] as String?,
  hidden: json['hidden'] as bool?,
  testUrl: json['testUrl'] as String?,
  icon: json['icon'] as String? ?? '',
  name: json['name'] as String,
);

Map<String, dynamic> _$GroupToJson(_Group instance) => <String, dynamic>{
  'type': _$GroupTypeEnumMap[instance.type]!,
  'all': instance.all,
  'now': instance.now,
  'hidden': instance.hidden,
  'testUrl': instance.testUrl,
  'icon': instance.icon,
  'name': instance.name,
};

const _$GroupTypeEnumMap = {
  GroupType.Selector: 'Selector',
  GroupType.URLTest: 'URLTest',
  GroupType.Fallback: 'Fallback',
  GroupType.LoadBalance: 'LoadBalance',
};

_IpRiskCheck _$IpRiskCheckFromJson(Map<String, dynamic> json) => _IpRiskCheck(
  group: $enumDecode(_$IpRiskGroupEnumMap, json['group']),
  name: json['name'] as String,
  hit: json['hit'] as bool?,
);

Map<String, dynamic> _$IpRiskCheckToJson(_IpRiskCheck instance) =>
    <String, dynamic>{
      'group': _$IpRiskGroupEnumMap[instance.group]!,
      'name': instance.name,
      'hit': instance.hit,
    };

const _$IpRiskGroupEnumMap = {
  IpRiskGroup.datacenter: 'datacenter',
  IpRiskGroup.blacklist: 'blacklist',
  IpRiskGroup.proxy: 'proxy',
};

_IpRiskNote _$IpRiskNoteFromJson(Map<String, dynamic> json) => _IpRiskNote(
  direct: json['direct'] as bool?,
  isp: json['isp'] as String? ?? '',
  amount: $enumDecodeNullable(_$IpRiskAmountEnumMap, json['amount']),
  share: $enumDecodeNullable(_$IpRiskShareEnumMap, json['share']),
  operatorName: json['operatorName'] as String? ?? '',
  operatorLevel: $enumDecodeNullable(
    _$IpRiskLevelEnumMap,
    json['operatorLevel'],
  ),
  ownerName: json['ownerName'] as String? ?? '',
  ownerLevel: $enumDecodeNullable(_$IpRiskLevelEnumMap, json['ownerLevel']),
  connection: $enumDecodeNullable(
    _$IpRiskConnectionEnumMap,
    json['connection'],
  ),
  warning: $enumDecodeNullable(_$IpRiskLevelEnumMap, json['warning']),
);

Map<String, dynamic> _$IpRiskNoteToJson(_IpRiskNote instance) =>
    <String, dynamic>{
      'direct': instance.direct,
      'isp': instance.isp,
      'amount': _$IpRiskAmountEnumMap[instance.amount],
      'share': _$IpRiskShareEnumMap[instance.share],
      'operatorName': instance.operatorName,
      'operatorLevel': _$IpRiskLevelEnumMap[instance.operatorLevel],
      'ownerName': instance.ownerName,
      'ownerLevel': _$IpRiskLevelEnumMap[instance.ownerLevel],
      'connection': _$IpRiskConnectionEnumMap[instance.connection],
      'warning': _$IpRiskLevelEnumMap[instance.warning],
    };

const _$IpRiskAmountEnumMap = {
  IpRiskAmount.low: 'low',
  IpRiskAmount.medium: 'medium',
  IpRiskAmount.high: 'high',
};

const _$IpRiskShareEnumMap = {
  IpRiskShare.little: 'little',
  IpRiskShare.some: 'some',
  IpRiskShare.almostAll: 'almostAll',
};

const _$IpRiskLevelEnumMap = {
  IpRiskLevel.low: 'low',
  IpRiskLevel.medium: 'medium',
  IpRiskLevel.high: 'high',
  IpRiskLevel.veryHigh: 'veryHigh',
};

const _$IpRiskConnectionEnumMap = {
  IpRiskConnection.server: 'server',
  IpRiskConnection.vpn: 'vpn',
  IpRiskConnection.publicProxy: 'publicProxy',
  IpRiskConnection.tor: 'tor',
  IpRiskConnection.webProxy: 'webProxy',
};

_IpRisk _$IpRiskFromJson(Map<String, dynamic> json) => _IpRisk(
  ip: json['ip'] as String,
  score: (json['score'] as num).toInt(),
  level: $enumDecode(_$IpRiskLevelEnumMap, json['level']),
  hostname: json['hostname'] as String? ?? '',
  asn: json['asn'] as String? ?? '',
  isp: json['isp'] as String? ?? '',
  organization: json['organization'] as String? ?? '',
  country: json['country'] as String? ?? '',
  countryCode: json['countryCode'] as String? ?? '',
  region: json['region'] as String? ?? '',
  city: json['city'] as String? ?? '',
  checks:
      (json['checks'] as List<dynamic>?)
          ?.map((e) => IpRiskCheck.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  note: json['note'] == null
      ? null
      : IpRiskNote.fromJson(json['note'] as Map<String, dynamic>),
);

Map<String, dynamic> _$IpRiskToJson(_IpRisk instance) => <String, dynamic>{
  'ip': instance.ip,
  'score': instance.score,
  'level': _$IpRiskLevelEnumMap[instance.level]!,
  'hostname': instance.hostname,
  'asn': instance.asn,
  'isp': instance.isp,
  'organization': instance.organization,
  'country': instance.country,
  'countryCode': instance.countryCode,
  'region': instance.region,
  'city': instance.city,
  'checks': instance.checks,
  'note': instance.note,
};

_HotKeyAction _$HotKeyActionFromJson(Map<String, dynamic> json) =>
    _HotKeyAction(
      action: $enumDecode(_$HotActionEnumMap, json['action']),
      key: (json['key'] as num?)?.toInt(),
      modifiers:
          (json['modifiers'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$KeyboardModifierEnumMap, e))
              .toSet() ??
          const {},
    );

Map<String, dynamic> _$HotKeyActionToJson(_HotKeyAction instance) =>
    <String, dynamic>{
      'action': _$HotActionEnumMap[instance.action]!,
      'key': instance.key,
      'modifiers': instance.modifiers
          .map((e) => _$KeyboardModifierEnumMap[e]!)
          .toList(),
    };

const _$HotActionEnumMap = {
  HotAction.start: 'start',
  HotAction.view: 'view',
  HotAction.mode: 'mode',
  HotAction.proxy: 'proxy',
  HotAction.tun: 'tun',
};

const _$KeyboardModifierEnumMap = {
  KeyboardModifier.alt: 'alt',
  KeyboardModifier.capsLock: 'capsLock',
  KeyboardModifier.control: 'control',
  KeyboardModifier.fn: 'fn',
  KeyboardModifier.meta: 'meta',
  KeyboardModifier.shift: 'shift',
};

_TextPainterParams _$TextPainterParamsFromJson(Map<String, dynamic> json) =>
    _TextPainterParams(
      text: json['text'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      textScaleFactor: (json['textScaleFactor'] as num).toDouble(),
      maxWidth: (json['maxWidth'] as num?)?.toDouble() ?? double.infinity,
      maxLines: (json['maxLines'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TextPainterParamsToJson(_TextPainterParams instance) =>
    <String, dynamic>{
      'text': instance.text,
      'fontSize': instance.fontSize,
      'textScaleFactor': instance.textScaleFactor,
      'maxWidth': instance.maxWidth,
      'maxLines': instance.maxLines,
    };

_Script _$ScriptFromJson(Map<String, dynamic> json) => _Script(
  id: json['id'] as String,
  label: json['label'] as String,
  content: json['content'] as String? ?? '',
  url: json['url'] as String?,
  customOptions: (json['custom-options'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as bool),
  ),
  digest: json['digest'] as String?,
  compatible: json['compatible'] as bool? ?? false,
  volatile: json['volatile'] as bool?,
);

Map<String, dynamic> _$ScriptToJson(_Script instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'content': instance.content,
  'url': instance.url,
  'custom-options': instance.customOptions,
  'digest': instance.digest,
  'compatible': instance.compatible,
  'volatile': instance.volatile,
};

_RouteRuleSet _$RouteRuleSetFromJson(Map<String, dynamic> json) =>
    _RouteRuleSet(
      tag: json['tag'] as String,
      type: json['type'] as String? ?? 'geosite',
      name: json['name'] as String?,
      icon: json['icon'] as String?,
      count: (json['count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RouteRuleSetToJson(_RouteRuleSet instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'type': instance.type,
      'name': instance.name,
      'icon': instance.icon,
      'count': instance.count,
    };

_RouteService _$RouteServiceFromJson(
  Map<String, dynamic> json,
) => _RouteService(
  name: json['name'] as String,
  icon: json['icon'] as String?,
  sets:
      (json['sets'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  keywords:
      (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  groups:
      (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  category:
      $enumDecodeNullable(
        _$RouteCategoryEnumMap,
        json['category'],
        unknownValue: RouteCategory.other,
      ) ??
      RouteCategory.other,
);

Map<String, dynamic> _$RouteServiceToJson(_RouteService instance) =>
    <String, dynamic>{
      'name': instance.name,
      'icon': instance.icon,
      'sets': instance.sets,
      'keywords': instance.keywords,
      'groups': instance.groups,
      'category': _$RouteCategoryEnumMap[instance.category]!,
    };

const _$RouteCategoryEnumMap = {
  RouteCategory.ai: 'ai',
  RouteCategory.streaming: 'streaming',
  RouteCategory.social: 'social',
  RouteCategory.gaming: 'gaming',
  RouteCategory.developer: 'developer',
  RouteCategory.finance: 'finance',
  RouteCategory.tech: 'tech',
  RouteCategory.other: 'other',
};

_RouteCatalog _$RouteCatalogFromJson(
  Map<String, dynamic> json,
) => _RouteCatalog(
  targets:
      (json['targets'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  reserved:
      (json['reserved'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  groupCategories:
      (json['groupCategories'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, $enumDecode(_$RouteCategoryEnumMap, e)),
      ) ??
      const {},
  icons:
      (json['icons'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  services:
      (json['services'] as List<dynamic>?)
          ?.map((e) => RouteService.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  sets:
      (json['sets'] as List<dynamic>?)
          ?.map((e) => RouteRuleSet.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$RouteCatalogToJson(_RouteCatalog instance) =>
    <String, dynamic>{
      'targets': instance.targets,
      'reserved': instance.reserved,
      'groupCategories': instance.groupCategories.map(
        (k, e) => MapEntry(k, _$RouteCategoryEnumMap[e]!),
      ),
      'icons': instance.icons,
      'services': instance.services,
      'sets': instance.sets,
    };

_IconSetIcon _$IconSetIconFromJson(Map<String, dynamic> json) =>
    _IconSetIcon(name: json['name'] as String, url: json['url'] as String);

Map<String, dynamic> _$IconSetIconToJson(_IconSetIcon instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};

_IconSet _$IconSetFromJson(Map<String, dynamic> json) => _IconSet(
  id: json['id'] as String,
  name: json['name'] as String,
  url: json['url'] as String? ?? '',
  icons:
      (json['icons'] as List<dynamic>?)
          ?.map((e) => IconSetIcon.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  lastUpdateTime: json['lastUpdateTime'] == null
      ? null
      : DateTime.parse(json['lastUpdateTime'] as String),
);

Map<String, dynamic> _$IconSetToJson(_IconSet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'url': instance.url,
  'icons': instance.icons,
  'lastUpdateTime': instance.lastUpdateTime?.toIso8601String(),
};
