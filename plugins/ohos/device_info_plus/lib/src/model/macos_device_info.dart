// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:device_info_plus_platform_interface/model/base_device_info.dart';

/// Object encapsulating MACOS device information.
class MacOsDeviceInfo extends BaseDeviceInfo {
  /// Constructs a MacOsDeviceInfo.
  MacOsDeviceInfo._({
    required Map<String, dynamic> data,
    required this.computerName,
    required this.hostName,
    required this.arch,
    required this.model,
    required this.kernelVersion,
    required this.osRelease,
    required this.majorVersion,
    required this.minorVersion,
    required this.patchVersion,
    required this.activeCPUs,
    required this.memorySize,
    required this.cpuFrequency,
    required this.systemGUID,
  }) : super(data);

  /// Name given to the local machine.
  final String computerName;

  /// Operating system type
  final String hostName;

  /// Machine cpu architecture
  /// Note, that on Apple Silicon Macs can return `x86_64` if app runs via Rosetta
  final String arch;

  /// Device model
  final String model;

  /// Machine Kernel version.
  /// Examples:
  /// `Darwin Kernel Version 15.3.0: Thu Dec 10 18:40:58 PST 2015; root:xnu-3248.30.4~1/RELEASE_X86_64`
  /// or
  /// `Darwin Kernel Version 15.0.0: Wed Dec 9 22:19:38 PST 2015; root:xnu-3248.31.3~2/RELEASE_ARM64_S8000`
  final String kernelVersion;

  /// Operating system release number
  final String osRelease;

  /// The major release number, such as 10 in version 10.9.3.
  final int majorVersion;

  /// The minor release number, such as 9 in version 10.9.3.
  final int minorVersion;

  /// The update release number, such as 3 in version 10.9.3.
  final int patchVersion;

  /// Number of active CPUs
  final int activeCPUs;

  /// Machine's memory size
  final int memorySize;

  /// Device CPU Frequency
  final int cpuFrequency;

  /// Device GUID
  final String? systemGUID;

  /// Constructs a [MacOsDeviceInfo] from a Map of dynamic.
  static MacOsDeviceInfo fromMap(Map<String, dynamic> map) {
    return MacOsDeviceInfo._(
      data: map,
      computerName: map['computerName'],
      hostName: map['hostName'],
      arch: map['arch'],
      model: map['model'],
      kernelVersion: map['kernelVersion'],
      osRelease: map['osRelease'],
      majorVersion: map['majorVersion'],
      minorVersion: map['minorVersion'],
      patchVersion: map['patchVersion'],
      activeCPUs: map['activeCPUs'],
      memorySize: map['memorySize'],
      cpuFrequency: map['cpuFrequency'],
      systemGUID: map['systemGUID'],
    );
  }
}
