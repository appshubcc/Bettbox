import 'dart:io';
import 'dart:typed_data';

const tailscaleProxyName = 'Tailscale';

/// Parent of each network's node state dir (`<parent>/<network id>`), so the
/// node never shares keys with a profile's tailscale proxy. Must match
/// tailscaleStateDir in core/tailscale.go.
const tailscaleStateDir = 'bettbox-tailscale';

/// Whether the core's path [dir] is the node state dir [stateDir].
bool isTailscaleStateDir(String dir, String stateDir) =>
    dir.split(RegExp(r'[\\/]')).last == stateDir.split('/').last;

/// Tailnet CGNAT range, tailnet IPv6 ULA and MagicDNS suffix.
const defaultTailscaleRoutes = [
  '100.64.0.0/10',
  'fd7a:115c:a1e0::/48',
  'ts.net',
];

final _domainRegExp = RegExp(r'^[a-z0-9_-]+(\.[a-z0-9_-]+)*$');

typedef _Net = ({BigInt base, int prefix, bool v6});

_Net? _parseNet(String value) {
  final parts = value.trim().split('/');
  if (parts.length > 2) return null;
  final ip = InternetAddress.tryParse(parts[0]);
  if (ip == null) return null;
  final v6 = ip.type == InternetAddressType.IPv6;
  final bits = v6 ? 128 : 32;
  final prefix = parts.length == 2 ? int.tryParse(parts[1]) : bits;
  if (prefix == null || prefix < 0 || prefix > bits) return null;
  final raw = ip.rawAddress.fold(
    BigInt.zero,
    (n, b) => (n << 8) | BigInt.from(b),
  );
  final mask = ((BigInt.one << prefix) - BigInt.one) << (bits - prefix);
  return (base: raw & mask, prefix: prefix, v6: v6);
}

String _formatNet(_Net net) {
  final length = net.v6 ? 16 : 4;
  final bytes = Uint8List.fromList(
    List.generate(
      length,
      (i) => ((net.base >> (8 * (length - 1 - i))) & BigInt.from(0xff)).toInt(),
    ),
  );
  return '${InternetAddress.fromRawAddress(bytes).address}/${net.prefix}';
}

/// Normalized `ip/prefix` for an IP or CIDR entry, null for anything else.
String? tailscaleCidr(String entry) {
  final net = _parseNet(entry);
  return net == null ? null : _formatNet(net);
}

/// Bare domain for a domain entry (`example.com`, `+.example.com`,
/// `*.example.com`, `.example.com`), null for anything else.
String? tailscaleDomain(String entry) {
  if (tailscaleCidr(entry) != null) return null;
  final domain = entry.trim().toLowerCase().replaceFirst(
    RegExp(r'^(\+\.|\*\.|\.)'),
    '',
  );
  return _domainRegExp.hasMatch(domain) ? domain : null;
}

bool isValidTailscaleEntry(String entry) =>
    tailscaleCidr(entry) != null || tailscaleDomain(entry) != null;

List<String> tailscaleRouteCidrs(List<String> entries) =>
    entries.map(tailscaleCidr).nonNulls.toSet().toList();

String _ipRule(String cidr) =>
    '${cidr.contains(':') ? 'IP-CIDR6' : 'IP-CIDR'},$cidr';

/// Rules sending [routes] and tailnet [dns] domains to [target].
///
/// A dns domain goes to the tailnet only when its answer is in a routed range
/// or the tailnet ranges, so public records of a split-horizon zone still
/// work; the IP is resolved lazily, through its tailnet DNS server. [except]
/// (the control server) never goes to the tailnet, so login pages load.
List<String> tailscaleRules(
  List<String> routes,
  String target, {
  List<String> dns = const [],
  String? except,
}) {
  final routedIps = {
    ...tailscaleRouteCidrs(routes),
    '100.64.0.0/10',
    'fd7a:115c:a1e0::/48',
  }.map((cidr) => '(${_ipRule(cidr)})').join(',');
  String domainRule(String domain, {bool answerRouted = false}) {
    final conditions = [
      '(DOMAIN-SUFFIX,$domain)',
      if (answerRouted) '(OR,($routedIps))',
      if (except != null && tailscaleRoutesCover([domain], except))
        '(NOT,((DOMAIN,$except)))',
    ];
    return conditions.length == 1
        ? 'DOMAIN-SUFFIX,$domain,$target'
        : 'AND,(${conditions.join(',')}),$target';
  }

  final routeDomains = routes.map(tailscaleDomain).nonNulls.toSet();
  return [
    for (final entry in routes)
      if (tailscaleCidr(entry) case final cidr?)
        '${_ipRule(cidr)},$target,no-resolve'
      else if (tailscaleDomain(entry) case final domain?)
        domainRule(domain),
    for (final domain in tailscaleDnsDomains(dns))
      if (!routeDomains.contains(domain))
        domainRule(domain, answerRouted: true),
  ];
}

bool tailscaleRoutesCover(List<String> entries, String host) => entries
    .map(tailscaleDomain)
    .nonNulls
    .any((domain) => host == domain || host.endsWith('.$domain'));

/// A tailnet DNS entry `domain=server`: the domain is resolved by a DNS
/// server reachable inside the tailnet, e.g. `corp.example.com=10.1.0.53`.
({String domain, String server})? parseTailscaleDns(String entry) {
  final parts = entry.split('=');
  if (parts.length != 2) return null;
  final domain = tailscaleDomain(parts[0]);
  var server = parts[1].trim();
  if (domain == null || server.isEmpty || server.contains(RegExp(r'[\s#]'))) {
    return null;
  }
  if (InternetAddress.tryParse(server)?.type == InternetAddressType.IPv6) {
    server = '[$server]';
  }
  final uri = Uri.tryParse(server.contains('://') ? server : 'udp://$server');
  if (uri == null || uri.host.isEmpty) return null;
  // Server hostnames are looked up outside the tailnet (default-nameserver),
  // so plain DNS needs an IP; DoT/DoH/DoQ may keep a public name for TLS.
  final ipOnly = uri.scheme == 'udp' || uri.scheme == 'tcp';
  if (!{'udp', 'tcp', 'tls', 'https', 'quic'}.contains(uri.scheme) ||
      (ipOnly && InternetAddress.tryParse(uri.host) == null)) {
    return null;
  }
  return (domain: domain, server: server);
}

List<String> tailscaleDnsDomains(List<String> dns) =>
    dns.map(parseTailscaleDns).nonNulls.map((e) => e.domain).toList();

/// nameserver-policy entries: routed domains resolve via MagicDNS, as the
/// tailscale outbound would; [dns] domains via their server, dialed through
/// the node (`#target`; TCP when the node has no UDP).
Map<String, Object> tailscaleNameserverPolicy(
  List<String> routes,
  String target, {
  List<String> dns = const [],
  bool udp = true,
}) {
  final servers = <String, List<String>>{};
  for (final entry in dns.map(parseTailscaleDns).nonNulls) {
    var server = entry.server;
    if (!udp && server.startsWith('udp://')) server = server.substring(6);
    if (!udp && !server.contains('://')) server = 'tcp://$server';
    (servers['+.${entry.domain}'] ??= []).add('$server#$target');
  }
  return {
    for (final domain in routes.map(tailscaleDomain).nonNulls)
      '+.$domain': 'tailscale://$target',
    ...servers,
  };
}

/// Removes [remove] from the CIDR list [from], splitting prefixes as needed.
/// Entries that are not CIDRs are kept as-is.
List<String> subtractCidrs(List<String> from, List<String> remove) {
  final removes = remove.map(_parseNet).nonNulls.toList();
  if (removes.isEmpty) return from;
  final result = <String>[];
  for (final raw in from) {
    final net = _parseNet(raw);
    if (net == null) {
      result.add(raw);
      continue;
    }
    var pieces = [net];
    for (final r in removes) {
      pieces = [for (final p in pieces) ..._minus(p, r)];
    }
    if (pieces.length == 1 && pieces.first == net) {
      result.add(raw);
    } else {
      result.addAll(pieces.map(_formatNet));
    }
  }
  return result;
}

bool _contains(_Net outer, _Net inner) {
  if (outer.v6 != inner.v6 || outer.prefix > inner.prefix) return false;
  final shift = (outer.v6 ? 128 : 32) - outer.prefix;
  return (inner.base >> shift) == (outer.base >> shift);
}

Iterable<_Net> _minus(_Net a, _Net b) sync* {
  if (_contains(b, a)) return;
  if (!_contains(a, b)) {
    yield a;
    return;
  }
  final bits = a.v6 ? 128 : 32;
  var current = a;
  while (current.prefix < b.prefix) {
    final prefix = current.prefix + 1;
    final low = (base: current.base, prefix: prefix, v6: a.v6);
    final high = (
      base: current.base | (BigInt.one << (bits - prefix)),
      prefix: prefix,
      v6: a.v6,
    );
    if (_contains(low, b)) {
      yield high;
      current = low;
    } else {
      yield low;
      current = high;
    }
  }
}
