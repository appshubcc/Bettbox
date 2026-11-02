import 'package:bett_box/models/common.dart';
import 'package:bett_box/widgets/code_editor.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<OverlayEntry> showToolbar(
    WidgetTester tester, {
    required List<PopupMenuItemData> items,
    required VoidCallback onDismiss,
    required GestureDragUpdateCallback onDrag,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: onDrag,
          child: const SizedBox.expand(),
        ),
      ),
    );
    final entry = OverlayEntry(
      builder: (_) => EditorSelectionToolbar(
        anchorAbove: const Offset(200, 300),
        anchorBelow: const Offset(200, 320),
        items: items,
        backgroundColor: Colors.white,
        onDismiss: onDismiss,
      ),
    );
    tester.state<NavigatorState>(find.byType(Navigator)).overlay?.insert(entry);
    await tester.pump();
    return entry;
  }

  testWidgets(
    'a drag outside the toolbar reaches the editor and dismisses it',
    (tester) async {
      var dismissed = 0;
      var dragged = false;
      final entry = await showToolbar(
        tester,
        items: [PopupMenuItemData(label: 'Copy', onPressed: () {})],
        onDismiss: () => dismissed++,
        onDrag: (_) => dragged = true,
      );
      addTearDown(entry.remove);

      await tester.dragFrom(const Offset(100, 500), const Offset(60, 40));

      expect(dragged, isTrue);
      expect(dismissed, 1);
    },
  );

  testWidgets('an item dismisses the toolbar before running its action', (
    tester,
  ) async {
    final calls = <String>[];
    final entry = await showToolbar(
      tester,
      items: [
        PopupMenuItemData(
          icon: Icons.copy,
          label: 'Copy',
          onPressed: () => calls.add('copy'),
        ),
      ],
      onDismiss: () => calls.add('dismiss'),
      onDrag: (_) {},
    );
    addTearDown(entry.remove);

    await tester.tap(find.text('Copy'));

    expect(calls, ['dismiss', 'copy']);
  });
}
