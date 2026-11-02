import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('SegmentButtonGroup 渲染选项并响应切换', (tester) async {
    var selected = 'rule';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SegmentButtonGroup<String>(
                options: const [
                  SegmentOption(value: 'rule', label: '规则'),
                  SegmentOption(value: 'global', label: '全局'),
                  SegmentOption(value: 'direct', label: '直连'),
                ],
                selected: selected,
                onSelected: (val) => setState(() => selected = val),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('规则'), findsOneWidget);
    expect(find.text('全局'), findsOneWidget);
    expect(find.text('直连'), findsOneWidget);

    await tester.tap(find.text('全局'));
    await tester.pumpAndSettle();

    expect(selected, 'global');
  });

  testWidgets('SegmentButtonGroup 支持 maxWidth 约束', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 1000,
              child: SegmentButtonGroup<int>(
                maxWidth: 480,
                options: const [
                  SegmentOption(value: 1, label: '一'),
                  SegmentOption(value: 2, label: '二'),
                ],
                selected: 1,
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final constrainedBoxFinder = find.descendant(
      of: find.byType(SegmentButtonGroup<int>),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is ConstrainedBox &&
            widget.constraints.maxWidth == 480,
      ),
    );
    expect(constrainedBoxFinder, findsOneWidget);
  });
}
