import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses uapis myip response', () {
    final info = IpInfo.fromJson({
      'ip': '183.137.128.1',
      'beginip': '183.137.128.1',
      'endip': '183.137.128.1',
      'region': '中国 浙江 杭州',
      'isp': 'Chinanet',
      'asn': 'AS4134',
      'llc': '电信',
      'latitude': 30.18505,
      'longitude': 120.26452,
    });
    expect(info.ip, '183.137.128.1');
    expect(info.countryCode, 'CN');
    expect(info.country, '中国');
    expect(info.province, '浙江');
    expect(info.city, '杭州');
    expect(info.isp, '电信');
    expect(info.asn, 'AS4134');

    final tw = IpInfo.fromJson({
      'ip': '213.210.4.3',
      'region': '中国 台湾 台北',
      'isp': 'ByteVirt LLC',
      'asn': 'AS199707',
      'llc': 'ByteVirt',
    });
    expect(tw.countryCode, 'TW');
    expect(tw.country, '台湾 (中国)');
  });

  test('normalizes traditional chinese 中華民國 to 台灣 (中国)', () {
    final info = IpInfo(ip: '168.95.1.1', countryCode: 'TW', country: '中華民國');
    expect(info.countryCode, 'TW');
    expect(info.country, '台灣 (中国)');

    final infoNoCc = IpInfo(ip: '168.95.1.1', countryCode: '', country: '中華民國');
    expect(infoNoCc.countryCode, 'TW');
    expect(infoNoCc.country, '台灣 (中国)');

    final infoWithParentheses = IpInfo(
      ip: '168.95.1.1',
      countryCode: 'TW',
      country: '中華民國（台灣）',
    );
    expect(infoWithParentheses.country, '台灣 (中国)');

    final infoAsciiParentheses = IpInfo(
      ip: '168.95.1.1',
      countryCode: 'TW',
      country: '中華民國(台灣)',
    );
    expect(infoAsciiParentheses.country, '台灣 (中国)');
  });

  test('normalizes simplified chinese 中华民国 to 台湾 (中国)', () {
    final info = IpInfo(ip: '140.112.1.1', countryCode: 'TW', country: '中华民国');
    expect(info.countryCode, 'TW');
    expect(info.country, '台湾 (中国)');

    final infoNoCc = IpInfo(
      ip: '140.112.1.1',
      countryCode: '',
      country: '中华民国',
    );
    expect(infoNoCc.countryCode, 'TW');
    expect(infoNoCc.country, '台湾 (中国)');
  });

  test('normalizes 台湾 and 台灣 and Taiwan', () {
    final s1 = IpInfo(ip: '1.1.1.1', countryCode: 'TW', country: '台湾');
    expect(s1.country, '台湾 (中国)');

    final s2 = IpInfo(ip: '1.1.1.1', countryCode: 'TW', country: '台灣');
    expect(s2.country, '台灣 (中国)');

    final s3 = IpInfo(ip: '1.1.1.1', countryCode: 'TW', country: 'Taiwan');
    expect(s3.country, 'Taiwan (China)');

    final s4 = IpInfo(
      ip: '1.1.1.1',
      countryCode: 'TW',
      country: 'Republic of China',
    );
    expect(s4.country, 'Taiwan (China)');
  });

  test('does not duplicate suffix when already normalized', () {
    final s1 = IpInfo(ip: '1.1.1.1', countryCode: 'TW', country: '台湾 (中国)');
    expect(s1.country, '台湾 (中国)');

    final s2 = IpInfo(ip: '1.1.1.1', countryCode: 'TW', country: '台灣 (中国)');
    expect(s2.country, '台灣 (中国)');

    final s3 = IpInfo(
      ip: '1.1.1.1',
      countryCode: 'TW',
      country: 'Taiwan (China)',
    );
    expect(s3.country, 'Taiwan (China)');

    final s4 = IpInfo(ip: '1.1.1.1', countryCode: 'TW', country: '中国台湾');
    expect(s4.country, '中国台湾');
  });

  test('parses myip ipip format for taiwan correctly', () {
    final info = IpInfo.fromJson({
      'ret': 'ok',
      'data': {
        'ip': '168.95.1.1',
        'location': ['中国', '台湾', '台北市', '', 'nasstar.com'],
      },
    });
    expect(info.ip, '168.95.1.1');
    expect(info.countryCode, 'TW');
    expect(info.country, '台湾 (中国)');
    expect(info.province, '台湾');
    expect(info.city, '台北市');
  });

  test('parses uapis format with traditional 中華民國', () {
    final info = IpInfo.fromJson({
      'ip': '210.242.0.1',
      'region': '中国 中華民國 台北',
      'isp': 'FarEasTone',
      'llc': 'FarEasTone',
    });
    expect(info.ip, '210.242.0.1');
    expect(info.countryCode, 'TW');
    expect(info.country, '台灣 (中国)');
  });

  test('parses ip-api format returning 中華民國', () {
    final info = IpInfo.fromJson({
      'status': 'success',
      'query': '140.109.1.1',
      'country': '中華民國',
      'countryCode': 'TW',
      'regionName': '台北市',
      'city': '台北市',
    });
    expect(info.ip, '140.109.1.1');
    expect(info.countryCode, 'TW');
    expect(info.country, '台灣 (中国)');
  });

  test('parses ip-api format returning 中华民国 with empty countryCode', () {
    final info = IpInfo.fromJson({
      'status': 'success',
      'query': '117.56.1.1',
      'country': '中华民国',
      'countryCode': '',
      'regionName': '新北市',
      'city': '板桥',
    });
    expect(info.ip, '117.56.1.1');
    expect(info.countryCode, 'TW');
    expect(info.country, '台湾 (中国)');
  });

  test('tests multiple real taiwan IPs', () {
    final testCases = <Map<String, dynamic>>[
      {
        'ip': '168.95.1.1',
        'country': '中華民國',
        'province': '台北市',
        'city': '台北市',
        'expectedCountry': '台灣 (中国)',
      },
      {
        'ip': '140.112.1.1',
        'country': '台湾',
        'province': '台北市',
        'city': '台北市',
        'expectedCountry': '台湾 (中国)',
      },
      {
        'ip': '210.242.0.1',
        'country': '台灣',
        'province': '新北市',
        'city': '鶯歌',
        'expectedCountry': '台灣 (中国)',
      },
      {
        'ip': '117.56.1.1',
        'country': '中华民国',
        'province': '新北市',
        'city': '板桥',
        'expectedCountry': '台湾 (中国)',
      },
      {
        'ip': '192.83.166.1',
        'country': '中華民國（台灣）',
        'province': '臺灣省 or 台灣省',
        'city': '台北市',
        'expectedCountry': '台灣 (中国)',
      },
    ];

    for (final tc in testCases) {
      final info = IpInfo(
        ip: tc['ip'] as String,
        countryCode: 'TW',
        country: tc['country'] as String,
        province: tc['province'] as String,
        city: tc['city'] as String,
      );
      expect(info.countryCode, 'TW');
      expect(info.country, tc['expectedCountry']);
    }
  });
}
