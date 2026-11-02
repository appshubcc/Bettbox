import 'dart:async';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/app.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/providers/state.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/proxies/common.dart' show delayTestCoordinator;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClashManager extends ConsumerStatefulWidget {
  final Widget child;

  const ClashManager({super.key, required this.child});

  @override
  ConsumerState<ClashManager> createState() => _ClashContainerState();
}

class _ClashContainerState extends ConsumerState<ClashManager>
    with AppMessageListener {
  final List<TrackerInfo> _pendingRequests = [];
  static const _flushDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _syncForeground() {
    clashCore.setForeground(!globalState.backgroundMode.value);
  }

  @override
  void initState() {
    super.initState();
    clashMessage.addListener(this);
    if (system.isAndroid) {
      globalState.backgroundMode.addListener(_syncForeground);
      unawaited(clashCore.preload().then((_) => _syncForeground()));
    }
    ref.listenManual(needSetupProvider, (prev, next) {
      if (prev != next) {
        final fullRestart =
            system.isDesktop &&
            prev?.a != next.a &&
            ref.read(networkSettingProvider).profileSwitchMode ==
                ProfileSwitchMode.fullRestart;
        unawaited(
          globalState.appController
              .handleChangeProfile(hardRestart: fullRestart)
              .catchError((Object error, StackTrace stackTrace) {
                commonPrint.error('Profile change failed: $error');
              }),
        );
      }
    });
    ref.listenManual(
      currentPageLabelProvider.select((state) => state == PageLabel.proxies),
      (prev, next) {
        if (next && prev == false) _refreshDelaySort();
      },
    );
    ref.listenManual(coreStateProvider, (prev, next) async {
      if (prev != next) {
        await clashCore.setState(next);
      }
    });
    ref.listenManual(updateParamsProvider, (prev, next) {
      if (prev != next) {
        globalState.appController.updateClashConfigDebounce();
      }
    });

    ref.listenManual(appSettingProvider.select((state) => state.openLogs), (
      prev,
      next,
    ) {
      if (!next) {
        clashCore.stopLog();
      }
    });
  }

  void _flushRequests() {
    if (!mounted || _pendingRequests.isEmpty) return;
    final requests = List.of(_pendingRequests);
    _pendingRequests.clear();
    ref.read(requestsProvider.notifier).addRequests(requests);
  }

  @override
  void dispose() {
    throttler.cancel(FunctionTag.requests);
    debouncer.cancel(FunctionTag.delaySort);
    clashMessage.removeListener(this);
    globalState.backgroundMode.removeListener(_syncForeground);
    super.dispose();
  }

  @override
  void onDelays(List<Delay> delays) {
    super.onDelays(delays);
    final appController = globalState.appController;
    for (final delay in delays) {
      appController.setDelay(delay);
    }
    debouncer.call(
      FunctionTag.delaySort,
      _refreshDelaySort,
      duration: const Duration(seconds: 5),
    );
  }

  void _refreshDelaySort() {
    if (!mounted || delayTestCoordinator.isTesting) return;
    final proxiesStyle = ref.read(proxiesStyleSettingProvider);
    if (proxiesStyle.sortType != ProxiesSortType.delay &&
        !proxiesStyle.hideTimeoutProxies) {
      return;
    }
    globalState.appController.addSortNum();
  }

  @override
  void onGroupsChanged() {
    super.onGroupsChanged();
    globalState.appController.updateGroupsDebounce();
  }

  @override
  void onLog(Log log) {
    globalState.appController.addLog(log);
    if (log.logLevel == LogLevel.error) {
      globalState.showNotifier(log.payload);
    }
    super.onLog(log);
  }

  @override
  void onRequest(TrackerInfo trackerInfo) async {
    _pendingRequests.add(trackerInfo);
    throttler.call(
      FunctionTag.requests,
      _flushRequests,
      duration: _flushDuration,
    );
    super.onRequest(trackerInfo);
  }
}
