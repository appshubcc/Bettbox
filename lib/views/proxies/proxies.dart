import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/common.dart';
import 'package:bett_box/models/config.dart';
import 'package:bett_box/models/profile.dart';
import 'package:bett_box/models/widget.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/proxies/list.dart';
import 'package:bett_box/views/proxies/providers.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profiles/scripts.dart'
    show showGroupSwitchOptions, showScriptCustomOptions;
import 'advanced_settings.dart';
import 'setting.dart';
import 'tab.dart';

/// 代理页右上角「自定义」应该打开哪个面板。
///
/// 合并配置的产物是内置脚本跑出来的，它的自定义就是**内置脚本的自定义开关**
/// （和脚本菜单里点内置脚本的自定义是同一个面板）。
enum CustomOptionsTarget {
  /// 当前全局脚本的自定义开关。
  script,

  /// 内置脚本的自定义开关（合并配置）。
  builtinScript,

  /// 配置自身的策略组开关。
  groupSwitches,
}

/// 决定「自定义」入口的目标面板。
///
/// 只在有当前配置时才会被调用（没有当前配置就没有可自定义的东西）。
CustomOptionsTarget resolveCustomOptionsTarget({
  required bool isBundle,
  required bool builtinScriptCompatible,
  required bool scriptOn,
  required bool scriptCompatible,
  required bool useScriptOverride,
}) {
  if (isBundle) {
    // 内置脚本被改得不再兼容时退回策略组开关，保证入口不会点了没反应
    return builtinScriptCompatible
        ? CustomOptionsTarget.builtinScript
        : CustomOptionsTarget.groupSwitches;
  }
  if (scriptOn && scriptCompatible && useScriptOverride) {
    return CustomOptionsTarget.script;
  }
  return CustomOptionsTarget.groupSwitches;
}

class ProxiesView extends ConsumerStatefulWidget {
  const ProxiesView({super.key});

  @override
  ConsumerState<ProxiesView> createState() => _ProxiesViewState();
}

class _ProxiesViewState extends ConsumerState<ProxiesView> {
  final GlobalKey<ProxiesTabViewState> _proxiesTabKey = GlobalKey();
  bool _hasProviders = false;
  bool _isTab = false;

  List<Widget> _buildActions() {
    final (autoStickyHeader, showHiddenItems) = ref.watch(
      proxiesStyleSettingProvider.select(
        (state) => (state.autoStickyHeader, state.showHiddenItems),
      ),
    );
    final hasProfile = ref.watch(currentProfileIdProvider) != null;
    return [
      if (_isTab)
        IconButton(
          onPressed: () {
            _proxiesTabKey.currentState?.scrollToGroupSelected();
          },
          tooltip: appLocalizations.locate,
          icon: const Icon(Icons.adjust, weight: 1),
        ),
      // 没有当前配置就没有可自定义的东西；具体打开哪个面板在点击时再判定
      if (hasProfile)
        IconButton(
          onPressed: _handleCustomOptions,
          icon: const Icon(Icons.tune),
          tooltip: appLocalizations.custom,
        ),
      CommonPopupBox(
        targetBuilder: (open) {
          return IconButton(
            onPressed: () {
              open(offset: const Offset(0, 20));
            },
            tooltip: appLocalizations.more,
            icon: const Icon(Icons.more_vert),
          );
        },
        popup: CommonPopupMenu(
          items: [
            PopupMenuItemData(
              icon: Icons.tune,
              label: appLocalizations.settings,
              onPressed: () {
                showSheet(
                  context: context,
                  props: SheetProps(isScrollControlled: true),
                  builder: (_, type) {
                    return AdaptiveSheetScaffold(
                      type: type,
                      body: const ProxiesSetting(),
                      title: appLocalizations.settings,
                    );
                  },
                );
              },
            ),
            if (_hasProviders)
              PopupMenuItemData(
                icon: Icons.poll_outlined,
                label: appLocalizations.providers,
                onPressed: () {
                  showExtend(
                    context,
                    builder: (_, type) {
                      return ProvidersView(type: type);
                    },
                  );
                },
              ),
            PopupMenuItemData(
              icon: Icons.settings_suggest,
              label: appLocalizations.advancedSettings,
              onPressed: () {
                showExtend(
                  context,
                  builder: (_, type) {
                    return AdaptiveSheetScaffold(
                      type: type,
                      body: const ProxiesAdvancedSettings(),
                      title: appLocalizations.advancedSettings,
                    );
                  },
                );
              },
            ),
            if (!_isTab)
              PopupMenuItemData(
                icon: autoStickyHeader
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                label: appLocalizations.autoStickyHeader,
                onPressed: () {
                  ref
                      .read(proxiesStyleSettingProvider.notifier)
                      .updateState(
                        (state) =>
                            state.copyWith(autoStickyHeader: !autoStickyHeader),
                      );
                },
              ),
            PopupMenuItemData(
              icon: showHiddenItems
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              label: appLocalizations.showHiddenItems,
              onPressed: () {
                ref
                    .read(proxiesStyleSettingProvider.notifier)
                    .updateState(
                      (state) =>
                          state.copyWith(showHiddenItems: !showHiddenItems),
                    );
              },
            ),
          ],
        ),
      ),
    ];
  }

  Widget? _buildFAB() {
    if (!_isTab || globalState.isAndroidTV) return null;
    return Consumer(
      builder: (_, ref, _) {
        final isMobileView = ref.watch(isMobileViewProvider);
        final currentGroupName = ref.watch(
          proxiesTabControllerStateProvider.select((state) => state.b),
        );
        return Padding(
          padding: EdgeInsets.only(
            bottom: isMobileView
                ? getFloatingBottomBarFABReserveHeight(context)
                : 0,
          ),
          child: DelayTestButton(
            groupName: currentGroupName ?? '',
            onClick: () async {
              await _proxiesTabKey.currentState?.delayTestCurrentGroup();
            },
          ),
        );
      },
    );
  }

  void _onSearch(String value) {
    ref.read(queryProvider.notifier).value = value;
  }

  Future<void> _handleCustomOptions() async {
    final profile = ref.read(currentProfileProvider);
    final scriptState = ref.read(scriptStateProvider);
    final builtinIndex = scriptState.scripts.indexWhere(
      (item) => item.id == builtinScriptId,
    );
    final target = resolveCustomOptionsTarget(
      isBundle: profile?.isBundle ?? false,
      builtinScriptCompatible:
          builtinIndex != -1 &&
          scriptState.scripts[builtinIndex].isCompatibleWithBettbox,
      scriptOn: scriptState.currentId != null,
      scriptCompatible:
          scriptState.currentScript?.isCompatibleWithBettbox ?? false,
      useScriptOverride: profile?.useScriptOverride ?? false,
    );
    if (target == CustomOptionsTarget.builtinScript) {
      // 与脚本菜单里点内置脚本的「自定义」完全同一个面板，改完会触发重新合并
      final builtin = builtinIndex == -1
          ? null
          : scriptState.scripts[builtinIndex];
      if (builtin != null) {
        await showScriptCustomOptions(context, ref, script: builtin);
        return;
      }
    } else if (target == CustomOptionsTarget.script) {
      final script = scriptState.currentScript;
      if (script != null && script.isCompatibleWithBettbox) {
        await showScriptCustomOptions(context, ref, script: script);
        return;
      }
    }
    final profileId = ref.read(currentProfileIdProvider);
    if (profileId != null) {
      await showGroupSwitchOptions(context, ref, profileId: profileId);
    }
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual(providersProvider.select((state) => state.isNotEmpty), (
      prev,
      next,
    ) {
      if (prev != next) {
        setState(() {
          _hasProviders = next;
        });
      }
    }, fireImmediately: true);
    ref.listenManual(
      proxiesStyleSettingProvider.select(
        (state) => state.type == ProxiesType.tab,
      ),
      (prev, next) {
        if (prev != next) {
          setState(() {
            _isTab = next;
          });
        }
      },
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final proxiesType = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.type),
    );
    final hasGroups = ref.watch(
      groupsProvider.select((state) => state.isNotEmpty),
    );
    ref.watch(appSettingProvider.select((state) => state.locale));
    return CommonScaffold(
      floatingActionButton: _buildFAB(),
      actions: _buildActions(),
      title: appLocalizations.proxies,
      searchState: AppBarSearchState(onSearch: _onSearch),
      body: switch (hasGroups) {
        false => NullStatus(label: appLocalizations.noProxy),
        true => switch (proxiesType) {
          ProxiesType.tab => ProxiesTabView(key: _proxiesTabKey),
          ProxiesType.list => const ProxiesListView(),
        },
      },
    );
  }
}

