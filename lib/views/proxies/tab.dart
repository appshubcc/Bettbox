import 'dart:math';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/config.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../models/common.dart';
import 'card.dart';
import 'common.dart';

typedef ProxyGroupViewKeyMap =
    Map<String, GlobalObjectKey<_ProxyGroupViewState>>;

class ProxiesTabView extends ConsumerStatefulWidget {
  const ProxiesTabView({super.key});

  static Map<String, PageStorageKey> pageListStoreMap = {};

  @override
  ConsumerState<ProxiesTabView> createState() => ProxiesTabViewState();
}

class ProxiesTabViewState extends ConsumerState<ProxiesTabView>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final _hasMoreButtonNotifier = ValueNotifier<bool>(false);
  final _moreMenuOpenNotifier = ValueNotifier<bool>(false);
  ProxyGroupViewKeyMap _keyMap = {};

  @override
  void initState() {
    super.initState();
    ref.listenManual(proxiesTabControllerStateProvider, (prev, next) {
      if (prev == next) {
        return;
      }
      if (!stringListEquality.equals(prev?.a, next.a)) {
        _destroyTabController();
        final index = next.a.indexWhere((item) => item == next.b);
        if (mounted) {
          setState(() {
            _updateTabController(next.a.length, index);
          });
        }
      }
    }, fireImmediately: true);
    // Listen for groups change from empty to non-empty
    ref.listenManual(groupsProvider, (prev, next) {
      if (prev?.isEmpty == true && next.isNotEmpty) {
        // Force rebuild
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _destroyTabController();
    _hasMoreButtonNotifier.dispose();
    _moreMenuOpenNotifier.dispose();
    super.dispose();
  }

  void scrollToGroupSelected() {
    final currentGroupName = globalState.appController.getCurrentGroupName();
    _keyMap[currentGroupName]?.currentState?.scrollToSelected();
  }

  Future<void> delayTestCurrentGroup() async {
    final currentGroupName = globalState.appController.getCurrentGroupName();
    final currentState = _keyMap[currentGroupName]?.currentState;
    final currentGroups = globalState.appController.getCurrentGroups();
    final group = currentGroups.getGroup(currentGroupName ?? '');
    await delayTest(
      group?.all ?? currentState?.proxies ?? [],
      testUrl: group?.testUrl ?? currentState?.testUrl,
      groupName: currentGroupName,
    );
  }

  Widget _buildMoreButton() {
    return Consumer(
      builder: (_, ref, _) {
        final isMobileView = ref.watch(isMobileViewProvider);
        return IconButton(
          onPressed: _showMoreMenu,
          icon: isMobileView
              ? const Icon(Icons.expand_more)
              : const Icon(Icons.chevron_right),
        );
      },
    );
  }

  Future<void> _openMoreMenu() async {
    _moreMenuOpenNotifier.value = true;
    await _showMoreMenu();
    if (!mounted) return;
    _moreMenuOpenNotifier.value = false;
  }

  Future<void> _showMoreMenu() {
    return showSheet(
      context: context,
      props: const SheetProps(expandable: false),
      builder: (sheetContext, type) {
        return AdaptiveSheetScaffold(
          type: type,
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.paddingOf(sheetContext).bottom,
            ),
            child: Consumer(
              builder: (_, ref, _) {
                final state = ref.watch(proxiesTabControllerStateProvider);
                final groupNames = state.a;
                final currentGroupName = state.b;
                return SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    runSpacing: 8,
                    spacing: 8,
                    children: [
                      for (final groupName in groupNames)
                        SettingTextCard(
                          groupName,
                          onPressed: () {
                            final index = groupNames.indexWhere(
                              (item) => item == groupName,
                            );
                            if (index == -1) return;
                            _tabController?.animateTo(
                              index,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                            );
                            globalState.appController.updateCurrentGroupName(
                              groupName,
                            );
                            Navigator.of(context).pop();
                          },
                          isSelected: groupName == currentGroupName,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          title: appLocalizations.proxyGroup,
        );
      },
    );
  }

  Widget _buildDelayTestButton() {
    return AnimatedBuilder(
      animation: delayTestCoordinator,
      builder: (_, _) {
        final isTesting = delayTestCoordinator.isTesting;
        return IconButton(
          onPressed: isTesting ? null : delayTestCurrentGroup,
          icon: Icon(Icons.network_ping),
          tooltip: appLocalizations.startTest,
        );
      },
    );
  }

  void _tabControllerListener([int? index]) {
    int? groupIndex = index;
    if (groupIndex == -1) {
      return;
    }
    final appController = globalState.appController;
    groupIndex ??= _tabController?.index;
    if (groupIndex == null) {
      return;
    }
    final currentGroups = appController.getCurrentGroups();
    if (groupIndex < 0 || groupIndex >= currentGroups.length) {
      return;
    }
    final currentGroup = currentGroups[groupIndex];
    if (appController.getCurrentGroupName() == currentGroup.name) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      globalState.appController.updateCurrentGroupName(currentGroup.name);
    });
  }

  void _destroyTabController() {
    _tabController?.removeListener(_tabControllerListener);
    _tabController?.dispose();
    _tabController = null;
  }

  void _updateTabController(int length, int index) {
    if (length == 0) {
      _destroyTabController();
      return;
    }
    final realIndex = index == -1 ? 0 : index;
    _tabController ??= TabController(
      length: length,
      initialIndex: realIndex,
      vsync: this,
    );
    _tabControllerListener(realIndex);
    _tabController?.addListener(_tabControllerListener);
  }

  Widget _buildTvTabBar(List<Group> groups) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (scrollNotification) {
        _hasMoreButtonNotifier.value =
            scrollNotification.metrics.maxScrollExtent > 0;
        return false;
      },
      child: ValueListenableBuilder(
        valueListenable: _hasMoreButtonNotifier,
        builder: (_, value, child) {
          return Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              TabBar(
                controller: _tabController,
                padding: EdgeInsets.only(left: 16, right: 48),
                dividerColor: Colors.transparent,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorColor: Colors.transparent,
                labelColor: context.colorScheme.onPrimaryContainer,
                unselectedLabelColor: context.colorScheme.onSurfaceVariant,
                tabs: [
                  for (final group in groups)
                    Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: EmojiText(group.name),
                      ),
                    ),
                ],
              ),
              Positioned(
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [_buildDelayTestButton(), if (value) child!],
                ),
              ),
            ],
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                context.colorScheme.pageColor.opacity10,
                context.colorScheme.pageColor,
              ],
              stops: const [0.0, 0.1],
            ),
          ),
          child: _buildMoreButton(),
        ),
      ),
    );
  }

  Widget _buildGroupTabBar(List<Group> groups) {
    final controller = _tabController;
    if (controller == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
      child: GroupTabBar(
        controller: controller,
        labels: [for (final group in groups) group.name],
        onMore: _openMoreMenu,
        moreOpen: _moreMenuOpenNotifier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeSettingProvider.select((state) => state.textScale));
    final groups = ref.watch(
      proxiesTabStateProvider.select((state) => state.groups),
    );
    final columns = ref.watch(
      proxiesTabStateProvider.select((state) => state.columns),
    );
    final cardType = ref.watch(
      proxiesTabStateProvider.select((state) => state.proxyCardType),
    );

    if (groups.isEmpty) {
      return NullStatus(
        label: appLocalizations.nullTip(appLocalizations.proxies),
        icon: Icons.cloud_off_outlined,
      );
    }
    // Safety check: ensure controller matches groups count
    if (_tabController != null && _tabController!.length != groups.length) {
      _destroyTabController();
      _updateTabController(groups.length, _tabController?.index ?? 0);
    }
    // Also handle case where controller is null but we have groups
    if (_tabController == null && groups.isNotEmpty) {
      _updateTabController(groups.length, 0);
    }

    final ProxyGroupViewKeyMap keyMap = {};
    final children = groups.map((group) {
      final key = _keyMap.putIfAbsent(
        group.name,
        () => GlobalObjectKey<_ProxyGroupViewState>(group.name),
      );
      keyMap[group.name] = key;
      return KeepScope(
        keep: true,
        child: ProxyGroupView(
          key: key,
          group: group,
          columns: columns,
          cardType: cardType,
        ),
      );
    }).toList();
    _keyMap = keyMap;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        globalState.isAndroidTV
            ? _buildTvTabBar(groups)
            : _buildGroupTabBar(groups),
        Expanded(
          child: TabBarView(controller: _tabController, children: children),
        ),
      ],
    );
  }
}

class ProxyGroupView extends ConsumerStatefulWidget {
  final Group group;
  final int columns;
  final ProxyCardType cardType;

  const ProxyGroupView({
    super.key,
    required this.group,
    required this.columns,
    required this.cardType,
  });

  @override
  ConsumerState<ProxyGroupView> createState() => _ProxyGroupViewState();
}

class _ProxyGroupViewState extends ConsumerState<ProxyGroupView> {
  late final ScrollController _controller;

  List<Proxy> proxies = [];
  String? testUrl;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  PageStorageKey _getPageStorageKey() {
    final profile = globalState.config.currentProfile;
    final key =
        '${profile?.id}_${ScrollPositionCacheKeys.proxiesTabList.name}_${widget.group.name}';
    return ProxiesTabView.pageListStoreMap.updateCacheValue(
      key,
      () => PageStorageKey(key),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void scrollToSelected() {
    if (_controller.position.maxScrollExtent == 0) {
      return;
    }
    _controller.animateTo(
      min(
        8 +
            getScrollToSelectedOffset(
              groupName: widget.group.name,
              proxies: proxies,
            ),
        _controller.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeSettingProvider.select((state) => state.textScale));
    final isMobileView = ref.watch(isMobileViewProvider);
    final sortedProxies = ref.watch(
      sortedGroupProxiesProvider(ref.watch(queryProvider), widget.group.name),
    );
    if (sortedProxies == null) {
      return const SizedBox.shrink();
    }
    proxies = sortedProxies;
    testUrl = widget.group.testUrl;
    final baseBottom =
        sortedProxies.isNotEmpty && sortedProxies.length % widget.columns == 0
        ? 88.0
        : 16.0;
    final extra = isMobileView
        ? getFloatingBottomBarReserveHeight(context)
        : 0.0;

    return Align(
      alignment: Alignment.topCenter,
      child: CommonScrollBar(
        controller: _controller,
        child: GridView.builder(
          key: _getPageStorageKey(),
          controller: _controller,
          scrollCacheExtent: const ScrollCacheExtent.viewport(1.0),
          padding: EdgeInsets.only(
            top: 8,
            left: 16,
            right: 16,
            bottom: baseBottom + extra,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.columns,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: getItemHeight(widget.cardType),
          ),
          itemCount: sortedProxies.length,
          itemBuilder: (_, index) {
            final proxy = sortedProxies[index];
            return ProxyCard(
              testUrl: widget.group.testUrl,
              groupType: widget.group.type,
              type: widget.cardType,
              proxy: proxy,
              groupName: widget.group.name,
            );
          },
        ),
      ),
    );
  }
}

class DelayTestButton extends ConsumerStatefulWidget {
  final String groupName;
  final Future Function() onClick;

  const DelayTestButton({
    super.key,
    required this.groupName,
    required this.onClick,
  });

  @override
  ConsumerState<DelayTestButton> createState() => _DelayTestButtonState();
}

class _DelayTestButtonState extends ConsumerState<DelayTestButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  bool get _isTesting => delayTestCoordinator.isTestingGroup(widget.groupName);

  Future<void> _healthcheck() async {
    if (delayTestCoordinator.isTesting) {
      return;
    }
    await widget.onClick();
  }

  void _handleTestingChanged() {
    if (!mounted) return;
    if (_isTesting) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 1)),
    );
    delayTestCoordinator.addListener(_handleTestingChanged);
    _handleTestingChanged();
  }

  @override
  void didUpdateWidget(covariant DelayTestButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupName != widget.groupName) {
      _handleTestingChanged();
    }
  }

  @override
  void dispose() {
    delayTestCoordinator.removeListener(_handleTestingChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appSettingProvider.select((state) => state.locale));
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (_, child) {
        final showLoading = _isTesting && _controller.isCompleted;
        final contentScale = showLoading ? 0.0 : _scale.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            FloatingActionButton.extended(
              heroTag: null,
              onPressed:
                  delayTestCoordinator.isTesting || widget.groupName.isEmpty
                  ? null
                  : _healthcheck,
              icon: Transform.scale(
                scale: contentScale,
                child: const Icon(Icons.network_ping),
              ),
              label: Transform.scale(
                scale: contentScale,
                child: Text(appLocalizations.startTest),
              ),
            ),
            if (showLoading)
              IgnorePointer(
                child: SizedBox(
                  width: 30,
                  height: 16,
                  child: OverflowBox(
                    maxWidth: 30,
                    maxHeight: 16,
                    child: SpinKitThreeBounce(
                      color: context.colorScheme.onPrimaryContainer,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
