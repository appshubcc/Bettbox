final _routeIconKeyPattern = RegExp(r'[^a-z0-9]');
final _routeTokenPattern = RegExp(r'[-_.]+');
final _routeTrailingDigits = RegExp(r'\d+$');

const _routeIconSuffixes = [
  '-!cn',
  '-cn',
  '-ads-all',
  '-ads',
  '-all',
  '-global',
  '-intl',
  '-international',
  '-dev',
  '-app',
  '-apps',
  '-cdn',
  '-games',
  '-game',
  '-tv',
  '-music',
  '-video',
  '-cloud',
  '-api',
  '-shop',
  '-store',
];

String routeIconKey(String value) =>
    value.toLowerCase().replaceAll(_routeIconKeyPattern, '');

Map<String, String> routeIconIndex(Iterable<String> files) {
  final index = <String, String>{};
  for (final file in files) {
    final base = file.substring(file.lastIndexOf('/') + 1);
    final name = base.endsWith('.svg')
        ? base.substring(0, base.length - 4)
        : base;
    final key = routeIconKey(name);
    if (key.isNotEmpty) index.putIfAbsent(key, () => file);
  }
  return index;
}

String? matchRouteIcon(String name, Map<String, String> index) {
  String? find(String value) {
    final key = routeIconKey(value);
    return key.isEmpty ? null : index[key];
  }

  final exact = find(name);
  if (exact != null) return exact;
  var base = name.split('@').first;
  final byBase = find(base);
  if (byBase != null) return byBase;
  var changed = true;
  while (changed) {
    changed = false;
    if (base.startsWith('category-')) {
      base = base.substring(9);
      changed = true;
    }
    for (final suffix in _routeIconSuffixes) {
      if (base.length > suffix.length + 1 && base.endsWith(suffix)) {
        base = base.substring(0, base.length - suffix.length);
        changed = true;
      }
    }
  }
  final byAffix = find(base);
  if (byAffix != null) return byAffix;
  final tokens = base
      .split(_routeTokenPattern)
      .where((token) => token.isNotEmpty)
      .toList();
  for (var count = tokens.length - 1; count > 0; count--) {
    final key = routeIconKey(tokens.take(count).join());
    if (key.length < 3) continue;
    final icon = index[key];
    if (icon != null) return icon;
  }
  final key = routeIconKey(base);
  final digits = _routeTrailingDigits.firstMatch(key);
  if (digits == null || digits.start < 3) return null;
  return index[key.substring(0, digits.start)];
}
