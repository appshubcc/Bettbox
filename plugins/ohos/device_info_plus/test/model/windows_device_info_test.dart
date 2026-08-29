// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$WindowsDeviceInfo', () {
    test('toMap should return map with correct key and map', () {
      final windowsDeviceInfo = WindowsDeviceInfo(
        computerName: 'computerName',
        numberOfCores: 4,
        systemMemoryInMegabytes: 16,
        userName: 'userName',
        majorVersion: 10,
        minorVersion: 0,
        buildNumber: 10240,
        platformId: 1,
        csdVersion: 'csdVersion',
        servicePackMajor: 1,
        servicePackMinor: 0,
        suitMask: 1,
        productType: 1,
        reserved: 1,
        buildLab: '22000.co_release.210604-1628',
        buildLabEx: '22000.1.amd64fre.co_release.210604-1628',
        digitalProductId: Uint8List.fromList([]),
        displayVersion: '21H2',
        editionId: 'Pro',
        installDate: DateTime(2022, 04, 02),
        productId: '00000-00000-0000-AAAAA',
        productName: 'Windows 10 Pro',
        registeredOwner: 'registeredOwner',
        releaseId: 'releaseId',
        deviceId: 'deviceId',
      );

      expect(windowsDeviceInfo.data, {
        'computerName': 'computerName',
        'numberOfCores': 4,
        'systemMemoryInMegabytes': 16,
        'userName': 'userName',
        'majorVersion': 10,
        'minorVersion': 0,
        'buildNumber': 10240,
        'platformId': 1,
        'csdVersion': 'csdVersion',
        'servicePackMajor': 1,
        'servicePackMinor': 0,
        'suitMask': 1,
        'productType': 1,
        'reserved': 1,
        'buildLab': '22000.co_release.210604-1628',
        'buildLabEx': '22000.1.amd64fre.co_release.210604-1628',
        'digitalProductId': Uint8List.fromList([]),
        'displayVersion': '21H2',
        'editionId': 'Pro',
        'installDate': DateTime(2022, 04, 02),
        'productId': '00000-00000-0000-AAAAA',
        'productName': 'Windows 10 Pro',
        'registeredOwner': 'registeredOwner',
        'releaseId': 'releaseId',
        'deviceId': 'deviceId',
      });
    });
  });
}
