import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:bett_box/models/models.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'constant.dart';
import 'path.dart';
import 'request.dart';
import 'route_icon.dart';
import 'string.dart';

const managedScriptId = 'managed';
const managedAnchorGroup = 'AdBlock';
const _managedScriptAsset = 'assets/scripts/managed.js';
const _routeCatalogAsset = 'assets/scripts/routing.json';
const _managedScriptUrl =
    'https://raw.githubusercontent.com/$repository/main/$_managedScriptAsset';
const _routeCatalogUrl =
    'https://raw.githubusercontent.com/$repository/main/$_routeCatalogAsset';
const _routeIconBaseUrl =
    'https://cdn.jsdelivr.net/gh/appshubcc/Qure_Style_SVG@main/icon/svg/';
const _routeIconCommonDir = 'common/';
const _routeIconAssetDir = 'assets/route_svg/';
final _versionPattern = RegExp(r'^//\s*@version\s+(\d+)\s*$', multiLine: true);
final _catalogSetPattern = RegExp(r'^(geosite|geoip):(.+)$');
Set<String> _bundledRouteIcons = const {};
Future<void>? _bundledRouteIconsLoad;

Future<void> loadBundledRouteIcons() => _bundledRouteIconsLoad ??= () async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  _bundledRouteIcons = {
    for (final asset in manifest.listAssets())
      if (asset.startsWith(_routeIconAssetDir))
        asset.substring(_routeIconAssetDir.length),
  };
}();

String? routeIconAsset(String? url) {
  if (url == null || !url.startsWith(_routeIconBaseUrl)) return null;
  final icon = Uri.tryParse(url)?.pathSegments.lastOrNull;
  if (icon == null || !_bundledRouteIcons.contains(icon)) return null;
  return '$_routeIconAssetDir$icon';
}

final _prefixStart = RegExp(r'[\p{L}\p{N}]', unicode: true);
final _prefixPattern = RegExp(
  r'^(?:\p{Script=Han}{1,2}|(?:(?!\p{Script=Han})[\p{L}\p{N}])+)',
  unicode: true,
);

String bundlePrefixOf(String label) {
  final text = label.trim();
  final start = text.indexOf(_prefixStart);
  if (start < 0) return text;
  return _prefixPattern.firstMatch(text.substring(start))?.group(0) ?? text;
}

const _mirrorHost = 'cdn.jsdelivr.net';
const _jsdelivrHosts = {
  'cdn.jsdelivr.net',
  'fastly.jsdelivr.net',
  'gcore.jsdelivr.net',
  'testingcf.jsdelivr.net',
  'cdn.jsdmirror.com',
};

String mirrorUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasScheme) return url;
  if (_jsdelivrHosts.contains(uri.host)) {
    return uri.replace(scheme: 'https', host: _mirrorHost).toString();
  }
  final segments = uri.pathSegments;
  final (owner, repo, rest) = switch (uri.host) {
    'raw.githubusercontent.com' when segments.length >= 4 => (
      segments[0],
      segments[1],
      segments.sublist(2),
    ),
    'github.com'
        when segments.length >= 5 &&
            (segments[2] == 'blob' || segments[2] == 'raw') =>
      (segments[0], segments[1], segments.sublist(3)),
    _ => (null, null, const <String>[]),
  };
  if (owner == null || repo == null) return url;
  final heads = rest.length >= 4 && rest[0] == 'refs' && rest[1] == 'heads';
  final branch = heads ? rest[2] : rest[0];
  final path = (heads ? rest.sublist(3) : rest.sublist(1)).join('/');
  return 'https://$_mirrorHost/gh/$owner/$repo@$branch/$path';
}

String? routeIconUrl(String? icon) {
  if (icon == null || icon.isEmpty) return null;
  if (icon.startsWith('http://') || icon.startsWith('https://')) {
    return mirrorUrl(icon);
  }
  final path = icon.contains('/') ? icon : '$_routeIconCommonDir$icon';
  return '$_routeIconBaseUrl${path.split('/').map(Uri.encodeComponent).join('/')}';
}

const builtInIconSetId = 'qure';

IconSet routeIconSet(RouteCatalog catalog) => IconSet(
  id: builtInIconSetId,
  name: 'Qure Style SVG',
  icons: [
    for (final icon in catalog.icons)
      if (routeIconUrl(icon) case final url?) IconSetIcon(name: icon, url: url),
  ],
);

String routeIconValue(String url) {
  if (!url.startsWith(_routeIconBaseUrl)) return url;
  final path = Uri.decodeComponent(url.substring(_routeIconBaseUrl.length));
  return path.startsWith(_routeIconCommonDir)
      ? path.substring(_routeIconCommonDir.length)
      : path;
}

List<String> managedRegions(
  RouteCatalog catalog,
  List<String>? enabled, [
  List<CustomRegion> customRegions = const [],
]) => [
  for (final region in catalog.regions)
    if (enabled?.contains(region.name) ?? region.preset) region.name,
  for (final region in customRegions)
    if (enabled?.contains(region.name) ?? true) region.name,
];

List<String> orderManagedGroups({
  required List<String> presets,
  required List<String> customs,
  required List<String> saved,
  List<String> regions = const [],
}) {
  final groups = [...presets];
  final anchor = groups.indexOf(managedAnchorGroup);
  groups.insertAll(anchor < 0 ? groups.length : anchor, customs);
  groups.addAll(regions);
  if (saved.isEmpty) return groups;
  final rank = {for (final (index, name) in saved.indexed) name: index};
  var last = -1.0;
  final keyed = <({String name, int index, double key})>[];
  for (final (index, name) in groups.indexed) {
    final order = rank[name];
    if (order != null) last = order.toDouble();
    keyed.add((name: name, index: index, key: order?.toDouble() ?? last + 0.5));
  }
  keyed.sort(
    (a, b) => a.key != b.key ? a.key.compareTo(b.key) : a.index - b.index,
  );
  return [for (final entry in keyed) entry.name];
}

class CustomRuleSet {
  static const domain = 'domain';
  static const ipcidr = 'ipcidr';
  static const behaviors = [domain, ipcidr];
  static final _ipPattern = RegExp(
    r'geoip|ipcidr|(^|[/_.-])ip([/_.-]|$)',
    caseSensitive: false,
  );
  static final _extensionPattern = RegExp(
    r'\.(mrs|ya?ml|txt|list|conf)$',
    caseSensitive: false,
  );
  static final _tagPattern = RegExp(r'[^\p{L}\p{N}_-]', unicode: true);

  final String behavior;
  final String url;

  const CustomRuleSet({required this.behavior, required this.url});

  static CustomRuleSet? parse(String key) {
    for (final behavior in behaviors) {
      if (key.startsWith('$behavior:')) {
        return CustomRuleSet(
          behavior: behavior,
          url: key.substring(behavior.length + 1),
        );
      }
    }
    return null;
  }

  static bool isValidUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static String guessBehavior(String url) =>
      _ipPattern.hasMatch(Uri.tryParse(url.trim())?.path ?? '')
      ? ipcidr
      : domain;

  bool get ip => behavior == ipcidr;

  String get key => '$behavior:$url';

  String get format {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    if (path.endsWith('.mrs')) return 'mrs';
    if (path.endsWith('.yaml') || path.endsWith('.yml')) return 'yaml';
    return 'text';
  }

  String get name {
    final uri = Uri.tryParse(url);
    final file =
        uri?.pathSegments.lastWhere(
          (segment) => segment.isNotEmpty,
          orElse: () => '',
        ) ??
        '';
    final name = file.replaceFirst(_extensionPattern, '');
    return name.isEmpty ? uri?.host ?? url : name;
  }

  String get tag => name.replaceAll(_tagPattern, '_');
}

class RouteCatalogIndex {
  final RouteCatalog catalog;
  final Map<String, RouteRuleSet> sets;
  final Map<String, String> icons;
  final Set<String> _names;
  final Map<String, String> _aliases;
  final List<String> _sortedAliasKeys;
  final Map<String, String> _serviceSets;

  RouteCatalogIndex(this.catalog)
    : sets = {for (final set in catalog.sets) set.key: set},
      icons = routeIconIndex(catalog.icons),
      _names = catalog.icons.toSet(),
      _aliases = _buildAliases(catalog, catalog.icons.toSet()),
      _sortedAliasKeys = _buildSortedAliasKeys(
        _buildAliases(catalog, catalog.icons.toSet()),
      ),
      _serviceSets = {
        for (final service in catalog.services)
          if (service.icon case final icon? when icon.isNotEmpty)
            for (final key in service.sets) key: icon,
      };

  static Map<String, String> _buildAliases(
    RouteCatalog catalog,
    Set<String> names,
  ) {
    final map = <String, String>{};
    void put(String key, String? icon) {
      if (icon == null || icon.isEmpty || !names.contains(icon)) return;
      final clean = key.trim().toLowerCase();
      if (clean.isNotEmpty) map.putIfAbsent(clean, () => icon);
    }

    for (final region in catalog.regions) {
      put(region.name, region.icon);
    }
    for (final service in catalog.services) {
      put(service.name, service.icon);
      for (final keyword in service.keywords) {
        put(keyword, service.icon);
      }
    }
    for (final MapEntry(:key, :value) in defaultRouteAliases.entries) {
      put(key, value);
    }
    return map;
  }

  static List<String> _buildSortedAliasKeys(Map<String, String> aliases) =>
      aliases.keys.toList()..sort((a, b) => b.length.compareTo(a.length));

  String? _matchName(String name) {
    final clean = name.trim().toLowerCase();
    if (clean.isEmpty) return null;
    if (_aliases[clean] case final icon?) return icon;
    final tokens = routeWordPattern
        .allMatches(clean)
        .map((m) => m.group(0) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    for (final key in _sortedAliasKeys) {
      if (routeHanPattern.hasMatch(key)) {
        if (clean.contains(key)) return _aliases[key];
      } else {
        if (tokens.contains(key)) return _aliases[key];
      }
    }
    for (final token in tokens) {
      if (_aliases[token] case final icon?) return icon;
    }
    if (matchRouteIcon(clean, icons) case final icon?) return icon;
    for (final token in tokens) {
      if (token.length < 2) continue;
      if (matchRouteIcon(token, icons) case final icon?) return icon;
    }
    return null;
  }

  String? autoIcon(String name, Iterable<String> keys) {
    if (_matchName(name) case final icon?) return icon;
    for (final key in keys) {
      if (CustomRuleSet.parse(key) case final custom?) {
        if (_matchName(custom.name) case final icon?) return icon;
      }
      if (_serviceSets[key] case final icon?) return icon;
      if (sets[key]?.icon case final icon? when icon.isNotEmpty) return icon;
      if (_catalogSetPattern.firstMatch(key) case final match?) {
        if (match.group(2) case final tag? when tag.isNotEmpty) {
          if (_matchName(tag) case final icon?) return icon;
        }
      }
    }
    return null;
  }

  String? iconOf(CustomRoute route) {
    final icon = route.icon;
    if (icon == null) return autoIcon(route.name, route.sets);
    if (icon.isEmpty) return null;
    if (icon.isHttpUrl || _names.contains(icon)) return icon;
    final name = icon.substring(icon.lastIndexOf('/') + 1);
    return matchRouteIcon(
          name.endsWith('.svg') ? name.substring(0, name.length - 4) : name,
          icons,
        ) ??
        autoIcon(route.name, route.sets);
  }

  String? iconUrlOf(CustomRoute route) => routeIconUrl(iconOf(route));
}

class ManagedScript {
  const ManagedScript._();

  static Future<File> _catalogFile() async {
    final script = await appPath.getScriptPath(managedScriptId);
    return File(p.join(p.dirname(script), '$managedScriptId.routing.json'));
  }

  static Future<String> _readCatalog(ManagedProps props) async {
    if (syncedVersion(props) != null) {
      final file = await _catalogFile();
      if (await file.exists()) return file.readAsString();
    }
    return rootBundle.loadString(_routeCatalogAsset, cache: false);
  }

  static Future<RouteCatalogIndex> _parseCatalog(String text) => Isolate.run(
    () => RouteCatalogIndex(
      RouteCatalog.fromJson(jsonDecode(text) as Map<String, Object?>),
    ),
  );

  static Future<RouteCatalogIndex> catalog(ManagedProps props) async {
    final (index, _) = await (
      _readCatalog(props).then(_parseCatalog),
      loadBundledRouteIcons(),
    ).wait;
    return index;
  }

  static Future<List<Map<String, Object?>>> _routes(ManagedProps props) async {
    final enabled = [
      for (final route in props.routes)
        if (route.enabled && route.sets.isNotEmpty) route,
    ];
    if (enabled.isEmpty) return const [];
    final index = enabled.any((route) => route.icon?.isHttpUrl != true)
        ? await catalog(props)
        : null;
    return [
      for (final route in enabled)
        {
          'name': route.name,
          'icon': ?routeIconUrl(index?.iconOf(route) ?? route.icon),
          'target': ?route.target,
          'sets': [
            for (final key in route.sets)
              if (_catalogSetPattern.firstMatch(key) case final match?)
                {'type': match.group(1), 'tag': match.group(2)}
              else if (CustomRuleSet.parse(key) case final custom?)
                {
                  'type': custom.ip ? 'geoip' : 'geosite',
                  'tag': custom.tag,
                  'url': mirrorUrl(custom.url),
                  'format': custom.format,
                },
          ],
        },
    ];
  }

  static const _customVersionPrefix = 'custom:';

  static String _bundledVersion = '';

  static String get bundledVersion => _bundledVersion;

  static String? parseVersion(String content) =>
      _versionPattern.firstMatch(content)?.group(1);

  static Future<String> readBundled() =>
      rootBundle.loadString(_managedScriptAsset);

  static Future<void> loadBundledVersion() async {
    final content = await readBundled();
    _bundledVersion = parseVersion(content) ?? '';
  }

  static int compareVersions(String a, String b) {
    final numA = BigInt.tryParse(a);
    final numB = BigInt.tryParse(b);
    if (numA != null && numB != null) {
      return numA.compareTo(numB);
    }
    return a.compareTo(b);
  }

  static bool isCustom(ManagedProps props) =>
      props.syncedVersion?.startsWith(_customVersionPrefix) ?? false;

  static String? syncedVersion(ManagedProps props) {
    final version = props.syncedVersion;
    if (version == null) return null;
    if (version.startsWith(_customVersionPrefix)) return version;
    if (compareVersions(version, bundledVersion) < 0) {
      return null;
    }
    return version;
  }

  static String version(ManagedProps props) =>
      syncedVersion(props) ?? bundledVersion;

  static Future<String> read(ManagedProps props) async {
    if (syncedVersion(props) != null) {
      final file = File(await appPath.getScriptPath(managedScriptId));
      if (await file.exists()) return file.readAsString();
    }
    return readBundled();
  }

  static Future<Script> script(
    ManagedProps props, {
    String? raw,
    bool bundled = false,
  }) async {
    final source = raw ?? (bundled ? await readBundled() : await read(props));
    final routes = await _routes(props);
    final prelude = [
      if (routes.isNotEmpty) 'const bettboxRoutes = ${jsonEncode(routes)};',
      if (props.regions case final regions?)
        'const bettboxRegions = ${jsonEncode(regions)};',
      if (props.customRegions.isNotEmpty)
        'const bettboxCustomRegions = ${jsonEncode([
          for (final cr in props.customRegions)
            {
              'name': cr.name,
              'regex': cr.regex,
              'icon': ?routeIconUrl(
                defaultRouteAliases[cr.name.trim().toLowerCase()] ??
                    defaultRouteAliases[cr.name.trim()],
              ),
            },
        ])};',
      if (props.order.isNotEmpty)
        'const bettboxOrder = ${jsonEncode(props.order)};',
    ];
    final content = prelude.isEmpty ? source : '${prelude.join('\n')}\n$source';
    return Script(
      id: managedScriptId,
      label: managedScriptId,
      content: content,
      customOptions: props.options,
      digest: content.toMd5(),
      volatile: volatileScriptPattern.hasMatch(source),
    );
  }

  static Future<String?> save(String content) async {
    final normalized = content.replaceAll(RegExp(r'\r\n?'), '\n');
    final bundled = (await readBundled()).replaceAll(RegExp(r'\r\n?'), '\n');
    if (normalized == bundled) {
      await restore();
      return null;
    }
    await _write(File(await appPath.getScriptPath(managedScriptId)), content);
    return '$_customVersionPrefix${normalized.toMd5()}';
  }

  static Future<void> _write(File file, String content) async {
    final temp = File(
      '${file.path}.${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    await temp.parent.create(recursive: true);
    await temp.writeAsString(content, flush: true);
    await temp.rename(file.path);
  }

  static Future<String> _fetchCatalog() async {
    final res = await request.getTextResponseForUrl(
      mirrorUrl(_routeCatalogUrl),
    );
    final content = res.data;
    if (content is! String) {
      throw 'Invalid route catalog';
    }
    final index = await _parseCatalog(content);
    if (index.catalog.sets.isEmpty) {
      throw 'Invalid route catalog';
    }
    return content;
  }

  static Future<({bool updated, String? syncedVersion})> sync(
    ManagedProps props,
  ) async {
    final (res, catalog) = await (
      request.getTextResponseForUrl(mirrorUrl(_managedScriptUrl)),
      _fetchCatalog(),
    ).wait;
    final content = res.data;
    final next = content is String ? parseVersion(content) : null;
    if (content is! String ||
        next == null ||
        !content.contains('function main')) {
      throw 'Invalid script';
    }
    final scriptChanged = content != await read(props);
    final catalogChanged = catalog != await _readCatalog(props);
    if (!scriptChanged && !catalogChanged && !isCustom(props)) {
      return (updated: false, syncedVersion: syncedVersion(props));
    }
    final (bundledScript, bundledCatalog) = await (
      readBundled(),
      rootBundle.loadString(_routeCatalogAsset, cache: false),
    ).wait;
    if (content == bundledScript && catalog == bundledCatalog) {
      await restore();
      return (updated: true, syncedVersion: null);
    }
    if (scriptChanged) {
      await _write(File(await appPath.getScriptPath(managedScriptId)), content);
    }
    if (catalogChanged) {
      await _write(await _catalogFile(), catalog);
    }
    return (updated: true, syncedVersion: next);
  }

  static Future<void> restore() async {
    for (final file in [
      File(await appPath.getScriptPath(managedScriptId)),
      await _catalogFile(),
    ]) {
      if (await file.exists()) await file.delete();
    }
  }
}
