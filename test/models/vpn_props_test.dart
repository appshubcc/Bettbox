import 'dart:convert';

import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VpnProps 托盘点击行为', () {
    test('默认左键显示面板、右键显示菜单', () {
      const props = VpnProps();

      expect(props.trayLeftClickBehavior, TrayClickBehavior.showPanel);
      expect(props.trayRightClickBehavior, TrayClickBehavior.showMenu);
    });

    test('序列化后能够独立恢复左右键设置', () {
      const props = VpnProps(
        trayLeftClickBehavior: TrayClickBehavior.showMenu,
        trayRightClickBehavior: TrayClickBehavior.showPanel,
      );

      final restored = VpnProps.fromJson(
        jsonDecode(jsonEncode(props.toJson())) as Map<String, dynamic>,
      );

      expect(restored.trayLeftClickBehavior, TrayClickBehavior.showMenu);
      expect(restored.trayRightClickBehavior, TrayClickBehavior.showPanel);
    });
  });
}
