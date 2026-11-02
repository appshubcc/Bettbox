import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/common.dart';
import 'package:bett_box/models/profile.dart';
import 'package:bett_box/models/widget.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/proxies/list.dart';
import 'package:bett_box/views/proxies/providers.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profiles/managed_options.dart' show showManagedOptions;
import '../profiles/scripts.dart'
    show showGroupSwitchOptions, showScriptCustomOptions;
import 'advanced_settings.dart';
import 'setting.dart';
import 'tab.dart';

class ProxiesView extends ConsumerStatefulWidget {
  const ProxiesView({super.key});

  @override
  ConsumerState<ProxiesView> createState() => _ProxiesViewState();
}

class _ProxiesViewState extends ConsumerState<ProxiesView> {
  final GlobalKey<ProxiesTabViewState> _proxiesTabKey = GlobalKey();
  final GlobalKey<ProxiesListViewState> _proxiesListKey = GlobalKey();
  bool _hasProviders = false;
  bool _isTab = false;

  List<Widget> _buildActions() {
    final (autoStickyHeader, showHiddenItems, hideTimeoutProxies) = ref.watch(
      proxiesStyleSettingProvider.select(
        (state) => (
          state.autoStickyHeader,
          state.showHiddenItems,
          state.hideTimeoutProxies,
        ),
      ),
    );
    final compatible = ref.watch(
      currentProfileScriptProvider.select(
        (script) => script?.compatible ?? false,
      ),
    );
    final managed = ref.watch(
      currentProfileProvider.select((p) => p?.isManaged ?? false),
    );
    final hasScriptCustom = managed || compatible;
    final hasGroupCustom =
        !hasScriptCustom && ref.read(currentProfileIdProvider) != null;
    final hasCustom = hasScriptCustom || hasGroupCustom;
    return [
      if (_isTab)
        IconButton(
          onPressed: () {
            _proxiesTabKey.currentState?.scrollToGroupSelected();
          },
          tooltip: appLocalizations.locate,
          icon: const Icon(Icons.adjust, weight: 1),
        ),
      if (hasCustom)
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
            PopupMenuItemData(
              icon: hideTimeoutProxies
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              label: appLocalizations.hideTimeoutProxies,
              onPressed: () {
                ref
                    .read(proxiesStyleSettingProvider.notifier)
                    .updateState(
                      (state) => state.copyWith(
                        hideTimeoutProxies: !hideTimeoutProxies,
                      ),
                    );
                globalState.appController.addSortNum();
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

  void _collapseAllGroups() {
    _proxiesListKey.currentState?.collapseAll();
  }

  void _onSearch(String value) {
    ref.read(queryProvider.notifier).value = value;
  }

  Future<void> _handleCustomOptions() async {
    final profile = ref.read(currentProfileProvider);
    if (profile?.isManaged ?? false) {
      await showManagedOptions(context);
      return;
    }
    final script = ref.read(currentProfileScriptProvider);
    if (script != null && script.compatible) {
      await showScriptCustomOptions(context, script: script);
      return;
    }
    final profileId = ref.read(currentProfileIdProvider);
    if (profileId != null) {
      await showGroupSwitchOptions(context, profileId: profileId);
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
    final (proxiesType, autoStickyHeader) = ref.watch(
      proxiesStyleSettingProvider.select(
        (state) => (state.type, state.autoStickyHeader),
      ),
    );
    final hasGroups = ref.watch(
      groupsProvider.select((state) => state.isNotEmpty),
    );
    ref.watch(appSettingProvider.select((state) => state.locale));
    return CommonScaffold(
      floatingActionButton: _buildFAB(),
      actions: _buildActions(),
      title: appLocalizations.proxies,
      scrollEdgeFade: proxiesType == ProxiesType.list && !autoStickyHeader,
      onAppBarDoubleTap: proxiesType == ProxiesType.list
          ? _collapseAllGroups
          : null,
      searchState: AppBarSearchState(onSearch: _onSearch),
      body: switch (hasGroups) {
        false => NullStatus(
          label: appLocalizations.noProxy,
          icon: Icons.cloud_off_outlined,
          description: appLocalizations.noProxyDesc,
          action: FilledButton.tonalIcon(
            onPressed: globalState.appController.toProfiles,
            icon: const Icon(Icons.add, size: 18),
            label: Text(appLocalizations.addProfile),
          ),
        ),
        true => switch (proxiesType) {
          ProxiesType.tab => ProxiesTabView(key: _proxiesTabKey),
          ProxiesType.list => ProxiesListView(key: _proxiesListKey),
        },
      },
    );
  }
}
