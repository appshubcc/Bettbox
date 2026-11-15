import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:material_ui/material_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/selector.freezed.dart';

@freezed
abstract class StartButtonSelectorState with _$StartButtonSelectorState {
  const factory StartButtonSelectorState({
    required bool isInit,
    required bool hasProfile,
  }) = _StartButtonSelectorState;
}

@freezed
abstract class ProfilesSelectorState with _$ProfilesSelectorState {
  const factory ProfilesSelectorState({
    required List<Profile> profiles,
    required String? currentProfileId,
    required int columns,
  }) = _ProfilesSelectorState;
}

@freezed
abstract class NetworkDetectionState with _$NetworkDetectionState {
  const factory NetworkDetectionState({
    required bool isLoading,
    required IpInfo? ipInfo,
    String? errorMessage, // 错误消息，用于显示"请尝试手动刷新"
  }) = _NetworkDetectionState;
}

@freezed
abstract class TrayState with _$TrayState {
  const factory TrayState({
    required Mode mode,
    required int port,
    required bool autoLaunch,
    required bool systemProxy,
    required bool tunEnable,
    required bool isStart,
    required String? locale,
    required Brightness? brightness,
    required List<Group> groups,
    required SelectedMap selectedMap,
    @Default(false) bool wakelockEnabled,
    @Default({}) Map<String, int?> delays,
    @Default(true) bool trayEnhancement,
    @Default(false) bool enableTraySpeed,
  }) = _TrayState;
}

@freezed
abstract class NavigationState with _$NavigationState {
  const factory NavigationState({
    required PageLabel pageLabel,
    required List<NavigationItem> navigationItems,
    required ViewMode viewMode,
    required String? locale,
    required int currentIndex,
  }) = _NavigationState;
}

@freezed
abstract class GroupsState with _$GroupsState {
  const factory GroupsState({required List<Group> value}) = _GroupsState;
}

@freezed
abstract class NavigationItemsState with _$NavigationItemsState {
  const factory NavigationItemsState({required List<NavigationItem> value}) =
      _NavigationItemsState;
}

@freezed
abstract class ProxiesListState with _$ProxiesListState {
  const factory ProxiesListState({
    required List<Group> groups,
    required Set<String> currentUnfoldSet,
    required ProxyCardType proxyCardType,
    required int columns,
  }) = _ProxiesListState;
}

@freezed
abstract class ProxiesTabState with _$ProxiesTabState {
  const factory ProxiesTabState({
    required List<Group> groups,
    required String? currentGroupName,
    required ProxiesSortType proxiesSortType,
    required ProxyCardType proxyCardType,
    required num sortNum,
    required int columns,
  }) = _ProxiesTabState;
}

@freezed
abstract class ProxyGroupSelectorState with _$ProxyGroupSelectorState {
  const factory ProxyGroupSelectorState({
    required String? testUrl,
    required ProxiesSortType proxiesSortType,
    required ProxyCardType proxyCardType,
    required num sortNum,
    required GroupType groupType,
    required List<Proxy> proxies,
    required int columns,
  }) = _ProxyGroupSelectorState;
}

@freezed
abstract class MoreToolsSelectorState with _$MoreToolsSelectorState {
  const factory MoreToolsSelectorState({
    required List<NavigationItem> navigationItems,
  }) = _MoreToolsSelectorState;
}

@freezed
abstract class PackageListSelectorState with _$PackageListSelectorState {
  const factory PackageListSelectorState({
    required List<Package> packages,
    required AccessControl accessControl,
  }) = _PackageListSelectorState;
}

final _packageNameRegex = RegExp(r'^[a-zA-Z0-9_]+(\.[a-zA-Z0-9_]+)+$');

extension PackageListSelectorStateExt on PackageListSelectorState {
  List<Package> get list {
    final isFilterSystemApp = accessControl.isFilterSystemApp;
    final isFilterNonInternetApp = accessControl.isFilterNonInternetApp;
    return packages
        .where(
          (item) =>
              (isFilterSystemApp ? item.system == false : true) &&
              (isFilterNonInternetApp ? item.internet == true : true),
        )
        .toList();
  }

  List<Package> getSortList(List<String> selectedList) {
    final sort = accessControl.sort;
    final filtered = list;
    final existingPackageNames = {for (final e in packages) e.packageName};
    final manualPackages = accessControl.manualList
        .where(
          (pkg) =>
              !existingPackageNames.contains(pkg) &&
              _packageNameRegex.hasMatch(pkg),
        )
        .map(
          (pkg) => Package(
            packageName: pkg,
            label: '[Manual]',
            system: false,
            internet: true,
            lastUpdateTime: 0,
          ),
        );

    final combined = [...filtered, ...manualPackages];
    final selectedSet = selectedList.toSet();
    int comparePackages(Package a, Package b) {
      final isSelectA = selectedSet.contains(a.packageName);
      final isSelectB = selectedSet.contains(b.packageName);
      if (isSelectA != isSelectB) {
        return isSelectA ? -1 : 1;
      }
      final bySort = switch (sort) {
        AccessSortType.none => utils.sortByChar(
          utils.getPinyin(a.label),
          utils.getPinyin(b.label),
        ),
        AccessSortType.installTime => b.firstInstallTime.compareTo(
          a.firstInstallTime,
        ),
        AccessSortType.updateTime => b.lastUpdateTime.compareTo(
          a.lastUpdateTime,
        ),
      };
      if (bySort != 0) {
        return bySort;
      }
      return a.packageName.compareTo(b.packageName);
    }

    return combined..sort(comparePackages);
  }
}

@freezed
abstract class ProxiesActionsState with _$ProxiesActionsState {
  const factory ProxiesActionsState({
    required PageLabel pageLabel,
    required ProxiesType type,
    required bool hasProviders,
  }) = _ProxiesActionsState;
}

@freezed
abstract class ProxyState with _$ProxyState {
  const factory ProxyState({
    required bool isStart,
    required bool systemProxy,
    required List<String> bypassDomain,
    required int port,
  }) = _ProxyState;
}

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    required List<DashboardWidget> dashboardWidgets,
    required double viewWidth,
  }) = _DashboardState;
}

@freezed
abstract class ProxyCardState with _$ProxyCardState {
  const factory ProxyCardState({required String proxyName, String? testUrl}) =
      _ProxyCardState;
}

@freezed
abstract class VpnState with _$VpnState {
  const factory VpnState({
    required TunStack stack,
    required VpnProps vpnProps,
  }) = _VpnState;
}

@freezed
abstract class ProfileOverrideStateModel with _$ProfileOverrideStateModel {
  const factory ProfileOverrideStateModel({
    ClashConfigSnippet? snippet,
    required Set<String> selectedRules,
    OverrideData? overrideData,
    @Default(false) bool managed,
    @Default({}) Set<String> sharedRules,
  }) = _ProfileOverrideStateModel;
}
