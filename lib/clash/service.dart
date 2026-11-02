import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bett_box/clash/interface.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/helper/helper.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/utils/frame_codec.dart';
import 'package:bett_box/utils/platform_check.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class ClashService extends ClashHandlerInterface {
  static ClashService? _instance;

  Completer<ServerSocket> serverCompleter = Completer();

  Completer<Socket> socketCompleter = Completer();

  bool isStarting = false;
  bool _isDestroying = false;
  bool _coreLost = false;
  Socket? _socket;
  DateTime? _lastAutoRestartAt;

  Process? process;

  Completer<void>? _restartCompleter;

  TransportType _transportType = TransportType.unixSocket;
  String? _socketPath;
  int? _tcpPort;

  factory ClashService() {
    _instance ??= ClashService._internal();
    return _instance!;
  }

  ClashService._internal() {
    _initTransport();
  }

  Future<void> _initTransport() async {
    _transportType = await PlatformChecker.getRecommendedTransport();

    if (_transportType == TransportType.unixSocket) {
      _socketPath = _newSocketPath();
      commonPrint.log('Using Unix Domain Socket: $_socketPath');
    } else {
      _tcpPort = PlatformChecker.getRandomPort();
      commonPrint.log('Using TCP Socket on port: $_tcpPort');
    }

    _initServer();
    reStart();
  }

  String _newSocketPath() {
    final token = Random.secure().nextInt(1 << 32).toRadixString(16);
    return p.join(Directory.systemTemp.path, 'Bettbox_$token.sock');
  }

  Future<void> _rebindTransport() async {
    try {
      await (await serverCompleter.future).close();
    } catch (_) {}
    serverCompleter = Completer();
    if (_transportType == TransportType.unixSocket) {
      _socketPath = _newSocketPath();
      await _deleteSocketFile();
    }
    _initServer();
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
          if (_socket != null && !isStarting) {
            socket.destroy();
            continue;
          }
          await _destroySocket();
          _socket = socket;
          _coreLost = false;
          socketCompleter.complete(socket);

          socket
              .transform(FrameDecoderTransformer())
              .listen(
                (data) {
                  handleResultMessage(data);
                },
                onError: (error) {
                  if (_isDestroying || globalState.isExiting) return;
                  commonPrint.error('Frame decode error: $error');
                },
                onDone: () {
                  commonPrint.log('Socket connection closed');
                  abortRequests(socket);
                  _handleSocketClosed(socket);
                },
              );
        }
      },
      (error, stack) {
        if (_isDestroying || globalState.isExiting) return;
        commonPrint.error(error.toString());
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
      isStarting = false;
      if (_restartCompleter == completer) {
        _restartCompleter = null;
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  Future<void> _doRestart() async {
    isStarting = true;
    _isDestroying = false;
    _coreLost = false;

    await _destroySocket();

    if (_usesHelper) {
      await helperClient.stopCore().catchError((_) => false);
    }

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

    await _destroySocket();

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

    if (_usesHelper) {
      final serviceOk = AppIdentity.isDev
          ? (await windows?.isHelperHealthy() ?? false)
          : (await windows?.registerService() ?? false);
      if (serviceOk) {
        final started = await helperClient.startCore(
          corePath: appPath.corePath,
          arg: arg,
          homeDir: homeDirPath,
        );
        if (started) {
          await _waitForCoreReady();
          isStarting = false;
          if (system.isWindows &&
              globalState.config.appSetting.enableHighPriority) {
            unawaited(
              helperClient
                  .setProcessPriority(
                    '${AppIdentity.coreExecutableName}.exe',
                    true,
                  )
                  .catchError((e) {
                    commonPrint.warn('Failed to set core process priority: $e');
                    return false;
                  }),
            );
          }
          return;
        }
        commonPrint.warn(
          'Helper start core failed, falling back to normal mode',
        );
      }
    }

    if (system.isWindows && AppIdentity.isDev) {
      try {
        await Process.run('taskkill', [
          '/F',
          '/IM',
          '${AppIdentity.coreExecutableName}.exe',
        ]);
      } catch (_) {}
    }

    var connected = await _startCoreDirectly(arg, environment);
    if (!connected) {
      commonPrint.warn('core did not connect, retrying with a fresh transport');
      process?.kill();
      process = null;
      await _rebindTransport();
      final retryArg = _transportType == TransportType.unixSocket
          ? _socketPath!
          : '${(await serverCompleter.future).port}';
      await _startCoreDirectly(retryArg, environment);
    }
    isStarting = false;
    if (_usesHelper && globalState.config.appSetting.enableHighPriority) {
      unawaited(
        helperClient
            .setProcessPriority('${AppIdentity.coreExecutableName}.exe', true)
            .catchError((e) {
              commonPrint.warn('Failed to set core process priority: $e');
              return false;
            }),
      );
    }
  }

  bool get _usesHelper => windows?.usesHelper ?? false;

  Duration get _coreReadyTimeout {
    if (kDebugMode || AppIdentity.isDev) {
      return const Duration(seconds: 15);
    }
    return const Duration(seconds: 6);
  }

  Future<bool> _startCoreDirectly(
    String arg,
    Map<String, String> environment,
  ) async {
    if (system.isLinux && appPath.isAppImage) {
      await appPath.ensureAppImageCoreSynced();
    }
    process = await Process.start(appPath.corePath, [
      arg,
    ], environment: environment);
    process?.stdout.listen((_) {});
    process?.stderr.listen((e) {
      final error = utf8.decode(e);
      if (error.isNotEmpty) commonPrint.error(error);
    });
    final ready = await _waitForCoreReady(process);
    final pid = process?.pid;
    if (ready && system.isLinux && pid != null) {
      unawaited(system.verifyCoreProcessPrivileges(pid));
    }
    return ready;
  }

  Future<bool> _waitForCoreReady([Process? targetProcess]) async {
    final timeout = _coreReadyTimeout;
    try {
      if (targetProcess != null) {
        final result = await Future.any<bool>([
          socketCompleter.future.then((_) => true),
          targetProcess.exitCode.then((code) {
            commonPrint.error(
              'Core process exited prematurely with code: $code',
            );
            return false;
          }),
        ]).timeout(timeout);
        return result;
      }

      await socketCompleter.future.timeout(timeout);
      return true;
    } on TimeoutException {
      commonPrint.error('Core ready timeout after ${timeout.inSeconds}s');
      return false;
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
  Future<Socket> sendMessage(String message) async {
    if (_isDestroying || globalState.isExiting || _coreLost) {
      throw const CoreDisconnectedException();
    }
    final socket = await socketCompleter.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw TimeoutException('Core socket connection timed out');
      },
    );
    try {
      final frame = FrameCodec.encode(message);
      socket.add(frame);
      return socket;
    } on SocketException catch (e) {
      if (_isDestroying || globalState.isExiting || isStarting) {
        commonPrint.debug(
          'Ignored message send on closed socket during transition: $e',
        );
        throw const CoreDisconnectedException();
      }
      rethrow;
    } on StateError catch (e) {
      if (_isDestroying || globalState.isExiting || isStarting) {
        commonPrint.debug(
          'Ignored message send on closed socket during transition: $e',
        );
        throw const CoreDisconnectedException();
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
      _socket = null;
      await lastSocket.close();
      socketCompleter = Completer();
    }
  }

  void _handleSocketClosed(Socket socket) {
    if (!identical(_socket, socket)) return;
    _socket = null;
    socketCompleter = Completer();
    socket.destroy();
    if (_isDestroying || isStarting || globalState.isExiting) return;
    _coreLost = true;
    commonPrint.error('Core disconnected unexpectedly');
    final now = DateTime.now();
    final last = _lastAutoRestartAt;
    if (!globalState.isInit ||
        (last != null && now.difference(last) < const Duration(minutes: 1))) {
      return;
    }
    _lastAutoRestartAt = now;
    unawaited(_autoRestart());
  }

  bool get _canAutoRestart =>
      _coreLost && !_isDestroying && !globalState.isExiting;

  Future<void> _autoRestart() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!_canAutoRestart) return;
    if (_usesHelper && !(await windows?.isHelperHealthy() ?? false)) {
      return;
    }
    if (!_canAutoRestart) return;
    commonPrint.warn('Restarting core after unexpected disconnect');
    await globalState.appController.restartCore().catchError((_) {});
  }

  @override
  shutdown() async {
    _isDestroying = true;
    if (_usesHelper) {
      await helperClient.stopCore();
    }
    await _destroySocket();
    process?.kill();
    process = null;
    return true;
  }

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
    await serverCompleter.future;
    return true;
  }
}

final clashService = system.isDesktop ? ClashService() : null;
