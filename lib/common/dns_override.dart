/// DNS / hosts 覆写逻辑。
///
/// 与 MyClash 仓库 `Script/mihomoScript.js` 的 `buildDnsAndHostsConfig` 保持同一套语义：
/// 保留订阅里的私有 DNS、按 hosts 改写节点 server、把节点域名的 policy 与
/// fake-ip-filter 收窄到节点域名上。
///
/// 调用点：GUI 的「覆写 DNS」。`GlobalState.patchRawConfig` 用 GUI 设置生成 DNS 之后调用
/// [applyDnsNodeOverride]，把订阅里的节点域名策略接回来。
/// 合并多份配置时**不**调用这里：成员的 DNS / hosts 由内置脚本各自承接，合并阶段只取并集。
library;

/// 常见的公共 DNS，用于过滤订阅中的公共 DNS（私有 DNS 才是需要保留的）。
const commonDnsList = [
  // IPv4（国内）
  '223.5.5.5',
  '223.6.6.6',
  '119.29.29.29',
  '1.12.12.12',
  '120.53.53.53',
  '114.114.114.114',
  '180.76.76.76',
  '1.2.4.8',
  '116.116.116.116',
  '101.226.4.6',
  '123.125.81.6',
  '180.184.1.1',
  '180.184.2.2',

  // IPv6（国内）
  '2400:3200::1',
  '2400:3200:baba::1',
  '2402:4e00::',
  '2400:da00::6666',

  // IPv4（国外）
  '1.1.1.1',
  '1.0.0.1',
  '8.8.8.8',
  '8.8.4.4',
  '9.9.9.9',
  '149.112.112.112',
  '208.67.222.222',
  '208.67.220.220',
  '94.140.14.14',
  '94.140.15.15',
  '76.76.2.0',
  '76.76.10.0',
  '185.228.168.9',
  '185.228.169.9',
  '77.88.8.8',
  '77.88.8.1',
  '156.154.70.1',
  '156.154.71.1',

  // IPv6（国外）
  '2606:4700:4700::1111',
  '2606:4700:4700::1001',
  '2001:4860:4860::8888',
  '2001:4860:4860::8844',
  '2620:fe::fe',
  '2620:fe::9',
  '2620:119:35::35',
  '2620:119:53::53',
  '2a10:50c0::bad1:ff',
  '2a10:50c0::bad2:ff',
  '2a10:50c0::ad1:ff',
  '2a10:50c0::ad2:ff',
  '2a0d:2a00:1::2',
  '2a0d:2a00:2::2',
  '2a02:6b8::feed:0ff',
  '2a02:6b8:0:1::feed:0ff',
  '2610:a1:1018::1',
  '2610:a1:1019::1',

  // 关键词（国内）
  'alidns',
  'doh.pub',
  'dot.pub',
  'dns.pub',
  'dnspod',
  'dns.baidu',

  // 关键词（国外）
  'dns.google',
  'dns.cloudflare',
  'dns.apple',
  'cloudflare-dns',
  'quad9',
  'opendns',
  'nextdns',
  'adguard',
  'one.one.one.one',
];

final _commonDnsRegex = RegExp(
  commonDnsList.map(RegExp.escape).join('|'),
  caseSensitive: false,
);

/// `system` 由内核解析，同样不属于需要承接的私有 DNS。
bool isCommonDns(String dns) {
  final value = dns.trim().toLowerCase();
  if (value == 'system' || value == 'system://') return true;
  return _commonDnsRegex.hasMatch(value);
}

int hostSpecificity(String pattern) {
  if (pattern.startsWith('+.')) return 2;
  if (pattern.startsWith('.')) return 1;
  if (pattern.contains('*')) return 0;
  return 3;
}

bool matchDomainPattern(String pattern, Iterable<String> domains) {
  pattern = pattern.toLowerCase();

  if (!pattern.contains('*') && !pattern.startsWith('+.') && !pattern.startsWith('.')) {
    return domains.any((d) => d.toLowerCase() == pattern);
  }

  final domainList = domains.map((d) => d.toLowerCase()).toList();

  if (pattern.startsWith('+.')) {
    final suffix = pattern.substring(2);
    return domainList.any((domain) => domain == suffix || domain.endsWith('.$suffix'));
  }

  if (pattern.startsWith('.')) {
    final suffix = pattern.substring(1);
    return domainList.any((domain) => domain != suffix && domain.endsWith('.$suffix'));
  }

  final patternParts = pattern.split('.');
  return domainList.any((domain) {
    final domainParts = domain.split('.');
    return patternParts.length == domainParts.length &&
        patternParts.indexed.every(
          (entry) => entry.$2 == '*' || entry.$2 == domainParts[entry.$1],
        );
  });
}

/// 剥离 DNS 地址的 `#` 策略组后缀；后缀含 direct/直连 时强制为 `#DIRECT`。
String stripDnsSuffix(String dns) {
  final hashIndex = dns.indexOf('#');
  if (hashIndex == -1) return dns;

  final prefix = dns.substring(0, hashIndex).trim();
  final suffix = dns.substring(hashIndex + 1).toLowerCase().trim();
  if (suffix.contains('direct') || suffix.contains('直连')) {
    return '$prefix#DIRECT';
  }
  return prefix;
}

/// 节点 server 是否为 IP（IP 不需要 DNS 解析，不参与域名策略收窄）。
bool isIpAddress(String server) {
  return RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(server) ||
      server.contains(':');
}

/// 简化节点域名策略：相同 DNS 的同后缀域名（至少三段）合并为 `+.suffix`。
Map<String, dynamic> simplifyDomainPolicy(Map<String, dynamic> policy) {
  final groups = <String, List<MapEntry<String, dynamic>>>{};

  for (final entry in policy.entries) {
    final domain = entry.key;
    if (domain.startsWith('+.') || domain.startsWith('.') || domain.contains('*')) {
      groups['keep:$domain'] = [entry];
      continue;
    }
    final parts = domain.split('.');
    if (parts.length < 3) {
      groups['keep:$domain'] = [entry];
      continue;
    }
    final suffix = parts.sublist(parts.length - 2).join('.');
    groups.putIfAbsent(suffix, () => []).add(entry);
  }

  String dnsKeyOf(dynamic dns) =>
      dns is List ? (List.of(dns)..sort()).join('\u0000') : '$dns';

  final result = <String, dynamic>{};
  for (final entry in groups.entries) {
    final domains = entry.value;
    final firstDnsKey = dnsKeyOf(domains.first.value);
    final sameDns = domains.every((d) => dnsKeyOf(d.value) == firstDnsKey);
    if (domains.length >= 2 && sameDns) {
      result['+.${entry.key}'] = domains.first.value;
    } else {
      for (final d in domains) {
        result[d.key] = d.value;
      }
    }
  }
  return result;
}

/// 根据订阅 hosts 映射改写节点 server，改写后无需再复制 hosts 进新配置。
/// 支持链式映射（如 a: b、b: c 时节点 a 改写为 c）；
/// 回环映射（a: b、b: a）由内核校验拒绝，此处仅以已访问集合防御性终止。
List<dynamic> applyHostsToProxies(List<dynamic> proxies, Map<String, dynamic>? hosts) {
  if (hosts == null || hosts.isEmpty) return proxies;

  final hostEntries = hosts.entries
      .where((entry) =>
          (entry.value is String && (entry.value as String).isNotEmpty) ||
          (entry.value is List && (entry.value as List).isNotEmpty))
      .toList()
    ..sort((a, b) => hostSpecificity(b.key) - hostSpecificity(a.key));
  if (hostEntries.isEmpty) return proxies;

  String? targetOf(dynamic value) {
    if (value is List) {
      for (final item in value) {
        if (item is String && item.isNotEmpty) return item;
      }
      return null;
    }
    return value is String && value.isNotEmpty ? value : null;
  }

  final resolveCache = <String, String>{};

  String resolve(String server) {
    final cached = resolveCache[server];
    if (cached != null) return cached;

    final seen = <String>{};
    var current = server.toLowerCase();
    var result = server;
    while (seen.add(current)) {
      MapEntry<String, dynamic>? entry;
      for (final e in hostEntries) {
        if (matchDomainPattern(e.key, [current])) {
          entry = e;
          break;
        }
      }
      final target = entry == null ? null : targetOf(entry.value);
      if (target == null) break;
      result = target;
      current = target.toLowerCase();
    }
    resolveCache[server] = result;
    return result;
  }

  return proxies.map((proxy) {
    if (proxy is! Map) return proxy;
    final server = proxy['server'];
    if (server is! String) return proxy;
    final resolved = resolve(server);
    return resolved == server ? proxy : {...proxy, 'server': resolved};
  }).toList();
}

/// 单个配置（订阅 / 成员）的 DNS 承接结果。
class DnsOverridePlan {
  const DnsOverridePlan({
    required this.proxies,
    required this.rewritten,
    required this.privateDns,
    required this.proxyServerPolicy,
    required this.fakeIpFilter,
  });

  /// hosts 改写后的节点列表。
  final List<dynamic> proxies;

  /// 节点列表是否因 hosts 改写而发生变化。
  final bool rewritten;

  /// 需要由 `proxy-server-nameserver` 承接的私有 DNS。
  final List<String> privateDns;

  /// 收窄到节点域名上的 `proxy-server-nameserver-policy`。
  final Map<String, dynamic> proxyServerPolicy;

  /// 收窄到节点域名上的 `fake-ip-filter`。
  final List<String> fakeIpFilter;
}

/// 计算一个配置的 DNS 承接方案，不改动入参。
///
/// hosts 改写条件（满足任意一个即可）：
/// 1. `proxy-server-nameserver` 有且仅有一个 DNS 并且该 DNS 包含非空的 listen 值
/// 2. `proxy-server-nameserver` 有且仅有一个 DNS 并且该 DNS 包含 127.0.0.1 且 listen 包含 0.0.0.0
DnsOverridePlan buildDnsOverridePlan({
  required List<dynamic> proxies,
  Map<String, dynamic>? originalDns,
  Map<String, dynamic>? originalHosts,
}) {
  originalDns ??= const {};

  final proxyServerNameservers =
      (originalDns['proxy-server-nameserver'] as List?)?.cast<String>() ??
          const <String>[];
  final listenValue = originalDns['listen'];

  final shouldRewriteByHosts =
      proxyServerNameservers.length == 1 &&
      listenValue is String &&
      listenValue.isNotEmpty &&
      (proxyServerNameservers.any(
            (dns) => dns.toLowerCase().contains(listenValue.toLowerCase()),
          ) ||
          (listenValue.contains('0.0.0.0') &&
              proxyServerNameservers.any(
                (dns) => dns.toLowerCase().contains('127.0.0.1'),
              )));

  final mappedProxies = shouldRewriteByHosts
      ? applyHostsToProxies(proxies, originalHosts)
      : proxies;

  final proxyDomains = <String>{};
  void collectServers(List<dynamic> list) {
    for (final proxy in list) {
      if (proxy is Map) {
        final server = proxy['server'];
        if (server is String && server.isNotEmpty && !isIpAddress(server)) {
          proxyDomains.add(server.toLowerCase());
        }
      }
    }
  }

  collectServers(proxies);
  if (shouldRewriteByHosts) {
    collectServers(mappedProxies);
  }

  // hosts 改写后节点域名已经被解析掉，不再需要承接私有 DNS。
  final privateProxyServerNameservers =
      shouldRewriteByHosts ? const <String>[] : proxyServerNameservers;

  final privateDns = <String>{};
  for (final dns in [
    ...(originalDns['nameserver'] as List? ?? const []),
    ...privateProxyServerNameservers,
  ]) {
    final stripped = stripDnsSuffix(dns.toString());
    if (stripped.isNotEmpty && !isCommonDns(stripped)) {
      privateDns.add(stripped);
    }
  }

  final originalPolicy = <String, dynamic>{
    ...?((originalDns['nameserver-policy'] as Map?)?.cast<String, dynamic>()),
    ...?((originalDns['proxy-server-nameserver-policy'] as Map?)
        ?.cast<String, dynamic>()),
  };
  final proxyServerPolicy = <String, dynamic>{};
  for (final entry in originalPolicy.entries) {
    if (!matchDomainPattern(entry.key, proxyDomains)) continue;

    final value = entry.value;
    final strippedValue = value is List
        ? value
            .map((item) => stripDnsSuffix(item.toString()))
            .where((item) => item.isNotEmpty)
            .toList()
        : stripDnsSuffix(value.toString());
    if (strippedValue is List && strippedValue.isEmpty) continue;

    proxyServerPolicy[entry.key] = strippedValue;
  }

  // 没有可用的域名策略时，私有 DNS 直接兜住全部节点域名。
  if (privateDns.isNotEmpty && proxyServerPolicy.isEmpty) {
    for (final domain in proxyDomains) {
      proxyServerPolicy[domain] = privateDns.toList();
    }
  }

  final proxyFakeIpFilter = ((originalDns['fake-ip-filter'] as List?) ?? const [])
      .where((pattern) => matchDomainPattern(pattern.toString(), proxyDomains))
      .map((pattern) => pattern.toString())
      .toList();

  final simplifiedPolicy =
      proxyDomains.length == proxyServerPolicy.length &&
          proxyServerPolicy.keys.every(
            (domain) => proxyDomains.contains(domain.toLowerCase()),
          )
      ? simplifyDomainPolicy(proxyServerPolicy)
      : proxyServerPolicy;

  return DnsOverridePlan(
    proxies: mappedProxies,
    rewritten: !identical(mappedProxies, proxies),
    privateDns: privateDns.toList(),
    proxyServerPolicy: simplifiedPolicy,
    fakeIpFilter: proxyFakeIpFilter,
  );
}

/// 把 [buildDnsOverridePlan] 的结果写回 [rawConfig]。
void applyDnsOverridePlan(Map<String, dynamic> rawConfig, DnsOverridePlan plan) {
  if (plan.rewritten) {
    rawConfig['proxies'] = plan.proxies;
  }

  final dns = (rawConfig['dns'] as Map?)?.cast<String, dynamic>();
  if (dns == null) return;

  if (plan.privateDns.isNotEmpty) {
    dns['proxy-server-nameserver'] = plan.privateDns;
  }
  if (plan.proxyServerPolicy.isNotEmpty) {
    dns['proxy-server-nameserver-policy'] = plan.proxyServerPolicy;
  }
  if (plan.fakeIpFilter.isNotEmpty) {
    final existingFilter = (dns['fake-ip-filter'] as List?) ?? const [];
    dns['fake-ip-filter'] = [...existingFilter, ...plan.fakeIpFilter];
  }
}

void applyDnsNodeOverride(
  Map<String, dynamic> rawConfig, {
  Map<String, dynamic>? originalDns,
  Map<String, dynamic>? originalHosts,
}) {
  final plan = buildDnsOverridePlan(
    proxies: (rawConfig['proxies'] as List?) ?? const [],
    originalDns: originalDns,
    originalHosts: originalHosts,
  );
  applyDnsOverridePlan(rawConfig, plan);
}
