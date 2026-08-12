import 'dart:async';
import 'dart:io';

import 'package:bett_box/common/common.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AppPath {
  static AppPath? _instance;
  Completer<Directory> dataDir = Completer();
  Completer<Directory> downloadDir = Completer();
  Completer<Directory> tempDir = Completer();
  late String appDirPath;

  AppPath._internal() {
    appDirPath = join(dirname(Platform.resolvedExecutable));
    getApplicationSupportDirectory().then((value) {
      if (system.isWindows && AppIdentity.isDev) {
        dataDir.complete(
          Directory(join(value.parent.path, AppIdentity.dataDirName)),
        );
      } else {
        dataDir.complete(value);
      }
    });
    getTemporaryDirectory().then((value) {
      tempDir.complete(value);
    });
    getDownloadsDirectory().then((value) {
      downloadDir.complete(value);
    });
  }

  factory AppPath() {
    _instance ??= AppPath._internal();
    return _instance!;
  }

  String get executableExtension {
    return system.isWindows ? '.exe' : '';
  }

  String get executableDirPath {
    final currentExecutablePath = Platform.resolvedExecutable;
    return dirname(currentExecutablePath);
  }

  String get corePath {
    return join(
      executableDirPath,
      '${AppIdentity.coreExecutableName}$executableExtension',
    );
  }

  String get helperPath {
    final devWorkspacePath = _devWorkspacePath;
    if (devWorkspacePath != null) {
      final helperPath = join(
        devWorkspacePath,
        'libclash',
        'windows',
        '$appHelperService$executableExtension',
      );
      if (File(helperPath).existsSync()) {
        return helperPath;
      }
    }

    return join(executableDirPath, '$appHelperService$executableExtension');
  }

  String? get _devWorkspacePath {
    if (!system.isWindows || !AppIdentity.isDev) return null;
    var directory = Directory(executableDirPath);
    for (var depth = 0; depth < 8; depth++) {
      final pubspecPath = join(directory.path, 'pubspec.yaml');
      if (File(pubspecPath).existsSync()) return directory.path;

      final parent = directory.parent;
      if (parent.path == directory.path) break;
      directory = parent;
    }

    return null;
  }

  Future<String> get downloadDirPath async {
    final directory = await downloadDir.future;
    return directory.path;
  }

  Future<String> get homeDirPath async {
    final directory = await dataDir.future;
    return directory.path;
  }

  Future<String> get lockFilePath async {
    final directory = await dataDir.future;
    return join(directory.path, '${AppIdentity.dataDirName}.lock');
  }

  Future<String> get controlSocketPath async {
    final directory = await dataDir.future;
    return join(directory.path, '${AppIdentity.dataDirName}.control.sock');
  }

  Future<String> get controlPortFilePath async {
    final directory = await dataDir.future;
    return join(directory.path, '${AppIdentity.dataDirName}.control.port');
  }

  Future<String> get sharedPreferencesPath async {
    final directory = await dataDir.future;
    return join(directory.path, 'shared_preferences.json');
  }

  Future<String> get helperAuthKeyPath async {
    final directory = await dataDir.future;
    return join(directory.path, 'helper_auth.key');
  }

  Future<String> get profilesPath async {
    final directory = await dataDir.future;
    return join(directory.path, profilesDirectoryName);
  }

  Future<String> getProfilePath(String id) async {
    final directory = await profilesPath;
    return join(directory, '$id.yaml');
  }

  Future<String> getProvidersDirPath(String id) async {
    final directory = await profilesPath;
    return join(directory, 'providers', id);
  }

  Future<String> getProvidersFilePath(
    String id,
    String type,
    String url,
  ) async {
    final directory = await profilesPath;
    return join(directory, 'providers', id, type, url.toMd5());
  }

  Future<String> get tempPath async {
    final directory = await tempDir.future;
    return directory.path;
  }

  Future<String> get uiPath async {
    final directory = await dataDir.future;
    return join(directory.path, 'ui');
  }
}

final appPath = AppPath();
