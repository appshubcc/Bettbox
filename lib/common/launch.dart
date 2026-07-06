import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import 'constant.dart';
import 'system.dart';

class AutoLaunch {
  static AutoLaunch? _instance;

  AutoLaunch._internal() {
    launchAtStartup.setup(
      appName: appName,
      appPath: Platform.resolvedExecutable,
    );
  }

  factory AutoLaunch() {
    _instance ??= AutoLaunch._internal();
    return _instance!;
  }

  Future<bool> get isEnable async {
    if (system.isWindows) {
      // Windows 上改为通过任务计划实现开机自启动
      try {
        final result = await Process.run('schtasks', [
          '/Query',
          '/TN',
          appName,
        ]);
        return result.exitCode == 0;
      } catch (_) {
        return false;
      }
    }
    return await launchAtStartup.isEnabled();
  }

  Future<bool> enable() async {
    if (system.isWindows) {
      // 使用任务计划实现 Windows 开机自启动（管理员模式）
      return await windows?.registerTask(appName) ?? false;
    }
    return await launchAtStartup.enable();
  }

  Future<bool> disable() async {
    if (system.isWindows) {
      return await windows?.unregisterTask(appName) ?? false;
    }
    return await launchAtStartup.disable();
  }

  Future<void> updateStatus(bool isAutoLaunch) async {
    if (kDebugMode) {
      return;
    }
    if (await isEnable == isAutoLaunch) return;

    // 异步执行，避免阻塞 UI
    if (isAutoLaunch == true) {
      unawaited(enable());
    } else {
      unawaited(disable());
    }
  }
}

final autoLaunch = system.isDesktop ? AutoLaunch() : null;
