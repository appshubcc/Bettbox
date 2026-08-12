import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/common.dart';
import 'package:bett_box/models/config.dart';
import 'package:bett_box/models/widget.dart';
import 'package:bett_box/providers/providers.dart';
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
    final showHiddenItems = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.showHiddenItems),
    );
    final (scriptOn, compatible) = ref.watch(
      scriptStateProvider.select(
        (s) => (s.currentId != null, s.currentScript?.isCompatibleWithBettbox ?? false),
      ),
    );
    final profileOverride = ref.watch(
      currentProfileProvider.select((p) => p?.useScriptOverride ?? false),
    );
    final hasScriptCustom = scriptOn && compatible && profileOverride;
    final hasGroupCustom =
        !hasScriptCustom && ref.read(currentProfileIdProvider) != null;
    final hasCustom = hasScriptCustom || hasGroupCustom;
    return [
      if (_isTab)
        IconButton(
          onPressed: () {
            _proxiesTabKey.currentState?.scrollToGroupSelected();
          },
          icon: Icon(Icons.adjust, weight: 1),
        ),
      if (hasCustom)
        IconButton(
          onPressed: _handleCustomOptions,
          icon: Icon(Icons.tune),
          tooltip: appLocalizations.custom,
        ),
      CommonPopupBox(
        targetBuilder: (open) {
          return IconButton(
            onPressed: () {
              open(offset: Offset(0, 20));
            },
            icon: Icon(Icons.more_vert),
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
                icon: Icons.style_outlined,
                label: appLocalizations.iconConfiguration,
                onPressed: () {
                  showExtend(
                    context,
                    builder: (_, type) {
                      return AdaptiveSheetScaffold(
                        type: type,
                        body: const _IconConfigView(),
                        title: appLocalizations.iconConfiguration,
                      );
                    },
                  );
                },
              ),
            PopupMenuItemData(
              icon: showHiddenItems
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
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
    if (!_isTab) return null;
    return Consumer(
      builder: (context, ref, _) {
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
    final profileOverride =
        ref.read(currentProfileProvider)?.useScriptOverride ?? false;
    final script = ref.read(scriptStateProvider).currentScript;
    if (script != null && script.isCompatibleWithBettbox && profileOverride) {
      await showScriptCustomOptions(context, ref, script: script);
      return;
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

class _IconConfigView extends ConsumerWidget {
  const _IconConfigView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconMap = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.iconMap),
    );
    return MapInputPage(
      title: appLocalizations.iconConfiguration,
      map: iconMap,
      keyLabel: appLocalizations.regExp,
      valueLabel: appLocalizations.icon,
      titleBuilder: (item) => Text(item.key),
      leadingBuilder: (item) => Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: CommonTargetIcon(src: item.value, size: 42),
      ),
      subtitleBuilder: (item) =>
          Text(item.value, maxLines: 2, overflow: TextOverflow.ellipsis),
      onChange: (value) {
        ref
            .read(proxiesStyleSettingProvider.notifier)
            .updateState((state) => state.copyWith(iconMap: value));
      },
    );
  }
}
