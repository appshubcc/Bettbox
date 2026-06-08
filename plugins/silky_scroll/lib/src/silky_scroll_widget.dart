import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'silky_scroll_animator.dart';
import 'silky_scroll_config.dart';
import 'silky_scroll_global_manager.dart';
import 'silky_scroll_state.dart';

/// A widget that provides smooth, animated scrolling on all platforms.
///
/// Wraps any scrollable child and automatically handles mouse wheel, trackpad,
/// and touch input to deliver a silky-smooth scrolling experience.
///
/// Example:
/// ```dart
/// SilkyScroll(
///   builder: (context, controller, physics, pointerDeviceKind) => ListView(
///     controller: controller,
///     physics: physics,
///     children: [...],
///   ),
/// )
/// ```
class SilkyScroll extends StatefulWidget {
  const SilkyScroll({
    super.key,
    this.controller,
    this.silkyScrollDuration = const Duration(milliseconds: 1600),
    this.scrollSpeed = 1,
    this.animationCurve = Curves.easeOutCirc,
    this.direction = Axis.vertical,
    this.reverse = false,
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
    this.isShiftPressed,
    this.setManualPointerDeviceKind,
    this.onScroll,
    this.onEdgeOverScroll,
    required this.builder,
  });

  /// Creates a [SilkyScroll] from a [SilkyScrollConfig] object.
  ///
  /// This is convenient when sharing the same configuration across
  /// multiple scroll widgets.
  SilkyScroll.fromConfig({
    super.key,
    required SilkyScrollConfig config,
    this.controller,
    this.reverse = false,
    this.isShiftPressed,
    this.setManualPointerDeviceKind,
    this.onScroll,
    this.onEdgeOverScroll,
    required this.builder,
  }) : silkyScrollDuration = config.silkyScrollDuration,
       scrollSpeed = config.scrollSpeed,
       animationCurve = config.animationCurve,
       direction = config.direction,
       physics = config.physics,
       edgeLockingDelay = config.edgeLockingDelay,
       overScrollingLockingDelay = config.overScrollingLockingDelay,
       enableStretchEffect = config.enableStretchEffect,
       edgeForwardingMode = config.edgeForwardingMode,
       mouseWheelVerticalDeltaBehavior = config.mouseWheelVerticalDeltaBehavior,
       decayLogFactor = config.decayLogFactor,
       blockWebOverscrollBehaviorX = config.blockWebOverscrollBehaviorX,
       debugMode = config.debugMode;

  /// An optional external [ScrollController].
  ///
  /// If not provided, an internal controller is created and managed
  /// automatically.
  final ScrollController? controller;

  /// Duration of the smooth scroll animation.
  ///
  /// Defaults to 1600 ms.
  final Duration silkyScrollDuration;

  /// Multiplier for the scroll delta. Higher values scroll faster.
  ///
  /// Defaults to `1`.
  final double scrollSpeed;

  /// The animation curve applied to smooth scrolling.
  ///
  /// Defaults to [Curves.easeOutCirc].
  final Curve animationCurve;

  /// The scroll direction. Defaults to [Axis.vertical].
  final Axis direction;

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// Defaults to `false`.
  final bool reverse;

  /// The [ScrollPhysics] applied to the scrollable child.
  final ScrollPhysics physics;

  /// Builder that provides a [ScrollController] and [ScrollPhysics]
  /// for the scrollable child widget.
  final SilkyScrollWidgetBuilder builder;

  /// How long the scroll is locked after reaching an edge.
  ///
  /// Prevents accidental parent-scroll activation. Defaults to 650 ms.
  final Duration edgeLockingDelay;

  /// How long the overscroll effect is suppressed after touch-up.
  ///
  /// Defaults to 700 ms.
  final Duration overScrollingLockingDelay;

  /// Exponential-decay log factor for the smooth-scroll animation.
  ///
  /// Higher values make the scroll converge faster.
  /// Defaults to [kDefaultDecayLogFactor] (12).
  final double decayLogFactor;

  /// Whether to allow the platform stretch / glow overscroll effect.
  ///
  /// Defaults to `true`.
  final bool enableStretchEffect;

  /// Whether to block browser back/forward swipe gestures on web.
  ///
  /// When `true`, `overscroll-behavior-x: none` is applied while
  /// this widget is mounted. Defaults to `true`.
  final bool blockWebOverscrollBehaviorX;

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

  /// Called on every scroll delta (both mouse and touch).
  final void Function(double delta)? onScroll;

  /// Called when the user scrolls past the edge.
  final void Function(double delta)? onEdgeOverScroll;

  /// Allows manually overriding the detected pointer device kind.
  final Function(PointerDeviceKind)? setManualPointerDeviceKind;

  /// Provides the current Shift key state.
  ///
  /// Defaults to [HardwareKeyboard.instance.isShiftPressed]. This exists so
  /// widget tests can provide deterministic modifier-key state.
  final bool Function()? isShiftPressed;

  /// Enables debug logging. Defaults to `false`.
  final bool debugMode;

  @override
  State<SilkyScroll> createState() => _SilkyScrollState();
}

class _SilkyScrollState extends State<SilkyScroll>
    with TickerProviderStateMixin {
  late final SilkyScrollState silkyScrollState;
  late final SilkyScrollGlobalManager silkyScrollGlobalManager;
  late ScrollPhysics currentPhysics;
  bool _lastBlocked = false;
  PointerDeviceKind? _currentDeviceKind;
  @override
  void initState() {
    super.initState();
    silkyScrollGlobalManager = SilkyScrollGlobalManager.instance;
    silkyScrollState = SilkyScrollState(
      scrollController: widget.controller,
      widgetScrollPhysics: widget.physics,
      silkyScrollDuration: widget.silkyScrollDuration,
      animationCurve: widget.animationCurve,
      edgeLockingDelay: widget.edgeLockingDelay,
      scrollSpeed: widget.scrollSpeed,
      setManualPointerDeviceKind: widget.setManualPointerDeviceKind,
      isVertical: widget.direction == Axis.vertical,
      reverse: widget.reverse,
      edgeForwardingMode: widget.edgeForwardingMode,
      mouseWheelVerticalDeltaBehavior: widget.mouseWheelVerticalDeltaBehavior,
      isShiftPressed: widget.isShiftPressed,
      decayLogFactor: widget.decayLogFactor,
      silkyScrollGlobalManager: silkyScrollGlobalManager,
      onScroll: widget.onScroll,
      onEdgeOverScroll: widget.onEdgeOverScroll,
      debugMode: widget.debugMode,
      vsync: this,
    );
    currentPhysics = silkyScrollState.currentScrollPhysics;
    silkyScrollState.addListener(_onPhysicsChanged);
    if (widget.blockWebOverscrollBehaviorX) {
      silkyScrollGlobalManager.incrementWidgetBlock();
    }
  }

  @override
  void didUpdateWidget(covariant SilkyScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollSpeed != widget.scrollSpeed ||
        oldWidget.silkyScrollDuration != widget.silkyScrollDuration ||
        oldWidget.animationCurve != widget.animationCurve ||
        oldWidget.edgeLockingDelay != widget.edgeLockingDelay ||
        oldWidget.decayLogFactor != widget.decayLogFactor) {
      silkyScrollState.setScrollBehavior(
        scrollSpeed: widget.scrollSpeed,
        silkyScrollDuration: widget.silkyScrollDuration,
        animationCurve: widget.animationCurve,
        edgeLockingDelay: widget.edgeLockingDelay,
        decayLogFactor: widget.decayLogFactor,
      );
    }
    if (oldWidget.physics != widget.physics) {
      silkyScrollState.setWidgetScrollPhysics(scrollPhysics: widget.physics);
    }
    if (oldWidget.mouseWheelVerticalDeltaBehavior !=
        widget.mouseWheelVerticalDeltaBehavior) {
      silkyScrollState.setMouseWheelVerticalDeltaBehavior(
        widget.mouseWheelVerticalDeltaBehavior,
      );
    }
    if (oldWidget.isShiftPressed != widget.isShiftPressed) {
      silkyScrollState.setIsShiftPressedProvider(
        widget.isShiftPressed ?? () => HardwareKeyboard.instance.isShiftPressed,
      );
    }
    if (oldWidget.blockWebOverscrollBehaviorX !=
        widget.blockWebOverscrollBehaviorX) {
      if (widget.blockWebOverscrollBehaviorX) {
        silkyScrollGlobalManager.incrementWidgetBlock();
      } else {
        silkyScrollGlobalManager.decrementWidgetBlock();
      }
    }
  }

  /// Called whenever [SilkyScrollState] fires [notifyListeners].
  /// Triggers a rebuild when the physics reference or blocking state changed.
  void _onPhysicsChanged() {
    final newPhysics = silkyScrollState.currentScrollPhysics;
    final newBlocked = silkyScrollState.isScrollBlocked;
    if (newPhysics != currentPhysics || newBlocked != _lastBlocked) {
      setState(() {
        currentPhysics = newPhysics;
        _lastBlocked = newBlocked;
      });
    }
  }

  @override
  void dispose() {
    if (widget.blockWebOverscrollBehaviorX) {
      silkyScrollGlobalManager.decrementWidgetBlock();
    }
    silkyScrollState.removeListener(_onPhysicsChanged);
    silkyScrollState.dispose();
    super.dispose();
  }

  void _updateDeviceKind(PointerDeviceKind kind) {
    if (_currentDeviceKind != kind) {
      setState(() {
        _currentDeviceKind = kind;
      });
    }
  }

  bool _handleTrackpadCheck(PointerDeviceKind kind) {
    if (kind == PointerDeviceKind.trackpad) {
      silkyScrollState.setPointerDeviceKind(PointerDeviceKind.trackpad);
      silkyScrollGlobalManager.markTrackpadHeuristic();
      _updateDeviceKind(PointerDeviceKind.trackpad);
      return true;
    } else {
      return false;
    }
  }

  void _onPointerSignal(PointerSignalEvent signalEvent) {
    if (signalEvent is! PointerScrollEvent) return;

    // ── Step 1: Platform directly reports trackpad ──
    if (_handleTrackpadCheck(signalEvent.kind)) {
      _ensureTrackpadMode();
      silkyScrollState.triggerTouchAction(
        signalEvent.scrollDelta,
        PointerDeviceKind.trackpad,
      );
      return;
    }

    final double scrollDeltaY = signalEvent.scrollDelta.dy;
    final double scrollDeltaX = signalEvent.scrollDelta.dx;

    // ── Step 2: Heuristic — horizontal delta or tiny vertical delta → trackpad ──
    // ★ Runs before timer checks → detects device switch immediately ★
    final bool horizontalMouseWheel =
        signalEvent.kind == PointerDeviceKind.mouse &&
        widget.direction == Axis.horizontal &&
        (silkyScrollState.isShiftPressed ||
            widget.mouseWheelVerticalDeltaBehavior ==
                MouseWheelVerticalDeltaBehavior.always) &&
        scrollDeltaX.abs() >= 0.1;
    if (!horizontalMouseWheel &&
        (scrollDeltaX.abs() >= 0.1 || scrollDeltaY.abs() < 4)) {
      _handleTrackpadCheck(PointerDeviceKind.trackpad);
      _ensureTrackpadMode();
      silkyScrollState.triggerTouchAction(
        signalEvent.scrollDelta,
        PointerDeviceKind.trackpad,
      );
      return;
    }

    // ── Step 3: Recent trackpad activity → trackpad (fast vertical swipe) ──
    // Unified check that combines two platform-specific signals:
    //   • Native: PanZoom activity within _kPanZoomTimeoutMs (high-confidence)
    //   • Web:    Heuristic match within _kHeuristicTrackpadTimeoutMs (no PanZoom on web)
    //
    // Why we don't filter out signalEvent.kind == mouse here:
    //   On Flutter Web, trackpad scroll events report kind == trackpad only
    //   at the *start* of the gesture. Subsequent frames arrive with
    //   kind == mouse and only carry a delta — no device kind update.
    //   The _kHeuristicTrackpadTimeoutMs heuristic window exists precisely to cover these
    //   "headless" follow-up frames, so excluding mouse would break
    //   web trackpad detection entirely.
    //
    //   On native, this branch is guarded by _panZoomTimer (_kPanZoomTimeoutMs),
    //   which is short enough that a real mouse event within that
    //   window is extremely unlikely.
    if (silkyScrollGlobalManager.isRecentlyTrackpad) {
      _updateDeviceKind(PointerDeviceKind.trackpad);
      silkyScrollState.triggerTouchAction(
        signalEvent.scrollDelta,
        PointerDeviceKind.trackpad,
      );
      return;
    }

    // ── Step 4: Treat as mouse ──
    if (_shouldOwnHorizontalMouseWheel(signalEvent)) {
      _ownPointerSignal(signalEvent);
    }
    _updateDeviceKind(PointerDeviceKind.mouse);
    silkyScrollState.triggerMouseAction(signalEvent.scrollDelta);
  }

  bool _shouldOwnHorizontalMouseWheel(PointerScrollEvent event) {
    if (widget.direction != Axis.horizontal ||
        event.kind != PointerDeviceKind.mouse ||
        (!silkyScrollState.isShiftPressed &&
            widget.mouseWheelVerticalDeltaBehavior !=
                MouseWheelVerticalDeltaBehavior.always)) {
      return false;
    }
    return event.scrollDelta.dx.abs() > 0 || event.scrollDelta.dy.abs() > 0;
  }

  void _ownPointerSignal(PointerScrollEvent event) {
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {});
  }

  /// Cancel any in-progress mouse animation when switching to trackpad mode.
  void _ensureTrackpadMode() {
    silkyScrollState.cancelSilkyScroll();
  }

  @override
  Widget build(BuildContext context) {
    silkyScrollState.widgetContext = context;
    silkyScrollState.detectBouncingPhysics(context);
    return MouseRegion(
      onEnter: (e) {
        silkyScrollGlobalManager.enteredKey(silkyScrollState.instanceKey);
      },
      onExit: (e) {
        silkyScrollGlobalManager.exitKey(silkyScrollState.instanceKey);
      },
      opaque: false,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          if (silkyScrollState.isEdgeLocked ||
              silkyScrollState.isOverscrollLocked ||
              !widget.enableStretchEffect) {
            overscroll.disallowIndicator();
            return false;
          }
          silkyScrollState.isOverScrolling = true;
          return true;
        },
        child: Listener(
          onPointerHover: (PointerHoverEvent signalEvent) {
            _handleTrackpadCheck(signalEvent.kind);
          },
          onPointerSignal: _onPointerSignal,
          onPointerDown: (PointerDownEvent event) {
            if (event.kind == PointerDeviceKind.touch) {
              silkyScrollState.onTouchDown();
            }
          },
          onPointerMove: (PointerMoveEvent event) {
            if (event.kind == PointerDeviceKind.touch) {
              _updateDeviceKind(PointerDeviceKind.touch);
              silkyScrollState.setPointerDeviceKind(PointerDeviceKind.touch);
              // silkyScrollState.tryGestureUnlock(event.delta);
              silkyScrollState.triggerTouchAction(
                event.delta,
                PointerDeviceKind.touch,
              );
            }
          },
          onPointerPanZoomUpdate: (PointerPanZoomUpdateEvent event) {
            _updateDeviceKind(PointerDeviceKind.trackpad);
            silkyScrollState.setPointerDeviceKind(PointerDeviceKind.trackpad);
            silkyScrollGlobalManager.markPanZoomActivity();
            silkyScrollState.cancelSilkyScroll();

            silkyScrollState.triggerTouchAction(
              event.panDelta,
              PointerDeviceKind.trackpad,
            );
          },
          onPointerPanZoomEnd: (PointerPanZoomEndEvent event) {
            silkyScrollGlobalManager.clearPanZoomMemory();
          },
          onPointerUp: (PointerUpEvent event) {
            if (event.kind == PointerDeviceKind.touch) {
              if (silkyScrollState.isOverScrolling) {
                silkyScrollState.beginOverscrollLock(
                  widget.overScrollingLockingDelay,
                );
              }
              silkyScrollState.onTouchUp();
            }
          },
          child: widget.builder(
            context,
            silkyScrollState.silkyScrollController,
            currentPhysics,
            _currentDeviceKind,
          ),
        ),
      ),
    );
  }
}

/// Signature for the builder callback used by [SilkyScroll].
///
/// Receives a managed [ScrollController] and [ScrollPhysics] that must
/// be forwarded to the scrollable child.
typedef SilkyScrollWidgetBuilder =
    Widget Function(
      BuildContext context,
      ScrollController controller,
      ScrollPhysics physics,
      PointerDeviceKind? pointerDeviceKind,
    );
