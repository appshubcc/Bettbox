// ignore_for_file: invalid_annotation_target

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/clash_config.freezed.dart';
part 'generated/clash_config.g.dart';

typedef HostsMap = Map<String, String>;

const defaultClashConfig = ClashConfig();

const defaultTun = Tun();
const defaultDns = Dns();
const defaultNtp = Ntp();
const defaultSniffer = Sniffer();
const defaultTunnel = <TunnelEntry>[];
const defaultExperimental = Experimental();
const defaultGeoXUrl = GeoXUrl();

const defaultMixedPort = 7890;
const defaultKeepAliveInterval = 30;

const defaultBypassPrivateRouteAddress = [
  '198.51.100.0/30',
  '1.0.0.0/8',
  '2.0.0.0/7',
  '4.0.0.0/6',
  '8.0.0.0/7',
  '11.0.0.0/8',
  '12.0.0.0/6',
  '16.0.0.0/4',
  '32.0.0.0/3',
  '64.0.0.0/3',
  '96.0.0.0/4',
  '112.0.0.0/5',
  '120.0.0.0/6',
  '124.0.0.0/7',
  '126.0.0.0/8',
  '128.0.0.0/3',
  '160.0.0.0/5',
  '168.0.0.0/8',
  '169.0.0.0/9',
  '169.128.0.0/10',
  '169.192.0.0/11',
  '169.224.0.0/12',
  '169.240.0.0/13',
  '169.248.0.0/14',
  '169.252.0.0/15',
  '169.255.0.0/16',
  '170.0.0.0/7',
  '172.0.0.0/12',
  '172.32.0.0/11',
  '172.64.0.0/10',
  '172.128.0.0/9',
  '173.0.0.0/8',
  '174.0.0.0/7',
  '176.0.0.0/4',
  '192.0.0.0/9',
  '192.128.0.0/11',
  '192.160.0.0/13',
  '192.169.0.0/16',
  '192.170.0.0/15',
  '192.172.0.0/14',
  '192.176.0.0/12',
  '192.192.0.0/10',
  '193.0.0.0/8',
  '194.0.0.0/7',
  '196.0.0.0/6',
  '200.0.0.0/5',
  '208.0.0.0/4',
  '2000::/3',
];

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
  }
  return null;
}

List<String>? _parseStringList(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return null;
}

@freezed
abstract class ProxyGroup with _$ProxyGroup {
  const factory ProxyGroup({
    required String name,
    @JsonKey(fromJson: GroupType.parseProfileType) required GroupType type,
    @JsonKey(fromJson: _parseStringList) List<String>? proxies,
    @JsonKey(fromJson: _parseStringList) List<String>? use,
    @JsonKey(fromJson: _parseInt) int? interval,
    @JsonKey(fromJson: _parseBool) bool? lazy,
    String? url,
    @JsonKey(fromJson: _parseInt) int? timeout,
    @JsonKey(name: 'max-failed-times', fromJson: _parseInt) int? maxFailedTimes,
    String? filter,
    @JsonKey(name: 'expected-filter') String? excludeFilter,
    @JsonKey(name: 'exclude-type') String? excludeType,
    @JsonKey(name: 'expected-status') dynamic expectedStatus,
    @JsonKey(fromJson: _parseBool) bool? hidden,
    String? icon,
    @JsonKey(fromJson: _parseInt) int? tolerance,
  }) = _ProxyGroup;

  factory ProxyGroup.fromJson(Map<String, Object?> json) =>
      _$ProxyGroupFromJson(json);
}

@freezed
abstract class RuleProvider with _$RuleProvider {
  const factory RuleProvider({required String name}) = _RuleProvider;

  factory RuleProvider.fromJson(Map<String, Object?> json) =>
      _$RuleProviderFromJson(json);
}

@freezed
abstract class Sniffer with _$Sniffer {
  const factory Sniffer({
    @Default(true) bool enable,
    @Default(false) @JsonKey(name: 'override-destination') bool overrideDest,
    @Default([]) List<String> sniffing,
    @Default(['+.v2ex.com'])
    @JsonKey(name: 'force-domain')
    List<String> forceDomain,
    @Default(['192.168.0.3/32'])
    @JsonKey(name: 'skip-src-address')
    List<String> skipSrcAddress,
    @Default([
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
    ])
    @JsonKey(name: 'skip-dst-address')
    List<String> skipDstAddress,
    @Default(['Mijia Cloud', '+.push.apple.com'])
    @JsonKey(name: 'skip-domain')
    List<String> skipDomain,
    @Default([]) @JsonKey(name: 'port-whitelist') List<String> port,
    @Default(true) @JsonKey(name: 'force-dns-mapping') bool forceDnsMapping,
    @Default(true) @JsonKey(name: 'parse-pure-ip') bool parsePureIp,
    @Default({
      'HTTP': SnifferConfig(ports: ['80', '8080-8880'], overrideDest: true),
      'TLS': SnifferConfig(ports: ['443', '8443']),
      'QUIC': SnifferConfig(ports: ['443', '8443']),
    })
    Map<String, SnifferConfig> sniff,
  }) = _Sniffer;

  factory Sniffer.fromJson(Map<String, Object?> json) =>
      _$SnifferFromJson(json);

  factory Sniffer.safeSnifferFromJson(Map<String, Object?> json) {
    try {
      return Sniffer.fromJson(json);
    } catch (_) {
      return const Sniffer();
    }
  }
}

List<String> _formJsonPorts(List? ports) {
  return ports?.map((item) => item.toString()).toList() ?? [];
}

@freezed
abstract class TunnelEntry with _$TunnelEntry {
  const factory TunnelEntry({
    required String id,
    List<String>? network,
    String? address,
    String? target,
    String? proxyName,
  }) = _TunnelEntry;

  factory TunnelEntry.fromJson(Map<String, Object?> json) =>
      _$TunnelEntryFromJson(json);

  factory TunnelEntry.fromString(String value) {
    final id = utils.uuidV4;
    // Parse simple format: tcp/udp,127.0.0.1:6553,114.114.114.114:53,proxy
    final parts = value.split(',').map((e) => e.trim()).toList();
    if (parts.length >= 3) {
      return TunnelEntry(
        id: id,
        network: parts[0].split('/').map((e) => e.trim()).toList(),
        address: parts[1],
        target: parts[2],
        proxyName: parts.length > 3 ? parts[3] : null,
      );
    }
    return TunnelEntry(id: id);
  }
}

extension TunnelEntryExt on TunnelEntry {
  String get displayValue {
    final parts = <String>[];
    if (network != null && network!.isNotEmpty) {
      parts.add(network!.join('/'));
    }
    if (address != null && address!.isNotEmpty) {
      parts.add(address!);
    }
    if (target != null && target!.isNotEmpty) {
      parts.add(target!);
    }
    if (proxyName != null && proxyName!.isNotEmpty) {
      parts.add(proxyName!);
    }
    return parts.join(', ');
  }

  Map<String, dynamic> toClashJson() {
    final map = <String, dynamic>{};
    if (network != null && network!.isNotEmpty) {
      map['network'] = network;
    }
    if (address != null && address!.isNotEmpty) {
      map['address'] = address;
    }
    if (target != null && target!.isNotEmpty) {
      map['target'] = target;
    }
    if (proxyName != null && proxyName!.isNotEmpty) {
      map['proxy'] = proxyName;
    }
    return map;
  }
}

@freezed
abstract class SnifferConfig with _$SnifferConfig {
  const factory SnifferConfig({
    @Default([]) @JsonKey(fromJson: _formJsonPorts) List<String> ports,
    @JsonKey(name: 'override-destination') bool? overrideDest,
  }) = _SnifferConfig;

  factory SnifferConfig.fromJson(Map<String, Object?> json) =>
      _$SnifferConfigFromJson(json);
}

@freezed
abstract class Tun with _$Tun {
  const factory Tun({
    @Default(false) bool enable,
    @Default(tunDeviceName) String device,
    @JsonKey(name: 'auto-route') @Default(false) bool autoRoute,
    @Default(TunStack.system) TunStack stack,
    @JsonKey(name: 'dns-hijack') @Default(['any:53']) List<String> dnsHijack,
    @JsonKey(name: 'route-address') @Default([]) List<String> routeAddress,
    @JsonKey(name: 'route-exclude-address')
    @Default([])
    List<String> routeExcludeAddress,
    @JsonKey(name: 'strict-route') @Default(false) bool strictRoute,
    @JsonKey(name: 'disable-icmp-forwarding')
    @Default(true)
    bool disableIcmpForwarding,
    @Default(4064) int mtu,
    @JsonKey(name: 'endpoint-independent-nat')
    @Default(false)
    bool endpointIndependentNat,
  }) = _Tun;

  factory Tun.fromJson(Map<String, Object?> json) => _$TunFromJson(json);

  factory Tun.safeFormJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultTun;
    }
    try {
      return Tun.fromJson(json);
    } catch (_) {
      return defaultTun;
    }
  }
}

extension TunExt on Tun {
  Tun getRealTun(
    bool bypassPrivateRoute, {
    String? fakeIpRange,
    String? fakeIpRangeV6,
  }) {
    if (system.isDesktop) {
      if (bypassPrivateRoute) {
        return copyWith(
          autoRoute: true,
          routeAddress: [],
          routeExcludeAddress: [
            '127.0.0.0/8',
            '::1/128',
            '10.0.0.0/8',
            '172.16.0.0/12',
            '192.168.0.0/16',
            '169.254.0.0/16',
            'fd00::/8',
            'fe80::/10',
          ],
        );
      }
      return copyWith(
        autoRoute: true,
        routeAddress: [],
        routeExcludeAddress: [],
      );
    }

    if (bypassPrivateRoute) {
      return copyWith(
        autoRoute: true,
        routeAddress: List<String>.from(defaultBypassPrivateRouteAddress),
      );
    }

    return copyWith(autoRoute: true, routeAddress: []);
  }
}

@freezed
abstract class FallbackFilter with _$FallbackFilter {
  const factory FallbackFilter({
    @Default(false) bool geoip,
    @Default('CN') @JsonKey(name: 'geoip-code') String geoipCode,
    @Default([]) List<String> ipcidr,
    @Default([]) List<String> domain,
  }) = _FallbackFilter;
  factory FallbackFilter.fromJson(Map<String, Object?> json) =>
      _$FallbackFilterFromJson(json);
}

@freezed
abstract class Dns with _$Dns {
  const factory Dns({
    @Default(true) bool enable,
    @Default('0.0.0.0:10053') String listen,
    @Default(false) @JsonKey(name: 'prefer-h3') bool preferH3,
    @Default(CacheAlgorithm.arc)
    @JsonKey(name: 'cache-algorithm')
    CacheAlgorithm cacheAlgorithm,
    @Default(true) @JsonKey(name: 'use-hosts') bool useHosts,
    @Default(true) @JsonKey(name: 'use-system-hosts') bool useSystemHosts,
    @Default(false) @JsonKey(name: 'respect-rules') bool respectRules,
    @Default(false) bool ipv6,
    @Default(['114.114.114.114'])
    @JsonKey(name: 'default-nameserver')
    List<String> defaultNameserver,
    @Default(DnsMode.fakeIp)
    @JsonKey(name: 'enhanced-mode')
    DnsMode enhancedMode,
    @Default('198.18.0.1/15')
    @JsonKey(name: 'fake-ip-range')
    String fakeIpRange,
    @Default('') @JsonKey(name: 'fake-ip-range6') String fakeIpRangeV6,
    @Default(FilterMode.blacklist)
    @JsonKey(name: 'fake-ip-filter-mode')
    FilterMode fakeIpFilterMode,
    @Default([
      '*',
      'geosite:private',
      'geosite:category-ntp',
      'geosite:geolocation-cn',
      'geosite:connectivity-check',
    ])
    @JsonKey(name: 'fake-ip-filter')
    List<String> fakeIpFilter,
    @Default(1) @JsonKey(name: 'fake-ip-ttl') int fakeIpTtl,
    @Default({
      '+.internal.corp.com': '10.0.0.1',
      'geosite:cn': '119.29.29.29',
      'geosite:private': 'system',
      '*': 'system',
    })
    @JsonKey(name: 'nameserver-policy')
    Map<String, String> nameserverPolicy,
    @Default(['1.1.1.1']) List<String> nameserver,
    @Default([]) List<String> fallback,
    @Default(['https://doh.pub/dns-query#DIRECT'])
    @JsonKey(name: 'proxy-server-nameserver')
    List<String> proxyServerNameserver,
    @Default([])
    @JsonKey(name: 'direct-nameserver')
    List<String> directNameserver,
    @Default(false)
    @JsonKey(name: 'direct-nameserver-follow-policy')
    bool directNameserverFollowPolicy,
    @Default(FallbackFilter())
    @JsonKey(name: 'fallback-filter')
    FallbackFilter fallbackFilter,
    @Default(false)
    @JsonKey(name: 'fallback-lazy-query')
    bool fallbackLazyQuery,
  }) = _Dns;

  factory Dns.fromJson(Map<String, Object?> json) => _$DnsFromJson(json);

  factory Dns.safeDnsFromJson(Map<String, Object?> json) {
    try {
      return Dns.fromJson(json);
    } catch (_) {
      return const Dns();
    }
  }
}

@freezed
abstract class Ntp with _$Ntp {
  const factory Ntp({
    @Default(true) bool enable,
    @Default(false) @JsonKey(name: 'write-to-system') bool writeToSystem,
    @Default('time.apple.com') String server,
    @Default(123) int port,
    @Default(60) int interval,
  }) = _Ntp;

  factory Ntp.fromJson(Map<String, Object?> json) => _$NtpFromJson(json);

  factory Ntp.safeNtpFromJson(Map<String, Object?> json) {
    try {
      return Ntp.fromJson(json);
    } catch (_) {
      return const Ntp();
    }
  }
}

@freezed
abstract class Experimental with _$Experimental {
  const factory Experimental({
    @Default(true) @JsonKey(name: 'quic-go-disable-gso') bool quicGoDisableGso,
    @Default(true) @JsonKey(name: 'quic-go-disable-ecn') bool quicGoDisableEcn,
    @Default(false)
    @JsonKey(name: 'dialer-ip4p-convert')
    bool dialerIp4pConvert,
  }) = _Experimental;

  factory Experimental.fromJson(Map<String, Object?> json) =>
      _$ExperimentalFromJson(json);

  factory Experimental.safeExperimentalFromJson(Map<String, Object?> json) {
    try {
      return Experimental.fromJson(json);
    } catch (_) {
      return const Experimental();
    }
  }
}

@freezed
abstract class GeoXUrl with _$GeoXUrl {
  const factory GeoXUrl({
    @Default(
      'https://fastly.jsdelivr.net/gh/appshubcc/bett-rules@release/geoip.metadb',
    )
    String mmdb,
    @Default(
      'https://fastly.jsdelivr.net/gh/appshubcc/bett-rules@release/GeoLite2-ASN.mmdb',
    )
    String asn,
    @Default(
      'https://fastly.jsdelivr.net/gh/appshubcc/bett-rules@release/geoip.dat',
    )
    String geoip,
    @Default(
      'https://fastly.jsdelivr.net/gh/appshubcc/bett-rules@release/geosite.dat',
    )
    String geosite,
  }) = _GeoXUrl;

  factory GeoXUrl.fromJson(Map<String, Object?> json) =>
      _$GeoXUrlFromJson(json);

  factory GeoXUrl.safeFormJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultGeoXUrl;
    }
    try {
      return GeoXUrl.fromJson(json);
    } catch (_) {
      return defaultGeoXUrl;
    }
  }
}

@freezed
abstract class ParsedRule with _$ParsedRule {
  const factory ParsedRule({
    required RuleAction ruleAction,
    String? content,
    String? ruleTarget,
    String? ruleProvider,
    String? subRule,
    @Default(false) bool noResolve,
    @Default(false) bool src,
  }) = _ParsedRule;

  factory ParsedRule.parseString(String value) {
    var raw = value.trim();
    bool noResolve = false;
    bool src = false;

    while (true) {
      if (raw.endsWith(',no-resolve')) {
        noResolve = true;
        raw = raw.substring(0, raw.length - ',no-resolve'.length).trim();
      } else if (raw.endsWith(',src')) {
        src = true;
        raw = raw.substring(0, raw.length - ',src'.length).trim();
      } else {
        break;
      }
    }

    final firstComma = raw.indexOf(',');
    if (firstComma == -1) {
      final action = RuleAction.values.firstWhere(
        (item) => item.value == raw,
        orElse: () => RuleAction.MATCH,
      );
      return ParsedRule(
        ruleAction: action,
        noResolve: noResolve,
        src: src,
      );
    }

    final actionStr = raw.substring(0, firstComma).trim();
    final ruleAction = RuleAction.values.firstWhere(
      (item) => item.value == actionStr,
      orElse: () => RuleAction.DOMAIN,
    );

    final rest = raw.substring(firstComma + 1).trim();

    if (ruleAction == RuleAction.MATCH) {
      return ParsedRule(
        ruleAction: ruleAction,
        ruleTarget: rest,
        noResolve: noResolve,
        src: src,
      );
    }

    final lastComma = rest.lastIndexOf(',');
    if (lastComma == -1) {
      return ParsedRule(
        ruleAction: ruleAction,
        content: ruleAction != RuleAction.RULE_SET ? rest : null,
        ruleProvider: ruleAction == RuleAction.RULE_SET ? rest : null,
        noResolve: noResolve,
        src: src,
      );
    }

    final mainContent = rest.substring(0, lastComma).trim();
    final targetStr = rest.substring(lastComma + 1).trim();

    String? subRule;
    String? ruleTarget;
    if (ruleAction == RuleAction.SUB_RULE) {
      subRule = targetStr;
    } else {
      ruleTarget = targetStr;
    }

    String? content;
    String? ruleProvider;
    if (ruleAction == RuleAction.RULE_SET) {
      ruleProvider = mainContent;
    } else {
      content = mainContent;
    }

    return ParsedRule(
      ruleAction: ruleAction,
      content: content,
      ruleProvider: ruleProvider,
      subRule: subRule,
      ruleTarget: ruleTarget,
      noResolve: noResolve,
      src: src,
    );
  }
}

extension ParsedRuleExt on ParsedRule {
  String get value {
    if (ruleAction == RuleAction.MATCH) {
      return [ruleAction.value, ruleTarget]
          .where((e) => e != null && e.isNotEmpty)
          .join(',');
    }
    final target = ruleAction == RuleAction.SUB_RULE ? subRule : ruleTarget;
    final main = ruleAction == RuleAction.RULE_SET ? ruleProvider : content;
    final parts = <String>[
      ruleAction.value,
      if (main != null && main.isNotEmpty) main,
      if (target != null && target.isNotEmpty) target,
      if (ruleAction.hasParams) ...[
        if (src) 'src',
        if (noResolve) 'no-resolve',
      ],
    ];
    return parts.join(',');
  }
}

@freezed
abstract class Rule with _$Rule {
  const factory Rule({required String id, required String value}) = _Rule;

  factory Rule.value(String value) {
    return Rule(value: value, id: utils.uuidV4);
  }

  factory Rule.fromJson(Map<String, Object?> json) => _$RuleFromJson(json);
}

@freezed
abstract class SubRule with _$SubRule {
  const factory SubRule({required String name}) = _SubRule;

  factory SubRule.fromJson(Map<String, Object?> json) =>
      _$SubRuleFromJson(json);
}

List<Rule> _genRule(List<dynamic>? rules) {
  if (rules == null) {
    return [];
  }
  return rules.map((item) => Rule.value(item)).toList();
}

List<RuleProvider> _genRuleProviders(Map<String, dynamic> json) {
  return json.entries.map((entry) => RuleProvider(name: entry.key)).toList();
}

List<SubRule> _genSubRules(Map<String, dynamic> json) {
  return json.entries.map((entry) => SubRule(name: entry.key)).toList();
}

@freezed
abstract class ClashConfigSnippet with _$ClashConfigSnippet {
  const factory ClashConfigSnippet({
    @Default([]) @JsonKey(name: 'proxy-groups') List<ProxyGroup> proxyGroups,
    @JsonKey(fromJson: _genRule, name: 'rules') @Default([]) List<Rule> rule,
    @JsonKey(name: 'rule-providers', fromJson: _genRuleProviders)
    @Default([])
    List<RuleProvider> ruleProvider,
    @JsonKey(name: 'sub-rules', fromJson: _genSubRules)
    @Default([])
    List<SubRule> subRules,
  }) = _ClashConfigSnippet;

  factory ClashConfigSnippet.fromJson(Map<String, Object?> json) =>
      _$ClashConfigSnippetFromJson(json);
}

@freezed
abstract class ClashConfig with _$ClashConfig {
  const factory ClashConfig({
    @Default(defaultMixedPort) @JsonKey(name: 'mixed-port') int mixedPort,
    @Default(0) @JsonKey(name: 'socks-port') int socksPort,
    @Default(0) @JsonKey(name: 'port') int port,
    @Default(0) @JsonKey(name: 'redir-port') int redirPort,
    @Default(0) @JsonKey(name: 'tproxy-port') int tproxyPort,
    @Default(Mode.rule) Mode mode,
    @Default(false) @JsonKey(name: 'allow-lan') bool allowLan,
    @Default(LogLevel.error) @JsonKey(name: 'log-level') LogLevel logLevel,
    @Default(false) bool ipv6,
    @Default(FindProcessMode.off)
    @JsonKey(
      name: 'find-process-mode',
      unknownEnumValue: FindProcessMode.always,
    )
    FindProcessMode findProcessMode,
    @Default(defaultKeepAliveInterval)
    @JsonKey(name: 'keep-alive-interval')
    int keepAliveInterval,
    @Default(true) @JsonKey(name: 'unified-delay') bool unifiedDelay,
    @Default(true) @JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,
    @Default(defaultTun) @JsonKey(fromJson: Tun.safeFormJson) Tun tun,
    @Default(defaultDns) @JsonKey(fromJson: Dns.safeDnsFromJson) Dns dns,
    @Default(defaultNtp) @JsonKey(fromJson: Ntp.safeNtpFromJson) Ntp ntp,
    @Default(defaultSniffer)
    @JsonKey(fromJson: Sniffer.safeSnifferFromJson)
    Sniffer sniffer,
    @Default(defaultTunnel) List<TunnelEntry> tunnels,
    @Default(defaultExperimental)
    @JsonKey(fromJson: Experimental.safeExperimentalFromJson)
    Experimental experimental,
    @Default(defaultGeoXUrl)
    @JsonKey(name: 'geox-url', fromJson: GeoXUrl.safeFormJson)
    GeoXUrl geoXUrl,
    @Default(GeodataLoader.memconservative)
    @JsonKey(name: 'geodata-loader')
    GeodataLoader geodataLoader,
    @Default([]) @JsonKey(name: 'proxy-groups') List<ProxyGroup> proxyGroups,
    @Default([]) List<String> rule,
    @JsonKey(name: 'global-ua') String? globalUa,
    @Default(ExternalControllerStatus.close)
    @JsonKey(name: 'external-controller')
    ExternalControllerStatus externalController,
    String? secret,
    @JsonKey(name: 'external-ui-name') String? externalUiName,
    @JsonKey(name: 'external-ui-url') String? externalUiUrl,
    @Default({}) HostsMap hosts,
  }) = _ClashConfig;

  factory ClashConfig.fromJson(Map<String, Object?> json) =>
      _$ClashConfigFromJson(json);

  factory ClashConfig.safeFormJson(Map<String, Object?>? json) {
    if (json == null) {
      return system.isAndroid
          ? const ClashConfig(findProcessMode: FindProcessMode.always)
          : defaultClashConfig;
    }
    try {
      return ClashConfig.fromJson(json);
    } catch (_) {
      return system.isAndroid
          ? const ClashConfig(findProcessMode: FindProcessMode.always)
          : defaultClashConfig;
    }
  }
}
