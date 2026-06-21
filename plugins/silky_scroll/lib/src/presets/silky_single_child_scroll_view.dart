import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../silky_scroll_animator.dart';
import '../silky_scroll_config.dart';
import '../silky_scroll_widget.dart';

/// A [SingleChildScrollView] with built-in [SilkyScroll] smooth scrolling.
///
/// Drop-in replacement for [SingleChildScrollView] — no manual `controller` /
/// `physics` wiring needed.
class SilkySingleChildScrollView extends StatelessWidget {
  const SilkySingleChildScrollView({
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
    // SingleChildScrollView parameters
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.child,
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

  // ── SingleChildScrollView parameters ──

  final ScrollController? controller;
  final Axis scrollDirection;
  final bool reverse;
  final EdgeInsetsGeometry? padding;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final cfg = silkyConfig;
    final effectiveDirection = cfg?.direction ?? scrollDirection;

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

        return SingleChildScrollView(
          controller: ctrl,
          physics: scrollPhysics,
          scrollDirection: effectiveDirection,
          reverse: reverse,
          padding: padding,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
          child: child,
        );
      },
    );
  }
}
