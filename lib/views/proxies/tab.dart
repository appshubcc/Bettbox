import 'dart:math';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/config.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
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
    super.dispose();
  }

  void scrollToGroupSelected() {
    final currentGroupName = globalState.appController.getCurrentGroupName();
    _keyMap[currentGroupName]?.currentState?.scrollToSelected();
  }

  Future<void> delayTestCurrentGroup() async {
    final currentGroupName = globalState.appController.getCurrentGroupName();
    final currentState = _keyMap[currentGroupName]?.currentState;
    await delayTest(
      currentState?.proxies ?? [],
      testUrl: currentState?.testUrl,
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

  void _showMoreMenu() {
    showSheet(
      context: context,
      props: SheetProps(isScrollControlled: false),
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                            _tabController?.animateTo(index);
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
    if (groupIndex == null) {
      final controller = _tabController;
      if (controller == null) return;
      final anim = controller.animation;
      if (anim != null && anim.value != controller.index.toDouble()) {
        return;
      }
      groupIndex = controller.index;
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
    final sortType = ref.watch(
      proxiesTabStateProvider.select((state) => state.proxiesSortType),
    );
    final sortNum = ref.watch(
      proxiesTabStateProvider.select((state) => state.sortNum),
    );

    if (groups.isEmpty) {
      return NullStatus(
        label: appLocalizations.nullTip(appLocalizations.proxies),
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
      final key = GlobalObjectKey<_ProxyGroupViewState>(group.name);
      keyMap[group.name] = key;
      return KeepScope(
        keep: true,
        child: ProxyGroupView(
          key: key,
          group: group,
          columns: columns,
          cardType: cardType,
          sortType: sortType,
          sortNum: sortNum,
        ),
      );
    }).toList();
    _keyMap = keyMap;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotificationListener<ScrollMetricsNotification>(
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
                    padding: EdgeInsets.only(
                      left: 16,
                      right: globalState.isAndroidTV ? 48 : (value ? 48 : 0),
                    ),
                    dividerColor: Colors.transparent,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    overlayColor: globalState.isAndroidTV
                        ? null
                        : const WidgetStatePropertyAll(Colors.transparent),
                    indicator: globalState.isAndroidTV
                        ? BoxDecoration(
                            color: context.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    indicatorColor: globalState.isAndroidTV
                        ? Colors.transparent
                        : context.colorScheme.primary,
                    labelColor: globalState.isAndroidTV
                        ? context.colorScheme.onPrimaryContainer
                        : context.colorScheme.primary,
                    unselectedLabelColor: context.colorScheme.onSurfaceVariant,
                    tabs: [
                      for (final group in groups)
                        Tab(
                          child: Padding(
                            padding: globalState.isAndroidTV
                                ? const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  )
                                : EdgeInsets.zero,
                            child: EmojiText(group.name),
                          ),
                        ),
                    ],
                  ),
                  if (globalState.isAndroidTV)
                    Positioned(
                      right: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [_buildDelayTestButton(), if (value) child!],
                      ),
                    )
                  else if (value)
                    Positioned(right: 0, child: child!),
                ],
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    context.colorScheme.surface.opacity10,
                    context.colorScheme.surface,
                  ],
                  stops: const [0.0, 0.1],
                ),
              ),
              child: _buildMoreButton(),
            ),
          ),
        ),
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
  final ProxiesSortType sortType;
  final num sortNum;

  const ProxyGroupView({
    super.key,
    required this.group,
    required this.columns,
    required this.cardType,
    required this.sortType,
    required this.sortNum,
  });

  @override
  ConsumerState<ProxyGroupView> createState() => _ProxyGroupViewState();
}

class _ProxyGroupViewState extends ConsumerState<ProxyGroupView> {
  late final ScrollController _controller;

  List<Proxy> proxies = [];
  String? testUrl;
  List<Proxy>? _cachedSortedProxies;
  ProxiesSortType? _lastSortType;
  List<Proxy>? _lastProxies;
  String? _lastTestUrl;
  num? _lastSortNum;

  List<Proxy> _getSortedProxies() {
    final group = widget.group;
    final sortType = widget.sortType;
    final proxies = group.all;
    final testUrl = group.testUrl;
    final sortNum = widget.sortNum;
    if (_cachedSortedProxies != null &&
        _lastSortType == sortType &&
        _lastTestUrl == testUrl &&
        _lastProxies == proxies &&
        _lastSortNum == sortNum) {
      return _cachedSortedProxies!;
    }
    _lastSortType = sortType;
    _lastTestUrl = testUrl;
    _lastProxies = proxies;
    _lastSortNum = sortNum;
    _cachedSortedProxies = globalState.appController.getSortProxies(
      proxies: proxies,
      sortType: sortType,
      testUrl: testUrl,
    );
    return _cachedSortedProxies!;
  }

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
        16 +
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
    final sortedProxies = _getSortedProxies();
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
          cacheExtent: MediaQuery.sizeOf(context).height,
          padding: EdgeInsets.only(
            top: 16,
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
