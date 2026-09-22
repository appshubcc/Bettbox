import 'dart:convert';

import 'package:bett_box/models/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSettingProps Dock 图标', () {
    test('默认显示 Dock 图标', () {
      const props = AppSettingProps();

      expect(props.hideDockIcon, isFalse);
    });

    test('序列化后能够恢复隐藏 Dock 图标设置', () {
      const props = AppSettingProps(hideDockIcon: true);

      final restored = AppSettingProps.fromJson(
        jsonDecode(jsonEncode(props.toJson())) as Map<String, dynamic>,
      );

      expect(restored.hideDockIcon, isTrue);
    });

    test('旧版本配置缺少字段时回退为显示 Dock 图标', () {
      const json = {'autoLaunch': true};

      final restored = AppSettingProps.safeFromJson(json);

      expect(restored.hideDockIcon, isFalse);
      expect(restored.autoLaunch, isTrue);
    });
  });
}
