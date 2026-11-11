import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/utils/platform_check.dart';

class ExternalControl {
  static ServerSocket? _server;
  static TransportType? _transportType;

  static Future<void> start() async {
    if (!system.isDesktop || _server != null || appPath.isPortable) return;

    _transportType = await PlatformChecker.getRecommendedTransport();

    if (_transportType == TransportType.unixSocket) {
      try {
        await _startUnixSocket();
        return;
      } catch (e) {
        commonPrint.warn(
          'ExternalControl UDS bind failed, falling back to TCP: $e',
        );
      }
    }
    await _startTcpSocket();
  }

  static Future<void> _startUnixSocket() async {
    final socketPath = await appPath.controlSocketPath;
    final type = FileSystemEntity.typeSync(socketPath);
    if (type != FileSystemEntityType.notFound) {
      try {
        await File(socketPath).delete();
      } catch (_) {}
    }
    final address = InternetAddress(socketPath, type: InternetAddressType.unix);
    _server = await ServerSocket.bind(address, 0);
    _listen();
  }

  static Future<void> _startTcpSocket() async {
    _server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final portFilePath = await appPath.controlPortFilePath;
    try {
      await File(portFilePath).writeAsString('${_server!.port}');
    } catch (_) {}
    _listen();
  }

  static void _listen() {
    _server!.listen(
      (socket) => socket
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) => unawaited(_handleLine(line, socket)),
            onError: (e) =>
                commonPrint.warn('ExternalControl server error: $e'),
          ),
      onError: (e) => commonPrint.warn('ExternalControl server error: $e'),
    );
  }

  static Future<void> _handleLine(String line, Socket socket) async {
    final command = line.trim();
    if (command.isEmpty) return;
    String? response;
    try {
      response = await _dispatch(command);
    } catch (e) {
      response = 'error: $e';
      commonPrint.warn('ExternalControl command failed [$command]: $e');
    }
    if (response == null) {
      // exit/restart/show 没有回执，直接断开，免得客户端干等到超时。
      try {
        await socket.close();
      } catch (_) {}
      return;
    }
    try {
      socket.write('$response\n');
      await socket.flush();
    } catch (e) {
      commonPrint.warn('ExternalControl response failed: $e');
    } finally {
      // 单个连接只处理一行命令，回执写完就关，客户端读到 EOF 即可返回。
      try {
        await socket.close();
      } catch (_) {}
    }
  }

  static Future<void> stop() async {
    await _server?.close();
    _server = null;
    _transportType = null;

    final socketPath = await appPath.controlSocketPath;
    final type = FileSystemEntity.typeSync(socketPath);
    if (type != FileSystemEntityType.notFound) {
      try {
        await File(socketPath).delete();
      } catch (_) {}
    }

    final portFilePath = await appPath.controlPortFilePath;
    if (await File(portFilePath).exists()) {
      try {
        await File(portFilePath).delete();
      } catch (_) {}
    }
  }

  /// 把一行命令发给正在运行的实例，并返回它的回执。
  ///
  /// `exit` / `restart` / `show` 这类命令没有回执，返回 `null`；
  /// 实例没在跑时抛 [StateError]。
  static Future<String?> sendCommand(String command) async {
    if (!system.isDesktop) return null;

    Object? lastError;

    // Prefer Unix Domain Socket when the socket file exists.
    final socketPath = await appPath.controlSocketPath;
    final socketType = FileSystemEntity.typeSync(socketPath);
    if (socketType != FileSystemEntityType.notFound) {
      try {
        return await _sendUnixCommand(socketPath, command);
      } on SocketException catch (e) {
        // 只有连接层面失败才回退到 TCP；命令已发出后的失败直接上抛，
        // 避免调用方重试导致重复执行。
        lastError = e;
      }
    }

    // Fall back to TCP loopback port file.
    final portFilePath = await appPath.controlPortFilePath;
    if (await File(portFilePath).exists()) {
      final content = await File(portFilePath).readAsString();
      final port = int.tryParse(content.trim());
      if (port != null) {
        try {
          return await _sendTcpCommand(port, command);
        } on SocketException catch (e) {
          lastError = e;
        }
      }
    }

    throw StateError(
      lastError == null
          ? 'Bettbox is not running'
          : 'Bettbox is not running ($lastError)',
    );
  }

  static Future<String?> _sendUnixCommand(
    String socketPath,
    String command,
  ) async {
    final address = InternetAddress(socketPath, type: InternetAddressType.unix);
    final socket = await Socket.connect(
      address,
      0,
    ).timeout(const Duration(seconds: 1));
    return _exchange(socket, command);
  }

  static Future<String?> _sendTcpCommand(int port, String command) async {
    final socket = await Socket.connect(
      InternetAddress.loopbackIPv4,
      port,
    ).timeout(const Duration(seconds: 1));
    return _exchange(socket, command);
  }

  /// 写一行命令进连接，等对端回一行（或直接断开），然后关掉连接。
  static Future<String?> _exchange(Socket socket, String command) async {
    final buffer = StringBuffer();
    final received = Completer<void>();
    final subscription = socket
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) => buffer.write('$line\n'),
          onError: (Object e) {
            commonPrint.warn('ExternalControl response read failed: $e');
            if (!received.isCompleted) received.complete();
          },
          onDone: () {
            if (!received.isCompleted) received.complete();
          },
          cancelOnError: true,
        );
    try {
      socket.write('$command\n');
      await socket.flush();
      // 服务端处理完会主动断开；这里留足切换订阅/重启内核的时间。
      await received.future.timeout(const Duration(seconds: 10));
    } on SocketException catch (e) {
      if (!_isConnectionReset(e)) rethrow;
    } finally {
      await subscription.cancel();
      try {
        socket.destroy();
      } catch (_) {}
    }
    final response = buffer.toString().trim();
    return response.isEmpty ? null : response;
  }

  static bool _isConnectionReset(SocketException e) {
    final osError = e.osError;
    if (osError == null) return false;
    const resetMessages = [
      'Connection reset by peer',
      'Connection refused',
      '远程主机强迫关闭了一个现有的连接',
      'An existing connection was forcibly closed',
    ];
    return osError.errorCode == 10054 ||
        resetMessages.any((m) => osError.message.contains(m));
  }

  /// 命令表。带返回值的命令会把结果按单行写回同一个连接；
  /// exit/restart/show 保持原有的「发了就不管」语义（返回 null）。
  static const _helpText =
      'commands: ping | status | profiles | profile [id|label] | '
      'profile-update [id|label|all] | mode rule|global|direct | tun on|off | '
      'core start|stop|restart|status | apply | dns | show | exit | restart';

  static Future<String?> _dispatch(String command) async {
    final parts = command.split(RegExp(r'\s+'));
    final name = parts.first.toLowerCase();
    final args = parts.skip(1).toList();
    final controller = globalState.appController;

    switch (name) {
      case 'exit':
        await controller.handleExit();
        return null;
      case 'restart':
        system.restartApp();
        return null;
      case 'show':
        window?.show();
        return null;
      case 'ping':
        return 'pong';
      case 'status':
        return json.encode(controller.controlStatus());
      case 'profiles':
        return json.encode(controller.controlProfiles());
      case 'profile':
        if (args.isEmpty) {
          return 'error: usage: profile <id|label> (see: profiles)';
        }
        return controller.controlSwitchProfile(args.first);
      case 'profile-update':
        return controller.controlUpdateProfile(
          args.isEmpty ? null : args.first,
        );
      case 'mode':
        if (args.isEmpty) {
          return 'error: usage: mode rule|global|direct';
        }
        return controller.controlSetMode(args.first);
      case 'tun':
        if (args.isEmpty) return 'error: usage: tun on|off';
        return controller.controlSetTun(args.first);
      case 'core':
        return controller.controlCore(args.isEmpty ? 'status' : args.first);
      case 'apply':
        await controller.applyProfile();
        return 'ok: config applied';
      case 'dns':
        await controller.flushDns();
        return 'ok: dns flushed';
      case 'help':
        return _helpText;
      default:
        return 'error: unknown command: $name ($_helpText)';
    }
  }
}
