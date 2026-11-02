import 'dart:convert';

import 'package:bett_box/common/constant.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/config.dart';
import 'package:bett_box/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProxiesStyle 自定义样式标记与序列化', () {
    test('默认情况下 hasCustomizedStyle 为 false', () {
      const style = ProxiesStyle();

      expect(style.type, ProxiesType.tab);
      expect(style.iconStyle, ProxiesIconStyle.none);
      expect(style.hasCustomizedStyle, isFalse);
    });

    test('序列化后能够正确恢复 hasCustomizedStyle 状态', () {
      const style = ProxiesStyle(
        type: ProxiesType.list,
        iconStyle: ProxiesIconStyle.icon,
        hasCustomizedStyle: true,
      );

      final restored = ProxiesStyle.fromJson(
        jsonDecode(jsonEncode(style.toJson())) as Map<String, dynamic>,
      );

      expect(restored.type, ProxiesType.list);
      expect(restored.iconStyle, ProxiesIconStyle.icon);
      expect(restored.hasCustomizedStyle, isTrue);
    });

    test('从没有 hasCustomizedStyle 字段的旧 JSON 反序列化时默认为 false', () {
      final oldJson = {'type': 'tab', 'iconStyle': 'none'};

      final restored = ProxiesStyle.fromJson(oldJson);

      expect(restored.hasCustomizedStyle, isFalse);
    });
  });

  test('并发限制默认 MAX，旧版大于 32 的取值迁移为 MAX', () {
    expect(const ProxiesStyle().concurrencyLimit, maxDelayTestConcurrency);
    for (final (saved, expected) in [
      (250, maxDelayTestConcurrency),
      (64, maxDelayTestConcurrency),
      (32, 32),
      (8, 8),
      (2, 2),
      (0, 1),
    ]) {
      expect(
        ProxiesStyle.fromJson({'concurrencyLimit': saved}).concurrencyLimit,
        expected,
      );
    }
  });

  test('托管样式首次标记默认为 false 且可序列化恢复', () {
    final profile = Profile.fromJson({'id': '1', 'autoUpdateDuration': 0});
    expect(profile.managedStyleApplied, isFalse);

    final restored = Profile.fromJson(
      jsonDecode(jsonEncode(profile.copyWith(managedStyleApplied: true)))
          as Map<String, dynamic>,
    );
    expect(restored.managedStyleApplied, isTrue);
  });
}
