import 'package:dynamic_color/dynamic_color.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/foundation.dart';
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
  final overrideDns = ref.watch(overrideDnsProvider);
  final overrideNtp = ref.watch(overrideNtpProvider);
  final overrideSniffer = ref.watch(overrideSnifferProvider);
  final overrideTunnel = ref.watch(overrideTunnelProvider);
  final overrideExperimental = ref.watch(overrideExperimentalProvider);
  final overrideTestUrl = ref.watch(overrideTestUrlProvider);
  final networkProps = ref.watch(networkSettingProvider);
  final tailscaleProps = ref.watch(tailscaleSettingProvider);
  final vpnProps = ref.watch(vpnSettingProvider);
  final proxiesStyle = ref.watch(proxiesStyleSettingProvider);
  final scriptProps = ref.watch(scriptStateProvider);
  final hotKeyActions = ref.watch(hotKeyActionsProvider);
  final dav = ref.watch(appDAVSettingProvider);
  final windowProps = ref.watch(windowSettingProvider);
  return Config(
    dav: dav,
    windowProps: windowProps,
    hotKeyActions: hotKeyActions,
    scriptProps: scriptProps,
    proxiesStyle: proxiesStyle,
    vpnProps: vpnProps,
    networkProps: networkProps,
    tailscaleProps: tailscaleProps,
    overrideDns: overrideDns,
    overrideNtp: overrideNtp,
    overrideSniffer: overrideSniffer,
    overrideTunnel: overrideTunnel,
    overrideExperimental: overrideExperimental,
    overrideTestUrl: overrideTestUrl,
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
  return CoreState(
    vpnProps: vpnProps.copyWith(bypassPrivateRoute: bypassPrivateRoute),
    onlyStatisticsProxy: onlyStatisticsProxy,
    currentProfileName: currentProfile?.label ?? currentProfile?.id ?? '',
    bypassDomain: bypassDomain,
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
  final tailscaleRouteCidrs = ref.watch(
    tailscaleSettingProvider.select((state) => state.tunRouteCidrs),
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
          forceRouteAddress: tailscaleRouteCidrs,
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

@riverpod
GroupsState filterGroupsState(Ref ref, String query) {
  final currentGroups = GroupsState(
    value: ref
        .watch(currentGroupsStateProvider)
        .value
        .map(_withoutSelection)
        .toList(),
  );
  if (query.isEmpty) {
    return currentGroups;
  }
  final lowQuery = query.toLowerCase();
  final groups = currentGroups.value
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
  return GroupsState(value: groups);
}

@riverpod
DelayMap delaySortSnapshot(Ref ref) {
  ref.watch(sortNumProvider);
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
        overrideTestUrl: ref.watch(overrideTestUrlProvider),
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
  final overrideTestUrl = ref.watch(overrideTestUrlProvider);
  final currentTestUrl = ref.watch(appSettingProvider).testUrl;

  // If override is enabled or testUrl is null or empty, use client setting
  if (overrideTestUrl || testUrl == null || testUrl.isEmpty) {
    return currentTestUrl;
  }

  // Otherwise use the provided testUrl from config file
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
  required bool overrideTestUrl,
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
    final url = overrideTestUrl || realTestUrl.isEmpty
        ? defaultTestUrl
        : realTestUrl;
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
    // if (globalState.corePalette != null) {
    //   return globalState.corePalette!.toColorScheme(brightness: brightness);
    // }
    return ColorScheme.fromSeed(
      seedColor:
          globalState.corePalette
              ?.toColorScheme(brightness: brightness)
              .primary ??
          globalState.accentColor,
      brightness: brightness,
      dynamicSchemeVariant: vm2.b,
    );
  }
  return ColorScheme.fromSeed(
    seedColor: color ?? Color(vm2.a!),
    brightness: brightness,
    dynamicSchemeVariant: vm2.b,
  );
}

@riverpod
VM5<String?, String?, Dns?, List<String>?, String?> needSetup(Ref ref) {
  final profileId = ref.watch(currentProfileIdProvider);
  final scriptDigest = ref.watch(
    scriptStateProvider.select((state) => state.currentScript?.digest),
  );
  final overrideDns = ref.watch(overrideDnsProvider);
  final dns = overrideDns == true
      ? ref.watch(patchClashConfigProvider.select((state) => state.dns))
      : null;
  final routeExcludeAddress = system.isLinux
      ? ref.watch(
          networkSettingProvider.select(
            (state) => state.bypassPrivateRoute
                ? state.realBypassPrivateRouteAddress
                : const <String>[],
          ),
        )
      : null;
  final loopbackPorts =
      ref.watch(vpnSettingProvider.select((state) => state.loopbackProtection))
      ? ref.watch(patchClashConfigProvider.select((state) => state.listenPorts))
      : null;
  return VM5(
    a: profileId,
    b: scriptDigest,
    c: dns,
    d: routeExcludeAddress,
    e: loopbackPorts,
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
VM2<bool, bool> autoSetSystemDnsState(Ref ref) {
  final isStart = ref.watch(runTimeProvider.select((state) => state != null));
  final realTunEnable = ref.watch(realTunEnableProvider);
  final autoSetSystemDns = ref.watch(
    networkSettingProvider.select((state) => state.autoSetSystemDns),
  );
  return VM2(a: isStart ? realTunEnable : false, b: autoSetSystemDns);
}

@riverpod
class Query extends _$Query with AutoDisposeNotifierMixin {
  @override
  String build() => '';
}
