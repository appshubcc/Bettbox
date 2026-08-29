// ignore_for_file: deprecated_member_use_from_same_package

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$MacOsDeviceInfo', () {
    group('fromMap | data', () {
      const macosDeviceInfoMap = <String, dynamic>{
        'arch': 'arch',
        'model': 'model',
        'activeCPUs': 4,
        'memorySize': 16,
        'cpuFrequency': 2,
        'hostName': 'hostName',
        'osRelease': 'osRelease',
        'majorVersion': 10,
        'minorVersion': 9,
        'patchVersion': 3,
        'computerName': 'computerName',
        'kernelVersion': 'kernelVersion',
        'systemGUID': null,
      };

      test('fromMap should return $MacOsDeviceInfo with correct values', () {
        final macosDeviceInfo = MacOsDeviceInfo.fromMap(macosDeviceInfoMap);

        expect(macosDeviceInfo.arch, 'arch');
        expect(macosDeviceInfo.model, 'model');
        expect(macosDeviceInfo.activeCPUs, 4);
        expect(macosDeviceInfo.memorySize, 16);
        expect(macosDeviceInfo.cpuFrequency, 2);
        expect(macosDeviceInfo.hostName, 'hostName');
        expect(macosDeviceInfo.osRelease, 'osRelease');
        expect(macosDeviceInfo.majorVersion, 10);
        expect(macosDeviceInfo.minorVersion, 9);
        expect(macosDeviceInfo.patchVersion, 3);
        expect(macosDeviceInfo.systemGUID, isNull);
      });

      test('toMap should return map with correct key and map', () {
        final macosDeviceInfo = MacOsDeviceInfo.fromMap(macosDeviceInfoMap);
        expect(macosDeviceInfo.data, macosDeviceInfoMap);
      });
    });
  });
}
