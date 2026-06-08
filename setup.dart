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

  static String get coreName => 'BettboxCore';

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
    final stream = file.openRead();
    return sha256.convert(await stream.reduce((a, b) => a + b)).toString();
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
      outDir,
      target.name,
      'BettboxHelperService${target.executableExtensionName}',
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
        valueHelp: arches.map((e) => e.name).join(','),
        help: 'The $name build desc',
      );
    } else {
      argParser.addOption('arch', help: 'The $name build archName');
    }
    argParser.addOption(
      'out',
      valueHelp: [if (target.same) 'app', 'core'].join(','),
      help: 'The $name build arch',
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

  Future<void> _getMacosDependencies() async {
    await Build.exec(Build.getExecutable('npm install -g appdmg'));
  }

  Future<void> _setMacOSCompatibleBuild(bool enable) async {
    final infoPlistPath = 'macos/Runner/Info.plist';
    final file = File(infoPlistPath);

    if (!await file.exists()) {
      print('Warning: Info.plist not found at $infoPlistPath');
      return;
    }

    var content = await file.readAsString();

    // Check if FLTDisableImpeller key exists
    if (content.contains('<key>FLTDisableImpeller</key>')) {
      // Update existing key
      if (enable) {
        content = content.replaceAll(
          RegExp(r'<key>FLTDisableImpeller</key>\s*<(?:true|false)/>'),
          '<key>FLTDisableImpeller</key>\n\t<true/>',
        );
      } else {
        content = content.replaceAll(
          RegExp(r'<key>FLTDisableImpeller</key>\s*<(?:true|false)/>'),
          '<key>FLTDisableImpeller</key>\n\t<false/>',
        );
      }
    } else {
      // Add new key before </dict>
      final impellerEntry = enable
          ? '\t<key>FLTDisableImpeller</key>\n\t<true/>\n'
          : '\t<key>FLTDisableImpeller</key>\n\t<false/>\n';
      content = content.replaceFirst(
        '</dict>\n</plist>',
        '$impellerEntry</dict>\n</plist>',
      );
    }

    await file.writeAsString(content);
    print('macOS ${enable ? "Compatible" : "Standard"} build: FLTDisableImpeller set to $enable');
  }

  Future<void> _setWindowsCompatibleBuild(bool enable) async {
    final cmakePath = 'windows/CMakeLists.txt';
    final file = File(cmakePath);

    if (!await file.exists()) {
      print('Warning: CMakeLists.txt not found at $cmakePath');
      return;
    }

    var content = await file.readAsString();
    final hasDefinition = content.contains('FLUTTER_DISABLE_IMPELLER');

    if (enable) {
      if (!hasDefinition) {
        content = content.replaceFirst(
          'project(Bettbox LANGUAGES CXX)',
          'project(Bettbox LANGUAGES CXX)\n\nadd_definitions(-DFLUTTER_DISABLE_IMPELLER=1)',
        );
      }
    } else {
      if (hasDefinition) {
        content = content.replaceAll(
          RegExp(r'\n?add_definitions\(-DFLUTTER_DISABLE_IMPELLER=1\)\n?'),
          '\n',
        );
      }
    }

    await file.writeAsString(content);
    print('Windows ${enable ? "Compatible" : "Standard"} build: Impeller ${enable ? "disabled" : "enabled"}');
  }

  Future<void> _setLinuxCompatibleBuild(bool enable) async {
    final cmakePath = 'linux/CMakeLists.txt';
    final file = File(cmakePath);

    if (!await file.exists()) {
      print('Warning: CMakeLists.txt not found at $cmakePath');
      return;
    }

    var content = await file.readAsString();
    final hasDefinition = content.contains('FLUTTER_DISABLE_IMPELLER');

    if (enable) {
      if (!hasDefinition) {
        content = content.replaceFirst(
          'set(APPLICATION_ID "com.appshub.bettbox")',
          'set(APPLICATION_ID "com.appshub.bettbox")\n\nadd_definitions(-DFLUTTER_DISABLE_IMPELLER=1)',
        );
      }
    } else {
      if (hasDefinition) {
        content = content.replaceAll(
          RegExp(r'\n?add_definitions\(-DFLUTTER_DISABLE_IMPELLER=1\)\n?'),
          '\n',
        );
      }
    }

    await file.writeAsString(content);
    print('Linux ${enable ? "Compatible" : "Standard"} build: Impeller ${enable ? "disabled" : "enabled"}');
  }

  Future<void> _buildDistributor({
    required Target target,
    required String targets,
    String args = '',
    required String env,
  }) async {
    final sentryDsn = Platform.environment['SENTRY_DSN'] ?? '';
    final sentryArg = sentryDsn.isNotEmpty
        ? ' --build-dart-define=SENTRY_DSN=$sentryDsn'
        : '';

    await Build.getDistributor();
    await Build.exec(
      name: name,
      Build.getExecutable(
        'flutter_distributor package --skip-clean --platform ${target.name} --targets $targets --flutter-build-args=verbose$args$sentryArg --build-dart-define=APP_ENV=$env',
      ),
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

  @override
  Future<void> run() async {
    final mode = target == Target.android ? Mode.lib : Mode.core;
    final String out = argResults?['out'] ?? (target.same ? 'app' : 'core');
    final archName = argResults?['arch'];
    final env = argResults?['env'] ?? 'pre';
    final currentArches = arches
        .where((element) => element.name == archName)
        .toList();
    final arch = currentArches.isEmpty ? null : currentArches.first;

    if (arch == null && target != Target.android) {
      throw 'Invalid arch parameter';
    }

    final bool compatible = argResults?['compatible'] ?? false;

    final corePaths = await Build.buildCore(
      target: target,
      arch: arch,
      mode: mode,
      compatible: compatible,
    );

    if (out != 'app') {
      return;
    }

    final String desc = compatible ? '$archName-compatible' : (archName ?? '');

    switch (target) {
      case Target.windows:
        final token = target != Target.android
            ? await Build.calcSha256(corePaths.first)
            : null;
        Build.buildHelper(target, token!);
        if (compatible) {
          await _setWindowsCompatibleBuild(true);
        } else {
          await _setWindowsCompatibleBuild(false);
        }
        _buildDistributor(
          target: target,
          targets: 'exe',
          args: ' --description $desc --build-dart-define=CORE_SHA256=$token',
          env: env,
        );
        return;
      case Target.linux:
        final targetMap = {Arch.arm64: 'linux-arm64', Arch.amd64: 'linux-x64'};
        final targets = [
          'deb',
          if (arch == Arch.amd64) 'appimage',
          if (arch == Arch.amd64) 'rpm',
        ].join(',');
        final defaultTarget = targetMap[arch];
        await _getLinuxDependencies(arch!);
        if (compatible) {
          await _setLinuxCompatibleBuild(true);
        } else {
          await _setLinuxCompatibleBuild(false);
        }
        _buildDistributor(
          target: target,
          targets: targets,
          args: ' --description $desc --build-target-platform $defaultTarget',
          env: env,
        );
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
        );
        return;
      case Target.macos:
        await _getMacosDependencies();
        // For compatible build, disable Impeller and use Skia renderer
        if (compatible) {
          await _setMacOSCompatibleBuild(true);
        } else {
          await _setMacOSCompatibleBuild(false);
        }
        _buildDistributor(
          target: target,
          targets: 'dmg',
          args: ' --description $desc',
          env: env,
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
