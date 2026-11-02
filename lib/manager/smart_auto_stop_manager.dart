import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/common/network_matcher.dart';
import 'package:bett_box/plugins/service.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:material_ui/material_ui.dart';
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

  String? _overrideNetwork;

  bool _overridePending = false;

  late final NativeEventCallback _nativeEventCallback;

  @override
  void initState() {
    super.initState();
    if (!system.isAndroid) {
      _initConnectivityListener();
    }
    _initNativeNetworkListener();
    _syncSmartStopped();
  }

  void _syncSmartStopped() async {
    if (!system.isAndroid) return;
    try {
      final isStopped = await service?.isSmartStopped() ?? false;
      if (mounted) {
        ref.read(isSmartStoppedProvider.notifier).set(isStopped);
      }
    } catch (_) {}
  }

  void _initNativeNetworkListener() {
    _nativeEventCallback = (String method, dynamic arguments) async {
      if (method == 'networkChanged') {
        _syncSmartStopped();
      }
    };
    service?.addNativeEventCallback(_nativeEventCallback);
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
    ref.listenManual(runTimeProvider.select((value) => value != null), (
      prev,
      next,
    ) {
      if (system.isAndroid) {
        _syncSmartStopped();
        return;
      }
      final isSmartStopped = ref.read(isSmartStoppedProvider);
      if (!next) {
        if (!isSmartStopped) _clearOverride();
        return;
      }
      if (isSmartStopped) {
        ref.read(isSmartStoppedProvider.notifier).set(false);
        _overridePending = true;
      }
      if (prev != true && ref.read(vpnSettingProvider).smartAutoStop) {
        _debouncedCheckCurrentNetwork();
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
    if (system.isAndroid) {
      _requestServiceCheck();
      return;
    }
    final vpnProps = ref.read(vpnSettingProvider);
    if (!vpnProps.smartAutoStop) {
      _clearOverride();
      final isSmartStopped = ref.read(isSmartStoppedProvider);
      if (isSmartStopped) {
        ref.read(isSmartStoppedProvider.notifier).set(false);
        _restartVpn();
      }
      return;
    }
    _checkCurrentNetwork();
  }

  Future<void> _requestServiceCheck() async {
    try {
      await globalState.appController.savePreferences();
      await service?.requestSmartAutoStopCheck();
    } catch (e) {
      commonPrint.warn('Smart Auto Stop: Request check error: $e');
    }
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
        commonPrint.debug('Smart Auto Stop: Skipping outdated network check');
        return;
      }
      await _checkCurrentNetwork();
    });
  }

  Future<void> _checkCurrentNetwork() async {
    await _checkLock.synchronized(() async {
      if (!mounted) return;
      final vpnProps = ref.read(vpnSettingProvider);
      if (!vpnProps.smartAutoStop) return;

      final networks = vpnProps.smartAutoStopNetworks;
      final isSmartStopped = ref.read(isSmartStoppedProvider);

      var shouldStop = false;
      if (networks.isEmpty) {
        _clearOverride();
      } else {
        final ips = await _getDesktopLocalIpAddresses();
        final gateways = await _getDesktopLocalGateways();
        if (!mounted) return;
        final network = NetworkMatcher.networkKey(ips);
        if (_overridePending) {
          _overrideNetwork = network;
          _overridePending = false;
        } else if (_overrideNetwork != network) {
          _overrideNetwork = null;
        }
        if (ips.isEmpty && gateways.isEmpty) {
          commonPrint.debug('Smart Auto Stop: No IP/Gateway found. Skipping.');
          return;
        }
        shouldStop =
            _overrideNetwork == null &&
            NetworkMatcher.shouldStop(
              ips: ips,
              gateways: gateways,
              rules: networks,
            );
        commonPrint.debug(
          'SmartAutoStop: IPs=${ips.join(",")}, Gateways=${gateways.join(",")}, RuleMatch=$shouldStop, SmartStopped=$isSmartStopped',
        );
      }

      if (shouldStop && !isSmartStopped) {
        final isRunning =
            ref.read(runTimeProvider) != null || globalState.isStart;
        if (isRunning) {
          ref.read(isSmartStoppedProvider.notifier).set(true);
          commonPrint.log('Smart Auto Stop: Stopping ...');
          await _stopVpn();
        }
      } else if (!shouldStop && isSmartStopped) {
        ref.read(isSmartStoppedProvider.notifier).set(false);
        commonPrint.log('Smart Auto Stop: Restarting ...');
        await _restartVpn();
      }
    });
  }

  void _clearOverride() {
    _overrideNetwork = null;
    _overridePending = false;
  }

  Future<List<String>> _getDesktopLocalIpAddresses() async {
    try {
      return await utils.getInterfaceIPv4Addresses();
    } catch (e) {
      commonPrint.warn('Smart Auto Stop: Desktop IP error: $e');
      return [];
    }
  }

  Future<List<String>> _getDesktopLocalGateways() async {
    try {
      return await utils.getLocalGateways();
    } catch (e) {
      commonPrint.warn('Smart Auto Stop: Desktop gateway error: $e');
      return [];
    }
  }

  Future<void> _stopVpn() async {
    await globalState.appController.updateStatus(false);
  }

  Future<void> _restartVpn() async {
    await globalState.appController.updateStatus(true);
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
