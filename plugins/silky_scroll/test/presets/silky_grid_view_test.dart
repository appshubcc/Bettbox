import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silky_scroll/silky_scroll.dart';

void main() {
  group('SilkyGridView', () {
    setUp(SilkyScrollGlobalManager.instance.resetForTesting);
    tearDown(SilkyScrollGlobalManager.instance.resetForTesting);

    testWidgets('default constructor renders children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SilkyGridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            children: const [Text('A'), Text('B'), Text('C')],
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('.builder renders items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SilkyGridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: 4,
            itemBuilder: (_, i) => Text('Item $i'),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('.count renders children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SilkyGridView.count(
            crossAxisCount: 3,
            children: const [Text('X'), Text('Y'), Text('Z')],
          ),
        ),
      );

      expect(find.text('X'), findsOneWidget);
      expect(find.text('Z'), findsOneWidget);
    });

    testWidgets('.extent renders children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SilkyGridView.extent(
            maxCrossAxisExtent: 200,
            children: const [Text('P'), Text('Q')],
          ),
        ),
      );

      expect(find.text('P'), findsOneWidget);
      expect(find.text('Q'), findsOneWidget);
    });

    testWidgets('respects external ScrollController', (tester) async {
      final controller = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: SilkyGridView.builder(
            controller: controller,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: 20,
            itemBuilder: (_, i) => Text('$i'),
          ),
        ),
      );

      expect(controller.hasClients, isTrue);
      controller.dispose();
    });

    testWidgets('silkyConfig overrides individual params', (tester) async {
      const config = SilkyScrollConfig(
        scrollSpeed: 2.0,
        mouseWheelVerticalDeltaBehavior:
            MouseWheelVerticalDeltaBehavior.forwardToVerticalAncestor,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SilkyGridView.count(
            silkyConfig: config,
            scrollSpeed: 5.0,
            mouseWheelVerticalDeltaBehavior:
                MouseWheelVerticalDeltaBehavior.always,
            crossAxisCount: 2,
            children: const [Text('Configured')],
          ),
        ),
      );

      expect(find.text('Configured'), findsOneWidget);
      final silky = tester.widget<SilkyScroll>(find.byType(SilkyScroll));
      expect(
        silky.mouseWheelVerticalDeltaBehavior,
        MouseWheelVerticalDeltaBehavior.forwardToVerticalAncestor,
      );
    });

    testWidgets('accepts mouse wheel vertical-delta behavior parameter', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SilkyGridView.count(
            mouseWheelVerticalDeltaBehavior:
                MouseWheelVerticalDeltaBehavior.always,
            crossAxisCount: 2,
            children: const [Text('Opt in')],
          ),
        ),
      );

      final silky = tester.widget<SilkyScroll>(find.byType(SilkyScroll));
      expect(
        silky.mouseWheelVerticalDeltaBehavior,
        MouseWheelVerticalDeltaBehavior.always,
      );
    });
  });
}
