@TestOn('linux')
library package_info_plus_linux_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart';

void main() {
  test('registered instance', () {
    PackageInfoPlusLinuxPlugin.registerWith();
    expect(PackageInfoPlatform.instance, isA<PackageInfoPlusLinuxPlugin>());
  });
}
