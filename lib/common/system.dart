import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:ffi/ffi.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/common/helper_auth.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/helper/helper.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:restart_app/restart_app.dart';
import 'package:synchronized/synchronized.dart';

class System {
  static System? _instance;

  System._internal();

  factory System() {
    _instance ??= System._internal();
    return _instance!;
  }

  bool get isDesktop => isWindows || isMacOS || isLinux;

  bool get isWindows => Platform.isWindows;

  bool get isMacOS => Platform.isMacOS;

  bool get isAndroid => Platform.isAndroid;

  bool get isLinux => Platform.isLinux;

  Future<int> get version async {
    final deviceInfo = await DeviceInfoPlugin().deviceInfo;
    return switch (Platform.operatingSystem) {
      'macos' => (deviceInfo as MacOsDeviceInfo).majorVersion,
      'android' => (deviceInfo as AndroidDeviceInfo).version.sdkInt,
      'windows' => (deviceInfo as WindowsDeviceInfo).majorVersion,
      String() => 0,
    };
  }

  Future<String> get deviceName async {
    try {
      if (isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        return info.model.isNotEmpty ? info.model : info.device;
      }
      final host = Platform.localHostname;
      return host.endsWith('.local')
          ? host.substring(0, host.length - '.local'.length)
          : host;
    } catch (_) {
      return '';
    }
  }

  Future<void> updateDns(bool restore) async {
    await macOS?.restoreDns();
    await linux?.updateDns(restore);
  }

  static String _shellEscape(String value) {
    return "'${value.replaceAll("'", "'\\''")}'";
  }

  static Future<bool> _isSetuidRootOwned(
    String corePath,
    String ownerPrefix,
  ) async {
    final macOS = system.isMacOS;
    final result = await Process.run('stat', [
      if (macOS) '-f' else '-c',
      if (macOS) '%Su:%Sg %Sp' else '%U:%G %A',
      corePath,
    ]);
    if (result.exitCode != 0) return false;
    final parts = result.stdout.toString().trim().split(' ');
    if (parts.length < 2) return false;
    return parts.first.startsWith(ownerPrefix) && parts.last.contains('s');
  }

  static Future<bool> _hasCoreCapabilities() async {
    for (final getcap in [
      'getcap',
      '/usr/sbin/getcap',
      '/sbin/getcap',
      '/usr/bin/getcap',
      '/bin/getcap',
    ]) {
      try {
        final result = await Process.run(getcap, [appPath.corePath]);
        return result.exitCode == 0 &&
            result.stdout.toString().contains('cap_net_admin');
      } catch (_) {}
    }
    return false;
  }

  Future<bool> checkIsAdmin() async {
    if (system.isWindows) {
      if (!(windows?.usesHelper ?? false)) {
        return windows?.isUserAnAdmin ?? false;
      }
      final result = await windows?.checkService();
      return result == WindowsHelperServiceStatus.running;
    }

    if (system.isMacOS) {
      return _isSetuidRootOwned(appPath.corePath, 'root:admin');
    }

    if (Platform.isLinux) {
      if (appPath.isAppImage) {
        await appPath.ensureAppImageCoreSynced();
      }
      return await _isSetuidRootOwned(appPath.corePath, 'root:') ||
          await _hasCoreCapabilities();
    }

    return true;
  }

  Future<AuthorizeCode> authorizeCore() async {
    if (system.isAndroid) return AuthorizeCode.none;

    if (Platform.isLinux) return _authorizeLinuxCore();

    if (await checkIsAdmin()) return AuthorizeCode.none;

    if (system.isWindows) {
      if (!(windows?.usesHelper ?? false)) return AuthorizeCode.error;
      if (await windows?.isHelperHealthy() ?? false) return AuthorizeCode.none;
      final result = await windows?.registerService();
      return result == true ? AuthorizeCode.success : AuthorizeCode.error;
    }

    if (system.isMacOS) {
      var quarantineCleared = true;
      const quarantineAttr = 'com.apple.quarantine';
      final core = _shellEscape(appPath.corePath);

      final xattrCheck = await Process.run('/usr/bin/xattr', [
        '-p',
        quarantineAttr,
        appPath.corePath,
      ]);
      if (xattrCheck.exitCode == 0) {
        final removeResult = await Process.run('/usr/bin/xattr', [
          '-d',
          quarantineAttr,
          appPath.corePath,
        ]);
        if (removeResult.exitCode == 0) {
          commonPrint.log('Cleared quarantine attribute from BettboxCore');
        } else {
          quarantineCleared = false;
          commonPrint.warn(
            'Failed to clear quarantine attribute: ${removeResult.stderr}',
          );
        }
      }

      final shell = 'chown root:admin $core && chmod u+s $core';
      final result = await Process.run('osascript', [
        '-e',
        'do shell script "$shell" with administrator privileges',
      ]);

      if (result.exitCode != 0) {
        globalState.showNotifier(
          !quarantineCleared
              ? 'Failed to authorize BettboxCore. Try: xattr -dr com.apple.quarantine /Applications/Bettbox.app'
              : appLocalizations.tunEnableRequireAdmin,
        );
        return AuthorizeCode.error;
      }
      return AuthorizeCode.success;
    }

    return AuthorizeCode.error;
  }

  Future<AuthorizeCode> _authorizeLinuxCore() async {
    if (appPath.isAppImage) {
      await appPath.ensureAppImageCoreSynced();
    }
    final corePath = appPath.corePath;
    if (await _isOnNosuidMount(corePath)) {
      globalState.showNotifier(appLocalizations.coreMountNosuid);
      return AuthorizeCode.error;
    }
    if (await _isSetuidRootOwned(corePath, 'root:')) return AuthorizeCode.none;

    final needCapabilities = !await _hasCoreCapabilities();
    final dataDirRepair = await _dataDirRepairScript;
    final stagedRule = await _stagePolkitRule();
    if (!needCapabilities && dataDirRepair == null && stagedRule == null) {
      return AuthorizeCode.none;
    }

    final script = [
      _legacyPolkitRuleCleanupScript,
      ?dataDirRepair,
      if (stagedRule != null) _polkitRuleInstallScript(stagedRule.path),
      if (needCapabilities) _linuxCapabilityScript(corePath),
    ].join('\n');
    final result = await _runPrivileged(script);
    await stagedRule?.delete();
    if (stagedRule != null && result != null) {
      await _recordPolkitRuleOutcome(result.stdout);
    }

    if (!needCapabilities) {
      if (result?.exitCode != 0) {
        commonPrint.log('Privileged repair failed: ${result?.stderr.trim()}');
      }
      return AuthorizeCode.none;
    }

    final fallback = switch (result?.exitCode) {
      _setcapNotInstalledExit => appLocalizations.setcapNotInstalledFallback,
      _xattrUnsupportedExit => appLocalizations.xattrUnsupportedFallback,
      _setcapFailedExit => appLocalizations.setcapFailedFallback,
      _ => null,
    };
    if (fallback != null) {
      commonPrint.log('Falling back to setuid: ${result?.stderr.trim()}');
      globalState.showNotifier(fallback);
      return AuthorizeCode.success;
    }
    if (result?.exitCode == 0) return AuthorizeCode.success;

    globalState.showNotifier(appLocalizations.tunEnableRequireAdmin);
    return AuthorizeCode.error;
  }

  static const _setcapNotInstalledExit = 10;

  static const _xattrUnsupportedExit = 11;

  static const _setcapFailedExit = 12;

  static const _polkitRuleFileName = '90-bettbox.rules';

  static const _legacyPolkitRuleFileName = '99-bettbox.rules';

  static const _polkitRuleSystemPath =
      '/usr/share/polkit-1/rules.d/$_polkitRuleFileName';

  static String _linuxCapabilityScript(String corePath) {
    final core = _shellEscape(corePath);
    const capabilities = 'cap_net_admin,cap_net_bind_service,cap_net_raw=+ep';
    return [
      'export PATH="/usr/sbin:/sbin:/usr/bin:/bin:\$PATH"',
      'if command -v setcap >/dev/null 2>&1; then',
      "  if output=\$(setcap '$capabilities' $core 2>&1); then",
      '    sync',
      '    exit 0',
      '  fi',
      '  echo "\$output" >&2',
      '  case "\$output" in',
      '    *"not supported"*) fallback=$_xattrUnsupportedExit ;;',
      '    *) fallback=$_setcapFailedExit ;;',
      '  esac',
      'else',
      '  fallback=$_setcapNotInstalledExit',
      'fi',
      'chown root:root $core && chmod u+s $core && sync || exit 1',
      'exit "\$fallback"',
    ].join('\n');
  }

  static const _legacyPolkitRuleCleanupScript =
      'rm -f /etc/polkit-1/rules.d/$_legacyPolkitRuleFileName '
      '/usr/share/polkit-1/rules.d/$_legacyPolkitRuleFileName';

  static const _polkitRuleEtcPath =
      '/etc/polkit-1/rules.d/$_polkitRuleFileName';

  static const _polkitRuleEtcMarker = 'bettbox-polkit-rule:etc';

  static const _polkitRuleFailedMarker = 'bettbox-polkit-rule:failed';

  static const _polkitRuleSettledKey = 'linux_polkit_rule_settled';

  static String _polkitRuleInstallScript(String stagedPath) {
    final staged = _shellEscape(stagedPath);
    return [
      'if ! install -Dm644 $staged $_polkitRuleSystemPath 2>/dev/null; then',
      '  if install -Dm644 $staged $_polkitRuleEtcPath; then',
      '    echo $_polkitRuleEtcMarker',
      '  else',
      '    echo $_polkitRuleFailedMarker',
      '  fi',
      'fi',
    ].join('\n');
  }

  static Future<void> _recordPolkitRuleOutcome(String stdout) async {
    final settled =
        stdout.contains(_polkitRuleEtcMarker) ||
        stdout.contains(_polkitRuleFailedMarker);
    if (!settled) return;
    commonPrint.log('Polkit rule outcome: ${stdout.trim()}');
    final prefs = await preferences.sharedPreferencesCompleter.future;
    await prefs?.setBool(_polkitRuleSettledKey, true);
  }

  static Future<bool> _isOnNosuidMount(String path) async {
    try {
      final target = await File(path).resolveSymbolicLinks();
      final lines = await File('/proc/self/mountinfo').readAsLines();
      final octal = RegExp(r'\\([0-7]{3})');
      var bestLength = -1;
      var nosuid = false;
      for (final line in lines) {
        final fields = line.split(' ');
        if (fields.length < 6) continue;
        final mountPoint = fields[4].replaceAllMapped(
          octal,
          (m) => String.fromCharCode(int.parse(m[1] ?? '0', radix: 8)),
        );
        final contains =
            mountPoint == '/' ||
            target == mountPoint ||
            target.startsWith('$mountPoint/');
        if (!contains || mountPoint.length < bestLength) continue;
        bestLength = mountPoint.length;
        nosuid = fields[5].split(',').contains('nosuid');
      }
      return nosuid;
    } catch (_) {
      return false;
    }
  }

  Future<void> verifyCoreProcessPrivileges(int pid) async {
    if (!Platform.isLinux || !globalState.appState.realTunEnable) return;
    final corePath = appPath.corePath;
    if (!await _isSetuidRootOwned(corePath, 'root:') &&
        !await _hasCoreCapabilities()) {
      return;
    }
    try {
      for (var attempt = 0; attempt < 3; attempt++) {
        final lines = await File('/proc/$pid/status').readAsLines();
        String? field(String name) => lines
            .where((line) => line.startsWith('$name:'))
            .map((line) => line.substring(name.length + 1).trim())
            .firstOrNull;
        final effectiveUid = field(
          'Uid',
        )?.split(RegExp(r'\s+')).elementAtOrNull(1);
        final capEff = int.tryParse(field('CapEff') ?? '', radix: 16) ?? 0;
        const capNetAdmin = 1 << 12;
        if (effectiveUid == '0' || capEff & capNetAdmin != 0) return;
        await Future.delayed(const Duration(milliseconds: 100));
      }
      commonPrint.log('Core process lacks CAP_NET_ADMIN');
      globalState.showNotifier(appLocalizations.coreCapabilityNotEffective);
    } catch (e) {
      commonPrint.log('Core privilege check skipped: $e');
    }
  }

  static Future<File?> _stagePolkitRule() async {
    final bundled = File(join(appPath.executableDirPath, _polkitRuleFileName));
    if (!await bundled.exists()) return null;
    if (await File(_polkitRuleSystemPath).exists()) return null;
    final prefs = await preferences.sharedPreferencesCompleter.future;
    if (prefs?.getBool(_polkitRuleSettledKey) ?? false) return null;
    return bundled.copy(join(await appPath.homeDirPath, _polkitRuleFileName));
  }

  static Future<String?> get _dataDirRepairScript async {
    final uid = await _idField('-u');
    final gid = await _idField('-g');
    if (uid == null || gid == null) return null;

    final homeDir = await appPath.homeDirPath;
    try {
      final result = await Process.run('find', [
        homeDir,
        '!',
        '-user',
        '$uid',
        '-print',
        '-quit',
      ]);
      if (result.stdout.toString().trim().isEmpty) return null;
    } catch (_) {
      return null;
    }
    return 'chown -R $uid:$gid ${_shellEscape(homeDir)}';
  }

  static Future<int?> _idField(String flag) async {
    try {
      final result = await Process.run('id', [flag]);
      if (result.exitCode != 0) return null;
      return int.tryParse(result.stdout.toString().trim());
    } catch (_) {
      return null;
    }
  }

  Future<({int exitCode, String stdout, String stderr})?> _runPrivileged(
    String script,
  ) async {
    try {
      final result = await Process.run('pkexec', ['sh', '-c', script]);
      if (result.exitCode != 127) {
        return (
          exitCode: result.exitCode,
          stdout: result.stdout.toString(),
          stderr: result.stderr.toString(),
        );
      }
    } catch (e) {
      commonPrint.warn('pkexec failed: $e');
    }

    window?.show();
    final password = await globalState.showCommonDialog<String>(
      child: InputDialog(
        obscureText: true,
        title: appLocalizations.pleaseInputAdminPassword,
        value: '',
      ),
    );
    if (password == null || password.isEmpty) return null;

    final Process process;
    try {
      process = await Process.start('sudo', [
        '-S',
        '-p',
        '',
        'sh',
        '-c',
        script,
      ]);
    } catch (e) {
      commonPrint.warn('sudo failed: $e');
      return null;
    }
    final stdout = process.stdout.transform(utf8.decoder).join();
    final stderr = process.stderr.transform(utf8.decoder).join();
    process.stdin.writeln(password);
    await process.stdin.close();
    return (
      exitCode: await process.exitCode,
      stdout: await stdout,
      stderr: await stderr,
    );
  }

  Future<void> back() async {
    if (system.isAndroid) await app.moveTaskToBack();
    await window?.hide();
  }

  Future<void> exit() async {
    if (system.isAndroid) await SystemNavigator.pop();
    await window?.close();
  }

  Future<void> restartAsAdmin() async {
    final executable = Platform.resolvedExecutable.replaceAll("'", "''");
    final command =
        '-NoProfile -WindowStyle Hidden -Command "Wait-Process -Id $pid -ErrorAction SilentlyContinue; Start-Process -FilePath \'$executable\'"';
    if (!(windows?.runas('powershell.exe', command) ?? false)) return;
    await globalState.appController.handleExit();
  }

  Future<void> restartApp() async {
    if (Platform.isLinux) {
      final appImage = Platform.environment['APPIMAGE'];
      final executable = (appImage != null && appImage.isNotEmpty)
          ? appImage
          : Platform.resolvedExecutable;
      await Process.start('sh', [
        '-c',
        'while kill -0 \$1 2>/dev/null; do sleep 0.1; done; exec "\$2"',
        '--',
        '$pid',
        executable,
      ], mode: ProcessStartMode.detached);
      await globalState.appController.handleExit();
      return;
    }
    if (isAndroid) {
      await globalState.appController.savePreferences();
      await Restart.restartApp(forceKill: true);
      return;
    }
    await Restart.restartApp();
  }

  Future<void> setProcessPriority(String processName, bool enable) async {
    if (!isWindows) return;

    if (processName == '${AppIdentity.mainExecutableName}.exe') {
      try {
        windows?.setCurrentProcessPriority(enable);
        return;
      } catch (e) {
        commonPrint.warn('Failed to set current process priority: $e');
      }
    }

    final result = await Process.run('wmic', [
      'process',
      'where',
      'name="$processName"',
      'call',
      'setpriority',
      enable ? 'above normal' : 'normal',
    ]);

    if (result.exitCode != 0) {
      throw Exception('Failed to set process priority: ${result.stderr}');
    }
  }

  void purgeMemory() {
    if (!isLinux && !isMacOS) return;
    try {
      final process = DynamicLibrary.process();
      if (isLinux) {
        process
            .lookupFunction<Int32 Function(UintPtr pad), int Function(int pad)>(
              'malloc_trim',
            )(0);
      } else {
        process.lookupFunction<
          UintPtr Function(Pointer<Void> zone, UintPtr goal),
          int Function(Pointer<Void> zone, int goal)
        >('malloc_zone_pressure_relief')(nullptr, 0);
      }
    } catch (_) {}
  }
}

final system = System();

class Windows {
  static Windows? _instance;
  late DynamicLibrary _shell32;

  Windows._internal() {
    _shell32 = DynamicLibrary.open('shell32.dll');
  }

  factory Windows() {
    _instance ??= Windows._internal();
    return _instance!;
  }

  void setCurrentProcessPriority(bool enable) {
    final kernel32 = DynamicLibrary.open('kernel32.dll');

    final getCurrentProcess = kernel32
        .lookupFunction<IntPtr Function(), int Function()>('GetCurrentProcess');

    final setPriorityClass = kernel32
        .lookupFunction<
          Int32 Function(IntPtr hProcess, Int32 dwPriorityClass),
          int Function(int hProcess, int dwPriorityClass)
        >('SetPriorityClass');

    final setProcessInformation = kernel32
        .lookupFunction<
          Int32 Function(
            IntPtr hProcess,
            Int32 processInformationClass,
            Pointer<Void> processInformation,
            Uint32 processInformationSize,
          ),
          int Function(
            int hProcess,
            int processInformationClass,
            Pointer<Void> processInformation,
            int processInformationSize,
          )
        >('SetProcessInformation');

    final priorityClass = enable ? 0x00008000 : 0x00000020;

    final hProcess = getCurrentProcess();
    final result = setPriorityClass(hProcess, priorityClass);

    if (result == 0) {
      throw Exception('SetPriorityClass failed');
    }

    commonPrint.log(
      'Set current process priority to ${enable ? "above normal" : "normal"}',
    );

    if (enable) {
      final memoryPriorityInfo = calloc<Uint32>();
      try {
        memoryPriorityInfo.value = 5;
        final memoryResult = setProcessInformation(
          hProcess,
          0,
          memoryPriorityInfo.cast<Void>(),
          sizeOf<Uint32>(),
        );
        if (memoryResult == 0) {
          commonPrint.warn('Set current process memory priority failed');
        } else {
          commonPrint.log('Set current process memory priority to normal');
        }
      } finally {
        calloc.free(memoryPriorityInfo);
      }
    }
  }

  void setBackgroundMemoryPriority(bool background) {
    try {
      final kernel32 = DynamicLibrary.open('kernel32.dll');
      final getCurrentProcess = kernel32
          .lookupFunction<IntPtr Function(), int Function()>(
            'GetCurrentProcess',
          );
      final setProcessInformation = kernel32
          .lookupFunction<
            Int32 Function(
              IntPtr hProcess,
              Int32 processInformationClass,
              Pointer<Void> processInformation,
              Uint32 processInformationSize,
            ),
            int Function(
              int hProcess,
              int processInformationClass,
              Pointer<Void> processInformation,
              int processInformationSize,
            )
          >('SetProcessInformation');
      final memoryPriorityInfo = calloc<Uint32>();
      try {
        memoryPriorityInfo.value = background ? 1 : 5;
        setProcessInformation(
          getCurrentProcess(),
          0,
          memoryPriorityInfo.cast<Void>(),
          sizeOf<Uint32>(),
        );
      } finally {
        calloc.free(memoryPriorityInfo);
      }
    } catch (_) {}
  }

  void emptyWorkingSet() {
    try {
      final kernel32 = DynamicLibrary.open('kernel32.dll');
      final getCurrentProcess = kernel32
          .lookupFunction<IntPtr Function(), int Function()>(
            'GetCurrentProcess',
          );
      final emptyWorkingSet = kernel32
          .lookupFunction<
            Int32 Function(IntPtr hProcess),
            int Function(int hProcess)
          >('K32EmptyWorkingSet');
      emptyWorkingSet(getCurrentProcess());
    } catch (_) {}
  }

  bool get usesHelper => !kDebugMode && !appPath.isPortable;

  bool get isUserAnAdmin {
    final isUserAnAdmin = _shell32
        .lookupFunction<Int32 Function(), int Function()>('IsUserAnAdmin');
    return isUserAnAdmin() != 0;
  }

  bool runas(String command, String arguments, {bool showWindow = false}) {
    final commandPtr = command.toNativeUtf16();
    final argumentsPtr = arguments.toNativeUtf16();
    final operationPtr = 'runas'.toNativeUtf16();

    final shellExecute = _shell32
        .lookupFunction<
          Int32 Function(
            Pointer<Utf16> hwnd,
            Pointer<Utf16> lpOperation,
            Pointer<Utf16> lpFile,
            Pointer<Utf16> lpParameters,
            Pointer<Utf16> lpDirectory,
            Int32 nShowCmd,
          ),
          int Function(
            Pointer<Utf16> hwnd,
            Pointer<Utf16> lpOperation,
            Pointer<Utf16> lpFile,
            Pointer<Utf16> lpParameters,
            Pointer<Utf16> lpDirectory,
            int nShowCmd,
          )
        >('ShellExecuteW');

    // 0 = hide, 1 = show
    final result = shellExecute(
      nullptr,
      operationPtr,
      commandPtr,
      argumentsPtr,
      nullptr,
      showWindow ? 1 : 0,
    );

    calloc.free(commandPtr);
    calloc.free(argumentsPtr);
    calloc.free(operationPtr);

    commonPrint.log('windows runas: [command masked] resultCode:$result');

    return result > 32;
  }

  Future<WindowsHelperServiceStatus> checkService() async {
    await HelperAuthManager.ensureAuthKey();
    final result = await Process.run('sc', ['query', appHelperService]);
    if (result.exitCode != 0) return WindowsHelperServiceStatus.none;

    final output = result.stdout.toString();
    if (!output.contains('RUNNING')) return WindowsHelperServiceStatus.presence;

    return await _pingHelper()
        ? WindowsHelperServiceStatus.running
        : WindowsHelperServiceStatus.presence;
  }

  Future<bool>? _registerServiceInFlight;

  Future<bool> registerService() {
    return _registerServiceInFlight ??= _registerService().whenComplete(
      () => _registerServiceInFlight = null,
    );
  }

  Future<bool> _registerService() async {
    await HelperAuthManager.ensureAuthKey();
    if (await isHelperHealthy()) return true;

    if (!await _configureHelperService()) return false;

    return _waitForHelperHealthy();
  }

  Future<bool> isHelperHealthy() async {
    final result = await Process.run('sc', ['query', appHelperService]);
    if (result.exitCode != 0) return false;

    if (!result.stdout.toString().contains('RUNNING')) return false;

    return _pingHelper();
  }

  Future<bool> _pingHelper() async {
    final coreSHA256 = await globalState.getOrCalcCoreSHA256();
    if (coreSHA256 == null || coreSHA256.isEmpty) return false;
    return helperClient.ping(coreSHA256);
  }

  Future<bool> _configureHelperService() async {
    final authKey = HelperAuthManager.getAuthKey();
    if (authKey == null) return false;

    final serviceRegistryPath =
        'HKLM\\SYSTEM\\CurrentControlSet\\Services\\$appHelperService';

    final command = [
      '/c',
      'net',
      'stop',
      appHelperService,
      '>nul',
      '2>&1',
      '&',
      'sc',
      'delete',
      appHelperService,
      '>nul',
      '2>&1',
      '&',
      'sc',
      'create',
      appHelperService,
      'binPath= "${appPath.helperPath}"',
      'start= ${AppIdentity.isDev ? 'demand' : 'auto'}',
      '&&',
      'reg',
      'add',
      '"$serviceRegistryPath"',
      '/v',
      'Environment',
      '/t',
      'REG_MULTI_SZ',
      '/d',
      '"HELPER_AUTH_KEY=$authKey\\0HELPER_SERVICE_NAME=$appHelperService\\0HELPER_PIPE_NAME=$helperPipeName"',
      '/f',
      '&&',
      'sc',
      'start',
      appHelperService,
    ].join(' ');

    return runas('cmd.exe', command);
  }

  Future<bool> _waitForHelperHealthy() async {
    for (var attempt = 0; attempt < 20; attempt++) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (await isHelperHealthy()) return true;

      if (attempt > 0 && attempt % 4 == 0) {
        final check = await Process.run('sc', ['query', appHelperService]);
        final output = check.stdout.toString();
        if (output.contains('STOPPED')) {
          commonPrint.warn('Helper service stopped/failed, skipping wait');
          break;
        }
      }
    }

    return false;
  }

  Future<void> stopHelperService() async {
    await helperClient.stopCore();
    if (!AppIdentity.isDev) return;

    if (await helperClient.stopHelperService()) {
      return;
    }

    await Process.run('sc', ['stop', appHelperService]);
  }

  Future<bool> registerTask(String appName) async {
    final executablePath = Platform.resolvedExecutable;
    final workingDirectory = dirname(executablePath);

    final taskXml =
        '''
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.3" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>开机自动启动代理服务</Description>
    <URI>\\$appName</URI>
  </RegistrationInfo>
  <Principals>
    <Principal id="Author">
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
    </LogonTrigger>
  </Triggers>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>false</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>6</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>"$executablePath"</Command>
      <WorkingDirectory>$workingDirectory</WorkingDirectory>
    </Exec>
  </Actions>
</Task>''';
    final taskPath = join(await appPath.tempPath, 'task.xml');
    await File(taskPath).create(recursive: true);
    await File(
      taskPath,
    ).writeAsBytes(taskXml.encodeUtf16LeWithBom, flush: true);
    final commandLine = [
      '/Create',
      '/TN',
      appName,
      '/XML',
      '%s',
      '/F',
    ].join(' ');
    return runas('schtasks', commandLine.replaceFirst('%s', taskPath));
  }

  Future<bool> unregisterTask(String appName) async {
    final commandLine = ['/Delete', '/TN', appName, '/F'].join(' ');
    return runas('schtasks', commandLine);
  }
}

final windows = system.isWindows ? Windows() : null;

class MacOS {
  static MacOS? _instance;
  static const _dnsBackupFileName = 'macos_system_dns_backup.json';
  final Lock _dnsLock = Lock();

  MacOS._internal();

  factory MacOS() {
    _instance ??= MacOS._internal();
    return _instance!;
  }

  Future<String?> get defaultServiceName async {
    final result = await Process.run('route', ['-n', 'get', 'default']);
    final output = result.stdout.toString();
    final deviceLine = output
        .split('\n')
        .firstWhere((s) => s.contains('interface:'), orElse: () => '');
    final parts = deviceLine.trim().split(' ');
    if (parts.length != 2) return null;

    final device = parts[1];
    final serviceResult = await Process.run('networksetup', [
      '-listnetworkserviceorder',
    ]);
    final serviceOutput = serviceResult.stdout.toString();
    final currentService = serviceOutput
        .split('\n\n')
        .firstWhere((s) => s.contains('Device: $device'), orElse: () => '');
    if (currentService.isEmpty) return null;

    final serviceNameLine = currentService
        .split('\n')
        .firstWhere(
          (line) => RegExp(r'^\(\d+\).*').hasMatch(line),
          orElse: () => '',
        );
    final match = RegExp(
      r'^\(\d+\)\s+(.+)$',
    ).firstMatch(serviceNameLine.trim());
    return match?.group(1)?.trim();
  }

  Future<List<String>?> get systemDns async {
    final deviceServiceName = await defaultServiceName;
    if (deviceServiceName == null) return null;
    return _getSystemDns(deviceServiceName);
  }

  Future<List<String>?> _getSystemDns(String serviceName) async {
    final result = await Process.run('networksetup', [
      '-getdnsservers',
      serviceName,
    ]);
    if (result.exitCode != 0) {
      commonPrint.warn(
        'Failed to get macOS system DNS: ${result.stderr.toString().trim()}',
      );
      return null;
    }
    final output = result.stdout.toString().trim();
    return output.startsWith("There aren't any DNS Servers set on")
        ? []
        : output.split('\n');
  }

  Future<void> restoreDns() {
    return _dnsLock.synchronized(_restoreDns);
  }

  Future<bool> _restoreDns() async {
    final backupFile = await _dnsBackupFile;
    if (!await backupFile.exists()) return true;

    try {
      final rawBackup = await backupFile.readAsString();
      final decodedBackup = jsonDecode(rawBackup);
      if (decodedBackup is! Map) {
        throw const FormatException('Invalid macOS system DNS backup');
      }
      final backup = Map<String, dynamic>.from(decodedBackup);
      final serviceName = backup['serviceName'] as String?;
      final servers = (backup['servers'] as List?)
          ?.whereType<String>()
          .toList();
      if (serviceName == null || serviceName.isEmpty || servers == null) {
        throw const FormatException('Invalid macOS system DNS backup');
      }

      final result = await Process.run('networksetup', [
        '-setdnsservers',
        serviceName,
        if (servers.isNotEmpty) ...servers,
        if (servers.isEmpty) 'Empty',
      ]);
      if (result.exitCode != 0) {
        commonPrint.warn(
          'Failed to restore macOS system DNS: '
          '${result.stderr.toString().trim()}',
        );
        return false;
      }
      await backupFile.delete();
      return true;
    } catch (e) {
      commonPrint.warn('Failed to read macOS system DNS backup: $e');
      return false;
    }
  }

  Future<File> get _dnsBackupFile async {
    return File(join(await appPath.homeDirPath, _dnsBackupFileName));
  }
}

final macOS = system.isMacOS ? MacOS() : null;

class Linux {
  static Linux? _instance;
  static const _dnsBackupFileName = 'linux_system_dns_backup.json';
  static const _hijackDns = '223.5.5.5';
  final Lock _dnsLock = Lock();

  Linux._internal();

  factory Linux() => _instance ??= Linux._internal();

  Future<void> updateDns(bool restore) {
    return _dnsLock.synchronized(() async {
      await _restoreDns();
      if (!restore) await _setDns();
    });
  }

  Future<ProcessResult?> _run(String executable, List<String> arguments) async {
    try {
      return await Process.run(executable, arguments);
    } on ProcessException catch (e) {
      commonPrint.warn('Failed to run $executable: ${e.message}');
      return null;
    }
  }

  Future<String?> get _defaultDevice async {
    final result = await _run('ip', ['route', 'show', 'default']);
    if (result == null || result.exitCode != 0) return null;
    return RegExp(
      r'\bdev\s+(\S+)',
    ).firstMatch(result.stdout.toString())?.group(1);
  }

  Future<bool> get _usesResolvedStub async {
    try {
      final content = await File('/etc/resolv.conf').readAsString();
      return RegExp(
        r'^\s*nameserver\s+127\.0\.0\.53\b',
        multiLine: true,
      ).hasMatch(content);
    } catch (e) {
      commonPrint.warn('Failed to read /etc/resolv.conf: $e');
      return false;
    }
  }

  Future<void> _setDns() async {
    if (await _usesResolvedStub) return;
    final device = await _defaultDevice;
    if (device == null) return;
    try {
      final backupFile = await _dnsBackupFile;
      await backupFile.parent.create(recursive: true);
      final temporaryFile = File('${backupFile.path}.tmp');
      await temporaryFile.writeAsString(
        jsonEncode({'device': device}),
        flush: true,
      );
      await temporaryFile.rename(backupFile.path);
    } catch (e) {
      commonPrint.warn('Failed to persist the Linux system DNS device: $e');
      return;
    }
    final result = await _run('nmcli', [
      'device',
      'modify',
      device,
      'ipv4.dns',
      _hijackDns,
    ]);
    if (result == null || result.exitCode != 0) {
      commonPrint.warn(
        'Failed to set Linux system DNS: ${result?.stderr.toString().trim()}',
      );
      await _deleteBackup();
    }
  }

  Future<void> _restoreDns() async {
    final backupFile = await _dnsBackupFile;
    if (!await backupFile.exists()) return;
    try {
      final backup = jsonDecode(await backupFile.readAsString());
      final device = backup is Map ? backup['device'] : null;
      if (device is String && device.isNotEmpty) {
        final result = await _run('nmcli', ['device', 'reapply', device]);
        if (result != null && result.exitCode != 0) {
          commonPrint.warn(
            'Failed to restore Linux system DNS: '
            '${result.stderr.toString().trim()}',
          );
        }
      }
    } catch (e) {
      commonPrint.warn('Failed to read Linux system DNS backup: $e');
    }
    await _deleteBackup();
  }

  Future<void> _deleteBackup() async {
    final backupFile = await _dnsBackupFile;
    if (await backupFile.exists()) await backupFile.delete();
  }

  Future<File> get _dnsBackupFile async {
    return File(join(await appPath.homeDirPath, _dnsBackupFileName));
  }
}

final linux = system.isLinux ? Linux() : null;
