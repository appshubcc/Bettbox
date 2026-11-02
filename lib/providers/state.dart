import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/foundation.dart';
import 'package:material_color_utilities/material_color_utilities.dart'
    show DynamicScheme, Variant;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app.dart';
import 'config.dart';

part 'generated/state.g.dart';

List<Group> getVisibleGroups({
  required Mode mode,
  required List<Group> groups,
  required bool showHiddenItems,
}) {
  final modeGroups = switch (mode) {
    Mode.direct => const <Group>[],
    Mode.global => groups,
    Mode.rule =>
      groups.where((group) => group.name != GroupName.GLOBAL.name).toList(),
  };
  if (showHiddenItems) {
    return modeGroups.toList();
  }
  return modeGroups.where((group) => group.hidden != true).toList();
}

@riverpod
Config configState(Ref ref) {
  final themeProps = ref.watch(themeSettingProvider);
  final patchClashConfig = ref.watch(patchClashConfigProvider);
  final appSetting = ref.watch(appSettingProvider);
  final profiles = ref.watch(profilesProvider);
  final currentProfileId = ref.watch(currentProfileIdProvider);
  final overrideNtp = ref.watch(overrideNtpProvider);
  final overrideSniffer = ref.watch(overrideSnifferProvider);
  final overrideTunnel = ref.watch(overrideTunnelProvider);
  final overrideExperimental = ref.watch(overrideExperimentalProvider);
  final networkProps = ref.watch(networkSettingProvider);
  final vpnProps = ref.watch(vpnSettingProvider);
  final proxiesStyle = ref.watch(proxiesStyleSettingProvider);
  final trafficStatsProps = ref.watch(trafficStatsSettingProvider);
  final scriptProps = ref.watch(scriptStateProvider);
  final managedProps = ref.watch(managedSettingProvider);
  final hotKeyActions = ref.watch(hotKeyActionsProvider);
  final dav = ref.watch(appDAVSettingProvider);
  final windowProps = ref.watch(windowSettingProvider);
  return Config(
    dav: dav,
    windowProps: windowProps,
    hotKeyActions: hotKeyActions,
    scriptProps: scriptProps,
    managedProps: managedProps,
    proxiesStyle: proxiesStyle,
    trafficStatsProps: trafficStatsProps,
    vpnProps: vpnProps,
    networkProps: networkProps,
    overrideNtp: overrideNtp,
    overrideSniffer: overrideSniffer,
    overrideTunnel: overrideTunnel,
    overrideExperimental: overrideExperimental,
    currentProfileId: currentProfileId,
    profiles: profiles,
    appSetting: appSetting,
    themeProps: themeProps,
    patchClashConfig: patchClashConfig,
  );
}

@riverpod
GroupsState currentGroupsState(Ref ref) {
  final mode = ref.watch(
    patchClashConfigProvider.select((state) => state.mode),
  );
  final groups = ref.watch(groupsProvider);
  final showHiddenItems = ref.watch(
    proxiesStyleSettingProvider.select((state) => state.showHiddenItems),
  );
  return GroupsState(
    value: getVisibleGroups(
      mode: mode,
      groups: groups,
      showHiddenItems: showHiddenItems,
    ),
  );
}

@riverpod
NavigationItemsState navigationItemsState(Ref ref) {
  ref.watch(appSettingProvider.select((state) => state.locale));
  final openLogs = ref.watch(appSettingProvider).openLogs;
  return NavigationItemsState(
    value: navigation.getItems(openLogs: openLogs, hasProxies: true),
  );
}

@riverpod
NavigationItemsState currentNavigationItemsState(Ref ref) {
  final viewWidth = ref.watch(viewWidthProvider);
  final navigationItemsState = ref.watch(navigationItemsStateProvider);
  final navigationItemMode = switch (viewWidth <= maxMobileWidth) {
    true => NavigationItemMode.mobile,
    false => NavigationItemMode.desktop,
  };

  var items = navigationItemsState.value
      .where(
        (element) =>
            element.modes.contains(navigationItemMode) || element.modes.isEmpty,
      )
      .toList();

  if (globalState.isAndroidTV) {
    items = items
        .where(
          (element) => [
            PageLabel.dashboard,
            PageLabel.proxies,
            PageLabel.profiles,
            PageLabel.tools,
          ].contains(element.label),
        )
        .toList();
  }

  return NavigationItemsState(value: items);
}

@riverpod
CoreState coreState(Ref ref) {
  final vpnProps = ref.watch(vpnSettingProvider);
  final (:bypassPrivateRoute, :bypassDomain) = ref.watch(
    networkSettingProvider.select(
      (state) => (
        bypassPrivateRoute: state.bypassPrivateRoute,
        bypassDomain: state.bypassDomain,
      ),
    ),
  );
  final currentProfile = ref.watch(currentProfileProvider);
  final onlyStatisticsProxy = ref.watch(appSettingProvider).onlyStatisticsProxy;
  final trafficStatsProps = ref.watch(trafficStatsSettingProvider);
  return CoreState(
    vpnProps: vpnProps.copyWith(bypassPrivateRoute: bypassPrivateRoute),
    onlyStatisticsProxy: onlyStatisticsProxy,
    currentProfileName: currentProfile?.label ?? currentProfile?.id ?? '',
    bypassDomain: bypassDomain,
    trafficStats: TrafficStatsOptions.fromProps(trafficStatsProps),
  );
}

@riverpod
UpdateParams updateParams(Ref ref) {
  final (:bypassPrivateRoute, :realBypassPrivateRouteAddress) = ref.watch(
    networkSettingProvider.select(
      (state) => (
        bypassPrivateRoute: state.bypassPrivateRoute,
        realBypassPrivateRouteAddress: state.realBypassPrivateRouteAddress,
      ),
    ),
  );
  return ref.watch(
    patchClashConfigProvider.select(
      (state) => UpdateParams(
        tun: state.tun.getRealTun(
          bypassPrivateRoute,
          fakeIpRange: state.dns.fakeIpRange,
          fakeIpRangeV6: state.dns.effectiveFakeIpRangeV6(
            ipv6Enabled: state.ipv6,
          ),
          bypassPrivateRouteAddress: realBypassPrivateRouteAddress,
        ),
        allowLan: state.allowLan,
        findProcessMode: state.findProcessMode,
        mode: state.mode,
        logLevel: state.logLevel,
        ipv6: state.ipv6,
        tcpConcurrent: state.tcpConcurrent,
        externalController: state.externalController,
        unifiedDelay: state.unifiedDelay,
        mixedPort: state.mixedPort,
      ),
    ),
  );
}

@riverpod
ProxyState proxyState(Ref ref) {
  final isStart = ref.watch(runTimeProvider.select((state) => state != null));
  final vm2 = ref.watch(
    networkSettingProvider.select(
      (state) => VM2(a: state.systemProxy, b: state.bypassDomain),
    ),
  );
  final mixedPort = ref.watch(
    patchClashConfigProvider.select((state) => state.mixedPort),
  );
  return ProxyState(
    isStart: isStart,
    systemProxy: vm2.a,
    bypassDomain: vm2.b,
    port: mixedPort,
  );
}

final wakelockStateProvider = StateProvider<bool>((ref) => false);

final isRestartingCoreProvider = StateProvider<bool>((ref) => false);

@riverpod
TrayState trayState(Ref ref) {
  final isStart = ref.watch(runTimeProvider.select((state) => state != null));
  final networkProps = ref.watch(networkSettingProvider);
  final clashConfig = ref.watch(patchClashConfigProvider);
  final appSetting = ref.watch(appSettingProvider);
  final groups = ref.watch(currentGroupsStateProvider).value;
  final brightness = ref.watch(systemBrightnessProvider);
  final vpnProps = ref.watch(vpnSettingProvider);

  final selectedMap = ref.watch(selectedMapProvider);

  final wakelockEnabled = ref.watch(wakelockStateProvider);

  return TrayState(
    mode: clashConfig.mode,
    port: clashConfig.mixedPort,
    autoLaunch: appSetting.autoLaunch,
    systemProxy: networkProps.systemProxy,
    tunEnable: clashConfig.tun.enable,
    isStart: isStart,
    locale: appSetting.locale,
    brightness: brightness,
    groups: groups,
    selectedMap: selectedMap,
    wakelockEnabled: wakelockEnabled,
    trayEnhancement: vpnProps.trayEnhancement,
    enableTraySpeed: vpnProps.enableTraySpeed,
  );
}

@riverpod
VpnState vpnState(Ref ref) {
  final vpnProps = ref.watch(vpnSettingProvider);
  final stack = ref.watch(
    patchClashConfigProvider.select((state) => state.tun.stack),
  );

  return VpnState(stack: stack, vpnProps: vpnProps);
}

@riverpod
NavigationState navigationState(Ref ref) {
  final pageLabel = ref.watch(currentPageLabelProvider);
  final navigationItems = ref.watch(currentNavigationItemsStateProvider).value;
  final viewMode = ref.watch(viewModeProvider);
  final locale = ref.watch(appSettingProvider).locale;
  final index = navigationItems.lastIndexWhere(
    (element) => element.label == pageLabel,
  );
  final currentIndex = index == -1 ? 0 : index;
  return NavigationState(
    pageLabel: pageLabel,
    navigationItems: navigationItems,
    viewMode: viewMode,
    locale: locale,
    currentIndex: currentIndex,
  );
}

@riverpod
DashboardState dashboardState(Ref ref) {
  final dashboardWidgets = ref.watch(
    appSettingProvider.select(
      (state) => system.isAndroid
          ? state.mobileDashboardWidgets
          : state.desktopDashboardWidgets,
    ),
  );
  final viewWidth = ref.watch(viewWidthProvider);
  final widgets = dashboardWidgets.contains(DashboardWidget.startButton)
      ? dashboardWidgets
      : [...dashboardWidgets, DashboardWidget.startButton];
  return DashboardState(dashboardWidgets: widgets, viewWidth: viewWidth);
}

@riverpod
ProxiesActionsState proxiesActionsState(Ref ref) {
  final pageLabel = ref.watch(currentPageLabelProvider);
  final hasProviders = ref.watch(
    providersProvider.select((state) => state.isNotEmpty),
  );
  final type = ref.watch(
    proxiesStyleSettingProvider.select((state) => state.type),
  );
  return ProxiesActionsState(
    pageLabel: pageLabel,
    hasProviders: hasProviders,
    type: type,
  );
}

@riverpod
StartButtonSelectorState startButtonSelectorState(Ref ref) {
  final isInit = ref.watch(initProvider);
  final hasProfile = ref.watch(
    profilesProvider.select((state) => state.isNotEmpty),
  );
  return StartButtonSelectorState(isInit: isInit, hasProfile: hasProfile);
}

@riverpod
ProfilesSelectorState profilesSelectorState(Ref ref) {
  final currentProfileId = ref.watch(currentProfileIdProvider);
  final profiles = ref.watch(profilesProvider);
  final columns = ref.watch(
    viewWidthProvider.select((state) => utils.getProfilesColumns(state)),
  );
  return ProfilesSelectorState(
    profiles: profiles,
    currentProfileId: currentProfileId,
    columns: columns,
  );
}

Group _withoutSelection(Group group) {
  final all = group.all.any(_hasSelection)
      ? [
          for (final proxy in group.all)
            _hasSelection(proxy) ? proxy.copyWith(now: null) : proxy,
        ]
      : group.all;
  return group.copyWith(now: null, all: all);
}

bool _hasSelection(Proxy proxy) => proxy.now != null;

const backgroundSortThreshold = 1000;

List<int> _sortOrder(int length, int Function(int a, int b) compare) {
  return List.generate(length, (index) => index)..sort((a, b) {
    final result = compare(a, b);
    return result != 0 ? result : a.compareTo(b);
  });
}

List<int> sortOrderByName(List<String> keys) {
  return _sortOrder(keys.length, (a, b) => utils.sortByChar(keys[a], keys[b]));
}

List<int> sortOrderByDelay(List<int> values) {
  return _sortOrder(values.length, (a, b) => values[a].compareTo(values[b]));
}

List<String> _nameSortKeys(List<Proxy> proxies) {
  return [for (final proxy in proxies) utils.getPinyin(proxy.name)];
}

List<int> _delaySortValues(
  List<Proxy> proxies,
  int? Function(String proxyName)? delayOf,
) {
  return [
    for (final proxy in proxies) _delaySortValue(delayOf?.call(proxy.name)),
  ];
}

List<Proxy> sortProxies(
  List<Proxy> proxies,
  ProxiesSortType sortType, {
  int? Function(String proxyName)? delayOf,
}) {
  final order = switch (sortType) {
    ProxiesSortType.none => null,
    ProxiesSortType.name => sortOrderByName(_nameSortKeys(proxies)),
    ProxiesSortType.delay => sortOrderByDelay(
      _delaySortValues(proxies, delayOf),
    ),
  };
  if (order == null) return proxies;
  return [for (final index in order) proxies[index]];
}

int _delaySortValue(int? delay) =>
    (delay == null || delay == -1) ? 1 << 30 : delay;

List<Proxy>? _reuseOrder(List<Proxy>? previous, List<Proxy> proxies) {
  if (previous == null || previous.length != proxies.length) return null;
  final byName = {for (final proxy in proxies) proxy.name: proxy};
  if (byName.length != proxies.length) return null;
  final result = <Proxy>[];
  for (final proxy in previous) {
    final current = byName[proxy.name];
    if (current == null) return null;
    result.add(current);
  }
  return result;
}

const _unprobeableProxyTypes = {
  'Reject',
  'RejectDrop',
  'Pass',
  'PassRule',
  'Rematch',
  'Compatible',
  'Dns',
};

List<Group> hideTimeoutProxies({
  required List<Group> groups,
  required List<Group> allGroups,
  required SelectedMap selectedMap,
  required DelayMap delayMap,
  required String defaultTestUrl,
}) {
  final proxyTypes = {
    for (final group in allGroups)
      for (final proxy in group.all) proxy.name: proxy.type,
  };
  final states = <String, ProxyCardState>{};
  return groups.map((group) {
    final selectedName = (allGroups.getGroup(group.name) ?? group)
        .getCurrentSelectedName(selectedMap[group.name] ?? '');

    bool isTimeout(Proxy proxy) {
      if (allGroups.getGroup(proxy.name) != null) {
        return false;
      }
      final state = states.putIfAbsent(
        proxy.name,
        () => resolveProxyCardState(
          allGroups,
          selectedMap,
          ProxyCardState(proxyName: proxy.name),
        ),
      );
      if (_unprobeableProxyTypes.contains(proxyTypes[state.proxyName])) {
        return false;
      }
      final testUrl = state.testUrl.getSafeValue(group.testUrl ?? '');
      final url = testUrl.isEmpty ? defaultTestUrl : testUrl;
      final delay = delayMap[url]?[state.proxyName];
      return delay != null && delay < 0;
    }

    final hasUsable = group.all.any((proxy) => !isTimeout(proxy));
    if (!hasUsable) {
      return group;
    }

    final visible = group.all.where((proxy) {
      if (proxy.name == selectedName) {
        return true;
      }
      return !isTimeout(proxy);
    }).toList();
    return group.copyWith(all: visible);
  }).toList();
}

GroupsState _hideTimeoutGroups(Ref ref, List<Group> groups) {
  final hideTimeout = ref.watch(
    proxiesStyleSettingProvider.select((state) => state.hideTimeoutProxies),
  );
  if (!hideTimeout) {
    return GroupsState(value: groups);
  }
  return GroupsState(
    value: hideTimeoutProxies(
      groups: groups,
      allGroups: ref.watch(groupsProvider),
      selectedMap: ref.watch(selectedMapProvider),
      delayMap: ref.watch(delaySortSnapshotProvider),
      defaultTestUrl: ref.watch(
        appSettingProvider.select((state) => state.testUrl),
      ),
    ),
  );
}

@riverpod
GroupsState visibleGroupsState(Ref ref) {
  final groups = ref
      .watch(currentGroupsStateProvider)
      .value
      .map(_withoutSelection)
      .toList();
  return _hideTimeoutGroups(ref, groups);
}

@riverpod
GroupsState filterGroupsState(Ref ref, String query) {
  if (query.isEmpty) {
    return ref.watch(visibleGroupsStateProvider);
  }
  final lowQuery = query.toLowerCase();
  final groups = ref
      .watch(currentGroupsStateProvider)
      .value
      .map(_withoutSelection)
      .map((group) {
        final groupNameMatch = group.name.toLowerCase().contains(lowQuery);
        if (groupNameMatch) {
          return group;
        }
        return group.copyWith(
          all: group.all
              .where((proxy) => proxy.name.toLowerCase().contains(lowQuery))
              .toList(),
        );
      })
      .where((group) => group.all.isNotEmpty)
      .toList();
  return _hideTimeoutGroups(ref, groups);
}

@riverpod
DelayMap delaySortSnapshot(Ref ref) {
  ref.watch(sortNumProvider);
  ref.listen(delayDataSourceProvider.select((state) => state.isEmpty), (
    _,
    isEmpty,
  ) {
    if (isEmpty) ref.invalidateSelf();
  });
  return {
    for (final entry in ref.read(delayDataSourceProvider).entries)
      entry.key: Map.of(entry.value),
  };
}

@riverpod
class SortedGroupProxies extends _$SortedGroupProxies {
  static final Map<String, List<Proxy>> _orderCache = {};

  List<Proxy>? _lastSorted;

  List<Proxy> _remember(List<Proxy> sorted) {
    _lastSorted = sorted;
    if (query.isEmpty) {
      _orderCache.remove(groupName);
      _orderCache[groupName] = sorted;
      if (_orderCache.length > 16) {
        _orderCache.remove(_orderCache.keys.first);
      }
    }
    return sorted;
  }

  @override
  List<Proxy>? build(String query, String groupName) {
    final group = ref.watch(
      filterGroupsStateProvider(
        query,
      ).select((state) => state.value.getGroup(groupName)),
    );
    if (group == null) return _lastSorted = const [];
    final proxies = group.all;
    final sortType = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.sortType),
    );
    if (sortType == ProxiesSortType.none) return _lastSorted = proxies;

    int? Function(String proxyName)? delayOf;
    if (sortType == ProxiesSortType.delay) {
      final lookup = createDelayLookup(
        groups: ref.read(groupsProvider),
        selectedMap: ref.read(selectedMapProvider),
        delayMap: ref.watch(delaySortSnapshotProvider),
        defaultTestUrl: ref.watch(
          appSettingProvider.select((state) => state.testUrl),
        ),
      );
      delayOf = (proxyName) => lookup(proxyName, group.testUrl);
    }
    if (proxies.length < backgroundSortThreshold) {
      return _lastSorted = sortProxies(proxies, sortType, delayOf: delayOf);
    }
    final pending = _reuseOrder(
      _lastSorted ?? (query.isEmpty ? _orderCache[groupName] : null),
      proxies,
    );
    if (pending == null && query.isNotEmpty) {
      return _lastSorted = sortProxies(proxies, sortType, delayOf: delayOf);
    }

    var active = true;
    ref.onDispose(() => active = false);
    final order = sortType == ProxiesSortType.name
        ? compute(sortOrderByName, _nameSortKeys(proxies))
        : compute(sortOrderByDelay, _delaySortValues(proxies, delayOf));
    order.then(
      (order) {
        if (!active) return;
        state = _remember([for (final index in order) proxies[index]]);
      },
      onError: (Object _) {
        if (!active) return;
        state = _remember(sortProxies(proxies, sortType, delayOf: delayOf));
      },
    );
    return _lastSorted = pending;
  }
}

@riverpod
GroupsState sortedGroupsState(Ref ref, String query) {
  final groupsState = ref.watch(filterGroupsStateProvider(query));
  final sortType = ref.watch(
    proxiesStyleSettingProvider.select((state) => state.sortType),
  );
  if (sortType == ProxiesSortType.none) {
    return groupsState;
  }
  final unfoldSet = ref.watch(unfoldSetProvider);
  return GroupsState(
    value: [
      for (final group in groupsState.value)
        unfoldSet.contains(group.name)
            ? group.copyWith(
                all:
                    ref.watch(sortedGroupProxiesProvider(query, group.name)) ??
                    const [],
              )
            : group,
    ],
  );
}

@Riverpod(dependencies: [Query])
ProxiesListState proxiesListState(Ref ref) {
  final query = ref.watch(queryProvider);
  final currentGroups = ref.watch(sortedGroupsStateProvider(query));
  final currentUnfoldSet = ref.watch(unfoldSetProvider);
  final cardType = ref.watch(
    proxiesStyleSettingProvider.select((state) => state.cardType),
  );
  final columns = ref.watch(getProxiesColumnsProvider);
  return ProxiesListState(
    groups: currentGroups.value,
    currentUnfoldSet: currentUnfoldSet,
    proxyCardType: cardType,
    columns: columns,
  );
}

@Riverpod(dependencies: [Query])
ProxiesTabState proxiesTabState(Ref ref) {
  final query = ref.watch(queryProvider);
  final currentGroups = ref.watch(filterGroupsStateProvider(query));
  final currentGroupName = ref.watch(
    currentProfileProvider.select((state) => state?.currentGroupName),
  );
  final vm2 = ref.watch(
    proxiesStyleSettingProvider.select(
      (state) => VM2(a: state.sortType, b: state.cardType),
    ),
  );
  final sortNum = ref.watch(sortNumProvider);
  final columns = ref.watch(getProxiesColumnsProvider);
  return ProxiesTabState(
    groups: currentGroups.value,
    currentGroupName: currentGroupName,
    proxiesSortType: vm2.a,
    proxyCardType: vm2.b,
    sortNum: sortNum,
    columns: columns,
  );
}

@Riverpod(dependencies: [proxiesTabState])
VM2<List<String>, String?> proxiesTabControllerState(Ref ref) {
  return ref.watch(
    proxiesTabStateProvider.select(
      (state) => VM2(
        a: state.groups.map((group) => group.name).toList(),
        b: state.currentGroupName,
      ),
    ),
  );
}

@riverpod
ProxyGroupSelectorState proxyGroupSelectorState(
  Ref ref,
  String groupName,
  String query,
) {
  final proxiesStyle = ref.watch(proxiesStyleSettingProvider);
  final group = ref.watch(
    currentGroupsStateProvider.select(
      (state) => state.value.getGroup(groupName),
    ),
  );
  final sortNum = ref.watch(sortNumProvider);
  final columns = ref.watch(getProxiesColumnsProvider);
  final lowQuery = query.toLowerCase();
  final proxies =
      group?.all.where((item) {
        return item.name.toLowerCase().contains(lowQuery);
      }).toList() ??
      [];
  return ProxyGroupSelectorState(
    testUrl: group?.testUrl,
    proxiesSortType: proxiesStyle.sortType,
    proxyCardType: proxiesStyle.cardType,
    sortNum: sortNum,
    groupType: group?.type ?? GroupType.Selector,
    proxies: proxies,
    columns: columns,
  );
}

@riverpod
PackageListSelectorState packageListSelectorState(Ref ref) {
  final packages = ref.watch(packagesProvider);
  final accessControl = ref.watch(
    vpnSettingProvider.select((state) => state.accessControl),
  );
  return PackageListSelectorState(
    packages: packages,
    accessControl: accessControl,
  );
}

@riverpod
MoreToolsSelectorState moreToolsSelectorState(Ref ref) {
  final viewMode = ref.watch(viewModeProvider);
  final navigationItems = ref.watch(
    navigationItemsStateProvider.select((state) {
      return state.value.where((element) {
        final isMore = element.modes.contains(NavigationItemMode.more);

        if (globalState.isAndroidTV) {
          return isMore;
        }

        final isDesktop = element.modes.contains(NavigationItemMode.desktop);
        if (isMore && !isDesktop) return true;
        if (viewMode != ViewMode.mobile || !isMore) {
          return false;
        }
        return true;
      }).toList();
    }),
  );

  return MoreToolsSelectorState(navigationItems: navigationItems);
}

@riverpod
bool isCurrentPage(
  Ref ref,
  PageLabel pageLabel, {
  bool Function(PageLabel pageLabel, ViewMode viewMode)? handler,
}) {
  final currentPageLabel = ref.watch(currentPageLabelProvider);
  if (pageLabel == currentPageLabel) {
    return true;
  }
  if (handler != null) {
    final viewMode = ref.watch(viewModeProvider);
    return handler(currentPageLabel, viewMode);
  }
  return false;
}

@riverpod
String getRealTestUrl(Ref ref, [String? testUrl]) {
  final currentTestUrl = ref.watch(appSettingProvider).testUrl;

  if (testUrl == null || testUrl.isEmpty) {
    return currentTestUrl;
  }

  return testUrl;
}

@riverpod
int? getDelay(Ref ref, {required String proxyName, String? testUrl}) {
  final proxyCardState = ref.watch(getProxyCardStateProvider(proxyName));
  final currentTestUrl = ref.watch(
    getRealTestUrlProvider(proxyCardState.testUrl.getSafeValue(testUrl ?? '')),
  );
  final delay = ref.watch(
    delayDataSourceProvider.select((state) {
      final delayMap = state[currentTestUrl];
      return delayMap?[proxyCardState.proxyName];
    }),
  );
  return delay;
}

@riverpod
SelectedMap selectedMap(Ref ref) {
  final selectedMap = ref.watch(
    currentProfileProvider.select((state) => state?.selectedMap ?? {}),
  );
  return selectedMap;
}

@riverpod
Set<String> unfoldSet(Ref ref) {
  final unfoldSet = ref.watch(
    currentProfileProvider.select((state) => state?.unfoldSet ?? {}),
  );
  return unfoldSet;
}

@riverpod
HotKeyAction getHotKeyAction(Ref ref, HotAction hotAction) {
  return ref.watch(
    hotKeyActionsProvider.select((state) {
      final index = state.indexWhere((item) => item.action == hotAction);
      return index != -1 ? state[index] : HotKeyAction(action: hotAction);
    }),
  );
}

@riverpod
Profile? currentProfile(Ref ref) {
  final profileId = ref.watch(currentProfileIdProvider);
  return ref.watch(
    profilesProvider.select((state) => state.getProfile(profileId)),
  );
}

@riverpod
int getProxiesColumns(Ref ref) {
  final viewWidth = ref.watch(viewWidthProvider);
  final proxiesLayout = ref.watch(
    proxiesStyleSettingProvider.select((state) => state.layout),
  );
  return utils.getProxiesColumns(viewWidth, proxiesLayout);
}

ProxyCardState resolveProxyCardState(
  List<Group> groups,
  SelectedMap selectedMap,
  ProxyCardState proxyDelayState,
) {
  final proxyName = proxyDelayState.proxyName;
  if (proxyName.isEmpty) return proxyDelayState;
  final group = groups.getGroup(proxyName);
  if (group == null) {
    final now = groups.getRematchProxy(proxyName)?.now;
    if (now != null && now.isNotEmpty && now != proxyName) {
      return resolveProxyCardState(
        groups,
        selectedMap,
        proxyDelayState.copyWith(proxyName: now),
      );
    }
    return proxyDelayState;
  }
  final currentSelectedName = group.getCurrentSelectedName(
    selectedMap[proxyName] ?? '',
  );
  if (currentSelectedName.isEmpty) {
    return proxyDelayState;
  }
  return resolveProxyCardState(
    groups,
    selectedMap,
    proxyDelayState.copyWith(
      proxyName: currentSelectedName,
      testUrl: group.testUrl,
    ),
  );
}

int? Function(String proxyName, String? testUrl) createDelayLookup({
  required List<Group> groups,
  required SelectedMap selectedMap,
  required DelayMap delayMap,
  required String defaultTestUrl,
}) {
  final cache = <(String, String?), int?>{};
  return (proxyName, testUrl) => cache.putIfAbsent((proxyName, testUrl), () {
    final state = resolveProxyCardState(
      groups,
      selectedMap,
      ProxyCardState(proxyName: proxyName),
    );
    final realTestUrl = state.testUrl.getSafeValue(testUrl ?? '');
    final url = realTestUrl.isEmpty ? defaultTestUrl : realTestUrl;
    return delayMap[url]?[state.proxyName];
  });
}

@riverpod
ProxyCardState getProxyCardState(Ref ref, String proxyName) {
  final groups = ref.watch(groupsProvider);
  final selectedMap = ref.watch(selectedMapProvider);
  return resolveProxyCardState(
    groups,
    selectedMap,
    ProxyCardState(proxyName: proxyName),
  );
}

@riverpod
String? getProxyName(Ref ref, String groupName) {
  final proxyName = ref.watch(
    selectedMapProvider.select((state) => state[groupName]),
  );
  return proxyName;
}

@riverpod
String? getSelectedProxyName(Ref ref, String groupName) {
  final proxyName = ref.watch(getProxyNameProvider(groupName));
  final group = ref.watch(
    groupsProvider.select((state) => state.getGroup(groupName)),
  );
  return group?.getCurrentSelectedName(proxyName ?? '');
}

@riverpod
String getProxyDesc(Ref ref, Proxy proxy) {
  final groupTypeNamesList = GroupType.values.map((e) => e.name).toList();
  if (!groupTypeNamesList.contains(proxy.type)) {
    return proxy.type;
  } else {
    final groups = ref.watch(groupsProvider);
    final index = groups.indexWhere((element) => element.name == proxy.name);
    if (index == -1) return proxy.type;
    final state = ref.watch(getProxyCardStateProvider(proxy.name));
    return "${proxy.type}(${state.proxyName.isNotEmpty ? state.proxyName : '*'})";
  }
}

@riverpod
class ProfileOverrideState extends _$ProfileOverrideState {
  @override
  ProfileOverrideStateModel build() {
    return ProfileOverrideStateModel(selectedRules: {});
  }

  void updateState(
    ProfileOverrideStateModel? Function(ProfileOverrideStateModel state)
    builder,
  ) {
    final value = builder(state);
    if (value == null) {
      return;
    }
    state = value;
  }
}

@riverpod
OverrideData? getProfileOverrideData(Ref ref, String profileId) {
  return ref.watch(
    profilesProvider.select(
      (state) => state.getProfile(profileId)?.overrideData,
    ),
  );
}

@riverpod
VM2? layoutChange(Ref ref) {
  final viewWidth = ref.watch(viewWidthProvider);
  final textScale = ref.watch(
    themeSettingProvider.select((state) => state.textScale),
  );
  return VM2(a: viewWidth, b: textScale);
}

@riverpod
VM2<int, bool> checkIp(Ref ref) {
  final checkIpNum = ref.watch(checkIpNumProvider);
  final containsDetection = ref.watch(
    dashboardStateProvider.select(
      (state) =>
          state.dashboardWidgets.contains(DashboardWidget.networkDetection),
    ),
  );
  return VM2(a: checkIpNum, b: containsDetection);
}

@riverpod
VM2<int, bool> checkMediaUnlock(Ref ref) {
  final checkIpNum = ref.watch(checkIpNumProvider);
  final containsMediaUnlock = ref.watch(
    dashboardStateProvider.select(
      (state) =>
          state.dashboardWidgets.contains(DashboardWidget.mediaUnlock) ||
          state.dashboardWidgets.contains(DashboardWidget.mediaUnlockSmall),
    ),
  );
  return VM2(a: checkIpNum, b: containsMediaUnlock);
}

@riverpod
ColorScheme genColorScheme(
  Ref ref,
  Brightness brightness, {
  Color? color,
  bool ignoreConfig = false,
}) {
  final vm2 = ref.watch(
    themeSettingProvider.select(
      (state) => VM2(a: state.primaryColor, b: state.schemeVariant),
    ),
  );
  if (color == null && (ignoreConfig == true || vm2.a == null)) {
    if (globalState.corePalette case final palette?) {
      return DynamicScheme(
        sourceColorHct: palette.primary.keyColor,
        variant: Variant.tonalSpot,
        isDark: brightness == Brightness.dark,
        primaryPalette: palette.primary,
        secondaryPalette: palette.secondary,
        tertiaryPalette: palette.tertiary,
        neutralPalette: palette.neutral,
        neutralVariantPalette: palette.neutralVariant,
      ).toColorScheme().toNeutralSurfaces();
    }
    return ColorScheme.fromSeed(
      seedColor: globalState.accentColor,
      brightness: brightness,
      dynamicSchemeVariant: vm2.b,
    ).toNeutralSurfaces();
  }
  return ColorScheme.fromSeed(
    seedColor: color ?? Color(vm2.a!),
    brightness: brightness,
    dynamicSchemeVariant: vm2.b,
  ).toNeutralSurfaces();
}

@riverpod
Script? currentProfileScript(Ref ref) {
  final id = ref.watch(
    currentProfileProvider.select(
      (profile) =>
          profile == null || profile.isManaged ? null : profile.scriptId,
    ),
  );
  if (id == null) return null;
  return ref.watch(scriptStateProvider.select((state) => state.findScript(id)));
}

@riverpod
bool currentProfileScriptActive(Ref ref) {
  final managed = ref.watch(
    currentProfileProvider.select((profile) => profile?.isManaged ?? false),
  );
  return managed ||
      ref.watch(
        currentProfileScriptProvider.select((script) => script != null),
      );
}

@riverpod
VM5<String?, String?, String?, bool, String> needSetup(Ref ref) {
  final profileId = ref.watch(currentProfileIdProvider);
  final runsManagedScript = ref.watch(
    currentProfileProvider.select(
      (profile) => profile?.runsManagedScript ?? false,
    ),
  );
  final script = ref.watch(currentProfileScriptProvider);
  final scriptDigest = runsManagedScript
      ? ref.watch(
          managedSettingProvider.select(
            (state) =>
                '${ManagedScript.version(state)}:${state.options}:${state.routes}:${state.order}',
          ),
        )
      : script == null
      ? null
      : '${script.id}:${script.digest}';
  final loopbackPorts =
      ref.watch(vpnSettingProvider.select((state) => state.loopbackProtection))
      ? ref.watch(patchClashConfigProvider.select((state) => state.listenPorts))
      : null;
  final ipv6 = ref.watch(
    patchClashConfigProvider.select((state) => state.ipv6),
  );
  final interfaceName = ref.watch(
    patchClashConfigProvider.select((state) => state.interfaceName),
  );
  return VM5(
    a: profileId,
    b: scriptDigest,
    c: loopbackPorts,
    d: ipv6,
    e: interfaceName,
  );
}

@riverpod
Brightness currentBrightness(Ref ref) {
  final themeMode = ref.watch(
    themeSettingProvider.select((state) => state.themeMode),
  );
  final systemBrightness = ref.watch(systemBrightnessProvider);
  return switch (themeMode) {
    ThemeMode.system => systemBrightness,
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
  };
}

@riverpod
bool systemDnsTakeover(Ref ref) {
  final isStart = ref.watch(runTimeProvider.select((state) => state != null));
  final realTunEnable = ref.watch(realTunEnableProvider);
  final dnsHijack = ref.watch(
    patchClashConfigProvider.select((state) => state.tun.dnsHijack.isNotEmpty),
  );
  return isStart && realTunEnable && dnsHijack;
}

@riverpod
class Query extends _$Query with AutoDisposeNotifierMixin {
  @override
  String build() => '';
}

@riverpod
String? currentMainGroupName(Ref ref) => ref.watch(
  currentGroupsStateProvider.select((state) {
    final groups = state.value;
    return (groups.getGroup(GroupName.GLOBAL.name) ?? groups.firstOrNull)?.name;
  }),
);

HomeWidgetColors _homeWidgetColors(ColorScheme scheme) {
  final isLight = scheme.brightness == Brightness.light;
  return HomeWidgetColors(
    surface: scheme.surfaceContainer.toARGB32(),
    tonal: scheme.surfaceContainerHighest.toARGB32(),
    onSurface: scheme.onSurface.toARGB32(),
    onSurfaceVariant: scheme.onSurfaceVariant.toARGB32(),
    primary: scheme.primary.toARGB32(),
    onPrimary: scheme.onPrimary.toARGB32(),
    active: (isLight ? scheme.primaryContainer : scheme.primary).toARGB32(),
    onActive: (isLight ? scheme.onPrimaryContainer : scheme.onPrimary)
        .toARGB32(),
  );
}

String _homeWidgetTwo(int value) => value.toString().padLeft(2, '0');

String _homeWidgetDate(DateTime time) =>
    '${_homeWidgetTwo(time.month)}-${_homeWidgetTwo(time.day)}';

String _homeWidgetTime(DateTime time) =>
    '${_homeWidgetDate(time)} ${_homeWidgetTwo(time.hour)}:${_homeWidgetTwo(time.minute)}';

@riverpod
HomeWidgetSnapshot homeWidgetSnapshot(Ref ref) {
  final light = _homeWidgetColors(
    ref.watch(genColorSchemeProvider(Brightness.light)),
  );
  final dark = _homeWidgetColors(
    ref.watch(genColorSchemeProvider(Brightness.dark)),
  );
  final (onLabel, offLabel) = ref.watch(
    appSettingProvider.select(
      (state) => (
        state.startSwitchOnLabel ?? appLocalizations.enabled,
        state.startSwitchOffLabel ?? appLocalizations.disabled,
      ),
    ),
  );
  final profile = ref.watch(currentProfileProvider);
  if (profile == null) {
    return HomeWidgetSnapshot(
      emptyText: appLocalizations.nullProfileDesc,
      onLabel: onLabel,
      offLabel: offLabel,
      light: light,
      dark: dark,
    );
  }
  final isDirect = ref.watch(
    patchClashConfigProvider.select((state) => state.mode == Mode.direct),
  );
  final group = isDirect ? null : ref.watch(currentMainGroupNameProvider);
  final node = isDirect
      ? appLocalizations.direct
      : group == null
      ? ''
      : ref.watch(
          getProxyCardStateProvider(group).select((state) => state.proxyName),
        );
  final delay = group == null
      ? null
      : ref.watch(getDelayProvider(proxyName: group));
  final providerUpdating = ref.watch(
    providersProvider.select(
      (items) => items.any((item) => item.type == 'Proxy' && item.isUpdating),
    ),
  );
  final usage = ProfileUsage.of(profile);
  final ratio = usage?.ratio;
  final remaining = usage?.remaining;
  final usedText = usage == null
      ? appLocalizations.noUsageData
      : TrafficValue(value: usage.used).shortShow;
  final totalText = usage == null
      ? ''
      : usage.unlimited
      ? '∞'
      : TrafficValue(value: usage.total).shortShow;
  final expireText = profile.usageExpireText(usage);
  final daysLeft = usage?.daysLeft;
  final expireAt = usage?.expireAt;
  final segments = usage?.segments ?? const <double>[];
  final updated = profile.lastUpdateDate;
  return HomeWidgetSnapshot(
    hasProfile: true,
    name: profile.label ?? profile.id,
    updated: updated == null
        ? ''
        : '${appLocalizations.updateTime} ${_homeWidgetTime(updated)}',
    subtitle: usage != null && usage.isMulti
        ? appLocalizations.providersCount(usage.items.length)
        : expireText ?? '',
    expired: usage?.isExpired ?? false,
    used: usedText,
    total: usage == null ? '' : '/ $totalText',
    usage: usage == null ? usedText : '$usedText / $totalText',
    percent: ratio == null ? '' : '${(ratio * 100).round()}%',
    segments: segments.isEmpty ? const [0] : segments,
    firstLabel: remaining != null
        ? appLocalizations.remainingTraffic
        : appLocalizations.speedTestDataUsed,
    firstValue: remaining != null
        ? TrafficValue(value: remaining).shortShow
        : usage == null
        ? '—'
        : usedText,
    secondLabel: appLocalizations.expirationTime,
    secondValue: daysLeft != null && usage?.isExpired != true
        ? '${expireText ?? ''} · $daysLeft ${appLocalizations.days(daysLeft)}'
        : expireText ?? '—',
    expireShort:
        expireAt != null && daysLeft != null && usage?.isExpired != true
        ? '${_homeWidgetDate(expireAt)} · $daysLeft ${appLocalizations.days(daysLeft)}'
        : expireText ?? '',
    nodeLabel: appLocalizations.currentSelection,
    node: node,
    delay: delay == null ? '' : (delay > 0 ? '$delay ms' : 'Timeout'),
    delayColor: utils.getDelayColor(delay)?.toARGB32() ?? 0,
    canRefresh:
        profile.type != ProfileType.file ||
        profile.providerSubscriptions.isNotEmpty,
    refreshing: profile.isUpdating || providerUpdating,
    onLabel: onLabel,
    offLabel: offLabel,
    light: light,
    dark: dark,
  );
}
