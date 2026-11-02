import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/plugins/clipboard_ext.dart';
import 'package:bett_box/plugins/tile.dart';
import 'package:bett_box/plugins/vpn.dart';
import 'package:bett_box/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synchronized/synchronized.dart';

import 'application.dart';
import 'clash/core.dart';
import 'clash/lib.dart';
import 'common/common.dart';
import 'common/external_control.dart';
import 'common/network_matcher.dart';
import 'models/models.dart';

ReceivePort? _serviceReceiverPort;
ReceivePort? _messageReceiverPort;

Future<void> main(List<String> args) async {
  globalState.isService = false;
  WidgetsFlutterBinding.ensureInitialized();

  if (system.isDesktop &&
      (args.contains('--exit') || args.contains('--restart'))) {
    final command = args.contains('--exit') ? 'exit' : 'restart';
    await _sendControlCommand(command);
    exit(0);
  }

  if (system.isMacOS || appPath.isPortable) {
    final acquire = await singleInstanceLock.acquire();
    if (!acquire) {
      commonPrint.warn(
        'SingleInstanceLock: another instance detected or lock failed, exiting',
      );
      if (!appPath.isPortable) {
        await _sendControlCommand('show');
        await Future.delayed(const Duration(milliseconds: 100));
      }
      exit(0);
    }
  }

  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024;

  final version = await system.version;
  await Future.wait([
    globalState.initApp(version),
    clashCore.preload(),
    loadBundledRouteIcons(),
    ManagedScript.loadBundledVersion(),
  ]);

  try {
    await uiManager.initializeUI();
  } catch (e) {
    commonPrint.error('Failed to initialize UI: $e');
  }

  await _runApp();
}

Future<void> _sendControlCommand(String command) async {
  for (int i = 0; i < 5; i++) {
    try {
      await ExternalControl.sendCommand(command);
      commonPrint.log('Sent $command command to running instance');
      return;
    } catch (e) {
      if (i == 4) {
        commonPrint.warn('Failed to send $command command: $e');
        return;
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }
}

Future<void> _runApp() async {
  await ensureRustLib();

  if (system.isAndroid) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  await android?.init();

  await window?.init();
  if (system.isWindows) {
    clipboardExt.init();
  }
  HttpOverrides.global = BettboxHttpOverrides();
  runApp(ProviderScope(retry: (_, _) => null, child: const Application()));
}

@pragma('vm:entry-point')
Future<void> _service(List<String> flags) async {
  globalState.isService = true;
  WidgetsFlutterBinding.ensureInitialized();
  await globalState.init();

  {
    final quickStart = flags.contains('quick');
    final bootStart = flags.contains('boot');
    final clashLibHandler = ClashLibHandler();
    final smartAutoStopLock = Lock();
    String? overrideNetwork;

    Future<void> refreshVpnProps() async {
      try {
        final configFile = File(await appPath.appConfigPath);
        if (!await configFile.exists()) return;
        final latestConfig = Config.compatibleFromJson(
          json.decode(await configFile.readAsString()),
        );
        globalState.config = globalState.config.copyWith(
          vpnProps: latestConfig.vpnProps,
        );
      } catch (e) {
        commonPrint.warn('Refresh vpn props failed: $e');
      }
    }

    Future<void> checkSmartAutoStop([bool defaultChanged = false]) async {
      try {
        await refreshVpnProps();
        final vpnProps = globalState.config.vpnProps;
        final networks = vpnProps.smartAutoStop
            ? vpnProps.smartAutoStopNetworks
            : '';

        await smartAutoStopLock.synchronized(() async {
          final isSmartStopped = await vpn?.isSmartStopped() ?? false;
          final ips = await vpn?.getLocalIpAddresses() ?? const <String>[];
          final gateways = await vpn?.getLocalGateways() ?? const <String>[];
          if (await vpn?.isSmartStopOverride() ?? false) {
            final network = NetworkMatcher.networkKey(ips);
            overrideNetwork ??= network;
            if (networks.isEmpty || overrideNetwork != network) {
              overrideNetwork = null;
              await vpn?.clearSmartStopOverride();
            }
          } else {
            overrideNetwork = null;
          }
          var shouldStop = false;
          if (networks.isNotEmpty) {
            if (ips.isNotEmpty || gateways.isNotEmpty) {
              shouldStop =
                  overrideNetwork == null &&
                  NetworkMatcher.shouldStop(
                    ips: ips,
                    gateways: gateways,
                    rules: networks,
                  );
            } else if (!(await vpn?.hasPhysicalNetwork() ?? false)) {
              shouldStop = isSmartStopped;
            }
          }

          if (shouldStop && !isSmartStopped) {
            if (await vpn?.getStatus() ?? false) {
              await vpn?.smartStop();
              return;
            }
          } else if (!shouldStop && isSmartStopped) {
            await vpn?.smartResume(clashLibHandler.getAndroidVpnOptions());
            return;
          }
          if (defaultChanged) {
            await vpn?.quickResponse();
          }
        });
      } catch (e) {
        commonPrint.warn('Smart auto stop check failed: $e');
      }
    }

    Future<void> startCore() async {
      await ClashCore.initGeo();
      app.tip(appLocalizations.startVpn);
      final homeDirPath = await appPath.homeDirPath;
      final version = await system.version;
      final clashConfig = globalState.config.patchClashConfig.copyWith.tun(
        enable: false,
      );

      Future(() async {
        try {
          final profileId = globalState.config.currentProfileId;
          if (profileId == null) {
            return;
          }
          final params = await globalState.getSetupParams(
            pathConfig: clashConfig,
          );
          final res = await clashLibHandler.quickStart(
            InitParams(homeDir: homeDirPath, version: version),
            params,
            globalState.getCoreState(),
          );
          final message = res.message;
          debugPrint(message);
          if (message.isNotEmpty) {
            commonPrint.error('QuickStart failed with error: $message');
            await vpn?.stop();
            return;
          }
          await vpn?.start(clashLibHandler.getAndroidVpnOptions());
          Future.delayed(const Duration(seconds: 2), checkSmartAutoStop);

          if (globalState.config.vpnProps.networkSpeedNotification) {
            final profile = globalState.config.profiles
                .where((e) => e.id == profileId)
                .firstOrNull;
            final profileName = profile?.label ?? 'Bettbox';
            await vpn?.updateNotificationSpeed(profileName, '↑0B/s ↓0B/s');
          }

          clashLibHandler.startListener();
        } catch (e) {
          commonPrint.error('Fatal error during service background start: $e');
          await vpn?.stop();
        }
      });
    }

    tile?.addListener(
      _TileListenerWithService(
        onStart: startCore,
        onStop: () async {
          await app.tip(appLocalizations.stopVpn);
          clashLibHandler.stopListener();
          await vpn?.stop();
        },
        onReconnectIpc: () {
          commonPrint.log(
            'Service: reconnectIpc requested, re-establishing IPC',
          );
          _handleMainIpc(clashLibHandler);
        },
      ),
    );

    vpn?.addListener(
      _VpnListenerWithService(
        onDnsChanged: (String dns) {
          clashLibHandler.updateDns(dns);
        },
        onNetworkChanged: checkSmartAutoStop,
      ),
    );

    if (!quickStart && !bootStart) {
      _handleMainIpc(clashLibHandler);
      return;
    }

    if (bootStart && !globalState.config.appSetting.autoRun) {
      commonPrint.log(
        'Silent boot detected, but autoRun is disabled. Staying idle.',
      );
      _handleMainIpc(clashLibHandler);
      return;
    }

    commonPrint.log('Executing ${bootStart ? "boot" : "quick"} start sequence');
    await startCore();
  }
}

void _handleMainIpc(ClashLibHandler clashLibHandler) {
  final sendPort = IsolateNameServer.lookupPortByName(mainIsolate);
  if (sendPort == null) {
    commonPrint.warn(
      'Service: mainIsolate sendPort not found, IPC unavailable',
    );
    return;
  }

  _serviceReceiverPort?.close();
  _messageReceiverPort?.close();

  _serviceReceiverPort = ReceivePort();
  _serviceReceiverPort!.listen((message) async {
    final res = await clashLibHandler.invokeAction(message);
    _safeSend(sendPort, res);
  });
  _safeSend(sendPort, _serviceReceiverPort!.sendPort);

  _messageReceiverPort = ReceivePort();
  clashLibHandler.attachMessagePort(_messageReceiverPort!.sendPort.nativePort);
  _messageReceiverPort!.listen((message) {
    _safeSend(sendPort, message);
  });

  if (clashLibHandler.getRunTime() != null) {
    clashLibHandler.startListener();
  }
}

void _safeSend(SendPort sendPort, dynamic message) {
  try {
    sendPort.send(message);
  } catch (e) {
    commonPrint.warn('Service: IPC send failed: $e');
    final retryPort = IsolateNameServer.lookupPortByName(mainIsolate);
    if (retryPort != null) {
      try {
        retryPort.send(message);
      } catch (_) {}
    }
  }
}

@immutable
class _TileListenerWithService with TileListener {
  final Function() _onStart;
  final Function() _onStop;
  final Function() _onReconnectIpc;

  const _TileListenerWithService({
    required Function() onStart,
    required Function() onStop,
    required Function() onReconnectIpc,
  }) : _onStart = onStart,
       _onStop = onStop,
       _onReconnectIpc = onReconnectIpc;

  @override
  void onStart() => _onStart();

  @override
  void onStop() => _onStop();

  @override
  void onReconnectIpc() => _onReconnectIpc();
}

@immutable
class _VpnListenerWithService with VpnListener {
  final Function(String dns) _onDnsChanged;
  final Function(bool defaultChanged) _onNetworkChanged;

  const _VpnListenerWithService({
    required Function(String dns) onDnsChanged,
    required Function(bool defaultChanged) onNetworkChanged,
  }) : _onDnsChanged = onDnsChanged,
       _onNetworkChanged = onNetworkChanged;

  @override
  void onDnsChanged(String dns) {
    super.onDnsChanged(dns);
    _onDnsChanged(dns);
  }

  @override
  void onNetworkChanged(bool defaultChanged) {
    super.onNetworkChanged(defaultChanged);
    _onNetworkChanged(defaultChanged);
  }
}
