// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:device_info_plus_platform_interface/model/base_device_info.dart';

/// Object encapsulating WINDOWS device information.
class WindowsDeviceInfo implements BaseDeviceInfo {
  /// Constructs a [WindowsDeviceInfo].
  const WindowsDeviceInfo({
    required this.computerName,
    required this.numberOfCores,
    required this.systemMemoryInMegabytes,
    required this.userName,
    required this.majorVersion,
    required this.minorVersion,
    required this.buildNumber,
    required this.platformId,
    required this.csdVersion,
    required this.servicePackMajor,
    required this.servicePackMinor,
    required this.suitMask,
    required this.productType,
    required this.reserved,
    required this.buildLab,
    required this.buildLabEx,
    required this.digitalProductId,
    required this.displayVersion,
    required this.editionId,
    required this.installDate,
    required this.productId,
    required this.productName,
    required this.registeredOwner,
    required this.releaseId,
    required this.deviceId,
  });

  /// The computer's fully-qualified DNS name, where available.
  final String computerName;

  /// Number of CPU cores on the local machine
  final int numberOfCores;

  /// The physically installed memory in the computer.
  /// This may not be the same as available memory.
  final int systemMemoryInMegabytes;

  final String userName;

  /// The major version number of the operating system.
  /// For example, for Windows 2000, the major version number is five.
  /// For more information, see the table in Remarks.
  /// https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/ns-wdm-_osversioninfoexw#remarks
  final int majorVersion;

  /// The minor version number of the operating system.
  /// For example, for Windows 2000, the minor version number is zero.
  /// For more information, see the table in Remarks.
  /// https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/ns-wdm-_osversioninfoexw#remarks
  final int minorVersion;

  /// The build number of the operating system.
  /// For example:
  /// - `22000` or greater for Windows 11.
  /// - `10240` or greator for Windows 10.
  final int buildNumber;

  /// The operating system platform. For Win32 on NT-based operating systems,
  /// RtlGetVersion returns the value `VER_PLATFORM_WIN32_NT`.
  final int platformId;

  /// The service-pack version string.
  ///
  /// This member contains a string, such as "Service Pack 3", which indicates
  /// the latest service pack installed on the system.
  final String csdVersion;

  /// The major version number of the latest service pack installed on the system.
  /// For example, for Service Pack 3, the major version number is three. If no
  /// service pack has been installed, the value is zero.
  final int servicePackMajor;

  /// The minor version number of the latest service pack installed on the
  /// system. For example, for Service Pack 3, the minor version number is zero.
  final int servicePackMinor;

  /// The product suites available on the system.
  final int suitMask;

  /// The product type. This member contains additional information about the
  /// system.
  final int productType;

  /// Reserved for future use.
  final int reserved;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\BuildLab` registry key. For example:
  /// `22000.co_release.210604-1628`.
  final String buildLab;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\BuildLabEx` registry key. For example:
  /// `22000.1.amd64fre.co_release.210604-1628`.
  final String buildLabEx;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\DigitalProductId` registry key.
  final Uint8List digitalProductId;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\DisplayVersion` registry key. For example: `21H2`.
  final String displayVersion;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\EditionID` registry key.
  final String editionId;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\InstallDate` registry key.
  final DateTime installDate;

  /// Displayed as "Product ID" in Windows Settings. Value of the
  /// `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\ProductId` registry key. For example:
  /// `00000-00000-0000-AAAAA`.
  final String productId;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\ProductName` registry key. For example: `Windows 10 Home
  /// Single Language`.
  final String productName;

  /// Value of the `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\RegisteredOwner` registry key. For example: `Microsoft
  /// Corporation`.
  final String registeredOwner;

  /// Value of the `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\ReleaseId` registry key. For example: `1903`.
  final String releaseId;

  /// Displayed as "Device ID" in Windows Settings. Value of
  /// `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SQMClient\MachineId` registry key.
  final String deviceId;

  @Deprecated('use [data] instead')
  @override
  Map<String, dynamic> toMap() {
    return {
      'computerName': computerName,
      'numberOfCores': numberOfCores,
      'systemMemoryInMegabytes': systemMemoryInMegabytes,
      'userName': userName,
      'majorVersion': majorVersion,
      'minorVersion': minorVersion,
      'buildNumber': buildNumber,
      'platformId': platformId,
      'csdVersion': csdVersion,
      'servicePackMajor': servicePackMajor,
      'servicePackMinor': servicePackMinor,
      'suitMask': suitMask,
      'productType': productType,
      'reserved': reserved,
      'buildLab': buildLab,
      'buildLabEx': buildLabEx,
      'digitalProductId': digitalProductId,
      'displayVersion': displayVersion,
      'editionId': editionId,
      'installDate': installDate,
      'productId': productId,
      'productName': productName,
      'registeredOwner': registeredOwner,
      'releaseId': releaseId,
      'deviceId': deviceId,
    };
  }

  @override
  // ignore: deprecated_member_use_from_same_package
  Map<String, dynamic> get data => toMap();
}
