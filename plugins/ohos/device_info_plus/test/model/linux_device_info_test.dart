// ignore_for_file: deprecated_member_use_from_same_package

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$LinuxDeviceInfo', () {
    test('toMap should return map with correct key and map', () {
      final linuxDeviceInfo = LinuxDeviceInfo(
        name: 'name',
        version: 'version',
        id: 'id',
        idLike: ['idLike'],
        versionCodename: 'versionCodename',
        versionId: 'versionId',
        prettyName: 'prettyName',
        buildId: 'buildId',
        variant: 'variant',
        variantId: 'variantId',
        machineId: 'machineId',
      );

      expect(linuxDeviceInfo.data, {
        'name': 'name',
        'version': 'version',
        'id': 'id',
        'idLike': ['idLike'],
        'versionCodename': 'versionCodename',
        'versionId': 'versionId',
        'prettyName': 'prettyName',
        'buildId': 'buildId',
        'variant': 'variant',
        'variantId': 'variantId',
        'machineId': 'machineId',
      });
    });
  });
}
