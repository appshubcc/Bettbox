import 'dart:convert';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundle prefix takes two Han characters or the first word', () {
    expect(bundlePrefixOf('花云机场'), '花云');
    expect(bundlePrefixOf('🇭🇰 一元机场 Pro'), '一元');
    expect(bundlePrefixOf('云'), '云');
    expect(bundlePrefixOf('Nexitally Pro'), 'Nexitally');
    expect(bundlePrefixOf('TAG-Cloud'), 'TAG');
    expect(bundlePrefixOf('  [Dler] Cloud'), 'Dler');
    expect(bundlePrefixOf('sub.example.com'), 'sub');
    expect(bundlePrefixOf('Pro花云'), 'Pro');
    expect(bundlePrefixOf('🚀'), '🚀');
    expect(bundlePrefixOf(''), '');
  });

  test('route icons match exactly, then by trimmed names', () {
    final index = routeIconIndex([
      'YouTube.svg',
      'Google.svg',
      'Steam.svg',
      'Bilibili.svg',
      'Microsoft.svg',
      'RiotJs.svg',
      'Ubisoft.svg',
    ]);
    expect(matchRouteIcon('youtube', index), 'YouTube.svg');
    expect(matchRouteIcon('You Tube', index), 'YouTube.svg');
    expect(matchRouteIcon('google@cn', index), 'Google.svg');
    expect(matchRouteIcon('category-games', index), null);
    expect(matchRouteIcon('steam-cn', index), 'Steam.svg');
    expect(matchRouteIcon('bilibili-game', index), 'Bilibili.svg');
    expect(matchRouteIcon('microsoft-dev-cdn', index), 'Microsoft.svg');
    expect(matchRouteIcon('google-deepmind', index), 'Google.svg');
    expect(matchRouteIcon('ubisoft2', index), 'Ubisoft.svg');
    expect(matchRouteIcon('riot', index), null);
    expect(matchRouteIcon('', index), null);
  });

  test('route icons resolve to Qure paths and bundled assets', () async {
    const base =
        'https://cdn.jsdelivr.net/gh/appshubcc/Qure_Style_SVG@main/icon/svg/';
    expect(routeIconUrl('YouTube.svg'), '${base}common/YouTube.svg');
    expect(routeIconUrl('flag/Japan.svg'), '${base}flag/Japan.svg');
    expect(
      routeIconUrl('Apple_Fitness+.svg'),
      '${base}common/Apple_Fitness%2B.svg',
    );
    expect(routeIconUrl(''), null);
    final index = routeIconIndex(['flag/Hong_Kong.svg', 'common/X.svg']);
    expect(matchRouteIcon('hong-kong', index), 'flag/Hong_Kong.svg');
    await loadBundledRouteIcons();
    expect(
      routeIconAsset(routeIconUrl('YouTube.svg')),
      'assets/route_svg/YouTube.svg',
    );
    expect(
      routeIconAsset(routeIconUrl('flag/Japan.svg')),
      'assets/route_svg/Japan.svg',
    );
    expect(routeIconAsset('https://example.com/YouTube.svg'), null);
  });

  test('route catalog entries point to the bundled rule sets', () async {
    final index = await ManagedScript.catalog(const ManagedProps());
    final catalog = index.catalog;
    final icons = catalog.icons.toSet();
    expect(catalog.sets, isNotEmpty);
    expect(index.sets.length, catalog.sets.length);
    expect(catalog.targets.first, '默认代理');
    expect(catalog.sets.map((set) => set.type).toSet(), {'geosite', 'geoip'});
    for (final set in catalog.sets) {
      expect(set.name, isNot(set.tag));
      final icon = set.icon;
      if (icon != null) expect(icons.contains(icon), isTrue);
    }
    expect(catalog.services, isNotEmpty);
    final names = <String>{};
    final reserved = catalog.reserved.toSet();
    for (final service in catalog.services) {
      expect(names.add(service.name), isTrue, reason: service.name);
      expect(reserved.contains(service.name), isFalse, reason: service.name);
      expect(service.sets, isNotEmpty, reason: service.name);
      for (final key in service.sets) {
        expect(index.sets.containsKey(key), isTrue, reason: key);
      }
      final icon = service.icon;
      if (icon != null) expect(icons.contains(icon), isTrue, reason: icon);
    }
  });

  test('icon set picks map back to catalog names', () async {
    final index = await ManagedScript.catalog(const ManagedProps());
    final iconSet = routeIconSet(index.catalog);
    expect(iconSet.icons.length, index.catalog.icons.length);
    for (final icon in iconSet.icons.take(50)) {
      expect(routeIconValue(icon.url), icon.name);
    }
    expect(
      routeIconValue(routeIconUrl('Apple_Fitness+.svg')!),
      'Apple_Fitness+.svg',
    );
    expect(
      routeIconValue('https://example.com/a.svg'),
      'https://example.com/a.svg',
    );
    CustomRoute route(String? icon) =>
        CustomRoute(id: 'x', name: 'Riot', icon: icon, sets: const []);
    expect(index.iconOf(route('flag/Japan.svg')), 'flag/Japan.svg');
    expect(index.iconOf(route('World_Map.svg')), 'WorldMap.svg');
    expect(index.iconOf(route('Riot_Games.svg')), 'RiotGames.svg');
    expect(index.iconOf(route('')), null);
    expect(index.iconOf(route('https://a.com/b.svg')), 'https://a.com/b.svg');
  });

  test('custom groups sit before AdBlock and follow the saved order', () {
    const presets = ['FCM', 'YouTube', 'Google', 'AdBlock'];
    expect(
      orderManagedGroups(presets: presets, customs: ['A', 'B'], saved: []),
      ['FCM', 'YouTube', 'Google', 'A', 'B', 'AdBlock'],
    );
    expect(
      orderManagedGroups(
        presets: const ['FCM', 'YouTube'],
        customs: ['A'],
        saved: [],
      ),
      ['FCM', 'YouTube', 'A'],
    );
    expect(
      orderManagedGroups(
        presets: presets,
        customs: ['A', 'B'],
        saved: ['AdBlock', 'B', 'FCM', 'Gone', 'Google', 'A'],
      ),
      ['AdBlock', 'B', 'FCM', 'YouTube', 'Google', 'A'],
    );
    expect(
      orderManagedGroups(
        presets: const ['FCM', 'New', 'YouTube', 'AdBlock'],
        customs: [],
        saved: ['YouTube', 'FCM', 'AdBlock'],
      ),
      ['YouTube', 'FCM', 'New', 'AdBlock'],
    );
  });

  test('enabled routes are injected before the managed script', () async {
    const props = ManagedProps();
    final plain = await ManagedScript.script(props);
    final routed = await ManagedScript.script(
      props.copyWith(
        routes: const [
          CustomRoute(
            id: 'a',
            name: 'Date',
            sets: [
              'geosite:youtube',
              'ipcidr:https://example.com/rules/netflix_ip.mrs?raw=1',
              'domain:https://example.com/规则/流媒体.mrs',
              'geoip:netflix',
            ],
            target: '美国',
          ),
          CustomRoute(
            id: 'b',
            name: 'Off',
            sets: ['geosite:google'],
            enabled: false,
          ),
          CustomRoute(id: 'c', name: 'Empty'),
          CustomRoute(
            id: 'd',
            name: 'Plain',
            icon: '',
            sets: ['geosite:steam'],
          ),
        ],
      ),
    );
    expect(routed.content.endsWith(plain.content), isTrue);
    expect(routed.digest, isNot(plain.digest));
    expect(routed.volatile, isFalse);
    final prelude = routed.content.substring(
      0,
      routed.content.length - plain.content.length,
    );
    expect(prelude.startsWith('const bettboxRoutes = '), isTrue);
    final routes =
        jsonDecode(prelude.substring(22, prelude.length - 2)) as List;
    expect(routes.length, 2);
    final first = routes.first as Map;
    expect(first['name'], 'Date');
    expect(first['target'], '美国');
    expect((first['icon'] as String).endsWith('/YouTube.svg'), isTrue);
    expect(first['sets'], [
      {'type': 'geosite', 'tag': 'youtube'},
      {
        'type': 'geoip',
        'tag': 'netflix_ip',
        'url': 'https://example.com/rules/netflix_ip.mrs?raw=1',
        'format': 'mrs',
      },
      {
        'type': 'geosite',
        'tag': '流媒体',
        'url': 'https://example.com/规则/流媒体.mrs',
        'format': 'mrs',
      },
      {'type': 'geoip', 'tag': 'netflix'},
    ]);
    final last = routes.last as Map;
    expect(last.containsKey('icon'), isFalse);
    expect(last.containsKey('target'), isFalse);
  });

  test('custom rule set links are parsed and validated', () {
    expect(CustomRuleSet.isValidUrl('https://a.com/x/google.mrs'), isTrue);
    expect(CustomRuleSet.isValidUrl(' http://a.com/x.MRS?v=1 '), isTrue);
    expect(CustomRuleSet.isValidUrl('https://a.com/x.yaml'), isTrue);
    expect(CustomRuleSet.isValidUrl('https://a.com/rules?id=1'), isTrue);
    expect(CustomRuleSet.isValidUrl('ftp://a.com/x.mrs'), isFalse);
    expect(CustomRuleSet.isValidUrl('a.com/x.mrs'), isFalse);
    expect(
      CustomRuleSet.guessBehavior('https://a.com/geo/geoip/cn.mrs'),
      'ipcidr',
    );
    expect(CustomRuleSet.guessBehavior('https://a.com/r/cn_ip.mrs'), 'ipcidr');
    expect(CustomRuleSet.guessBehavior('https://ip.com/r/skip.mrs'), 'domain');
    expect(
      CustomRuleSet.guessBehavior('https://a.com/r/whatsapp.mrs'),
      'domain',
    );
    final custom = CustomRuleSet.parse('ipcidr:https://a.com/r/my list.mrs');
    expect(custom?.ip, isTrue);
    expect(custom?.url, 'https://a.com/r/my list.mrs');
    expect(custom?.name, 'my list');
    expect(custom?.tag, 'my_list');
    expect(custom?.key, 'ipcidr:https://a.com/r/my list.mrs');
    expect(CustomRuleSet.parse('geosite:google'), isNull);
    expect(
      const CustomRuleSet(
        behavior: 'domain',
        url: 'https://a.com/r/ai.mrs',
      ).format,
      'mrs',
    );
    const yaml = CustomRuleSet(
      behavior: 'domain',
      url: 'https://a.com/r/ai.YML',
    );
    expect(yaml.format, 'yaml');
    expect(yaml.name, 'ai');
    const text = CustomRuleSet(
      behavior: 'ipcidr',
      url: 'https://a.com/r/cn.list',
    );
    expect(text.format, 'text');
    expect(text.name, 'cn');
    expect(
      const CustomRuleSet(
        behavior: 'domain',
        url: 'https://a.com/r/x?y=1',
      ).format,
      'text',
    );
    expect(CustomRuleSet.parse('domain:https://a.com/.mrs')?.tag, 'a_com');
  });

  test('group order is injected only when saved', () async {
    const props = ManagedProps();
    final plain = await ManagedScript.script(props);
    expect(plain.content.contains('const bettboxOrder'), isFalse);
    final ordered = await ManagedScript.script(
      props.copyWith(order: const ['AdBlock', 'FCM']),
    );
    expect(ordered.content.endsWith(plain.content), isTrue);
    expect(ordered.digest, isNot(plain.digest));
    expect(
      ordered.content.startsWith('const bettboxOrder = ["AdBlock","FCM"];\n'),
      isTrue,
    );
  });

  test(
    'regions default to the preset ones and are injected when chosen',
    () async {
      final catalog = (await ManagedScript.catalog(
        const ManagedProps(),
      )).catalog;
      expect(managedRegions(catalog, null), ['香港', '日本', '美国', '新加坡', '台湾']);
      expect(managedRegions(catalog, const ['日本', '韩国', 'Gone']), ['日本', '韩国']);
      expect(
        managedRegions(
          catalog,
          null,
          const [CustomRegion(name: '德国', regex: '德国|DE')],
        ),
        ['香港', '日本', '美国', '新加坡', '台湾', '德国'],
      );
      expect(
        managedRegions(
          catalog,
          const ['韩国', '德国'],
          const [CustomRegion(name: '德国', regex: '德国|DE')],
        ),
        ['韩国', '德国'],
      );
      for (final region in catalog.regions) {
        expect(
          catalog.reserved,
          containsAll([region.name, '${region.name}-自动选择']),
        );
        expect(catalog.targets, contains(region.name));
        expect(routeIconAsset(routeIconUrl(region.icon)), isNotNull);
      }

      const props = ManagedProps();
      final plain = await ManagedScript.script(props);
      expect(plain.content.contains('const bettboxRegions'), isFalse);
      expect(plain.content.contains('const bettboxCustomRegions'), isFalse);
      final chosen = await ManagedScript.script(
        props.copyWith(regions: const ['香港', '韩国']),
      );
      expect(chosen.content.endsWith(plain.content), isTrue);
      expect(
        chosen.content.startsWith('const bettboxRegions = ["香港","韩国"];\n'),
        isTrue,
      );
      final withCustom = await ManagedScript.script(
        props.copyWith(
          customRegions: const [CustomRegion(name: '德国', regex: '德国|DE')],
        ),
      );
      expect(withCustom.content.contains('const bettboxCustomRegions'), isTrue);
    },
  );

  test('regions join the saved group order', () {
    const presets = ['AI', 'YouTube', 'AdBlock'];
    expect(
      orderManagedGroups(
        presets: presets,
        customs: ['A'],
        saved: [],
        regions: ['香港', '韩国'],
      ),
      ['AI', 'YouTube', 'A', 'AdBlock', '香港', '韩国'],
    );
    expect(
      orderManagedGroups(
        presets: presets,
        customs: [],
        saved: ['韩国', 'AI', 'YouTube', 'AdBlock', '香港'],
        regions: ['香港', '韩国', '英国'],
      ),
      ['韩国', '英国', 'AI', 'YouTube', 'AdBlock', '香港'],
    );
  });

  test('remote links go through the jsDelivr mirror', () {
    expect(
      mirrorUrl('https://raw.githubusercontent.com/a/b/main/icons/x.svg'),
      'https://cdn.jsdelivr.net/gh/a/b@main/icons/x.svg',
    );
    expect(
      mirrorUrl('https://raw.githubusercontent.com/a/b/refs/heads/dev/x.mrs'),
      'https://cdn.jsdelivr.net/gh/a/b@dev/x.mrs',
    );
    expect(
      mirrorUrl('https://github.com/a/b/blob/main/rules/x.mrs'),
      'https://cdn.jsdelivr.net/gh/a/b@main/rules/x.mrs',
    );
    expect(
      mirrorUrl('https://cdn.jsdelivr.net/gh/a/b@main/x.svg'),
      'https://cdn.jsdelivr.net/gh/a/b@main/x.svg',
    );
    expect(
      mirrorUrl('https://cdn.jsdmirror.com/gh/a/b@main/x.svg'),
      'https://cdn.jsdelivr.net/gh/a/b@main/x.svg',
    );
    expect(
      mirrorUrl('https://example.com/icon.svg'),
      'https://example.com/icon.svg',
    );
    expect(mirrorUrl('https://github.com/a/b'), 'https://github.com/a/b');
    expect(
      routeIconUrl('https://raw.githubusercontent.com/a/b/main/x.svg'),
      'https://cdn.jsdelivr.net/gh/a/b@main/x.svg',
    );
  });

  test('custom managed script version and raw override are tracked', () async {
    await ManagedScript.loadBundledVersion();
    expect(ManagedScript.bundledVersion, isNotEmpty);
    const customProps = ManagedProps(syncedVersion: 'custom:12345678');
    expect(ManagedScript.isCustom(customProps), isTrue);
    expect(ManagedScript.syncedVersion(customProps), 'custom:12345678');
    expect(ManagedScript.version(customProps), 'custom:12345678');

    const defaultProps = ManagedProps();
    expect(ManagedScript.isCustom(defaultProps), isFalse);
    expect(ManagedScript.syncedVersion(defaultProps), isNull);

    final rawScript = await ManagedScript.script(
      defaultProps.copyWith(order: const ['AdBlock', 'FCM']),
      raw: 'function main(config) { return config; }',
    );
    expect(
      rawScript.content,
      'const bettboxOrder = ["AdBlock","FCM"];\nfunction main(config) { return config; }',
    );
  });

  test('version comparison compares numerically when numbers', () {
    expect(ManagedScript.compareVersions('99', '100'), lessThan(0));
    expect(ManagedScript.compareVersions('100', '99'), greaterThan(0));
    expect(ManagedScript.compareVersions('20241012', '2026111105'), lessThan(0));
    expect(ManagedScript.compareVersions('2026111105', '2026111105'), 0);
    expect(ManagedScript.compareVersions('beta', 'alpha'), greaterThan(0));

    const olderProps = ManagedProps(syncedVersion: '99');
    expect(ManagedScript.syncedVersion(olderProps), isNull);
  });
}
