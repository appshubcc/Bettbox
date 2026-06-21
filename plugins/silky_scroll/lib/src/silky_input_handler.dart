import 'package:flutter/gestures.dart';
import 'silky_scroll_config.dart';
import 'silky_scroll_global_manager.dart';

enum MouseWheelForwardingResult {
  forwarded,
  noVerticalAncestor,
  blockedAtAncestorExtent,
  blockedByAncestorPhysics,
}

bool _isConsumedForwardingResult(MouseWheelForwardingResult result) {
  return result == MouseWheelForwardingResult.forwarded ||
      result == MouseWheelForwardingResult.blockedAtAncestorExtent ||
      result == MouseWheelForwardingResult.blockedByAncestorPhysics;
}

/// Callback interface used by [SilkyInputHandler] to communicate
/// input events back to the owning [SilkyScrollState].
abstract interface class SilkyInputHandlerDelegate {
  bool get isVertical;
  double get scrollSpeed;
  bool get isWebPlatform;
  MouseWheelVerticalDeltaBehavior get mouseWheelVerticalDeltaBehavior;
  bool get isShiftPressed;

  void handleTrackpadScroll(double delta);
  void handleTouchDragScroll(double delta);
  void handleMouseScroll(double delta, double scrollSpeed);
  MouseWheelForwardingResult forwardUnhandledMouseWheelVerticalDelta(
    double delta,
  );
  MouseWheelForwardingResult forwardAlwaysMouseWheelDeltaAtEdge(double delta);

  void Function(double delta)? get onScroll;
  Function(PointerDeviceKind) get setPointerDeviceKind;

  SilkyScrollGlobalManager get silkyScrollGlobalManager;
}

/// Routes mouse, trackpad, and touch input to the correct scroll handler.
///
/// Extracted from [SilkyScrollState] to follow the Single
/// Responsibility Principle.
final class SilkyInputHandler {
  const SilkyInputHandler(this._delegate);

  final SilkyInputHandlerDelegate _delegate;

  /// Processes touch or trackpad scroll input.
  ///
  /// Routes to [handleTrackpadScroll] or [handleTouchDragScroll]
  /// based on [kind].
  void triggerTouchAction(Offset delta, PointerDeviceKind kind) {
    final double scrollDelta;
    if (kind == PointerDeviceKind.trackpad && _delegate.isWebPlatform) {
      scrollDelta = _delegate.isVertical ? delta.dy : delta.dx;
    } else {
      scrollDelta = _delegate.isVertical ? -delta.dy : -delta.dx;
    }

    if (kind == PointerDeviceKind.trackpad) {
      _delegate.handleTrackpadScroll(scrollDelta);
    } else {
      _delegate.handleTouchDragScroll(scrollDelta);
    }

    _delegate.onScroll?.call(scrollDelta);
  }

  /// Processes mouse-wheel scroll input.
  void triggerMouseAction(Offset scrollDelta) {
    _delegate.setPointerDeviceKind(PointerDeviceKind.mouse);

    final double scrollDeltaY = scrollDelta.dy;
    final bool hasVerticalWheelDelta = scrollDeltaY.abs() > 0;
    final bool hasHorizontalWheelDelta = scrollDelta.dx.abs() > 0;
    final bool shouldRouteHorizontalVerticalWheel =
        !_delegate.isVertical &&
        hasVerticalWheelDelta &&
        !hasHorizontalWheelDelta &&
        !_delegate.isShiftPressed;

    if (shouldRouteHorizontalVerticalWheel) {
      final behavior = _delegate.mouseWheelVerticalDeltaBehavior;
      if (behavior == MouseWheelVerticalDeltaBehavior.shiftOnly) {
        _delegate.silkyScrollGlobalManager.clearTrackpadMemory();
        return;
      }

      if (behavior != MouseWheelVerticalDeltaBehavior.always) {
        final result = _delegate.forwardUnhandledMouseWheelVerticalDelta(
          scrollDeltaY,
        );
        if (_isConsumedForwardingResult(result) ||
            behavior ==
                MouseWheelVerticalDeltaBehavior.forwardToVerticalAncestor) {
          _delegate.silkyScrollGlobalManager.clearTrackpadMemory();
          return;
        }
      }
    }

    final double effectiveDelta = _delegate.isVertical
        ? scrollDeltaY
        : hasHorizontalWheelDelta
        ? scrollDelta.dx
        : scrollDeltaY;

    if (!_delegate.isVertical &&
        _delegate.mouseWheelVerticalDeltaBehavior ==
            MouseWheelVerticalDeltaBehavior.always &&
        !_delegate.isShiftPressed) {
      final result = _delegate.forwardAlwaysMouseWheelDeltaAtEdge(
        effectiveDelta,
      );
      if (_isConsumedForwardingResult(result)) {
        _delegate.silkyScrollGlobalManager.clearTrackpadMemory();
        return;
      }
    }

    _delegate.onScroll?.call(effectiveDelta);
    _delegate.handleMouseScroll(effectiveDelta, _delegate.scrollSpeed);
    _delegate.silkyScrollGlobalManager.clearTrackpadMemory();
  }
}
