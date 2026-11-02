import 'package:bett_box/common/network_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseIPv4', () {
    test('accepts plain addresses and surrounding spaces', () {
      expect(NetworkMatcher.parseIPv4('192.168.1.1'), isNotNull);
      expect(NetworkMatcher.parseIPv4(' 10.0.0.1 '), isNotNull);
      expect(NetworkMatcher.parseIPv4('192.168.001.1'), isNotNull);
    });

    test('rejects signs, hex and out of range octets', () {
      expect(NetworkMatcher.parseIPv4('0x10.0.0.1'), isNull);
      expect(NetworkMatcher.parseIPv4('+1.2.3.4'), isNull);
      expect(NetworkMatcher.parseIPv4('-0.2.3.4'), isNull);
      expect(NetworkMatcher.parseIPv4('256.0.0.1'), isNull);
      expect(NetworkMatcher.parseIPv4('1.2.3'), isNull);
      expect(NetworkMatcher.parseIPv4('1.2.3.4.5'), isNull);
      expect(NetworkMatcher.parseIPv4('1..3.4'), isNull);
    });
  });

  group('parseCIDR', () {
    test('normalizes host bits', () {
      final parsed = NetworkMatcher.parseCIDR('192.168.1.5/24');
      expect(parsed, isNotNull);
      expect(NetworkMatcher.formatIPv4(parsed!.$1), '192.168.1.0');
      expect(parsed.$2, 24);
    });

    test('rejects invalid prefixes', () {
      expect(NetworkMatcher.parseCIDR('10.0.0.0/33'), isNull);
      expect(NetworkMatcher.parseCIDR('10.0.0.0/+8'), isNull);
      expect(NetworkMatcher.parseCIDR('10.0.0.0/0x8'), isNull);
      expect(NetworkMatcher.parseCIDR('10.0.0.0/'), isNull);
      expect(NetworkMatcher.parseCIDR('10.0.0.0/8/8'), isNull);
    });
  });

  group('matching', () {
    const rules = '192.168.1.0/24, 10.0.0.7, gateway:172.16.0.1';

    test('address rules ignore gateway rules', () {
      expect(NetworkMatcher.matchAny('192.168.1.23', rules), isTrue);
      expect(NetworkMatcher.matchAny('10.0.0.7', rules), isTrue);
      expect(NetworkMatcher.matchAny('10.0.0.8', rules), isFalse);
      expect(NetworkMatcher.matchAny('172.16.0.1', rules), isFalse);
    });

    test('gateway rules only match gateways', () {
      expect(NetworkMatcher.matchAnyGateway('172.16.0.1', rules), isTrue);
      expect(NetworkMatcher.matchAnyGateway('192.168.1.1', rules), isFalse);
      expect(
        NetworkMatcher.matchAnyGateway(
          '192.168.8.1',
          'GATEWAY: 192.168.8.0/24',
        ),
        isTrue,
      );
    });

    test('shouldStop matches any address or gateway', () {
      expect(
        NetworkMatcher.shouldStop(
          ips: ['100.64.3.2', '192.168.1.9'],
          gateways: const [],
          rules: rules,
        ),
        isTrue,
      );
      expect(
        NetworkMatcher.shouldStop(
          ips: ['192.168.2.9'],
          gateways: ['172.16.0.1'],
          rules: rules,
        ),
        isTrue,
      );
      expect(
        NetworkMatcher.shouldStop(
          ips: ['192.168.2.9'],
          gateways: ['192.168.2.1'],
          rules: rules,
        ),
        isFalse,
      );
      expect(
        NetworkMatcher.shouldStop(
          ips: const [],
          gateways: const [],
          rules: rules,
        ),
        isFalse,
      );
    });
  });

  group('networkKey', () {
    test('ignores order and duplicates', () {
      expect(
        NetworkMatcher.networkKey(['192.168.1.9', '10.0.0.2', '10.0.0.2']),
        NetworkMatcher.networkKey(['10.0.0.2', '192.168.1.9']),
      );
    });

    test('changes when addresses change', () {
      expect(
        NetworkMatcher.networkKey(['192.168.1.9']),
        isNot(NetworkMatcher.networkKey(['192.168.2.9'])),
      );
      expect(
        NetworkMatcher.networkKey(['192.168.1.9']),
        isNot(NetworkMatcher.networkKey(const [])),
      );
    });
  });

  group('validation', () {
    test('accepts address, cidr and gateway rules', () {
      expect(NetworkMatcher.isValidRule('192.168.1.1'), isTrue);
      expect(NetworkMatcher.isValidRule('192.168.1.0/24'), isTrue);
      expect(NetworkMatcher.isValidRule('gateway:192.168.1.1'), isTrue);
      expect(NetworkMatcher.isValidRule('Gateway: 10.0.0.0/8'), isTrue);
    });

    test('rejects malformed and nested gateway rules', () {
      expect(NetworkMatcher.isValidRule('gateway:gateway:1.2.3.4'), isFalse);
      expect(NetworkMatcher.isValidRule('gateway:'), isFalse);
      expect(NetworkMatcher.isValidRule('0x10.0.0.1'), isFalse);
      expect(NetworkMatcher.isValidRule('home'), isFalse);
    });

    test('counts only non-empty rules toward the limit', () {
      expect(
        NetworkMatcher.isValidRules('1.1.1.1,,2.2.2.2,3.3.3.3,4.4.4.4,5.5.5.5'),
        isTrue,
      );
      expect(
        NetworkMatcher.isValidRules(
          '1.1.1.1,2.2.2.2,3.3.3.3,4.4.4.4,5.5.5.5,6.6.6.6',
        ),
        isFalse,
      );
      expect(
        NetworkMatcher.getValidationError(
          '1.1.1.1,2.2.2.2,3.3.3.3,4.4.4.4,5.5.5.5,6.6.6.6',
          tooManyRulesMsg: 'many',
        ),
        'many',
      );
      expect(
        NetworkMatcher.getValidationError(
          '1.1.1.1, bad',
          invalidFormatMsg: 'bad',
        ),
        'bad',
      );
      expect(NetworkMatcher.getValidationError(''), isNull);
    });
  });
}
