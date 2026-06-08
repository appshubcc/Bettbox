import 'package:flutter/material.dart';
import 'silky_scroll_animator.dart';

/// Controls how edge-locked scroll deltas are forwarded to ancestor
/// [Scrollable] widgets.
enum EdgeForwardingMode {
  /// Never forward scroll deltas to ancestor scrollables at edges.
  none,

  /// Forward only when the ancestor scrollable's axis direction matches
  /// this scrollable's axis direction.
  sameAxisOnly,

  /// Always forward scroll deltas to the nearest ancestor scrollable,
  /// regardless of axis direction.
  always,
}

/// Controls how a horizontal [SilkyScroll] handles a regular mouse wheel's
/// vertical delta when Shift is not pressed.
enum MouseWheelVerticalDeltaBehavior {
  /// Ignore the vertical wheel delta. Shift is required for vertical wheel
  /// input to drive horizontal scrolling.
  shiftOnly,

  /// Always use the vertical wheel delta to scroll this horizontal scrollable.
  always,

  /// Forward the vertical wheel delta to the nearest vertical ancestor
  /// scrollable. If no such ancestor is the nearest scrollable, ignore it.
  forwardToVerticalAncestor,

  /// Forward to the nearest vertical ancestor when possible; otherwise scroll
  /// this horizontal scrollable. This is the default because it preserves
  /// natural page scrolling while keeping standalone and horizontal-in-
  /// horizontal scrollables usable with a mouse wheel.
  forwardToVerticalAncestorOrSelf,
}

const MouseWheelVerticalDeltaBehavior _kDefaultMouseWheelVerticalDeltaBehavior =
    MouseWheelVerticalDeltaBehavior.forwardToVerticalAncestorOrSelf;

/// Configuration data class that groups [SilkyScroll] scroll-behavior
/// parameters into a single object.
///
/// Use this to share a common scroll configuration across multiple
/// [SilkyScroll] instances, or to simplify widget construction when
/// many parameters need to be customized.
///
/// ```dart
/// const config = SilkyScrollConfig(
///   silkyScrollDuration: Duration(milliseconds: 1600),
///   scrollSpeed: 1.5,
/// );
///
/// SilkyScroll.fromConfig(
///   config: config,
///   builder: (context, controller, physics) => ListView(...),
/// )
/// ```
@immutable
final class SilkyScrollConfig {
  const SilkyScrollConfig({
    this.silkyScrollDuration = const Duration(milliseconds: 1600),
    this.scrollSpeed = 1,
    this.animationCurve = Curves.easeOutCirc,
    this.direction = Axis.vertical,
    this.physics = const ScrollPhysics(),
    this.edgeLockingDelay = const Duration(milliseconds: 650),
    this.overScrollingLockingDelay = const Duration(milliseconds: 700),
    this.enableStretchEffect = true,
    this.edgeForwardingMode = EdgeForwardingMode.sameAxisOnly,
    this.mouseWheelVerticalDeltaBehavior =
        _kDefaultMouseWheelVerticalDeltaBehavior,
    this.decayLogFactor = kDefaultDecayLogFactor,
    this.blockWebOverscrollBehaviorX = true,
    this.debugMode = false,
  });

  /// Duration of the smooth scroll animation.
  final Duration silkyScrollDuration;

  /// Multiplier for the scroll delta.
  final double scrollSpeed;

  /// The animation curve applied to smooth scrolling.
  final Curve animationCurve;

  /// How long the scroll is locked after reaching an edge.
  final Duration edgeLockingDelay;

  /// How long the overscroll effect is suppressed after touch-up.
  final Duration overScrollingLockingDelay;

  /// Whether to allow the platform stretch / glow overscroll effect.
  final bool enableStretchEffect;

  /// Controls how edge-locked scroll deltas are forwarded to
  /// ancestor [Scrollable] widgets.
  ///
  /// Defaults to [EdgeForwardingMode.sameAxisOnly], which forwards
  /// outward scroll deltas at edges only when the ancestor scrollable
  /// shares the same axis direction.
  ///
  /// Use [EdgeForwardingMode.always] to forward regardless of axis
  /// direction, or [EdgeForwardingMode.none] to disable forwarding
  /// entirely.
  final EdgeForwardingMode edgeForwardingMode;

  /// How a horizontal scrollable handles regular vertical mouse-wheel deltas
  /// when Shift is not pressed.
  final MouseWheelVerticalDeltaBehavior mouseWheelVerticalDeltaBehavior;

  /// Exponential-decay log factor for the smooth-scroll animation.
  final double decayLogFactor;

  /// Whether to block browser back/forward swipe gestures on web.
  ///
  /// When `true`, `overscroll-behavior-x: none` is applied while
  /// this widget is mounted. Defaults to `true`.
  final bool blockWebOverscrollBehaviorX;

  /// Enables debug logging.
  final bool debugMode;

  /// The scroll direction.
  final Axis direction;

  /// The [ScrollPhysics] applied to the scrollable child.
  final ScrollPhysics physics;

  /// Creates a copy of this config with the given fields replaced.
  SilkyScrollConfig copyWith({
    Duration? silkyScrollDuration,
    double? scrollSpeed,
    Curve? animationCurve,
    Axis? direction,
    ScrollPhysics? physics,
    Duration? edgeLockingDelay,
    Duration? overScrollingLockingDelay,
    bool? enableStretchEffect,
    EdgeForwardingMode? edgeForwardingMode,
    MouseWheelVerticalDeltaBehavior? mouseWheelVerticalDeltaBehavior,
    double? decayLogFactor,
    bool? blockWebOverscrollBehaviorX,
    bool? debugMode,
  }) {
    return SilkyScrollConfig(
      silkyScrollDuration: silkyScrollDuration ?? this.silkyScrollDuration,
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      animationCurve: animationCurve ?? this.animationCurve,
      direction: direction ?? this.direction,
      physics: physics ?? this.physics,
      edgeLockingDelay: edgeLockingDelay ?? this.edgeLockingDelay,
      overScrollingLockingDelay:
          overScrollingLockingDelay ?? this.overScrollingLockingDelay,
      enableStretchEffect: enableStretchEffect ?? this.enableStretchEffect,
      edgeForwardingMode: edgeForwardingMode ?? this.edgeForwardingMode,
      mouseWheelVerticalDeltaBehavior:
          mouseWheelVerticalDeltaBehavior ??
          this.mouseWheelVerticalDeltaBehavior,
      decayLogFactor: decayLogFactor ?? this.decayLogFactor,
      blockWebOverscrollBehaviorX:
          blockWebOverscrollBehaviorX ?? this.blockWebOverscrollBehaviorX,
      debugMode: debugMode ?? this.debugMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SilkyScrollConfig &&
          runtimeType == other.runtimeType &&
          silkyScrollDuration == other.silkyScrollDuration &&
          scrollSpeed == other.scrollSpeed &&
          animationCurve == other.animationCurve &&
          direction == other.direction &&
          physics == other.physics &&
          edgeLockingDelay == other.edgeLockingDelay &&
          overScrollingLockingDelay == other.overScrollingLockingDelay &&
          enableStretchEffect == other.enableStretchEffect &&
          edgeForwardingMode == other.edgeForwardingMode &&
          mouseWheelVerticalDeltaBehavior ==
              other.mouseWheelVerticalDeltaBehavior &&
          decayLogFactor == other.decayLogFactor &&
          blockWebOverscrollBehaviorX == other.blockWebOverscrollBehaviorX &&
          debugMode == other.debugMode;

  @override
  int get hashCode => Object.hash(
    silkyScrollDuration,
    scrollSpeed,
    animationCurve,
    direction,
    physics,
    edgeLockingDelay,
    overScrollingLockingDelay,
    enableStretchEffect,
    edgeForwardingMode,
    mouseWheelVerticalDeltaBehavior,
    decayLogFactor,
    blockWebOverscrollBehaviorX,
    debugMode,
  );

  @override
  String toString() =>
      'SilkyScrollConfig('
      'silkyScrollDuration: $silkyScrollDuration, '
      'scrollSpeed: $scrollSpeed, '
      'animationCurve: $animationCurve, '
      'direction: $direction, '
      'edgeLockingDelay: $edgeLockingDelay, '
      'enableStretchEffect: $enableStretchEffect, '
      'edgeForwardingMode: $edgeForwardingMode, '
      'mouseWheelVerticalDeltaBehavior: $mouseWheelVerticalDeltaBehavior, '
      'decayLogFactor: $decayLogFactor, '
      'blockWebOverscrollBehaviorX: $blockWebOverscrollBehaviorX, '
      'debugMode: $debugMode)';
}
