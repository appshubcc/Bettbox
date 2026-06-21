import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silky_scroll/silky_scroll.dart';

void main() {
  group('SilkyListView', () {
    setUp(SilkyScrollGlobalManager.instance.resetForTesting);
    tearDown(SilkyScrollGlobalManager.instance.resetForTesting);

    testWidgets('default constructor renders children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SilkyListView(children: [const Text('A'), const Text('B')]),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('.builder renders items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SilkyListView.builder(
            itemCount: 5,
            itemBuilder: (_, i) => Text('Item $i'),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
    });

    testWidgets('.separated renders items and separators', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SilkyListView.separated(
            itemCount: 3,
            itemBuilder: (_, i) => Text('Item $i'),
            separatorBuilder: (_, __) => const Divider(),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('respects external ScrollController', (tester) async {
      final controller = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: SilkyListView.builder(
            controller: controller,
            itemCount: 50,
            itemBuilder: (_, i) => SizedBox(height: 100, child: Text('$i')),
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
          home: SilkyListView.builder(
            silkyConfig: config,
            scrollSpeed: 5.0, // should be overridden by config
            mouseWheelVerticalDeltaBehavior:
                MouseWheelVerticalDeltaBehavior.always,
            itemCount: 3,
            itemBuilder: (_, i) => Text('$i'),
          ),
        ),
      );

      // Widget builds successfully — config takes priority
      expect(find.text('0'), findsOneWidget);
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
          home: SilkyListView.builder(
            mouseWheelVerticalDeltaBehavior:
                MouseWheelVerticalDeltaBehavior.always,
            itemCount: 1,
            itemBuilder: (_, i) => Text('$i'),
          ),
        ),
      );

      final silky = tester.widget<SilkyScroll>(find.byType(SilkyScroll));
      expect(
        silky.mouseWheelVerticalDeltaBehavior,
        MouseWheelVerticalDeltaBehavior.always,
      );
    });

    testWidgets('passes scrollDirection and reverse', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SilkyListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: true,
            itemCount: 5,
            itemBuilder: (_, i) => SizedBox(width: 100, child: Text('Item $i')),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets('passes padding and shrinkWrap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SilkyListView(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            children: const [Text('Padded')],
          ),
        ),
      );

      expect(find.text('Padded'), findsOneWidget);
    });
  });
}
