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
import 'package:flutter/services.dart';
import 'package:path/path.dart';
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

  bool get isOhos => Platform.operatingSystem == 'ohos';

  bool get isMobile => isAndroid || isOhos;

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

  static String _shellEscape(String value) {
    return "'${value.replaceAll("'", "'\\''")}'";
  }

  Future<bool> checkIsAdmin() async {
    final corePath = appPath.corePath;
    if (system.isWindows) {
      final result = await windows?.checkService();
      return result == WindowsHelperServiceStatus.running;
    }

    if (system.isMacOS) {
      final result = await Process.run('stat', ['-f', '%Su:%Sg %Sp', corePath]);
      final output = result.stdout.trim();
      final parts = output.split(' ');
      if (parts.length < 2) return false;
      return parts.first.startsWith('root:admin') && parts.last.contains('s');
    }

    if (Platform.isLinux) {
      final result = await Process.run('stat', ['-c', '%U:%G %A', corePath]);
      final output = result.stdout.trim();
      final parts = output.split(' ');
      if (parts.length < 2) return false;
      return parts.first.startsWith('root:') && parts.last.contains('s');
    }

    return true;
  }

  Future<AuthorizeCode> authorizeCore() async {
    if (system.isAndroid) return AuthorizeCode.none;

    if (await checkIsAdmin()) return AuthorizeCode.none;

    if (system.isWindows) {
      if (await windows?._isHelperHealthy() ?? false) return AuthorizeCode.none;
      final result = await windows?.registerService();
      return result == true ? AuthorizeCode.success : AuthorizeCode.error;
    }

    if (system.isMacOS) {
      final corePath = appPath.corePath;
      var quarantineCleared = true;

      final xattrCheck = await Process.run('/usr/bin/xattr', [
        '-p',
        'com.apple.quarantine',
        corePath,
      ]);
      if (xattrCheck.exitCode == 0) {
        final removeResult = await Process.run('/usr/bin/xattr', [
          '-d',
          'com.apple.quarantine',
          corePath,
        ]);
        if (removeResult.exitCode == 0) {
          commonPrint.log('Cleared quarantine attribute from BettboxCore');
        } else {
          quarantineCleared = false;
          commonPrint.log(
            'Failed to clear quarantine attribute: ${removeResult.stderr}',
          );
        }
      }

      final escapedPath = _shellEscape(corePath);
      final shell = 'chown root:admin $escapedPath && chmod u+s $escapedPath';
      final result = await Process.run('osascript', [
        '-e',
        'do shell script "$shell" with administrator privileges',
      ]);

      if (result.exitCode != 0) {
        if (!quarantineCleared) {
          globalState.showNotifier(
            'Failed to authorize BettboxCore. Try: xattr -dr com.apple.quarantine /Applications/Bettbox.app',
          );
        } else {
          globalState.showNotifier(appLocalizations.tunEnableRequireAdmin);
        }
        return AuthorizeCode.error;
      }
      return AuthorizeCode.success;
    }

    if (Platform.isLinux) {
      final escapedCorePath = _shellEscape(appPath.corePath);

      try {
        final pkexecResult = await Process.run('pkexec', [
          'sh',
          '-c',
          'chown root:root $escapedCorePath && chmod u+s $escapedCorePath && sync',
        ]);
        if (pkexecResult.exitCode == 0) {
          return AuthorizeCode.success;
        }
        if (pkexecResult.exitCode != 127) {
          globalState.showNotifier(appLocalizations.tunEnableRequireAdmin);
          return AuthorizeCode.error;
        }
      } catch (e) {
        commonPrint.log('pkexec failed: $e');
      }

      window?.show();
      final shell = Platform.environment['SHELL'] ?? 'bash';
      final password = await globalState.showCommonDialog<String>(
        child: InputDialog(
          obscureText: true,
          title: appLocalizations.pleaseInputAdminPassword,
          value: '',
        ),
      );
      if (password == null || password.isEmpty) {
        globalState.showNotifier(appLocalizations.tunEnableRequireAdmin);
        return AuthorizeCode.error;
      }
      final escapedPassword = _shellEscape(password);
      final result = await Process.run(shell, [
        '-c',
        'echo $escapedPassword | sudo -S chown root:root $escapedCorePath && echo $escapedPassword | sudo -S chmod u+s $escapedCorePath && sync',
      ]);
      if (result.exitCode != 0) {
        globalState.showNotifier(appLocalizations.tunEnableRequireAdmin);
      }
      return result.exitCode == 0 ? AuthorizeCode.success : AuthorizeCode.error;
    }

    return AuthorizeCode.error;
  }

  Future<void> back() async {
    if (system.isAndroid) await app.moveTaskToBack();
    await window?.hide();
  }

  Future<void> exit() async {
    if (system.isAndroid) await SystemNavigator.pop();
    await window?.close();
  }

  Future<void> setProcessPriority(String processName, bool enable) async {
    if (!isWindows) return;

    if (processName == '${AppIdentity.mainExecutableName}.exe') {
      try {
        windows?.setCurrentProcessPriority(enable);
        return;
      } catch (e) {
        commonPrint.log('Failed to set current process priority: $e');
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
          commonPrint.log('Set current process memory priority failed');
        } else {
          commonPrint.log('Set current process memory priority to normal');
        }
      } finally {
        calloc.free(memoryPriorityInfo);
      }
    }
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
    if (await _isHelperHealthy()) return true;

    if (!await _configureHelperService()) return false;

    return _waitForHelperHealthy();
  }

  Future<bool> _isHelperHealthy() async {
    final result = await Process.run('sc', ['query', appHelperService]);
    if (result.exitCode != 0) return false;

    if (!result.stdout.toString().contains('RUNNING')) return false;

    return _pingHelper();
  }

  Future<bool> _pingHelper() async {
    final coreSHA256 = globalState.coreSHA256;
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
      'sc',
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
      if (await _isHelperHealthy()) return true;

      if (attempt > 0 && attempt % 4 == 0) {
        final check = await Process.run('sc', ['query', appHelperService]);
        final output = check.stdout.toString();
        if (output.contains('STOPPED')) {
          commonPrint.log('Helper service stopped/failed, skipping wait');
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
  static const _hijackDns = '223.5.5.5';
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
      commonPrint.log(
        'Failed to get macOS system DNS: ${result.stderr.toString().trim()}',
      );
      return null;
    }
    final output = result.stdout.toString().trim();
    return output.startsWith("There aren't any DNS Servers set on")
        ? []
        : output.split('\n');
  }

  Future<void> updateDns(bool restore) {
    return _dnsLock.synchronized(() async {
      if (restore) {
        await _restoreDns();
      } else {
        await _setDns();
      }
    });
  }

  Future<void> _setDns() async {
    // Restore a previous managed value first so repeated enable operations never
    // overwrite the real system DNS backup with Bettbox's own hijack DNS.
    if (!await _restoreDns()) return;

    final serviceName = await defaultServiceName;
    if (serviceName == null) return;

    final currentDns = await _getSystemDns(serviceName);
    if (currentDns == null || currentDns.contains(_hijackDns)) return;

    final backup = jsonEncode({
      'serviceName': serviceName,
      'servers': currentDns,
    });
    try {
      final backupFile = await _dnsBackupFile;
      await backupFile.parent.create(recursive: true);
      final temporaryFile = File('${backupFile.path}.tmp');
      await temporaryFile.writeAsString(backup, flush: true);
      await temporaryFile.rename(backupFile.path);
    } catch (e) {
      commonPrint.log('Failed to persist the original macOS system DNS: $e');
      return;
    }

    final result = await Process.run('networksetup', [
      '-setdnsservers',
      serviceName,
      ...currentDns,
      _hijackDns,
    ]);
    if (result.exitCode != 0) {
      commonPrint.log(
        'Failed to set macOS system DNS: ${result.stderr.toString().trim()}',
      );
    }
  }

  Future<bool> _restoreDns() async {
    final backupFile = await _dnsBackupFile;
    if (!await backupFile.exists()) return true;

    try {
      final rawBackup = await backupFile.readAsString();
      final backup = jsonDecode(rawBackup) as Map<String, dynamic>;
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
        commonPrint.log(
          'Failed to restore macOS system DNS: '
          '${result.stderr.toString().trim()}',
        );
        return false;
      }
      await backupFile.delete();
      return true;
    } catch (e) {
      commonPrint.log('Failed to read macOS system DNS backup: $e');
      return false;
    }
  }

  Future<File> get _dnsBackupFile async {
    return File(join(await appPath.homeDirPath, _dnsBackupFileName));
  }
}

final macOS = system.isMacOS ? MacOS() : null;
