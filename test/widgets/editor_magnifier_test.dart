import 'package:bett_box/widgets/code_editor.dart';
import 'package:code_forge/code_forge.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../plugins/code_forge/support.dart';

void main() {
  setUpAll(initEditorNative);

  testWidgets('the magnifier keeps the colors of the whole highlighted line', (
    tester,
  ) async {
    const key = 'name';
    const value = ': "a long quoted value here"';
    final controller = CodeForgeController()
      ..text = '$key$value'
      ..selection = const TextSelection.collapsed(offset: 20);
    addTearDown(controller.dispose);
    const red = Color(0xFFFF0000);
    final info = ValueNotifier(
      const MagnifierInfo(
        globalGesturePosition: Offset(100, 200),
        caretRect: Rect.fromLTWH(100, 190, 2, 20),
        fieldBounds: Rect.fromLTWH(0, 0, 400, 600),
        currentLineBoundaries: Rect.fromLTWH(0, 190, 400, 20),
      ),
    );
    addTearDown(info.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            EditorMagnifier(
              controller: controller,
              magnifierInfo: info,
              textStyle: const TextStyle(fontSize: 14),
              backgroundColor: Colors.white,
              borderColor: Colors.grey,
              caretColor: Colors.blue,
              selectionColor: Colors.green,
              lineSpan: (_, text) => TextSpan(
                children: [
                  TextSpan(text: text.substring(0, key.length)),
                  TextSpan(
                    text: text.substring(key.length),
                    style: const TextStyle(color: red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final rich = tester.widget<RichText>(
      find.descendant(
        of: find.byType(EditorMagnifier),
        matching: find.byType(RichText),
      ),
    );
    final pieces = <(String, Color?)>[];
    rich.text.visitChildren((span) {
      if (span is TextSpan && span.text != null) {
        pieces.add((span.text!, span.style?.color));
      }
      return true;
    });

    expect(
      pieces.map((piece) => piece.$1).join(),
      '$key$value'.substring(10, 30),
    );
    expect(pieces.every((piece) => piece.$2 == red), isTrue);
  });

  testWidgets('the magnifier shades the selection up to the dragged handle', (
    tester,
  ) async {
    final controller = CodeForgeController()
      ..text = 'DOMAIN-SUFFIX,gtzszy.com,cn'
      ..selection = const TextSelection(baseOffset: 10, extentOffset: 21);
    addTearDown(controller.dispose);
    final info = ValueNotifier(
      const MagnifierInfo(
        globalGesturePosition: Offset(200, 200),
        caretRect: Rect.fromLTWH(200, 190, 2, 20),
        fieldBounds: Rect.fromLTWH(0, 0, 400, 600),
        currentLineBoundaries: Rect.fromLTWH(0, 190, 400, 20),
      ),
    );
    addTearDown(info.dispose);
    const shade = Color(0xFF00FF00);

    Future<List<Rect>> shades() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              EditorMagnifier(
                controller: controller,
                magnifierInfo: info,
                textStyle: const TextStyle(fontSize: 14),
                backgroundColor: Colors.white,
                borderColor: Colors.grey,
                caretColor: Colors.blue,
                selectionColor: shade,
              ),
            ],
          ),
        ),
      );
      return [
        for (final element in find.byType(ColoredBox).evaluate())
          if ((element.widget as ColoredBox).color == shade)
            tester.getRect(find.byWidget(element.widget)),
      ];
    }

    final selected = await shades();
    expect(selected, hasLength(1));
    expect(selected.single.right, moreOrLessEquals(201, epsilon: 1));
    expect(selected.single.width, greaterThan(100));

    controller.selection = const TextSelection.collapsed(offset: 21);
    expect(await shades(), isEmpty);
  });
}
