import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/utils/platform_check.dart';
import 'package:restart_app/restart_app.dart';

class ExternalControl {
  static ServerSocket? _server;
  static TransportType? _transportType;

  static Future<void> start() async {
    if (!system.isDesktop || _server != null) return;

    _transportType = await PlatformChecker.getRecommendedTransport();

    if (_transportType == TransportType.unixSocket) {
      try {
        await _startUnixSocket();
        return;
      } catch (e) {
        commonPrint.log(
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
          .listen(_handleCommand),
      onError: (e) => commonPrint.log('ExternalControl server error: $e'),
    );
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

  static Future<void> sendCommand(String command) async {
    if (!system.isDesktop) return;

    // Prefer Unix Domain Socket when the socket file exists.
    final socketPath = await appPath.controlSocketPath;
    final socketType = FileSystemEntity.typeSync(socketPath);
    if (socketType != FileSystemEntityType.notFound) {
      try {
        await _sendUnixCommand(socketPath, command);
        return;
      } catch (_) {}
    }

    // Fall back to TCP loopback port file.
    final portFilePath = await appPath.controlPortFilePath;
    if (await File(portFilePath).exists()) {
      final content = await File(portFilePath).readAsString();
      final port = int.tryParse(content.trim());
      if (port != null) {
        try {
          await _sendTcpCommand(port, command);
          return;
        } catch (_) {}
      }
    }

    throw StateError('Bettbox is not running');
  }

  static Future<void> _sendUnixCommand(
    String socketPath,
    String command,
  ) async {
    final address = InternetAddress(socketPath, type: InternetAddressType.unix);
    final socket = await Socket.connect(
      address,
      0,
    ).timeout(const Duration(seconds: 1));
    try {
      socket.write('$command\n');
      await socket.flush();
    } on SocketException catch (e) {
      if (!_isConnectionReset(e)) rethrow;
    } finally {
      try {
        await socket.close();
      } catch (_) {}
    }
  }

  static Future<void> _sendTcpCommand(int port, String command) async {
    final socket = await Socket.connect(
      InternetAddress.loopbackIPv4,
      port,
    ).timeout(const Duration(seconds: 1));
    try {
      socket.write('$command\n');
      await socket.flush();
    } on SocketException catch (e) {
      if (!_isConnectionReset(e)) rethrow;
    } finally {
      try {
        await socket.close();
      } catch (_) {}
    }
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

  static void _handleCommand(String command) {
    switch (command.trim()) {
      case 'exit':
        globalState.appController.handleExit();
      case 'restart':
        Restart.restartApp();
      case 'show':
        window?.show();
      default:
        commonPrint.log('ExternalControl unknown command: $command');
    }
  }
}
