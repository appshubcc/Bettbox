import 'package:bett_box/common/profile_merger.dart';

/// 合并配置（bundle）的元数据。
///
/// 挂在 [Profile] 上：成员列表、每个成员自己的节点前缀、上次生成时的
/// 成员文件指纹与内置脚本签名快照，以及结果报告。
/// 成员文件、成员名称或内置脚本一旦变化（比对 [memberStamps] / [scriptStamp]）
/// 就说明这份合并配置已过期，需要重新生成。
class BundleConfig {
  const BundleConfig({
    this.members = const [],
    this.memberPrefixes = const {},
    this.memberStamps = const {},
    this.scriptStamp,
    this.report,
  });

  /// 成员 profile id，顺序即去重与命名优先级。
  final List<String> members;

  /// 成员 id -> 该成员自己的节点前缀；没有条目或值为空表示用成员名称。
  final Map<String, String> memberPrefixes;

  /// 成员 id -> 生成时的 profile 文件指纹。
  final Map<String, String> memberStamps;

  /// 生成时内置脚本（内容 + 自定义开关）的签名；对不上说明脚本改过，产物要重新生成。
  final String? scriptStamp;

  /// 上次生成的结果报告。
  final BundleMergeReport? report;

  BundleConfig copyWith({
    List<String>? members,
    Map<String, String>? memberPrefixes,
    Map<String, String>? memberStamps,
    String? scriptStamp,
    BundleMergeReport? report,
  }) {
    return BundleConfig(
      members: members ?? this.members,
      memberPrefixes: memberPrefixes ?? this.memberPrefixes,
      memberStamps: memberStamps ?? this.memberStamps,
      scriptStamp: scriptStamp ?? this.scriptStamp,
      report: report ?? this.report,
    );
  }

  /// [currentStamps] 与生成时的成员指纹、[scriptStamp] 与生成时的脚本签名：
  /// 任一不一致即为过期。
  ///
  /// [scriptStamp] 传 null 表示当前拿不到脚本签名（例如内置脚本缺失），
  /// 这时不拿它判过期，避免反复重生。
  bool isStale(Map<String, String> currentStamps, {String? scriptStamp}) {
    if (members.length != currentStamps.length) return true;
    if (scriptStamp != null && this.scriptStamp != scriptStamp) return true;
    for (final entry in currentStamps.entries) {
      if (memberStamps[entry.key] != entry.value) return true;
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
    'members': members,
    if (memberPrefixes.isNotEmpty) 'memberPrefixes': memberPrefixes,
    'memberStamps': memberStamps,
    if (scriptStamp != null) 'scriptStamp': scriptStamp,
    if (report != null) 'report': report!.toJson(),
  };

  factory BundleConfig.fromJson(Map<String, dynamic> json) {
    return BundleConfig(
      members:
          (json['members'] as List? ?? const []).map((e) => e.toString()).toList(),
      memberPrefixes: (json['memberPrefixes'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ) ??
          const {},
      memberStamps: (json['memberStamps'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ) ??
          const {},
      scriptStamp: json['scriptStamp'] as String?,
      report: json['report'] is Map
          ? BundleMergeReport.fromJson(
              (json['report'] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }
}
