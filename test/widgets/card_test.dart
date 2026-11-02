import 'package:bett_box/widgets/card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('卡片描边用单次圆角描线绘制且贴在卡片内侧', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 200,
            height: 80,
            child: CommonCard(
              elevated: false,
              onPressed: () {},
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final material = find.descendant(
      of: find.byType(CommonCard),
      matching: find.byType(Material),
    );
    expect(material, isNot(paints..drrect()));
    expect(
      material,
      paints..rsuperellipse(
        rsuperellipse: RSuperellipse.fromRectAndRadius(
          const Rect.fromLTWH(0.5, 0.5, 199, 79),
          const Radius.circular(23.5),
        ),
        strokeWidth: 1,
      ),
    );
  });
}
