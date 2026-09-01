// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';

enum Target { windows, linux, android, macos }

extension TargetExt on Target {
  String get os {
    if (this == Target.macos) {
      return 'darwin';
    }
    return name;
  }

  bool get same {
    if (this == Target.android) {
      return true;
    }
    if (Platform.isWindows && this == Target.windows) {
      return true;
    }
    if (Platform.isLinux && this == Target.linux) {
      return true;
    }
    if (Platform.isMacOS && this == Target.macos) {
      return true;
    }
    return false;
  }

  String get dynamicLibExtensionName {
    final String extensionName;
    switch (this) {
      case Target.android || Target.linux:
        extensionName = '.so';
        break;
      case Target.windows:
        extensionName = '.dll';
        break;
      case Target.macos:
        extensionName = '.dylib';
        break;
    }
    return extensionName;
  }

  String get executableExtensionName {
    final String extensionName;
    switch (this) {
      case Target.windows:
        extensionName = '.exe';
        break;
      default:
        extensionName = '';
        break;
    }
    return extensionName;
  }
}

enum Mode { core, lib }

enum Arch { amd64, arm64, arm }

class BuildItem {
  Target target;
  Arch? arch;
  String? archName;

  BuildItem({required this.target, this.arch, this.archName});

  @override
  String toString() {
    return 'BuildLibItem{target: $target, arch: $arch, archName: $archName}';
  }
}

class Build {
  static bool isDev = false;

  static String get identityName => isDev ? '${appName}Dev' : appName;

  static List<BuildItem> get buildItems => [
    BuildItem(target: Target.macos, arch: Arch.arm64),
    BuildItem(target: Target.macos, arch: Arch.amd64),
    BuildItem(target: Target.linux, arch: Arch.arm64),
    BuildItem(target: Target.linux, arch: Arch.amd64),
    BuildItem(target: Target.windows, arch: Arch.amd64),
    BuildItem(target: Target.windows, arch: Arch.arm64),
    BuildItem(target: Target.android, arch: Arch.arm, archName: 'armeabi-v7a'),
    BuildItem(target: Target.android, arch: Arch.arm64, archName: 'arm64-v8a'),
    BuildItem(target: Target.android, arch: Arch.amd64, archName: 'x86_64'),
  ];

  static String get appName => 'Bettbox';

  static String get coreName => '${identityName}Core';

  static String get helperName => '${identityName}HelperService';

  static String get libName => 'libclash';

  static String get outDir => join(current, libName);

  static String get _coreDir => join(current, 'core');

  static String get _servicesDir => join(current, 'services', 'helper');

  static String get distPath => join(current, 'dist');

  static String _getCc(BuildItem buildItem) {
    final environment = Platform.environment;
    if (buildItem.target == Target.android) {
      final ndk = environment['ANDROID_NDK'];
      assert(ndk != null);
      final prebuiltDir = Directory(
        join(ndk!, 'toolchains', 'llvm', 'prebuilt'),
      );
      final prebuiltDirList = prebuiltDir.listSync();
      final map = {
        'armeabi-v7a': 'armv7a-linux-androideabi21-clang',
        'arm64-v8a': 'aarch64-linux-android21-clang',
        'x86': 'i686-linux-android21-clang',
        'x86_64': 'x86_64-linux-android21-clang',
      };
      return join(prebuiltDirList.first.path, 'bin', map[buildItem.archName]);
    }
    return 'gcc';
  }

  static String getTags(BuildItem buildItem) {
    final baseTags = 'with_gvisor';
    if (buildItem.target == Target.android &&
        buildItem.archName == 'armeabi-v7a') {
      return '$baseTags,with_low_memory';
    }
    return baseTags;
  }

  static Future<void> exec(
    List<String> executable, {
    String? name,
    Map<String, String>? environment,
    String? workingDirectory,
    bool runInShell = true,
  }) async {
    if (name != null) print('run $name');
    final process = await Process.start(
      executable[0],
      executable.sublist(1),
      environment: environment,
      workingDirectory: workingDirectory,
      runInShell: runInShell,
    );
    process.stdout.listen((data) {
      print(utf8.decode(data));
    });
    process.stderr.listen((data) {
      print(utf8.decode(data));
    });
    final exitCode = await process.exitCode;
    if (exitCode != 0 && name != null) throw '$name error';
  }

  static Future<String> calcSha256(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw 'File not exists';
    }
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  static Future<List<String>> buildCore({
    required Mode mode,
    required Target target,
    Arch? arch,
    bool compatible = false,
  }) async {
    final isLib = mode == Mode.lib;

    final items = buildItems.where((element) {
      return element.target == target &&
          (arch == null ? true : element.arch == arch);
    }).toList();

    final List<String> corePaths = [];

    for (final item in items) {
      final outFileDir = join(outDir, item.target.name, item.archName);

      final file = File(outFileDir);
      if (file.existsSync()) {
        file.deleteSync(recursive: true);
      }

      final fileName = isLib
          ? '$libName${item.target.dynamicLibExtensionName}'
          : '$coreName${item.target.executableExtensionName}';
      final outPath = join(outFileDir, fileName);
      corePaths.add(outPath);

      final Map<String, String> env = {};
      env['GOOS'] = item.target.os;
      if (item.arch != null) {
        env['GOARCH'] = item.arch!.name;
      }
      if (item.arch == Arch.amd64 &&
          (item.target == Target.windows ||
              item.target == Target.linux ||
              item.target == Target.macos)) {
        env['GOAMD64'] = compatible ? 'v1' : 'v3';
      }
      if (isLib) {
        env['CGO_ENABLED'] = '1';
        env['CC'] = _getCc(item);
        env['CFLAGS'] = '-O3 -Werror';
      } else {
        env['CGO_ENABLED'] = '0';
      }

      final buildTags = getTags(item);

      await exec(
        ['go', 'mod', 'tidy'],
        name: 'go mod tidy',
        environment: env,
        workingDirectory: _coreDir,
      );

      final execLines = [
        'go',
        'build',
        '-trimpath',
        '-ldflags=-w -s${item.target == Target.android && (item.arch == Arch.arm64 || item.arch == Arch.amd64) ? ' -extldflags "-Wl,-z,max-page-size=16384"' : ''}',
        '-tags=$buildTags',
        if (isLib) '-buildmode=c-shared',
        '-o',
        outPath,
      ];
      await exec(
        execLines,
        name: 'build core',
        environment: env,
        workingDirectory: _coreDir,
      );
    }

    return corePaths;
  }

  static Future<void> buildHelper(Target target, String token) async {
    await exec(
      ['cargo', 'build', '--release', '--features', 'windows-service'],
      environment: {'TOKEN': token},
      name: 'build helper',
      workingDirectory: _servicesDir,
    );
    final outPath = join(
      _servicesDir,
      'target',
      'release',
      'helper${target.executableExtensionName}',
    );
    final targetPath = join(
      Build.outDir,
      target.name,
      '${Build.helperName}${target.executableExtensionName}',
    );
    await File(outPath).copy(targetPath);
  }

  static List<String> getExecutable(String command) {
    return command.split(' ');
  }

  static Future<void> getDistributor() async {
    final distributorDir = join(
      current,
      'plugins',
      'flutter_distributor',
      'packages',
      'flutter_distributor',
    );

    await exec(
      name: 'clean distributor',
      Build.getExecutable('flutter clean'),
      workingDirectory: distributorDir,
    );
    await exec(
      name: 'upgrade distributor',
      Build.getExecutable('flutter pub upgrade'),
      workingDirectory: distributorDir,
    );
    await exec(
      name: 'get distributor',
      Build.getExecutable('dart pub global activate -s path $distributorDir'),
    );
  }

  static void copyFile(String sourceFilePath, String destinationFilePath) {
    final sourceFile = File(sourceFilePath);
    if (!sourceFile.existsSync()) {
      throw 'SourceFilePath not exists';
    }
    final destinationFile = File(destinationFilePath);
    final destinationDirectory = destinationFile.parent;
    if (!destinationDirectory.existsSync()) {
      destinationDirectory.createSync(recursive: true);
    }
    try {
      sourceFile.copySync(destinationFilePath);
      print('File copied successfully!');
    } catch (e) {
      print('Failed to copy file: $e');
    }
  }
}

class BuildCommand extends Command {
  Target target;

  BuildCommand({required this.target}) {
    if (target == Target.android || target == Target.linux) {
      argParser.addOption(
        'arch',
        valueHelp: [
          if (target != Target.android) 'auto',
          ...arches.map((e) => e.name),
        ].join(','),
        help: 'The $name build desc',
      );
    } else {
      argParser.addOption(
        'arch',
        valueHelp: ['auto', ...arches.map((e) => e.name)].join(','),
        help: 'The $name build archName',
      );
    }
    argParser.addOption(
      'out',
      valueHelp: [
        if (target.same) 'app',
        'core',
        'core-only',
        'helper',
      ].join(','),
      help: 'The $name build arch',
    );
    argParser.addOption(
      'core-hash',
      help:
          'SHA256 hash of the (signed) core binary, used when --out=helper to embed the correct TOKEN',
    );
    argParser.addOption(
      'env',
      valueHelp: ['pre', 'stable'].join(','),
      help: 'The $name build env',
    );
    argParser.addFlag(
      'compatible',
      help: 'Build with GOAMD64=v2 for broader compatibility on amd64',
    );
    argParser.addFlag('dev', help: 'Build debug/dev variant');
    argParser.addFlag(
      'ensure',
      help: 'Skip build if output artifact already exists',
    );
  }

  @override
  String get description => 'build $name application';

  @override
  String get name => target.name;

  List<Arch> get arches => Build.buildItems
      .where((element) => element.target == target && element.arch != null)
      .map((e) => e.arch!)
      .toList();

  Future<void> _getLinuxDependencies(Arch arch) async {
    await Build.exec(Build.getExecutable('sudo apt update -y'));
    await Build.exec(
      Build.getExecutable('sudo apt install -y ninja-build libgtk-3-dev'),
    );
    await Build.exec(
      Build.getExecutable('sudo apt install -y libayatana-appindicator3-dev'),
    );
    await Build.exec(
      Build.getExecutable('sudo apt-get install -y libkeybinder-3.0-dev'),
    );
    await Build.exec(Build.getExecutable('sudo apt install -y locate'));
    if (arch == Arch.amd64) {
      await Build.exec(
        Build.getExecutable('sudo apt install -y rpm patchelf libfuse2'),
      );

      final downloadName = arch == Arch.amd64 ? 'x86_64' : 'aarch64';
      await Build.exec(
        Build.getExecutable(
          'wget -O appimagetool https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$downloadName.AppImage',
        ),
      );
      await Build.exec(Build.getExecutable('chmod +x appimagetool'));
      await Build.exec(
        Build.getExecutable('sudo mv appimagetool /usr/local/bin/'),
      );
    }
  }

  Future<void> _setLinuxCoreSetuid() async {
    final coreFile = File('libclash/linux/BettboxCore');
    if (!coreFile.existsSync()) return;
    try {
      await Process.run('chmod', ['+sx', coreFile.path]);
    } catch (_) {}
  }

  Future<void> _getMacosDependencies() async {
    await Build.exec(Build.getExecutable('npm install -g appdmg'));
  }

  Future<void> _setMacOSImpeller(bool enable) async {
    final infoPlistPath = 'macos/Runner/Info.plist';
    final file = File(infoPlistPath);

    if (!await file.exists()) {
      print('Warning: Info.plist not found at $infoPlistPath');
      return;
    }

    var content = await file.readAsString();

    content = content.replaceAll(
      RegExp(r'\s*<key>FLTDisableImpeller</key>\s*<(?:true|false)/>'),
      '',
    );
    content = content.replaceAll(
      RegExp(r'\s*<key>FLTEnableImpeller</key>\s*<(?:true|false)/>'),
      '',
    );

    if (!enable) {
      const impellerEntry = '\t<key>FLTEnableImpeller</key>\n\t<false/>\n';
      content = content.replaceFirst(
        '</dict>\n</plist>',
        '$impellerEntry</dict>\n</plist>',
      );
    }

    await file.writeAsString(content);
    print(
      'macOS ${enable ? "default" : "compatible"} build: Impeller ${enable ? "enabled" : "disabled"}',
    );
  }

  Future<void> _buildDistributor({
    required Target target,
    required String targets,
    String args = '',
    required String env,
    required String suffix,
    bool compatible = false,
  }) async {
    final sentryDsn = Platform.environment['SENTRY_DSN'] ?? '';
    final sentryArg = sentryDsn.isNotEmpty
        ? ' --build-dart-define=SENTRY_DSN=$sentryDsn'
        : '';
    final suffixArg = suffix.isNotEmpty
        ? ' --build-dart-define=APP_ASSET_SUFFIX=$suffix'
        : '';

    final ipinfoToken = Platform.environment['IPINFO_TOKEN'] ?? '';
    final ipinfoArg = ipinfoToken.isNotEmpty
        ? ' --build-dart-define=IPINFO_TOKEN=$ipinfoToken'
        : '';

    final appDevArg = Build.isDev ? ' --build-dart-define=APP_DEV=true' : '';

    final environment = Map<String, String>.from(Platform.environment);
    if (compatible) {
      environment['BETTBOX_COMPATIBLE_BUILD'] = '1';
    }

    await Build.getDistributor();
    await Build.exec(
      name: name,
      Build.getExecutable(
        'flutter_distributor package --skip-clean --platform ${target.name} --targets $targets --flutter-build-args=verbose$args$sentryArg$suffixArg$ipinfoArg --build-dart-define=APP_ENV=$env$appDevArg',
      ),
      environment: environment,
    );
  }

  Future<String?> get systemArch async {
    if (Platform.isWindows) {
      return Platform.environment['PROCESSOR_ARCHITECTURE'];
    } else if (Platform.isLinux || Platform.isMacOS) {
      final result = await Process.run('uname', ['-m']);
      return result.stdout.toString().trim();
    }
    return null;
  }

  String? _mapHostArch(String? hostArch) {
    if (hostArch == null) return null;
    final lower = hostArch.toLowerCase();
    if (lower == 'amd64' || lower == 'x86_64' || lower == 'x64') return 'amd64';
    if (lower == 'arm64' || lower == 'aarch64') return 'arm64';
    if (lower.startsWith('arm')) return 'arm';
    return null;
  }

  List<String> _expectedOutputs(Arch? arch) {
    final items = Build.buildItems.where((element) {
      return element.target == target &&
          (arch == null ? true : element.arch == arch);
    });

    final outputs = <String>[];
    for (final item in items) {
      final outFileDir = join(Build.outDir, item.target.name, item.archName);
      if (target == Target.android) {
        outputs.add(join(outFileDir, '${Build.libName}.so'));
        outputs.add(join(outFileDir, '${Build.libName}.h'));
        continue;
      }

      outputs.add(
        join(outFileDir, '${Build.coreName}${target.executableExtensionName}'),
      );

      if (target == Target.windows) {
        outputs.add(
          join(
            outFileDir,
            '${Build.helperName}${target.executableExtensionName}',
          ),
        );
      }
    }
    return outputs;
  }

  DateTime _latestModified(Iterable<FileSystemEntity> entities) {
    var latest = DateTime.fromMillisecondsSinceEpoch(0);
    for (final entity in entities) {
      if (!entity.existsSync()) continue;
      final modified = entity.statSync().modified;
      if (modified.isAfter(latest)) latest = modified;
    }
    return latest;
  }

  DateTime _windowsSourcesLastModified() {
    final helperDir = Directory(Build._servicesDir);
    if (!helperDir.existsSync()) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return _latestModified([
      File(join(current, 'setup.dart')),
      ...helperDir.listSync(recursive: true).where((entity) {
        return entity is File &&
            !isWithin(join(Build._servicesDir, 'target'), entity.path);
      }),
    ]);
  }

  bool _outputsAreFresh(Arch? arch) {
    final outputs = _expectedOutputs(arch);
    if (outputs.isEmpty || !outputs.every((path) => File(path).existsSync())) {
      return false;
    }

    if (target == Target.windows) {
      final latestInput = _windowsSourcesLastModified();
      final oldestOutput = outputs
          .map((path) => File(path).statSync().modified)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      return !oldestOutput.isBefore(latestInput);
    }

    return true;
  }

  @override
  Future<void> run() async {
    final mode = target == Target.android ? Mode.lib : Mode.core;
    final String out = argResults?['out'] ?? (target.same ? 'app' : 'core');
    final env = argResults?['env'] ?? 'pre';
    Build.isDev = argResults?['dev'] ?? false;

    String? archName = argResults?['arch'];
    if (archName == 'auto') {
      if (target == Target.android) {
        throw '--arch auto is not supported for android; choose the device ABI explicitly';
      }
      if (!target.same) {
        throw '--arch auto can only be used for the current host platform';
      }
      archName = _mapHostArch(await systemArch);
      if (archName == null) {
        throw 'Unable to detect host architecture';
      }
    }

    final currentArches = arches
        .where((element) => element.name == archName)
        .toList();
    final arch = currentArches.isEmpty ? null : currentArches.first;

    if (arch == null && target != Target.android) {
      throw 'Invalid arch parameter';
    }

    final bool compatible = argResults?['compatible'] ?? false;
    final bool ensure = argResults?['ensure'] ?? false;

    if (ensure && out != 'app') {
      if (_outputsAreFresh(arch)) {
        print('${target.name} output already exists');
        return;
      }
    }

    final corePaths = await Build.buildCore(
      target: target,
      arch: arch,
      mode: mode,
      compatible: compatible,
    );

    if (out == 'core-only') {
      return;
    }

    if (out == 'helper') {
      if (target != Target.windows) {
        throw '--out helper is only supported for windows';
      }
      final coreHash = argResults?['core-hash'] as String?;
      if (coreHash == null || coreHash.isEmpty) {
        throw '--core-hash is required when --out=helper';
      }
      await Build.buildHelper(target, coreHash);
      return;
    }

    if (out != 'app') {
      if (target == Target.windows) {
        final token = await Build.calcSha256(corePaths.first);
        await Build.buildHelper(target, token);
      }
      return;
    }

    final String desc = compatible ? '$archName-compatible' : (archName ?? '');

    String appAssetSuffix = '';
    switch (target) {
      case Target.windows:
        appAssetSuffix = 'windows-$desc-setup.exe';
        break;
      case Target.macos:
        appAssetSuffix = 'macos-$desc.dmg';
        break;
      case Target.linux:
        break;
      case Target.android:
        if (archName == 'universal') {
          appAssetSuffix = 'android-universal.apk';
        } else if (arch == Arch.arm64) {
          appAssetSuffix = 'android-arm64-v8a.apk';
        } else if (arch == Arch.arm) {
          appAssetSuffix = 'android-armeabi-v7a.apk';
        } else if (arch == Arch.amd64) {
          appAssetSuffix = 'android-x86_64.apk';
        }
        break;
    }

    switch (target) {
      case Target.windows:
        final token = target != Target.android
            ? await Build.calcSha256(corePaths.first)
            : null;
        Build.buildHelper(target, token!);
        _buildDistributor(
          target: target,
          targets: 'exe',
          args: ' --description $desc --build-dart-define=CORE_SHA256=$token',
          env: env,
          suffix: appAssetSuffix,
          compatible: compatible,
        );
        return;
      case Target.linux:
        final targetMap = {Arch.arm64: 'linux-arm64', Arch.amd64: 'linux-x64'};
        final targets = [
          'deb',
          if (arch == Arch.amd64) 'appimage',
          if (arch == Arch.amd64) 'rpm',
        ];
        final defaultTarget = targetMap[arch];
        await _getLinuxDependencies(arch!);
        await _setLinuxCoreSetuid();
        for (final t in targets) {
          final ext = t == 'appimage' ? 'AppImage' : t;
          final currentSuffix = 'linux-$desc.$ext';
          await _buildDistributor(
            target: target,
            targets: t,
            args: ' --description $desc --build-target-platform $defaultTarget',
            env: env,
            suffix: currentSuffix,
            compatible: compatible,
          );
        }
        return;
      case Target.android:
        final targetMap = {
          Arch.arm: 'android-arm',
          Arch.arm64: 'android-arm64',
          Arch.amd64: 'android-x64',
        };
        final defaultArches = [Arch.arm, Arch.arm64, Arch.amd64];
        final defaultTargets = defaultArches
            .where((element) => arch == null ? true : element == arch)
            .map((e) => targetMap[e])
            .toList();

        final buildArgs = archName == 'universal'
            ? ' --build-target-platform ${defaultTargets.join(",")} --description universal'
            : ',split-per-abi --build-target-platform ${defaultTargets.join(",")}';

        _buildDistributor(
          target: target,
          targets: 'apk',
          args: buildArgs,
          env: env,
          suffix: appAssetSuffix,
          compatible: compatible,
        );
        return;
      case Target.macos:
        await _getMacosDependencies();
        await _setMacOSImpeller(!compatible);
        await Build.exec(
          Build.getExecutable('rm -rf Pods Podfile.lock'),
          workingDirectory: 'macos',
        );
        await Build.exec(Build.getExecutable('flutter pub get'));
        await Build.exec(
          Build.getExecutable('pod install --repo-update'),
          workingDirectory: 'macos',
        );
        _buildDistributor(
          target: target,
          targets: 'dmg',
          args: ' --description $desc',
          env: env,
          suffix: appAssetSuffix,
          compatible: compatible,
        );
        return;
    }
  }
}

Future<void> main(Iterable<String> args) async {
  final runner = CommandRunner('setup', 'build Application');
  runner.addCommand(BuildCommand(target: Target.android));
  runner.addCommand(BuildCommand(target: Target.linux));
  runner.addCommand(BuildCommand(target: Target.windows));
  runner.addCommand(BuildCommand(target: Target.macos));
  runner.run(args);
}
