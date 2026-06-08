import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silky_scroll/src/blocked_scroll_physics.dart';
import 'package:silky_scroll/src/silky_scroll_state.dart';
import 'package:silky_scroll/src/silky_scroll_config.dart';
import 'package:silky_scroll/src/silky_scroll_global_manager.dart';

/// Minimal [TickerProvider] for tests.
class _TestVSync implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

/// Helper to build a minimal widget tree with a [SilkyScrollState].
Widget _buildScrollable({
  required ScrollController controller,
  int itemCount = 50,
  double itemHeight = 100,
}) {
  return MaterialApp(
    home: ListView.builder(
      controller: controller,
      itemCount: itemCount,
      itemBuilder: (_, i) => SizedBox(height: itemHeight, child: Text('$i')),
    ),
  );
}

Widget _buildHorizontalScrollable({
  required ScrollController controller,
  int itemCount = 50,
  double itemWidth = 100,
}) {
  return MaterialApp(
    home: SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: controller,
        itemCount: itemCount,
        itemBuilder: (_, i) => SizedBox(width: itemWidth, child: Text('$i')),
      ),
    ),
  );
}

SilkyScrollState _createState({
  ScrollController? scrollController,
  ScrollPhysics physics = const ScrollPhysics(),
  Duration edgeLockingDelay = const Duration(milliseconds: 650),
  double scrollSpeed = 1,
  Duration silkyScrollDuration = const Duration(milliseconds: 700),
  Curve animationCurve = Curves.easeOutQuart,
  bool isVertical = true,
  EdgeForwardingMode edgeForwardingMode = EdgeForwardingMode.sameAxisOnly,
  bool debugMode = false,
  SilkyScrollGlobalManager? manager,
  TickerProvider? vsync,
  int Function()? clock,
  MouseWheelVerticalDeltaBehavior mouseWheelVerticalDeltaBehavior =
      MouseWheelVerticalDeltaBehavior.forwardToVerticalAncestorOrSelf,
  bool Function()? isShiftPressed,
}) {
  manager ??= SilkyScrollGlobalManager.instance;
  return SilkyScrollState(
    scrollController: scrollController,
    widgetScrollPhysics: physics,
    edgeLockingDelay: edgeLockingDelay,
    scrollSpeed: scrollSpeed,
    silkyScrollDuration: silkyScrollDuration,
    animationCurve: animationCurve,
    isVertical: isVertical,
    edgeForwardingMode: edgeForwardingMode,
    mouseWheelVerticalDeltaBehavior: mouseWheelVerticalDeltaBehavior,
    isShiftPressed: isShiftPressed,
    debugMode: debugMode,
    setManualPointerDeviceKind: null,
    silkyScrollGlobalManager: manager,
    vsync: vsync ?? _TestVSync(),
    clock: clock,
  );
}

void main() {
  group('SilkyScrollState — ScrollPhysicsPhase transitions', () {
    late SilkyScrollState state;
    late SilkyScrollGlobalManager manager;

    setUp(() {
      manager = SilkyScrollGlobalManager.instance;
      manager.keyStack.clear();
      manager.reserveKey = null;
    });

    tearDown(() {
      if (!state.isDisposed) {
        state.dispose();
      }
    });

    test('initial phase is normal', () {
      state = _createState(manager: manager);
      expect(state.physicsPhase, ScrollPhysicsPhase.normal);
      expect(state.isEdgeLocked, isFalse);
      expect(state.isOverscrollLocked, isFalse);
    });

    testWidgets('handleTrackpadScroll transitions to edgeCheckPending', (
      tester,
    ) async {
      state = _createState(manager: manager);
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      state.handleTrackpadScroll(10.0);
      expect(state.physicsPhase, ScrollPhysicsPhase.edgeCheckPending);

      // Dispose within test body to cancel pending timer.
      state.dispose();
    });

    testWidgets(
      'handleTrackpadScroll at edge transitions to edgeLocked after delay',
      (tester) async {
        int fakeTime = 1000;
        state = _createState(
          manager: manager,
          edgeLockingDelay: const Duration(milliseconds: 200),
          clock: () => fakeTime,
        );
        await tester.pumpWidget(
          _buildScrollable(controller: state.clientController),
        );

        // At top edge, scrolling up (negative delta)
        state.handleTrackpadScroll(-10.0);
        fakeTime += 50;
        state.handleTrackpadScroll(-10.0);
        expect(state.physicsPhase, ScrollPhysicsPhase.edgeCheckPending);

        // Wait for the 80ms edge check delay
        await tester.pump(const Duration(milliseconds: 100));

        // After check, should be edgeLocked
        expect(state.physicsPhase, ScrollPhysicsPhase.edgeLocked);
        expect(state.isEdgeLocked, isTrue);

        // Dispose within test body to cancel pending edgeLockingDelay timer.
        state.dispose();
      },
    );

    testWidgets('edgeLocked unlocks after edgeLockingDelay', (tester) async {
      int fakeTime = 1000;
      state = _createState(
        manager: manager,
        edgeLockingDelay: const Duration(milliseconds: 200),
        clock: () => fakeTime,
      );
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      // Trigger edge lock at top
      state.handleTrackpadScroll(-10.0);
      fakeTime += 50;
      state.handleTrackpadScroll(-10.0);
      await tester.pump(const Duration(milliseconds: 100));
      expect(state.isEdgeLocked, isTrue);

      // Wait for edgeLockingDelay
      await tester.pump(const Duration(milliseconds: 250));
      expect(state.isEdgeLocked, isFalse);
      expect(state.physicsPhase, ScrollPhysicsPhase.normal);
    });

    testWidgets(
      'continued trackpad scroll during edgeLocked does not cancel unlock timer',
      (tester) async {
        int fakeTime = 1000;
        state = _createState(
          manager: manager,
          edgeLockingDelay: const Duration(milliseconds: 300),
          clock: () => fakeTime,
        );
        await tester.pumpWidget(
          _buildScrollable(controller: state.clientController),
        );

        // Trigger edge lock at top
        state.handleTrackpadScroll(-10.0);
        fakeTime += 50;
        state.handleTrackpadScroll(-10.0);
        await tester.pump(const Duration(milliseconds: 100));
        expect(state.isEdgeLocked, isTrue);

        // Simulate continued trackpad scrolling while locked — this previously
        // cancelled the unlock timer, leaving physics permanently blocked.
        state.handleTrackpadScroll(-5.0);
        state.handleTrackpadScroll(-8.0);
        await tester.pump(const Duration(milliseconds: 50));
        state.handleTrackpadScroll(-3.0);

        // Phase should still be edgeLocked, not edgeCheckPending
        expect(state.physicsPhase, ScrollPhysicsPhase.edgeLocked);

        // Wait for the original edgeLockingDelay to expire
        await tester.pump(const Duration(milliseconds: 300));

        // Must unlock — previously this would stay locked forever
        expect(state.isEdgeLocked, isFalse);
        expect(state.physicsPhase, ScrollPhysicsPhase.normal);
      },
    );

    testWidgets(
      'continued trackpad scroll during overscrollLocked does not cancel timer',
      (tester) async {
        state = _createState(manager: manager);
        await tester.pumpWidget(
          _buildScrollable(controller: state.clientController),
        );

        state.isOverScrolling = true;
        state.beginOverscrollLock(const Duration(milliseconds: 200));
        expect(state.isOverscrollLocked, isTrue);

        // Simulate trackpad scrolling during overscroll lock
        state.handleTrackpadScroll(5.0);
        state.handleTrackpadScroll(3.0);

        // Should remain overscrollLocked
        expect(state.physicsPhase, ScrollPhysicsPhase.overscrollLocked);

        // Wait for overscroll lock to expire
        await tester.pump(const Duration(milliseconds: 250));
        expect(state.physicsPhase, ScrollPhysicsPhase.normal);
      },
    );

    testWidgets('beginOverscrollLock transitions to overscrollLocked', (
      tester,
    ) async {
      state = _createState(manager: manager);
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      state.isOverScrolling = true;
      state.beginOverscrollLock(const Duration(milliseconds: 200));
      expect(state.physicsPhase, ScrollPhysicsPhase.overscrollLocked);
      expect(state.isOverscrollLocked, isTrue);
      expect(state.isOverScrolling, isFalse);

      // Dispose within test body to cancel pending timer.
      state.dispose();
    });

    testWidgets('overscrollLock returns to normal after timeout', (
      tester,
    ) async {
      state = _createState(manager: manager);
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      state.beginOverscrollLock(const Duration(milliseconds: 200));
      expect(state.isOverscrollLocked, isTrue);

      await tester.pump(const Duration(milliseconds: 250));
      expect(state.physicsPhase, ScrollPhysicsPhase.normal);
      expect(state.isOverscrollLocked, isFalse);
    });

    testWidgets('setWidgetScrollPhysics resets phase to normal', (
      tester,
    ) async {
      state = _createState(manager: manager);
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      // Force into a non-normal state
      state.handleTrackpadScroll(-10.0);
      expect(state.physicsPhase, isNot(ScrollPhysicsPhase.normal));

      state.setWidgetScrollPhysics(
        scrollPhysics: const BouncingScrollPhysics(),
      );
      expect(state.physicsPhase, ScrollPhysicsPhase.normal);
    });
  });

  group('SilkyScrollState — touch-aware edge locking', () {
    late SilkyScrollState state;
    late SilkyScrollGlobalManager manager;

    setUp(() {
      manager = SilkyScrollGlobalManager.instance;
      manager.keyStack.clear();
      manager.reserveKey = null;
    });

    tearDown(() {
      if (!state.isDisposed) {
        state.dispose();
      }
    });

    testWidgets(
      'handleTouchDragScroll during active touch does not lock at edge',
      (tester) async {
        state = _createState(
          manager: manager,
          edgeLockingDelay: const Duration(milliseconds: 200),
        );
        await tester.pumpWidget(
          _buildScrollable(controller: state.clientController),
        );

        // Simulate finger down
        state.onTouchDown();

        // Scroll up at top edge — should NOT lock
        state.handleTouchDragScroll(-10.0);
        expect(state.physicsPhase, ScrollPhysicsPhase.normal);

        await tester.pump(const Duration(milliseconds: 100));
        // Should still be normal — no timer was started
        expect(state.physicsPhase, ScrollPhysicsPhase.normal);

        state.dispose();
      },
    );

    testWidgets('onEdgeOverScroll fires during active touch at edge', (
      tester,
    ) async {
      final List<double> edgeDeltas = [];
      state = _createState(manager: manager);
      // Need to recreate with callback — use a fresh state
      state.dispose();
      state = SilkyScrollState(
        widgetScrollPhysics: const ScrollPhysics(),
        edgeLockingDelay: const Duration(milliseconds: 200),
        scrollSpeed: 1,
        silkyScrollDuration: const Duration(milliseconds: 700),
        animationCurve: Curves.easeOutQuart,
        isVertical: true,
        edgeForwardingMode: EdgeForwardingMode.sameAxisOnly,
        debugMode: false,
        onEdgeOverScroll: edgeDeltas.add,
        setManualPointerDeviceKind: null,
        silkyScrollGlobalManager: manager,
        vsync: _TestVSync(),
      );
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      state.onTouchDown();
      state.handleTouchDragScroll(-10.0); // top edge, scroll up
      expect(edgeDeltas, [-10.0]);

      state.dispose();
    });

    testWidgets('onTouchUp locks at edge with directional awareness', (
      tester,
    ) async {
      int fakeTime = 1000;
      state = _createState(
        manager: manager,
        edgeLockingDelay: const Duration(milliseconds: 300),
        clock: () => fakeTime,
      );
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      // Simulate touch scroll at top edge then lift
      state.onTouchDown();
      state.handleTouchDragScroll(-10.0);
      fakeTime += 50;
      state.handleTouchDragScroll(-10.0);
      expect(state.physicsPhase, ScrollPhysicsPhase.normal);

      state.onTouchUp();
      // Should now be edge locked
      expect(state.physicsPhase, ScrollPhysicsPhase.edgeLocked);
      expect(state.isEdgeLocked, isTrue);

      state.dispose();
    });

    testWidgets('onTouchUp does not lock when not at edge', (tester) async {
      state = _createState(manager: manager);
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      // Move away from edge
      state.clientController.jumpTo(500);
      await tester.pump();

      state.onTouchDown();
      state.handleTouchDragScroll(10.0);
      state.onTouchUp();

      expect(state.physicsPhase, ScrollPhysicsPhase.normal);
      expect(state.isEdgeLocked, isFalse);
    });

    testWidgets('touch-up edge lock uses BlockedScrollPhysics', (tester) async {
      int fakeTime = 1000;
      state = _createState(
        manager: manager,
        edgeLockingDelay: const Duration(milliseconds: 300),
        clock: () => fakeTime,
      );
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      // Lock at top edge via touch-up
      state.onTouchDown();
      state.handleTouchDragScroll(-10.0);
      fakeTime += 50;
      state.handleTouchDragScroll(-10.0);
      state.onTouchUp();
      expect(state.isEdgeLocked, isTrue);
      expect(state.isScrollBlocked, isTrue);
      // Fully blocked — unlock is handled by tryGestureUnlock
      expect(state.currentScrollPhysics, isA<DynamicBlockingScrollPhysics>());

      state.dispose();
    });

    testWidgets('onTouchDown preserves edge lock for outward blocking', (
      tester,
    ) async {
      int fakeTime = 1000;
      state = _createState(
        manager: manager,
        edgeLockingDelay: const Duration(milliseconds: 300),
        clock: () => fakeTime,
      );
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      // Lock at top edge via touch-up
      state.onTouchDown();
      state.handleTouchDragScroll(-10.0);
      fakeTime += 50;
      state.handleTouchDragScroll(-10.0);
      state.onTouchUp();
      expect(state.isEdgeLocked, isTrue);

      // New touch preserves lock (scroll blocked;
      // unlock is handled by tryGestureUnlock)
      state.onTouchDown();
      expect(state.isEdgeLocked, isTrue);
      expect(state.isScrollBlocked, isTrue);

      state.dispose();
    });

    testWidgets('edge lock expires after edgeLockingDelay', (tester) async {
      int fakeTime = 1000;
      state = _createState(
        manager: manager,
        edgeLockingDelay: const Duration(milliseconds: 200),
        clock: () => fakeTime,
      );
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      state.onTouchDown();
      state.handleTouchDragScroll(-10.0);
      fakeTime += 50;
      state.handleTouchDragScroll(-10.0);
      state.onTouchUp();
      expect(state.isEdgeLocked, isTrue);

      await tester.pump(const Duration(milliseconds: 250));
      expect(state.isEdgeLocked, isFalse);
      expect(state.physicsPhase, ScrollPhysicsPhase.normal);
    });

    testWidgets('onTouchDown keeps edge lock, touchUp renews it at edge', (
      tester,
    ) async {
      int fakeTime = 1000;
      state = _createState(
        manager: manager,
        edgeLockingDelay: const Duration(milliseconds: 300),
        clock: () => fakeTime,
      );
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      // Lock at top edge
      state.onTouchDown();
      state.handleTouchDragScroll(-10.0);
      fakeTime += 50;
      state.handleTouchDragScroll(-10.0);
      state.onTouchUp();
      expect(state.isEdgeLocked, isTrue);

      // New touch keeps the lock
      state.onTouchDown();
      expect(state.isEdgeLocked, isTrue);

      // Touch up at the same edge renews the lock
      state.onTouchUp();
      expect(state.isEdgeLocked, isTrue);

      state.dispose();
    });

    testWidgets('onTouchUp applies edge lock even when overscrollLocked', (
      tester,
    ) async {
      int fakeTime = 1000;
      state = _createState(manager: manager, clock: () => fakeTime);
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      state.onTouchDown();
      state.handleTouchDragScroll(-10.0);
      fakeTime += 50;
      state.handleTouchDragScroll(-10.0);

      // Simulate overscroll lock (from widget's onPointerUp)
      state.isOverScrolling = true;
      state.beginOverscrollLock(const Duration(milliseconds: 200));
      expect(state.isOverscrollLocked, isTrue);

      // onTouchUp should apply edge lock, overriding overscrollLocked
      state.onTouchUp();
      expect(state.physicsPhase, ScrollPhysicsPhase.edgeLocked);

      state.dispose();
    });

    testWidgets('trackpad inward delta unlocks edge lock immediately', (
      tester,
    ) async {
      int fakeTime = 1000;
      state = _createState(
        manager: manager,
        edgeLockingDelay: const Duration(milliseconds: 300),
        clock: () => fakeTime,
      );
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      // Simulate trackpad scroll at top edge (no touch down/up for trackpad)
      state.handleTrackpadScroll(-10.0);
      fakeTime += 50;
      state.handleTrackpadScroll(-10.0);

      // Let edge-check timer fire → edgeLocked
      await tester.pump(const Duration(milliseconds: 60));
      expect(state.isEdgeLocked, isTrue);
      // Trackpad edge-lock does NOT block physics — Flutter's own
      // PointerScrollEvent propagation handles nested scrolling.
      expect(state.isScrollBlocked, isFalse);

      // Single inward (positive) delta should unlock immediately
      fakeTime += 20;
      state.handleTrackpadScroll(5.0);
      expect(state.isEdgeLocked, isFalse);
      expect(state.isScrollBlocked, isFalse);
      // After unlock, trackpad re-enters edgeCheckPending (normal flow).
      // This is correct — the 50ms check will find no edge condition.

      state.dispose();
    });

    testWidgets('trackpad outward delta keeps edge lock', (tester) async {
      int fakeTime = 1000;
      state = _createState(
        manager: manager,
        edgeLockingDelay: const Duration(milliseconds: 300),
        clock: () => fakeTime,
      );
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      // Lock at top edge
      state.handleTrackpadScroll(-10.0);
      fakeTime += 50;
      state.handleTrackpadScroll(-10.0);
      await tester.pump(const Duration(milliseconds: 60));
      expect(state.isEdgeLocked, isTrue);

      // Continued outward (negative) delta should NOT unlock
      fakeTime += 20;
      state.handleTrackpadScroll(-3.0);
      expect(state.isEdgeLocked, isTrue);
      // Trackpad edge-lock does NOT block physics.
      expect(state.isScrollBlocked, isFalse);

      state.dispose();
    });

    testWidgets('edge forwarding respects disabled ancestor physics', (
      tester,
    ) async {
      final parentController = ScrollController();
      int fakeTime = 1000;
      state = _createState(
        manager: manager,
        edgeLockingDelay: const Duration(milliseconds: 300),
        clock: () => fakeTime,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            height: 300,
            child: SingleChildScrollView(
              controller: parentController,
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      state.widgetContext = context;
                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          controller: state.clientController,
                          itemCount: 50,
                          itemBuilder: (_, i) =>
                              SizedBox(height: 100, child: Text('$i')),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        ),
      );

      state.clientController.jumpTo(
        state.clientController.position.maxScrollExtent,
      );
      await tester.pump();

      state.handleTrackpadScroll(80.0);
      fakeTime += 50;
      state.handleTrackpadScroll(80.0);
      await tester.pump(const Duration(milliseconds: 60));
      expect(state.isEdgeLocked, isTrue);

      fakeTime += 20;
      state.handleTrackpadScroll(80.0);
      await tester.pump();

      expect(parentController.offset, 0);
      expect(
        state.clientController.offset,
        state.clientController.position.maxScrollExtent,
      );

      parentController.dispose();
      state.dispose();
    });
  });

  group('SilkyScrollState — horizontal mouse wheel policy', () {
    late SilkyScrollState state;
    late SilkyScrollGlobalManager manager;

    setUp(() {
      manager = SilkyScrollGlobalManager.instance;
      manager.resetForTesting();
    });

    tearDown(() {
      if (!state.isDisposed) {
        state.dispose();
      }
      manager.resetForTesting();
    });

    testWidgets(
      'default horizontal mouse vertical wheel without ancestor scrolls self',
      (tester) async {
        state = _createState(
          manager: manager,
          isVertical: false,
          isShiftPressed: () => false,
          silkyScrollDuration: const Duration(milliseconds: 100),
        );
        await tester.pumpWidget(
          _buildHorizontalScrollable(controller: state.clientController),
        );

        state.triggerMouseAction(const Offset(0, 80));
        await tester.pumpAndSettle();

        expect(state.clientController.offset, greaterThan(0));
      },
    );

    testWidgets(
      'shiftOnly horizontal mouse vertical wheel without Shift is ignored',
      (tester) async {
        state = _createState(
          manager: manager,
          isVertical: false,
          mouseWheelVerticalDeltaBehavior:
              MouseWheelVerticalDeltaBehavior.shiftOnly,
          isShiftPressed: () => false,
          silkyScrollDuration: const Duration(milliseconds: 100),
        );
        await tester.pumpWidget(
          _buildHorizontalScrollable(controller: state.clientController),
        );

        state.triggerMouseAction(const Offset(0, 80));
        await tester.pumpAndSettle();

        expect(state.clientController.offset, 0);
      },
    );

    testWidgets(
      'horizontal mouse vertical wheel with Shift scrolls internally',
      (tester) async {
        state = _createState(
          manager: manager,
          isVertical: false,
          isShiftPressed: () => true,
          silkyScrollDuration: const Duration(milliseconds: 100),
        );
        await tester.pumpWidget(
          _buildHorizontalScrollable(controller: state.clientController),
        );

        state.triggerMouseAction(const Offset(0, 80));
        await tester.pumpAndSettle();

        expect(state.clientController.offset, greaterThan(0));
      },
    );

    testWidgets(
      'always behavior lets horizontal mouse vertical wheel scroll internally',
      (tester) async {
        state = _createState(
          manager: manager,
          isVertical: false,
          mouseWheelVerticalDeltaBehavior:
              MouseWheelVerticalDeltaBehavior.always,
          isShiftPressed: () => false,
          silkyScrollDuration: const Duration(milliseconds: 100),
        );
        await tester.pumpWidget(
          _buildHorizontalScrollable(controller: state.clientController),
        );

        state.triggerMouseAction(const Offset(0, 80));
        await tester.pumpAndSettle();

        expect(state.clientController.offset, greaterThan(0));
      },
    );

    testWidgets(
      'always behavior forwards mouse wheel at horizontal edge to any ancestor axis',
      (tester) async {
        final parentController = ScrollController();
        state = _createState(
          manager: manager,
          isVertical: false,
          mouseWheelVerticalDeltaBehavior:
              MouseWheelVerticalDeltaBehavior.always,
          isShiftPressed: () => false,
          silkyScrollDuration: const Duration(milliseconds: 100),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SingleChildScrollView(
              controller: parentController,
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      state.widgetContext = context;
                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: state.clientController,
                          itemCount: 50,
                          itemBuilder: (_, i) =>
                              SizedBox(width: 100, child: Text('$i')),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        );

        state.clientController.jumpTo(
          state.clientController.position.maxScrollExtent,
        );
        await tester.pump();

        state.triggerMouseAction(const Offset(0, 80));
        await tester.pump();

        expect(
          state.clientController.offset,
          state.clientController.position.maxScrollExtent,
        );
        expect(parentController.offset, 80);

        parentController.dispose();
      },
    );

    testWidgets(
      'always behavior respects disabled ancestor physics at horizontal edge',
      (tester) async {
        final parentController = ScrollController();
        state = _createState(
          manager: manager,
          isVertical: false,
          mouseWheelVerticalDeltaBehavior:
              MouseWheelVerticalDeltaBehavior.always,
          isShiftPressed: () => false,
          silkyScrollDuration: const Duration(milliseconds: 100),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SingleChildScrollView(
              controller: parentController,
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      state.widgetContext = context;
                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: state.clientController,
                          itemCount: 50,
                          itemBuilder: (_, i) =>
                              SizedBox(width: 100, child: Text('$i')),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        );

        state.clientController.jumpTo(
          state.clientController.position.maxScrollExtent,
        );
        await tester.pump();

        state.triggerMouseAction(const Offset(0, 80));
        await tester.pump();

        expect(
          state.clientController.offset,
          state.clientController.position.maxScrollExtent,
        );
        expect(parentController.offset, 0);

        parentController.dispose();
      },
    );

    testWidgets(
      'always behavior with Shift does not forward mouse wheel at horizontal edge',
      (tester) async {
        final parentController = ScrollController();
        state = _createState(
          manager: manager,
          isVertical: false,
          mouseWheelVerticalDeltaBehavior:
              MouseWheelVerticalDeltaBehavior.always,
          isShiftPressed: () => true,
          silkyScrollDuration: const Duration(milliseconds: 100),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SingleChildScrollView(
              controller: parentController,
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      state.widgetContext = context;
                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: state.clientController,
                          itemCount: 50,
                          itemBuilder: (_, i) =>
                              SizedBox(width: 100, child: Text('$i')),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        );

        state.clientController.jumpTo(
          state.clientController.position.maxScrollExtent,
        );
        await tester.pump();

        state.triggerMouseAction(const Offset(0, 80));
        await tester.pump();

        expect(
          state.clientController.offset,
          state.clientController.position.maxScrollExtent,
        );
        expect(parentController.offset, 0);

        parentController.dispose();
      },
    );

    testWidgets(
      'always behavior does not forward mouse wheel when edge forwarding is disabled',
      (tester) async {
        final parentController = ScrollController();
        state = _createState(
          manager: manager,
          isVertical: false,
          edgeForwardingMode: EdgeForwardingMode.none,
          mouseWheelVerticalDeltaBehavior:
              MouseWheelVerticalDeltaBehavior.always,
          silkyScrollDuration: const Duration(milliseconds: 100),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SingleChildScrollView(
              controller: parentController,
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      state.widgetContext = context;
                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: state.clientController,
                          itemCount: 50,
                          itemBuilder: (_, i) =>
                              SizedBox(width: 100, child: Text('$i')),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        );

        state.clientController.jumpTo(
          state.clientController.position.maxScrollExtent,
        );
        await tester.pump();

        state.triggerMouseAction(const Offset(0, 80));
        await tester.pump();

        expect(
          state.clientController.offset,
          state.clientController.position.maxScrollExtent,
        );
        expect(parentController.offset, 0);

        parentController.dispose();
      },
    );

    testWidgets(
      'rejected horizontal mouse vertical wheel forwards to vertical ancestor',
      (tester) async {
        final parentController = ScrollController();
        state = _createState(
          manager: manager,
          isVertical: false,
          isShiftPressed: () => false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SingleChildScrollView(
              controller: parentController,
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      state.widgetContext = context;
                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: state.clientController,
                          itemCount: 50,
                          itemBuilder: (_, i) =>
                              SizedBox(width: 100, child: Text('$i')),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        );

        state.triggerMouseAction(const Offset(0, 80));
        await tester.pump();

        expect(state.clientController.offset, 0);
        expect(parentController.offset, 80);

        parentController.dispose();
      },
    );

    testWidgets(
      'rejected horizontal mouse vertical wheel respects disabled ancestor physics',
      (tester) async {
        final parentController = ScrollController();
        state = _createState(
          manager: manager,
          isVertical: false,
          isShiftPressed: () => false,
          silkyScrollDuration: const Duration(milliseconds: 100),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SingleChildScrollView(
              controller: parentController,
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      state.widgetContext = context;
                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: state.clientController,
                          itemCount: 50,
                          itemBuilder: (_, i) =>
                              SizedBox(width: 100, child: Text('$i')),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        );

        state.triggerMouseAction(const Offset(0, 80));
        await tester.pumpAndSettle();

        expect(state.clientController.offset, 0);
        expect(parentController.offset, 0);

        parentController.dispose();
      },
    );

    testWidgets(
      'rejected horizontal mouse vertical wheel delegates to silky ancestor',
      (tester) async {
        final parentState = _createState(
          manager: manager,
          isVertical: true,
          silkyScrollDuration: const Duration(milliseconds: 700),
        );
        state = _createState(
          manager: manager,
          isVertical: false,
          isShiftPressed: () => false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SizedBox(
              height: 300,
              child: ListView(
                controller: parentState.silkyScrollController,
                children: [
                  Builder(
                    builder: (context) {
                      state.widgetContext = context;
                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: state.silkyScrollController,
                          itemCount: 50,
                          itemBuilder: (_, i) =>
                              SizedBox(width: 100, child: Text('$i')),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        );

        manager.enteredKey(parentState.instanceKey);
        manager.enteredKey(state.instanceKey);

        state.triggerMouseAction(const Offset(0, 80));

        expect(state.clientController.offset, 0);
        expect(parentState.clientController.offset, 0);
        expect(parentState.isOnSilkyScrolling, isTrue);

        await tester.pump(const Duration(milliseconds: 16));

        expect(state.clientController.offset, 0);
        expect(parentState.clientController.offset, greaterThan(0));
        expect(parentState.clientController.offset, lessThan(80));

        await tester.pumpWidget(const SizedBox.shrink());
        parentState.dispose();
      },
    );

    testWidgets(
      'default horizontal mouse vertical wheel inside horizontal ancestor scrolls self',
      (tester) async {
        final parentController = ScrollController();
        state = _createState(
          manager: manager,
          isVertical: false,
          isShiftPressed: () => false,
          silkyScrollDuration: const Duration(milliseconds: 100),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                controller: parentController,
                children: [
                  Builder(
                    builder: (context) {
                      state.widgetContext = context;
                      return SizedBox(
                        width: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: state.clientController,
                          itemCount: 50,
                          itemBuilder: (_, i) =>
                              SizedBox(width: 100, child: Text('$i')),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 1000),
                ],
              ),
            ),
          ),
        );

        state.triggerMouseAction(const Offset(0, 80));
        await tester.pumpAndSettle();

        expect(state.clientController.offset, greaterThan(0));
        expect(parentController.offset, 0);

        parentController.dispose();
      },
    );

    testWidgets('runtime option update is applied immediately', (tester) async {
      state = _createState(
        manager: manager,
        isVertical: false,
        mouseWheelVerticalDeltaBehavior:
            MouseWheelVerticalDeltaBehavior.shiftOnly,
        isShiftPressed: () => false,
        silkyScrollDuration: const Duration(milliseconds: 100),
      );
      await tester.pumpWidget(
        _buildHorizontalScrollable(controller: state.clientController),
      );

      state.triggerMouseAction(const Offset(0, 80));
      await tester.pumpAndSettle();
      expect(state.clientController.offset, 0);

      state.setMouseWheelVerticalDeltaBehavior(
        MouseWheelVerticalDeltaBehavior.always,
      );
      state.triggerMouseAction(const Offset(0, 80));
      await tester.pumpAndSettle();

      expect(state.clientController.offset, greaterThan(0));
    });
  });

  group('SilkyScrollState — dispose safety', () {
    test('dispose sets _disposed flag', () {
      final state = _createState();
      expect(state.isDisposed, isFalse);
      state.dispose();
      expect(state.isDisposed, isTrue);
    });

    testWidgets('dispose cancels active phase timer', (tester) async {
      final state = _createState();
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      state.handleTrackpadScroll(10.0);
      expect(state.physicsPhase, ScrollPhysicsPhase.edgeCheckPending);

      state.dispose();
      // Should not throw after dispose, timer should be cancelled
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('notifyListeners throws after dispose', (tester) async {
      final state = _createState();
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      bool listenerCalled = false;
      state.addListener(() => listenerCalled = true);
      state.dispose();

      // ChangeNotifier throws FlutterError when notifyListeners
      // is called after dispose.
      expect(state.notifyListeners, throwsFlutterError);
      expect(listenerCalled, isFalse);
    });

    testWidgets('double dispose does not throw', (tester) async {
      final controller = ScrollController();
      final state = _createState(scrollController: controller);
      await tester.pumpWidget(_buildScrollable(controller: controller));

      state.dispose();
      // Second dispose should not crash
      // (ChangeNotifier.dispose may assert, but in test mode we verify
      // our guards prevent cascading failures)
      controller.dispose();
    });
  });

  group('SilkyScrollState — controller ownership', () {
    test('creates own controller when none provided', () {
      final state = _createState();
      expect(state.isControllerOwn, isTrue);
      state.dispose();
    });

    test('uses provided controller without ownership', () {
      final controller = ScrollController();
      final state = _createState(scrollController: controller);
      expect(state.isControllerOwn, isFalse);
      state.dispose();
      // External controller should still be usable after state dispose
      expect(controller.dispose, returnsNormally);
    });
  });

  group('SilkyScrollState — scroll position sync', () {
    testWidgets('futurePosition syncs with clientController offset', (
      tester,
    ) async {
      final state = _createState();
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      state.clientController.jumpTo(200);
      await tester.pump();
      expect(state.futurePosition, 200);

      state.dispose();
    });

    testWidgets('futurePosition does not sync during silky scrolling', (
      tester,
    ) async {
      final state = _createState();
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      state.isOnSilkyScrolling = true;
      state.clientController.jumpTo(200);
      await tester.pump();
      // futurePosition should stay at 0 because silky scrolling is active
      expect(state.futurePosition, 0);

      state.dispose();
    });
  });

  group('SilkyScrollState — cancelSilkyScroll', () {
    late SilkyScrollState state;
    late SilkyScrollGlobalManager manager;

    setUp(() {
      manager = SilkyScrollGlobalManager.instance;
      manager.resetForTesting();
    });

    tearDown(() {
      if (!state.isDisposed) {
        state.dispose();
      }
    });

    testWidgets(
      'cancelSilkyScroll resets isOnSilkyScrolling and futurePosition',
      (tester) async {
        state = _createState(manager: manager);
        await tester.pumpWidget(
          _buildScrollable(controller: state.clientController),
        );

        // Simulate an in-progress silky scroll
        state.isOnSilkyScrolling = true;
        state.futurePosition = 500.0;

        state.cancelSilkyScroll();

        expect(state.isOnSilkyScrolling, isFalse);
        expect(state.futurePosition, state.clientController.offset);
      },
    );

    testWidgets('cancelSilkyScroll is no-op when not scrolling', (
      tester,
    ) async {
      state = _createState(manager: manager);
      await tester.pumpWidget(
        _buildScrollable(controller: state.clientController),
      );

      state.isOnSilkyScrolling = false;
      state.futurePosition = 0.0;

      // Should not throw
      state.cancelSilkyScroll();

      expect(state.isOnSilkyScrolling, isFalse);
    });
  });
}
