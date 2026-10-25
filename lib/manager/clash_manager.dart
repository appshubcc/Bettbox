import 'dart:async';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/app.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/providers/state.dart';
import 'package:bett_box/state.dart';
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
        final profileChanged = prev?.a != next.a;
        unawaited(
          globalState.appController
              .handleChangeProfile(
                hardRestart: system.isDesktop && profileChanged,
              )
              .catchError((Object error, StackTrace stackTrace) {
                commonPrint.error('Profile change failed: $error');
              }),
        );
      }
    });
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

  @override
  Future<void> onLoaded(String providerName) async {
    final provider = await clashCore.getExternalProvider(providerName);
    if (!mounted) return;
    globalState.appController.setProvider(provider);
    globalState.appController.updateGroupsDebounce();
    super.onLoaded(providerName);
  }
}
