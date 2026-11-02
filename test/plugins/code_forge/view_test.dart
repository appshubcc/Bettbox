import 'dart:ui' as ui;

import 'package:code_forge/code_forge.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

import 'support.dart';

void main() {
  setUpAll(initEditorNative);
  group('lifecycle', _lifecycle);
  group('caret scroll', _caretScroll);
  group('hit test', _hitTest);
  group('multi touch', _multiTouch);
  group('folding', _folding);
  group('theme', _theme);
  group('painting', _painting);
}

void _lifecycle() {
  testWidgets('mounting the editor keeps another field as the input client', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a: 1';
    final title = TextEditingController();
    final showEditor = ValueNotifier(false);
    addTearDown(title.dispose);
    addTearDown(showEditor.dispose);
    await pumpEditor(
      tester,
      controller,
      wrap: (editor) => Column(
        children: [
          TextField(controller: title),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: showEditor,
              builder: (_, show, _) => show ? editor : const SizedBox(),
            ),
          ),
        ],
      ),
    );
    await tester.showKeyboard(find.byType(TextField));

    showEditor.value = true;
    await settle(tester);
    tester.testTextInput.enterText('title');
    await tester.pump();

    expect(title.text, 'title');
    expect(controller.text, 'a: 1');
  });

  testWidgets('toggling read-only applies to the mounted editor', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a: 1';
    await pumpEditor(tester, controller, readOnly: true);
    await focusEditor(tester);
    expect(controller.readOnly, isTrue);

    await pumpEditor(tester, controller);
    expect(controller.readOnly, isFalse);
    controller.selection = TextSelection.collapsed(offset: controller.length);
    await typeText(tester, controller, '2');
    expect(controller.text, 'a: 12');

    await pumpEditor(tester, controller, readOnly: true);
    expect(controller.readOnly, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await settle(tester, 2);
    expect(controller.text, 'a: 12');
  });

  testWidgets('a disposed editor lets go of the controller', (tester) async {
    final controller = CodeForgeController()..text = 'a: 1';
    await pumpEditor(tester, controller, key: const ValueKey(1));
    await focusEditor(tester);
    final firstNode = controller.focusNode;

    await pumpEditor(tester, controller, key: const ValueKey(2));
    expect(controller.focusNode, isNot(same(firstNode)));
    expect(controller.focusNode?.context, isNotNull);
    expect(controller.undoController, isNotNull);

    await tester.pumpWidget(const SizedBox());
    expect(controller.focusNode, isNull);
    expect(controller.connection, isNull);
    expect(controller.undoController, isNull);
    controller.replaceRange(0, 0, '# ');
    expect(controller.text, '# a: 1');
  });

  group('a composition in progress', () {
    Future<CodeForgeController> compose(WidgetTester tester, {Key? key}) async {
      final controller = CodeForgeController()..text = 'ab';
      await pumpEditor(tester, controller, key: key);
      await focusEditor(tester);
      controller.selection = const TextSelection.collapsed(offset: 1);
      await tester.pump();
      final value = controller.currentTextEditingValue;
      await sendDeltas(tester, [
        {
          ...textDelta(value.text, 'n', 1, 1),
          'composingBase': 1,
          'composingExtent': 2,
        },
      ]);
      expect(controller.isComposingActive, isTrue);
      return controller;
    }

    testWidgets('is committed when the editor turns read-only', (tester) async {
      final controller = await compose(tester);

      await pumpEditor(tester, controller, readOnly: true);
      expect(controller.imeComposition, isNull);
      expect(controller.text, 'anb');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(controller.selection, const TextSelection.collapsed(offset: 3));
      await settle(tester, 2);
    });

    testWidgets('is committed when the editor is disposed', (tester) async {
      final controller = await compose(tester);

      await tester.pumpWidget(const SizedBox());
      expect(controller.imeComposition, isNull);
      expect(controller.text, 'anb');
    });

    testWidgets('is committed when the editor is re-keyed', (tester) async {
      final controller = await compose(tester, key: const ValueKey(1));

      await pumpEditor(tester, controller, key: const ValueKey(2));
      expect(controller.imeComposition, isNull);
      expect(controller.text, 'anb');
    });
  });

  testWidgets('a new controller takes over the mounted editor', (tester) async {
    final first = CodeForgeController()..text = 'first: 1';
    final second = CodeForgeController()
      ..text = 'b: 2'
      ..selection = const TextSelection.collapsed(offset: 0);
    await pumpEditor(tester, first);
    await focusEditor(tester);

    await pumpEditor(tester, second);
    expect(first.focusNode, isNull);
    expect(first.connection, isNull);
    expect(first.undoController, isNull);

    await focusEditor(tester);
    expect(second.selection, const TextSelection.collapsed(offset: 4));
    await typeText(tester, second, '3');
    expect(second.text, 'b: 23');
    expect(first.text, 'first: 1');
    expect(second.undoController!.undo(), isTrue);
    expect(second.text, 'b: 2');
  });

  testWidgets('new undo and find controllers take over the mounted editor', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a: 1';
    final undos = [UndoRedoController(), UndoRedoController()];
    final finders = [FindController(controller), FindController(controller)];
    for (final undo in undos) {
      addTearDown(undo.dispose);
    }
    for (final finder in finders) {
      addTearDown(finder.dispose);
    }
    Future<void> pump(int index) => pumpEditor(
      tester,
      controller,
      undoController: undos[index],
      findController: finders[index],
    );
    await pump(0);
    await focusEditor(tester);
    await typeText(tester, controller, '2');

    await pump(1);
    expect(controller.undoController, same(undos[1]));
    await typeText(tester, controller, '3');
    expect(undos[1].canUndo, isTrue);
    expect(undos[0].undo(), isFalse);
    expect(controller.text, 'a: 123');

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(finders[1].isActive, isTrue);
    expect(finders[0].isActive, isFalse);
    await settle(tester, 2);
  });

  testWidgets('a released undo controller leaves the document alone', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a: 1';
    final undo = UndoRedoController();
    addTearDown(undo.dispose);
    await pumpEditor(tester, controller, undoController: undo);
    await focusEditor(tester);
    await typeText(tester, controller, '2');
    expect(undo.canUndo, isTrue);

    await tester.pumpWidget(const SizedBox());
    expect(undo.undo(), isFalse);
    expect(undo.canUndo, isTrue);
    expect(controller.text, 'a: 12');
  });

  testWidgets('a re-keyed editor keeps the undo controller it shares', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a: 1';
    final undo = UndoRedoController();
    addTearDown(undo.dispose);
    Future<void> pump(int key) => pumpEditor(
      tester,
      controller,
      undoController: undo,
      key: ValueKey(key),
    );
    await pump(1);
    await focusEditor(tester);
    await typeText(tester, controller, '2');

    await pump(2);
    expect(controller.undoController, same(undo));
    expect(undo.undo(), isTrue);
    expect(controller.text, 'a: 1');
  });

  test('a history another controller took over survives the first', () {
    final undo = UndoRedoController();
    addTearDown(undo.dispose);
    final first = CodeForgeController()..setUndoController(undo);
    final second = CodeForgeController()..text = 'b';
    addTearDown(second.dispose);
    second.setUndoController(undo);

    first.dispose();
    second.replaceRange(1, 1, 'x');

    expect(undo.undo(), isTrue);
    expect(second.text, 'b');
  });

  test('dispose releases the rope and the undo controller', () {
    final controller = CodeForgeController()..text = 'a: 1';
    final undo = UndoRedoController();
    controller
      ..setUndoController(undo)
      ..replaceRange(0, 0, '# ')
      ..dispose();

    expect(controller.rope.core.isDisposed, isTrue);
    expect(undo.undo(), isFalse);
  });

  test('dispose releases the suggestion notifiers', () {
    final controller = CodeForgeController()..text = 'a: 1';
    controller.dispose();
    expect(
      () => controller.suggestionsNotifier.addListener(() {}),
      throwsFlutterError,
    );
    expect(
      () => controller.selectedSuggestionNotifier.addListener(() {}),
      throwsFlutterError,
    );
  });

  test('replacing the text releases the previous rope', () {
    final controller = CodeForgeController()..text = 'a: 1';
    final previous = controller.rope;
    controller.text = 'b: 2';
    expect(previous.core.isDisposed, isTrue);
    expect(controller.rope.core.isDisposed, isFalse);
  });

  testWidgets('disposing the editor mid scroll to a line throws nothing', (
    tester,
  ) async {
    final controller = CodeForgeController()
      ..text = [for (var i = 0; i < 400; i++) 'k$i: $i'].join('\n');
    await pumpEditor(tester, controller);

    controller.scrollToLine(300);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
  });

  testWidgets('disposing the editor while it computes folds reports no error', (
    tester,
  ) async {
    final controller = CodeForgeController()
      ..text = [for (var i = 0; i < 12000; i++) 'k$i: {a: $i}'].join('\n');
    final printed = <String?>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) => printed.add(message);
    try {
      await pumpEditor(tester, controller);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpWidget(const SizedBox());
      await settle(tester);
    } finally {
      debugPrint = original;
    }

    expect(printed, isEmpty);
  });
}

const _glyphWidth = 16.0;
const _gutterWidth = 41.6;

void _caretScroll() {
  testWidgets('the caret scrolls into view clear of the initial padding', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const padding = EdgeInsets.only(right: 100, bottom: 100);
    late ScrollController vertical;
    final controller = CodeForgeController()
      ..text = [for (var i = 0; i < 40; i++) 'a' * 60].join('\n');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CodeForge(
            controller: controller,
            language: editorYamlMode,
            editorTheme: atomOneLightTheme,
            textStyle: const TextStyle(
              fontSize: 16,
              height: editorLineHeight / 16,
            ),
            innerPadding: padding,
            onContextMenu: (_, _) {},
            suggestionPopupBuilder: (_, _) => const SizedBox.shrink(),
            scrollbarBuilder: (_, details, child) {
              vertical = details.controller;
              return child;
            },
          ),
        ),
      ),
    );
    await settle(tester);

    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(30) + 60,
    );
    await settle(tester);

    final horizontal = tester
        .widget<RawScrollbar>(find.byType(RawScrollbar))
        .controller!;
    final caretX = _gutterWidth + 60 * _glyphWidth - horizontal.offset;
    final caretBottom = 31 * editorLineHeight - vertical.offset;
    expect(caretX, lessThanOrEqualTo(400 - padding.right));
    expect(caretBottom, lessThanOrEqualTo(300 - padding.bottom));
    expect(caretX, greaterThan(400 - padding.right - _glyphWidth));
    expect(caretBottom, greaterThan(300 - padding.bottom - editorLineHeight));
  });

  testWidgets('the view follows a caret the input method moves', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a' * 100;
    await pumpEditor(tester, controller, size: const Size(400, 300));
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 0);
    await settle(tester, 2);
    final horizontal = tester
        .widget<RawScrollbar>(find.byType(RawScrollbar))
        .controller!;
    expect(horizontal.offset, 0);

    await sendDeltas(tester, [
      {
        ...textDelta(controller.currentTextEditingValue.text, '', -1, -1),
        'selectionBase': 80,
        'selectionExtent': 80,
      },
    ]);
    await settle(tester, 2);

    expect(controller.selection, const TextSelection.collapsed(offset: 80));
    final caretX = _gutterWidth + 80 * _glyphWidth - horizontal.offset;
    expect(caretX, lessThanOrEqualTo(400));
  });

  testWidgets('the view follows the caret to the end of a pasted line wider '
      'than it', (tester) async {
    final clipboard = mockClipboard(tester)..text = 'b' * 100;
    final controller = CodeForgeController()..text = 'a\n\na';
    await pumpEditor(tester, controller, size: const Size(400, 300));
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 2);
    await settle(tester, 2);
    final horizontal = tester
        .widget<RawScrollbar>(find.byType(RawScrollbar))
        .controller!;

    await tester.runAsync(controller.paste);
    await settle(tester);

    expect(controller.getLineText(1), clipboard.text);
    final caretX = _gutterWidth + 100 * _glyphWidth - horizontal.offset;
    expect(caretX, lessThanOrEqualTo(400));
    expect(caretX, greaterThan(400 - 2 * _glyphWidth));
  });

  testWidgets('a long line far below the first screen widens the content '
      'once scrolled to', (tester) async {
    late ScrollController vertical;
    final controller = CodeForgeController()
      ..text = [
        for (var i = 0; i < 200; i++) i == 150 ? 'b' * 100 : 'a',
      ].join('\n');
    await pumpEditor(
      tester,
      controller,
      size: const Size(400, 300),
      scrollbarBuilder: (_, details, child) {
        vertical = details.controller;
        return child;
      },
    );
    final horizontal = tester
        .widget<RawScrollbar>(find.byType(RawScrollbar))
        .controller!;
    expect(horizontal.position.maxScrollExtent, 0);

    vertical.jumpTo(140 * editorLineHeight);
    await settle(tester, 2);

    expect(
      horizontal.position.maxScrollExtent,
      greaterThanOrEqualTo(_gutterWidth + 100 * _glyphWidth - 400),
    );
  });

  testWidgets('reaching the end of a long wrapped text keeps its extent', (
    tester,
  ) async {
    late ScrollController vertical;
    final controller = CodeForgeController()
      ..text = [
        for (var i = 0; i < 1000; i++) i < 900 ? 'a' : 'b' * 100,
      ].join('\n');
    await pumpEditor(
      tester,
      controller,
      lineWrap: true,
      size: const Size(400, 300),
      scrollbarBuilder: (_, details, child) {
        vertical = details.controller;
        return child;
      },
    );
    final extent = vertical.position.maxScrollExtent;

    vertical.jumpTo(extent);
    await settle(tester, 2);

    expect(vertical.position.maxScrollExtent, extent);
    expect(vertical.offset, extent);
  });
}

// Ten lines, so inserting two keeps two-digit line numbers: a wider gutter
// would narrow the wrap width and change every row count.
final _lines = [
  'root:',
  '  a: ${'x' * 120}',
  '  b: {',
  '    c: 1',
  '    d: 2',
  '  }',
  '  e: ${'y' * 60}',
  'f: 1',
  'g: 2',
  'end: true',
];

const _viewSize = Size(400, 1200);
const _textX = 300.0;

// Taps below the document also land on its last line, so the scan stops at
// the first hit on it and every fixture keeps its last line a single row.
typedef _Row = ({int line, int offset});

Future<List<_Row>> _tapEveryRow(
  WidgetTester tester,
  CodeForgeController controller,
) async {
  final rows = <_Row>[];
  final origin = tester.getTopLeft(find.byType(CodeForge));
  for (
    var y = editorTopPadding + editorLineHeight / 2;
    y < _viewSize.height - editorLineHeight;
    y += editorLineHeight
  ) {
    await tester.tapAt(origin + Offset(_textX, y));
    await tester.pump(const Duration(milliseconds: 500));
    final offset = controller.selection.extentOffset;
    rows.add((line: controller.getLineAtOffset(offset), offset: offset));
  }
  final lastLine = rows.indexWhere(
    (row) => row.line == controller.lineCount - 1,
  );
  expect(lastLine, isNonNegative, reason: 'the document fits the view');
  return rows.sublist(0, lastLine + 1);
}

Map<int, List<int>> _rowsByLine(List<_Row> rows) {
  final byLine = <int, List<int>>{};
  for (final row in rows) {
    byLine.putIfAbsent(row.line, () => []).add(row.offset);
  }
  return byLine;
}

void _expectContiguous(List<_Row> rows, List<int> visibleLines) {
  final order = <int>[];
  for (final row in rows) {
    if (order.isEmpty || order.last != row.line) order.add(row.line);
  }
  expect(order, visibleLines, reason: 'lines hit from top to bottom');
}

// With a 16px font and two-digit line numbers the last 24px of the gutter hold
// the fold icons.
const _gutterWidthHitTest = 51.2;
const _lineNumberX = 12.0;
const _foldIconX = 40.0;

Offset _gutterAt(
  WidgetTester tester,
  List<_Row> rows,
  int line, {
  int row = 0,
  double x = _lineNumberX,
}) {
  final index = rows.indexWhere((r) => r.line == line) + row;
  return tester.getTopLeft(find.byType(CodeForge)) +
      Offset(x, editorTopPadding + editorLineHeight * (index + 0.5));
}

TextSelection _lineSelection(
  CodeForgeController controller,
  int from,
  int to,
) => TextSelection(
  baseOffset: controller.getLineStartOffset(from),
  extentOffset: to < controller.lineCount
      ? controller.getLineStartOffset(to)
      : controller.length,
);

void _hitTest() {
  Future<CodeForgeController> pumpWrapped(WidgetTester tester) async {
    final controller = CodeForgeController()..text = _lines.join('\n');
    await pumpEditor(tester, controller, lineWrap: true, size: _viewSize);
    return controller;
  }

  testWidgets('taps land on the wrapped line painted at that height', (
    tester,
  ) async {
    final controller = await pumpWrapped(tester);

    final rows = await _tapEveryRow(tester, controller);
    _expectContiguous(rows, List.generate(_lines.length, (i) => i));

    final byLine = _rowsByLine(rows);
    for (final line in [0, 2, 3, 4, 5, 7, 8, 9]) {
      expect(byLine[line], hasLength(1), reason: 'line $line is one row');
    }
    final longRows = byLine[1]!.length;
    final shorterRows = byLine[6]!.length;
    expect(shorterRows, greaterThan(1));
    expect(longRows, greaterThan(shorterRows));
    for (final line in [1, 6]) {
      final offsets = byLine[line]!;
      for (var i = 1; i < offsets.length; i++) {
        expect(
          offsets[i],
          greaterThan(offsets[i - 1]),
          reason: 'row $i of line $line maps further into the line',
        );
      }
    }
  });

  testWidgets('a folded block takes no rows and taps skip it', (tester) async {
    final controller = await pumpWrapped(tester);
    final unfolded = await _tapEveryRow(tester, controller);

    controller.toggleFold(2);
    await settle(tester);
    expect(controller.isLineInFoldedRegion(3), isTrue);
    expect(controller.isLineInFoldedRegion(5), isTrue);
    expect(controller.isLineInFoldedRegion(6), isFalse);

    final folded = await _tapEveryRow(tester, controller);
    _expectContiguous(folded, [0, 1, 2, 6, 7, 8, 9]);
    expect(folded, hasLength(unfolded.length - 3));
    expect(_rowsByLine(folded)[6], hasLength(_rowsByLine(unfolded)[6]!.length));
  });

  testWidgets('taps track lines inserted above a fold', (tester) async {
    final controller = await pumpWrapped(tester);
    controller.toggleFold(2);
    await settle(tester);
    final before = await _tapEveryRow(tester, controller);

    controller.replaceRange(0, 0, 'first: 1\nsecond: 2\n');
    await settle(tester);
    expect(controller.lineCount, _lines.length + 2);
    expect(controller.isLineInFoldedRegion(5), isTrue);
    expect(controller.isLineInFoldedRegion(8), isFalse);

    final after = await _tapEveryRow(tester, controller);
    _expectContiguous(after, [0, 1, 2, 3, 4, 8, 9, 10, 11]);
    expect(after, hasLength(before.length + 2));
    expect(
      [for (final row in after.skip(2)) row.line - 2],
      [for (final row in before) row.line],
    );
  });

  testWidgets('tapping the fold icon folds and unfolds a block', (
    tester,
  ) async {
    final controller = await pumpWrapped(tester);
    final text = controller.text;
    final unfolded = await _tapEveryRow(tester, controller);
    final gutterTap = _gutterAt(tester, unfolded, 2, x: _foldIconX);

    await tester.tapAt(gutterTap);
    await settle(tester);
    expect(controller.isLineInFoldedRegion(3), isTrue);
    expect(visibleText(controller), isNot(contains('    c: 1')));
    expect(controller.text, text);

    await tester.tapAt(gutterTap);
    await settle(tester);
    expect(controller.isLineInFoldedRegion(3), isFalse);
    expect(visibleText(controller), text);
    _expectContiguous(
      await _tapEveryRow(tester, controller),
      List.generate(_lines.length, (i) => i),
    );
  });

  testWidgets('tapping the ellipsis of a folded block unfolds it', (
    tester,
  ) async {
    final controller = await pumpWrapped(tester);
    final text = controller.text;
    final unfolded = await _tapEveryRow(tester, controller);
    await tester.tapAt(_gutterAt(tester, unfolded, 2, x: _foldIconX));
    await settle(tester);
    expect(controller.isLineInFoldedRegion(3), isTrue);

    final lineEnd = (TextPainter(
      text: TextSpan(text: _lines[2], style: const TextStyle(fontSize: 16)),
      textDirection: TextDirection.ltr,
    )..layout()).width;
    final row = _gutterAt(tester, unfolded, 2);
    const textLeft = _gutterWidthHitTest - _lineNumberX;

    await tester.tapAt(row + Offset(textLeft + lineEnd + 120, 0));
    await settle(tester);
    expect(controller.isLineInFoldedRegion(3), isTrue);

    controller.suggestionsNotifier.value = const [
      CodeForgeSuggestion(label: 'root'),
    ];
    await tester.tapAt(row + Offset(textLeft + lineEnd + 24, 0));
    await settle(tester);
    expect(controller.isLineInFoldedRegion(3), isFalse);
    expect(visibleText(controller), text);
    expect(controller.suggestionsNotifier.value, isNull);
  });

  testWidgets('replacing the whole text resets lines, folds and the caret', (
    tester,
  ) async {
    final replacement = [
      'other:',
      '  z: ${'q' * 90}',
      '  list: [',
      '    1,',
      '    2,',
      '  ]',
      for (var i = 0; i < 5; i++) '  k$i: $i',
      'last: ${'w' * 150}',
      'end: 1',
    ].join('\n');
    final fresh = CodeForgeController()..text = replacement;
    await pumpEditor(tester, fresh, lineWrap: true, size: _viewSize);
    final expected = await _tapEveryRow(tester, fresh);
    _expectContiguous(expected, List.generate(13, (i) => i));
    await tester.pumpWidget(const SizedBox());

    final controller = await pumpWrapped(tester);
    controller.toggleFold(2);
    await settle(tester);
    expect(controller.isLineInFoldedRegion(3), isTrue);

    controller.text = replacement;
    await settle(tester);
    expect(controller.lineCount, 13);
    expect(
      controller.selection,
      TextSelection.collapsed(offset: controller.length),
    );
    expect(controller.foldings, isEmpty);
    expect(controller.isLineInFoldedRegion(3), isFalse);
    expect(await _tapEveryRow(tester, controller), expected);

    controller.toggleFold(2);
    await settle(tester);
    expect(controller.isLineInFoldedRegion(4), isTrue);
    expect(controller.isLineInFoldedRegion(6), isFalse);
  });

  testWidgets('clicking a line number selects the whole line', (tester) async {
    final controller = await pumpWrapped(tester);
    final rows = await _tapEveryRow(tester, controller);

    await tester.tapAt(_gutterAt(tester, rows, 3));
    await settle(tester, 2);
    expect(controller.selection, _lineSelection(controller, 3, 4));

    await tester.tapAt(_gutterAt(tester, rows, 2));
    await settle(tester, 2);
    expect(controller.selection, _lineSelection(controller, 2, 3));
    expect(controller.isLineInFoldedRegion(3), isFalse);
  });

  testWidgets('a line number selects every row of a wrapped line', (
    tester,
  ) async {
    final controller = await pumpWrapped(tester);
    final rows = await _tapEveryRow(tester, controller);
    expect(_rowsByLine(rows)[1]!.length, greaterThan(1));

    await tester.tapAt(_gutterAt(tester, rows, 1, row: 1));
    await settle(tester, 2);
    expect(controller.selection, _lineSelection(controller, 1, 2));
  });

  testWidgets('a folded block is selected whole from its line number', (
    tester,
  ) async {
    final controller = await pumpWrapped(tester);
    controller.toggleFold(2);
    await settle(tester);
    final rows = await _tapEveryRow(tester, controller);

    await tester.tapAt(_gutterAt(tester, rows, 2));
    await settle(tester, 2);
    expect(controller.selection, _lineSelection(controller, 2, 6));
    expect(controller.isLineInFoldedRegion(3), isTrue);
  });

  testWidgets('dragging over line numbers extends by whole lines', (
    tester,
  ) async {
    final controller = await pumpWrapped(tester);
    final rows = await _tapEveryRow(tester, controller);

    final down = await tester.startGesture(_gutterAt(tester, rows, 3));
    await tester.pump();
    await down.moveTo(_gutterAt(tester, rows, 5));
    await tester.pump();
    expect(controller.selection, _lineSelection(controller, 3, 6));
    await down.moveTo(_gutterAt(tester, rows, 1, row: 1));
    await tester.pump();
    await down.up();
    await settle(tester, 2);
    expect(
      controller.selection,
      TextSelection(
        baseOffset: controller.getLineStartOffset(4),
        extentOffset: controller.getLineStartOffset(1),
      ),
    );
  });

  testWidgets('shift-clicking a line number extends from the base', (
    tester,
  ) async {
    final controller = await pumpWrapped(tester);
    final rows = await _tapEveryRow(tester, controller);
    final base = controller.getLineStartOffset(4) + 2;

    Future<void> shiftClick(int line) async {
      controller.selection = TextSelection.collapsed(offset: base);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.tapAt(_gutterAt(tester, rows, line));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await settle(tester, 2);
    }

    await shiftClick(7);
    expect(
      controller.selection,
      TextSelection(
        baseOffset: base,
        extentOffset: controller.getLineStartOffset(8),
      ),
    );

    await shiftClick(2);
    expect(
      controller.selection,
      TextSelection(
        baseOffset: base,
        extentOffset: controller.getLineStartOffset(2),
      ),
    );
  });

  testWidgets('the last line number selects to the end of the text', (
    tester,
  ) async {
    final controller = await pumpWrapped(tester);
    final rows = await _tapEveryRow(tester, controller);

    await tester.tapAt(_gutterAt(tester, rows, 9));
    await settle(tester, 2);
    expect(controller.selection, _lineSelection(controller, 9, 10));
    expect(controller.selection.extentOffset, controller.length);
  });

  testWidgets('dragging to the right edge stops at the line end', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _lines.join('\n');
    await pumpEditor(tester, controller);
    final origin = tester.getTopLeft(find.byType(CodeForge));
    const rowY = editorTopPadding + editorLineHeight * 7.5;

    final drag = await tester.startGesture(
      origin + const Offset(_gutterWidthHitTest + 4, rowY),
    );
    await tester.pump();
    await drag.moveTo(
      origin + Offset(tester.getSize(find.byType(CodeForge)).width - 2, rowY),
    );
    await tester.pump();
    await drag.up();
    await settle(tester, 2);
    expect(
      controller.selection,
      TextSelection(
        baseOffset: controller.getLineStartOffset(7),
        extentOffset: controller.getLineStartOffset(7) + _lines[7].length,
      ),
    );
  });

  testWidgets('a shift-click keeps its base while the mouse moves on', (
    tester,
  ) async {
    final controller = CodeForgeController()
      ..text = List.generate(200, (i) => 'line $i').join('\n');
    await pumpEditor(tester, controller);
    final origin = tester.getTopLeft(find.byType(CodeForge));
    const base = 3;
    controller.selection = const TextSelection.collapsed(offset: base);
    await tester.pump();

    final mouse = TestPointer(1, PointerDeviceKind.mouse)
      ..hover(origin + const Offset(_textX, 300));
    await tester.sendEventToBinding(mouse.scroll(const Offset(0, 1500)));
    await settle(tester, 2);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    final click = await tester.startGesture(
      origin + const Offset(_textX, 300),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await click.moveBy(const Offset(16, 0));
    await tester.pump();
    await click.up();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    await settle(tester, 2);

    expect(controller.selection.baseOffset, base);
    expect(
      controller.getLineAtOffset(controller.selection.extentOffset),
      greaterThan(60),
    );
  });

  testWidgets('the first double click on a new editor selects the word', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = '${'x' * 60} end';
    await pumpEditor(tester, controller);
    final at =
        tester.getTopLeft(find.byType(CodeForge)) +
        const Offset(_textX, editorTopPadding + editorLineHeight / 2);

    await tester.tapAt(at);
    await tester.pump(kDoubleTapMinTime * 2);
    await tester.tapAt(at);
    await tester.pump(kDoubleTapTimeout);

    expect(
      controller.selection,
      const TextSelection(baseOffset: 0, extentOffset: 60),
    );
  });

  testWidgets('each right click asks for the context menu where it landed', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _lines.join('\n');
    final requests = <Offset>[];
    await pumpEditor(
      tester,
      controller,
      onContextMenu: (context, request) => requests.add(request.globalPosition),
    );
    final at =
        tester.getTopLeft(find.byType(CodeForge)) +
        const Offset(_textX, editorTopPadding + editorLineHeight * 2.5);

    for (var i = 0; i < 2; i++) {
      await tester.tapAt(at, buttons: kSecondaryButton);
      await settle(tester, 2);
    }
    expect(requests, [at, at]);
  });

  testWidgets('the context menu gets the selected rows, not the glyph boxes', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _lines.join('\n');
    Rect? selectionRect;
    await pumpEditor(
      tester,
      controller,
      onContextMenu: (context, request) =>
          selectionRect = request.selectionRect,
    );
    final start = controller.getLineStartOffset(1) + 2;
    final end = controller.getLineStartOffset(3) + 2;
    controller.selection = TextSelection(baseOffset: start, extentOffset: end);
    await settle(tester, 2);
    final origin = tester.getTopLeft(find.byType(CodeForge));
    await tester.tapAt(
      origin + const Offset(_textX, editorTopPadding + editorLineHeight * 2.5),
      buttons: kSecondaryButton,
    );
    await settle(tester, 2);

    expect(selectionRect!.top - origin.dy, editorTopPadding + editorLineHeight);
    expect(
      selectionRect!.bottom - origin.dy,
      editorTopPadding + editorLineHeight * 4,
    );
  });
}

void _multiTouch() {
  testWidgets('a second finger ends the first one\'s selection drag', (
    tester,
  ) async {
    final controller = CodeForgeController()
      ..text = [for (var i = 0; i < 20; i++) 'line $i with text'].join('\n');
    await pumpEditor(tester, controller);
    final origin = tester.getTopLeft(find.byType(CodeForge));
    final first = origin + const Offset(120, editorTopPadding + 10);

    final one = await tester.startGesture(first, kind: PointerDeviceKind.touch);
    await tester.pump();
    final caret = controller.selection;
    final two = await tester.startGesture(
      first + const Offset(0, 200),
      pointer: 2,
      kind: PointerDeviceKind.touch,
    );
    await one.moveBy(const Offset(0, 120));
    await two.moveBy(const Offset(0, 60));
    await tester.pump();
    await one.up();
    await two.up();
    await tester.pump(const Duration(milliseconds: 600));

    expect(controller.selection, caret);
  });
}

const _blockLines = 6;

String _block(int i) =>
    '''
  - name: node $i
    type: vmess
    server: ${'s' * 40}.example$i.com
    opts: {
      path: /
    }''';

String _document(int blocks) =>
    ['proxies:', for (var i = 0; i < blocks; i++) _block(i)].join('\n');

int _optsLine(int block) => 1 + block * _blockLines + 3;

void _folding() {
  testWidgets('folding hides lines and keeps the text', (tester) async {
    final text = _document(3);
    final controller = CodeForgeController()..text = text;
    await pumpEditor(tester, controller);

    controller.toggleFold(_optsLine(1));
    await settle(tester);
    expect(controller.text, text);
    expect(controller.isLineInFoldedRegion(_optsLine(1) + 1), isTrue);
    expect(controller.isLineInFoldedRegion(_optsLine(1) + 2), isTrue);
    expect(controller.isLineInFoldedRegion(_optsLine(1) + 3), isFalse);
    expect(controller.getFoldStartForLine(_optsLine(1) + 1), _optsLine(1));
    final visible = text.split('\n')
      ..removeRange(_optsLine(1) + 1, _optsLine(1) + 3);
    expect(visibleText(controller), visible.join('\n'));

    controller.toggleFold(_optsLine(1));
    await settle(tester);
    expect(controller.isLineInFoldedRegion(_optsLine(1) + 1), isFalse);
    expect(visibleText(controller), text);
    expect(controller.text, text);
  });

  testWidgets('an indentation fold covers every nested line', (tester) async {
    final text = '${_document(2)}\nrules:\n  - MATCH,DIRECT';
    final controller = CodeForgeController()..text = text;
    await pumpEditor(tester, controller);

    controller.toggleFold(0);
    await settle(tester);
    expect(visibleText(controller), 'proxies:\nrules:\n  - MATCH,DIRECT');
    expect(controller.getFoldStartForLine(2 * _blockLines), 0);

    controller.toggleFold(0);
    await settle(tester);
    expect(visibleText(controller), text);
    expect(controller.text, text);
  });

  testWidgets('an indentation fold covers a block of any length', (
    tester,
  ) async {
    final text = '${_document(900)}\nrules:\n  - MATCH,DIRECT';
    final controller = CodeForgeController()..text = text;
    await pumpEditor(tester, controller);

    controller.toggleFold(0);
    await settle(tester);
    expect(visibleText(controller), 'proxies:\nrules:\n  - MATCH,DIRECT');
  });

  testWidgets('a document folds the same past the per-line folding limit', (
    tester,
  ) async {
    const lines = [
      'a: {',
      '  b: (',
      '  c: 1',
      '}',
      'd: [',
      '  e: )',
      ']',
      'f(x, [',
      '  y)',
      ']',
      'k: [ v:',
      '    x',
      '    y',
      ']',
      'm:',
      '  n: 1',
      '',
      '  o: 2',
      'p: 3',
      'q:\u{feff}',
      '  r: 1',
    ];

    Future<List<(int, int)>> foldsOf(String text) async {
      final controller = CodeForgeController()..text = text;
      await pumpEditor(tester, controller);
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
      final folds = <(int, int)>[];
      for (var line = 0; line < lines.length; line++) {
        controller.toggleFold(line);
        await tester.pump();
        final fold = controller.foldings[line];
        if (fold != null && fold.isFolded) folds.add((line, fold.endIndex));
        controller.toggleFold(line);
        await tester.pump();
      }
      return folds;
    }

    final text = lines.join('\n');
    final perLine = await foldsOf(text);
    expect(perLine, [
      (0, 3),
      (1, 5),
      (4, 6),
      (7, 8),
      (10, 12),
      (14, 17),
      (19, 20),
    ]);
    expect(await foldsOf('$text${'\n' * 10001}'), perLine);
  });

  testWidgets('an indentation fold holds past the per-line folding limit', (
    tester,
  ) async {
    final text = '${_document(1700)}\nrules:\n  - MATCH,DIRECT';
    final controller = CodeForgeController()..text = text;
    await pumpEditor(tester, controller);
    await tester.pump(const Duration(milliseconds: 400));
    await settle(tester);

    controller.toggleFold(0);
    await settle(tester);
    expect(visibleText(controller), 'proxies:\nrules:\n  - MATCH,DIRECT');
  });

  testWidgets('a whole-document fold pass overtaken by an edit is redone', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document(1700);
    await pumpEditor(tester, controller);
    await tester.pump(const Duration(milliseconds: 400));
    controller.replaceRange(0, 0, '#\n#\n');
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 400));
    await settle(tester);

    controller.toggleFold(0);
    await settle(tester);
    expect(controller.isLineInFoldedRegion(1), isFalse);

    controller.toggleFold(2);
    await settle(tester);
    expect(controller.getFoldStartForLine(3), 2);
  });

  testWidgets('editing below a fold keeps it folded and the text exact', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document(3);
    await pumpEditor(tester, controller);
    controller.toggleFold(_optsLine(0));
    await settle(tester);

    final line = _optsLine(2);
    final start = controller.getLineStartOffset(line);
    controller.replaceRange(start, start, '    udp: true\n');
    await settle(tester);

    expect(controller.getLineText(line), '    udp: true');
    expect(controller.isLineInFoldedRegion(_optsLine(0) + 1), isTrue);
    expect(controller.lineCount, 1 + 3 * _blockLines + 1);
  });

  testWidgets('deleting a whole folded block leaves no fold behind', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document(3);
    await pumpEditor(tester, controller);
    final line = _optsLine(1);
    controller.toggleFold(line);
    await settle(tester);

    controller.replaceRange(
      controller.getLineStartOffset(line),
      controller.getLineStartOffset(line + 3),
      '',
    );
    await settle(tester);

    for (var i = 0; i < controller.lineCount; i++) {
      expect(controller.isLineInFoldedRegion(i), isFalse, reason: 'line $i');
    }
    expect(visibleText(controller), controller.text);
  });

  testWidgets('a newline on a folded start line does not move the fold', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document(3);
    await pumpEditor(tester, controller);
    final line = _optsLine(0);
    controller.toggleFold(line);
    await settle(tester);

    final end = controller.getLineStartOffset(line + 1) - 1;
    controller.replaceRange(end, end, '\n');
    await settle(tester);

    expect(controller.getFoldStartForLine(line + 2), isNot(line + 1));
    expect(controller.isLineInFoldedRegion(line + 1), isFalse);
    expect(visibleText(controller), controller.text);
  });

  testWidgets('replacing lines that hold a fold drops it', (tester) async {
    final controller = CodeForgeController()..text = _document(3);
    await pumpEditor(tester, controller);
    final line = _optsLine(1);
    controller.toggleFold(line);
    await settle(tester);

    controller.replaceRange(
      controller.getLineStartOffset(line - 1),
      controller.getLineStartOffset(line + 2) - 1,
      '    x: 1\n    y: 2\n    z: 3',
    );
    await settle(tester);

    expect(controller.lineCount, 1 + 3 * _blockLines);
    expect(controller.isLineInFoldedRegion(line + 1), isFalse);
    expect(visibleText(controller), controller.text);
  });

  testWidgets('editing a folded start line before its bracket keeps it', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = _document(3);
    await pumpEditor(tester, controller);
    final line = _optsLine(0);
    controller.toggleFold(line);
    await settle(tester);

    final start = controller.getLineStartOffset(line) + '    '.length;
    controller.replaceRange(start, start + 'opts'.length, 'options');
    await settle(tester);

    expect(controller.getLineText(line), '    options: {');
    expect(controller.getFoldStartForLine(line + 1), line);
    expect(controller.isLineInFoldedRegion(line + 2), isTrue);
    expect(controller.isLineInFoldedRegion(line + 3), isFalse);

    controller.toggleFold(line);
    await settle(tester);
    expect(controller.isLineInFoldedRegion(line + 1), isFalse);
  });

  group('an edit inside a fold', () {
    const text = 'a: {\n  b: 1\n  c: 2\n}\nd: 3';

    Future<CodeForgeController> pump(
      WidgetTester tester, {
      bool folded = true,
    }) async {
      final controller = CodeForgeController()..text = text;
      await pumpEditor(tester, controller);
      if (folded) {
        controller.toggleFold(0);
        await settle(tester);
        expect(controller.getFoldStartForLine(3), 0);
      }
      return controller;
    }

    void closeEarly(CodeForgeController controller) {
      final end = controller.getLineStartOffset(2) - 1;
      controller.replaceRange(end, end, ' }');
    }

    testWidgets('that keeps its shape leaves it folded', (tester) async {
      final controller = await pump(tester);

      final end = controller.getLineStartOffset(2) - 1;
      controller.replaceRange(end, end, '0');
      await settle(tester);

      expect(controller.getLineText(1), '  b: 10');
      expect(visibleText(controller), 'a: {\nd: 3');
    });

    testWidgets('that ends it on an earlier line unfolds it', (tester) async {
      final controller = await pump(tester);

      closeEarly(controller);
      await settle(tester);

      expect(visibleText(controller), controller.text);
    });

    testWidgets('that adds lines and ends it early unfolds it', (tester) async {
      final controller = await pump(tester);

      final start = controller.getLineStartOffset(2);
      controller.replaceRange(start, start, '}\ne: {\n');
      await settle(tester);

      expect(controller.lineCount, 7);
      expect(visibleText(controller), controller.text);
    });

    testWidgets('left unfolded is folded by what the text now says', (
      tester,
    ) async {
      final controller = await pump(tester, folded: false);

      closeEarly(controller);
      await settle(tester);
      controller.toggleFold(0);
      await settle(tester);

      expect(visibleText(controller), 'a: {\n  c: 2\n}\nd: 3');
    });
  });

  testWidgets('indenting a folded key past its lines unfolds it', (
    tester,
  ) async {
    final controller = CodeForgeController()
      ..text = 'proxies:\n  - a\n  - b\nrules:\n  - c';
    await pumpEditor(tester, controller);
    controller.toggleFold(0);
    await settle(tester);
    expect(visibleText(controller), 'proxies:\nrules:\n  - c');

    controller.replaceRange(0, 0, '    ');
    await settle(tester);

    expect(visibleText(controller), controller.text);
  });

  group('past the per-line folding limit, a whole-document pass', () {
    Future<CodeForgeController> pump(WidgetTester tester) async {
      final controller = CodeForgeController()..text = _document(1700);
      await pumpEditor(tester, controller);
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
      return controller;
    }

    Future<void> closeEarly(
      WidgetTester tester,
      CodeForgeController controller,
    ) async {
      final end = controller.getLineStartOffset(_optsLine(0) + 2) - 1;
      controller.replaceRange(end, end, ' }');
      await settle(tester);
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
    }

    testWidgets('unfolds a fold an edit ended on an earlier line', (
      tester,
    ) async {
      final controller = await pump(tester);
      final line = _optsLine(0);
      controller.toggleFold(line);
      await settle(tester);
      expect(controller.getFoldStartForLine(line + 2), line);

      await closeEarly(tester, controller);

      expect(controller.isLineInFoldedRegion(line + 1), isFalse);
      expect(controller.isLineInFoldedRegion(line + 2), isFalse);
    });

    testWidgets('gives an unfolded fold the range an edit left it', (
      tester,
    ) async {
      final controller = await pump(tester);
      final line = _optsLine(0);

      await closeEarly(tester, controller);
      controller.toggleFold(line);
      await settle(tester);

      expect(controller.getFoldStartForLine(line + 1), line);
      expect(controller.isLineInFoldedRegion(line + 2), isFalse);
    });

    testWidgets('keeps a fold whose head a whole-line edit moved', (
      tester,
    ) async {
      final controller = await pump(tester);
      final line = _optsLine(0);
      controller.toggleFold(line);
      await settle(tester);

      final above = controller.getLineStartOffset(line - 1);
      final head = controller.getLineStartOffset(line);
      controller.replaceRange(above, head, '');
      await settle(tester);
      expect(controller.getFoldStartForLine(line), line - 1);

      controller.replaceRange(above, above, '    udp: true\n');
      await settle(tester);
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
      expect(controller.getFoldStartForLine(line + 1), line);
      expect(controller.isLineInFoldedRegion(line + 3), isFalse);
    });

    testWidgets('leaves a folded fold the folds it folded over', (
      tester,
    ) async {
      final controller = await pump(tester);
      final inner = _optsLine(0);
      controller.toggleFold(inner);
      await settle(tester);
      controller.toggleFold(0);
      await settle(tester);

      controller.replaceRange(0, 0, '# top\n');
      await settle(tester);
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
      expect(controller.getFoldStartForLine(inner + 1), 1);
      controller.toggleFold(1);
      await settle(tester);

      expect(controller.isLineInFoldedRegion(inner + 1), isFalse);
      expect(controller.getFoldStartForLine(inner + 2), inner + 1);
    });
  });

  testWidgets('a line inserted above a fold shifts it whole', (tester) async {
    final controller = CodeForgeController()..text = _document(3);
    await pumpEditor(tester, controller);
    final line = _optsLine(1);
    controller.toggleFold(line);
    await settle(tester);

    final start = controller.getLineStartOffset(1);
    controller.replaceRange(start, start, '# a\n# b\n');
    await settle(tester);

    expect(controller.getFoldStartForLine(line + 3), line + 2);
    expect(controller.isLineInFoldedRegion(line + 4), isTrue);
    expect(controller.isLineInFoldedRegion(line + 5), isFalse);
  });

  group('a fold with a whole line edited at its edge', () {
    const text = 'x: 1\na:\n  b: 1\nc: 2';

    Future<CodeForgeController> pumpFolded(WidgetTester tester) async {
      final controller = CodeForgeController()..text = text;
      await pumpEditor(tester, controller);
      controller.toggleFold(1);
      await settle(tester);
      expect(visibleText(controller), 'x: 1\na:\nc: 2');
      return controller;
    }

    testWidgets('stays folded when the line above it is deleted', (
      tester,
    ) async {
      final controller = await pumpFolded(tester);

      controller.replaceRange(0, controller.getLineStartOffset(1), '');
      await settle(tester);

      expect(visibleText(controller), 'a:\nc: 2');
    });

    testWidgets('stays folded when a line is inserted at its start', (
      tester,
    ) async {
      final controller = await pumpFolded(tester);

      final head = controller.getLineStartOffset(1);
      controller.replaceRange(head, head, 'n: 0\n');
      await settle(tester);

      expect(visibleText(controller), 'x: 1\nn: 0\na:\nc: 2');
    });
  });

  group('nested folds', () {
    const text = 'a:\n  b:\n    x: 1\n    y: 2\nc: 3';

    Future<CodeForgeController> pumpBothFolded(WidgetTester tester) async {
      final controller = CodeForgeController()..text = text;
      await pumpEditor(tester, controller);
      controller.toggleFold(1);
      await settle(tester);
      controller.toggleFold(0);
      await settle(tester);
      expect(visibleText(controller), 'a:\nc: 3');
      return controller;
    }

    testWidgets('refold the inner one only by what the text still gives', (
      tester,
    ) async {
      final controller = await pumpBothFolded(tester);

      final start = controller.getLineStartOffset(3);
      controller.replaceRange(start, start + 2, '');
      await settle(tester);
      controller.toggleFold(0);
      await settle(tester);

      expect(visibleText(controller), controller.text);
    });

    testWidgets('keep the inner one folded when an edit opens the outer', (
      tester,
    ) async {
      final controller = await pumpBothFolded(tester);

      controller.replaceRange(2, 2, ' 1');
      await settle(tester);

      expect(visibleText(controller), 'a: 1\n  b:\nc: 3');
    });

    testWidgets('open down to a line scrolled to', (tester) async {
      final controller = await pumpBothFolded(tester);

      controller.scrollToLine(2);
      await settle(tester, 12);

      expect(controller.isLineInFoldedRegion(2), isFalse);
    });

    testWidgets('keep the inner one folded through a replace-all across '
        'them', (tester) async {
      final controller = CodeForgeController()..text = 'z: 0\n$text';
      final finder = FindController(controller);
      addTearDown(finder.dispose);
      await pumpEditor(tester, controller, findController: finder);
      controller.toggleFold(2);
      await settle(tester);
      controller.toggleFold(1);
      await settle(tester);

      finder.isRegex = true;
      finder.find(r'\d');
      finder.replaceInputController.text = '9';
      finder.replaceAll();
      await tester.pump(const Duration(milliseconds: 300));
      await settle(tester);
      expect(visibleText(controller), 'z: 9\na:\nc: 9');

      controller.toggleFold(1);
      await settle(tester);
      expect(visibleText(controller), 'z: 9\na:\n  b:\nc: 9');
    });

    testWidgets('keep the inner one folded in a re-keyed editor that is '
        'edited', (tester) async {
      final controller = CodeForgeController()..text = text;
      await pumpEditor(tester, controller, key: const ValueKey(1));
      controller.toggleFold(1);
      await settle(tester);
      controller.toggleFold(0);
      await settle(tester);
      await pumpEditor(tester, controller, key: const ValueKey(2));

      controller.replaceRange(0, 0, '# top\n');
      await settle(tester);
      controller.toggleFold(1);
      await settle(tester);

      expect(visibleText(controller), '# top\na:\n  b:\nc: 3');
    });
  });

  testWidgets('a replace-all across a fold keeps it only where it still '
      'is', (tester) async {
    final controller = CodeForgeController()..text = _document(6);
    final finder = FindController(controller);
    addTearDown(finder.dispose);
    await pumpEditor(tester, controller, findController: finder);
    final line = _optsLine(3);
    controller.toggleFold(line);
    await settle(tester);

    finder.find('vmess');
    finder.replaceInputController.text = 'trojan';
    finder.replaceAll();
    await settle(tester);
    expect(controller.getFoldStartForLine(line + 2), line);

    finder.isRegex = true;
    finder.find(r'^  - name: node [14]\n(.*\n){5}');
    expect(finder.matchCount, 2);
    finder.replaceInputController.text = '';
    finder.replaceAll();
    await tester.pump(const Duration(milliseconds: 300));
    await settle(tester);
    expect(controller.lineCount, 1 + 4 * _blockLines);
    expect(visibleText(controller), controller.text);
  });

  group('the caret', () {
    const text = 'x: 1\na:\n  b: 1\n  c: 2';

    Future<CodeForgeController> pumpFocused(
      WidgetTester tester, [
      String text = text,
    ]) async {
      final controller = CodeForgeController()..text = text;
      await pumpEditor(tester, controller);
      await focusEditor(tester);
      return controller;
    }

    testWidgets('on a line a fold hides moves to the line heading it', (
      tester,
    ) async {
      final controller = await pumpFocused(tester);
      controller.selection = TextSelection.collapsed(
        offset: controller.getLineStartOffset(2) + 3,
      );
      await settle(tester, 2);

      controller.toggleFold(1);
      await settle(tester);

      expect(visibleText(controller), 'x: 1\na:');
      expect(controller.selection, const TextSelection.collapsed(offset: 7));
    });

    testWidgets('steps over a fold to the line after it', (tester) async {
      final controller = await pumpFocused(tester, '$text\nd: 3');
      controller.toggleFold(1);
      await settle(tester);
      controller.selection = const TextSelection.collapsed(offset: 7);
      await settle(tester, 2);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester, 2);

      expect(visibleText(controller), 'x: 1\na:\nd: 3');
      expect(
        controller.selection,
        TextSelection.collapsed(offset: controller.getLineStartOffset(4)),
      );
    });

    testWidgets('stays on the line heading a fold that ends the document', (
      tester,
    ) async {
      final controller = await pumpFocused(tester);
      controller.toggleFold(1);
      await settle(tester);
      controller.selection = const TextSelection.collapsed(offset: 5);
      await settle(tester, 2);

      for (final key in [
        LogicalKeyboardKey.arrowDown,
        LogicalKeyboardKey.arrowRight,
        LogicalKeyboardKey.arrowRight,
        LogicalKeyboardKey.arrowRight,
      ]) {
        await tester.sendKeyEvent(key);
        await settle(tester, 2);
      }

      expect(visibleText(controller), 'x: 1\na:');
      expect(controller.selection, const TextSelection.collapsed(offset: 7));
    });
  });

  testWidgets('a fold the text no longer gives leaves its line number to '
      'select the line', (tester) async {
    final controller = CodeForgeController()..text = 'a:\n  b: 1\nc: 2';
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 5);
    await settle(tester, 2);
    controller.replaceRange(3, 5, '');
    await tester.pump();

    await tester.tapAt(
      tester.getTopLeft(find.byType(CodeForge)) +
          const Offset(36, editorTopPadding + editorLineHeight / 2),
    );
    await settle(tester, 8);

    expect(visibleText(controller), controller.text);
    expect(
      controller.selection,
      const TextSelection(baseOffset: 0, extentOffset: 3),
    );
  });

  testWidgets('finding text inside a fold opens it and scrolls there', (
    tester,
  ) async {
    const block = 150;
    final line = _optsLine(block) + 1;
    final text = _document(200).split('\n')..[line] = '      path: /unique';
    final controller = CodeForgeController()..text = text.join('\n');
    final finder = FindController(controller);
    addTearDown(finder.dispose);
    late ScrollController vertical;
    await pumpEditor(
      tester,
      controller,
      findController: finder,
      scrollbarBuilder: (_, details, child) {
        vertical = details.controller;
        return child;
      },
    );
    controller.toggleFold(0);
    await settle(tester);
    expect(vertical.position.maxScrollExtent, 0);

    finder.find('unique');
    await settle(tester, 12);

    expect(controller.isLineInFoldedRegion(line), isFalse);
    final lineTop = editorTopPadding + line * editorLineHeight;
    expect(vertical.offset, lessThanOrEqualTo(lineTop));
    expect(vertical.offset + 600, greaterThanOrEqualTo(lineTop + 20));
  });

  testWidgets('a line indented under a key gives the key its fold at once', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a:\nb: 1';
    await pumpEditor(tester, controller);

    controller.replaceRange(3, 3, '  ');
    await settle(tester);
    controller.toggleFold(0);
    await settle(tester);

    expect(visibleText(controller), 'a:');
  });

  testWidgets('indenting the line below a folded block into it unfolds it', (
    tester,
  ) async {
    final controller = CodeForgeController()
      ..text = 'proxies:\n  - a\n\nrules:\n  - c';
    await pumpEditor(tester, controller);
    controller.toggleFold(0);
    await settle(tester);

    final start = controller.getLineStartOffset(3);
    controller.replaceRange(start, start, '  ');
    await settle(tester);

    expect(visibleText(controller), controller.text);
  });

  testWidgets('a re-keyed editor keeps what was folded', (tester) async {
    final controller = CodeForgeController()..text = 'a:\n  b: 1\n  c: 2\nd: 3';
    await pumpEditor(tester, controller, key: const ValueKey(1));
    controller.toggleFold(0);
    await settle(tester);

    await pumpEditor(tester, controller, key: const ValueKey(2));

    expect(visibleText(controller), 'a:\nd: 3');
    controller.toggleFold(0);
    await settle(tester);
    expect(visibleText(controller), controller.text);
  });

  testWidgets(
    'after scrolling a folded wrapped document, taps and the line indicator agree',
    (tester) async {
      final controller = CodeForgeController()..text = _document(200);
      late CodeForgeScrollbarDetails scrollbar;
      await pumpEditor(
        tester,
        controller,
        lineWrap: true,
        size: const Size(400, 600),
        scrollbarBuilder: (context, details, child) {
          scrollbar = details;
          return child;
        },
      );
      for (final block in [2, 5, 8, 40, 41, 42]) {
        controller.toggleFold(_optsLine(block));
        await settle(tester, 2);
      }

      final editor = find.byType(CodeForge);
      final center = tester.getCenter(editor);
      for (var i = 0; i < 6; i++) {
        tester.binding.handlePointerEvent(
          PointerScrollEvent(
            position: center,
            scrollDelta: const Offset(0, 997),
          ),
        );
        await settle(tester, 2);
      }
      expect(scrollbar.controller.offset, greaterThan(4000));

      final origin = tester.getTopLeft(editor);
      final hits = <int>[];
      for (var row = 0; row < 25; row++) {
        await tester.tapAt(
          origin +
              Offset(
                380,
                editorTopPadding + 1 + (row + 0.5) * editorLineHeight,
              ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        hits.add(controller.getLineAtOffset(controller.selection.extentOffset));
      }

      expect(hits.first, scrollbar.firstVisibleLine.value - 1);
      for (var i = 1; i < hits.length; i++) {
        expect(hits[i], greaterThanOrEqualTo(hits[i - 1]));
      }
      for (final line in hits) {
        expect(controller.isLineInFoldedRegion(line), isFalse);
      }
      final lines = hits.toSet().toList();
      final hidden = <int>{
        for (final block in [40, 41, 42]) ...[
          _optsLine(block) + 1,
          _optsLine(block) + 2,
        ],
      };
      final expected = [
        for (var line = lines.first; line <= lines.last; line++)
          if (!hidden.contains(line)) line,
      ];
      expect(lines, expected, reason: 'every visible line gets a row');
    },
  );
}

Future<Color> _pixelAt(WidgetTester tester, GlobalKey key, Offset at) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = (await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return data!;
  }))!;
  final index =
      (at.dy.toInt() * boundary.size.width.toInt() + at.dx.toInt()) * 4;
  return Color.fromARGB(
    bytes.getUint8(index + 3),
    bytes.getUint8(index),
    bytes.getUint8(index + 1),
    bytes.getUint8(index + 2),
  );
}

void _theme() {
  testWidgets('a new theme repaints the gutter and selection in place', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a${' ' * 40}b\nc: 1';
    final boundary = GlobalKey();

    Future<void> pumpTheme(Color background, Color selection) => pumpEditor(
      tester,
      controller,
      editorTheme: {
        ...atomOneLightTheme,
        'root': TextStyle(color: Colors.black, backgroundColor: background),
      },
      selectionStyle: CodeSelectionStyle(selectionColor: selection),
      wrap: (editor) => RepaintBoundary(key: boundary, child: editor),
    );

    const rowY = editorTopPadding + editorLineHeight / 2;
    const gutter = Offset(36, rowY);
    const selected = Offset(200, rowY);
    await pumpTheme(Colors.white, const Color(0xFF00FF00));
    final state = tester.state(find.byType(CodeForge));
    controller.selectAll();
    await settle(tester, 2);
    expect(await _pixelAt(tester, boundary, gutter), Colors.white);
    expect(await _pixelAt(tester, boundary, selected), const Color(0xFF00FF00));

    await pumpTheme(Colors.black, const Color(0xFFFF0000));
    expect(tester.state(find.byType(CodeForge)), same(state));
    expect(await _pixelAt(tester, boundary, gutter), Colors.black);
    expect(await _pixelAt(tester, boundary, selected), const Color(0xFFFF0000));
  });
}

RenderObject _renderer(WidgetTester tester) => tester.allRenderObjects
    .firstWhere((r) => r.runtimeType.toString() == '_CodeFieldRenderer');

List<(ui.Paragraph, Offset)> _paintedParagraphs(WidgetTester tester) {
  final painted = <(ui.Paragraph, Offset)>[];
  expect(
    _renderer(tester),
    paints..everything((method, args) {
      if (method == #drawParagraph) {
        painted.add((args[0] as ui.Paragraph, args[1] as Offset));
      }
      return true;
    }),
  );
  return painted;
}

Future<void> _compose(
  WidgetTester tester,
  CodeForgeController controller,
  String text,
) async {
  final setClient = tester.testTextInput.log.lastWhere(
    (call) => call.method == 'TextInput.setClient',
  );
  final client = (setClient.arguments as List)[0] as int;
  final value = controller.currentTextEditingValue;
  final caret = value.selection.extentOffset;
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.textInput.name,
    SystemChannels.textInput.codec.encodeMethodCall(
      MethodCall('TextInputClient.updateEditingStateWithDeltas', [
        client,
        {
          'deltas': [
            {
              'oldText': value.text,
              'deltaText': text,
              'deltaStart': caret,
              'deltaEnd': caret,
              'selectionBase': caret + text.length,
              'selectionExtent': caret + text.length,
              'selectionAffinity': 'TextAffinity.downstream',
              'selectionIsDirectional': false,
              'composingBase': caret,
              'composingExtent': caret + text.length,
            },
          ],
        },
      ]),
    ),
    (_) {},
  );
  await tester.pump();
}

void _painting() {
  testWidgets('the composition overlay redraws the rest of the line after '
      'an astral character', (tester) async {
    final controller = CodeForgeController()..text = '\u{1F600}ab\nc';
    await pumpEditor(tester, controller);
    await focusEditor(tester);

    controller.selection = const TextSelection.collapsed(offset: 2);
    await tester.pump();
    await _compose(tester, controller, 'x');
    expect(controller.isComposingActive, isTrue);

    final painted = _paintedParagraphs(tester);
    final (composing, composingAt) = painted[painted.length - 2];
    final (remainder, remainderAt) = painted.last;
    expect(composing.longestLine, _glyphWidth);
    expect(remainderAt.dx - composingAt.dx, _glyphWidth);
    expect(remainder.longestLine, _glyphWidth);
  });

  testWidgets('a tap past a composition lands on the text shown there', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'aaaa bbbb';
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    final (_, lineStart) = _paintedParagraphs(tester).first;

    controller.selection = const TextSelection.collapsed(offset: 4);
    await tester.pump();
    await _compose(tester, controller, 'xy');
    expect(controller.isComposingActive, isTrue);

    final renderer = _renderer(tester) as RenderBox;
    await tester.tapAt(
      renderer.localToGlobal(lineStart + const Offset(8 * _glyphWidth + 4, 8)),
    );
    await settle(tester, 2);

    expect(controller.text, 'aaaaxy bbbb');
    expect(controller.selection, const TextSelection.collapsed(offset: 8));
  });

  testWidgets('an edit after the input method dropped a composition is laid '
      'out', (tester) async {
    late ScrollController vertical;
    final controller = CodeForgeController()..text = 'ab\ncd';
    await pumpEditor(
      tester,
      controller,
      size: const Size(400, 40),
      scrollbarBuilder: (_, details, child) {
        vertical = details.controller;
        return child;
      },
    );
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 1);
    await tester.pump();
    await _compose(tester, controller, 'x');
    expect(controller.isComposingActive, isTrue);

    final setClient = tester.testTextInput.log.lastWhere(
      (call) => call.method == 'TextInput.setClient',
    );
    final client = (setClient.arguments as List)[0] as int;
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.textInput.name,
      SystemChannels.textInput.codec.encodeMethodCall(
        MethodCall('TextInputClient.onConnectionClosed', [client]),
      ),
      (_) {},
    );
    await tester.pump();
    expect(controller.isComposingActive, isFalse);

    controller.selection = const TextSelection.collapsed(offset: 2);
    controller.replaceRange(2, 2, '\n');
    await tester.pump();

    expect(
      vertical.position.maxScrollExtent,
      3 * editorLineHeight + editorTopPadding - 40,
    );
  });

  testWidgets('a selection starting at a line end marks that line end', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'abcd\nef';
    await pumpEditor(tester, controller);
    controller.selection = const TextSelection(baseOffset: 4, extentOffset: 6);
    await tester.pump();

    final rects = _selectionRects(tester);
    expect(rects, hasLength(2));
    final (_, lineStart) = _paintedParagraphs(tester).first;
    expect(rects.first.left, lineStart.dx + 4 * _glyphWidth);
    expect(rects.last.left, lineStart.dx);
  });

  Future<void> typeOne(
    WidgetTester tester,
    CodeForgeController controller,
    String char, {
    bool pump = true,
  }) {
    final value = controller.currentTextEditingValue;
    final caret = value.selection.extentOffset;
    return sendDeltas(tester, [
      textDelta(value.text, char, caret, caret),
    ], pump: pump);
  }

  testWidgets('typing on a line pauses the bracket highlight until it rests', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a: {\n  b: 1\n}';
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 3);
    await tester.pump(const Duration(milliseconds: 600));
    expect(_bracketBoxes(tester), hasLength(2));

    await typeOne(tester, controller, 'x');
    expect(controller.isBufferActive, isTrue);
    expect(_bracketBoxes(tester), isEmpty);

    await tester.pump(const Duration(milliseconds: 600));
    final boxes = _bracketBoxes(tester);
    final (_, lineStart) = _paintedParagraphs(tester).first;
    expect(boxes, hasLength(2));
    expect(boxes.first.left, lineStart.dx + 4 * _glyphWidth - 1.5);
  });

  testWidgets('typing over a closing bracket repaints the caret at once', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'f()';
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 2);
    await tester.pump();

    await typeOne(tester, controller, ')', pump: false);

    expect(controller.text, 'f()');
    expect(controller.selection, const TextSelection.collapsed(offset: 3));
    expect(_renderer(tester).debugNeedsPaint, isTrue);
  });

  testWidgets('an edit between a bracket pair moves its highlight along', (
    tester,
  ) async {
    final controller = CodeForgeController()..text = 'a: {\n  b: 1\n}';
    await pumpEditor(tester, controller);
    await focusEditor(tester);
    controller.selection = const TextSelection.collapsed(offset: 4);
    await tester.pump(const Duration(milliseconds: 600));
    expect(_bracketBoxes(tester), hasLength(2));

    controller.replaceRange(5, 5, 'x');
    controller.selection = const TextSelection.collapsed(offset: 4);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    final boxes = _bracketBoxes(tester);
    expect(boxes, hasLength(2));
    expect(boxes.last.top - boxes.first.top, 2 * editorLineHeight);
  });

  SyntaxHighlighter yamlHighlighter() {
    final highlighter = SyntaxHighlighter(
      language: editorYamlMode,
      editorTheme: atomOneLightTheme,
    );
    addTearDown(highlighter.dispose);
    return highlighter;
  }

  test('a line is highlighted once, wherever edits move it', () {
    final highlighter = yamlHighlighter();
    const text = 'a: 1 # note';
    final span = highlighter.lineSpan(text);
    expect(span, isNotNull);

    expect(highlighter.hasLineSpan(text), isTrue);
    expect(highlighter.lineSpan(text), same(span));
  });

  test(
    'a batch highlighted off the UI isolate matches one line at a time',
    () async {
      final highlighter = yamlHighlighter();
      final lines = [
        for (var i = 0; i < 100; i++) 'key$i: "value" # ${'note ' * 5}',
      ];

      await highlighter.preHighlightLines([
        for (var i = 0; i < lines.length; i++) i,
      ], (line) => lines[line]);

      final inline = yamlHighlighter();
      for (final line in lines) {
        expect(highlighter.hasLineSpan(line), isTrue);
        expect(highlighter.lineSpan(line), inline.lineSpan(line));
      }
    },
  );

  test('a line too long to highlight stays plain text', () {
    final highlighter = yamlHighlighter();
    final line = 'key: ${'v' * SyntaxHighlighter.maxHighlightedLineLength}';

    expect(highlighter.lineSpan(line), isNull);
    expect(highlighter.hasLineSpan(line), isTrue);
    expect(highlighter.lineSpan('key: v'), isNotNull);
  });

  testWidgets('a line too long to highlight is painted from a slice in view', (
    tester,
  ) async {
    const viewWidth = 400.0;
    final long = List.filled(3000, 'abc').join(' ');
    final controller = CodeForgeController()..text = 'a: 1\n$long\nb: 2';
    await pumpEditor(tester, controller, size: const Size(viewWidth, 600));
    await focusEditor(tester);
    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(1) + 6000,
    );
    await settle(tester, 2);

    final painted = _paintedParagraphs(tester);
    final lineStart = painted[0].$2.dx;
    final (slice, at) = painted[1];
    expect(slice.longestLine, lessThan(4 * viewWidth));
    expect(at.dx, lessThanOrEqualTo(0));
    expect(at.dx + slice.longestLine, greaterThanOrEqualTo(viewWidth));
    expect(at.dx - lineStart, greaterThan(0));
    expect((at.dx - lineStart) % _glyphWidth, 0);
  });

  testWidgets('a selection over a line too long to highlight is drawn around '
      'the view', (tester) async {
    const viewWidth = 400.0;
    final long = List.filled(3000, 'abc').join(' ');
    final controller = CodeForgeController()..text = 'a: 1\n$long\nb: 2';
    await pumpEditor(tester, controller, size: const Size(viewWidth, 600));
    await focusEditor(tester);
    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(1) + 6000,
    );
    await settle(tester, 2);
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.length,
    );
    await tester.pump();

    final longRow = _selectionRects(
      tester,
    ).firstWhere((rect) => rect.top > 0 && rect.width > viewWidth);
    expect(longRow.width, lessThan(4 * viewWidth));
    expect(longRow.left, lessThanOrEqualTo(0));
    expect(longRow.right, greaterThanOrEqualTo(viewWidth));
    final lineStart = _paintedParagraphs(tester).first.$2.dx;
    expect((longRow.left - lineStart) % _glyphWidth, 0);
  });

  testWidgets('search highlights on a long line are drawn around the view', (
    tester,
  ) async {
    const viewWidth = 400.0;
    final long = List.filled(4000, 'ab').join(' ');
    final controller = CodeForgeController()..text = 'a: 1\n$long\nb: 2';
    final finder = FindController(controller);
    await pumpEditor(
      tester,
      controller,
      findController: finder,
      size: const Size(viewWidth, 600),
    );
    await focusEditor(tester);
    controller.selection = TextSelection.collapsed(
      offset: controller.getLineStartOffset(1) + 6000,
    );
    await settle(tester, 2);
    finder.isActive = true;
    finder.find('ab', scrollToMatch: false);
    await tester.pump();

    final lineStart = _paintedParagraphs(tester).first.$2.dx;
    final rects = _rectsOf(tester, {0xFF01A2FF, 0xA348D7FF});
    expect(rects, isNotEmpty);
    expect(rects.length, lessThan(4 * viewWidth / (3 * _glyphWidth)));
    final inView = rects.where((r) => r.left >= 0 && r.right <= viewWidth);
    expect(inView, isNotEmpty);
    for (final rect in inView) {
      expect((rect.left - lineStart) % (3 * _glyphWidth), 0);
      expect(rect.width, 2 * _glyphWidth);
    }
  });

  testWidgets('a long wrapped line is painted from the rows in view', (
    tester,
  ) async {
    late ScrollController vertical;
    final long = List.filled(4000, 'abc').join(' ');
    final controller = CodeForgeController()..text = 'a: 1\n$long\nb: 2';
    await pumpEditor(
      tester,
      controller,
      size: const Size(400, 600),
      lineWrap: true,
      scrollbarBuilder: (_, details, child) {
        vertical = details.controller;
        return child;
      },
    );
    vertical.jumpTo(3000);
    await tester.pump();

    final (slice, at) = _paintedParagraphs(tester).first;
    final lineTop = editorTopPadding + editorLineHeight - vertical.offset;
    expect(at.dy, lessThanOrEqualTo(0));
    expect(at.dy + slice.height, greaterThanOrEqualTo(600));
    expect(slice.height, lessThan(vertical.position.maxScrollExtent / 4));
    expect((at.dy - lineTop) % editorLineHeight, 0);

    const tap = Offset(200, 300);
    await focusEditor(tester);
    await tester.tapAt((_renderer(tester) as RenderBox).localToGlobal(tap));
    await settle(tester, 2);
    final caret = controller.selection.extentOffset;
    controller.selection = TextSelection(
      baseOffset: caret,
      extentOffset: caret + 1,
    );
    await tester.pump();
    final rect = _selectionRects(tester).single;
    expect(rect.top, lessThanOrEqualTo(tap.dy));
    expect(rect.bottom, greaterThan(tap.dy));
    expect((rect.left - tap.dx).abs(), lessThanOrEqualTo(_glyphWidth));
  });

  testWidgets('a line shown whole keeps its slices in place while it scrolls', (
    tester,
  ) async {
    final long = List.generate(30000, (i) => '${i % 10}').join();
    final controller = CodeForgeController()..text = 'a: 1\n$long\nb: 2';
    await pumpEditor(tester, controller, size: const Size(400, 600));
    await focusEditor(tester);
    final lineStart = controller.getLineStartOffset(1);
    controller.selection = TextSelection.collapsed(offset: lineStart + 12000);
    await settle(tester, 2);

    final horizontal = _horizontalScroll(tester);
    for (final step in [...List.filled(8, 150.0), ...List.filled(12, -150.0)]) {
      horizontal.jumpTo(horizontal.pixels + step);
      await tester.pump();
      final column = (horizontal.pixels / _glyphWidth).round() + 5;
      controller.selection = TextSelection(
        baseOffset: lineStart + column,
        extentOffset: lineStart + column + 3,
      );
      await tester.pump();
      final textStart = _paintedParagraphs(tester).first.$2.dx;
      final rect = _selectionRects(tester).single;
      expect(rect.left - textStart, column * _glyphWidth);
      expect(rect.width, 3 * _glyphWidth);
    }
  });

  group('a line past the cut', () {
    const cut = 10000;
    CodeForgeController longLine() =>
        CodeForgeController()..text = 'a: 1\n${'x' * (3 * cut)}\nb: 2';

    testWidgets('is shown up to the cut with a marker after it', (
      tester,
    ) async {
      final controller = longLine();
      await pumpEditor(tester, controller, size: const Size(400, 600));
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.length,
      );
      await tester.pump();

      final lineStart = _paintedParagraphs(tester).first.$2.dx;
      expect(_cutMarker(tester)!.dx - lineStart, cut * _glyphWidth);
    });

    testWidgets('is shown whole once the caret moves past the cut', (
      tester,
    ) async {
      final controller = longLine();
      await pumpEditor(tester, controller, size: const Size(400, 600));
      controller.selection = TextSelection.collapsed(
        offset: controller.getLineStartOffset(1) + cut,
      );
      await settle(tester, 2);
      expect(_cutMarker(tester), isNotNull);

      controller.selection = TextSelection.collapsed(
        offset: controller.getLineStartOffset(1) + cut + 1,
      );
      await settle(tester, 2);
      expect(_cutMarker(tester), isNull);
    });

    testWidgets('scrolls to a caret placed far past the cut', (tester) async {
      final controller = longLine();
      await pumpEditor(tester, controller, size: const Size(400, 600));
      await focusEditor(tester);
      controller.selection = TextSelection.collapsed(
        offset: controller.getLineStartOffset(1) + 2 * cut,
      );
      await settle(tester, 3);

      final horizontal = _horizontalScroll(tester);
      expect(
        horizontal.pixels,
        greaterThan(2 * cut * _glyphWidth - horizontal.viewportDimension),
      );
    });

    testWidgets('is shown whole by a tap past the cut', (tester) async {
      final controller = longLine();
      await pumpEditor(tester, controller, size: const Size(400, 600));
      await focusEditor(tester);
      final lineStart = controller.getLineStartOffset(1);
      controller.selection = TextSelection.collapsed(offset: lineStart + cut);
      await settle(tester, 2);
      final horizontal = _horizontalScroll(tester);
      horizontal.jumpTo(horizontal.maxScrollExtent);
      await tester.pump();

      final marker = _cutMarker(tester)!;
      final renderer = _renderer(tester) as RenderBox;
      expect(
        marker.dx + 2 * _glyphWidth,
        lessThanOrEqualTo(renderer.size.width),
      );
      await tester.tapAt(renderer.localToGlobal(marker + const Offset(20, 8)));
      await settle(tester, 2);

      expect(_cutMarker(tester), isNull);
      expect(controller.selection.extentOffset, lineStart + cut + 1);
    });

    testWidgets('is not cut when lines wrap', (tester) async {
      final controller = longLine();
      await pumpEditor(
        tester,
        controller,
        size: const Size(400, 600),
        lineWrap: true,
      );
      await tester.pump();
      expect(_cutMarker(tester), isNull);
    });
  });
}

Offset? _cutMarker(WidgetTester tester) {
  for (final (paragraph, at) in _paintedParagraphs(tester)) {
    if (paragraph.longestLine == 2 * _glyphWidth) return at;
  }
  return null;
}

List<Rect> _rectsOf(WidgetTester tester, Set<int> colors) {
  final rects = <Rect>[];
  expect(
    _renderer(tester),
    paints..everything((method, args) {
      if (method == #drawRect &&
          colors.contains((args[1] as Paint).color.toARGB32())) {
        rects.add(args[0] as Rect);
      }
      return true;
    }),
  );
  return rects;
}

ScrollPosition _horizontalScroll(WidgetTester tester) => tester
    .stateList<ScrollableState>(find.byWidgetPredicate((w) => w is Scrollable))
    .firstWhere((s) => s.axisDirection == AxisDirection.right)
    .position;

List<Rect> _selectionRects(WidgetTester tester) {
  final rects = <Rect>[];
  expect(
    _renderer(tester),
    paints..everything((method, args) {
      if (method == #drawRect &&
          (args[1] as Paint).color.toARGB32() ==
              CodeSelectionStyle().selectionColor.toARGB32()) {
        rects.add(args[0] as Rect);
      }
      return true;
    }),
  );
  return rects;
}

List<Rect> _bracketBoxes(WidgetTester tester) {
  final boxes = <Rect>[];
  expect(
    _renderer(tester),
    paints..everything((method, args) {
      if (method == #drawRSuperellipse &&
          ((args[1] as Paint).strokeWidth - 1.2).abs() < 0.01) {
        boxes.add((args[0] as RSuperellipse).outerRect);
      }
      return true;
    }),
  );
  return boxes;
}
