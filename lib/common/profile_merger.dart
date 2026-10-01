/// 多份本地配置的合并引擎。
///
/// 纯函数实现：输入的各成员配置**已经跑过内置覆写脚本**（见 `builtin_script.dart`），
/// 已经是含 `proxies` / `proxy-groups` / `rules` / `dns` / `hosts` / 全局项的完整配置，
/// 输出一份合并后的完整配置。
///
/// 内置脚本随包分发、不开放编辑，它的自定义节点（`customizeProxies`）恒为空，
/// 所以合并阶段不需要为「脚本自带的节点」留例外：不加前缀的只有内核直连 / 拒绝节点。
///
/// 处理顺序：
/// 1. 节点按内容指纹跨成员去重；去重后的节点加成员前缀（每个成员可单独填，留空用成员名称），
///    但脚本固定注入的内核直连 / 拒绝节点不属于任何成员，按原样保留、不加前缀；
///    `dialer-proxy` 引用同步改写
/// 2. 策略组按名字取并集：脚本对每个成员生成的是同一套组名，只有节点名单不同；
///    组内引用先跟随改名重写，再按先出现顺序合并去重。组的先后顺序则按**脚本顺序**
///    还原（成员可能因为缺某类节点而少生成组，例如没有某地区节点，不能让这些组被甩到末尾）
/// 3. `rule-providers` 取并集，`rules` 与全局项沿用先出现成员的（脚本对每个成员一致）
/// 4. DNS 的 `proxy-server-nameserver-policy` / `fake-ip-filter` 取并集，
///    其余 DNS 模板沿用先出现成员的
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// 合并中的一个成员配置。
class BundleMemberConfig {
  const BundleMemberConfig({
    required this.id,
    required this.label,
    required this.config,
  });

  final String id;
  final String label;

  /// 该成员跑过内置覆写脚本之后的完整配置。
  final Map<String, dynamic> config;
}

class BundleMergeOptions {
  const BundleMergeOptions({
    this.memberPrefixes = const {},
    this.prefixSeparator = ' | ',
  });

  /// 成员 id -> 该成员自己的节点前缀；没有条目或值为空表示用成员名称。
  final Map<String, String> memberPrefixes;

  final String prefixSeparator;
}

/// 合并过程中的提示项，交由 UI 做本地化。
class BundleMergeWarning {
  const BundleMergeWarning(this.code, {this.member, this.count = 0});

  /// `scriptFailed` / `tunnels` / `hostConflict` / `policyConflict`
  final String code;

  /// 相关成员名称（可选）。
  final String? member;

  /// 相关条目数量。
  final int count;

  Map<String, dynamic> toJson() => {
    'code': code,
    if (member != null) 'member': member,
    'count': count,
  };

  factory BundleMergeWarning.fromJson(Map<String, dynamic> json) =>
      BundleMergeWarning(
        json['code'] as String? ?? '',
        member: json['member'] as String?,
        count: (json['count'] as num?)?.toInt() ?? 0,
      );
}

class BundleMergeReport {
  const BundleMergeReport({
    this.memberCount = 0,
    this.nodeCount = 0,
    this.duplicateNodeCount = 0,
    this.dnsPolicyCount = 0,
    this.groupCount = 0,
    this.warnings = const [],
  });

  final int memberCount;
  final int nodeCount;
  final int duplicateNodeCount;

  /// 合并后的节点域名 DNS 策略条目数（脚本按节点域名承接的私有 DNS 都在这里）。
  final int dnsPolicyCount;

  final int groupCount;
  final List<BundleMergeWarning> warnings;

  Map<String, dynamic> toJson() => {
    'memberCount': memberCount,
    'nodeCount': nodeCount,
    'duplicateNodeCount': duplicateNodeCount,
    'dnsPolicyCount': dnsPolicyCount,
    'groupCount': groupCount,
    'warnings': warnings.map((w) => w.toJson()).toList(),
  };

  factory BundleMergeReport.fromJson(Map<String, dynamic> json) =>
      BundleMergeReport(
        memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
        nodeCount: (json['nodeCount'] as num?)?.toInt() ?? 0,
        duplicateNodeCount: (json['duplicateNodeCount'] as num?)?.toInt() ?? 0,
        dnsPolicyCount: (json['dnsPolicyCount'] as num?)?.toInt() ?? 0,
        groupCount: (json['groupCount'] as num?)?.toInt() ?? 0,
        warnings: (json['warnings'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => BundleMergeWarning.fromJson(e.cast<String, dynamic>()))
            .toList(),
      );
}

class BundleMergeResult {
  const BundleMergeResult({required this.config, required this.report});

  final Map<String, dynamic> config;
  final BundleMergeReport report;
}

/// 内核保留的代理名，不能作为节点名。
const _reservedProxyNames = {
  'DIRECT',
  'REJECT',
  'REJECT-DROP',
  'PASS',
  'COMPATIBLE',
  'GLOBAL',
};

/// 由脚本重建的字段，必须走合并逻辑而不是沿用先出现成员的那一份。
const _rebuiltKeys = {
  'proxies',
  'proxy-groups',
  'rule-providers',
  'dns',
  'hosts',
};

/// 合并多个已跑过内置覆写脚本的配置。
///
/// [extraWarnings] 由调用方补充（例如脚本求值失败的成员），会并入结果报告。
BundleMergeResult mergeBundleConfigs({
  required List<BundleMemberConfig> members,
  BundleMergeOptions options = const BundleMergeOptions(),
  List<BundleMergeWarning> extraWarnings = const [],
}) {
  if (members.isEmpty) {
    throw ArgumentError.value(members, 'members', '至少需要一个成员');
  }

  final warnings = <BundleMergeWarning>[...extraWarnings];
  final mergedProxies = <Map<String, dynamic>>[];
  final fingerprints = <String, String>{};
  final usedNames = <String>{};
  final mergedGroups = <String, Map<String, dynamic>>{};
  // 每个成员自己的组顺序（都是同一套脚本产物的子序列），最后用它还原脚本的固定顺序
  final memberGroupOrders = <List<String>>[];
  final mergedProviders = <String, dynamic>{};
  final mergedHosts = <String, dynamic>{};
  final mergedPolicy = <String, dynamic>{};
  final mergedFakeIpFilter = <String>[];
  final dns = <String, dynamic>{};
  var duplicateCount = 0;
  var hostConflictCount = 0;
  var policyConflictCount = 0;

  for (final member in members) {
    final config = member.config;
    final prefix = _prefixFor(member, options);
    final rename = <String, String>{};
    final kept = <Map<String, dynamic>>[];

    // --- 1. 节点：内容指纹跨成员去重，去重后再加成员前缀 ---
    for (final raw in (config['proxies'] as List?) ?? const []) {
      if (raw is! Map) continue;
      final proxy = raw.cast<String, dynamic>();
      final originalName = (proxy['name'] as String?)?.trim() ?? '';
      final fingerprint = _fingerprint(proxy);

      final existing = fingerprints[fingerprint];
      if (existing != null) {
        duplicateCount++;
        if (originalName.isNotEmpty) rename[originalName] = existing;
        continue;
      }

      final name = _allocateName(
        _sanitizeName(_prefixedName(proxy, originalName, prefix, options)),
        usedNames,
      );
      fingerprints[fingerprint] = name;
      if (originalName.isNotEmpty) rename[originalName] = name;
      kept.add({...proxy, 'name': name});
    }

    // 成员的节点可能自带 dialer-proxy（订阅自己的中转链），引用的是节点名，改名后必须一起重写；
    // 指向策略组的引用不在改名表里，原样保留。
    for (final proxy in kept) {
      final dialer = proxy['dialer-proxy'];
      if (dialer is! String || dialer.isEmpty) continue;
      final mapped = rename[dialer];
      if (mapped != null) {
        proxy['dialer-proxy'] = mapped;
      }
    }
    mergedProxies.addAll(kept);

    // --- 2. 策略组：节点引用跟随改名，再按组名取并集 ---
    final memberOrder = <String>[];
    final memberOrderSeen = <String>{};
    for (final raw in (config['proxy-groups'] as List?) ?? const []) {
      if (raw is! Map) continue;
      final group = raw.cast<String, dynamic>();
      final name = group['name']?.toString() ?? '';
      if (name.isEmpty) continue;

      if (memberOrderSeen.add(name)) memberOrder.add(name);
      final references = _remapReferences(group['proxies'], rename);
      final existing = mergedGroups[name];
      if (existing == null) {
        mergedGroups[name] = {
          ...group,
          if (group.containsKey('proxies')) 'proxies': references,
        };
      } else if (references.isNotEmpty) {
        final current = (existing['proxies'] as List?) ?? const [];
        existing['proxies'] = _unionReferences(current, references);
      }
    }
    memberGroupOrders.add(memberOrder);

    // --- 3. 规则集取并集（脚本对每个成员是同一套，兜底按 key 去重） ---
    final providers = config['rule-providers'];
    if (providers is Map) {
      for (final entry in providers.entries) {
        mergedProviders.putIfAbsent(entry.key.toString(), () => entry.value);
      }
    }

    // --- 4. DNS：基础模板取先出现成员，节点域名策略与 fake-ip-filter 取并集 ---
    final memberDns = _stringMap(config['dns']);
    if (memberDns != null) {
      if (dns.isEmpty) dns.addAll(memberDns);
      final policy = _stringMap(memberDns['proxy-server-nameserver-policy']);
      for (final entry in policy?.entries ?? const <MapEntry<String, dynamic>>[]) {
        final existing = mergedPolicy[entry.key];
        if (existing == null) {
          mergedPolicy[entry.key] = entry.value;
          continue;
        }
        if (_canonicalJson(existing) == _canonicalJson(entry.value)) continue;
        // 脚本会按后缀把同一份私有 DNS 压缩成 +.suffix，两个成员的节点域名
        // 同后缀时会撞在同一个 key 上。这里取并集，避免后出现成员的私有 DNS 被丢掉。
        final unified = _unionDnsValues(existing, entry.value);
        if (unified != null) {
          mergedPolicy[entry.key] = unified;
        }
        policyConflictCount++;
      }
      for (final pattern in (memberDns['fake-ip-filter'] as List?) ?? const []) {
        final value = pattern.toString();
        if (!mergedFakeIpFilter.contains(value)) mergedFakeIpFilter.add(value);
      }
    }

    // --- 5. hosts 取并集 ---
    final memberHosts = _stringMap(config['hosts']);
    for (final entry in memberHosts?.entries ?? const <MapEntry<String, dynamic>>[]) {
      if (entry.value == null) continue;
      final existing = mergedHosts[entry.key];
      if (existing == null) {
        mergedHosts[entry.key] = entry.value;
      } else if (_canonicalJson(existing) != _canonicalJson(entry.value)) {
        hostConflictCount++;
      }
    }
  }

  if (hostConflictCount > 0) {
    warnings.add(BundleMergeWarning('hostConflict', count: hostConflictCount));
  }
  if (policyConflictCount > 0) {
    warnings.add(
      BundleMergeWarning('policyConflict', count: policyConflictCount),
    );
  }

  // --- 6. 组装：策略组 / 分流 / DNS / 全局项都由脚本产出，这里只做并集与去重 ---
  final config = <String, dynamic>{};
  for (final entry in members.first.config.entries) {
    if (_rebuiltKeys.contains(entry.key)) continue;
    config[entry.key] = entry.value;
  }
  config['proxies'] = mergedProxies;
  final groupOrder = _restoreGroupOrder(memberGroupOrders);
  if (groupOrder.isNotEmpty) {
    config['proxy-groups'] = [
      for (final name in groupOrder)
        if (mergedGroups[name] != null) mergedGroups[name]!,
    ];
  }
  if (mergedProviders.isNotEmpty) {
    config['rule-providers'] = mergedProviders;
  }
  if (dns.isNotEmpty) {
    if (mergedPolicy.isNotEmpty) {
      dns['proxy-server-nameserver-policy'] = mergedPolicy;
    } else {
      dns.remove('proxy-server-nameserver-policy');
    }
    if (mergedFakeIpFilter.isNotEmpty) {
      dns['fake-ip-filter'] = mergedFakeIpFilter;
    }
    config['dns'] = dns;
  }
  config['hosts'] = mergedHosts;

  return BundleMergeResult(
    config: config,
    report: BundleMergeReport(
      memberCount: members.length,
      nodeCount: mergedProxies.length,
      duplicateNodeCount: duplicateCount,
      dnsPolicyCount: mergedPolicy.length,
      groupCount: groupOrder.length,
      warnings: warnings,
    ),
  );
}

/// 还原脚本自己的策略组顺序。
///
/// 每个成员的组列表都是同一套脚本产物的**子序列**：某个成员可能因为节点不够（例如没有
/// 低倍率节点）而没生成某些组，另一个成员却生成了。按「谁先出现谁在前」会把这类组甩到
/// 最后，所以这里以组最多的成员为底，再把别的成员多出来的组插回它在脚本里的位置
/// （用它在该成员列表里最近的前/后邻居做锚点）。
///
/// 局限：如果某个组只在 A 里出现、另一个组只在 B 里出现，而没有任何成员同时含这两者，
/// 它们的先后就只能靠锚点推断（例如「其他节点」在脚本里其实是最后一组，但在这种组合下
/// 会被插在中间）。要精确到这种程度只能再跑一遍脚本，代价不值当。
List<String> _restoreGroupOrder(List<List<String>> memberOrders) {
  // 以组最多的成员为底；组数相同取先出现的成员（保证结果稳定可预期）
  final orders =
      [
        for (var i = 0; i < memberOrders.length; i++)
          if (memberOrders[i].isNotEmpty) (index: i, order: memberOrders[i]),
      ]..sort((a, b) {
        final byLength = b.order.length.compareTo(a.order.length);
        return byLength != 0 ? byLength : a.index.compareTo(b.index);
      });
  if (orders.isEmpty) return const [];

  final result = <String>[...orders.first.order];
  final placed = result.toSet();
  for (final entry in orders.skip(1)) {
    final order = entry.order;
    for (var i = 0; i < order.length; i++) {
      final name = order[i];
      if (!placed.add(name)) continue;

      // 先往前找最近的、已经排好的组，插到它后面
      var insertAt = -1;
      for (var j = i - 1; j >= 0; j--) {
        final index = result.indexOf(order[j]);
        if (index != -1) {
          insertAt = index + 1;
          break;
        }
      }
      // 前面没有锚点就往后找，插到它前面；都没有就放末尾
      if (insertAt == -1) {
        for (var j = i + 1; j < order.length; j++) {
          final index = result.indexOf(order[j]);
          if (index != -1) {
            insertAt = index;
            break;
          }
        }
      }
      result.insert(insertAt == -1 ? result.length : insertAt, name);
    }
  }
  return result;
}

/// 合并配置的默认名称：把每个成员的名字都用 ` + ` 连起来。
///
/// 早期版本只取前两个成员再补 `+N`（例如「良心云 + 花云 +1」），
/// 三个成员起名称就对不上，所以改成全部列出来。
String bundleDefaultLabel(Iterable<String> memberLabels) =>
    memberLabels.join(' + ');

/// 成员指纹：名称 + 成员文件修改时间。
///
/// 名称会作为节点前缀参与合并，所以**改名同样要触发重新合并**，不能只看文件时间。
String bundleMemberStamp({required String? label, required int lastModified}) {
  return '${label ?? ''}\u0000$lastModified';
}

/// 成员前缀：成员自己填了就用它，没填（留空）就用成员名称。
String _prefixFor(BundleMemberConfig member, BundleMergeOptions options) {
  final own = options.memberPrefixes[member.id];
  if (own != null && own.trim().isNotEmpty) {
    return _sanitizeName(own);
  }
  return _sanitizeName(member.label.isNotEmpty ? member.label : member.id);
}

/// 内核直连 / 拒绝节点由脚本固定注入，每个成员完全一致，且不属于任何单个成员，
/// 加前缀只会让「直连」策略组变得难读，所以保持原样。
bool _isGeneratedNode(Map<String, dynamic> proxy) {
  final type = proxy['type']?.toString().toLowerCase();
  return type == 'direct' || type == 'reject' || type == 'rematch';
}

/// 只有成员自己的节点才加前缀：脚本注入的内核直连 / 拒绝节点按原样保留。
String _prefixedName(
  Map<String, dynamic> proxy,
  String originalName,
  String prefix,
  BundleMergeOptions options,
) {
  if (prefix.isEmpty || originalName.isEmpty || _isGeneratedNode(proxy)) {
    return originalName;
  }
  return '$prefix${options.prefixSeparator}$originalName';
}

/// 去掉会破坏规则目标与 YAML 可读性的字符。
String _sanitizeName(String name) {
  return name
      .replaceAll(RegExp(r'[\r\n\t]+'), ' ')
      .replaceAll(',', '，')
      .trim();
}

String _allocateName(String name, Set<String> usedNames) {
  final base = name.isEmpty ? '未命名节点' : name;
  if (!_reservedProxyNames.contains(base.toUpperCase()) &&
      usedNames.add(base)) {
    return base;
  }
  var index = 2;
  while (true) {
    final candidate = '$base-$index';
    if (usedNames.add(candidate)) return candidate;
    index++;
  }
}

/// 策略组里的节点引用跟随改名重写；组名引用（如「默认代理」「DIRECT」）不在改名表里，保持原样。
List<String> _remapReferences(dynamic references, Map<String, String> rename) {
  if (references is! List) return const [];
  return [
    for (final item in references)
      if (item != null) rename[item.toString()] ?? item.toString(),
  ];
}

List<String> _unionReferences(List<dynamic> current, List<String> incoming) {
  final result = <String>[];
  final seen = <String>{};
  for (final item in [...current, ...incoming]) {
    final value = item.toString();
    if (seen.add(value)) result.add(value);
  }
  return result;
}

/// 两份 `proxy-server-nameserver-policy` 取值取并集；形状不一致（单值 vs 列表）时
/// 返回 null，由调用方保留先出现的值。
List<String>? _unionDnsValues(dynamic existing, dynamic incoming) {
  if (existing is! List || incoming is! List) return null;
  return _unionReferences(existing, [
    for (final item in incoming)
      if (item != null) item.toString(),
  ]);
}

/// 节点内容指纹：剔除 `name` 后做规范化 JSON 再取 MD5。
String _fingerprint(Map<String, dynamic> proxy) {
  final content = Map<String, dynamic>.from(proxy)..remove('name');
  return md5.convert(utf8.encode(_canonicalJson(content))).toString();
}

String _canonicalJson(dynamic value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return '{${keys.map((key) => '${jsonEncode(key)}:${_canonicalJson(value[key])}').join(',')}}';
  }
  if (value is List) {
    return '[${value.map(_canonicalJson).join(',')}]';
  }
  return jsonEncode(value);
}

Map<String, dynamic>? _stringMap(dynamic value) {
  if (value is! Map) return null;
  return value.map((key, item) => MapEntry(key.toString(), item));
}
