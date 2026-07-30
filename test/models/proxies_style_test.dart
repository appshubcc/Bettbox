import 'package:bett_box/models/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProxiesStyle hidden items', () {
    test('defaults to hiding hidden items', () {
      final style = ProxiesStyle.fromJson({});

      expect(style.showHiddenItems, isFalse);
    });

    test('persists showing hidden items', () {
      const style = ProxiesStyle(showHiddenItems: true);
      final json = style.toJson();

      expect(json['showHiddenItems'], isTrue);
      expect(ProxiesStyle.fromJson(json).showHiddenItems, isTrue);
    });
  });
}
