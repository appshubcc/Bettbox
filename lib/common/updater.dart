import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/state.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:path/path.dart' hide windows;

class AppUpdater {
  static const _assetSuffix = String.fromEnvironment('APP_ASSET_SUFFIX');
  static const _checksumsName = 'sha256sums.txt';
  static const _linuxInstallDir = '/usr/share/Bettbox';
  static const _macInstallScript = '''
while kill -0 "\$1" 2>/dev/null; do sleep 0.2; done
rm -rf "\$3.old"
if mv "\$3" "\$3.old"; then
  if ditto "\$2" "\$3"; then
    rm -rf "\$3.old"
  else
    rm -rf "\$3"
    mv "\$3.old" "\$3"
  fi
fi
hdiutil detach "\$4" -quiet -force
rmdir "\$4"
open "\$3"
''';

  static AppUpdater? _instance;

  AppUpdater._internal();

  factory AppUpdater() => _instance ??= AppUpdater._internal();

  late final Dio _dio =
      Dio(
          BaseOptions(
            headers: {'User-Agent': browserUa},
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
          ),
        )
        ..httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: () {
            final client = HttpClient();
            client.findProxy = BettboxHttpOverrides.handleFindProxy;
            return client;
          },
        );

  bool get isSupported => _assetSuffix.isNotEmpty && !appPath.isPortable;

  String get releaseUrl => 'https://github.com/$repository/releases/latest';

  String releaseTagUrl(String tagName) =>
      'https://github.com/$repository/releases/tag/$tagName';

  String assetName(String tagName) {
    final version = tagName.startsWith('v') ? tagName.substring(1) : tagName;
    return 'Bettbox-$version-$_assetSuffix';
  }

  String _url(String tagName, String name) =>
      'https://github.com/$repository/releases/download/$tagName/$name';

  Future<Directory> get _dir async {
    final tempDir = await appPath.tempDir.future;
    return Directory(join(tempDir.path, 'update'));
  }

  Future<File?> findDownloaded(String tagName) async {
    final dir = await _dir;
    final file = File(join(dir.path, assetName(tagName)));
    return file.existsSync() ? file : null;
  }

  Future<void> removeVersion(String version) async {
    final dir = await _dir;
    final path = join(dir.path, assetName(version));
    for (final file in [File(path), File('$path.part')]) {
      if (file.existsSync()) await file.delete();
    }
  }

  Future<void> clear({String? keep}) async {
    final dir = await _dir;
    if (!dir.existsSync()) return;
    for (final entity in dir.listSync()) {
      final name = basename(entity.path);
      if (keep != null && (name == keep || name == '$keep.part')) continue;
      try {
        entity.deleteSync(recursive: true);
      } catch (_) {}
    }
  }

  Future<File> download(
    String tagName,
    void Function(double progress) onProgress,
  ) async {
    final name = assetName(tagName);
    final dir = await _dir;
    await dir.create(recursive: true);
    await clear(keep: name);
    final target = File(join(dir.path, name));
    if (target.existsSync()) return target;

    final expected = await _fetchChecksum(tagName, name);
    final part = File('${target.path}.part');
    final offset = part.existsSync() ? part.lengthSync() : 0;
    final response = await _dio.get<ResponseBody>(
      _url(tagName, name),
      options: Options(
        responseType: ResponseType.stream,
        headers: {if (offset > 0) 'Range': 'bytes=$offset-'},
        validateStatus: (status) =>
            status == 200 || status == 206 || status == 416,
      ),
    );
    final body = response.data;
    if (response.statusCode != 416 && body != null) {
      final append = response.statusCode == 206;
      var received = append ? offset : 0;
      final total = body.contentLength > 0 ? received + body.contentLength : 0;
      final sink = part.openWrite(
        mode: append ? FileMode.append : FileMode.write,
      );
      try {
        await for (final chunk in body.stream.timeout(
          const Duration(seconds: 30),
        )) {
          sink.add(chunk);
          received += chunk.length;
          if (total > 0) onProgress(received / total);
        }
      } finally {
        await sink.close();
      }
    }

    final path = part.path;
    final actual = await Isolate.run(
      () async => (await sha256.bind(File(path).openRead()).first).toString(),
    );
    if (actual != expected) {
      await part.delete();
      throw 'Update checksum mismatch: $name';
    }
    return part.rename(target.path);
  }

  Future<String> _fetchChecksum(String tagName, String name) async {
    final response = await _dio.get<String>(
      _url(tagName, _checksumsName),
      options: Options(responseType: ResponseType.plain),
    );
    final checksum = parseChecksum(response.data ?? '', name);
    if (checksum == null) throw 'Update checksum not found: $name';
    return checksum;
  }

  static String? parseChecksum(String content, String name) {
    for (final line in content.split('\n')) {
      final parts = line.trim().split(RegExp(r'\s+'));
      if (parts.length < 2) continue;
      final file = parts.last.startsWith('*')
          ? parts.last.substring(1)
          : parts.last;
      if (file == name) return parts.first.toLowerCase();
    }
    return null;
  }

  Future<bool> install(File file) async {
    if (system.isAndroid) return app.installApk(file.path);
    if (system.isWindows) {
      final started =
          windows?.runas(
            file.path,
            '/SILENT /SUPPRESSMSGBOXES /NORESTART /relaunch=1',
            showWindow: true,
          ) ??
          false;
      if (started) await globalState.appController.handleExit();
      return started;
    }
    if (system.isMacOS) return _installMacOS(file);
    if (system.isLinux) return _installLinux(file);
    return false;
  }

  Future<bool> _isWritable(String path) async {
    final result = await Process.run('test', ['-w', path]);
    return result.exitCode == 0;
  }

  Future<bool> _open(String command, String path) async {
    final result = await Process.run(command, [path]);
    return result.exitCode == 0;
  }

  Future<bool> _installMacOS(File file) async {
    final bundle = dirname(dirname(dirname(Platform.resolvedExecutable)));
    final replaceable =
        bundle.endsWith('.app') &&
        !bundle.contains('/AppTranslocation/') &&
        await _isWritable(dirname(bundle));
    if (!replaceable) return _open('open', file.path);

    final mount = await Directory.systemTemp.createTemp('bettbox_update');
    final attach = await Process.run('hdiutil', [
      'attach',
      file.path,
      '-nobrowse',
      '-readonly',
      '-quiet',
      '-mountpoint',
      mount.path,
    ]);
    final source = join(mount.path, '${AppIdentity.productName}.app');
    if (attach.exitCode != 0 || !Directory(source).existsSync()) {
      await Process.run('hdiutil', ['detach', mount.path, '-quiet', '-force']);
      return _open('open', file.path);
    }
    await Process.start('sh', [
      '-c',
      _macInstallScript,
      '--',
      '$pid',
      source,
      bundle,
      mount.path,
    ], mode: ProcessStartMode.detached);
    await globalState.appController.handleExit();
    return true;
  }

  Future<bool> _installLinux(File file) async {
    final path = file.path;
    if (path.endsWith('.AppImage')) {
      final target = Platform.environment['APPIMAGE'];
      if (target == null ||
          target.isEmpty ||
          !await _isWritable(dirname(target))) {
        return _open('xdg-open', dirname(path));
      }
      final staged = await file.copy('$target.new');
      await Process.run('chmod', ['+x', staged.path]);
      await staged.rename(target);
      await system.restartApp();
      return true;
    }
    if (appPath.executableDirPath != _linuxInstallDir) {
      return _open('xdg-open', dirname(path));
    }
    final ProcessResult result;
    try {
      result = await Process.run('pkexec', [
        if (path.endsWith('.rpm')) ...[
          'rpm',
          '-U',
          '--force',
        ] else ...[
          'dpkg',
          '-i',
        ],
        path,
      ]);
    } on ProcessException {
      return _open('xdg-open', dirname(path));
    }
    if (result.exitCode == 126) return true;
    if (result.exitCode != 0) return _open('xdg-open', dirname(path));
    await system.restartApp();
    return true;
  }
}

final appUpdater = AppUpdater();
