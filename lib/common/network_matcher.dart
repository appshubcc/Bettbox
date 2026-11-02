class NetworkMatcher {
  static const _gatewayPrefix = 'gateway:';
  static final _octetRegExp = RegExp(r'^\d{1,3}$');
  static final _prefixRegExp = RegExp(r'^\d{1,2}$');

  static int? parseIPv4(String ip) {
    final parts = ip.trim().split('.');
    if (parts.length != 4) return null;

    int result = 0;
    for (final part in parts) {
      final trimmed = part.trim();
      if (!_octetRegExp.hasMatch(trimmed)) return null;
      final value = int.parse(trimmed);
      if (value > 255) return null;
      result = (result << 8) | value;
    }
    return result;
  }

  static String formatIPv4(int ip) {
    return '${(ip >> 24) & 0xFF}.${(ip >> 16) & 0xFF}.${(ip >> 8) & 0xFF}.${ip & 0xFF}';
  }

  static (int, int)? parseCIDR(String cidr) {
    final parts = cidr.trim().split('/');

    if (parts.length == 1) {
      final ip = parseIPv4(parts[0]);
      return ip != null ? (ip, 32) : null;
    }

    if (parts.length != 2) return null;

    final ip = parseIPv4(parts[0]);
    if (ip == null) return null;

    final prefixText = parts[1].trim();
    if (!_prefixRegExp.hasMatch(prefixText)) return null;
    final prefix = int.parse(prefixText);
    if (prefix > 32) return null;

    final mask = prefix == 0 ? 0 : (0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF;
    return (ip & mask, prefix);
  }

  static bool isIPInCIDR(String ip, String cidr) {
    final ipInt = parseIPv4(ip);
    if (ipInt == null) return false;

    final parsed = parseCIDR(cidr);
    if (parsed == null) return false;

    final (network, prefix) = parsed;
    if (prefix == 0) return true;

    final mask = (0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF;
    return (ipInt & mask) == network;
  }

  static bool matchRule(String ip, String rule) {
    final trimmed = rule.trim();
    if (trimmed.isEmpty) return false;

    if (trimmed.contains('/')) {
      return isIPInCIDR(ip, trimmed);
    }

    final ipInt = parseIPv4(ip);
    final ruleInt = parseIPv4(trimmed);
    return ipInt != null && ruleInt != null && ipInt == ruleInt;
  }

  static String? _gatewayTarget(String rule) {
    final trimmed = rule.trim();
    if (!trimmed.toLowerCase().startsWith(_gatewayPrefix)) return null;
    return trimmed.substring(_gatewayPrefix.length).trim();
  }

  static bool matchAny(String? ip, String rules) {
    if (ip == null || ip.isEmpty || rules.isEmpty) return false;

    return rules
        .split(',')
        .any((rule) => _gatewayTarget(rule) == null && matchRule(ip, rule));
  }

  static bool matchAnyGateway(String? gateway, String rules) {
    if (gateway == null || gateway.isEmpty || rules.isEmpty) return false;

    return rules.split(',').any((rule) {
      final target = _gatewayTarget(rule);
      return target != null && matchRule(gateway, target);
    });
  }

  static bool shouldStop({
    required Iterable<String> ips,
    required Iterable<String> gateways,
    required String rules,
  }) {
    return ips.any((ip) => matchAny(ip, rules)) ||
        gateways.any((gateway) => matchAnyGateway(gateway, rules));
  }

  static String networkKey(Iterable<String> ips) {
    return (ips.toSet().toList()..sort()).join(',');
  }

  static bool _isValidAddressRule(String rule) {
    final trimmed = rule.trim();
    if (trimmed.isEmpty) return false;
    return trimmed.contains('/')
        ? parseCIDR(trimmed) != null
        : parseIPv4(trimmed) != null;
  }

  static bool isValidRule(String rule) {
    final trimmed = rule.trim();
    if (trimmed.isEmpty) return false;
    return _isValidAddressRule(_gatewayTarget(trimmed) ?? trimmed);
  }

  static List<String> _nonEmptyRules(String rules) {
    return rules
        .split(',')
        .map((rule) => rule.trim())
        .where((rule) => rule.isNotEmpty)
        .toList();
  }

  static bool isValidRules(String rules) {
    if (rules.isEmpty) return true;

    final ruleList = _nonEmptyRules(rules);
    if (ruleList.length > 5) return false;

    return ruleList.every(isValidRule);
  }

  static String? getValidationError(
    String rules, {
    String invalidFormatMsg = 'Invalid IP or CIDR format',
    String tooManyRulesMsg = 'Maximum 5 rules allowed',
  }) {
    if (rules.isEmpty) return null;

    final ruleList = _nonEmptyRules(rules);
    if (ruleList.length > 5) return tooManyRulesMsg;

    for (final rule in ruleList) {
      if (!isValidRule(rule)) {
        return invalidFormatMsg;
      }
    }
    return null;
  }
}
