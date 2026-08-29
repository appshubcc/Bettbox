// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:flutter/foundation.dart';

import 'src/model/android_device_info.dart';
import 'src/model/ios_device_info.dart';
import 'src/model/linux_device_info.dart';
import 'src/model/macos_device_info.dart';
import 'src/model/ohos_device_info.dart';
import 'src/model/web_browser_info.dart';
import 'src/model/windows_device_info.dart';

export 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart'
    show BaseDeviceInfo;

export 'src/model/android_device_info.dart';
export 'src/model/ios_device_info.dart';
export 'src/model/linux_device_info.dart';
export 'src/model/macos_device_info.dart';
export 'src/model/ohos_device_info.dart';
export 'src/model/web_browser_info.dart';
export 'src/model/windows_device_info.dart';

export 'src/device_info_plus_linux.dart'
    if (dart.library.html) 'src/device_info_plus_web.dart';
export 'src/device_info_plus_windows.dart'
    if (dart.library.html) 'src/device_info_plus_web.dart';

/// Provides device and operating system information.
class DeviceInfoPlugin {
  /// No work is done when instantiating the plugin. It's safe to call this
  /// repeatedly or in performance-sensitive blocks.
  DeviceInfoPlugin();

  // This is to manually endorse the Linux plugin until automatic registration
  // of dart plugins is implemented.
  // See https://github.com/flutter/flutter/issues/52267 for more details.
  static DeviceInfoPlatform get _platform {
    return DeviceInfoPlatform.instance;
  }

  /// This information does not change from call to call. Cache it.
  AndroidDeviceInfo? _cachedAndroidDeviceInfo;

  /// Information derived from `android.os.Build`.
  ///
  /// See: https://developer.android.com/reference/android/os/Build.html
  Future<AndroidDeviceInfo> get androidInfo async =>
      _cachedAndroidDeviceInfo ??=
          AndroidDeviceInfo.fromMap((await _platform.deviceInfo()).data);

  /// This information does not change from call to call. Cache it.
  IosDeviceInfo? _cachedIosDeviceInfo;

  /// Information derived from `UIDevice`.
  ///
  /// See: https://developer.apple.com/documentation/uikit/uidevice
  Future<IosDeviceInfo> get iosInfo async => _cachedIosDeviceInfo ??=
      IosDeviceInfo.fromMap((await _platform.deviceInfo()).data);

  /// This information does not change from call to call. Cache it.
  LinuxDeviceInfo? _cachedLinuxDeviceInfo;

  /// Information derived from `/etc/os-release`.
  ///
  /// See: https://www.freedesktop.org/software/systemd/man/os-release.html
  Future<LinuxDeviceInfo> get linuxInfo async => _cachedLinuxDeviceInfo ??=
      await _platform.deviceInfo() as LinuxDeviceInfo;

  /// This information does not change from call to call. Cache it.
  WebBrowserInfo? _cachedWebBrowserInfo;

  /// Information derived from `Navigator`.
  Future<WebBrowserInfo> get webBrowserInfo async =>
      _cachedWebBrowserInfo ??= await _platform.deviceInfo() as WebBrowserInfo;

  /// This information does not change from call to call. Cache it.
  MacOsDeviceInfo? _cachedMacosDeviceInfo;

  /// Returns device information for macos. Information sourced from Sysctl.
  Future<MacOsDeviceInfo> get macOsInfo async => _cachedMacosDeviceInfo ??=
      MacOsDeviceInfo.fromMap((await _platform.deviceInfo()).data);

  /// This information does not change from call to call. Cache it.
  OhosDeviceInfo? _cachedOhosDeviceInfo;

  /// Returns device information for ohos. Information sourced from Sysctl.
  Future<OhosDeviceInfo> get ohosInfo async => _cachedOhosDeviceInfo ??=
      OhosDeviceInfo.fromMap((await _platform.deviceInfo()).data);

  WindowsDeviceInfo? _cachedWindowsDeviceInfo;

  /// Returns device information for Windows.
  Future<WindowsDeviceInfo> get windowsInfo async =>
      _cachedWindowsDeviceInfo ??=
          await _platform.deviceInfo() as WindowsDeviceInfo;

  /// Returns device information for the current platform.
  Future<BaseDeviceInfo> get deviceInfo async {
    if (kIsWeb) {
      return webBrowserInfo;
    } else {
      if (Platform.isAndroid) {
        return androidInfo;
      } else if (Platform.isIOS) {
        return iosInfo;
      } else if (Platform.isLinux) {
        return linuxInfo;
      } else if (Platform.isMacOS) {
        return macOsInfo;
      } else if (Platform.operatingSystem == "ohos") {
        return ohosInfo;
      } else if (Platform.isWindows) {
        return windowsInfo;
      }
    }
    // allow for extension of the plugin
    return _platform.deviceInfo();
  }
}
