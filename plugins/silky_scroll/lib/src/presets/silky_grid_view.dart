import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../silky_scroll_animator.dart';
import '../silky_scroll_config.dart';
import '../silky_scroll_widget.dart';

enum _GridViewMode { children, builder, count, extent }

/// A [GridView] with built-in [SilkyScroll] smooth scrolling.
///
/// Drop-in replacement for [GridView], [GridView.builder],
/// [GridView.count], and [GridView.extent] — no manual `controller` /
/// `physics` wiring needed.
class SilkyGridView extends StatelessWidget {
  /// Creates a [SilkyGridView] with explicit children and a grid delegate.
  SilkyGridView({
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
    // GridView parameters
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.scrollCacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    required SliverGridDelegate gridDelegate,
    List<Widget> children = const <Widget>[],
  }) : _mode = _GridViewMode.children,
       _gridDelegate = gridDelegate,
       _children = children,
       _itemBuilder = null,
       _itemCount = null,
       _findItemIndexCallback = null,
       _crossAxisCount = null,
       _maxCrossAxisExtent = null,
       _mainAxisSpacing = 0.0,
       _crossAxisSpacing = 0.0,
       _childAspectRatio = 1.0;

  /// Creates a [SilkyGridView] using an item builder and a grid delegate.
  SilkyGridView.builder({
    super.key,
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
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.scrollCacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    required SliverGridDelegate gridDelegate,
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findItemIndexCallback,
    int? itemCount,
  }) : _mode = _GridViewMode.builder,
       _gridDelegate = gridDelegate,
       _children = null,
       _itemBuilder = itemBuilder,
       _itemCount = itemCount,
       _findItemIndexCallback = findItemIndexCallback,
       _crossAxisCount = null,
       _maxCrossAxisExtent = null,
       _mainAxisSpacing = 0.0,
       _crossAxisSpacing = 0.0,
       _childAspectRatio = 1.0;

  /// Creates a [SilkyGridView] with a fixed number of tiles in the cross axis.
  SilkyGridView.count({
    super.key,
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
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.scrollCacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    List<Widget> children = const <Widget>[],
  }) : _mode = _GridViewMode.count,
       _gridDelegate = null,
       _children = children,
       _itemBuilder = null,
       _itemCount = null,
       _findItemIndexCallback = null,
       _crossAxisCount = crossAxisCount,
       _maxCrossAxisExtent = null,
       _mainAxisSpacing = mainAxisSpacing,
       _crossAxisSpacing = crossAxisSpacing,
       _childAspectRatio = childAspectRatio;

  /// Creates a [SilkyGridView] with tiles that have a maximum cross-axis
  /// extent.
  SilkyGridView.extent({
    super.key,
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
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.scrollCacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    required double maxCrossAxisExtent,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    List<Widget> children = const <Widget>[],
  }) : _mode = _GridViewMode.extent,
       _gridDelegate = null,
       _children = children,
       _itemBuilder = null,
       _itemCount = null,
       _findItemIndexCallback = null,
       _crossAxisCount = null,
       _maxCrossAxisExtent = maxCrossAxisExtent,
       _mainAxisSpacing = mainAxisSpacing,
       _crossAxisSpacing = crossAxisSpacing,
       _childAspectRatio = childAspectRatio;

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

  // ── GridView parameters ──

  final ScrollController? controller;
  final Axis scrollDirection;
  final bool reverse;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final ScrollCacheExtent? scrollCacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  // ── Mode-specific (private) ──

  final _GridViewMode _mode;
  final SliverGridDelegate? _gridDelegate;
  final List<Widget>? _children;
  final NullableIndexedWidgetBuilder? _itemBuilder;
  final ChildIndexGetter? _findItemIndexCallback;
  final int? _itemCount;
  final int? _crossAxisCount;
  final double? _maxCrossAxisExtent;
  final double _mainAxisSpacing;
  final double _crossAxisSpacing;
  final double _childAspectRatio;

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

        return switch (_mode) {
          _GridViewMode.children => GridView(
            controller: ctrl,
            physics: scrollPhysics,
            scrollDirection: effectiveDirection,
            reverse: reverse,
            padding: padding,
            shrinkWrap: shrinkWrap,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            scrollCacheExtent: effectiveScrollCacheExtent,
            semanticChildCount: semanticChildCount,
            dragStartBehavior: dragStartBehavior,
            keyboardDismissBehavior: keyboardDismissBehavior,
            restorationId: restorationId,
            clipBehavior: clipBehavior,
            gridDelegate: _gridDelegate!,
            children: _children!,
          ),
          _GridViewMode.builder => GridView.builder(
            controller: ctrl,
            physics: scrollPhysics,
            scrollDirection: effectiveDirection,
            reverse: reverse,
            padding: padding,
            shrinkWrap: shrinkWrap,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            scrollCacheExtent: effectiveScrollCacheExtent,
            semanticChildCount: semanticChildCount,
            dragStartBehavior: dragStartBehavior,
            keyboardDismissBehavior: keyboardDismissBehavior,
            restorationId: restorationId,
            clipBehavior: clipBehavior,
            gridDelegate: _gridDelegate!,
            itemBuilder: _itemBuilder!,
            findChildIndexCallback: _findItemIndexCallback,
            itemCount: _itemCount,
          ),
          _GridViewMode.count => GridView.count(
            controller: ctrl,
            physics: scrollPhysics,
            scrollDirection: effectiveDirection,
            reverse: reverse,
            padding: padding,
            shrinkWrap: shrinkWrap,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            scrollCacheExtent: effectiveScrollCacheExtent,
            semanticChildCount: semanticChildCount,
            dragStartBehavior: dragStartBehavior,
            keyboardDismissBehavior: keyboardDismissBehavior,
            restorationId: restorationId,
            clipBehavior: clipBehavior,
            crossAxisCount: _crossAxisCount!,
            mainAxisSpacing: _mainAxisSpacing,
            crossAxisSpacing: _crossAxisSpacing,
            childAspectRatio: _childAspectRatio,
            children: _children!,
          ),
          _GridViewMode.extent => GridView.extent(
            controller: ctrl,
            physics: scrollPhysics,
            scrollDirection: effectiveDirection,
            reverse: reverse,
            padding: padding,
            shrinkWrap: shrinkWrap,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            scrollCacheExtent: effectiveScrollCacheExtent,
            semanticChildCount: semanticChildCount,
            dragStartBehavior: dragStartBehavior,
            keyboardDismissBehavior: keyboardDismissBehavior,
            restorationId: restorationId,
            clipBehavior: clipBehavior,
            maxCrossAxisExtent: _maxCrossAxisExtent!,
            mainAxisSpacing: _mainAxisSpacing,
            crossAxisSpacing: _crossAxisSpacing,
            childAspectRatio: _childAspectRatio,
            children: _children!,
          ),
        };
      },
    );
  }
}
