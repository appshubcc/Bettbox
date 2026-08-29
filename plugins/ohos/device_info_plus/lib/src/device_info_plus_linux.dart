import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:meta/meta.dart';

/// See [DeviceInfoPlatform]
class DeviceInfoPlusLinuxPlugin extends DeviceInfoPlatform {
  /// Register this dart class as the platform implementation for linux
  static void registerWith() {
    DeviceInfoPlatform.instance = DeviceInfoPlusLinuxPlugin();
  }

  LinuxDeviceInfo? _cache;
  final FileSystem _fileSystem;

  ///
  DeviceInfoPlusLinuxPlugin({@visibleForTesting FileSystem? fileSystem})
      : _fileSystem = fileSystem ?? const LocalFileSystem();

  @override
  Future<BaseDeviceInfo> deviceInfo() async {
    return _cache ??= await _getInfo();
  }

  Future<LinuxDeviceInfo> linuxInfo() async {
    return (await deviceInfo()) as LinuxDeviceInfo;
  }

  Future<LinuxDeviceInfo> _getInfo() async {
    final os = await _getOsRelease() ?? {};
    final lsb = await _getLsbRelease() ?? {};
    final machineId = await _getMachineId();

    return LinuxDeviceInfo(
      name: os['NAME'] ?? 'Linux',
      version: os['VERSION'] ?? lsb['LSB_VERSION'],
      id: os['ID'] ?? lsb['DISTRIB_ID'] ?? 'linux',
      idLike: os['ID_LIKE']?.split(' '),
      versionCodename: os['VERSION_CODENAME'] ?? lsb['DISTRIB_CODENAME'],
      versionId: os['VERSION_ID'] ?? lsb['DISTRIB_RELEASE'],
      prettyName: os['PRETTY_NAME'] ?? lsb['DISTRIB_DESCRIPTION'] ?? 'Linux',
      buildId: os['BUILD_ID'],
      variant: os['VARIANT'],
      variantId: os['VARIANT_ID'],
      machineId: machineId,
    );
  }

  Future<Map<String, String?>?> _getOsRelease() {
    return _tryReadKeyValues('/etc/os-release').then((value) async =>
        value ?? await _tryReadKeyValues('/usr/lib/os-release'));
  }

  Future<Map<String, String?>?> _getLsbRelease() {
    return _tryReadKeyValues('/etc/lsb-release');
  }

  Future<String?> _getMachineId() {
    return _tryReadValue('/etc/machine-id');
  }

  Future<String?> _tryReadValue(String path) {
    return _fileSystem
        .file(path)
        .readAsString()
        .then((str) => str.trim(), onError: (_) => null);
  }

  Future<Map<String, String?>?> _tryReadKeyValues(String path) {
    return _fileSystem
        .file(path)
        .readAsLines()
        .then((lines) => lines.toKeyValues(), onError: (_) => null);
  }
}

extension _Unquote on String {
  String removePrefix(String prefix) {
    if (!startsWith(prefix)) return this;
    return substring(prefix.length);
  }

  String removeSuffix(String suffix) {
    if (!endsWith(suffix)) return this;
    return substring(0, length - suffix.length);
  }

  String unquote() {
    return removePrefix('"').removeSuffix('"');
  }
}

extension _KeyValues on List<String> {
  Map<String, String?> toKeyValues() {
    return Map.fromEntries(map((line) {
      final parts = line.split('=');
      if (parts.length != 2) return MapEntry(line, null);
      return MapEntry(parts.first, parts.last.unquote());
    }));
  }
}
