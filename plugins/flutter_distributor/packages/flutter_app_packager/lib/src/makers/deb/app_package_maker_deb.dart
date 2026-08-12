import 'dart:io';

import 'package:flutter_app_packager/src/api/app_package_maker.dart';
import 'package:flutter_app_packager/src/makers/deb/make_deb_config.dart';
import 'package:path/path.dart' as path;
import 'package:shell_executor/shell_executor.dart';

class AppPackageMakerDeb extends AppPackageMaker {
  @override
  String get name => 'deb';
  @override
  String get platform => 'linux';
  @override
  bool get isSupportedOnCurrentPlatform => Platform.isLinux;
  @override
  String get packageFormat => 'deb';

  @override
  MakeConfigLoader get configLoader {
    return MakeDebConfigLoader()
      ..platform = platform
      ..packageFormat = packageFormat;
  }

  @override
  Future<MakeResult> make(MakeConfig config) {
    return _make(
      config.buildOutputDirectory,
      outputDirectory: config.outputDirectory,
      makeConfig: config as MakeDebConfig,
    );
  }

  Future<MakeResult> _make(
    Directory appDirectory, {
    required Directory outputDirectory,
    required MakeDebConfig makeConfig,
  }) async {
    final files = makeConfig.toFilesString();

    Directory packagingDirectory = makeConfig.packagingDirectory;

    /// Need to create following directories
    /// /DEBIAN
    /// /usr/share/$appBinaryName
    /// /usr/share/applications
    /// /usr/share/icons/hicolor/128x128/apps
    /// /usr/share/icons/hicolor/256x256/apps

    final debianDir = path.join(packagingDirectory.path, 'DEBIAN');
    final applicationsDir =
        path.join(packagingDirectory.path, 'usr/share/applications');
    final icon128Dir = path.join(
      packagingDirectory.path,
      'usr/share/icons/hicolor/128x128/apps',
    );
    final icon256Dir = path.join(
      packagingDirectory.path,
      'usr/share/icons/hicolor/256x256/apps',
    );
    final mkdirProcessResult = await $('mkdir', [
      '-p',
      debianDir,
      path.join(packagingDirectory.path, 'usr/share', makeConfig.appBinaryName),
      applicationsDir,
      if (makeConfig.icon != null) ...[icon128Dir, icon256Dir],
    ]);

    if (mkdirProcessResult.exitCode != 0) throw MakeError();

    if (makeConfig.icon != null) {
      final iconFile = File(makeConfig.icon!);
      if (!iconFile.existsSync()) {
        throw MakeError("provided icon ${makeConfig.icon} path wasn't found");
      }

      await iconFile.copy(
        path.join(
          icon128Dir,
          makeConfig.appBinaryName + path.extension(makeConfig.icon!),
        ),
      );
      await iconFile.copy(
        path.join(
          icon256Dir,
          makeConfig.appBinaryName + path.extension(makeConfig.icon!),
        ),
      );
    }

    // create & write the files got from makeConfig
    final controlFile = File(path.join(debianDir, 'control'));
    final postinstFile = File(path.join(debianDir, 'postinst'));
    final postrmFile = File(path.join(debianDir, 'postrm'));
    final desktopEntryFile =
        File(path.join(applicationsDir, '${makeConfig.appBinaryName}.desktop'));

    if (!controlFile.existsSync()) controlFile.createSync();
    if (!postinstFile.existsSync()) postinstFile.createSync();
    if (!postrmFile.existsSync()) postrmFile.createSync();
    if (!desktopEntryFile.existsSync()) desktopEntryFile.createSync();

    await controlFile.writeAsString(files['CONTROL']!);
    await desktopEntryFile.writeAsString(files['DESKTOP']!);
    await postinstFile.writeAsString(files['postinst']!);
    await postrmFile.writeAsString(files['postrm']!);

    // give execution permission to shell scripts
    await $('chmod', ['+x', postinstFile.path, postrmFile.path]);

    // copy the application binary to /usr/share/$appBinaryName
    await $('cp', [
      '-fr',
      '${appDirectory.path}/.',
      '${packagingDirectory.path}/usr/share/${makeConfig.appBinaryName}/',
    ]);

    // Preserve setuid bit on the core binary when packaging as root/fakeroot.
    final coreFile = File(
      '${packagingDirectory.path}/usr/share/${makeConfig.appBinaryName}/BettboxCore',
    );
    if (coreFile.existsSync()) {
      await $('chmod', ['+sx', coreFile.path]);
    }

    ProcessResult processResult = await $('dpkg-deb', [
      '--build',
      '--root-owner-group',
      packagingDirectory.path,
      makeConfig.outputFile.path,
    ]);

    if (processResult.exitCode != 0) {
      throw MakeError();
    }

    packagingDirectory.deleteSync(recursive: true);
    return MakeResult(makeConfig);
  }
}
