// ignore_for_file: deprecated_member_use_from_same_package

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$WebBrowserInfo', () {
    group('fromMap | toMap', () {
      const webBrowserInfoMap = <String, dynamic>{
        'browserName': BrowserName.safari,
        'appCodeName': 'appCodeName',
        'appName': 'appName',
        'appVersion': 'appVersion',
        'deviceMemory': 42,
        'language': 'language',
        'languages': ['en', 'es'],
        'platform': 'platform',
        'product': 'product',
        'productSub': 'productSub',
        'userAgent': 'Safari',
        'vendor': 'vendor',
        'vendorSub': 'vendorSub',
        'hardwareConcurrency': 2,
        'maxTouchPoints': 42,
      };

      test('fromMap should return $WebBrowserInfo with correct values', () {
        final webBrowserInfo = WebBrowserInfo.fromMap(webBrowserInfoMap);

        expect(webBrowserInfo.browserName, BrowserName.safari);
        expect(webBrowserInfo.appCodeName, 'appCodeName');
        expect(webBrowserInfo.appName, 'appName');
        expect(webBrowserInfo.appVersion, 'appVersion');
        expect(webBrowserInfo.deviceMemory, 42);
        expect(webBrowserInfo.language, 'language');
        expect(webBrowserInfo.languages, ['en', 'es']);
        expect(webBrowserInfo.platform, 'platform');
        expect(webBrowserInfo.product, 'product');
        expect(webBrowserInfo.productSub, 'productSub');
        expect(webBrowserInfo.userAgent, 'Safari');
        expect(webBrowserInfo.vendor, 'vendor');
        expect(webBrowserInfo.vendorSub, 'vendorSub');
        expect(webBrowserInfo.hardwareConcurrency, 2);
        expect(webBrowserInfo.maxTouchPoints, 42);
      });

      test('toMap should return map with correct key and map', () {
        final webBrowserInfo = WebBrowserInfo.fromMap(webBrowserInfoMap);
        expect(webBrowserInfo.data, webBrowserInfoMap);
      });
    });
  });
}
