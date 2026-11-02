import 'package:bett_box/views/dashboard/dashboard.dart';
import 'package:bett_box/widgets/grid.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('packGridItems correctly packs half and full width items', () {
    const item1 = GridItem(crossAxisCellCount: 4, child: SizedBox());
    const item2 = GridItem(crossAxisCellCount: 8, child: SizedBox());
    const item3 = GridItem(crossAxisCellCount: 4, child: SizedBox());
    const item4 = GridItem(crossAxisCellCount: 4, child: SizedBox());

    final packed = packGridItems([item1, item2, item3, item4], 8);

    expect(packed, [item1, item3, item2, item4]);
  });

  test('packGridItems preserves order when already packed', () {
    const item1 = GridItem(crossAxisCellCount: 4, child: SizedBox());
    const item2 = GridItem(crossAxisCellCount: 4, child: SizedBox());
    const item3 = GridItem(crossAxisCellCount: 8, child: SizedBox());

    final packed = packGridItems([item1, item2, item3], 8);

    expect(packed, [item1, item2, item3]);
  });

  test(
    'packGridItems handles single half width with only full width remaining',
    () {
      const item1 = GridItem(crossAxisCellCount: 4, child: SizedBox());
      const item2 = GridItem(crossAxisCellCount: 8, child: SizedBox());
      const item3 = GridItem(crossAxisCellCount: 8, child: SizedBox());

      final packed = packGridItems([item1, item2, item3], 8);

      expect(packed, [item1, item2, item3]);
    },
  );

  test('packGridItems handles empty list', () {
    expect(packGridItems([], 8), isEmpty);
  });
}
