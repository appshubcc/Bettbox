// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:device_info_plus_platform_interface/model/base_device_info.dart';

/// Information derived from `UIDevice`.
///
/// See: https://developer.apple.com/documentation/uikit/uidevice
class IosDeviceInfo extends BaseDeviceInfo {
  /// IOS device info class.
  IosDeviceInfo._({
    required Map<String, dynamic> data,
    required this.name,
    required this.systemName,
    required this.systemVersion,
    required this.model,
    required this.localizedModel,
    this.identifierForVendor,
    required this.isPhysicalDevice,
    required this.utsname,
  }) : super(data);

  /// Device name.
  ///
  /// On iOS < 16 returns user-assigned device name
  /// On iOS >= 16 returns a generic device name if project has
  /// no entitlement to get user-assigned device name.
  /// https://developer.apple.com/documentation/uikit/uidevice/1620015-name
  final String name;

  /// The name of the current operating system.
  /// https://developer.apple.com/documentation/uikit/uidevice/1620054-systemname
  final String systemName;

  /// The current operating system version.
  /// https://developer.apple.com/documentation/uikit/uidevice/1620043-systemversion
  final String systemVersion;

  /// Device model.
  /// https://developer.apple.com/documentation/uikit/uidevice/1620044-model
  final String model;

  /// Localized name of the device model.
  /// https://developer.apple.com/documentation/uikit/uidevice/1620029-localizedmodel
  final String localizedModel;

  /// Unique UUID value identifying the current device.
  /// https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor
  final String? identifierForVendor;

  /// `false` if the application is running in a simulator, `true` otherwise.
  final bool isPhysicalDevice;

  /// Operating system information derived from `sys/utsname.h`.
  final IosUtsname utsname;

  /// Deserializes from the map message received from [_kChannel].
  static IosDeviceInfo fromMap(Map<String, dynamic> map) {
    return IosDeviceInfo._(
      data: map,
      name: map['name'],
      systemName: map['systemName'],
      systemVersion: map['systemVersion'],
      model: map['model'],
      localizedModel: map['localizedModel'],
      identifierForVendor: map['identifierForVendor'],
      isPhysicalDevice: map['isPhysicalDevice'] == 'true',
      utsname:
          IosUtsname._fromMap(map['utsname']?.cast<String, dynamic>() ?? {}),
    );
  }
}

/// Information derived from `utsname`.
/// See http://pubs.opengroup.org/onlinepubs/7908799/xsh/sysutsname.h.html for details.
class IosUtsname {
  const IosUtsname._({
    required this.sysname,
    required this.nodename,
    required this.release,
    required this.version,
    required this.machine,
  });

  /// Operating system name.
  final String sysname;

  /// Network node name.
  final String nodename;

  /// Release level.
  final String release;

  /// Version level.
  final String version;

  /// Hardware type (e.g. 'iPhone7,1' for iPhone 6 Plus).
  final String machine;

  /// Deserializes from the map message received from [_kChannel].
  static IosUtsname _fromMap(Map<String, dynamic> map) {
    return IosUtsname._(
      sysname: map['sysname'],
      nodename: map['nodename'],
      release: map['release'],
      version: map['version'],
      machine: map['machine'],
    );
  }
}
