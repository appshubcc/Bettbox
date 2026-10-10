import 'package:bett_box/common/dns_override.dart';
import 'package:bett_box/common/profile_merger.dart';
import 'package:flutter_test/flutter_test.dart';

/// 构造一份「已经跑过内置覆写脚本」的成员配置：脚本产出的节点、策略组、
/// 规则、DNS、hosts 与全局项都在。
Map<String, dynamic> _overridden({
  required List<Map<String, dynamic>> proxies,
  List<Map<String, dynamic>> groups = const [],
  Map<String, dynamic>? dns,
  Map<String, dynamic>? hosts,
  Map<String, dynamic>? extra,
}) {
  return {
    'proxies': proxies,
    'proxy-groups': groups,
    'rules': ['MATCH,漏网之鱼'],
    'rule-providers': {
      'cn': {'type': 'http', 'url': 'https://example.com/cn.mrs'},
    },
    'mixed-port': 7890,
    'mode': 'rule',
    'dns': ?dns,
    'hosts': hosts ?? const <String, dynamic>{},
    ...?extra,
  };
}

BundleMemberConfig _member({
  required String id,
  required String label,
  required Map<String, dynamic> config,
}) {
  return BundleMemberConfig(id: id, label: label, config: config);
}

Map<String, dynamic> _group(String name, List<String> proxies) => {
  'name': name,
  'type': 'select',
  'proxies': proxies,
};

Map<String, dynamic> _proxy(String name, String server) => {
  'name': name,
  'type': 'ss',
  'server': server,
  'port': 443,
  'cipher': 'aes-128-gcm',
  'password': 'p',
};

List<String> _namesOf(BundleMergeResult result) {
  return (result.config['proxies'] as List)
      .cast<Map>()
      .map((proxy) => proxy['name'] as String)
      .toList();
}

Map<String, Map<String, dynamic>> _groupsOf(BundleMergeResult result) {
  final groups = (result.config['proxy-groups'] as List).cast<Map>();
  return {
    for (final group in groups)
      group['name'] as String: group.cast<String, dynamic>(),
  };
}

/// 脚本固定注入的内核直连节点。
Map<String, dynamic> _directProxy() => {
  'name': '🇨🇳 直连 | 双栈',
  'type': 'direct',
};

void main() {
  group('dns_override', () {
    test('stripDnsSuffix 强制 direct 后缀并裁剪空白', () {
      expect(stripDnsSuffix('1.1.1.1#proxy'), '1.1.1.1');
      expect(stripDnsSuffix('1.1.1.1 #direct '), '1.1.1.1#DIRECT');
      expect(stripDnsSuffix('1.1.1.1#直连'), '1.1.1.1#DIRECT');
      expect(stripDnsSuffix('1.1.1.1'), '1.1.1.1');
    });

    test('isCommonDns 覆盖 system 与 IPv6 公共 DNS', () {
      expect(isCommonDns('system'), isTrue);
      expect(isCommonDns('system://'), isTrue);
      expect(isCommonDns('2606:4700:4700::1111'), isTrue);
      expect(isCommonDns('https://dns.google/dns-query'), isTrue);
      expect(isCommonDns('192.168.1.1'), isFalse);
    });

    test('simplifyDomainPolicy 合并同后缀同 DNS 的域名', () {
      const dns = ['192.168.1.1'];
      final simplified = simplifyDomainPolicy({
        'a.example.com': dns,
        'b.example.com': dns,
        'c.other.com': dns,
      });
      expect(simplified.keys, contains('+.example.com'));
      expect(simplified['c.other.com'], dns);
    });

    test('proxy-server-nameserver 指向本地监听时按 hosts 改写节点', () {
      final plan = buildDnsOverridePlan(
        proxies: [_proxy('A', 'node.example.com')],
        originalDns: {
          'proxy-server-nameserver': ['127.0.0.1:5353'],
          'listen': '0.0.0.0:5353',
        },
        originalHosts: {
          'node.example.com': '1.2.3.4',
        },
      );
      expect(plan.rewritten, isTrue);
      expect((plan.proxies.single as Map)['server'], '1.2.3.4');
      expect(plan.privateDns, isEmpty);
    });

    test('私有 DNS 收窄到节点域名上', () {
      final plan = buildDnsOverridePlan(
        proxies: [_proxy('B', 'sub.example.com')],
        originalDns: {
          'nameserver': ['192.168.1.1'],
          'proxy-server-nameserver': ['192.168.1.1'],
        },
      );
      expect(plan.privateDns, ['192.168.1.1']);
      expect(plan.proxyServerPolicy['sub.example.com'], ['192.168.1.1']);
    });
  });

  group('mergeBundleConfigs', () {
    test('跨成员按内容指纹去重，并保留先出现的成员', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(
              proxies: [_proxy('HK 01', 'hk1.example.com')],
            ),
          ),
          _member(
            id: '2',
            label: 'B',
            config: _overridden(
              proxies: [
                _proxy('HK 01 duplicate', 'hk1.example.com'),
                _proxy('JP 01', 'jp1.example.com'),
              ],
            ),
          ),
        ],
      );

      expect(_namesOf(result), ['A | HK 01', 'B | JP 01']);
      expect(result.report.duplicateNodeCount, 1);
      expect(result.report.nodeCount, 2);
    });

    test('重名成员的前缀撞车时追加序号，不静默覆盖', () {
      final result = mergeBundleConfigs(
        members: [
          // 两个成员同名 → 前缀相同，第二个必须让号
          _member(
            id: '1',
            label: 'A',
            config: _overridden(proxies: [_proxy('同名', 'a.example.com')]),
          ),
          _member(
            id: '2',
            label: 'A',
            config: _overridden(proxies: [_proxy('同名', 'b.example.com')]),
          ),
        ],
      );

      final names = _namesOf(result);
      expect(names.where((name) => name == 'A | 同名').length, 1);
      expect(names.where((name) => name == 'A | 同名-2').length, 1);
    });

    test('成员自己填的前缀优先于成员名称', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(proxies: [_proxy('HK 01', 'hk1.example.com')]),
          ),
          _member(
            id: '2',
            label: 'B',
            config: _overridden(proxies: [_proxy('JP 01', 'jp1.example.com')]),
          ),
        ],
        options: const BundleMergeOptions(
          memberPrefixes: {'1': '机场甲'},
        ),
      );
      // 成员 1 用自己的前缀，成员 2 没填 → 用成员名称
      expect(_namesOf(result), ['机场甲 | HK 01', 'B | JP 01']);
    });

    test('成员前缀留空（含纯空白）时用成员名称', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(proxies: [_proxy('HK 01', 'hk1.example.com')]),
          ),
        ],
        options: const BundleMergeOptions(memberPrefixes: {'1': '   '}),
      );
      expect(_namesOf(result), ['A | HK 01']);
    });

    test('各成员里完全一样的节点按内容去重，算作先出现成员的节点', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: '机场A',
            config: _overridden(
              proxies: [
                _proxy('共用', 'custom.example.com'),
                _proxy('HK 01', 'hk1.example.com'),
              ],
              groups: [
                _group('默认代理', ['共用', 'HK 01']),
              ],
            ),
          ),
          _member(
            id: '2',
            label: '机场B',
            config: _overridden(
              proxies: [
                _proxy('共用', 'custom.example.com'),
                _proxy('JP 01', 'jp1.example.com'),
              ],
              groups: [
                _group('默认代理', ['共用', 'JP 01']),
              ],
            ),
          ),
        ],
      );

      // 不加前缀的只有内核直连 / 拒绝节点：普通节点一律带成员前缀，
      // 内容完全相同的按「先出现成员」保留一份
      expect(_namesOf(result), [
        '机场A | 共用',
        '机场A | HK 01',
        '机场B | JP 01',
      ]);
      expect(result.report.duplicateNodeCount, 1);
      expect(_groupsOf(result)['默认代理']!['proxies'], [
        '机场A | 共用',
        '机场A | HK 01',
        '机场B | JP 01',
      ]);
    });

    test('内容相同但名字不同的节点也按内容指纹去重', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(
              proxies: [_proxy('自建-日本', 'custom.example.com')],
            ),
          ),
          _member(
            id: '2',
            label: 'B',
            config: _overridden(
              proxies: [_proxy('自建-自建-日本', 'custom.example.com')],
            ),
          ),
        ],
      );
      // 名字不一致不影响去重：按内容指纹保留先出现成员的那一份
      expect(_namesOf(result), ['A | 自建-日本']);
      expect(result.report.duplicateNodeCount, 1);
    });

    test('只在一个成员里出现的节点仍然带前缀', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(proxies: [_proxy('独有', 'only.example.com')]),
          ),
          _member(
            id: '2',
            label: 'B',
            config: _overridden(proxies: [_proxy('别的', 'other.example.com')]),
          ),
        ],
      );
      expect(_namesOf(result), ['A | 独有', 'B | 别的']);
    });

    test('只有一个成员时照常加前缀', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: '机场A',
            config: _overridden(
              proxies: [_proxy('自建-日本', 'custom.example.com')],
            ),
          ),
        ],
      );
      expect(_namesOf(result), ['机场A | 自建-日本']);
    });

    test('节点名与前缀里的逗号都会被清洗，避免破坏规则目标', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(proxies: [_proxy('HK,01', 'hk.example.com')]),
          ),
          _member(
            id: '2',
            label: 'B',
            config: _overridden(proxies: [_proxy('JP,01', 'jp.example.com')]),
          ),
        ],
        options: const BundleMergeOptions(memberPrefixes: {'2': 'P,Q'}),
      );
      expect(_namesOf(result), ['A | HK，01', 'P，Q | JP，01']);
    });

    test('dialer-proxy 引用随改名一起重写', () {
      final entry = _proxy('入口', 'entry.example.com')
        ..['dialer-proxy'] = '出口';
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(
              proxies: [entry, _proxy('出口', 'exit.example.com')],
            ),
          ),
        ],
        options: const BundleMergeOptions(memberPrefixes: {'1': 'P'}),
      );
      final proxies = (result.config['proxies'] as List).cast<Map>();
      final kept = proxies.firstWhere((proxy) => proxy['name'] == 'P | 入口');
      expect(kept['dialer-proxy'], 'P | 出口');
    });

    test('dialer-proxy 指向策略组时原样保留，且不再产生告警', () {
      final relay = _proxy('中转入口', 'relay.example.com')
        ..['dialer-proxy'] = '链式中转';
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(
              proxies: [relay, _proxy('落地', 'land.example.com')],
              groups: [
                _group('链式中转', ['中转入口', '落地']),
              ],
            ),
          ),
        ],
      );

      final proxies = (result.config['proxies'] as List).cast<Map>();
      final kept = proxies.firstWhere(
        (proxy) => proxy['name'] == 'A | 中转入口',
      );
      // 组引用不在改名表里，保持原样；也不该再报「dialer-proxy 目标不存在」
      expect(kept['dialer-proxy'], '链式中转');
      expect(
        result.report.warnings.any((w) => w.code == 'dialerProxy'),
        isFalse,
      );
      expect(_groupsOf(result)['链式中转']!['proxies'], [
        'A | 中转入口',
        'A | 落地',
      ]);
    });

    test('策略组按名字取并集，组内节点引用跟随改名', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(
              proxies: [_proxy('HK 01', 'hk1.example.com')],
              groups: [
                _group('香港', ['HK 01']),
                _group('默认代理', ['香港', '直连']),
              ],
            ),
          ),
          _member(
            id: '2',
            label: 'B',
            config: _overridden(
              proxies: [_proxy('HK 02', 'hk2.example.com')],
              groups: [
                _group('香港', ['HK 02']),
                _group('默认代理', ['香港', '直连']),
              ],
            ),
          ),
        ],
      );

      final groups = _groupsOf(result);
      expect(groups['香港']!['proxies'], ['A | HK 01', 'B | HK 02']);
      // 组名引用（如「直连」）不是节点名，保持原样
      expect(groups['默认代理']!['proxies'], ['香港', '直连']);
      expect(result.report.groupCount, 2);
    });

    test('只在一个成员里出现的策略组被保留下来', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(
              proxies: [_proxy('HK 01', 'hk1.example.com')],
              groups: [_group('香港', ['HK 01'])],
            ),
          ),
          _member(
            id: '2',
            label: 'B',
            config: _overridden(
              proxies: [
                _proxy('JP 01', 'jp1.example.com'),
                _proxy('HK 02', 'hk2.example.com'),
              ],
              groups: [
                _group('香港', ['HK 02']),
                _group('日本', ['JP 01']),
              ],
            ),
          ),
        ],
      );

      final names = (_groupsOf(result).keys).toList();
      // 组顺序按脚本顺序还原（成员的组列表都是它的子序列），只在后出现成员里的「日本」保留下来
      expect(names, ['香港', '日本']);
      final groups = _groupsOf(result);
      // 先出现的成员里的「香港」保留，另一个成员的节点并入
      expect(groups['香港']!['proxies'], ['A | HK 01', 'B | HK 02']);
    });

    test('某个成员缺组时，该组仍然回到脚本里的位置（不甩到末尾）', () {
      // A 没有低倍率节点，所以没有「低倍率/高倍率」组，但它的地区组更多
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(
              proxies: [_proxy('HK 01', 'hk1.example.com')],
              groups: [
                _group('默认代理', ['手动选择']),
                _group('手动选择', ['HK 01']),
                _group('漏网之鱼', ['默认代理']),
                _group('直连', ['DIRECT']),
                _group('香港', ['HK 01']),
                _group('日本', ['HK 01']),
                _group('美国', ['HK 01']),
              ],
            ),
          ),
          _member(
            id: '2',
            label: 'B',
            config: _overridden(
              proxies: [_proxy('JP 01', 'jp1.example.com')],
              groups: [
                _group('默认代理', ['手动选择']),
                _group('手动选择', ['JP 01']),
                _group('低倍率', ['JP 01']),
                _group('高倍率', ['JP 01']),
                _group('漏网之鱼', ['默认代理']),
                _group('直连', ['DIRECT']),
              ],
            ),
          ),
        ],
      );

      expect((_groupsOf(result).keys).toList(), [
        '默认代理',
        '手动选择',
        '低倍率',
        '高倍率',
        '漏网之鱼',
        '直连',
        '香港',
        '日本',
        '美国',
      ]);
    });

    test('组最多的成员恰好有那些组时，顺序同样正确', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(
              proxies: [_proxy('HK 01', 'hk1.example.com')],
              groups: [
                _group('默认代理', ['手动选择']),
                _group('手动选择', ['HK 01']),
                _group('漏网之鱼', ['默认代理']),
                _group('直连', ['DIRECT']),
              ],
            ),
          ),
          _member(
            id: '2',
            label: 'B',
            config: _overridden(
              proxies: [_proxy('JP 01', 'jp1.example.com')],
              groups: [
                _group('默认代理', ['手动选择']),
                _group('手动选择', ['JP 01']),
                _group('低倍率', ['JP 01']),
                _group('漏网之鱼', ['默认代理']),
                _group('直连', ['DIRECT']),
                _group('香港', ['JP 01']),
              ],
            ),
          ),
        ],
      );

      // B 组更多 → 以它为准；A 没有多出来的组，顺序保持脚本顺序
      expect((_groupsOf(result).keys).toList(), [
        '默认代理',
        '手动选择',
        '低倍率',
        '漏网之鱼',
        '直连',
        '香港',
      ]);
    });

    test('内核直连节点不加前缀且跨成员去重', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(
              proxies: [_directProxy()],
              groups: [_group('直连', ['🇨🇳 直连 | 双栈'])],
            ),
          ),
          _member(
            id: '2',
            label: 'B',
            config: _overridden(
              proxies: [_directProxy()],
              groups: [_group('直连', ['🇨🇳 直连 | 双栈'])],
            ),
          ),
        ],
      );

      expect(_namesOf(result), ['🇨🇳 直连 | 双栈']);
      expect(result.report.duplicateNodeCount, 1);
      expect(_groupsOf(result)['直连']!['proxies'], ['🇨🇳 直连 | 双栈']);
    });

    test('规则与规则集沿用脚本产出，全局项取先出现成员', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(
              proxies: [_proxy('A1', 'a.example.com')],
              extra: {
                'rules': ['MATCH,漏网之鱼', 'RULE-SET,cn,直连'],
                'mixed-port': 7890,
                'tun': {'enable': true},
              },
            ),
          ),
          _member(
            id: '2',
            label: 'B',
            config: _overridden(
              proxies: [_proxy('B1', 'b.example.com')],
              extra: {
                'rules': ['MATCH,漏网之鱼'],
                'mixed-port': 7891,
              },
            ),
          ),
        ],
      );

      expect(result.config['rules'], ['MATCH,漏网之鱼', 'RULE-SET,cn,直连']);
      expect(result.config['mixed-port'], 7890);
      expect(result.config['mode'], 'rule');
      expect((result.config['tun'] as Map)['enable'], isTrue);
      expect(
        (result.config['rule-providers'] as Map).keys.toSet(),
        {'cn'},
      );
    });

    test('逐成员的节点域名 DNS 策略取并集，基础模板沿用先出现成员', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(
              proxies: [_proxy('A1', 'a.example.com')],
              dns: {
                'nameserver': ['1.1.1.1'],
                'proxy-server-nameserver-policy': {
                  'a.example.com': ['192.168.1.1'],
                },
                'fake-ip-filter': ['rule-set:private', 'a.example.com'],
              },
            ),
          ),
          _member(
            id: '2',
            label: 'B',
            config: _overridden(
              proxies: [_proxy('B1', 'b.example.com')],
              dns: {
                'nameserver': ['2.2.2.2'],
                'proxy-server-nameserver-policy': {
                  'b.example.com': ['192.168.2.1'],
                },
                'fake-ip-filter': ['rule-set:private', 'b.example.com'],
              },
            ),
          ),
        ],
      );

      final dns = (result.config['dns'] as Map).cast<String, dynamic>();
      expect(dns['nameserver'], ['1.1.1.1']);
      final policy = (dns['proxy-server-nameserver-policy'] as Map)
          .cast<String, dynamic>();
      expect(policy['a.example.com'], ['192.168.1.1']);
      expect(policy['b.example.com'], ['192.168.2.1']);
      expect(dns['fake-ip-filter'], [
        'rule-set:private',
        'a.example.com',
        'b.example.com',
      ]);
      expect(result.report.dnsPolicyCount, 2);
    });

    test('同一域名被多个成员共用时策略取并集，并给出提示', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(
              proxies: [_proxy('A1', 'shared.example.com')],
              dns: {
                'proxy-server-nameserver-policy': {
                  'shared.example.com': ['192.168.1.1'],
                },
              },
            ),
          ),
          _member(
            id: '2',
            label: 'B',
            config: _overridden(
              proxies: [_proxy('B1', 'shared.example.com')],
              dns: {
                'proxy-server-nameserver-policy': {
                  'shared.example.com': ['192.168.2.1'],
                },
              },
            ),
          ),
        ],
      );

      final policy =
          ((result.config['dns'] as Map)['proxy-server-nameserver-policy']
                  as Map)
              .cast<String, dynamic>();
      // 脚本会把同后缀的域名压成 +.suffix，撞 key 时不能丢掉后出现成员的私有 DNS
      expect(policy['shared.example.com'], ['192.168.1.1', '192.168.2.1']);
      expect(
        result.report.warnings.any((w) => w.code == 'policyConflict'),
        isTrue,
      );
    });

    test('hosts 取并集，冲突时保留先出现的值并给出提示', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(
              proxies: [_proxy('A1', 'a.example.com')],
              hosts: {'same.example.com': '10.0.0.1'},
            ),
          ),
          _member(
            id: '2',
            label: 'B',
            config: _overridden(
              proxies: [_proxy('B1', 'b.example.com')],
              hosts: {'same.example.com': '10.0.0.2', 'only.example.com': '10.0.0.3'},
            ),
          ),
        ],
      );

      final hosts = (result.config['hosts'] as Map).cast<String, dynamic>();
      expect(hosts['same.example.com'], '10.0.0.1');
      expect(hosts['only.example.com'], '10.0.0.3');
      expect(
        result.report.warnings.any((w) => w.code == 'hostConflict'),
        isTrue,
      );
    });

    test('调用方补充的成员级提示并入结果报告', () {
      final result = mergeBundleConfigs(
        members: [
          _member(
            id: '1',
            label: 'A',
            config: _overridden(proxies: [_proxy('A1', 'a.example.com')]),
          ),
        ],
        extraWarnings: const [
          BundleMergeWarning('scriptFailed', member: 'B'),
          BundleMergeWarning('tunnels', member: 'B'),
        ],
      );

      expect(
        result.report.warnings.map((w) => w.code),
        containsAll(['scriptFailed', 'tunnels']),
      );
      expect(result.report.warnings.first.member, 'B');
    });

    test('没有成员时直接抛错', () {
      expect(
        () => mergeBundleConfigs(members: const []),
        throwsArgumentError,
      );
    });

    test('成员指纹把名称计入，改名即视为过期', () {
      final before = bundleMemberStamp(label: '机场A', lastModified: 100);
      expect(bundleMemberStamp(label: '机场A', lastModified: 100), before);
      expect(bundleMemberStamp(label: '机场B', lastModified: 100), isNot(before));
      expect(bundleMemberStamp(label: '机场A', lastModified: 101), isNot(before));
      expect(bundleMemberStamp(label: null, lastModified: 100), isNotNull);
    });

    test('合并结果可以 JSON 往返报告', () {
      final report = BundleMergeReport(
        memberCount: 2,
        nodeCount: 5,
        duplicateNodeCount: 1,
        dnsPolicyCount: 3,
        groupCount: 4,
        warnings: const [BundleMergeWarning('hostConflict', count: 2)],
      );
      final restored = BundleMergeReport.fromJson(report.toJson());
      expect(restored.memberCount, 2);
      expect(restored.dnsPolicyCount, 3);
      expect(restored.groupCount, 4);
      expect(restored.warnings.single.code, 'hostConflict');
      expect(restored.warnings.single.count, 2);
    });
  });

  group('bundleDefaultLabel', () {
    test('两个成员直接用 + 连接', () {
      expect(bundleDefaultLabel(['机场A', '机场B']), '机场A + 机场B');
    });

    test('三个及以上成员全部列出，不再收口成 +N', () {
      expect(
        bundleDefaultLabel(['良心云', '花云', '百变小樱']),
        '良心云 + 花云 + 百变小樱',
      );
      expect(
        bundleDefaultLabel(['A', 'B', 'C', 'D', 'E']),
        'A + B + C + D + E',
      );
    });

    test('单个成员与空列表', () {
      expect(bundleDefaultLabel(['机场A']), '机场A');
      expect(bundleDefaultLabel(const <String>[]), '');
    });
  });
}
