import 'package:flutter/material.dart';

/// Mutable state controlling whether scrolling is dynamically blocked.
///
/// Shared across all [DynamicBlockingScrollPhysics] instances created
/// by [DynamicBlockingScrollPhysics.applyTo], so flipping [isBlocked]
/// immediately affects the active [ScrollPosition] without changing
/// the physics [runtimeType].
class ScrollBlockingState {
  bool isBlocked = false;
}

/// Scroll physics that can dynamically block/unblock user scrolling
/// without changing [runtimeType].
///
/// When [blockingState.isBlocked] is `true`, behaves like
/// [NeverScrollableScrollPhysics]: user drag produces zero offset,
/// ballistic simulations are suppressed, and pointer-scroll events
/// are rejected.
///
/// Because the [runtimeType] stays constant, Flutter's
/// `Scrollable._shouldUpdatePosition` never triggers a position
/// recreation, preserving the active drag gesture across
/// block ↔ unblock transitions.
final class DynamicBlockingScrollPhysics extends ScrollPhysics {
  const DynamicBlockingScrollPhysics({
    super.parent,
    required this.blockingState,
  });

  /// Small tolerance so that floating-point rounding near the edge
  /// is not mistaken for genuine overscroll.
  static const double _kOverscrollTolerance = 0.5;

  final ScrollBlockingState blockingState;

  @override
  DynamicBlockingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return DynamicBlockingScrollPhysics(
      parent: buildParent(ancestor),
      blockingState: blockingState,
    );
  }

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    final pixels = newPosition.pixels;
    // When the position is already in the overscroll region (past the
    // old scroll extents), preserve it.  This prevents a child-widget
    // rebuild that changes content dimensions from snapping an active
    // BouncingScrollPhysics bounce back to the edge.
    if (pixels < oldPosition.minScrollExtent - _kOverscrollTolerance ||
        pixels > oldPosition.maxScrollExtent + _kOverscrollTolerance) {
      return pixels;
    }
    return super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (blockingState.isBlocked) return 0.0;
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    if (blockingState.isBlocked) return false;
    return super.shouldAcceptUserOffset(position);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (blockingState.isBlocked) return null;
    return super.createBallisticSimulation(position, velocity);
  }

  @override
  bool get allowImplicitScrolling {
    if (blockingState.isBlocked) return false;
    return super.allowImplicitScrolling;
  }
}

/// Scroll physics that completely blocks scrolling.
///
/// Used internally by [SilkyScroll] to temporarily disable scroll
/// when the scrollable content has reached an edge.
final class BlockedScrollPhysics extends NeverScrollableScrollPhysics {
  const BlockedScrollPhysics({super.parent});

  @override
  BlockedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return BlockedScrollPhysics(parent: buildParent(ancestor));
  }
}
