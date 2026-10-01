import 'package:bett_box/common/profile_merger.dart';
import 'package:bett_box/common/task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

/// 合并结果最终要以 YAML 落盘，这里把「合并 -> 编码 -> 解析」整条链路钉住。
/// 输入是各成员跑过内置覆写脚本之后的完整配置。
void main() {
  test('合并后的完整配置可以编码为合法 YAML 且结构完整', () async {
    final result = mergeBundleConfigs(
      members: [
        BundleMemberConfig(
          id: '1',
          label: '机场A',
          config: {
            'proxies': [
              {
                'name': 'HK 01',
                'type': 'ss',
                'server': 'hk1.example.com',
                'port': 443,
                'cipher': 'aes-128-gcm',
                'password': 'p',
              },
            ],
            'proxy-groups': [
              {
                'name': '香港',
                'type': 'select',
                'proxies': ['HK 01'],
              },
              {
                'name': '默认代理',
                'type': 'select',
                'proxies': ['香港', 'DIRECT'],
              },
            ],
            'rules': ['MATCH,默认代理'],
            'rule-providers': {
              'cn': {'type': 'http', 'url': 'https://example.com/cn.mrs'},
            },
            'mixed-port': 7890,
            'dns': {
              'nameserver': ['1.1.1.1'],
              'proxy-server-nameserver-policy': {
                'hk1.example.com': ['192.168.1.1'],
              },
            },
            'hosts': {'doh.pub': ['1.12.12.12']},
          },
        ),
        BundleMemberConfig(
          id: '2',
          label: '机场B',
          config: {
            'proxies': [
              {
                'name': 'JP 01',
                'type': 'ss',
                'server': 'jp1.example.com',
                'port': 443,
                'cipher': 'aes-128-gcm',
                'password': 'p',
              },
            ],
            'proxy-groups': [
              {
                'name': '日本',
                'type': 'select',
                'proxies': ['JP 01'],
              },
              {
                'name': '默认代理',
                'type': 'select',
                'proxies': ['日本', 'DIRECT'],
              },
            ],
            'rules': ['MATCH,默认代理'],
            'rule-providers': {
              'cn': {'type': 'http', 'url': 'https://example.com/cn.mrs'},
            },
            'mixed-port': 7890,
            'dns': {
              'nameserver': ['1.1.1.1'],
              'proxy-server-nameserver-policy': {
                'jp1.example.com': ['192.168.2.1'],
              },
            },
            'hosts': {'doh.pub': ['1.12.12.12']},
          },
        ),
      ],
    );

    final content = await encodeYamlTask(result.config);
    final yaml = loadYaml(content) as YamlMap;

    expect(yaml.keys, contains('proxies'));
    expect(yaml.keys, contains('proxy-groups'));
    expect(yaml.keys, contains('rules'));

    final proxies = (yaml['proxies'] as YamlList)
        .cast<YamlMap>()
        .map((proxy) => proxy['name'])
        .toList();
    expect(proxies, ['机场A | HK 01', '机场B | JP 01']);

    final groups = {
      for (final group in (yaml['proxy-groups'] as YamlList).cast<YamlMap>())
        group['name'] as String: (group['proxies'] as YamlList).toList(),
    };
    // 同名策略组按「先出现优先」取并集，节点引用已跟随改名
    expect(groups['香港'], ['机场A | HK 01']);
    expect(groups['日本'], ['机场B | JP 01']);
    expect(groups['默认代理'], ['香港', 'DIRECT', '日本']);

    expect((yaml['rules'] as YamlList).toList(), ['MATCH,默认代理']);

    final dns = yaml['dns'] as YamlMap;
    expect(dns['nameserver'], ['1.1.1.1']);
    final policy = (dns['proxy-server-nameserver-policy'] as YamlMap).cast<
      String,
      dynamic
    >();
    expect(policy['hk1.example.com'], ['192.168.1.1']);
    expect(policy['jp1.example.com'], ['192.168.2.1']);

    final hosts = yaml['hosts'] as YamlMap;
    expect(hosts['doh.pub'], ['1.12.12.12']);
    expect(yaml['mixed-port'], 7890);
  });
}
