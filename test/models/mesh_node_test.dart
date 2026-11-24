import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

ProxyNode _node(String type) =>
    ProxyNode(id: 'node-1', proxy: {'name': 'n', 'type': type});

void main() {
  test('flags mesh outbound types regardless of case', () {
    for (final type in ['easytier', 'ZeroTier', 'TAILSCALE']) {
      expect(_node(type).isMesh, isTrue, reason: type);
    }
    for (final type in ['ss', 'wireguard', '']) {
      expect(_node(type).isMesh, isFalse, reason: type);
    }
  });

  test('import gives each new mesh node its own portable state directory', () {
    for (final type in ['EasyTier', 'ZeroTier', 'TAILSCALE']) {
      final source = {'type': type, 'name': 'mesh'};
      final names = <String>{};
      final first = ProxyNode.fromImport(source, names);
      final second = ProxyNode.fromImport(source, names);
      expect([first.name, second.name], ['mesh', 'mesh 2']);
      expect(first.id, isNot(second.id));
      expect(source.containsKey('state-dir'), isFalse);
      for (final node in [first, second]) {
        expect(
          node.proxy['state-dir'],
          'nodes/${type.toLowerCase()}/${node.id}',
        );
        final renamed = node.withUpdatedProxy({
          ...node.proxy,
          'name': 'renamed',
        }, {});
        expect(renamed.id, node.id);
        expect(renamed.proxy['state-dir'], node.proxy['state-dir']);
        final patch = renamed.patchOf('profile', managed: true)!;
        expect(patch.containsKey('id'), isFalse);
        expect(patch['proxy'], renamed.proxy);
      }
    }
  });

  test(
    'import preserves explicit state directories and skips non-mesh proxies',
    () {
      final explicit = {
        'name': 'mesh',
        'type': 'tailscale',
        'state-dir': 'my/state',
      };
      expect(ProxyNode.fromImport(explicit, {}).proxy, explicit);
      final ordinary = {'name': 'wg', 'type': 'wireguard'};
      expect(ProxyNode.fromImport(ordinary, {}).proxy, ordinary);
    },
  );

  test(
    'loading and editing an old mesh node keeps its implicit state directory',
    () {
      final saved = {
        'id': 'existing',
        'proxy': {'name': 'old', 'type': 'zerotier'},
      };
      final old = ProxyNode.fromJson(saved);
      expect(old.proxy.containsKey('state-dir'), isFalse);
      final edited = old.withUpdatedProxy(
        {...old.proxy, 'name': 'new'},
        {'new'},
      );
      expect(edited.id, old.id);
      expect(edited.name, 'new 2');
      expect(edited.proxy.containsKey('state-dir'), isFalse);
      expect(edited.patchOf('profile', managed: true)!['proxy'], edited.proxy);
    },
  );

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
