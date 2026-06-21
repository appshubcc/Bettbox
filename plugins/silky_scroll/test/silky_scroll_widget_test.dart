import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silky_scroll/silky_scroll.dart';

void main() {
  group('SilkyScroll widget', () {
    setUp(SilkyScrollGlobalManager.instance.resetForTesting);

    tearDown(SilkyScrollGlobalManager.instance.resetForTesting);
    testWidgets('renders child via builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SilkyScroll(
            builder: (context, controller, physics, _) => ListView(
              controller: controller,
              physics: physics,
              children: const [Text('Hello Silky')],
            ),
          ),
        ),
      );

      expect(find.text('Hello Silky'), findsOneWidget);
    });

    testWidgets('passes controller to builder', (tester) async {
      ScrollController? capturedController;

      await tester.pumpWidget(
        MaterialApp(
          home: SilkyScroll(
            builder: (context, controller, physics, _) {
              capturedController = controller;
              return ListView(
                controller: controller,
                physics: physics,
                children: const [SizedBox(height: 100)],
              );
            },
          ),
        ),
      );

      expect(capturedController, isNotNull);
      expect(capturedController, isA<SilkyScrollController>());
    });

    testWidgets('respects external ScrollController', (tester) async {
      final externalController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: SilkyScroll(
            controller: externalController,
            builder: (context, controller, physics, _) => ListView.builder(
              controller: controller,
              physics: physics,
              itemCount: 50,
              itemBuilder: (_, i) => SizedBox(height: 100, child: Text('$i')),
            ),
          ),
        ),
      );

      // The external controller should be linked
      expect(externalController.hasClients, isTrue);

      externalController.dispose();
    });

    testWidgets('SilkyScroll.fromConfig applies config', (tester) async {
      const config = SilkyScrollConfig(
        scrollSpeed: 2.0,
        enableStretchEffect: false,
        mouseWheelVerticalDeltaBehavior: MouseWheelVerticalDeltaBehavior.always,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SilkyScroll.fromConfig(
            config: config,
            builder: (context, controller, physics, _) => ListView(
              controller: controller,
              physics: physics,
              children: const [Text('Config Test')],
            ),
          ),
        ),
      );

      expect(find.text('Config Test'), findsOneWidget);
      final silky = tester.widget<SilkyScroll>(find.byType(SilkyScroll));
      expect(
        silky.mouseWheelVerticalDeltaBehavior,
        MouseWheelVerticalDeltaBehavior.always,
      );
    });

    testWidgets('SilkyScroll.fromConfig updates behavior without remounting', (
      tester,
    ) async {
      Future<void> pumpWithConfig(SilkyScrollConfig config) {
        return tester.pumpWidget(
          MaterialApp(
            home: SilkyScroll.fromConfig(
              config: config,
              builder: (context, controller, physics, _) => ListView(
                controller: controller,
                physics: physics,
                children: const [SizedBox(height: 100)],
              ),
            ),
          ),
        );
      }

      await pumpWithConfig(const SilkyScrollConfig(scrollSpeed: 1.0));
      final state = tester.state(find.byType(SilkyScroll)) as dynamic;
      final silkyState = state.silkyScrollState as dynamic;

      await pumpWithConfig(
        const SilkyScrollConfig(
          scrollSpeed: 3.0,
          silkyScrollDuration: Duration(milliseconds: 400),
          animationCurve: Curves.linear,
          edgeLockingDelay: Duration(milliseconds: 250),
          decayLogFactor: 18,
        ),
      );

      expect(tester.state(find.byType(SilkyScroll)), same(state));
      expect(silkyState.scrollSpeed, 3.0);
      expect(silkyState.silkyScrollDuration, const Duration(milliseconds: 400));
      expect(silkyState.animationCurve, Curves.linear);
      expect(silkyState.edgeLockingDelay, const Duration(milliseconds: 250));
      expect(silkyState.decayLogFactor, 18);
    });

    testWidgets('mouseWheelVerticalDeltaBehavior defaults to forward-or-self', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SilkyScroll(
            builder: (context, controller, physics, _) => ListView(
              controller: controller,
              physics: physics,
              children: const [Text('Default Option Test')],
            ),
          ),
        ),
      );

      final silky = tester.widget<SilkyScroll>(find.byType(SilkyScroll));
      expect(
        silky.mouseWheelVerticalDeltaBehavior,
        MouseWheelVerticalDeltaBehavior.forwardToVerticalAncestorOrSelf,
      );
    });

    testWidgets('disposes without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SilkyScroll(
            builder: (context, controller, physics, _) => ListView(
              controller: controller,
              physics: physics,
              children: const [SizedBox(height: 100)],
            ),
          ),
        ),
      );

      // Replace with a different widget to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      // No errors expected
    });

    testWidgets(
      'blockWebOverscrollBehaviorX: true calls incrementWidgetBlock on mount',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SilkyScroll(
              builder: (context, controller, physics, _) => ListView(
                controller: controller,
                physics: physics,
                children: const [SizedBox(height: 100)],
              ),
            ),
          ),
        );

        // Default blockWebOverscrollBehaviorX is true → increment called
        // Dispose should decrement
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        await tester.pump();
      },
    );

    testWidgets(
      'blockWebOverscrollBehaviorX: false does not call incrementWidgetBlock',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SilkyScroll(
              blockWebOverscrollBehaviorX: false,
              builder: (context, controller, physics, _) => ListView(
                controller: controller,
                physics: physics,
                children: const [SizedBox(height: 100)],
              ),
            ),
          ),
        );

        // Dispose should not call decrement
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        await tester.pump();
      },
    );

    testWidgets(
      'didUpdateWidget toggles blockWebOverscrollBehaviorX correctly',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SilkyScroll(
              blockWebOverscrollBehaviorX: true,
              builder: (context, controller, physics, _) => ListView(
                controller: controller,
                physics: physics,
                children: const [SizedBox(height: 100)],
              ),
            ),
          ),
        );

        // Change to false → should call decrementWidgetBlock
        await tester.pumpWidget(
          MaterialApp(
            home: SilkyScroll(
              blockWebOverscrollBehaviorX: false,
              builder: (context, controller, physics, _) => ListView(
                controller: controller,
                physics: physics,
                children: const [SizedBox(height: 100)],
              ),
            ),
          ),
        );

        // Change back to true → should call incrementWidgetBlock
        await tester.pumpWidget(
          MaterialApp(
            home: SilkyScroll(
              blockWebOverscrollBehaviorX: true,
              builder: (context, controller, physics, _) => ListView(
                controller: controller,
                physics: physics,
                children: const [SizedBox(height: 100)],
              ),
            ),
          ),
        );

        // Clean up
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        await tester.pump();
      },
    );

    testWidgets('SilkyScroll.fromConfig passes blockWebOverscrollBehaviorX', (
      tester,
    ) async {
      const config = SilkyScrollConfig(blockWebOverscrollBehaviorX: false);

      await tester.pumpWidget(
        MaterialApp(
          home: SilkyScroll.fromConfig(
            config: config,
            builder: (context, controller, physics, _) => ListView(
              controller: controller,
              physics: physics,
              children: const [Text('Config Blocking Test')],
            ),
          ),
        ),
      );

      expect(find.text('Config Blocking Test'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
    });

    testWidgets(
      'Shift mouse wheel at horizontal edge does not scroll vertical ancestor',
      (tester) async {
        final parentController = ScrollController();
        final horizontalController = ScrollController();

        await tester.pumpWidget(
          MaterialApp(
            home: SizedBox(
              height: 300,
              child: SingleChildScrollView(
                controller: parentController,
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: SilkyScroll(
                        controller: horizontalController,
                        direction: Axis.horizontal,
                        isShiftPressed: () => true,
                        builder: (context, controller, physics, _) {
                          return ListView.builder(
                            key: const Key('horizontal-list'),
                            scrollDirection: Axis.horizontal,
                            controller: controller,
                            physics: physics,
                            itemCount: 40,
                            itemBuilder: (_, index) =>
                                SizedBox(width: 100, child: Text('$index')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 2000),
                  ],
                ),
              ),
            ),
          ),
        );

        horizontalController.jumpTo(
          horizontalController.position.maxScrollExtent,
        );
        await tester.pump();

        await tester.sendEventToBinding(
          PointerScrollEvent(
            position: tester.getCenter(
              find.byKey(const Key('horizontal-list')),
            ),
            kind: PointerDeviceKind.mouse,
            scrollDelta: const Offset(0, 80),
          ),
        );
        await tester.pump();

        expect(
          horizontalController.offset,
          horizontalController.position.maxScrollExtent,
        );
        expect(parentController.offset, 0);

        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        horizontalController.dispose();
        parentController.dispose();
      },
    );
  });
}
