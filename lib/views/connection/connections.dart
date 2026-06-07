import 'dart:async';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'item.dart';

class ConnectionsView extends ConsumerStatefulWidget {
  final bool respectCurrentPage;

  const ConnectionsView({
    super.key,
    this.respectCurrentPage = true,
  });

  @override
  ConsumerState<ConnectionsView> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends ConsumerState<ConnectionsView>
    with WidgetsBindingObserver, WindowListener {
  late final ScrollController _scrollController;
  Timer? _timer;
  ProviderSubscription? _pageLabelSubscription;

  bool get _isForeground {
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    return lifecycleState == null || lifecycleState == AppLifecycleState.resumed;
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
      unawaited(_syncUpdateTimer());
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

  Future<void> _syncUpdateTimer() async {
    final shouldRun = await _shouldRunTimer();
    if (!mounted) return;
    if (!shouldRun) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    if (_timer != null) {
      return;
    }
    await _updateConnections();
    if (!mounted || !await _shouldRunTimer()) {
      return;
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_updateConnections());
    });
  }

  Future<void> _updateConnections() async {
    if (!mounted || !await _shouldRunTimer()) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    final connections = await clashCore.getConnections();
    if (!mounted || !await _shouldRunTimer()) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    final oldConnections = ref.read(connectionsProvider);
    final oldMap = {for (final e in oldConnections) e.id: e};
    final newConnections = connections.map((item) {
      final oldItem = oldMap[item.id];
      if (oldItem != null) {
        final upSpeed = item.upload - oldItem.upload;
        final downSpeed = item.download - oldItem.download;
        return item.copyWith(
          uploadSpeed: upSpeed > 0 ? upSpeed : 0,
          downloadSpeed: downSpeed > 0 ? downSpeed : 0,
        );
      }
      return item.copyWith(uploadSpeed: 0, downloadSpeed: 0);
    }).toList();
    ref.read(connectionsProvider.notifier).state = newConnections;
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
    await _updateConnections();
  }

  void _handleCloseAll() async {
    clashCore.closeConnections();
    await _updateConnections();
  }

  void _onSearch(String value) {
    ref.read(connectionsSearchProvider.notifier).state = value;
  }

  void _onKeywordsUpdate(List<String> keywords) {
    ref.read(connectionsKeywordsProvider.notifier).state = keywords;
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: appLocalizations.connections,
      onKeywordsUpdate: _onKeywordsUpdate,
      searchState: AppBarSearchState(onSearch: _onSearch),
      actions: [
        IconButton(
          onPressed: _handleCloseAll,
          icon: const Icon(Icons.delete_sweep_outlined),
        ),
        IconButton(
          onPressed: () async {
            final currentSortType = ref.read(connectionsSortProvider);
            final selectedSortType = await globalState.showCommonDialog<ConnectionsSortType>(
              child: OptionsDialog<ConnectionsSortType>(
                title: appLocalizations.connectionsSort,
                options: ConnectionsSortType.values,
                value: currentSortType,
                textBuilder: (sortType) {
                  return switch (sortType) {
                    ConnectionsSortType.defaultSort => appLocalizations.defaultSort,
                    ConnectionsSortType.realTimeSpeed => appLocalizations.realTimeSpeed,
                    ConnectionsSortType.totalTraffic => appLocalizations.totalTraffic,
                    ConnectionsSortType.creationTime => appLocalizations.creationTime,
                  };
                },
              ),
            );
            if (selectedSortType != null && selectedSortType != currentSortType) {
              ref.read(connectionsSortProvider.notifier).state = selectedSortType;
            }
          },
          icon: const Icon(Icons.sort),
        ),
      ],
      body: Consumer(
        builder: (_, ref, _) {
          final connections = ref.watch(filteredConnectionsProvider);
          final hasConnections = connections.isNotEmpty;

          if (!hasConnections) {
            return NullStatus(
              label: appLocalizations.nullTip(appLocalizations.connections),
            );
          }

          return CommonScrollBar(
            controller: _scrollController,
            child: ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, index) {
              if (index.isOdd) {
                return const Divider(height: 0);
              }
              final itemIndex = index ~/ 2;
              if (itemIndex >= connections.length) {
                return const SizedBox.shrink();
              }
              final trackerInfo = connections[itemIndex];
              return TrackerInfoItem(
                key: ValueKey(trackerInfo.id),
                trackerInfo: trackerInfo,
                onClickKeyword: (value) {
                  context.commonScaffoldState?.addKeyword(value);
                },
                trailing: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  style: const ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(Size.zero),
                  ),
                  icon: const Icon(Icons.block),
                  onPressed: () => _handleBlockConnection(trackerInfo.id),
                ),
                detailTitle: appLocalizations.details(
                  appLocalizations.connection,
                ),
              );
            },
            itemExtentBuilder: (index, _) {
              if (index.isOdd) {
                return 0;
              }
              return TrackerInfoItem.height;
            },
              itemCount: connections.length * 2 - 1,
            ),
          );
        },
      ),
    );
  }
}
