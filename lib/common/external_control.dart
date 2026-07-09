import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';
import 'package:restart_app/restart_app.dart';

class ExternalControl {
  static ServerSocket? _server;

  static Future<void> start() async {
    if (!system.isDesktop || _server != null) return;
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    _server = server;
    final portFile = File(await appPath.controlPortFilePath);
    await portFile.create(recursive: true);
    await portFile.writeAsString('${server.port}');
    server.listen(_onConnection);
  }

  static Future<void> stop() async {
    await _server?.close();
    _server = null;
    try {
      final portFile = File(await appPath.controlPortFilePath);
      if (portFile.existsSync()) {
        await portFile.delete();
      }
    } catch (_) {}
  }

  static Future<void> sendCommand(String command) async {
    if (!system.isDesktop) return;
    final portFile = File(await appPath.controlPortFilePath);
    if (!portFile.existsSync()) {
      throw StateError('Bettbox is not running');
    }
    final port = int.tryParse(await portFile.readAsString());
    if (port == null) {
      throw StateError('Invalid control port file');
    }
    final socket = await Socket.connect(InternetAddress.loopbackIPv4, port)
        .timeout(const Duration(seconds: 2));
    try {
      socket.write('$command\n');
      await socket.flush();
    } finally {
      await socket.close();
    }
  }

  static void _onConnection(Socket socket) {
    socket
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          _handleCommand,
          onError: (e) => commonPrint.log('ExternalControl connection error: $e'),
          onDone: () {},
        );
  }

  static void _handleCommand(String command) {
    switch (command.trim()) {
      case 'exit':
        globalState.appController.handleExit();
      case 'restart':
        Restart.restartApp();
      default:
        commonPrint.log('ExternalControl unknown command: $command');
    }
  }
}
