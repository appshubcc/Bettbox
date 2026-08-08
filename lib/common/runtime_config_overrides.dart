void applyProviderHealthCheckTimeoutOverride(
  Map<String, dynamic> rawConfig,
  int timeout,
) {
  if (timeout == 5000) {
    return;
  }

  final providers = rawConfig['proxy-providers'];
  if (providers is! Map) {
    return;
  }

  for (final provider in providers.values) {
    if (provider is! Map) {
      continue;
    }
    final healthCheck = provider['health-check'];
    if (healthCheck is Map) {
      healthCheck['timeout'] ??= timeout;
    }
  }
}
