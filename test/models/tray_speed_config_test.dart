import 'dart:convert';

import 'package:bett_box/models/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VpnProps 托盘速率', () {
    test('默认关闭', () {
      expect(const VpnProps().enableTraySpeed, isFalse);
    });

    test('序列化后能够恢复开关状态', () {
      const props = VpnProps(enableTraySpeed: true);

      final restored = VpnProps.fromJson(
        jsonDecode(jsonEncode(props.toJson())) as Map<String, dynamic>,
      );

      expect(restored.enableTraySpeed, isTrue);
    });
  });
}
