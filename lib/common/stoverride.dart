import 'package:yaml/yaml.dart';

class StOverrideImport {
  const StOverrideImport({
    required this.hosts,
    required this.rewrite,
    required this.ignoredScripts,
    this.name,
  });

  final List<String> hosts;
  final List<String> rewrite;
  final bool ignoredScripts;
  final String? name;

  bool get isEmpty => hosts.isEmpty && rewrite.isEmpty;
}

StOverrideImport parseStOverride(String source) {
  final doc = loadYaml(source);
  if (doc is! YamlMap) {
    return const StOverrideImport(hosts: [], rewrite: [], ignoredScripts: false);
  }
  final root = _yamlMap(doc);
  final http = root['http'];
  final httpMap = http is YamlMap
      ? _yamlMap(http)
      : http is Map
      ? Map<String, dynamic>.from(http)
      : <String, dynamic>{};

  final hosts = _stringList(httpMap['mitm'] ?? root['mitm']);
  final rewrite = _stringList(httpMap['rewrite'] ?? root['rewrite']);
  final hasScripts =
      httpMap['script'] != null ||
      httpMap['script-providers'] != null ||
      root['script'] != null ||
      root['script-providers'] != null;
  final name = (root['name'] ?? root['desc'])?.toString();
  return StOverrideImport(
    hosts: hosts,
    rewrite: rewrite,
    ignoredScripts: hasScripts,
    name: name,
  );
}

Map<String, dynamic> _yamlMap(YamlMap map) {
  return Map<String, dynamic>.from(map);
}

List<String> _stringList(dynamic value) {
  if (value is YamlList) {
    return value
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  if (value is List) {
    return value
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  if (value is String && value.trim().isNotEmpty) {
    return [value.trim()];
  }
  return const [];
}

List<String> mergeUnique(List<String> current, List<String> incoming) {
  final seen = <String>{};
  final out = <String>[];
  for (final item in [...current, ...incoming]) {
    final v = item.trim();
    if (v.isEmpty || seen.contains(v)) continue;
    seen.add(v);
    out.add(v);
  }
  return out;
}
