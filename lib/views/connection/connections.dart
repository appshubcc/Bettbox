import 'dart:async';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'item.dart';

enum _ConnectionsTab { active, closed, all }

class ConnectionsView extends ConsumerStatefulWidget {
  final bool respectCurrentPage;

  const ConnectionsView({super.key, this.respectCurrentPage = true});

  @override
  ConsumerState<ConnectionsView> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends ConsumerState<ConnectionsView>
    with WidgetsBindingObserver, WindowListener {
  late final ScrollController _scrollController;
  Timer? _timer;
  ProviderSubscription? _pageLabelSubscription;
  var _isScrolling = false;
  var _isTrackingRequests = false;
  var _autoScrollToEnd = false;
  var _tab = _ConnectionsTab.active;
  List<TrackerInfo>? _pendingConnections;

  bool get _isForeground {
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    return lifecycleState == null ||
        lifecycleState == AppLifecycleState.resumed;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    globalState.backgroundMode.addListener(_handleBackgroundModeChanged);
    if (system.isDesktop) {
      windowManager.addListener(this);
    }
    _pageLabelSubscription = ref.listenManual(currentPageLabelProvider, (
      prev,
      next,
    ) {
      if (prev != next) {
        unawaited(_syncUpdateTimer());
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.afterRouteTransition(() => unawaited(_syncUpdateTimer()));
    });
  }

  @override
  void dispose() {
    _pageLabelSubscription?.close();
    globalState.backgroundMode.removeListener(_handleBackgroundModeChanged);
    if (system.isDesktop) {
      windowManager.removeListener(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _stopTrackRequests();
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _shouldRunTimer() async {
    if (!mounted) return false;
    if (globalState.backgroundMode.value) {
      return false;
    }
    if (widget.respectCurrentPage &&
        ref.read(currentPageLabelProvider) != PageLabel.connections) {
      return false;
    }
    if (!_isForeground) {
      return false;
    }
    if (system.isDesktop && await window?.isVisible == false) {
      return false;
    }
    return true;
  }

  void _stopUpdate() {
    _timer?.cancel();
    _timer = null;
    _stopTrackRequests();
  }

  Future<void> _syncUpdateTimer() async {
    final shouldRun = await _shouldRunTimer();
    if (!mounted) return;
    if (!shouldRun) {
      _stopUpdate();
      return;
    }
    if (_timer != null) {
      return;
    }
    unawaited(_startTrackRequests());
    await _updateConnections();
    if (!mounted || !await _shouldRunTimer()) {
      return;
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_updateConnections());
    });
  }

  bool _isSameRequests(List<TrackerInfo> a, List<TrackerInfo> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  Future<void> _startTrackRequests() async {
    if (_isTrackingRequests) return;
    _isTrackingRequests = true;
    clashCore.startTrackRequests();
    final history = await clashCore.getRequests();
    if (!mounted || history.isEmpty) return;
    final current = ref.read(requestsProvider).list;
    if (_isSameRequests(current, history)) return;
    ref.read(requestsProvider.notifier).setRequests(history);
  }

  void _stopTrackRequests() {
    if (!_isTrackingRequests) return;
    _isTrackingRequests = false;
    clashCore.stopTrackRequests();
  }

  void _applyPendingConnections() {
    if (_pendingConnections != null) {
      ref.read(connectionsProvider.notifier).state = _pendingConnections!;
      _pendingConnections = null;
    }
  }

  Future<void> _updateConnections() async {
    if (!mounted || !await _shouldRunTimer()) {
      _stopUpdate();
      return;
    }
    final connections = await clashCore.getConnections();
    if (!mounted || !await _shouldRunTimer()) {
      _stopUpdate();
      return;
    }
    final oldConnections = ref.read(connectionsProvider);
    final oldMap = {for (final e in oldConnections) e.id: e};
    var hasChanges = oldConnections.length != connections.length;
    final newConnections = connections.map((item) {
      final oldItem = oldMap[item.id];
      if (oldItem != null) {
        final upSpeed = item.upload - oldItem.upload;
        final downSpeed = item.download - oldItem.download;
        final newItem = item.copyWith(
          uploadSpeed: upSpeed > 0 ? upSpeed : 0,
          downloadSpeed: downSpeed > 0 ? downSpeed : 0,
        );
        if (newItem != oldItem) hasChanges = true;
        return newItem;
      }
      hasChanges = true;
      return item.copyWith(uploadSpeed: 0, downloadSpeed: 0);
    }).toList();
    if (hasChanges) {
      if (_isScrolling) {
        _pendingConnections = newConnections;
      } else {
        ref.read(connectionsProvider.notifier).state = newConnections;
      }
    }
  }

  void _handleBackgroundModeChanged() {
    unawaited(_syncUpdateTimer());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(_syncUpdateTimer());
  }

  @override
  void onWindowMinimize() {
    unawaited(_syncUpdateTimer());
  }

  @override
  void onWindowRestore() {
    unawaited(_syncUpdateTimer());
  }

  Future<void> _handleBlockConnection(String id) async {
    clashCore.closeConnection(id);
    _isScrolling = false;
    _pendingConnections = null;
    await _updateConnections();
  }

  void _handleCloseAll() async {
    unawaited(
      clashCore.closeConnections().then<void>(
        (_) {},
        onError: (Object e) =>
            commonPrint.debug('closeConnections ignored: $e'),
      ),
    );
    _isScrolling = false;
    _pendingConnections = null;
    await _updateConnections();
  }

  void _handleClearClosed() {
    ref.read(requestsProvider.notifier).clearRequests();
    clashCore.clearRequests();
  }

  Future<void> _handleSort() async {
    final currentSortType = ref.read(connectionsSortProvider);
    final selectedSortType = await globalState
        .showCommonDialog<ConnectionsSortType>(
          child: OptionsDialog<ConnectionsSortType>(
            title: appLocalizations.connectionsSort,
            options: ConnectionsSortType.values
                .where(
                  (sortType) => sortType != ConnectionsSortType.creationTime,
                )
                .toList(),
            value: currentSortType,
            textBuilder: (sortType) {
              return switch (sortType) {
                ConnectionsSortType.defaultSort => appLocalizations.defaultSort,
                ConnectionsSortType.realTimeSpeed =>
                  appLocalizations.realTimeSpeed,
                ConnectionsSortType.totalTraffic =>
                  appLocalizations.totalTraffic,
                ConnectionsSortType.creationTime =>
                  appLocalizations.creationTime,
              };
            },
          ),
        );
    if (selectedSortType != null && selectedSortType != currentSortType) {
      ref.read(connectionsSortProvider.notifier).state = selectedSortType;
    }
  }

  void _onSearch(String value) {
    ref.read(connectionsSearchProvider.notifier).state = value;
  }

  void _onKeywordsUpdate(List<String> keywords) {
    final notifier = ref.read(connectionsKeywordsProvider.notifier);
    if (listEquals(notifier.state, keywords)) return;
    notifier.state = keywords;
  }

  void _handleTabChanged(_ConnectionsTab tab) {
    if (tab == _tab) return;
    setState(() {
      _tab = tab;
      _autoScrollToEnd = false;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _toggleAutoScroll() {
    setState(() {
      _autoScrollToEnd = !_autoScrollToEnd;
    });
  }

  void _cancelAutoScroll() {
    if (_autoScrollToEnd) {
      setState(() {
        _autoScrollToEnd = false;
      });
    }
  }

  List<Widget> _buildActions() {
    if (_tab == _ConnectionsTab.closed) {
      return [
        IconButton(
          onPressed: _handleClearClosed,
          tooltip: appLocalizations.clear,
          icon: const Icon(Icons.delete_sweep_outlined),
        ),
        IconButton(
          style: _autoScrollToEnd
              ? ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    context.colorScheme.secondaryContainer,
                  ),
                )
              : null,
          onPressed: _toggleAutoScroll,
          tooltip: appLocalizations.autoScroll,
          icon: const Icon(Icons.vertical_align_top_outlined),
        ),
      ];
    }
    return [
      IconButton(
        onPressed: _handleCloseAll,
        tooltip: appLocalizations.closeAll,
        icon: const Icon(Icons.delete_sweep_outlined),
      ),
      IconButton(
        tooltip: appLocalizations.connectionsSort,
        onPressed: _handleSort,
        icon: const Icon(Icons.sort),
      ),
    ];
  }

  Widget _buildTabs() {
    return Consumer(
      builder: (_, ref, _) {
        final activeCount = ref.watch(
          filteredConnectionsProvider.select((state) => state.length),
        );
        final closedCount = ref.watch(
          filteredRequestsProvider.select((state) => state.length),
        );
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Row(
            spacing: 8,
            children: [
              for (final tab in _ConnectionsTab.values)
                FilterChip(
                  selected: tab == _tab,
                  showCheckmark: false,
                  label: Text(switch (tab) {
                    _ConnectionsTab.active =>
                      '${appLocalizations.connectionsActive} $activeCount',
                    _ConnectionsTab.closed =>
                      '${appLocalizations.connectionsClosed} $closedCount',
                    _ConnectionsTab.all => appLocalizations.categoryAll,
                  }),
                  onSelected: (_) => _handleTabChanged(tab),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlockButton(String id) {
    return InkResponse(
      radius: 12,
      onTap: () => _handleBlockConnection(id),
      child: SizedBox.square(
        dimension: 40,
        child: Icon(Icons.block, color: context.colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildClosedMark() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        appLocalizations.connectionsClosed,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildItem({
    required TrackerInfo trackerInfo,
    required int index,
    required int count,
    required bool closed,
    required bool showSpeed,
    required bool markClosed,
  }) {
    final item = TrackerInfoItem(
      key: ValueKey(trackerInfo.id),
      index: index,
      count: count,
      showSpeed: !closed && showSpeed,
      trackerInfo: trackerInfo,
      onClickKeyword: (value) {
        context.commonScaffoldState?.addKeyword(value);
      },
      trailing: closed
          ? (markClosed ? _buildClosedMark() : null)
          : _buildBlockButton(trackerInfo.id),
      detailTitle: appLocalizations.details,
    );
    if (!markClosed || !closed) return item;
    return Opacity(key: ValueKey(trackerInfo.id), opacity: 0.6, child: item);
  }

  Widget _buildList({
    required int count,
    required String Function(int index) idOf,
    required Widget Function(int index) itemOf,
    bool autoScroll = false,
    List<Object>? dataSource,
  }) {
    if (count == 0) {
      return NullStatus(
        label: appLocalizations.nullTip(appLocalizations.connections),
      );
    }
    Map<String, int>? indexById;
    final scrollView = RouteScrollCacheBuilder(
      builder: (_, cacheExtent) => CustomScrollView(
        controller: _scrollController,
        physics: const NextClampingScrollPhysics(),
        scrollCacheExtent: cacheExtent,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            sliver: SliverFixedExtentList(
              itemExtent: TrackerInfoItem.height + 1,
              delegate: SliverChildBuilderDelegate(
                (_, index) => itemOf(index),
                childCount: count,
                findChildIndexCallback: (key) {
                  indexById ??= {for (var i = 0; i < count; i++) idOf(i): i};
                  return indexById![(key as ValueKey<String>).value];
                },
              ),
            ),
          ),
        ],
      ),
    );
    return CommonScrollBar(
      controller: _scrollController,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            _isScrolling = true;
          } else if (notification is ScrollEndNotification) {
            _isScrolling = false;
            _applyPendingConnections();
          }
          return false;
        },
        child: autoScroll && dataSource != null
            ? ScrollToEndBox(
                controller: _scrollController,
                dataSource: dataSource,
                enable: _autoScrollToEnd,
                reverse: false,
                onCancelToEnd: _cancelAutoScroll,
                child: scrollView,
              )
            : scrollView,
      ),
    );
  }

  Widget _buildActiveList() {
    return Consumer(
      builder: (_, ref, _) {
        final connections = ref.watch(filteredConnectionsProvider);
        final showSpeed =
            ref.watch(connectionsSortProvider) !=
            ConnectionsSortType.totalTraffic;
        return _buildList(
          count: connections.length,
          idOf: (index) => connections[index].id,
          itemOf: (index) => _buildItem(
            trackerInfo: connections[index],
            index: index,
            count: connections.length,
            closed: false,
            showSpeed: showSpeed,
            markClosed: false,
          ),
        );
      },
    );
  }

  Widget _buildClosedList() {
    return Consumer(
      builder: (_, ref, _) {
        final requests = ref.watch(filteredRequestsProvider);
        ref.listen<List<TrackerInfo>>(filteredRequestsProvider, (prev, next) {
          if (prev == null || prev.isEmpty || next.isEmpty) return;
          if (_autoScrollToEnd ||
              !_scrollController.hasClients ||
              _scrollController.offset <= 0 ||
              next.last.id == prev.last.id) {
            return;
          }
          final prevLastId = prev.last.id;
          final index = next.indexWhere((r) => r.id == prevLastId);
          final addedCount = index == -1
              ? next.length - prev.length
              : next.length - 1 - index;
          if (addedCount > 0) {
            final delta = addedCount * (TrackerInfoItem.height + 1);
            _scrollController.jumpTo(_scrollController.offset + delta);
          }
        });
        final count = requests.length;
        return _buildList(
          count: count,
          autoScroll: true,
          dataSource: requests,
          idOf: (index) => requests[count - 1 - index].id,
          itemOf: (index) => _buildItem(
            trackerInfo: requests[count - 1 - index],
            index: index,
            count: count,
            closed: true,
            showSpeed: false,
            markClosed: false,
          ),
        );
      },
    );
  }

  Widget _buildAllList() {
    return Consumer(
      builder: (_, ref, _) {
        final items = ref.watch(filteredAllConnectionsProvider);
        final showSpeed =
            ref.watch(connectionsSortProvider) !=
            ConnectionsSortType.totalTraffic;
        return _buildList(
          count: items.length,
          idOf: (index) => items[index].info.id,
          itemOf: (index) => _buildItem(
            trackerInfo: items[index].info,
            index: index,
            count: items.length,
            closed: items[index].closed,
            showSpeed: showSpeed,
            markClosed: true,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: appLocalizations.connections,
      keywords: ref.watch(connectionsKeywordsProvider),
      onKeywordsUpdate: _onKeywordsUpdate,
      searchState: AppBarSearchState(onSearch: _onSearch),
      actions: _buildActions(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTabs(),
          Expanded(
            child: switch (_tab) {
              _ConnectionsTab.active => _buildActiveList(),
              _ConnectionsTab.closed => _buildClosedList(),
              _ConnectionsTab.all => _buildAllList(),
            },
          ),
        ],
      ),
    );
  }
}
