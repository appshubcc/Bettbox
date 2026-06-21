import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../silky_scroll_animator.dart';
import '../silky_scroll_config.dart';
import '../silky_scroll_widget.dart';

enum _ListViewMode { children, builder, separated }

/// A [ListView] with built-in [SilkyScroll] smooth scrolling.
///
/// Drop-in replacement for [ListView], [ListView.builder], and
/// [ListView.separated] — no manual `controller` / `physics` wiring needed.
class SilkyListView extends StatelessWidget {
  /// Creates a [SilkyListView] with explicit children.
  SilkyListView({
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
    // ListView parameters
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.prototypeItem,
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
    List<Widget> children = const <Widget>[],
  }) : _mode = _ListViewMode.children,
       _children = children,
       _itemBuilder = null,
       _itemCount = null,
       _separatorBuilder = null,
       _findItemIndexCallback = null;

  /// Creates a [SilkyListView] using an item builder.
  SilkyListView.builder({
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
    this.itemExtent,
    this.prototypeItem,
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
    required NullableIndexedWidgetBuilder itemBuilder,
    ChildIndexGetter? findItemIndexCallback,
    int? itemCount,
  }) : _mode = _ListViewMode.builder,
       _children = null,
       _itemBuilder = itemBuilder,
       _itemCount = itemCount,
       _separatorBuilder = null,
       _findItemIndexCallback = findItemIndexCallback;

  /// Creates a [SilkyListView] with item and separator builders.
  SilkyListView.separated({
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
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    required NullableIndexedWidgetBuilder itemBuilder,
    required IndexedWidgetBuilder separatorBuilder,
    ChildIndexGetter? findItemIndexCallback,
    required int itemCount,
  }) : _mode = _ListViewMode.separated,
       _children = null,
       _itemBuilder = itemBuilder,
       _itemCount = itemCount,
       _separatorBuilder = separatorBuilder,
       _findItemIndexCallback = findItemIndexCallback,
       itemExtent = null,
       prototypeItem = null,
       semanticChildCount = null;

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

  // ── ListView parameters ──

  final ScrollController? controller;
  final Axis scrollDirection;
  final bool reverse;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final Widget? prototypeItem;
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

  final _ListViewMode _mode;
  final List<Widget>? _children;
  final NullableIndexedWidgetBuilder? _itemBuilder;
  final IndexedWidgetBuilder? _separatorBuilder;
  final ChildIndexGetter? _findItemIndexCallback;
  final int? _itemCount;

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
      reverse: reverse,
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
          _ListViewMode.children => ListView(
            controller: ctrl,
            physics: scrollPhysics,
            scrollDirection: effectiveDirection,
            reverse: reverse,
            padding: padding,
            itemExtent: itemExtent,
            prototypeItem: prototypeItem,
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
            children: _children!,
          ),
          _ListViewMode.builder => ListView.builder(
            controller: ctrl,
            physics: scrollPhysics,
            scrollDirection: effectiveDirection,
            reverse: reverse,
            padding: padding,
            itemExtent: itemExtent,
            prototypeItem: prototypeItem,
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
            itemBuilder: _itemBuilder!,
            findChildIndexCallback: _findItemIndexCallback,
            itemCount: _itemCount,
          ),
          _ListViewMode.separated => ListView.separated(
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
            dragStartBehavior: dragStartBehavior,
            keyboardDismissBehavior: keyboardDismissBehavior,
            restorationId: restorationId,
            clipBehavior: clipBehavior,
            itemBuilder: _itemBuilder!,
            separatorBuilder: _separatorBuilder!,
            findItemIndexCallback: _findItemIndexCallback,
            itemCount: _itemCount!,
          ),
        };
      },
    );
  }
}
