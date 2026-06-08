import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silky_scroll/src/silky_input_handler.dart';
import 'package:silky_scroll/src/silky_scroll_config.dart';
import 'package:silky_scroll/src/silky_scroll_global_manager.dart';

/// Minimal delegate for testing [SilkyInputHandler] in isolation.
class _FakeInputDelegate implements SilkyInputHandlerDelegate {
  @override
  bool isVertical = true;

  @override
  double scrollSpeed = 1.0;

  @override
  bool isWebPlatform = false;

  @override
  MouseWheelVerticalDeltaBehavior mouseWheelVerticalDeltaBehavior =
      MouseWheelVerticalDeltaBehavior.forwardToVerticalAncestor;

  @override
  bool isShiftPressed = false;

  double? lastTrackpadDelta;
  double? lastTouchDragDelta;
  double? lastMouseDelta;
  double? lastMouseSpeed;
  double? lastOnScrollDelta;
  double? lastForwardedMouseWheelDelta;
  PointerDeviceKind? lastPointerDeviceKind;
  MouseWheelForwardingResult forwardingResult =
      MouseWheelForwardingResult.forwarded;

  @override
  void handleTrackpadScroll(double delta) {
    lastTrackpadDelta = delta;
  }

  @override
  void handleTouchDragScroll(double delta) {
    lastTouchDragDelta = delta;
  }

  @override
  void handleMouseScroll(double delta, double scrollSpeed) {
    lastMouseDelta = delta;
    lastMouseSpeed = scrollSpeed;
  }

  @override
  MouseWheelForwardingResult forwardUnhandledMouseWheelVerticalDelta(
    double delta,
  ) {
    lastForwardedMouseWheelDelta = delta;
    return forwardingResult;
  }

  double? lastForwardedAlwaysMouseWheelEdgeDelta;
  MouseWheelForwardingResult alwaysMouseWheelEdgeForwardingResult =
      MouseWheelForwardingResult.noVerticalAncestor;

  @override
  MouseWheelForwardingResult forwardAlwaysMouseWheelDeltaAtEdge(double delta) {
    lastForwardedAlwaysMouseWheelEdgeDelta = delta;
    return alwaysMouseWheelEdgeForwardingResult;
  }

  @override
  void Function(double delta)? onScroll;

  @override
  late Function(PointerDeviceKind) setPointerDeviceKind = (kind) {
    lastPointerDeviceKind = kind;
  };

  @override
  final SilkyScrollGlobalManager silkyScrollGlobalManager =
      SilkyScrollGlobalManager.instance;
}

void main() {
  group('SilkyInputHandler', () {
    late _FakeInputDelegate delegate;
    late SilkyInputHandler handler;

    setUp(() {
      delegate = _FakeInputDelegate();
      handler = SilkyInputHandler(delegate);
    });

    group('triggerTouchAction', () {
      test(
        'vertical touch inverts delta.dy and routes to handleTouchDragScroll',
        () {
          delegate.isVertical = true;
          handler.triggerTouchAction(
            const Offset(0, 10),
            PointerDeviceKind.touch,
          );
          // Non-web: -delta.dy = -10
          expect(delegate.lastTouchDragDelta, -10.0);
          expect(delegate.lastTrackpadDelta, isNull);
        },
      );

      test(
        'horizontal touch inverts delta.dx and routes to handleTouchDragScroll',
        () {
          delegate.isVertical = false;
          handler.triggerTouchAction(
            const Offset(10, 0),
            PointerDeviceKind.touch,
          );
          expect(delegate.lastTouchDragDelta, -10.0);
          expect(delegate.lastTrackpadDelta, isNull);
        },
      );

      test(
        'trackpad on web uses delta directly and routes to handleTrackpadScroll',
        () {
          delegate.isWebPlatform = true;
          delegate.isVertical = true;
          handler.triggerTouchAction(
            const Offset(0, 10),
            PointerDeviceKind.trackpad,
          );
          expect(delegate.lastTrackpadDelta, 10.0);
          expect(delegate.lastTouchDragDelta, isNull);
        },
      );

      test(
        'trackpad on non-web inverts delta and routes to handleTrackpadScroll',
        () {
          delegate.isWebPlatform = false;
          delegate.isVertical = true;
          handler.triggerTouchAction(
            const Offset(0, 10),
            PointerDeviceKind.trackpad,
          );
          expect(delegate.lastTrackpadDelta, -10.0);
          expect(delegate.lastTouchDragDelta, isNull);
        },
      );

      test('calls onScroll callback', () {
        double? scrolledDelta;
        delegate.onScroll = (delta) => scrolledDelta = delta;
        handler.triggerTouchAction(
          const Offset(0, -5),
          PointerDeviceKind.touch,
        );
        expect(scrolledDelta, 5.0); // inverted: -(-5) = 5
      });
    });

    group('triggerMouseAction', () {
      test('sets pointer device kind to mouse', () {
        handler.triggerMouseAction(const Offset(0, 10));
        expect(delegate.lastPointerDeviceKind, PointerDeviceKind.mouse);
      });

      test('forwards delta and scrollSpeed to handleMouseScroll', () {
        handler.triggerMouseAction(const Offset(0, 42));
        expect(delegate.lastMouseDelta, 42.0);
        expect(delegate.lastMouseSpeed, 1.0);
      });

      test('calls onScroll callback', () {
        double? scrolledDelta;
        delegate.onScroll = (delta) => scrolledDelta = delta;
        handler.triggerMouseAction(const Offset(0, 10));
        expect(scrolledDelta, 10.0);
      });

      test('horizontal mouse vertical delta requires Shift by default', () {
        delegate.isVertical = false;
        delegate.isShiftPressed = false;

        handler.triggerMouseAction(const Offset(0, 10));

        expect(delegate.lastMouseDelta, isNull);
        expect(delegate.lastOnScrollDelta, isNull);
        expect(delegate.lastForwardedMouseWheelDelta, 10.0);
      });

      test('horizontal mouse vertical delta is handled with Shift', () {
        delegate.isVertical = false;
        delegate.isShiftPressed = true;

        handler.triggerMouseAction(const Offset(0, 10));

        expect(delegate.lastMouseDelta, 10.0);
        expect(delegate.lastForwardedMouseWheelDelta, isNull);
      });

      test('horizontal mouse vertical delta opt-in preserves old behavior', () {
        delegate.isVertical = false;
        delegate.mouseWheelVerticalDeltaBehavior =
            MouseWheelVerticalDeltaBehavior.always;

        handler.triggerMouseAction(const Offset(0, 10));

        expect(delegate.lastMouseDelta, 10.0);
        expect(delegate.lastForwardedMouseWheelDelta, isNull);
      });

      test('always behavior forwards mouse wheel at edge before self', () {
        delegate.isVertical = false;
        delegate.isShiftPressed = false;
        delegate.mouseWheelVerticalDeltaBehavior =
            MouseWheelVerticalDeltaBehavior.always;
        delegate.alwaysMouseWheelEdgeForwardingResult =
            MouseWheelForwardingResult.forwarded;

        handler.triggerMouseAction(const Offset(0, 10));

        expect(delegate.lastForwardedAlwaysMouseWheelEdgeDelta, 10.0);
        expect(delegate.lastMouseDelta, isNull);
      });

      test('always behavior with Shift does not forward at edge', () {
        delegate.isVertical = false;
        delegate.isShiftPressed = true;
        delegate.mouseWheelVerticalDeltaBehavior =
            MouseWheelVerticalDeltaBehavior.always;
        delegate.alwaysMouseWheelEdgeForwardingResult =
            MouseWheelForwardingResult.forwarded;

        handler.triggerMouseAction(const Offset(0, 10));

        expect(delegate.lastForwardedAlwaysMouseWheelEdgeDelta, isNull);
        expect(delegate.lastMouseDelta, 10.0);
      });

      test('always behavior scrolls self when there is no edge ancestor', () {
        delegate.isVertical = false;
        delegate.isShiftPressed = false;
        delegate.mouseWheelVerticalDeltaBehavior =
            MouseWheelVerticalDeltaBehavior.always;
        delegate.alwaysMouseWheelEdgeForwardingResult =
            MouseWheelForwardingResult.noVerticalAncestor;

        handler.triggerMouseAction(const Offset(0, 10));

        expect(delegate.lastForwardedAlwaysMouseWheelEdgeDelta, 10.0);
        expect(delegate.lastMouseDelta, 10.0);
      });

      test('horizontal mouse horizontal delta is handled without Shift', () {
        delegate.isVertical = false;

        handler.triggerMouseAction(const Offset(12, 0));

        expect(delegate.lastMouseDelta, 12.0);
        expect(delegate.lastForwardedMouseWheelDelta, isNull);
      });

      test(
        'default horizontal mouse vertical delta scrolls self without ancestor',
        () {
          delegate.isVertical = false;
          delegate.mouseWheelVerticalDeltaBehavior =
              MouseWheelVerticalDeltaBehavior.forwardToVerticalAncestorOrSelf;
          delegate.forwardingResult =
              MouseWheelForwardingResult.noVerticalAncestor;

          handler.triggerMouseAction(const Offset(0, 10));

          expect(delegate.lastMouseDelta, 10.0);
          expect(delegate.lastForwardedMouseWheelDelta, 10.0);
        },
      );
    });
  });
}
