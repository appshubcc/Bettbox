import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../silky_scroll_animator.dart';
import '../silky_scroll_config.dart';
import '../silky_scroll_widget.dart';

/// A [CustomScrollView] with built-in [SilkyScroll] smooth scrolling.
///
/// Drop-in replacement for [CustomScrollView] — no manual `controller` /
/// `physics` wiring needed.
class SilkyCustomScrollView extends StatelessWidget {
  const SilkyCustomScrollView({
    super.key,
    // SilkyScroll configuration
    this.silkyConfig,
    this.silkyScrollDuration = const Duration(milliseconds: 1600),
    this.scrollSpeed = 1,
    this.animationCurve = Curves.easeOutCirc,
    this.physics = const ScrollPhysics(),
    this.edgeLockingDelay = const Duration(milliseconds: 650),
    this.overScrollingLockingDelay = const Duration(milliseconds: 700),
    this.enableStretchEffect = true,
    this.edgeForwardingMode = EdgeForwardingMode.sameAxisOnly,
    this.mouseWheelVerticalDeltaBehavior =
        MouseWheelVerticalDeltaBehavior.forwardToVerticalAncestorOrSelf,
    this.decayLogFactor = kDefaultDecayLogFactor,
    this.blockWebOverscrollBehaviorX = true,
    this.debugMode = false,
    this.setManualPointerDeviceKind,
    this.onScroll,
    this.onEdgeOverScroll,
    this.onPointerDeviceKindChanged,
    // CustomScrollView parameters
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.scrollCacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.slivers = const <Widget>[],
  });

  // ── SilkyScroll configuration ──

  final SilkyScrollConfig? silkyConfig;
  final Duration silkyScrollDuration;
  final double scrollSpeed;
  final Curve animationCurve;
  final ScrollPhysics physics;
  final Duration edgeLockingDelay;
  final Duration overScrollingLockingDelay;
  final bool enableStretchEffect;
  final EdgeForwardingMode edgeForwardingMode;
  final MouseWheelVerticalDeltaBehavior mouseWheelVerticalDeltaBehavior;
  final double decayLogFactor;
  final bool blockWebOverscrollBehaviorX;
  final bool debugMode;
  final Function(PointerDeviceKind)? setManualPointerDeviceKind;
  final void Function(double)? onScroll;
  final void Function(double)? onEdgeOverScroll;
  final void Function(PointerDeviceKind)? onPointerDeviceKindChanged;

  // ── CustomScrollView parameters ──

  final ScrollController? controller;
  final Axis scrollDirection;
  final bool reverse;
  final bool shrinkWrap;
  final Key? center;
  final double anchor;
  final double? cacheExtent;
  final ScrollCacheExtent? scrollCacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    final cfg = silkyConfig;
    final effectiveDirection = cfg?.direction ?? scrollDirection;
    final effectiveScrollCacheExtent =
        scrollCacheExtent ??
        (cacheExtent == null ? null : ScrollCacheExtent.pixels(cacheExtent!));

    return SilkyScroll(
      controller: controller,
      silkyScrollDuration: cfg?.silkyScrollDuration ?? silkyScrollDuration,
      scrollSpeed: cfg?.scrollSpeed ?? scrollSpeed,
      animationCurve: cfg?.animationCurve ?? animationCurve,
      direction: effectiveDirection,
      physics: cfg?.physics ?? physics,
      edgeLockingDelay: cfg?.edgeLockingDelay ?? edgeLockingDelay,
      overScrollingLockingDelay:
          cfg?.overScrollingLockingDelay ?? overScrollingLockingDelay,
      enableStretchEffect: cfg?.enableStretchEffect ?? enableStretchEffect,
      edgeForwardingMode: cfg?.edgeForwardingMode ?? edgeForwardingMode,
      mouseWheelVerticalDeltaBehavior:
          cfg?.mouseWheelVerticalDeltaBehavior ??
          mouseWheelVerticalDeltaBehavior,
      decayLogFactor: cfg?.decayLogFactor ?? decayLogFactor,
      blockWebOverscrollBehaviorX:
          cfg?.blockWebOverscrollBehaviorX ?? blockWebOverscrollBehaviorX,
      debugMode: cfg?.debugMode ?? debugMode,
      setManualPointerDeviceKind: setManualPointerDeviceKind,
      onScroll: onScroll,
      onEdgeOverScroll: onEdgeOverScroll,
      builder: (context, ctrl, scrollPhysics, deviceKind) {
        if (onPointerDeviceKindChanged != null && deviceKind != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onPointerDeviceKindChanged!(deviceKind);
          });
        }

        return CustomScrollView(
          controller: ctrl,
          physics: scrollPhysics,
          scrollDirection: effectiveDirection,
          reverse: reverse,
          shrinkWrap: shrinkWrap,
          center: center,
          anchor: anchor,
          scrollCacheExtent: effectiveScrollCacheExtent,
          semanticChildCount: semanticChildCount,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
          slivers: slivers,
        );
      },
    );
  }
}
