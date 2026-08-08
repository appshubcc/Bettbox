import 'package:bett_box/models/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps the detected IP when trace location is absent', () {
    final info = IpInfo.fromCloudflareTrace('ip=203.0.113.10\n');

    expect(info.ip, '203.0.113.10');
    expect(info.countryCode, isEmpty);
  });
}
