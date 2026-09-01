// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../clash_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProxyGroup _$ProxyGroupFromJson(Map<String, dynamic> json) => _ProxyGroup(
  name: json['name'] as String,
  type: GroupType.parseProfileType(json['type'] as String),
  proxies: _parseStringList(json['proxies']),
  use: _parseStringList(json['use']),
  interval: _parseInt(json['interval']),
  lazy: _parseBool(json['lazy']),
  url: json['url'] as String?,
  timeout: _parseInt(json['timeout']),
  maxFailedTimes: _parseInt(json['max-failed-times']),
  filter: json['filter'] as String?,
  excludeFilter: json['expected-filter'] as String?,
  excludeType: json['exclude-type'] as String?,
  expectedStatus: json['expected-status'],
  hidden: _parseBool(json['hidden']),
  icon: json['icon'] as String?,
  tolerance: _parseInt(json['tolerance']),
);

Map<String, dynamic> _$ProxyGroupToJson(_ProxyGroup instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$GroupTypeEnumMap[instance.type]!,
      'proxies': instance.proxies,
      'use': instance.use,
      'interval': instance.interval,
      'lazy': instance.lazy,
      'url': instance.url,
      'timeout': instance.timeout,
      'max-failed-times': instance.maxFailedTimes,
      'filter': instance.filter,
      'expected-filter': instance.excludeFilter,
      'exclude-type': instance.excludeType,
      'expected-status': instance.expectedStatus,
      'hidden': instance.hidden,
      'icon': instance.icon,
      'tolerance': instance.tolerance,
    };

const _$GroupTypeEnumMap = {
  GroupType.Selector: 'Selector',
  GroupType.URLTest: 'URLTest',
  GroupType.Fallback: 'Fallback',
  GroupType.LoadBalance: 'LoadBalance',
};

_RuleProvider _$RuleProviderFromJson(Map<String, dynamic> json) =>
    _RuleProvider(name: json['name'] as String);

Map<String, dynamic> _$RuleProviderToJson(_RuleProvider instance) =>
    <String, dynamic>{'name': instance.name};

_Sniffer _$SnifferFromJson(Map<String, dynamic> json) => _Sniffer(
  enable: json['enable'] as bool? ?? true,
  overrideDest: json['override-destination'] as bool? ?? false,
  sniffing:
      (json['sniffing'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  forceDomain:
      (json['force-domain'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['+.v2ex.com'],
  skipSrcAddress:
      (json['skip-src-address'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['192.168.0.3/32'],
  skipDstAddress:
      (json['skip-dst-address'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [
        '91.108.56.0/22',
        '91.108.4.0/22',
        '91.108.8.0/22',
        '91.108.16.0/22',
        '91.108.12.0/22',
        '149.154.160.0/20',
        '91.105.192.0/23',
        '91.108.20.0/22',
        '185.76.151.0/24',
        '2001:b28:f23d::/48',
        '2001:b28:f23f::/48',
        '2001:67c:4e8::/48',
        '2001:b28:f23c::/48',
        '2a0a:f280::/32',
      ],
  skipDomain:
      (json['skip-domain'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['Mijia Cloud', '+.push.apple.com'],
  port:
      (json['port-whitelist'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  forceDnsMapping: json['force-dns-mapping'] as bool? ?? true,
  parsePureIp: json['parse-pure-ip'] as bool? ?? true,
  sniff:
      (json['sniff'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, SnifferConfig.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {
        'HTTP': SnifferConfig(ports: ['80', '8080-8880'], overrideDest: true),
        'TLS': SnifferConfig(ports: ['443', '8443']),
        'QUIC': SnifferConfig(ports: ['443', '8443']),
      },
);

Map<String, dynamic> _$SnifferToJson(_Sniffer instance) => <String, dynamic>{
  'enable': instance.enable,
  'override-destination': instance.overrideDest,
  'sniffing': instance.sniffing,
  'force-domain': instance.forceDomain,
  'skip-src-address': instance.skipSrcAddress,
  'skip-dst-address': instance.skipDstAddress,
  'skip-domain': instance.skipDomain,
  'port-whitelist': instance.port,
  'force-dns-mapping': instance.forceDnsMapping,
  'parse-pure-ip': instance.parsePureIp,
  'sniff': instance.sniff,
};

_TunnelEntry _$TunnelEntryFromJson(Map<String, dynamic> json) => _TunnelEntry(
  id: json['id'] as String,
  network: (json['network'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  address: json['address'] as String?,
  target: json['target'] as String?,
  proxyName: json['proxyName'] as String?,
);

Map<String, dynamic> _$TunnelEntryToJson(_TunnelEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'network': instance.network,
      'address': instance.address,
      'target': instance.target,
      'proxyName': instance.proxyName,
    };

_SnifferConfig _$SnifferConfigFromJson(Map<String, dynamic> json) =>
    _SnifferConfig(
      ports: json['ports'] == null
          ? const []
          : _formJsonPorts(json['ports'] as List?),
      overrideDest: json['override-destination'] as bool?,
    );

Map<String, dynamic> _$SnifferConfigToJson(_SnifferConfig instance) =>
    <String, dynamic>{
      'ports': instance.ports,
      'override-destination': instance.overrideDest,
    };

_Tun _$TunFromJson(Map<String, dynamic> json) => _Tun(
  enable: json['enable'] as bool? ?? false,
  device: json['device'] as String? ?? tunDeviceName,
  autoRoute: json['auto-route'] as bool? ?? false,
  stack:
      $enumDecodeNullable(_$TunStackEnumMap, json['stack']) ?? TunStack.mixed,
  dnsHijack:
      (json['dns-hijack'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['any:53'],
  routeAddress:
      (json['route-address'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  routeExcludeAddress:
      (json['route-exclude-address'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  strictRoute: json['strict-route'] as bool? ?? false,
  disableIcmpForwarding: json['disable-icmp-forwarding'] as bool? ?? true,
  mtu: (json['mtu'] as num?)?.toInt() ?? 9000,
  endpointIndependentNat: json['endpoint-independent-nat'] as bool? ?? false,
);

Map<String, dynamic> _$TunToJson(_Tun instance) => <String, dynamic>{
  'enable': instance.enable,
  'device': instance.device,
  'auto-route': instance.autoRoute,
  'stack': _$TunStackEnumMap[instance.stack]!,
  'dns-hijack': instance.dnsHijack,
  'route-address': instance.routeAddress,
  'route-exclude-address': instance.routeExcludeAddress,
  'strict-route': instance.strictRoute,
  'disable-icmp-forwarding': instance.disableIcmpForwarding,
  'mtu': instance.mtu,
  'endpoint-independent-nat': instance.endpointIndependentNat,
};

const _$TunStackEnumMap = {
  TunStack.gvisor: 'gvisor',
  TunStack.system: 'system',
  TunStack.mixed: 'mixed',
};

_FallbackFilter _$FallbackFilterFromJson(
  Map<String, dynamic> json,
) => _FallbackFilter(
  geoip: json['geoip'] as bool? ?? false,
  geoipCode: json['geoip-code'] as String? ?? 'CN',
  ipcidr:
      (json['ipcidr'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  domain:
      (json['domain'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$FallbackFilterToJson(_FallbackFilter instance) =>
    <String, dynamic>{
      'geoip': instance.geoip,
      'geoip-code': instance.geoipCode,
      'ipcidr': instance.ipcidr,
      'domain': instance.domain,
    };

_Dns _$DnsFromJson(Map<String, dynamic> json) => _Dns(
  enable: json['enable'] as bool? ?? true,
  listen: json['listen'] as String? ?? '0.0.0.0:10053',
  preferH3: json['prefer-h3'] as bool? ?? false,
  cacheAlgorithm:
      $enumDecodeNullable(_$CacheAlgorithmEnumMap, json['cache-algorithm']) ??
      CacheAlgorithm.arc,
  useHosts: json['use-hosts'] as bool? ?? true,
  useSystemHosts: json['use-system-hosts'] as bool? ?? true,
  respectRules: json['respect-rules'] as bool? ?? false,
  ipv6: json['ipv6'] as bool? ?? false,
  defaultNameserver:
      (json['default-nameserver'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['114.114.114.114'],
  enhancedMode:
      $enumDecodeNullable(_$DnsModeEnumMap, json['enhanced-mode']) ??
      DnsMode.fakeIp,
  fakeIpRange: json['fake-ip-range'] as String? ?? '198.18.0.1/15',
  fakeIpRangeV6: json['fake-ip-range6'] as String? ?? '',
  fakeIpFilterMode:
      $enumDecodeNullable(_$FilterModeEnumMap, json['fake-ip-filter-mode']) ??
      FilterMode.blacklist,
  fakeIpFilter:
      (json['fake-ip-filter'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [
        '*',
        'geosite:private',
        'geosite:category-ntp',
        'geosite:geolocation-cn',
        'geosite:connectivity-check',
      ],
  fakeIpTtl: (json['fake-ip-ttl'] as num?)?.toInt() ?? 1,
  nameserverPolicy:
      (json['nameserver-policy'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {
        '+.internal.corp.com': '10.0.0.1',
        'geosite:cn': '119.29.29.29',
        'geosite:private': 'system',
        '*': 'system',
      },
  nameserver:
      (json['nameserver'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['1.1.1.1'],
  fallback:
      (json['fallback'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  proxyServerNameserver:
      (json['proxy-server-nameserver'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['https://120.53.53.53/dns-query#DIRECT'],
  directNameserver:
      (json['direct-nameserver'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  directNameserverFollowPolicy:
      json['direct-nameserver-follow-policy'] as bool? ?? false,
  fallbackFilter: json['fallback-filter'] == null
      ? const FallbackFilter()
      : FallbackFilter.fromJson(
          json['fallback-filter'] as Map<String, dynamic>,
        ),
  fallbackLazyQuery: json['fallback-lazy-query'] as bool? ?? false,
);

Map<String, dynamic> _$DnsToJson(_Dns instance) => <String, dynamic>{
  'enable': instance.enable,
  'listen': instance.listen,
  'prefer-h3': instance.preferH3,
  'cache-algorithm': _$CacheAlgorithmEnumMap[instance.cacheAlgorithm]!,
  'use-hosts': instance.useHosts,
  'use-system-hosts': instance.useSystemHosts,
  'respect-rules': instance.respectRules,
  'ipv6': instance.ipv6,
  'default-nameserver': instance.defaultNameserver,
  'enhanced-mode': _$DnsModeEnumMap[instance.enhancedMode]!,
  'fake-ip-range': instance.fakeIpRange,
  'fake-ip-range6': instance.fakeIpRangeV6,
  'fake-ip-filter-mode': _$FilterModeEnumMap[instance.fakeIpFilterMode]!,
  'fake-ip-filter': instance.fakeIpFilter,
  'fake-ip-ttl': instance.fakeIpTtl,
  'nameserver-policy': instance.nameserverPolicy,
  'nameserver': instance.nameserver,
  'fallback': instance.fallback,
  'proxy-server-nameserver': instance.proxyServerNameserver,
  'direct-nameserver': instance.directNameserver,
  'direct-nameserver-follow-policy': instance.directNameserverFollowPolicy,
  'fallback-filter': instance.fallbackFilter,
  'fallback-lazy-query': instance.fallbackLazyQuery,
};

const _$CacheAlgorithmEnumMap = {
  CacheAlgorithm.arc: 'arc',
  CacheAlgorithm.lru: 'lru',
};

const _$DnsModeEnumMap = {
  DnsMode.normal: 'normal',
  DnsMode.fakeIp: 'fake-ip',
  DnsMode.redirHost: 'redir-host',
  DnsMode.hosts: 'hosts',
};

const _$FilterModeEnumMap = {
  FilterMode.blacklist: 'blacklist',
  FilterMode.whitelist: 'whitelist',
  FilterMode.rule: 'rule',
};

_Ntp _$NtpFromJson(Map<String, dynamic> json) => _Ntp(
  enable: json['enable'] as bool? ?? true,
  writeToSystem: json['write-to-system'] as bool? ?? false,
  server: json['server'] as String? ?? 'time.apple.com',
  port: (json['port'] as num?)?.toInt() ?? 123,
  interval: (json['interval'] as num?)?.toInt() ?? 60,
);

Map<String, dynamic> _$NtpToJson(_Ntp instance) => <String, dynamic>{
  'enable': instance.enable,
  'write-to-system': instance.writeToSystem,
  'server': instance.server,
  'port': instance.port,
  'interval': instance.interval,
};

_Experimental _$ExperimentalFromJson(Map<String, dynamic> json) =>
    _Experimental(
      quicGoDisableGso: json['quic-go-disable-gso'] as bool? ?? true,
      quicGoDisableEcn: json['quic-go-disable-ecn'] as bool? ?? true,
      dialerIp4pConvert: json['dialer-ip4p-convert'] as bool? ?? false,
    );

Map<String, dynamic> _$ExperimentalToJson(_Experimental instance) =>
    <String, dynamic>{
      'quic-go-disable-gso': instance.quicGoDisableGso,
      'quic-go-disable-ecn': instance.quicGoDisableEcn,
      'dialer-ip4p-convert': instance.dialerIp4pConvert,
    };

_GeoXUrl _$GeoXUrlFromJson(Map<String, dynamic> json) => _GeoXUrl(
  mmdb:
      json['mmdb'] as String? ??
      'https://github.com/appshubcc/bett-rules/releases/download/latest/geoip.metadb',
  asn:
      json['asn'] as String? ??
      'https://github.com/appshubcc/bett-rules/releases/download/latest/GeoLite2-ASN.mmdb',
  geosite:
      json['geosite'] as String? ??
      'https://github.com/appshubcc/bett-rules/releases/download/latest/geosite.dat',
);

Map<String, dynamic> _$GeoXUrlToJson(_GeoXUrl instance) => <String, dynamic>{
  'mmdb': instance.mmdb,
  'asn': instance.asn,
  'geosite': instance.geosite,
};

_Rule _$RuleFromJson(Map<String, dynamic> json) =>
    _Rule(id: json['id'] as String, value: json['value'] as String);

Map<String, dynamic> _$RuleToJson(_Rule instance) => <String, dynamic>{
  'id': instance.id,
  'value': instance.value,
};

_SubRule _$SubRuleFromJson(Map<String, dynamic> json) =>
    _SubRule(name: json['name'] as String);

Map<String, dynamic> _$SubRuleToJson(_SubRule instance) => <String, dynamic>{
  'name': instance.name,
};

_ClashConfigSnippet _$ClashConfigSnippetFromJson(Map<String, dynamic> json) =>
    _ClashConfigSnippet(
      proxyGroups:
          (json['proxy-groups'] as List<dynamic>?)
              ?.map((e) => ProxyGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      rule: json['rules'] == null ? const [] : _genRule(json['rules'] as List?),
      ruleProvider: json['rule-providers'] == null
          ? const []
          : _genRuleProviders(json['rule-providers'] as Map<String, dynamic>),
      subRules: json['sub-rules'] == null
          ? const []
          : _genSubRules(json['sub-rules'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClashConfigSnippetToJson(_ClashConfigSnippet instance) =>
    <String, dynamic>{
      'proxy-groups': instance.proxyGroups,
      'rules': instance.rule,
      'rule-providers': instance.ruleProvider,
      'sub-rules': instance.subRules,
    };

_ClashConfig _$ClashConfigFromJson(Map<String, dynamic> json) => _ClashConfig(
  mixedPort: (json['mixed-port'] as num?)?.toInt() ?? defaultMixedPort,
  socksPort: (json['socks-port'] as num?)?.toInt() ?? 0,
  port: (json['port'] as num?)?.toInt() ?? 0,
  redirPort: (json['redir-port'] as num?)?.toInt() ?? 0,
  tproxyPort: (json['tproxy-port'] as num?)?.toInt() ?? 0,
  mode: $enumDecodeNullable(_$ModeEnumMap, json['mode']) ?? Mode.rule,
  allowLan: json['allow-lan'] as bool? ?? false,
  logLevel:
      $enumDecodeNullable(_$LogLevelEnumMap, json['log-level']) ??
      LogLevel.error,
  ipv6: json['ipv6'] as bool? ?? false,
  findProcessMode:
      $enumDecodeNullable(
        _$FindProcessModeEnumMap,
        json['find-process-mode'],
        unknownValue: FindProcessMode.always,
      ) ??
      FindProcessMode.off,
  keepAliveInterval:
      (json['keep-alive-interval'] as num?)?.toInt() ??
      defaultKeepAliveInterval,
  unifiedDelay: json['unified-delay'] as bool? ?? true,
  tcpConcurrent: json['tcp-concurrent'] as bool? ?? true,
  tun: json['tun'] == null
      ? defaultTun
      : Tun.safeFormJson(json['tun'] as Map<String, Object?>?),
  dns: json['dns'] == null
      ? defaultDns
      : Dns.safeDnsFromJson(json['dns'] as Map<String, Object?>),
  ntp: json['ntp'] == null
      ? defaultNtp
      : Ntp.safeNtpFromJson(json['ntp'] as Map<String, Object?>),
  sniffer: json['sniffer'] == null
      ? defaultSniffer
      : Sniffer.safeSnifferFromJson(json['sniffer'] as Map<String, Object?>),
  tunnels:
      (json['tunnels'] as List<dynamic>?)
          ?.map((e) => TunnelEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      defaultTunnel,
  experimental: json['experimental'] == null
      ? defaultExperimental
      : Experimental.safeExperimentalFromJson(
          json['experimental'] as Map<String, Object?>,
        ),
  geoXUrl: json['geox-url'] == null
      ? defaultGeoXUrl
      : GeoXUrl.safeFormJson(json['geox-url'] as Map<String, Object?>?),
  geodataLoader:
      $enumDecodeNullable(_$GeodataLoaderEnumMap, json['geodata-loader']) ??
      GeodataLoader.memconservative,
  proxyGroups:
      (json['proxy-groups'] as List<dynamic>?)
          ?.map((e) => ProxyGroup.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  rule:
      (json['rule'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  globalUa: json['global-ua'] as String?,
  externalController:
      $enumDecodeNullable(
        _$ExternalControllerStatusEnumMap,
        json['external-controller'],
      ) ??
      ExternalControllerStatus.close,
  secret: json['secret'] as String?,
  externalUiName: json['external-ui-name'] as String?,
  externalUiUrl: json['external-ui-url'] as String?,
  hosts:
      (json['hosts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
);

Map<String, dynamic> _$ClashConfigToJson(_ClashConfig instance) =>
    <String, dynamic>{
      'mixed-port': instance.mixedPort,
      'socks-port': instance.socksPort,
      'port': instance.port,
      'redir-port': instance.redirPort,
      'tproxy-port': instance.tproxyPort,
      'mode': _$ModeEnumMap[instance.mode]!,
      'allow-lan': instance.allowLan,
      'log-level': _$LogLevelEnumMap[instance.logLevel]!,
      'ipv6': instance.ipv6,
      'find-process-mode': _$FindProcessModeEnumMap[instance.findProcessMode]!,
      'keep-alive-interval': instance.keepAliveInterval,
      'unified-delay': instance.unifiedDelay,
      'tcp-concurrent': instance.tcpConcurrent,
      'tun': instance.tun,
      'dns': instance.dns,
      'ntp': instance.ntp,
      'sniffer': instance.sniffer,
      'tunnels': instance.tunnels,
      'experimental': instance.experimental,
      'geox-url': instance.geoXUrl,
      'geodata-loader': _$GeodataLoaderEnumMap[instance.geodataLoader]!,
      'proxy-groups': instance.proxyGroups,
      'rule': instance.rule,
      'global-ua': instance.globalUa,
      'external-controller':
          _$ExternalControllerStatusEnumMap[instance.externalController]!,
      'secret': instance.secret,
      'external-ui-name': instance.externalUiName,
      'external-ui-url': instance.externalUiUrl,
      'hosts': instance.hosts,
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

const _$FindProcessModeEnumMap = {
  FindProcessMode.always: 'always',
  FindProcessMode.off: 'off',
};

const _$GeodataLoaderEnumMap = {
  GeodataLoader.standard: 'standard',
  GeodataLoader.memconservative: 'memconservative',
};

const _$ExternalControllerStatusEnumMap = {
  ExternalControllerStatus.close: '',
  ExternalControllerStatus.open: '127.0.0.1:9090',
};
