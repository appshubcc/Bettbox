import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/common/network_matcher.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/plugins/service.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synchronized/synchronized.dart';

/// Smart Auto Stop Manager
class SmartAutoStopManager extends ConsumerStatefulWidget {
  final Widget child;

  const SmartAutoStopManager({super.key, required this.child});

  @override
  ConsumerState<SmartAutoStopManager> createState() =>
      _SmartAutoStopManagerState();
}

class _SmartAutoStopManagerState extends ConsumerState<SmartAutoStopManager> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final _checkLock = Lock();

  int _checkSequence = 0;

  late final NativeEventCallback _nativeEventCallback;

  @override
  void initState() {
    super.initState();
    _initConnectivityListener();
    _initNativeNetworkListener();
  }

  void _initNativeNetworkListener() {
    _nativeEventCallback = (String method, dynamic arguments) async {
      if (method == 'networkChanged') {
        _onNativeNetworkChanged();
      } else if (method == 'quickResponse') {
        final vpnProps = ref.read(vpnSettingProvider);
        if (vpnProps.quickResponse) {
          final isSmartStopped = ref.read(isSmartStoppedProvider);
          if (isSmartStopped) {
            return;
          }
          final startTime = globalState.startTime;
          if (startTime != null &&
              DateTime.now().difference(startTime) < const Duration(seconds: 3)) {
            return;
          }
          clashCore.closeConnections();
        }
      }
    };
    service?.addNativeEventCallback(_nativeEventCallback);
  }

  void _onNativeNetworkChanged() {
    final vpnProps = ref.read(vpnSettingProvider);
    if (!vpnProps.smartAutoStop) return;
    _debouncedCheckCurrentNetwork();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.listenManual(vpnSettingProvider, (prev, next) {
      if (prev?.smartAutoStop != next.smartAutoStop ||
          prev?.smartAutoStopNetworks != next.smartAutoStopNetworks) {
        _onSettingsChanged();
      }
    });
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      _onConnectivityChanged(results);
    });
  }

  void _onSettingsChanged() {
    final vpnProps = ref.read(vpnSettingProvider);
    if (!vpnProps.smartAutoStop) {
      // Feature disabled, if we were smart-stopped, resume.
      final isSmartStopped = ref.read(isSmartStoppedProvider);
      if (isSmartStopped) {
        ref.read(isSmartStoppedProvider.notifier).set(false);
        _restartVpn();
      }
      return;
    }
    // Re-check current network
    _checkCurrentNetwork();
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    final vpnProps = ref.read(vpnSettingProvider);
    if (!vpnProps.smartAutoStop) return;

    _debouncedCheckCurrentNetwork();
  }

  void _debouncedCheckCurrentNetwork() {
    final currentSequence = ++_checkSequence;

    Future.delayed(const Duration(milliseconds: 1000), () async {
      if (currentSequence != _checkSequence) {
        commonPrint.log('Smart Auto Stop: Skipping outdated network check');
        return;
      }
      await _checkCurrentNetwork();
    });
  }

  Future<void> _checkCurrentNetwork() async {
    await _checkLock.synchronized(() async {
      final vpnProps = ref.read(vpnSettingProvider);
      if (!vpnProps.smartAutoStop) return;

      final networks = vpnProps.smartAutoStopNetworks;
      if (networks.isEmpty) return;

      final isSmartStopped = ref.read(isSmartStoppedProvider);

      // Get current IP(s) — always from native on Android for consistency
      List<String> candidateIps;
      if (system.isAndroid) {
        candidateIps = await _getNativeLocalIpAddresses();
      } else {
        final ip = await _getLocalIpAddress();
        candidateIps = ip != null ? [ip] : [];
      }

      if (candidateIps.isEmpty) {
        commonPrint.log('Smart Auto Stop: No IP found. Skipping.');
        return;
      }

      // Match: any IP matches any rule = should stop
      final shouldStop = candidateIps.any(
        (ip) => NetworkMatcher.matchAny(ip, networks),
      );

      commonPrint.log(
        'SmartAutoStop: IPs=${candidateIps.join(",")}, RuleMatch=$shouldStop, SmartStopped=$isSmartStopped',
      );

      // Dedup: only act on state transitions
      if (shouldStop && !isSmartStopped) {
        // Need to stop, but only if VPN is actually running
        final isRunning = ref.read(runTimeProvider) != null || globalState.isStart;
        if (isRunning) {
          ref.read(isSmartStoppedProvider.notifier).set(true);
          commonPrint.log('Smart Auto Stop: Stopping ...');
          await _stopVpn();
        }
      } else if (!shouldStop && isSmartStopped) {
        // Need to resume
        ref.read(isSmartStoppedProvider.notifier).set(false);
        commonPrint.log('Smart Auto Stop: Restarting ...');
        await _restartVpn();
      }
    });
  }



  Future<List<String>> _getNativeLocalIpAddresses() async {
    try {
      final serviceInstance = service;
      if (serviceInstance != null) {
        final ips = await serviceInstance.getLocalIpAddresses();
        if (ips.isNotEmpty) return ips;
      }
    } catch (e) {
      commonPrint.log('Smart Auto Stop: Native IP error: $e');
    }
    // Fallback to Flutter layer
    final ip = await _getLocalIpAddress();
    return ip != null ? [ip] : [];
  }

  Future<String?> _getLocalIpAddress() async {
    return await utils.getLocalIpAddress();
  }

  Future<void> _stopVpn() async {
    if (system.isAndroid) {
      // Android: Enable smart-stop mode (Blank notification)
      // This keeps the service alive but stops the VPN logic
      await service?.setSmartStopped(true);
      await service?.smartStop();

      // Update Dart state to look "stopped"
      globalState.startTime = null;
      clashCore.resetTraffic();
      ref.read(trafficsProvider.notifier).clear();
      ref.read(totalTrafficProvider.notifier).value = Traffic();
      ref.read(runTimeProvider.notifier).value = null;
    } else {
      // Desktop: Full stop
      await globalState.appController.updateStatus(false);
    }
  }

  Future<void> _restartVpn() async {
    if (system.isAndroid) {
      // Android: Resume from smart-stop mode
      await service?.setSmartStopped(false);
      await service?.smartResume();

      globalState.startTime = DateTime.now();
      ref.read(runTimeProvider.notifier).value = 0;
      globalState.appController.addCheckIpNumDebounce();
    } else {
      // Desktop: Full start
      await globalState.appController.updateStatus(true);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    service?.removeNativeEventCallback(_nativeEventCallback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
