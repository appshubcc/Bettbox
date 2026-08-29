/// The Windows implementation of `package_info_plus`.
library package_info_plus_windows;

import 'dart:io';

import 'package:package_info_plus_platform_interface/package_info_data.dart';
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart';

import 'file_version_info.dart';

/// The Windows implementation of [PackageInfoPlatform].
class PackageInfoPlusWindowsPlugin extends PackageInfoPlatform {
  /// Register this dart class as the platform implementation for Windows
  static void registerWith() {
    PackageInfoPlatform.instance = PackageInfoPlusWindowsPlugin();
  }

  /// Returns a map with the following keys:
  /// appName, packageName, version, buildNumber
  @override
  Future<PackageInfoData> getAll() {
    String resolvedExecutable = Platform.resolvedExecutable;

    /// Workaround for https://github.com/dart-lang/sdk/issues/52309
    if (resolvedExecutable.startsWith(r"UNC\")) {
      resolvedExecutable = resolvedExecutable.replaceFirst(r"UNC\", r"\\");
    }

    final info = FileVersionInfo(resolvedExecutable);
    final versions = info.productVersion.split('+');
    final data = PackageInfoData(
      appName: info.productName,
      packageName: info.internalName,
      version: versions.getOrNull(0) ?? '',
      buildNumber: versions.getOrNull(1) ?? '',
      buildSignature: '',
    );
    info.dispose();
    return Future.value(data);
  }
}

extension _GetOrNull<T> on List<T> {
  T? getOrNull(int index) => _checkIndex(index) ? this[index] : null;

  bool _checkIndex(int index) => index >= 0 && index < length;
}
