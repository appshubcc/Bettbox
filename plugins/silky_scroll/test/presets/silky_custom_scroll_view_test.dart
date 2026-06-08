import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silky_scroll/silky_scroll.dart';

void main() {
  group('SilkyCustomScrollView', () {
    setUp(SilkyScrollGlobalManager.instance.resetForTesting);
    tearDown(SilkyScrollGlobalManager.instance.resetForTesting);

    testWidgets('renders slivers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SilkyCustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: Text('Sliver A')),
              SliverToBoxAdapter(child: Text('Sliver B')),
            ],
          ),
        ),
      );

      expect(find.text('Sliver A'), findsOneWidget);
      expect(find.text('Sliver B'), findsOneWidget);
    });

    testWidgets('respects external ScrollController', (tester) async {
      final controller = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: SilkyCustomScrollView(
            controller: controller,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => SizedBox(height: 100, child: Text('$i')),
                  childCount: 50,
                ),
              ),
            ],
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
        const MaterialApp(
          home: SilkyCustomScrollView(
            silkyConfig: config,
            scrollSpeed: 5.0,
            mouseWheelVerticalDeltaBehavior:
                MouseWheelVerticalDeltaBehavior.always,
            slivers: [SliverToBoxAdapter(child: Text('Configured'))],
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
        const MaterialApp(
          home: SilkyCustomScrollView(
            mouseWheelVerticalDeltaBehavior:
                MouseWheelVerticalDeltaBehavior.always,
            slivers: [SliverToBoxAdapter(child: Text('Opt in'))],
          ),
        ),
      );

      final silky = tester.widget<SilkyScroll>(find.byType(SilkyScroll));
      expect(
        silky.mouseWheelVerticalDeltaBehavior,
        MouseWheelVerticalDeltaBehavior.always,
      );
    });

    testWidgets('passes scrollDirection', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SilkyCustomScrollView(
            scrollDirection: Axis.horizontal,
            slivers: [
              SliverToBoxAdapter(child: SizedBox(width: 100, child: Text('H'))),
            ],
          ),
        ),
      );

      expect(find.text('H'), findsOneWidget);
    });
  });
}
