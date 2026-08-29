@TestOn('browser')
library device_info_plus_web_test;

import 'package:device_info_plus/src/model/web_browser_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('WebBrowserInfo from Map with values', () {
    final info = WebBrowserInfo.fromMap(
      {
        'appCodeName': 'CODENAME',
        'appName': 'NAME',
        'appVersion': 'VERSION',
        'deviceMemory': 64,
        'language': 'en',
        'languages': ['en', 'es'],
        'platform': 'PLATFORM',
        'product': 'PRODUCT',
        'productSub': 'PRODUCTSUB',
        'userAgent':
            'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:61.0) Gecko/20100101 Firefox/61.0',
        'vendor': 'VENDOR',
        'vendorSub': 'VENDORSUB',
        'hardwareConcurrency': 1,
        'maxTouchPoints': 2,
      },
    );

    expect(info.appName, 'NAME');
    expect(info.browserName, BrowserName.firefox);
  });

  test('WebBrowserInfo from empty map', () {
    final info = WebBrowserInfo.fromMap({});

    expect(info.appName, isNull);
    expect(info.browserName, BrowserName.unknown);
  });
}
