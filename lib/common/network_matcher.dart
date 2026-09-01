class NetworkMatcher {
  static int? parseIPv4(String ip) {
    final parts = ip.trim().split('.');
    if (parts.length != 4) return null;

    int result = 0;
    for (final part in parts) {
      final value = int.tryParse(part);
      if (value == null || value < 0 || value > 255) return null;
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

    final prefix = int.tryParse(parts[1]);
    if (prefix == null || prefix < 0 || prefix > 32) return null;

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

  static bool matchAny(String? ip, String rules) {
    if (ip == null || ip.isEmpty || rules.isEmpty) return false;

    return rules.split(',').any((rule) => matchRule(ip, rule));
  }

  static bool matchAnyGateway(String? gateway, String rules) {
    if (gateway == null || gateway.isEmpty || rules.isEmpty) return false;

    return rules.split(',').any((rule) {
      final trimmed = rule.trim();
      if (!trimmed.toLowerCase().startsWith('gateway:')) return false;
      return matchRule(gateway, trimmed.substring(8).trim());
    });
  }

  static bool isValidRule(String rule) {
    final trimmed = rule.trim();
    if (trimmed.isEmpty) return false;

    if (trimmed.toLowerCase().startsWith('gateway:')) {
      return isValidRule(trimmed.substring(8).trim());
    }

    return trimmed.contains('/') ? parseCIDR(trimmed) != null : parseIPv4(trimmed) != null;
  }

  static bool isValidRules(String rules) {
    if (rules.isEmpty) return true;

    final ruleList = rules.split(',');
    if (ruleList.length > 5) return false;

    return ruleList.every((rule) => rule.trim().isEmpty || isValidRule(rule));
  }

  static String? getValidationError(
    String rules, {
    String invalidFormatMsg = 'Invalid IP or CIDR format',
    String tooManyRulesMsg = 'Maximum 5 rules allowed',
  }) {
    if (rules.isEmpty) return null;

    final ruleList = rules.split(',');
    if (ruleList.length > 5) return tooManyRulesMsg;

    for (final rule in ruleList) {
      if (rule.trim().isNotEmpty && !isValidRule(rule)) {
        return invalidFormatMsg;
      }
    }
    return null;
  }
}
