import 'dart:convert';

import 'package:bett_box/clash/core.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final proxies = json.encode({
    'names': ['Main', 'Auto', 'A', 'B', 'DIRECT', 'Remote'],
    'types': [
      'Selector',
      'URLTest',
      'Shadowsocks',
      'Trojan',
      'Direct',
      'Vless',
    ],
    'groups': [
      {
        'name': 'GLOBAL',
        'type': 'Selector',
        'now': 'Main',
        'all': [0, 1, 2, 3],
      },
      {
        'name': 'Main',
        'type': 'Selector',
        'now': 'Auto',
        'all': [1, 2, 3, 4],
      },
      {
        'name': 'Auto',
        'type': 'URLTest',
        'now': 'A',
        'all': [2, 3, 5, 99],
        'testUrl': 'https://example.com/204',
        'hidden': true,
        'icon': 'auto.png',
      },
      {
        'name': 'Chain',
        'type': 'Relay',
        'all': [2],
      },
    ],
  });

  test('keeps the core order and shares proxy instances', () {
    final groups = buildGroups(proxies);

    expect(groups.map((group) => group.name), ['GLOBAL', 'Main', 'Auto']);
    final main = groups[1];
    expect(main.type, GroupType.Selector);
    expect(main.now, 'Auto');
    expect(main.all.map((proxy) => proxy.name), ['Auto', 'A', 'B', 'DIRECT']);
    expect(
      main.all.first,
      const Proxy(name: 'Auto', type: 'URLTest', now: 'A'),
    );
    final auto = groups[2];
    expect(auto.testUrl, 'https://example.com/204');
    expect(auto.hidden, isTrue);
    expect(auto.icon, 'auto.png');
    expect(auto.all.map((proxy) => proxy.name), ['A', 'B', 'Remote']);
    expect(auto.all.last, const Proxy(name: 'Remote', type: 'Vless'));
    expect(identical(main.all[1], auto.all[0]), isTrue);
  });

  test('returns nothing for an empty payload', () {
    expect(buildGroups('{}'), isEmpty);
    expect(buildGroups('null'), isEmpty);
  });
}
