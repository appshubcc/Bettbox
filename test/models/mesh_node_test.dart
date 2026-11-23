import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

ProxyNode _node(String type, {String id = 'node-1'}) => ProxyNode(
  id: id,
  proxy: {'name': 'n', 'type': type},
  bindings: const {
    'profile': NodeBinding(groups: ['Proxy']),
  },
);

void main() {
  test('flags mesh outbound types regardless of case', () {
    for (final type in ['easytier', 'ZeroTier', 'TAILSCALE']) {
      expect(_node(type).isMesh, isTrue, reason: type);
    }
    for (final type in ['ss', 'wireguard', '']) {
      expect(_node(type).isMesh, isFalse, reason: type);
    }
  });

  test('patch carries the node id for stable state directories', () {
    final patch = _node('easytier', id: 'abc').patchOf(
      'profile',
      managed: false,
    );
    expect(patch?['id'], 'abc');
  });

  test('mesh templates cover each supported type with its own name', () {
    expect(meshTemplates.map((item) => item.title), [
      'EasyTier',
      'ZeroTier',
      'Tailscale',
    ]);
    for (final template in meshTemplates) {
      final type = template.title.toLowerCase();
      expect(meshNodeTypes, contains(type));
      expect(template.content, contains('type: $type'));
      expect(template.content, isNot(contains('state-dir')));
    }
  });
}
