import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';

Proxy _proxy(String name, {String? now}) =>
    Proxy(name: name, type: 'Shadowsocks', now: now);

void main() {
  setUp(() {
    globalState.appState = AppState(
      brightness: Brightness.light,
      version: 0,
      viewSize: Size.zero,
      requests: FixedList(maxLength),
      logs: FixedList(maxLogLength),
      traffics: FixedList(30),
      totalTraffic: Traffic(),
      systemUiOverlayStyle: const SystemUiOverlayStyle(),
    );
  });

  group('sortProxies', () {
    final proxies = [
      _proxy('c'),
      _proxy('a'),
      _proxy('b'),
      _proxy('d'),
      _proxy('e'),
    ];

    test('none 原样返回', () {
      expect(sortProxies(proxies, ProxiesSortType.none), same(proxies));
    });

    test('按延迟排序，超时和未测速排在最后且保持原有顺序', () {
      final delays = {'c': 300, 'a': -1, 'b': 100, 'd': null, 'e': 100};
      final sorted = sortProxies(
        proxies,
        ProxiesSortType.delay,
        delayOf: (name) => delays[name],
      );
      expect(sorted.map((proxy) => proxy.name), ['b', 'e', 'c', 'a', 'd']);
    });

    test('按名称排序', () {
      final sorted = sortProxies(proxies, ProxiesSortType.name);
      expect(sorted.map((proxy) => proxy.name), ['a', 'b', 'c', 'd', 'e']);
    });
  });

  test('sortByChar 逐字符比较，较短的前缀排在前面', () {
    expect(utils.sortByChar('', ''), 0);
    expect(utils.sortByChar('', 'a'), -1);
    expect(utils.sortByChar('a', ''), 1);
    expect(utils.sortByChar('a', 'ab'), -1);
    expect(utils.sortByChar('ab', 'a'), 1);
    expect(utils.sortByChar('abc', 'abd'), lessThan(0));
    expect(utils.sortByChar('B', 'a'), greaterThan(0));
  });

  group('DelayDataSource 批量合并', () {
    test('多条结果合并为一次通知，且不改动旧状态', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      var notifyCount = 0;
      container.listen(
        delayDataSourceProvider,
        (_, _) => notifyCount++,
        fireImmediately: false,
      );
      final notifier = container.read(delayDataSourceProvider.notifier);
      notifier.setDelay(const Delay(url: 'u', name: 'a', value: 0));
      notifier.flush();
      final before = container.read(delayDataSourceProvider);
      expect(notifyCount, 1);

      notifier.setDelay(const Delay(url: 'u', name: 'a', value: 120));
      notifier.setDelay(const Delay(url: 'u', name: 'b', value: 80));
      notifier.setDelay(const Delay(url: 'v', name: 'a', value: -1));
      expect(notifyCount, 1);

      notifier.flush();
      expect(notifyCount, 2);
      expect(container.read(delayDataSourceProvider), {
        'u': {'a': 120, 'b': 80},
        'v': {'a': -1},
      });
      expect(before, {
        'u': {'a': 0},
      });
    });

    test('无变化的结果不触发通知', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      var notifyCount = 0;
      container.listen(delayDataSourceProvider, (_, _) => notifyCount++);
      final notifier = container.read(delayDataSourceProvider.notifier);
      notifier.setDelay(const Delay(url: 'u', name: 'a', value: 50));
      notifier.flush();
      notifier.setDelay(const Delay(url: 'u', name: 'a', value: 50));
      notifier.flush();
      expect(notifyCount, 1);
    });

    test('到时自动写入', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(delayDataSourceProvider, (_, _) {});
      container
          .read(delayDataSourceProvider.notifier)
          .setDelay(const Delay(url: 'u', name: 'a', value: 42));
      expect(container.read(delayDataSourceProvider)['u']?['a'], isNull);
      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(container.read(delayDataSourceProvider)['u']?['a'], 42);
    });

    test('测试中标记立即生效，同一批只通知一次，结果仍按批写入', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      var notifyCount = 0;
      container.listen(delayDataSourceProvider, (_, _) => notifyCount++);
      final notifier = container.read(delayDataSourceProvider.notifier);

      notifier
        ..setDelay(const Delay(url: 'u', name: 'a', value: 0))
        ..setDelay(const Delay(url: 'u', name: 'b', value: 0));
      await Future<void>.delayed(Duration.zero);
      expect(container.read(delayDataSourceProvider)['u'], {'a': 0, 'b': 0});
      expect(notifyCount, 1);

      notifier.setDelay(const Delay(url: 'u', name: 'a', value: 42));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(container.read(delayDataSourceProvider)['u']?['a'], 0);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(container.read(delayDataSourceProvider)['u']?['a'], 42);
      expect(notifyCount, 2);
    });

    test('provider 释放时未写入的结果不会丢失', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(delayDataSourceProvider, (_, _) {});
      container
          .read(delayDataSourceProvider.notifier)
          .setDelay(const Delay(url: 'u', name: 'a', value: 7));
      subscription.close();
      await container.pump();
      expect(globalState.appState.delayMap['u']?['a'], 7);
    });
  });

  group('节点解析与索引', () {
    ProxyCardState legacyResolve(
      List<Group> groups,
      SelectedMap selectedMap,
      ProxyCardState state,
    ) {
      if (state.proxyName.isEmpty) return state;
      final index = groups.indexWhere(
        (element) => element.name == state.proxyName,
      );
      if (index == -1) {
        Proxy? proxy;
        for (final group in groups) {
          for (final p in group.all) {
            if (p.name == state.proxyName) {
              proxy = p;
              break;
            }
          }
          if (proxy != null) break;
        }
        final now = proxy?.now;
        if (proxy != null &&
            proxy.type.toUpperCase() == 'REMATCH' &&
            now != null &&
            now.isNotEmpty &&
            now != state.proxyName) {
          return legacyResolve(
            groups,
            selectedMap,
            state.copyWith(proxyName: now),
          );
        }
        return state;
      }
      final group = groups[index];
      final currentSelectedName = group.getCurrentSelectedName(
        selectedMap[state.proxyName] ?? '',
      );
      if (currentSelectedName.isEmpty) return state;
      return legacyResolve(
        groups,
        selectedMap,
        state.copyWith(proxyName: currentSelectedName, testUrl: group.testUrl),
      );
    }

    test('与旧实现结果一致：嵌套分组、自动选择、REMATCH、未知节点', () {
      final groups = [
        Group(
          type: GroupType.Selector,
          name: 'PROXY',
          now: 'a',
          testUrl: 'http://proxy',
          all: [
            _proxy('AUTO'),
            _proxy('a'),
            const Proxy(name: 'r', type: 'Rematch', now: 'b'),
            const Proxy(name: 'self', type: 'REMATCH', now: 'self'),
            const Proxy(name: 'idle', type: 'rematch'),
          ],
        ),
        Group(
          type: GroupType.URLTest,
          name: 'AUTO',
          now: 'b',
          testUrl: 'http://auto',
          all: [_proxy('a'), _proxy('b')],
        ),
        Group(type: GroupType.Selector, name: 'EMPTY', all: [_proxy('a')]),
        Group(type: GroupType.Selector, name: 'PROXY', now: 'b', all: const []),
      ];
      for (final selectedMap in <SelectedMap>[
        {},
        {'PROXY': 'AUTO'},
        {'PROXY': 'r', 'AUTO': 'a'},
        {'PROXY': 'missing'},
      ]) {
        for (final name in [
          'PROXY',
          'AUTO',
          'EMPTY',
          'a',
          'b',
          'r',
          'self',
          'idle',
          'missing',
          '',
        ]) {
          expect(
            resolveProxyCardState(
              groups,
              selectedMap,
              ProxyCardState(proxyName: name),
            ),
            legacyResolve(groups, selectedMap, ProxyCardState(proxyName: name)),
            reason: '$name @ $selectedMap',
          );
        }
      }
      expect(groups.getGroup('PROXY')?.now, 'a');
      expect(groups.getRematchProxy('r')?.now, 'b');
      expect(groups.getRematchProxy('a'), isNull);
    });

    test('9000 节点下逐个解析不再随节点数平方增长', () {
      final nodes = [for (var i = 0; i < 9000; i++) _proxy('node-$i')];
      final groups = [
        for (var i = 0; i < 12; i++)
          Group(type: GroupType.Selector, name: 'G$i', all: nodes),
      ];
      final stopwatch = Stopwatch()..start();
      for (final node in nodes) {
        resolveProxyCardState(groups, {}, ProxyCardState(proxyName: node.name));
      }
      final delayOf = createDelayLookup(
        groups: groups,
        selectedMap: {},
        delayMap: {
          'u': {for (var i = 0; i < 9000; i++) 'node-$i': 9000 - i},
        },
        overrideTestUrl: true,
        defaultTestUrl: 'u',
      );
      final sorted = sortProxies(
        nodes,
        ProxiesSortType.delay,
        delayOf: (name) => delayOf(name, null),
      );
      stopwatch.stop();
      expect(sorted.first.name, 'node-8999');
      expect(stopwatch.elapsedMilliseconds, lessThan(300));
    });
  });

  group('按需排序', () {
    test('只排序展开的分组，展开其他分组不重排已排好的', () {
      globalState.config = Config(
        themeProps: defaultThemeProps,
        currentProfileId: 'p',
        profiles: [
          Profile(id: 'p', autoUpdateDuration: Duration.zero, unfoldSet: {'A'}),
        ],
        proxiesStyle: const ProxiesStyle(sortType: ProxiesSortType.name),
      );
      final container = ProviderContainer(
        overrides: [
          currentGroupsStateProvider.overrideWith(
            (ref) => GroupsState(
              value: [
                Group(
                  type: GroupType.Selector,
                  name: 'A',
                  all: [_proxy('c'), _proxy('a'), _proxy('b')],
                ),
                Group(
                  type: GroupType.Selector,
                  name: 'B',
                  all: [_proxy('z'), _proxy('y')],
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(sortedGroupsStateProvider(''), (_, _) {});

      List<String> names(String group) => [
        for (final proxy
            in container
                    .read(sortedGroupsStateProvider(''))
                    .value
                    .getGroup(group)
                    ?.all ??
                const <Proxy>[])
          proxy.name,
      ];

      expect(names('A'), ['a', 'b', 'c']);
      expect(names('B'), ['z', 'y']);
      final sortedA = container.read(sortedGroupProxiesProvider('', 'A'));

      container
          .read(profilesProvider.notifier)
          .setProfile(
            globalState.config.profiles.single.copyWith(unfoldSet: {'A', 'B'}),
          );
      expect(names('B'), ['y', 'z']);
      expect(
        identical(container.read(sortedGroupProxiesProvider('', 'A')), sortedA),
        isTrue,
      );
    });
  });

  group('后台排序', () {
    List<Proxy> nodes(int count) => [
      for (var i = count - 1; i >= 0; i--)
        _proxy('${String.fromCharCode(97 + i % 26)}$i'),
    ];

    ProviderContainer createContainer(StateProvider<List<Group>> source) {
      globalState.config = Config(
        themeProps: defaultThemeProps,
        proxiesStyle: const ProxiesStyle(sortType: ProxiesSortType.name),
      );
      final container = ProviderContainer(
        overrides: [
          currentGroupsStateProvider.overrideWith(
            (ref) => GroupsState(value: ref.watch(source)),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    Future<List<Proxy>> settled(
      ProviderContainer container,
      String query,
      String group,
    ) async {
      final provider = sortedGroupProxiesProvider(query, group);
      for (var i = 0; i < 200; i++) {
        final value = container.read(provider);
        if (value != null &&
            value.isNotEmpty &&
            value.first.name.startsWith('a') &&
            value.last.name.startsWith('z')) {
          return value;
        }
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      fail('sort did not settle');
    }

    test('大分组首次排序在后台完成，结果与同步排序一致', () async {
      final all = nodes(backgroundSortThreshold + 200);
      final source = StateProvider<List<Group>>(
        (_) => [Group(type: GroupType.Selector, name: 'BG1', all: all)],
      );
      final container = createContainer(source);
      final provider = sortedGroupProxiesProvider('', 'BG1');
      container.listen(provider, (_, _) {});

      expect(container.read(provider), isNull);
      final sorted = await settled(container, '', 'BG1');
      expect(sorted, sortProxies(all, ProxiesSortType.name));
    });

    test('分组刷新后先沿用上次顺序，不出现空白', () async {
      final source = StateProvider<List<Group>>(
        (_) => [
          Group(
            type: GroupType.Selector,
            name: 'BG2',
            all: nodes(backgroundSortThreshold + 200),
          ),
        ],
      );
      final container = createContainer(source);
      final provider = sortedGroupProxiesProvider('', 'BG2');
      container.listen(provider, (_, _) {});
      container.read(provider);
      final first = await settled(container, '', 'BG2');

      final refreshed = [
        for (final proxy in nodes(backgroundSortThreshold + 200))
          proxy.copyWith(type: 'Vmess'),
      ];
      container.read(source.notifier).state = [
        Group(type: GroupType.Selector, name: 'BG2', all: refreshed),
      ];
      final pending = container.read(provider);
      expect(pending, isNotNull);
      expect(
        [for (final proxy in pending!) proxy.name],
        [for (final proxy in first) proxy.name],
      );
      expect(pending.first.type, 'Vmess');

      final other = createContainer(source);
      expect(other.read(sortedGroupProxiesProvider('', 'BG2')), isNotNull);
    });

    test('搜索结果同步排序，小分组同步排序', () {
      final source = StateProvider<List<Group>>(
        (_) => [
          Group(
            type: GroupType.Selector,
            name: 'BG3',
            all: nodes(backgroundSortThreshold * 3),
          ),
          Group(type: GroupType.Selector, name: 'SMALL', all: nodes(50)),
        ],
      );
      final container = createContainer(source);
      final searched = container.read(sortedGroupProxiesProvider('1', 'BG3'));
      expect(searched, isNotNull);
      expect(searched!.length, greaterThanOrEqualTo(backgroundSortThreshold));
      expect(searched.first.name, startsWith('a'));
      expect(searched.last.name, startsWith('z'));
      final small = container.read(sortedGroupProxiesProvider('', 'SMALL'));
      expect(small!.first.name, startsWith('a'));
      expect(small.last.name, startsWith('z'));
    });
  });

  group('hideTimeoutProxies', () {
    const url = 'https://test';
    final groups = [
      Group(
        type: GroupType.Selector,
        name: 'G',
        now: 'a',
        all: [
          _proxy('a'),
          _proxy('b'),
          _proxy('c'),
          _proxy('d'),
          const Proxy(name: 'REJECT', type: 'Reject'),
        ],
      ),
      Group(
        type: GroupType.Selector,
        name: 'H',
        all: [_proxy('a'), _proxy('b')],
      ),
    ];

    List<String> visible(DelayMap delayMap, {String group = 'G'}) =>
        hideTimeoutProxies(
          groups: groups,
          allGroups: groups,
          selectedMap: const {},
          delayMap: delayMap,
          overrideTestUrl: false,
          defaultTestUrl: url,
        ).getGroup(group)!.all.map((proxy) => proxy.name).toList();

    test('隐藏超时节点，保留当前选中、未测速与不可测速类型', () {
      expect(
        visible({
          url: {'a': -1, 'b': -1, 'c': 120, 'REJECT': -1},
        }),
        ['a', 'c', 'd', 'REJECT'],
      );
    });

    test('整组都超时时保持原样', () {
      expect(
        visible({
          url: {'a': -1, 'b': -1},
        }, group: 'H'),
        ['a', 'b'],
      );
    });
  });

  group('filterGroupsState 剥离 now', () {
    test('只有 now 变化时不通知，节点变化时通知', () {
      final source = StateProvider<List<Group>>(
        (_) => [
          Group(
            type: GroupType.Selector,
            name: 'g',
            now: 'a',
            all: [
              _proxy('a'),
              _proxy('b', now: 'x'),
            ],
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          currentGroupsStateProvider.overrideWith(
            (ref) => GroupsState(value: ref.watch(source)),
          ),
        ],
      );
      addTearDown(container.dispose);
      var notifyCount = 0;
      container.listen(filterGroupsStateProvider(''), (_, _) => notifyCount++);
      expect(
        container.read(filterGroupsStateProvider('')).value.single.now,
        isNull,
      );

      container.read(source.notifier).state = [
        Group(
          type: GroupType.Selector,
          name: 'g',
          now: 'b',
          all: [
            _proxy('a'),
            _proxy('b', now: 'y'),
          ],
        ),
      ];
      container.read(filterGroupsStateProvider(''));
      expect(notifyCount, 0);

      container.read(source.notifier).state = [
        Group(
          type: GroupType.Selector,
          name: 'g',
          now: 'b',
          all: [_proxy('a'), _proxy('b'), _proxy('c')],
        ),
      ];
      container.read(filterGroupsStateProvider(''));
      expect(notifyCount, 1);
    });
  });

  group('DelayDataSource', () {
    test('clear 丢弃已有和待合并的延迟', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(delayDataSourceProvider.notifier);
      notifier.value = {
        'u': {'A': 10},
      };
      notifier.setDelay(const Delay(name: 'B', url: 'u', value: 20));
      notifier.clear();
      notifier.flush();
      expect(container.read(delayDataSourceProvider), isEmpty);
    });

    test('dropTesting 只移除测速中的节点', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(delayDataSourceProvider.notifier);
      notifier.value = {
        'u': {'A': 10, 'B': 0},
        'v': {'C': 0},
      };
      notifier.setDelay(const Delay(name: 'D', url: 'u', value: 0));
      notifier.dropTesting();
      expect(container.read(delayDataSourceProvider), {
        'u': {'A': 10},
      });
    });
  });
}
