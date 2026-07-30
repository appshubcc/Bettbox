import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/common.dart';
import 'package:bett_box/providers/state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const groups = [
    Group(type: GroupType.Selector, name: 'GLOBAL'),
    Group(type: GroupType.Selector, name: '常用'),
    Group(type: GroupType.Selector, name: '隐藏', hidden: true),
    Group(type: GroupType.Selector, name: '备用'),
  ];

  group('getVisibleGroups', () {
    test('hides hidden groups while preserving original order', () {
      final result = getVisibleGroups(
        mode: Mode.rule,
        groups: groups,
        showHiddenItems: false,
      );

      expect(result.map((group) => group.name), ['常用', '备用']);
    });

    test('shows hidden groups in their original position', () {
      final result = getVisibleGroups(
        mode: Mode.rule,
        groups: groups,
        showHiddenItems: true,
      );

      expect(result.map((group) => group.name), ['常用', '隐藏', '备用']);
    });

    test('keeps global mode filtering consistent', () {
      final hidden = getVisibleGroups(
        mode: Mode.global,
        groups: groups,
        showHiddenItems: false,
      );
      final shown = getVisibleGroups(
        mode: Mode.global,
        groups: groups,
        showHiddenItems: true,
      );

      expect(hidden.map((group) => group.name), ['GLOBAL', '常用', '备用']);
      expect(shown.map((group) => group.name), ['GLOBAL', '常用', '隐藏', '备用']);
    });
  });
}
