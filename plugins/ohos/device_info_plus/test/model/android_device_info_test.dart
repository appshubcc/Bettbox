// ignore_for_file: deprecated_member_use_from_same_package

import 'package:device_info_plus/src/model/android_device_info.dart';
import 'package:flutter_test/flutter_test.dart';

part '../model/android_device_info_fake.dart';

void main() {
  group('$AndroidDeviceInfo fromMap | toMap', () {
    test('fromMap should return $AndroidDeviceInfo with correct values', () {
      final androidDeviceInfo =
          AndroidDeviceInfo.fromMap(_fakeAndroidDeviceInfo);

      expect(androidDeviceInfo.id, 'id');
      expect(androidDeviceInfo.host, 'host');
      expect(androidDeviceInfo.tags, 'tags');
      expect(androidDeviceInfo.type, 'type');
      expect(androidDeviceInfo.model, 'model');
      expect(androidDeviceInfo.board, 'board');
      expect(androidDeviceInfo.brand, 'Google');
      expect(androidDeviceInfo.device, 'device');
      expect(androidDeviceInfo.product, 'product');
      expect(androidDeviceInfo.display, 'display');
      expect(androidDeviceInfo.hardware, 'hardware');
      expect(androidDeviceInfo.bootloader, 'bootloader');
      expect(androidDeviceInfo.isPhysicalDevice, isTrue);
      expect(androidDeviceInfo.fingerprint, 'fingerprint');
      expect(androidDeviceInfo.manufacturer, 'manufacturer');
      expect(androidDeviceInfo.supportedAbis, _fakeSupportedAbis);
      expect(androidDeviceInfo.systemFeatures, _fakeSystemFeatures);
      expect(androidDeviceInfo.supported32BitAbis, _fakeSupported32BitAbis);
      expect(androidDeviceInfo.supported64BitAbis, _fakeSupported64BitAbis);
      expect(androidDeviceInfo.version.sdkInt, 16);
      expect(androidDeviceInfo.version.baseOS, 'baseOS');
      expect(androidDeviceInfo.version.previewSdkInt, 30);
      expect(androidDeviceInfo.version.release, 'release');
      expect(androidDeviceInfo.version.codename, 'codename');
      expect(androidDeviceInfo.version.incremental, 'incremental');
      expect(androidDeviceInfo.version.securityPatch, 'securityPatch');
      expect(androidDeviceInfo.displayMetrics.widthPx, 1080);
      expect(androidDeviceInfo.displayMetrics.heightPx, 2220);
      expect(androidDeviceInfo.displayMetrics.xDpi, 530.0859);
      expect(androidDeviceInfo.displayMetrics.yDpi, 529.4639);
      expect(androidDeviceInfo.serialNumber, 'SERIAL');
    });

    test('toMap should return map with correct key and map', () {
      final androidDeviceInfo =
          AndroidDeviceInfo.fromMap(_fakeAndroidDeviceInfo);

      expect(androidDeviceInfo.data, _fakeAndroidDeviceInfo);
    });
  });
}
