import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';

class TorConfigTransformer {
  const TorConfigTransformer();

  static const outboundName = 'tor-out';
  static const socksHost = '127.0.0.1';
  static const socksPort = 19050;
  static const fallbackMixedPort = 12334;
  static const bridgeProxyFallback = 'Default Proxy';
  static const networkDetectionDomains = [
    'cp.cloudflare.com',
    'api.cloudflare.com',
    'www.qualcomm.cn',
    'www.cloudflare-cn.com',
    'ip-api.com',
  ];
  static const bridgeIps = [
    '212.83.43.95',
    '45.145.95.6',
    '146.57.248.225',
    '212.83.43.74',
    '209.148.46.65',
    '37.218.245.14',
    '51.222.13.177',
  ];

  List<dynamic> transform({
    required Map<String, dynamic> rawConfig,
    required List<dynamic> rules,
    required TorProps torProps,
    AccessControl? accessControl,
  }) {
    if (!torProps.enable) return rules;

    final torAppPackages = _effectiveTorAppPackages(torProps, accessControl);
    if (torAppPackages.isEmpty) return rules;

    _ensureMixedPort(rawConfig);
    _ensureTorProxy(rawConfig);
    _ensureTorDns(rawConfig);
    _ensureProcessLookup(rawConfig);

    return [
      ..._buildTorRules(rawConfig, torProps, accessControl, torAppPackages),
      ...rules.where((rule) => !_isGeneratedTorRule(rule)),
    ];
  }

  void _ensureMixedPort(Map<String, dynamic> rawConfig) {
    final mixedPort = rawConfig['mixed-port'];
    if (mixedPort is int && mixedPort > 0) return;
    rawConfig['mixed-port'] = fallbackMixedPort;
  }

  void _ensureTorProxy(Map<String, dynamic> rawConfig) {
    final proxies = rawConfig['proxies'];
    final proxyList = proxies is List ? proxies : <dynamic>[];
    proxyList.removeWhere((proxy) {
      return proxy is Map && proxy['name'] == outboundName;
    });
    proxyList.add({
      'name': outboundName,
      'type': 'socks5',
      'server': socksHost,
      'port': socksPort,
      'udp': false,
    });
    rawConfig['proxies'] = proxyList;
  }

  void _ensureTorDns(Map<String, dynamic> rawConfig) {
    final dns = rawConfig['dns'];
    final dnsMap = dns is Map ? dns : <String, dynamic>{};
    dnsMap['enable'] = true;
    rawConfig['dns'] = dnsMap;
  }

  void _ensureProcessLookup(Map<String, dynamic> rawConfig) {
    rawConfig['find-process-mode'] = FindProcessMode.always.name;
  }

  Iterable<String> _effectiveTorAppPackages(
    TorProps torProps,
    AccessControl? accessControl,
  ) {
    final torPackages = torProps.appPackages
        .map((packageName) => packageName.trim())
        .where((packageName) => packageName.isNotEmpty);
    final isVpnWhitelist =
        accessControl?.enable == true &&
        accessControl?.mode == AccessControlMode.acceptSelected;
    if (!isVpnWhitelist) return torPackages;
    return torPackages.where(
      (packageName) => accessControl!.acceptList.contains(packageName),
    );
  }

  List<String> _buildTorRules(
    Map<String, dynamic> rawConfig,
    TorProps torProps,
    AccessControl? accessControl,
    Iterable<String> torAppPackages,
  ) {
    final bridgeProxy = _bridgeProxyName(rawConfig);
    final bridgeRules = _bridgeRules(torProps, bridgeProxy);
    final proxyServerRules = _proxyServerRules(rawConfig, bridgeProxy);
    final networkDetectionRules = networkDetectionDomains.map(
      (domain) => 'DOMAIN,$domain,$bridgeProxy',
    );
    final allVpnAppsUseTor = _allVpnAppsUseTor(torProps, accessControl);
    final packageRules = torAppPackages.expand((packageName) {
      return [
        'PROCESS-NAME,$packageName,$outboundName',
        'PROCESS-NAME-REGEX,^${RegExp.escape(packageName)}(:.*)?\$,$outboundName',
      ];
    });

    return [
      ...bridgeRules,
      ...proxyServerRules,
      ...networkDetectionRules,
      ...packageRules,
      if (allVpnAppsUseTor) 'NETWORK,TCP,$outboundName',
      'AND,((NETWORK,UDP),(DST-PORT,53)),REJECT',
      'AND,((NETWORK,UDP),(NOT,((DST-PORT,53)))),REJECT',
    ];
  }

  bool _allVpnAppsUseTor(TorProps torProps, AccessControl? accessControl) {
    final isVpnWhitelist =
        accessControl?.enable == true &&
        accessControl?.mode == AccessControlMode.acceptSelected;
    if (!isVpnWhitelist) return false;

    final torAppPackageSet = torProps.appPackages
        .map((packageName) => packageName.trim())
        .where((packageName) => packageName.isNotEmpty)
        .toSet();
    final acceptedPackageSet =
        accessControl?.acceptList
            .map((packageName) => packageName.trim())
            .where((packageName) => packageName.isNotEmpty)
            .toSet() ??
        const <String>{};
    return acceptedPackageSet.isNotEmpty &&
        acceptedPackageSet.difference(torAppPackageSet).isEmpty;
  }

  String _bridgeProxyName(Map<String, dynamic> rawConfig) {
    final groups = rawConfig['proxy-groups'];
    if (groups is! List) return bridgeProxyFallback;

    final names = groups
        .whereType<Map>()
        .map((group) => group['name']?.toString())
        .whereType<String>()
        .toList();

    return names.firstWhere(
      (name) => name == bridgeProxyFallback,
      orElse: () => names.isNotEmpty ? names.first : bridgeProxyFallback,
    );
  }

  List<String> _bridgeRules(TorProps torProps, String bridgeProxy) {
    final ips = {
      ...bridgeIps,
      if (torProps.customBridgesEnabled)
        ..._customBridgeIps(torProps.customBridges),
    };
    return ips.map((ip) => 'IP-CIDR,$ip/32,$bridgeProxy').toList();
  }

  List<String> _proxyServerRules(Map<String, dynamic> rawConfig, String proxy) {
    final proxies = rawConfig['proxies'];
    if (proxies is! List) return const [];

    final rules = <String>[];
    final seen = <String>{};
    for (final item in proxies) {
      if (item is! Map) continue;
      final server = item['server']?.toString().trim();
      if (server == null ||
          server.isEmpty ||
          server == socksHost ||
          server == 'localhost') {
        continue;
      }
      if (!seen.add(server)) continue;

      if (_isIpv4(server)) {
        rules.add('IP-CIDR,$server/32,$proxy');
      } else {
        rules.add('DOMAIN,$server,$proxy');
      }
    }
    return rules;
  }

  Iterable<String> _customBridgeIps(String bridges) sync* {
    for (final line in bridges.split(RegExp(r'\r?\n'))) {
      final parts = line.trim().split(RegExp(r'\s+'));
      if (parts.length < 2) continue;
      final host = parts[1].split(':').first;
      if (_isIpv4(host)) {
        yield host;
      }
    }
  }

  bool _isIpv4(String value) {
    return RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(value);
  }

  bool _isGeneratedTorRule(dynamic rule) {
    final value = rule.toString();
    return value.contains(outboundName) ||
        networkDetectionDomains.any(
          (domain) => value.startsWith('DOMAIN,$domain,'),
        ) ||
        value == 'AND,((NETWORK,UDP),(NOT,((DST-PORT,53)))),REJECT';
  }
}
