@TestOn('windows')
library package_info_plus_windows_test;

import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/src/file_version_info.dart';
import 'package:package_info_plus/src/package_info_plus_windows.dart';
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart';

void main() {
  test('registered instance', () {
    PackageInfoPlusWindowsPlugin.registerWith();
    expect(PackageInfoPlatform.instance, isA<PackageInfoPlusWindowsPlugin>());
  });

  test('File version info for standard Windows DLL', () {
    final windir = Platform.environment['WINDIR']!; // normally C:\Windows

    // Every valid Windows release should have this file
    final kernelVersion = FileVersionInfo('$windir\\System32\\kernel32.dll');

    // For example, "Microsoft® Windows® Operating System"
    expect(kernelVersion.productName, contains('Windows'));

    // For example, "10.0.19041.2788"
    expect(kernelVersion.productVersion, isNotNull);

    // For example, "Windows NT BASE API Client DLL" (in Windows 10)
    expect(kernelVersion.fileDescription, contains('Windows'));
    kernelVersion.dispose();
  });

  test('File version info for missing file', () {
    const missingFile = 'C:\\macos\\system128\\colonel.dll';

    expect(
        () => FileVersionInfo(missingFile),
        throwsA(isArgumentError.having(
          (e) => e.message,
          'message',
          startsWith('File not present'),
        )));
  });
}
