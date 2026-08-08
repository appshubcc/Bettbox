import 'package:bett_box/common/runtime_config_overrides.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('updates the timeout of existing provider health checks only', () {
    final rawConfig = <String, dynamic>{
      'proxy-providers': {
        'with-health-check': {
          'health-check': <String, dynamic>{'url': 'https://test.invalid'},
        },
        'without-health-check': <String, dynamic>{'type': 'http'},
      },
    };

    applyProviderHealthCheckTimeoutOverride(rawConfig, 8000);

    final providers = rawConfig['proxy-providers'] as Map;
    final enabled = providers['with-health-check'] as Map;
    expect((enabled['health-check'] as Map)['timeout'], 8000);
    expect(
      (providers['without-health-check'] as Map).containsKey('health-check'),
      isFalse,
    );
  });

  test('keeps an explicitly configured provider timeout', () {
    final rawConfig = <String, dynamic>{
      'proxy-providers': {
        'provider': {
          'health-check': <String, dynamic>{'timeout': 3000},
        },
      },
    };

    applyProviderHealthCheckTimeoutOverride(rawConfig, 8000);

    final provider = (rawConfig['proxy-providers'] as Map)['provider'] as Map;
    expect((provider['health-check'] as Map)['timeout'], 3000);
  });
}
