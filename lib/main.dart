import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/plugins/service.dart' as vpn_service;
import 'package:bett_box/plugins/tile.dart';
import 'package:bett_box/plugins/vpn.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'application.dart';
import 'clash/core.dart';
import 'clash/lib.dart';
import 'common/common.dart';
import 'common/external_control.dart';
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

  if (system.isDesktop) {
    final acquire = await singleInstanceLock.acquire();
    if (!acquire) {
      commonPrint.log(
        'SingleInstanceLock: another instance detected or lock failed, exiting',
      );
      await _sendControlCommand('show');
      await Future.delayed(const Duration(milliseconds: 100));
      exit(0);
    }
  }

  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024;

  final version = await system.version;
  await clashCore.preload();
  await globalState.initApp(version);

  try {
    await uiManager.initializeUI();
  } catch (e) {
    commonPrint.log('Failed to initialize UI: $e');
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
        commonPrint.log('Failed to send $command command: $e');
        return;
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }
}

Future<void> _runApp() async {
  if (system.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      commonPrint.log('Failed to set high refresh rate: $e');
    }
  }
  await android?.init();

  await window?.init();
  HttpOverrides.global = BettboxHttpOverrides();
  runApp(ProviderScope(child: const Application()));
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

    tile?.addListener(
      _TileListenerWithService(
        onStart: () async {
          await app.tip(appLocalizations.startVpn);
          await globalState.handleStart();
        },
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
    await ClashCore.initGeo();
    app.tip(appLocalizations.startVpn);
    final homeDirPath = await appPath.homeDirPath;
    final version = await system.version;
    final clashConfig = globalState.config.patchClashConfig.copyWith.tun(
      enable: false,
    );

    Future(() async {
      try {
        final params = await globalState.getSetupParams(
          pathConfig: clashConfig,
        );
        final profileId = globalState.config.currentProfileId;
        if (profileId == null) {
          return;
        }
        final res = await clashLibHandler.quickStart(
          InitParams(homeDir: homeDirPath, version: version),
          params,
          globalState.getCoreState(),
        );
        debugPrint(res);
        if (res.isNotEmpty) {
          commonPrint.log('QuickStart failed with error: $res');
          await vpn?.stop();
          return;
        }
        await vpn?.start(clashLibHandler.getAndroidVpnOptions());

        if (globalState.config.vpnProps.networkSpeedNotification) {
          final profile = globalState.config.profiles
              .where((e) => e.id == profileId)
              .firstOrNull;
          final profileName = profile?.label ?? 'Bettbox';
          await vpn_service.service?.updateNotificationSpeed(
            profileName,
            '↑0B/s ↓0B/s',
          );
        }

        if (globalState.config.appSetting.openLogs) {
          await clashLibHandler.invokeAction(
            '{"id": "quickStartLog", "method": "startLog"}',
          );
        } else {
          await clashLibHandler.invokeAction(
            '{"id": "quickStopLog", "method": "stopLog"}',
          );
        }

        clashLibHandler.startListener();
      } catch (e) {
        commonPrint.log('Fatal error during service background start: $e');
        await vpn?.stop();
      }
    });
  }
}

void _handleMainIpc(ClashLibHandler clashLibHandler) {
  final sendPort = IsolateNameServer.lookupPortByName(mainIsolate);
  if (sendPort == null) {
    commonPrint.log('Service: mainIsolate sendPort not found, IPC unavailable');
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

  clashLibHandler.startListener();
}

void _safeSend(SendPort sendPort, dynamic message) {
  try {
    sendPort.send(message);
  } catch (e) {
    commonPrint.log('Service: IPC send failed: $e');
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

  const _VpnListenerWithService({required Function(String dns) onDnsChanged})
    : _onDnsChanged = onDnsChanged;

  @override
  void onDnsChanged(String dns) {
    super.onDnsChanged(dns);
    _onDnsChanged(dns);
  }
}
