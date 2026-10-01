import 'dart:convert';

import 'package:bett_box/common/profile_merger.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Profile 的 bundle 元数据可以 JSON 往返', () {
    final profile = Profile.normal(label: '合并', url: '').copyWith(
      bundle: const BundleConfig(
        members: ['1', '2'],
        memberPrefixes: {'1': '甲', '2': '乙'},
        memberStamps: {'1': '100', '2': '200'},
        scriptStamp: 'stamp-1',
        report: BundleMergeReport(
          memberCount: 2,
          nodeCount: 3,
          duplicateNodeCount: 1,
          dnsPolicyCount: 1,
          groupCount: 4,
          warnings: [BundleMergeWarning('hostConflict', count: 1)],
        ),
      ),
    );

    final restored = Profile.fromJson(
      json.decode(json.encode(profile.toJson())) as Map<String, dynamic>,
    );

    final bundle = restored.bundle!;
    expect(bundle.members, ['1', '2']);
    expect(bundle.memberPrefixes, {'1': '甲', '2': '乙'});
    expect(bundle.memberStamps, {'1': '100', '2': '200'});
    expect(bundle.scriptStamp, 'stamp-1');
    expect(bundle.report!.nodeCount, 3);
    expect(bundle.report!.dnsPolicyCount, 1);
    expect(bundle.report!.groupCount, 4);
    expect(bundle.report!.warnings.single.code, 'hostConflict');
    expect(bundle.report!.warnings.single.count, 1);
  });

  test('旧配置缺少 bundle 字段时解析为 null', () {
    final map =
        json.decode(
              json.encode(
                Profile.normal(label: 'x', url: 'https://example.com').toJson(),
              ),
            )
            as Map<String, dynamic>;
    map.remove('bundle');
    expect(Profile.fromJson(map).bundle, isNull);
  });

  test('成员指纹变化即视为过期', () {
    const bundle = BundleConfig(members: ['1'], memberStamps: {'1': '100'});
    expect(bundle.isStale({'1': '100'}), isFalse);
    expect(bundle.isStale({'1': '101'}), isTrue);
    // 成员被删掉（指纹条目少了一个）
    expect(bundle.isStale(const {}), isTrue);
  });

  test('内置脚本签名变化即视为过期', () {
    const bundle = BundleConfig(
      members: ['1'],
      memberStamps: {'1': '100'},
      scriptStamp: 'script-1',
    );
    expect(bundle.isStale({'1': '100'}, scriptStamp: 'script-1'), isFalse);
    expect(bundle.isStale({'1': '100'}, scriptStamp: 'script-2'), isTrue);
    // 拿不到脚本签名（内置脚本缺失）时不拿它判过期，免得反复重生
    expect(bundle.isStale({'1': '100'}), isFalse);
  });

  test('老数据没有 scriptStamp 时按脚本已改处理', () {
    const bundle = BundleConfig(members: ['1'], memberStamps: {'1': '100'});
    expect(bundle.isStale({'1': '100'}, scriptStamp: 'script-1'), isTrue);
  });
}
