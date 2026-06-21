import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silky_scroll/src/silky_scroll_animator.dart';

/// Minimal [TickerProvider] for tests.
class _TestVSync implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

/// Minimal delegate for testing [SilkyScrollAnimator] in isolation.
class _FakeAnimatorDelegate implements SilkyScrollAnimatorDelegate {
  _FakeAnimatorDelegate({
    required this.clientController,
    bool bouncingPhysics = false,
  }) : isPlatformBouncingScrollPhysics = bouncingPhysics;

  @override
  final ScrollController clientController;

  @override
  final Curve animationCurve = Curves.easeOutQuart;

  @override
  final Duration silkyScrollDuration = const Duration(milliseconds: 700);

  @override
  final double decayLogFactor = kDefaultDecayLogFactor;

  @override
  final bool isPlatformBouncingScrollPhysics;

  @override
  double futurePosition = 0;

  @override
  bool prevDeltaPositive = false;

  @override
  bool isOnSilkyScrolling = false;

  @override
  bool isDisposed = false;

  bool silkyTickerActiveState = false;

  @override
  void setSilkyTickerActive(bool active) {
    silkyTickerActiveState = active;
  }

  int triggerNativeBounceCount = 0;

  @override
  void triggerNativeBounce() {
    triggerNativeBounceCount++;
  }
}

void main() {
  group('SilkyScrollAnimator', () {
    late ScrollController controller;
    late _FakeAnimatorDelegate delegate;
    late SilkyScrollAnimator animator;

    setUp(() {
      controller = ScrollController();
      delegate = _FakeAnimatorDelegate(clientController: controller);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('animateToScroll sets isOnSilkyScrolling to true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ListView.builder(
            controller: controller,
            itemCount: 50,
            itemBuilder: (_, i) => SizedBox(height: 100, child: Text('$i')),
          ),
        ),
      );

      animator = SilkyScrollAnimator(
        delegate,
        _TestVSync(),
        maxBounceOvershoot: 150,
      );
      animator.animateToScroll(100, 1.0);
      expect(delegate.isOnSilkyScrolling, isTrue);

      // Let Ticker-based animation complete
      await tester.pumpAndSettle();
      expect(delegate.isOnSilkyScrolling, isFalse);
      animator.dispose();
    });

    testWidgets('animateToScroll updates futurePosition', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ListView.builder(
            controller: controller,
            itemCount: 50,
            itemBuilder: (_, i) => SizedBox(height: 100, child: Text('$i')),
          ),
        ),
      );

      animator = SilkyScrollAnimator(
        delegate,
        _TestVSync(),
        maxBounceOvershoot: 150,
      );
      animator.animateToScroll(100, 1.0);
      // futurePosition = offset(0) + 100 * 1.0 = 100
      expect(delegate.futurePosition, 100.0);

      await tester.pumpAndSettle();
      animator.dispose();
    });

    testWidgets(
      'futurePosition is clamped to maxScrollExtent + maxBounceOvershoot',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ListView.builder(
              controller: controller,
              itemCount: 50,
              itemBuilder: (_, i) => SizedBox(height: 100, child: Text('$i')),
            ),
          ),
        );

        final bouncingDelegate = _FakeAnimatorDelegate(
          clientController: controller,
          bouncingPhysics: true,
        );
        animator = SilkyScrollAnimator(
          bouncingDelegate,
          _TestVSync(),
          maxBounceOvershoot: 150,
        );
        final maxExtent = controller.position.maxScrollExtent;
        // Scroll way past max
        animator.animateToScroll(maxExtent * 10, 1.0);
        expect(bouncingDelegate.futurePosition, maxExtent + 150);

        animator.cancel();
        animator.dispose();
      },
    );

    testWidgets('direction reversal resets futurePosition from offset', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ListView.builder(
            controller: controller,
            itemCount: 50,
            itemBuilder: (_, i) => SizedBox(height: 100, child: Text('$i')),
          ),
        ),
      );

      animator = SilkyScrollAnimator(
        delegate,
        _TestVSync(),
        maxBounceOvershoot: 150,
      );

      // Scroll down
      animator.animateToScroll(100, 1.0);
      expect(delegate.prevDeltaPositive, isTrue);

      await tester.pumpAndSettle();

      // Scroll up (direction change)
      animator.animateToScroll(-50, 1.0);
      expect(delegate.prevDeltaPositive, isFalse);

      await tester.pumpAndSettle();
      animator.dispose();
    });

    testWidgets('cancel stops animation immediately', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ListView.builder(
            controller: controller,
            itemCount: 50,
            itemBuilder: (_, i) => SizedBox(height: 100, child: Text('$i')),
          ),
        ),
      );

      animator = SilkyScrollAnimator(
        delegate,
        _TestVSync(),
        maxBounceOvershoot: 150,
      );
      animator.animateToScroll(100, 1.0);
      expect(delegate.isOnSilkyScrolling, isTrue);

      animator.cancel();
      expect(delegate.isOnSilkyScrolling, isFalse);
      animator.dispose();
    });
  });
}
