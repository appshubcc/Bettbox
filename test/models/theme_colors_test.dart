import 'dart:convert';

import 'package:bett_box/common/constant.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/config.dart';
import 'package:flutter_test/flutter_test.dart';

Config _restore(ThemeProps themeProps) {
  final json = jsonDecode(
    jsonEncode(Config(themeProps: themeProps).toJson()),
  ) as Map<String, Object?>;
  return Config.compatibleFromJson(json);
}

void main() {
  group('预设主题色', () {
    test('新增颜色不重复且保留原有顺序', () {
      expect(defaultPrimaryColors.toSet().length, defaultPrimaryColors.length);
      expect(defaultPrimaryColors.length, 11);
      expect(defaultPrimaryColors.take(6), legacyPrimaryColors.take(6));
    });

    test('未改动过的旧预设升级为新预设', () {
      final config = _restore(
        ThemeProps(
          primaryColor: defaultPrimaryColor,
          primaryColors: legacyPrimaryColors,
        ),
      );

      expect(config.themeProps.primaryColors, defaultPrimaryColors);
      expect(config.themeProps.primaryColor, defaultPrimaryColor);
    });

    test('旧 schemeVariant 值可以兼容读取', () {
      expect(
        ThemeProps.fromJson(const {'schemeVariant': 'vibrant'}).schemeVariant,
        ThemeSchemeVariant.vibrant,
      );
      expect(
        ThemeProps.fromJson(const {'schemeVariant': 'cmf'}).schemeVariant,
        ThemeSchemeVariant.cmf,
      );
      expect(
        ThemeProps.fromJson(const {}).schemeVariant,
        ThemeSchemeVariant.content,
      );
    });

    test('颜色规范默认为 2021，且可以持久化切换', () {
      expect(
        ThemeProps.fromJson(const {}).colorSpecVersion,
        ColorSpecVersion.spec2021,
      );
      expect(
        ThemeProps.fromJson(const {'colorSpecVersion': 'spec2025'})
            .colorSpecVersion,
        ColorSpecVersion.spec2025,
      );
      expect(
        _restore(const ThemeProps(colorSpecVersion: ColorSpecVersion.spec2025))
            .themeProps
            .colorSpecVersion,
        ColorSpecVersion.spec2025,
      );
    });

    test('自定义过的列表和正在使用被替换颜色的配置保持不变', () {
      const custom = [0xFF1E293B, 0xFF123456];
      expect(
        _restore(ThemeProps(primaryColor: custom.last, primaryColors: custom))
            .themeProps
            .primaryColors,
        custom,
      );
      expect(
        _restore(
          ThemeProps(
            primaryColor: legacyPrimaryColors.last,
            primaryColors: legacyPrimaryColors,
          ),
        ).themeProps.primaryColors,
        legacyPrimaryColors,
      );
    });
  });
}
