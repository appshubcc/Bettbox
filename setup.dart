// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';

enum TargetPlatform { windows, linux, android, macos }

extension PlatformExt on TargetPlatform {
  String get os {
    if (this == TargetPlatform.macos) {
      return 'darwin';
    }
    return name;
  }

  bool get same => name == Platform.operatingSystem;

  bool get buildable {
    return same || this == TargetPlatform.android;
  }

  String get dynamicLibExtensionName {
    final String extensionName;
    switch (this) {
      case TargetPlatform.android || TargetPlatform.linux:
        extensionName = '.so';
        break;
      case TargetPlatform.windows:
        extensionName = '.dll';
        break;
      case TargetPlatform.macos:
        extensionName = '.dylib';
        break;
    }
    return extensionName;
  }

  String get executableExtensionName {
    final String extensionName;
    switch (this) {
      case TargetPlatform.windows:
        extensionName = '.exe';
        break;
      default:
        extensionName = '';
        break;
    }
    return extensionName;
  }
}

enum CoreMode { core, lib }

enum Arch { amd64, arm64, arm }

extension ArchExt on Arch {
  Map<String, String> get archMap {
    switch (Platform.operatingSystem) {
      case 'windows':
        return {
          'AMD64': 'amd64',
          'x86': 'amd32',
          'ARM64': 'arm64',
          'ARM': 'arm',
        };
      case 'linux' || 'android':
        return {
          'x86_64': 'amd64',
          'i386': 'amd32',
          'i486': 'amd32',
          'i586': 'amd32',
          'i686': 'amd32',
          'aarch64': 'arm64',
          'armv5l': 'arm',
          'armv6l': 'arm',
          'armv7l': 'arm',
        };
      case 'macos':
        return {
          'x86_64': 'amd64',
          'arm64': 'arm64',
          'arm64e': 'arm64'
        };
      default:
        throw 'Unsupported platform!';
    }
  }

  bool get same {
    final String hostArchName;
    if (Platform.isWindows) {
      hostArchName = Platform.environment['PROCESSOR_ARCHITECTURE']!;
    } else {
      var info = Process.runSync('uname', ['-m']);
      hostArchName = info.stdout.toString().trim();
    }
    final hostArch = archMap[hostArchName] ?? hostArchName;
    return name == hostArch ? true : false;
  }
}

class BuildItem {
  TargetPlatform platform;
  Arch arch;
  String? archName;

  BuildItem({required this.platform, required this.arch, this.archName});

  @override
  String toString() {
    return 'BuildLibItem{platform: $platform, arch: $arch, archName: $archName}';
  }
}

Future<void> checkDeps({
  List<String>? commands,
  Map<String, String>? devLibs,
  Map<String, String>? rtLibs,
  List<String>? files,
  List<String>? ndks,
}) async {
  final missing = <String>[];

  if (devLibs != null && devLibs.isNotEmpty) {
    final pkgConfigExists = (await Process.run('which', ['pkg-config'])).exitCode == 0;
    if (!pkgConfigExists) {
      missing.add('pkg-config');
    } else {
      for (final entry in devLibs.entries) {
        final result = await Process.run('pkg-config', ['--exists', entry.value]);
        if (result.exitCode != 0) missing.add(entry.key);
      }
    }
  }

  if (rtLibs != null && rtLibs.isNotEmpty) {
    for (final entry in rtLibs.entries) {
      final result = await Process.run('sh', ['-c', 'ldconfig -p | grep ${entry.value}']);
      if (result.exitCode != 0) missing.add(entry.key);
    }
  }

  if (ndks != null && ndks.isNotEmpty) {
    final sdkmanager = join(Platform.environment['ANDROID_HOME']!, 'cmdline-tools', 'latest', 'bin', 'sdkmanager');
    final cmdlineToolsExist = File(sdkmanager).existsSync();
    if (!cmdlineToolsExist) {
      missing.add('Android SDK Command-line Tools');
    } else {
      for (final ndkVersion in ndks) {
        final result = await Process.run(sdkmanager, ['--list_installed']);
        final pattern = RegExp('^\\s.${RegExp.escape('ndk;$ndkVersion')}', multiLine: true);
        final installed = pattern.hasMatch(result.stdout);
        if (!installed) {
          missing.add('Android NDK $ndkVersion');
        }
      }
    }
  }

  if (commands != null && commands.isNotEmpty) {
    for (final cmd in commands) {
      final result = Platform.isWindows
          ? await Process.run('where.exe', [cmd])
          : await Process.run('which', [cmd]);
      if (result.exitCode != 0) {
        missing.add(cmd);
      }
    }
  }

  if (files != null && files.isNotEmpty) {
    for (final filePath in files) {
      if (!File(filePath).existsSync()) {
        missing.add(basename(filePath));
      }
    }
  }

  if (missing.isNotEmpty) {
    throw 'Missing required dependencies: ${missing.join(", ")}. '
        'Please install them first. See README for details.';
  }
}

class Build {
  static bool isDev = false;

  static String get identityName => isDev ? '${appName}Dev' : appName;

  static List<BuildItem> get buildItems => [
    BuildItem(platform: TargetPlatform.macos, arch: Arch.arm64),
    BuildItem(platform: TargetPlatform.macos, arch: Arch.amd64),
    BuildItem(platform: TargetPlatform.linux, arch: Arch.arm64),
    BuildItem(platform: TargetPlatform.linux, arch: Arch.amd64),
    BuildItem(platform: TargetPlatform.windows, arch: Arch.amd64),
    BuildItem(platform: TargetPlatform.windows, arch: Arch.arm64),
    BuildItem(
      platform: TargetPlatform.android,
      arch: Arch.arm,
      archName: 'armeabi-v7a',
    ),
    BuildItem(
      platform: TargetPlatform.android,
      arch: Arch.arm64,
      archName: 'arm64-v8a',
    ),
    BuildItem(
      platform: TargetPlatform.android,
      arch: Arch.amd64,
      archName: 'x86_64',
    ),
  ];

  static String get appName => 'Bettbox';

  static String get coreName => '${identityName}Core';

  static String get helperName => '${identityName}HelperService';

  static String get libName => 'libclash';

  static String get outDir => join(current, libName);

  static String get _coreDir => join(current, 'core');

  static String get _servicesDir => join(current, 'services', 'helper');

  static String get distPath => join(current, 'dist');

  static String getTags(BuildItem buildItem) {
    final baseTags = 'with_gvisor';
    if (buildItem.platform == TargetPlatform.android &&
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
    required CoreMode mode,
    required TargetPlatform platform,
    Arch? arch,
    bool compatible = false,
  }) async {
    final isLib = mode == CoreMode.lib;

    final items = buildItems.where((element) {
      return element.platform == platform && (arch == null || element.arch == arch);
    }).toList();

    final List<String> corePaths = [];

    for (final item in items) {
      final outFileDir = join(outDir, item.platform.name, item.archName);

      final file = File(outFileDir);
      if (file.existsSync()) {
        file.deleteSync(recursive: true);
      }

      final fileName = isLib
          ? '$libName${item.platform.dynamicLibExtensionName}'
          : '$coreName${item.platform.executableExtensionName}';
      final outPath = join(outFileDir, fileName);
      corePaths.add(outPath);

      final Map<String, String> env = {};
      env['GOOS'] = item.platform.os;
      env['GOARCH'] = item.arch.name;
      if (item.arch == Arch.amd64 &&
          (item.platform == TargetPlatform.windows ||
              item.platform == TargetPlatform.linux ||
              item.platform == TargetPlatform.macos)) {
        env['GOAMD64'] = compatible ? 'v1' : 'v3';
      }
      if (isLib) {
        env['CGO_ENABLED'] = '1';
        env['CFLAGS'] = '-O3 -Werror';
        if (item.platform == TargetPlatform.android) {
          var ndkPath = Platform.environment['ANDROID_NDK'];
          if (ndkPath == null) {
            const ndkVersion = '28.2.13676358';
            final androidHome = Platform.environment['ANDROID_HOME']!;
            await checkDeps(ndks: [ndkVersion]);
            ndkPath = join(androidHome, 'ndk', ndkVersion);
          }
          final prebuiltDir = Directory(join(ndkPath, 'toolchains', 'llvm', 'prebuilt'));
          final map = {
            'armeabi-v7a': 'armv7a-linux-androideabi21-clang',
            'arm64-v8a': 'aarch64-linux-android21-clang',
            'x86': 'i686-linux-android21-clang',
            'x86_64': 'x86_64-linux-android21-clang',
          };
          env['CC'] = join(prebuiltDir.listSync().first.path, 'bin', map[item.archName]);
        } else {
          env['CC'] = 'gcc';
          await checkDeps(commands: ['gcc']);
        }
      } else {
        env['CGO_ENABLED'] = '0';
      }

      final buildTags = getTags(item);

      await checkDeps(commands: ['go']);
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
        '-ldflags=-w -s${item.platform == TargetPlatform.android && (item.arch == Arch.arm64 || item.arch == Arch.amd64) ? ' -extldflags "-Wl,-z,max-page-size=16384"' : ''}',
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

  static Future<void> buildHelper(TargetPlatform platform, String token) async {
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
      'helper${platform.executableExtensionName}',
    );
    final targetPath = join(
      Build.outDir,
      platform.name,
      '${Build.helperName}${platform.executableExtensionName}',
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
  TargetPlatform platform;

  //TODO: Delete arg option 'targets' for android
  BuildCommand({required this.platform}) {
    if (platform == TargetPlatform.android ||
        platform == TargetPlatform.linux) {
      argParser.addOption(
        'arch',
        valueHelp: arches.map((e) => e.name).join(','),
        help: 'The $name build desc',
      );
      argParser.addOption(
        'targets',
        valueHelp: 'deb,zip,appimage,rpm',
        help: 'The linux package formats (comma separated)',
      );
    } else {
      argParser.addOption(
        'arch',
        valueHelp: arches.map((e) => e.name).join(','),
        help: 'The $name build archName',
      );
    }
    argParser.addOption(
      'out',
      valueHelp: [
        if (platform.buildable) 'app',
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
  String get name => platform.name;

  List<Arch> get arches => Build.buildItems
      .where((element) => element.platform == platform)
      .map((e) => e.arch)
      .toList();

  Future<void> _setLinuxCoreSetuid() async {
    final coreFile = File('libclash/linux/BettboxCore');
    if (!coreFile.existsSync()) return;
    try {
      await Process.run('chmod', ['+sx', coreFile.path]);
    } catch (_) {}
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
    required TargetPlatform platform,
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
      name: description,
      Build.getExecutable(
'flutter_distributor package --skip-clean --platform ${platform.name} --targets $targets --flutter-build-args=verbose$args$sentryArg$suffixArg$ipinfoArg --build-dart-define=APP_ENV=$env$appDevArg',
      ),
      environment: environment,
    );
  }

  List<String> _expectedOutputs(Arch? arch) {
    final items = Build.buildItems.where((element) {
      return element.platform == platform &&
          (arch == null ? true : element.arch == arch);
    });

    final outputs = <String>[];
    for (final item in items) {
      final outFileDir = join(Build.outDir, item.platform.name, item.archName);
      if (platform == TargetPlatform.android) {
        outputs.add(join(outFileDir, '${Build.libName}.so'));
        outputs.add(join(outFileDir, '${Build.libName}.h'));
        continue;
      }

      outputs.add(
        join(outFileDir, '${Build.coreName}${platform.executableExtensionName}'),
      );

      if (platform == TargetPlatform.windows) {
        outputs.add(
          join(
            outFileDir,
            '${Build.helperName}${platform.executableExtensionName}',
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

    if (platform == TargetPlatform.windows) {
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
    await execute(
      archName: argResults?['arch'],
      out: argResults?['out'],
      env: argResults?['env'] ?? 'pre',
      dev: argResults?['dev'] ?? false,
      ensure: argResults?['ensure'] ?? false,
      compatible: argResults?['compatible'] ?? false,
      coreHash: argResults?['core-hash'] as String?,
    );
  }

  Future<void> execute({
    String? archName,
    String? out,
    String env = 'pre',
    bool dev = false,
    bool ensure = false,
    bool compatible = false,
    String? coreHash,
  }) async {
    final coreMode = platform == TargetPlatform.android ? CoreMode.lib : CoreMode.core;
final String actualOut = out ?? (platform.buildable ? 'app' : 'core');
    Build.isDev = dev;

    Arch? arch = arches
        .where((element) => element.name == archName)
        .firstOrNull;

    if (platform != TargetPlatform.android) {
      arch ??= arches.where((element) => element.same).first;
    }

    if (ensure && actualOut != 'app') {
      if (_outputsAreFresh(arch)) {
        print('${platform.name} output already exists');
        return;
      }
    }

    final corePaths = await Build.buildCore(
      platform: platform,
      arch: arch,
      mode: coreMode,
      compatible: compatible,
    );

    if (actualOut == 'core-only') {
      return;
    }

    if (actualOut == 'helper') {
      if (platform != TargetPlatform.windows) {
        throw '--out helper is only supported for windows';
      }
      if (coreHash == null || coreHash.isEmpty) {
        throw '--core-hash is required when --out=helper';
      }
      await Build.buildHelper(platform, coreHash);
      return;
    }

    if (actualOut == 'app' && !platform.buildable) {
      print('Platform incompatible, core built only!');
      return;
    }

    if (actualOut != 'app') {
      if (platform == TargetPlatform.windows) {
        final token = await Build.calcSha256(corePaths.first);
        await Build.buildHelper(platform, token);
      }
      return;
    }

    final String desc = platform == TargetPlatform.android
        ? ''
        : '${archName ?? arch!.name}${compatible ? "-compatible" : ""}';

    String appAssetSuffix = '';
    switch (platform) {
      case TargetPlatform.windows:
        appAssetSuffix = 'windows-$desc-setup.exe';
        break;
      case TargetPlatform.macos:
        appAssetSuffix = 'macos-$desc.dmg';
        break;
      case TargetPlatform.linux:
        break;
      case TargetPlatform.android:
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

    switch (platform) {
      case TargetPlatform.windows:
        if (!arch!.same) {
          throw 'Corss-build to $name ${arch.name} target is not currently supported!';
        }

        final token = platform != TargetPlatform.android
            ? await Build.calcSha256(corePaths.first)
            : null;
        await checkDeps(commands: ['cargo']);
        await Build.buildHelper(platform, token!);
        await checkDeps(
          commands: ['rustup'],
          files: [r'C:\Program Files (x86)\Inno Setup 6\ISCC.exe'],
        );
        await _buildDistributor(
          platform: platform,
          targets: 'exe',
          args: ' --description $desc --build-dart-define=CORE_SHA256=$token',
          env: env,
          suffix: appAssetSuffix,
          compatible: compatible,
        );
        return;
      case TargetPlatform.linux:
        if (!arch!.same) {
          throw 'Corss-build to $name ${arch.name} target is not currently supported!';
        }

        final validTargets = ['deb', 'rpm', 'appimage', 'zip'];
        final targets = argResults?['targets'] ?? <String>[];
        if (targets.isEmpty) {
          throw 'Invalid targets parameter';
        }
        final invalidTargets = targets.where((t) => !validTargets.contains(t)).toList();
        if (invalidTargets.isNotEmpty) {
          throw 'Invalid targets parameter: ${invalidTargets.join(', ')}';
        }

        final requiredCmds = ['clang', 'cmake', 'ninja', 'rustup'];
        Map<String, String> requiredRtLibs = {};
        if (targets.contains('deb')) requiredCmds.add('dpkg-deb');
        if (targets.contains('rpm')) requiredCmds.addAll(['rpm', 'patchelf']);
        if (targets.contains('appimage')) {
          requiredCmds.addAll(['appimagetool', 'locate']);
          requiredRtLibs.addAll({'libfuse2': 'libfuse.so.2'});
        }
        await checkDeps(
          commands: requiredCmds,
          devLibs: {
            'gtk3': 'gtk+-3.0',
            'libayatana-appindicator': 'ayatana-appindicator3-0.1',
            'keybinder-3.0': 'keybinder-3.0',
            'libcurl': 'libcurl',
          },
          rtLibs: requiredRtLibs,
        );

        final targetMap = {Arch.arm64: 'linux-arm64', Arch.amd64: 'linux-x64'};
        final defaultTarget = targetMap[arch];

        await _setLinuxCoreSetuid();

        for (final t in targets.isEmpty ? [''] : targets) {
          final ext = t == 'appimage' ? 'AppImage' : t;
          final currentSuffix = 'linux-$desc.$ext';

          await _buildDistributor(
            platform: platform,
            targets: t,
            args: ' --description $desc --build-target-platform $defaultTarget',
            env: env,
            suffix: currentSuffix,
            compatible: compatible,
          );
        }
        return;
      case TargetPlatform.android:
        await checkDeps(commands: ['rustup']);
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

        await _buildDistributor(
          platform: platform,
          targets: 'apk',
          args: buildArgs,
          env: env,
          suffix: appAssetSuffix,
          compatible: compatible,
        );
        return;
      case TargetPlatform.macos:
        await checkDeps(commands: ['rustup', 'appdmg']);
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
        await _buildDistributor(
          platform: platform,
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

class AutoBuildCommand extends Command {
  AutoBuildCommand() {
    argParser.addOption(
      'device-id',
      help: 'Target Flutter device ID (e.g. from \${command:flutter.getSelectedDeviceId})',
    );
    argParser.addOption(
      'arch',
      help: 'Target architecture (default: auto detect based on device)',
    );
    argParser.addOption(
      'out',
      valueHelp: ['app', 'core', 'core-only', 'helper'].join(','),
      defaultsTo: 'core',
      help: 'Build output type',
    );
    argParser.addOption(
      'core-hash',
      help: 'SHA256 hash of the core binary when --out=helper',
    );
    argParser.addOption(
      'env',
      valueHelp: ['pre', 'stable'].join(','),
      help: 'Build env',
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
  String get description => 'Automatically detect target device and build core';

  @override
  String get name => 'auto';

  @override
  Future<void> run() async {
    final optDeviceId = argResults?['device-id']?.toString().trim() ?? '';
    final rawDeviceId = optDeviceId.startsWith('-') ? '' : optDeviceId;
    final String? explicitArch = argResults?['arch'];

    TargetPlatform? platform;
    String? archName = explicitArch;

    if (rawDeviceId == 'windows') {
      platform = TargetPlatform.windows;
    } else if (rawDeviceId == 'macos') {
      platform = TargetPlatform.macos;
    } else if (rawDeviceId == 'linux') {
      platform = TargetPlatform.linux;
    } else if (rawDeviceId == 'chrome' ||
        rawDeviceId == 'edge' ||
        rawDeviceId == 'web-server') {
      print('Web device "$rawDeviceId" does not require core binary. Skipping.');
      return;
    } else if (rawDeviceId.isEmpty) {
      if (Platform.isWindows) {
        platform = TargetPlatform.windows;
      } else if (Platform.isMacOS) {
        platform = TargetPlatform.macos;
      } else if (Platform.isLinux) {
        platform = TargetPlatform.linux;
      } else {
        throw 'No device specified and unable to determine host platform.';
      }
    } else {
      final res = await Process.run(
        'flutter',
        ['devices', '--machine'],
        runInShell: true,
      );
      if (res.exitCode != 0) {
        throw 'Failed to execute "flutter devices --machine": ${res.stderr}';
      }
      final jsonList = jsonDecode(res.stdout.toString()) as List<dynamic>;
      final device = jsonList.cast<Map<String, dynamic>?>().firstWhere(
            (d) => d?['id'] == rawDeviceId,
            orElse: () => null,
          );

      if (device == null) {
        throw 'Device "$rawDeviceId" not found in flutter devices list.';
      }

      final targetPlatform =
          (device['targetPlatform'] as String? ?? '').toLowerCase();
      if (targetPlatform.startsWith('android')) {
        platform = TargetPlatform.android;
        if (archName == null) {
          if (targetPlatform.contains('arm64')) {
            archName = 'arm64';
          } else if (targetPlatform.contains('x64') ||
              targetPlatform.contains('x86_64')) {
            archName = 'amd64';
          } else if (targetPlatform.contains('arm')) {
            archName = 'arm';
          } else {
            throw 'Unsupported android platform architecture: $targetPlatform';
          }
        }
      } else if (targetPlatform.startsWith('darwin') ||
          targetPlatform.startsWith('macos')) {
        platform = TargetPlatform.macos;
      } else if (targetPlatform.startsWith('windows')) {
        platform = TargetPlatform.windows;
      } else if (targetPlatform.startsWith('linux')) {
        platform = TargetPlatform.linux;
      } else if (targetPlatform.startsWith('web')) {
        print(
          'Web target platform "$targetPlatform" does not require core binary. Skipping.',
        );
        return;
      } else {
        throw 'Unknown or unsupported targetPlatform: $targetPlatform';
      }
    }

    final cmd = BuildCommand(platform: platform);
    await cmd.execute(
      archName: archName,
      out: argResults?['out'] ?? 'core',
      env: argResults?['env'] ?? 'pre',
      dev: argResults?['dev'] ?? false,
      ensure: argResults?['ensure'] ?? false,
      compatible: argResults?['compatible'] ?? false,
      coreHash: argResults?['core-hash'] as String?,
    );
  }
}

Future<void> main(Iterable<String> args) async {
  final runner = CommandRunner('setup', 'build Application');
  runner.addCommand(AutoBuildCommand());
  runner.addCommand(BuildCommand(platform: TargetPlatform.android));
  runner.addCommand(BuildCommand(platform: TargetPlatform.linux));
  runner.addCommand(BuildCommand(platform: TargetPlatform.windows));
  runner.addCommand(BuildCommand(platform: TargetPlatform.macos));
  await runner.run(args);
}
