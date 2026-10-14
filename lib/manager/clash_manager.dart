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

  @override
  void initState() {
    super.initState();
    clashMessage.addListener(this);
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
  Future<void> dispose() async {
    throttler.cancel(FunctionTag.requests);
    clashMessage.removeListener(this);
    super.dispose();
  }

  @override
  Future<void> onDelay(Delay delay) async {
    super.onDelay(delay);
    final appController = globalState.appController;
    appController.setDelay(delay);
    debouncer.call(FunctionTag.updateDelay, () async {
      appController.updateGroupsDebounce();
    }, duration: const Duration(milliseconds: 5000));
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
  void onTailscaleAuth(String url) {
    final network = ref.read(tailscaleSettingProvider).runningNetwork;
    if (network == null) return;
    final wasPending = ref.read(tailscaleAuthUrlProvider)?.isNotEmpty == true;
    ref.read(tailscaleAuthUrlProvider.notifier).value = url;
    if (url.isNotEmpty) {
      globalState.showNotifier(
        '${network.label}: ${appLocalizations.tailscaleLoginNeeded}',
        actionLabel: appLocalizations.tailscaleLogin,
        onAction: () => globalState.openUrl(url),
      );
    } else if (wasPending) {
      globalState.showNotifier(appLocalizations.tailscaleLoggedIn);
    }
    super.onTailscaleAuth(url);
  }

  @override
  Future<void> onLoaded(String providerName) async {
    final provider = await clashCore.getExternalProvider(providerName);
    if (!mounted) return;
    ref.read(providersProvider.notifier).setProvider(provider);
    globalState.appController.updateGroupsDebounce();
    super.onLoaded(providerName);
  }
}
