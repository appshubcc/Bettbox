import 'dart:convert';

import 'package:bett_box/models/clash_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('默认 DNS 不再引用 geosite', () {
    const dns = Dns();

    expect(
      dns.fakeIpFilter.any((item) => item.startsWith('geosite:')),
      isFalse,
    );
    expect(
      dns.nameserverPolicy.keys.any((key) => key.startsWith('geosite:')),
      isFalse,
    );
    expect(dns.fakeIpFilter, contains('rule-set:cn_bettbox'));
    expect(dns.fakeIpFilter, contains('rule-set:fakeip-filter_bettbox'));
    expect(dns.nameserverPolicy['rule-set:cn_bettbox'], '119.29.29.29');
  });

  test('旧默认 geosite 条目迁移为 _bettbox 规则集，其余条目保持不变', () {
    final dns = Dns.safeDnsFromJson({
      'fake-ip-filter': [
        '*',
        'geosite:private',
        'geosite:category-ntp',
        'geosite:geolocation-cn',
        'geosite:connectivity-check',
        'geosite:apple',
        'rule-set:cn_bettbox',
      ],
      'nameserver-policy': {
        '+.corp.com': '10.0.0.1',
        'geosite:cn': '119.29.29.29',
        'geosite:private': 'system',
        'geosite:google': '8.8.8.8',
      },
      'nameserver': ['1.1.1.1'],
    });

    expect(dns.fakeIpFilter, [
      '*',
      'rule-set:private_bettbox',
      'rule-set:fakeip-filter_bettbox',
      'rule-set:category-ntp_bettbox',
      'rule-set:cn_bettbox',
      'rule-set:connectivity-check_bettbox',
      'geosite:apple',
    ]);
    expect(dns.nameserverPolicy, {
      '+.corp.com': '10.0.0.1',
      'rule-set:cn_bettbox': '119.29.29.29',
      'rule-set:private_bettbox': 'system',
      'geosite:google': '8.8.8.8',
    });
    expect(dns.nameserver, ['1.1.1.1']);
  });

  test('从 JSON 文本迁移时保留其他 DNS 字段', () {
    final dns = Dns.safeDnsFromJson(
      jsonDecode(
            jsonEncode({
              'listen': '0.0.0.0:1053',
              'nameserver-policy': {'geosite:cn': '223.5.5.5'},
            }),
          )
          as Map<String, Object?>,
    );

    expect(dns.listen, '0.0.0.0:1053');
    expect(dns.nameserverPolicy, {'rule-set:cn_bettbox': '223.5.5.5'});
  });

  test('没有旧默认条目时原样解析', () {
    final dns = Dns.safeDnsFromJson({
      'fake-ip-filter': ['+.lan'],
      'nameserver-policy': {'geosite:google': '8.8.8.8'},
    });

    expect(dns.fakeIpFilter, ['+.lan']);
    expect(dns.nameserverPolicy, {'geosite:google': '8.8.8.8'});
  });
}
