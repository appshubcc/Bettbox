import 'dart:convert';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

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

  test('import follows Mihomo state-dir key matching and precedence', () {
    final base = {'name': 'mesh', 'type': 'tailscale'};
    for (final key in ['state-dir', 'state_dir', 'STATE-DIR', 'StAtE_DiR']) {
      final custom = {...base, key: 'my state/path '};
      expect(ProxyNode.fromImport(custom, {}).proxy, {
        ...base,
        'state-dir': 'my state/path ',
      });
      for (final value in [null, '']) {
        final source = {...base, key: value};
        final node = ProxyNode.fromImport(source, {});
        expect(node.proxy, {
          ...base,
          'state-dir': 'nodes/tailscale/${node.id}',
        });
        expect(source[key], value);
      }
    }
    final exact = ProxyNode.fromImport({
      ...base,
      'state_dir': 'ignored',
      'state-dir': 'canonical',
    }, {});
    expect(exact.proxy, {...base, 'state-dir': 'canonical'});
    final empty = ProxyNode.fromImport({
      ...base,
      'state_dir': 'ignored',
      'state-dir': null,
    }, {});
    expect(empty.proxy['state-dir'], 'nodes/tailscale/${empty.id}');
    final unknown = ProxyNode.fromImport({
      ...base,
      'stateDir': 'unrelated',
    }, {});
    expect(unknown.proxy['stateDir'], 'unrelated');
    expect(unknown.proxy['state-dir'], 'nodes/tailscale/${unknown.id}');
  });

  test('only a shared node’s own default is regenerated on reimport', () {
    for (final type in meshNodeTypes) {
      final base = {'name': 'mesh', 'type': type, 'udp': true};
      final owner = ProxyNode.fromImport(base, {});
      final path = owner.proxy['state-dir'];
      // Even an identical UUID-shaped path is an explicit choice on another row.
      final custom = ProxyNode.fromImport({...base, 'state-dir': path}, {});
      final shared = [
        owner,
        custom,
      ].patchOf('p', managed: true, forSharing: true);
      final ownerProxy = shared.first['proxy'] as Map<String, dynamic>;
      expect(ownerProxy, base);
      expect(shared.last['proxy'], custom.proxy);
      final copy = ProxyNode.fromImport(ownerProxy, {owner.name});
      expect(copy.id, isNot(owner.id));
      expect(copy.proxy['state-dir'], 'nodes/$type/${copy.id}');
      expect(owner.patchOf('p', managed: true)!['proxy'], {
        ...base,
        'state-dir': path,
      });

      final saved = jsonDecode(jsonEncode(owner)) as Map<String, dynamic>;
      final restored = ProxyNode.fromJson(saved);
      expect(restored.id, owner.id);
      expect(restored.proxy['state-dir'], path);
      final edited = restored.withUpdatedProxy({
        ...restored.proxy,
        'name': 'edited',
      }, {});
      expect(edited.id, owner.id);
      expect(edited.proxy['state-dir'], path);
    }
  });

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

  testWidgets('localized mesh templates keep optional fields commented', (
    _,
  ) async {
    expect(meshTemplates.map((item) => item.title), [
      'EasyTier',
      'ZeroTier',
      'Tailscale',
    ]);
    for (final template in meshTemplates) {
      final type = template.title.toLowerCase();
      expect(meshNodeTypes, contains(type));
      final english = await template.load('en');
      final chinese = await template.load('zh');
      expect(chinese, isNot(english));
      expect(await template.load('fr'), english);
      final defaults = loadYaml(english) as YamlMap;
      expect(loadYaml(chinese), equals(defaults));
      expect(defaults['type'], type);
      expect(defaults['name'], isNotEmpty);
      expect(defaults.containsKey('state-dir'), isFalse);
      // Translators may change prose, but the editable YAML keys must agree.
      final fields = RegExp(r'^#? *([a-z][a-z0-9-]*):', multiLine: true);
      List<String> keys(String text) =>
          fields.allMatches(text).map((match) => match[1]!).toList();
      expect(keys(chinese), unorderedEquals(keys(english)));
      expect(keys(english), containsAll(['state-dir', 'dialer-proxy', 'udp']));
    }
  });
}
