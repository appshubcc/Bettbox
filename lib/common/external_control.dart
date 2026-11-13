import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/common/control_cli.dart';
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

  /// 执行一条命令：语法由 [ControlCli] 归一化，这里只做分发。
  ///
  /// 回执是 0..N 行文本，写完即关连接；首行以 `error:` 开头表示失败。
  /// `--exit` / `--restart` / `--show` 保持原语义：动作发出后直接断开，没有回执。
  static Future<String?> _dispatch(String line) async {
    final ControlCommand command;
    try {
      command = ControlCli.parse(line);
    } on ControlCliError catch (e) {
      return 'error: ${e.message}';
    }
    if (command.help) return ControlCli.help(command.scope);

    final controller = globalState.appController;
    try {
      switch (command.key) {
        case '--exit':
          await controller.handleExit();
          return null;
        case '--restart':
          system.restartApp();
          return null;
        case '--show':
          window?.show();
          return null;
        case '--ping':
          return _data(command, {'pong': true}, 'pong');
        case '--status':
          final data = controller.controlStatus();
          return _data(command, data, ControlCli.formatAppStatus(data));
        case '--refresh-dns':
          await controller.flushDns();
          return _ok(command, 'dns flushed');
        case 'profiles --list':
          final list = controller.controlProfiles();
          return _data(command, list, ControlCli.formatProfiles(list));
        case 'profiles --status':
          final status = controller.controlStatus();
          final data = {
            'currentId': status['profileId'],
            'currentLabel': status['profileLabel'],
            'loadedId': status['loadedProfileId'],
          };
          return _data(command, data, ControlCli.formatProfilesStatus(data));
        case 'profiles --select':
          return await _action(
            command,
            () => controller.controlSwitchProfile(command.value),
          );
        case 'profiles --update':
          return await _action(
            command,
            () => controller.controlUpdateProfile(
              command.value.isEmpty ? null : command.value,
            ),
          );
        case 'profiles --reapply':
          return await _action(command, () async {
            await controller.applyProfile();
            return 'ok: config applied';
          });
        case 'mode --status':
          final data = {'mode': controller.controlStatus()['mode']};
          return _data(command, data, ControlCli.formatModeStatus(data));
        case 'mode --switch':
          return await _action(
            command,
            () => controller.controlSetMode(command.value),
          );
        case 'tun --status':
          final status = controller.controlStatus();
          final data = {'tun': status['tun'], 'realTun': status['realTun']};
          return _data(command, data, ControlCli.formatTunStatus(data));
        case 'tun --enable':
        case 'tun --disable':
          return await _action(
            command,
            () => controller.controlSetTun(
              command.option == '--enable' ? 'on' : 'off',
            ),
          );
        case 'core --status':
          final status = controller.controlStatus();
          final data = {
            'core': status['core'],
            'version': status['version'],
          };
          return _data(command, data, ControlCli.formatCoreStatus(data));
        case 'core --start':
        case 'core --stop':
        case 'core --restart':
          return await _action(
            command,
            () => controller.controlCore(command.option.substring(2)),
          );
        case 'settings --list':
        case 'settings --status':
        case 'settings --get':
          final all = controller.controlSettings();
          final field = command.value.toLowerCase();
          if (field.isEmpty) {
            return _data(command, all, ControlCli.formatSettings(all));
          }
          if (!all.containsKey(field)) {
            return 'error: unknown field: $field '
                '(fields: ${all.keys.join(', ')})';
          }
          final data = {field: all[field]};
          return _data(command, data, ControlCli.formatSettings(data));
        case 'settings --set':
          return await _action(
            command,
            () => controller.controlSet(
              command.args.first,
              command.args.length < 2
                  ? ''
                  : command.args.sublist(1).join(' '),
            ),
          );
        default:
          return 'error: unsupported command: ${command.key}'
              ' (try: Bettbox --help)';
      }
    } catch (e) {
      commonPrint.warn('ExternalControl command failed [${command.key}]: $e');
      return command.json
          ? json.encode({'ok': false, 'error': '$e'})
          : 'error: $e';
    }
  }

  /// 查询类回执：`--json` 出单行 JSON，默认出对齐后的文本。
  static String _data(ControlCommand command, Object? data, String human) =>
      command.json ? json.encode({'ok': true, 'data': data}) : human;

  static String _ok(ControlCommand command, String message) => command.json
      ? json.encode({'ok': true, 'message': message})
      : 'ok: $message';

  /// 动作类命令统一收敛 `ok: ...` / `error: ...` 两种回执。
  static Future<String> _action(
    ControlCommand command,
    Future<String> Function() run,
  ) async {
    final text = await run();
    if (!text.startsWith('error:')) {
      return command.json ? json.encode({'ok': true, 'message': text}) : text;
    }
    final message = text.substring('error:'.length).trim();
    return command.json
        ? json.encode({'ok': false, 'error': message})
        : text;
  }
}
