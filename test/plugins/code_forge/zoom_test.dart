import 'dart:typed_data';

import 'package:code_forge/code_forge.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

import 'support.dart';

void main() {
  setUpAll(initEditorNative);
  group('pinch zoom', _pinchZoom);
  group('pinch zoom tree stability', _pinchZoomTreeStability);
  group('pinch release', _pinchRelease);
  group('zoom anchor', _zoomAnchor);
  group('wheel zoom', _wheelZoom);
  group('trackpad pinch', _trackpadPinch);
}

void _pinchZoom() {
  testWidgets('a pinch keeps the scrolled editor mounted and in place', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = CodeForgeController()
      ..text = [for (var i = 0; i < 200; i++) 'key$i: value'].join('\n');
    ScrollController? scroll;
    double? committed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CodeForge(
            controller: controller,
            language: editorYamlMode,
            editorTheme: atomOneLightTheme,
            textStyle: const TextStyle(fontSize: 16, height: 1.25),
            enablePinchZoom: true,
            onZoomEnd: (zoom) => committed = zoom,
            onContextMenu: (_, _) {},
            suggestionPopupBuilder: (_, _) => const SizedBox.shrink(),
            scrollbarBuilder: (_, details, child) {
              scroll = details.controller;
              return child;
            },
          ),
        ),
      ),
    );
    await settle(tester);
    scroll!.jumpTo(800);
    await tester.pump();
    final scrollable = tester.state(find.byType(TwoDimensionalScrollable));

    final center = tester.getCenter(find.byType(CodeForge));
    final one = await tester.startGesture(
      center - const Offset(0, 50),
      pointer: 1,
      kind: PointerDeviceKind.touch,
    );
    final two = await tester.startGesture(
      center + const Offset(0, 50),
      pointer: 2,
      kind: PointerDeviceKind.touch,
    );
    await tester.pump();
    await one.moveBy(const Offset(0, -20));
    await two.moveBy(const Offset(0, 20));
    await tester.pump();

    expect(
      identical(
        tester.state(find.byType(TwoDimensionalScrollable)),
        scrollable,
      ),
      isTrue,
    );
    expect(scroll!.offset, 800);

    await one.up();
    await two.up();
    await settle(tester);

    expect(committed, isNotNull);
    expect(
      identical(
        tester.state(find.byType(TwoDimensionalScrollable)),
        scrollable,
      ),
      isTrue,
    );
  });

  testWidgets('robust pinch handling with 3 pointers and pointer release', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = CodeForgeController()
      ..text = [for (var i = 0; i < 200; i++) 'key$i: value'].join('\n');
    double? committed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CodeForge(
            controller: controller,
            language: editorYamlMode,
            editorTheme: atomOneLightTheme,
            enablePinchZoom: true,
            onZoomEnd: (zoom) => committed = zoom,
            onContextMenu: (_, _) {},
            suggestionPopupBuilder: (_, _) => const SizedBox.shrink(),
            scrollbarBuilder: (_, _, child) => child,
          ),
        ),
      ),
    );
    await settle(tester);

    final center = tester.getCenter(find.byType(CodeForge));
    final p1 = await tester.startGesture(
      center - const Offset(0, 40),
      pointer: 1,
      kind: PointerDeviceKind.touch,
    );
    final p2 = await tester.startGesture(
      center + const Offset(0, 40),
      pointer: 2,
      kind: PointerDeviceKind.touch,
    );
    await tester.pump();

    await p1.moveBy(const Offset(0, -20));
    await p2.moveBy(const Offset(0, 20));
    await tester.pump();

    final p3 = await tester.startGesture(
      center + const Offset(50, 0),
      pointer: 3,
      kind: PointerDeviceKind.touch,
    );
    await tester.pump();

    await p1.up();
    await tester.pump();

    expect(committed, isNotNull);
    final firstCommit = committed;

    await p3.moveBy(const Offset(10, 10));
    await p2.moveBy(const Offset(10, 10));
    await tester.pump();

    expect(committed, firstCommit);

    await p2.up();
    await p3.up();
    await settle(tester);
  });

  testWidgets(
    'dynamically disabling pinch zoom safely resets transform state',
    (tester) async {
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = CodeForgeController()
        ..text = [for (var i = 0; i < 200; i++) 'key$i: value'].join('\n');

      Widget buildApp({required bool enable}) {
        return MaterialApp(
          home: Scaffold(
            body: CodeForge(
              controller: controller,
              language: editorYamlMode,
              editorTheme: atomOneLightTheme,
              enablePinchZoom: enable,
              onContextMenu: (_, _) {},
              suggestionPopupBuilder: (_, _) => const SizedBox.shrink(),
              scrollbarBuilder: (_, _, child) => child,
            ),
          ),
        );
      }

      await tester.pumpWidget(buildApp(enable: true));
      await settle(tester);

      final center = tester.getCenter(find.byType(CodeForge));
      final p1 = await tester.startGesture(
        center - const Offset(0, 30),
        pointer: 1,
        kind: PointerDeviceKind.touch,
      );
      final p2 = await tester.startGesture(
        center + const Offset(0, 30),
        pointer: 2,
        kind: PointerDeviceKind.touch,
      );
      await tester.pump();
      await p1.moveBy(const Offset(0, -20));
      await p2.moveBy(const Offset(0, 20));
      await tester.pump();

      await tester.pumpWidget(buildApp(enable: false));
      await tester.pump();

      final transformFinder = find.byType(Transform);
      expect(transformFinder, findsWidgets);
      final transformWidget = tester
          .widgetList<Transform>(transformFinder)
          .firstWhere((t) => t.alignment == Alignment.topLeft);
      expect(transformWidget.transform.isIdentity(), isTrue);

      await p1.up();
      await p2.up();
      await settle(tester);
    },
  );

  testWidgets(
    'a pinch out stays at the left edge and a pinch in tracks the focal point',
    (tester) async {
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = CodeForgeController()
        ..text = [for (var i = 0; i < 200; i++) 'key$i: value'].join('\n');
      ScrollController? vscroll;
      var zoom = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => CodeForge(
                controller: controller,
                language: editorYamlMode,
                editorTheme: atomOneLightTheme,
                textStyle: TextStyle(fontSize: 14 * zoom),
                zoom: zoom,
                enablePinchZoom: true,
                onZoomEnd: (value) => setState(() => zoom = value),
                onContextMenu: (_, _) {},
                suggestionPopupBuilder: (_, _) => const SizedBox.shrink(),
                scrollbarBuilder: (_, details, child) {
                  vscroll = details.controller;
                  return child;
                },
              ),
            ),
          ),
        ),
      );
      await settle(tester);

      final center = tester.getCenter(find.byType(CodeForge));
      final p1 = await tester.startGesture(
        center - const Offset(0, 50),
        pointer: 1,
        kind: PointerDeviceKind.touch,
      );
      final p2 = await tester.startGesture(
        center + const Offset(0, 50),
        pointer: 2,
        kind: PointerDeviceKind.touch,
      );
      await tester.pump();

      await p1.moveBy(const Offset(0, 20));
      await p2.moveBy(const Offset(0, -20));
      await tester.pump();

      var transform = tester
          .widgetList<Transform>(find.byType(Transform))
          .firstWhere((t) => t.alignment == Alignment.topLeft)
          .transform;
      expect(transform.storage[12], inInclusiveRange(0.0, 8.0));
      expect(transform.storage[13], 0.0);
      expect(transform.storage[0], lessThan(1.0));
      final backdrop = find.ancestor(
        of: find.byWidgetPredicate(
          (widget) =>
              widget is Transform && widget.alignment == Alignment.topLeft,
        ),
        matching: find.byType(ColoredBox),
      );
      expect(
        tester.widget<ColoredBox>(backdrop.first).color,
        atomOneLightTheme['root']?.backgroundColor,
      );
      expect(
        tester.getSize(backdrop.first),
        tester.getSize(find.byType(TwoDimensionalScrollable)),
      );

      await p1.moveBy(const Offset(0, -60));
      await p2.moveBy(const Offset(0, 60));
      await tester.pump();

      transform = tester
          .widgetList<Transform>(find.byType(Transform))
          .firstWhere((t) => t.alignment == Alignment.topLeft)
          .transform;
      expect(transform.storage[0], greaterThan(1.0));
      expect(transform.storage[13], lessThan(0.0));

      final initialPixels = vscroll!.offset;
      await p1.up();
      await p2.up();
      await settle(tester);

      expect(vscroll!.offset, greaterThan(initialPixels));
    },
  );
}

void _pinchZoomTreeStability() {
  testWidgets(
    'verifies tree instability when conditionally swapping ClipRect/Transform wrapper',
    (tester) async {
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final controller = CodeForgeController()
        ..text = [for (var i = 0; i < 200; i++) 'line $i: data'].join('\n');
      ScrollController? scrollController;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeForge(
              controller: controller,
              language: editorYamlMode,
              editorTheme: atomOneLightTheme,
              enablePinchZoom: true,
              onContextMenu: (_, _) {},
              suggestionPopupBuilder: (_, _) => const SizedBox.shrink(),
              scrollbarBuilder: (_, details, child) {
                scrollController = details.controller;
                return child;
              },
            ),
          ),
        ),
      );
      await settle(tester);

      scrollController!.jumpTo(600);
      await tester.pump();

      final initialScrollableElement = tester.element(
        find.byType(TwoDimensionalScrollable),
      );
      final initialScrollableState = tester.state(
        find.byType(TwoDimensionalScrollable),
      );

      final center = tester.getCenter(find.byType(CodeForge));
      final touch1 = await tester.startGesture(
        center - const Offset(0, 40),
        pointer: 1,
        kind: PointerDeviceKind.touch,
      );
      final touch2 = await tester.startGesture(
        center + const Offset(0, 40),
        pointer: 2,
        kind: PointerDeviceKind.touch,
      );
      await tester.pump();

      await touch1.moveBy(const Offset(0, -30));
      await touch2.moveBy(const Offset(0, 30));
      await tester.pump();

      final inPinchScrollableElement = tester.element(
        find.byType(TwoDimensionalScrollable),
      );
      final inPinchScrollableState = tester.state(
        find.byType(TwoDimensionalScrollable),
      );

      expect(
        identical(inPinchScrollableElement, initialScrollableElement),
        isTrue,
        reason:
            'TwoDimensionalScrollable element should not be unmounted during pinch',
      );
      expect(
        identical(inPinchScrollableState, initialScrollableState),
        isTrue,
        reason:
            'TwoDimensionalScrollable state should not be recreated during pinch',
      );

      await touch1.up();
      await touch2.up();
      await settle(tester);

      final afterPinchScrollableElement = tester.element(
        find.byType(TwoDimensionalScrollable),
      );
      final afterPinchScrollableState = tester.state(
        find.byType(TwoDimensionalScrollable),
      );

      expect(
        identical(afterPinchScrollableElement, initialScrollableElement),
        isTrue,
        reason:
            'TwoDimensionalScrollable element should remain identical after pinch ends',
      );
      expect(
        identical(afterPinchScrollableState, initialScrollableState),
        isTrue,
        reason:
            'TwoDimensionalScrollable state should remain identical after pinch ends',
      );
    },
  );
}

const _viewSize = Size(400, 600);
const _baseFontSize = 16.0;
const _focal = Offset(250, 300);
final _frameKey = GlobalKey();

class _Editor {
  ScrollController? vertical;
  double zoom;

  _Editor(this.zoom);

  Future<void> pump(
    WidgetTester tester,
    String text, {
    bool lineWrap = false,
  }) async {
    tester.view.physicalSize = _viewSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = CodeForgeController()..text = text;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            key: _frameKey,
            child: StatefulBuilder(
              builder: (context, setState) => CodeForge(
                controller: controller,
                language: editorYamlMode,
                editorTheme: atomOneLightTheme,
                lineWrap: lineWrap,
                textStyle: TextStyle(
                  fontSize: _baseFontSize * zoom,
                  height: 1.25,
                ),
                lineNumberStyle: TextStyle(
                  fontSize: _baseFontSize * (zoom < 1 ? zoom : 1),
                ),
                zoom: zoom,
                lineNumberMaxZoom: 1,
                onZoomEnd: (value) {
                  final fontSize = (_baseFontSize * value * 2).round() / 2;
                  setState(() => zoom = fontSize / _baseFontSize);
                },
                onContextMenu: (_, _) {},
                suggestionPopupBuilder: (_, _) => const SizedBox.shrink(),
                scrollbarBuilder: (_, details, child) {
                  vertical = details.controller;
                  return child;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await settle(tester);
  }

  ScrollPosition get position => vertical!.position;
}

Future<(TestGesture, TestGesture)> _pinch(
  WidgetTester tester,
  double scale,
) async {
  final one = await tester.startGesture(
    _focal - const Offset(0, 50),
    pointer: 1,
    kind: PointerDeviceKind.touch,
  );
  final two = await tester.startGesture(
    _focal + const Offset(0, 50),
    pointer: 2,
    kind: PointerDeviceKind.touch,
  );
  await tester.pump();
  final travel = Offset(0, 50 * (scale - 1) / 2);
  for (var i = 0; i < 2; i++) {
    await one.moveBy(-travel);
    await two.moveBy(travel);
    await tester.pump();
  }
  return (one, two);
}

Future<void> _release(
  WidgetTester tester,
  (TestGesture, TestGesture) fingers,
) async {
  await fingers.$1.up();
  await tester.pump();
  await fingers.$2.up();
  await tester.pump();
}

Matrix4 _preview(WidgetTester tester) => tester
    .widgetList<Transform>(find.byType(Transform))
    .firstWhere((transform) => transform.alignment == Alignment.topLeft)
    .transform;

Future<ByteData> _capture(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_frameKey),
  );
  final data = await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData();
    image.dispose();
    return bytes;
  });
  return data!;
}

double _difference(ByteData a, ByteData b, Rect area) {
  final width = _viewSize.width.toInt();
  var different = 0;
  var total = 0;
  for (var y = area.top.toInt(); y < area.bottom; y++) {
    for (var x = area.left.toInt(); x < area.right; x++) {
      final at = (y * width + x) * 4;
      total++;
      for (var channel = 0; channel < 3; channel++) {
        if ((a.getUint8(at + channel) - b.getUint8(at + channel)).abs() > 64) {
          different++;
          break;
        }
      }
    }
  }
  return different / total;
}

String _lines(String Function(int) line) =>
    [for (var i = 0; i < 200; i++) line(i)].join('\n');

void _pinchRelease() {
  const textArea = Rect.fromLTRB(90, 0, 400, 600);

  testWidgets('releasing a pinch in leaves short lines where it showed them', (
    tester,
  ) async {
    final editor = _Editor(1);
    await editor.pump(tester, _lines((i) => 'key$i: value$i'));
    editor.vertical!.jumpTo(800);
    await settle(tester);
    final before = await _capture(tester);

    final fingers = await _pinch(tester, 1.25);
    final shown = await _capture(tester);
    await _release(tester, fingers);
    final released = await _capture(tester);

    expect(editor.zoom, 1.25);
    expect(_difference(before, shown, textArea), greaterThan(0.1));
    expect(_difference(shown, released, textArea), lessThan(0.02));
    await settle(tester);
  });

  testWidgets('releasing a pinch in leaves long lines where it showed them', (
    tester,
  ) async {
    final editor = _Editor(1);
    await editor.pump(tester, _lines((i) => 'key$i: ${'value$i ' * 12}'));
    editor.vertical!.jumpTo(800);
    await settle(tester);

    final fingers = await _pinch(tester, 1.25);
    expect(_preview(tester).storage[12], lessThan(-40));
    final shown = await _capture(tester);
    await _release(tester, fingers);
    final released = await _capture(tester);

    expect(_difference(shown, released, textArea), lessThan(0.02));
    await settle(tester);
  });

  testWidgets('releasing a pinch out leaves the text where it showed it', (
    tester,
  ) async {
    final editor = _Editor(1);
    await editor.pump(tester, _lines((i) => 'key$i: ${'value$i ' * 12}'));
    editor.vertical!.jumpTo(800);
    await settle(tester);

    final fingers = await _pinch(tester, 0.75);
    final preview = _preview(tester);
    final top = preview.storage[13];
    expect(top, closeTo(_focal.dy * 0.25, 0.01));
    final shown = await _capture(tester);
    await _release(tester, fingers);
    final released = await _capture(tester);

    expect(editor.zoom, 0.75);
    expect(
      _difference(
        shown,
        released,
        Rect.fromLTRB(70, top + 4, 296, top + _viewSize.height * 0.75 - 4),
      ),
      lessThan(0.02),
    );
    await settle(tester);
  });

  testWidgets('a pinch out at the top of the document stays at the top', (
    tester,
  ) async {
    final editor = _Editor(1);
    await editor.pump(tester, _lines((i) => 'key$i: value$i'));

    final fingers = await _pinch(tester, 0.75);
    expect(_preview(tester).storage[13], 0);
    await _release(tester, fingers);

    expect(editor.position.pixels, 0);
    await settle(tester);
  });

  testWidgets('a pinch too small to change the size leaves the view alone', (
    tester,
  ) async {
    final editor = _Editor(1);
    await editor.pump(tester, _lines((i) => 'key$i: value$i'));
    editor.vertical!.jumpTo(800);
    await settle(tester);

    final fingers = await _pinch(tester, 1.01);
    await _release(tester, fingers);

    expect(editor.zoom, 1);
    expect(editor.position.pixels, 800);
    expect(_preview(tester).isIdentity(), isTrue);
    await settle(tester);
  });

  for (final (from, to) in const [(1.0, 1.25), (1.0, 0.75), (0.75, 1.0)]) {
    testWidgets('wrapped lines stay under the fingers from $from to $to', (
      tester,
    ) async {
      final editor = _Editor(from);
      await editor.pump(tester, _lines((_) => 'x' * 170), lineWrap: true);
      editor.vertical!.jumpTo(800);
      await settle(tester);
      final height =
          editor.position.maxScrollExtent + editor.position.viewportDimension;

      final fingers = await _pinch(tester, to / from);
      await _release(tester, fingers);
      final zoomedHeight =
          editor.position.maxScrollExtent + editor.position.viewportDimension;

      expect(editor.zoom, to);
      expect(
        editor.position.pixels + _focal.dy,
        closeTo((800 + _focal.dy) * zoomedHeight / height, 1),
      );
      await settle(tester);
    });

    testWidgets('wrapped lines are laid out once from $from to $to', (
      tester,
    ) async {
      final editor = _Editor(from);
      await editor.pump(
        tester,
        _lines((i) => 'key$i: ${'x' * (150 + i % 37)}'),
        lineWrap: true,
      );
      editor.vertical!.jumpTo(800);
      await settle(tester);

      final fingers = await _pinch(tester, to / from);
      await _release(tester, fingers);
      final released = editor.position.maxScrollExtent;
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();

      expect(editor.position.maxScrollExtent, released);
      await settle(tester);
    });
  }
}

void _zoomAnchor() {
  testWidgets('a font size change keeps the top line in place', (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = CodeForgeController()
      ..text = [for (var i = 0; i < 200; i++) 'key$i: value'].join('\n');
    ScrollController? scroll;

    Widget editor(double fontSize) => MaterialApp(
      home: Scaffold(
        body: CodeForge(
          controller: controller,
          language: editorYamlMode,
          editorTheme: atomOneLightTheme,
          textStyle: TextStyle(fontSize: fontSize, height: 1.25),
          onContextMenu: (_, _) {},
          suggestionPopupBuilder: (_, _) => const SizedBox.shrink(),
          scrollbarBuilder: (_, details, child) {
            scroll = details.controller;
            return child;
          },
        ),
      ),
    );

    await tester.pumpWidget(editor(16));
    await settle(tester);
    scroll!.jumpTo(40 * 20.0);
    await tester.pump();

    await tester.pumpWidget(editor(24));

    expect(scroll!.offset, closeTo(40 * 30.0, 0.5));
  });
}

Future<void> _wheel(
  WidgetTester tester,
  double dy, {
  bool control = true,
}) async {
  final pointer = TestPointer(1, PointerDeviceKind.mouse);
  if (control) await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendEventToBinding(pointer.hover(_focal));
  await tester.sendEventToBinding(pointer.scroll(Offset(0, dy)));
  if (control) await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await settle(tester, 2);
}

void _wheelZoom() {
  testWidgets('control and the wheel zoom in around the pointer', (
    tester,
  ) async {
    final editor = _Editor(1);
    await editor.pump(tester, _lines((i) => 'key$i: value$i'));
    editor.vertical!.jumpTo(800);
    await settle(tester);

    await _wheel(tester, -100);

    expect(editor.zoom, greaterThan(1));
    expect(
      editor.position.pixels,
      closeTo((800 + _focal.dy) * editor.zoom - _focal.dy, 2),
    );
  });

  testWidgets('control and the wheel zoom out', (tester) async {
    final editor = _Editor(1);
    await editor.pump(tester, _lines((i) => 'key$i: value$i'));

    await _wheel(tester, 100);

    expect(editor.zoom, lessThan(1));
  });

  testWidgets('the wheel alone scrolls without zooming', (tester) async {
    final editor = _Editor(1);
    await editor.pump(tester, _lines((i) => 'key$i: value$i'));

    await _wheel(tester, 100, control: false);

    expect(editor.zoom, 1);
    expect(editor.position.pixels, greaterThan(0));
  });

  testWidgets('control and the wheel at the largest size do not scroll', (
    tester,
  ) async {
    final editor = _Editor(1.5);
    await editor.pump(tester, _lines((i) => 'key$i: value$i'));
    editor.vertical!.jumpTo(800);
    await settle(tester);

    await _wheel(tester, -100);

    expect(editor.zoom, 1.5);
    expect(editor.position.pixels, 800);
  });
}

void _trackpadPinch() {
  const textArea = Rect.fromLTRB(90, 0, 400, 600);

  Future<TestPointer> pinch(WidgetTester tester, double scale) async {
    final pointer = TestPointer(1, PointerDeviceKind.trackpad);
    await tester.sendEventToBinding(pointer.panZoomStart(_focal));
    for (final value in [1.02, 1.05, 1.05 * scale]) {
      await tester.sendEventToBinding(
        pointer.panZoomUpdate(_focal, scale: value),
      );
      await tester.pump();
    }
    return pointer;
  }

  testWidgets('a trackpad pinch zooms and leaves the text where it showed it', (
    tester,
  ) async {
    final editor = _Editor(1);
    await editor.pump(tester, _lines((i) => 'key$i: value$i'));
    editor.vertical!.jumpTo(800);
    await settle(tester);
    final before = await _capture(tester);

    final pointer = await pinch(tester, 1.25);
    final shown = await _capture(tester);
    await tester.sendEventToBinding(pointer.panZoomEnd());
    await tester.pump();
    final released = await _capture(tester);

    expect(editor.zoom, 1.25);
    expect(_difference(before, shown, textArea), greaterThan(0.1));
    expect(_difference(shown, released, textArea), lessThan(0.02));
    expect(_preview(tester).isIdentity(), isTrue);
    await settle(tester);
  });

  testWidgets('a trackpad pinch locks scrolling until it ends', (tester) async {
    final editor = _Editor(1);
    await editor.pump(tester, _lines((i) => 'key$i: value$i'));
    editor.vertical!.jumpTo(800);
    await settle(tester);

    final pointer = await pinch(tester, 1.25);
    await tester.sendEventToBinding(
      pointer.panZoomUpdate(_focal, pan: const Offset(0, -200), scale: 1.3125),
    );
    await tester.pump();

    expect(editor.position.pixels, 800);
    await tester.sendEventToBinding(pointer.panZoomEnd());
    await settle(tester);
  });

  testWidgets('a two finger trackpad scroll scrolls without zooming', (
    tester,
  ) async {
    final editor = _Editor(1);
    await editor.pump(tester, _lines((i) => 'key$i: value$i'));
    final pointer = TestPointer(1, PointerDeviceKind.trackpad);

    await tester.sendEventToBinding(pointer.panZoomStart(_focal));
    for (var i = 1; i <= 5; i++) {
      await tester.sendEventToBinding(
        pointer.panZoomUpdate(_focal, pan: Offset(0, -40.0 * i)),
      );
      await tester.pump();
    }
    await tester.sendEventToBinding(pointer.panZoomEnd());
    await settle(tester);

    expect(editor.zoom, 1);
    expect(editor.position.pixels, greaterThan(0));
    expect(_preview(tester).isIdentity(), isTrue);
  });
}
