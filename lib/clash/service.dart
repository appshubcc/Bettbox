import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bett_box/clash/core_startup.dart';
import 'package:bett_box/clash/interface.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/helper/helper.dart';
import 'package:bett_box/models/core.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/utils/frame_codec.dart';
import 'package:bett_box/utils/platform_check.dart';
import 'package:path/path.dart' as p;

class ClashService extends ClashHandlerInterface {
  static ClashService? _instance;

  Completer<ServerSocket> serverCompleter = Completer();

  Completer<Socket> socketCompleter = Completer();

  final CoreStartGuard _startGuard = CoreStartGuard();
  bool get isStarting => _startGuard.isRunning;
  bool _isDestroying = false;

  Process? process;

  Completer<void>? _restartCompleter;
  late final Future<void> _initialStartup;

  TransportType _transportType = TransportType.unixSocket;
  String? _socketPath;
  int? _tcpPort;

  factory ClashService() {
    _instance ??= ClashService._internal();
    return _instance!;
  }

  ClashService._internal() {
    _initialStartup = _initTransport();
  }

  Future<void> _initTransport() async {
    _transportType = await PlatformChecker.getRecommendedTransport();

    if (_transportType == TransportType.unixSocket) {
      final random = Random().nextInt(10000);
      final tempDir = Directory.systemTemp.path;
      _socketPath = p.join(tempDir, 'Bettbox_$random.sock');
      commonPrint.log('Using Unix Domain Socket: $_socketPath');
    } else {
      _tcpPort = PlatformChecker.getRandomPort();
      commonPrint.log('Using TCP Socket on port: $_tcpPort');
    }

    unawaited(_initServer());
    await reStart();
  }

  Future<void> _initServer() async {
    runZonedGuarded(
      () async {
        late final ServerSocket server;

        if (_transportType == TransportType.unixSocket) {
          final address = InternetAddress(
            _socketPath!,
            type: InternetAddressType.unix,
          );
          await _deleteSocketFile();
          server = await ServerSocket.bind(address, 0, shared: true);
        } else {
          server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
          _tcpPort = server.port;
          commonPrint.log('TCP Server bound to port: $_tcpPort');
        }

        serverCompleter.complete(server);
        await for (final socket in server) {
          await _destroySocket();
          socketCompleter.complete(socket);

          socket
              .transform(FrameDecoderTransformer())
              .listen(
                (data) {
                  handleResult(ActionResult.fromJson(json.decode(data)));
                },
                onError: (error) {
                  if (_isDestroying || globalState.isExiting) return;
                  commonPrint.log('Frame decode error: $error');
                },
                onDone: () {
                  commonPrint.log('Socket connection closed');
                },
              );
        }
      },
      (error, stack) {
        if (_isDestroying || globalState.isExiting) return;
        commonPrint.log(error.toString());
        if (!serverCompleter.isCompleted) {
          serverCompleter.completeError(error, stack);
        }
        if (error is SocketException &&
            !_isDestroying &&
            !globalState.isExiting) {
          globalState.showNotifier(error.toString());
        }
      },
    );
  }

  @override
  Future<void> reStart() async {
    final completer = Completer<void>();
    final previous = _restartCompleter;
    _restartCompleter = completer;

    if (previous != null) {
      await previous.future;
    }

    try {
      // Perform a real restart so every caller is guaranteed to see a fresh
      // core after this call returns. Queued calls will run sequentially.
      await _doRestart();
    } finally {
      if (_restartCompleter == completer) {
        _restartCompleter = null;
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  Future<void> _doRestart() {
    return _startGuard.run(() async {
      _isDestroying = false;
      try {
        await _destroySocket();

        process?.kill();
        if (process != null) {
          await process!.exitCode.timeout(
            const Duration(seconds: 2),
            onTimeout: () {
              process?.kill(ProcessSignal.sigkill);
              return -1;
            },
          );
        }
        process = null;

        socketCompleter = Completer();

        final serverSocket = await serverCompleter.future;

        final String arg;
        if (_transportType == TransportType.unixSocket) {
          arg = _socketPath!;
        } else {
          arg = '${serverSocket.port}';
        }

        final homeDirPath = await appPath.homeDirPath;
        final environment = Map<String, String>.from(Platform.environment);
        environment['SAFE_PATHS'] = homeDirPath;

        if (system.isWindows) {
          final serviceOk = await windows?.registerService() ?? false;
          if (serviceOk) {
            final started = await helperClient.startCore(
              corePath: appPath.corePath,
              arg: arg,
              homeDir: homeDirPath,
            );
            if (started) {
              await _waitForCoreReady();
              _setHighPriority();
              return;
            }
            commonPrint.log(
              'Helper start core failed, falling back to normal mode',
            );
          }
        }

        process = await Process.start(appPath.corePath, [
          arg,
        ], environment: environment);
        process?.stdout.listen((_) {});
        process?.stderr.listen((e) {
          final error = utf8.decode(e);
          if (error.isNotEmpty) commonPrint.log(error);
        });
        await _waitForCoreReady();
        _setHighPriority();
      } catch (error, stackTrace) {
        commonPrint.log('Core restart failed: $error');
        try {
          await _cleanupFailedCoreStart();
        } catch (cleanupError) {
          commonPrint.log(
            'Failed to clean up Core after startup error: $cleanupError',
          );
        }
        Error.throwWithStackTrace(error, stackTrace);
      }
    });
  }

  Future<void> _waitForCoreReady() async {
    await waitForCoreReady(socketCompleter.future);
  }

  void _setHighPriority() {
    if (!system.isWindows ||
        !globalState.config.appSetting.enableHighPriority) {
      return;
    }
    unawaited(
      helperClient
          .setProcessPriority('${AppIdentity.coreExecutableName}.exe', true)
          .catchError((e) {
            commonPrint.log('Failed to set core process priority: $e');
            return false;
          }),
    );
  }

  Future<void> _cleanupFailedCoreStart() async {
    _isDestroying = true;
    try {
      if (system.isWindows) {
        try {
          await helperClient.stopCore().timeout(const Duration(seconds: 5));
        } catch (error) {
          commonPrint.log('Failed to stop Core after startup error: $error');
        }
      }
      await _destroySocket();
      process?.kill();
      if (process != null) {
        await process!.exitCode.timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            process?.kill(ProcessSignal.sigkill);
            return -1;
          },
        );
      }
      process = null;
      socketCompleter = Completer();
    } finally {
      _isDestroying = false;
    }
  }

  @override
  destroy() async {
    _isDestroying = true;
    final server = await serverCompleter.future;
    await server.close();
    await _deleteSocketFile();
    return true;
  }

  @override
  sendMessage(String message) async {
    if (_isDestroying || globalState.isExiting) {
      return;
    }
    final socket = await socketCompleter.future;
    try {
      final frame = FrameCodec.encode(message);
      socket.add(frame);
    } on SocketException catch (e) {
      if (_isDestroying || globalState.isExiting || isStarting) {
        commonPrint.log(
          'Ignored message send on closed socket during transition: $e',
        );
        return;
      }
      rethrow;
    } on StateError catch (e) {
      if (_isDestroying || globalState.isExiting || isStarting) {
        commonPrint.log(
          'Ignored message send on closed socket during transition: $e',
        );
        return;
      }
      rethrow;
    }
  }

  Future<void> _deleteSocketFile() async {
    if (_transportType == TransportType.unixSocket && _socketPath != null) {
      final file = File(_socketPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> _destroySocket() async {
    if (socketCompleter.isCompleted) {
      final lastSocket = await socketCompleter.future;
      await lastSocket.close();
      socketCompleter = Completer();
    }
  }

  @override
  shutdown() async {
    _isDestroying = true;
    if (system.isWindows) {
      await helperClient.stopCore();
    }
    await _destroySocket();
    process?.kill();
    process = null;
    return true;
  }

  /// Checks IPC/control-plane health only.
  ///
  /// A true result does not prove that TUN or mixed-port traffic can pass.
  Future<bool> checkCoreHealth({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    if (_isDestroying || globalState.isExiting || isStarting) return false;
    if (!socketCompleter.isCompleted) return false;
    try {
      final result = await invoke<bool>(
        method: ActionMethod.getIsInit,
        timeout: timeout,
      );
      return result == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> preload() async {
    await _initialStartup;
    return true;
  }
}

final clashService = system.isDesktop ? ClashService() : null;
