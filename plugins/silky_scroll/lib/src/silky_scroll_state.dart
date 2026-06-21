import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'silky_scroll_global_manager.dart';
import 'silky_scroll_config.dart';
import 'silky_scroll_controller.dart';
import 'blocked_scroll_physics.dart';
import 'silky_scroll_animator.dart';
import 'silky_input_handler.dart';
import 'scroll_delta_sample.dart';
import 'scroll_delta_sample_analyzer.dart';

/// Magic number constants for scroll behavior tuning.
const int _kScrollDisableCheckDelayMs = 50;
const double _kMaxBounceOvershoot = 120;
const int _kDeltaSampleRetentionMs = 1000;

/// Describes the current physics-management phase.
///
/// Only one timer-driven phase is active at any time, preventing
/// race conditions between independent timers.
enum ScrollPhysicsPhase {
  /// Default — no timer is active, physics == widgetScrollPhysics.
  normal,

  /// A short delay before edge-checking (trackpad scroll).
  edgeCheckPending,

  /// Physics are blocked because the scroll is at an edge.
  edgeLocked,

  /// Overscroll stretch indicator is suppressed after touch-up.
  overscrollLocked,
}

/// Central state management for a [SilkyScroll] widget.
///
/// Composes [SilkyScrollAnimator] and [SilkyInputHandler] to keep
/// itself a thin coordination layer.
class SilkyScrollState extends ChangeNotifier
    implements SilkyScrollAnimatorDelegate, SilkyInputHandlerDelegate {
  SilkyScrollState({
    ScrollController? scrollController,
    this.widgetScrollPhysics = const ScrollPhysics(),
    this.reverse = false,
    required this.edgeLockingDelay,
    required this.scrollSpeed,
    required this.silkyScrollDuration,
    required this.animationCurve,
    required this.isVertical,
    required this.edgeForwardingMode,
    required this.debugMode,
    this.decayLogFactor = kDefaultDecayLogFactor,
    this.onScroll,
    this.onEdgeOverScroll,
    this.mouseWheelVerticalDeltaBehavior =
        MouseWheelVerticalDeltaBehavior.forwardToVerticalAncestorOrSelf,
    bool Function()? isShiftPressed,
    required Function(PointerDeviceKind)? setManualPointerDeviceKind,
    required this.silkyScrollGlobalManager,
    required TickerProvider vsync,
    int Function()? clock,
  }) : _isShiftPressed =
           isShiftPressed ?? (() => HardwareKeyboard.instance.isShiftPressed),
       _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch) {
    currentScrollPhysics = DynamicBlockingScrollPhysics(
      parent: widgetScrollPhysics,
      blockingState: _blockingState,
    );
    isPlatformBouncingScrollPhysics =
        widgetScrollPhysics is BouncingScrollPhysics;

    if (scrollController != null) {
      clientController = scrollController;
      isControllerOwn = false;
    } else {
      clientController = ScrollController();
      isControllerOwn = true;
    }
    silkyScrollController = SilkyScrollController(
      clientController: clientController,
      onDelegatedMouseWheel: handleDelegatedMouseWheelScroll,
    );

    clientController.addListener(_onScrollUpdate);

    if (setManualPointerDeviceKind == null) {
      setPointerDeviceKind = silkyScrollController.setPointerDeviceKind;
    } else {
      setPointerDeviceKind = setManualPointerDeviceKind;
    }

    _animator = SilkyScrollAnimator(
      this,
      vsync,
      maxBounceOvershoot: _kMaxBounceOvershoot,
    );
    _inputHandler = SilkyInputHandler(this);
  }

  bool _disposed = false;
  final int Function() _clock;
  @override
  late final ScrollController clientController;
  late final SilkyScrollController silkyScrollController;
  late final bool isControllerOwn;
  final UniqueKey instanceKey = UniqueKey();

  @override
  Curve animationCurve;
  @override
  Duration silkyScrollDuration;
  @override
  bool isPlatformBouncingScrollPhysics = false;

  @override
  double decayLogFactor;

  late ScrollPhysics currentScrollPhysics;
  late ScrollPhysics widgetScrollPhysics;
  final ScrollBlockingState _blockingState = ScrollBlockingState();

  /// Sets [_blockingState.isBlocked] and notifies listeners when it
  /// actually changes, so the widget tree can update the physics indicator.
  void _setBlocked(bool value) {
    if (_blockingState.isBlocked == value) return;
    _blockingState.isBlocked = value;
    notifyListeners();
  }

  @override
  final void Function(double delta)? onScroll;
  final void Function(double delta)? onEdgeOverScroll;
  @override
  late final Function(PointerDeviceKind) setPointerDeviceKind;
  final bool debugMode;

  @override
  bool prevDeltaPositive = false;
  @override
  bool isOnSilkyScrolling = false;
  @override
  final bool isVertical;
  @override
  final bool reverse;
  final EdgeForwardingMode edgeForwardingMode;
  Duration edgeLockingDelay;
  @override
  double scrollSpeed;
  @override
  double futurePosition = 0;
  @override
  MouseWheelVerticalDeltaBehavior mouseWheelVerticalDeltaBehavior;
  bool Function() _isShiftPressed;

  Timer? _phaseTimer;
  ScrollPhysicsPhase _physicsPhase = ScrollPhysicsPhase.normal;

  /// The current physics-management phase.
  ScrollPhysicsPhase get physicsPhase => _physicsPhase;

  /// Whether the scroll is currently locked at an edge.
  bool get isEdgeLocked => _physicsPhase == ScrollPhysicsPhase.edgeLocked;

  /// Whether scrolling is currently dynamically blocked.
  bool get isScrollBlocked => _blockingState.isBlocked;

  /// Whether the overscroll indicator is temporarily suppressed.
  bool get isOverscrollLocked =>
      _physicsPhase == ScrollPhysicsPhase.overscrollLocked;

  @override
  bool get isDisposed => _disposed;

  @override
  final SilkyScrollGlobalManager silkyScrollGlobalManager;
  bool isOverScrolling = false;
  int _lockedEdgeDirection = 0;

  /// The [BuildContext] of the [SilkyScroll] widget, used to locate
  /// an ancestor [Scrollable] for delta forwarding on edge lock.
  BuildContext? _widgetContext;

  // ── User-input delta samples ──────────────────────────────────────
  final List<ScrollDeltaSample> _recentInputDeltaSamples = [];

  // Speed cache — reused within the same ~16 ms frame.
  double? _cachedInputSpeed;
  int _cachedInputSpeedTimeMs = 0;

  /// Current user-input scroll speed in logical-pixels / second.
  ///
  /// Computed from recent input delta samples using time-window grouping.
  /// The result is cached for ~16 ms (one frame) to avoid redundant
  /// recalculation across multiple call-sites per event.
  double get currentInputSpeed {
    final int now = _clock();
    if (_cachedInputSpeed != null && now - _cachedInputSpeedTimeMs < 16) {
      return _cachedInputSpeed!;
    }
    _cachedInputSpeed = ScrollDeltaSampleAnalyzer.calculateAverageSpeed(
      _recentInputDeltaSamples,
    );
    _cachedInputSpeedTimeMs = now;
    return _cachedInputSpeed!;
  }

  void _recordDelta(double delta) {
    final int now = _clock();
    _recentInputDeltaSamples.add(ScrollDeltaSample(delta, now));
    // Trim old samples — exploit time-sorted order.
    final int cutoff = now - _kDeltaSampleRetentionMs;
    int removeCount = 0;
    for (final sample in _recentInputDeltaSamples) {
      if (sample.timeMs >= cutoff) break;
      removeCount++;
    }
    if (removeCount > 0) {
      _recentInputDeltaSamples.removeRange(0, removeCount);
    }
  }

  // ── Composed helpers ──────────────────────────────────────────────
  late final SilkyScrollAnimator _animator;
  late final SilkyInputHandler _inputHandler;

  bool _canScroll(ScrollController c) =>
      c.hasClients && c.position.maxScrollExtent.round() > 0;

  /// Returns `-1` if at the top/start edge with velocity toward it,
  /// `1` if at the bottom/end edge with velocity toward it,
  /// and `0` otherwise.
  int _checkOffsetAtEdge(double velocity) {
    if (!clientController.hasClients || velocity.abs().round() == 0) {
      return 0;
    }

    final double offset = clientController.offset;
    final double maxExtent = clientController.position.maxScrollExtent;
    final double clampedVelocity = velocity.clamp(-2, 2);
    final double projected = offset + clampedVelocity;

    if (velocity < 0) {
      return projected < 0 ? -1 : 0;
    }
    return projected > maxExtent ? 1 : 0;
  }

  // ── SilkyScrollAnimatorDelegate ──────────────────────────────────
  @override
  void setSilkyTickerActive(bool active) {
    silkyScrollController.currentSilkyScrollPosition?.silkyTickerActive =
        active;
  }

  @override
  void triggerNativeBounce() {
    silkyScrollController.currentSilkyScrollPosition?.goBallistic(0.0);
  }

  // ── SilkyInputHandlerDelegate ────────────────────────────────────
  @override
  bool get isWebPlatform =>
      silkyScrollGlobalManager.silkyScrollWebManager.isWebPlatform;

  @override
  bool get isShiftPressed => _isShiftPressed();

  // ── Public API (delegated) ───────────────────────────────────────

  /// Supplies the widget [BuildContext] so that the state can find an
  /// ancestor [Scrollable] for delta forwarding when edge-locked.
  set widgetContext(BuildContext context) => _widgetContext = context;

  /// Re-detects [isPlatformBouncingScrollPhysics] from the runtime-resolved
  /// physics chain obtained via [ScrollConfiguration].
  ///
  /// Must be called from the widget's `build()` where a valid
  /// [BuildContext] is available.  This covers the case where the
  /// widget-level physics is the default `ScrollPhysics()` which
  /// resolves to `BouncingScrollPhysics` on iOS/macOS at runtime.
  void detectBouncingPhysics(BuildContext context) {
    if (widgetScrollPhysics is BouncingScrollPhysics) {
      isPlatformBouncingScrollPhysics = true;
      return;
    }
    final ScrollPhysics resolved = ScrollConfiguration.of(
      context,
    ).getScrollPhysics(context);
    isPlatformBouncingScrollPhysics = resolved is BouncingScrollPhysics;
  }

  /// Routes touch/trackpad input through [SilkyInputHandler].
  void triggerTouchAction(Offset delta, PointerDeviceKind kind) =>
      _inputHandler.triggerTouchAction(delta, kind);

  /// Routes mouse input through [SilkyInputHandler].
  void triggerMouseAction(Offset scrollDelta) =>
      _inputHandler.triggerMouseAction(scrollDelta);

  /// Updates how vertical mouse-wheel deltas drive horizontal scroll without
  /// Shift. Used when the widget option changes at runtime.
  void setMouseWheelVerticalDeltaBehavior(
    MouseWheelVerticalDeltaBehavior value,
  ) {
    mouseWheelVerticalDeltaBehavior = value;
  }

  /// Updates runtime scroll behavior options without recreating the scrollable.
  void setScrollBehavior({
    required double scrollSpeed,
    required Duration silkyScrollDuration,
    required Curve animationCurve,
    required Duration edgeLockingDelay,
    required double decayLogFactor,
  }) {
    this.scrollSpeed = scrollSpeed;
    this.silkyScrollDuration = silkyScrollDuration;
    this.animationCurve = animationCurve;
    this.edgeLockingDelay = edgeLockingDelay;
    this.decayLogFactor = decayLogFactor;
  }

  /// Updates the Shift-key state provider.
  void setIsShiftPressedProvider(bool Function() isShiftPressed) {
    _isShiftPressed = isShiftPressed;
  }

  /// Immediately cancels any in-progress smooth scroll animation.
  ///
  /// Called on mouse→trackpad switch so that trackpad direct scrolling
  /// takes effect immediately.
  void cancelSilkyScroll() {
    if (isOnSilkyScrolling && clientController.hasClients) {
      _animator.cancel();
      futurePosition = clientController.offset;
    }
  }

  /// Called when a touch pointer goes down.
  ///
  /// Keeps an active edge lock so that repeated outward drags at the
  /// same edge remain blocked.  Inward unlock is handled separately
  /// by [tryGestureUnlock] from the [Listener].
  void onTouchDown() {
    if (debugMode) {
      debugPrint(
        '[SilkyScroll] onTouchDown | phase=$_physicsPhase '
        'lockedEdge=$_lockedEdgeDirection',
      );
    }
  }

  /// Called when a touch pointer goes up.
  ///
  /// If the scroll is at an edge, activates a direction-aware edge lock
  /// for [edgeLockingDelay].
  void onTouchUp() {
    if (debugMode) {
      debugPrint(
        '[SilkyScroll] onTouchUp | phase=$_physicsPhase '
        'lockedEdge=$_lockedEdgeDirection',
      );
    }
    _checkEdgeLockOnTouchUp();
  }

  // ── State machine transitions ─────────────────────────────────────

  void _transitionTo(
    ScrollPhysicsPhase phase, [
    Duration? timerDuration,
    VoidCallback? onTimeout,
  ]) {
    _phaseTimer?.cancel();
    _physicsPhase = phase;

    if (timerDuration != null && !_disposed) {
      _phaseTimer = Timer(timerDuration, () {
        if (!_disposed) {
          onTimeout?.call();
        }
      });
    }
  }

  // ── Edge locking ─────────────────────────────────────────────────

  void _checkNeedLocking() {
    final double speed = currentInputSpeed;
    if (_disposed || !clientController.hasClients || speed.abs().round() == 0) {
      _transitionTo(ScrollPhysicsPhase.normal);
      return;
    }

    if (!_canScroll(clientController)) {
      _transitionTo(ScrollPhysicsPhase.normal);
      return;
    }

    final int edgeResult = _checkOffsetAtEdge(speed);
    if (edgeResult != 0 && !_blockingState.isBlocked && !isOverScrolling) {
      // On BouncingScrollPhysics platforms, skip edge-locking entirely
      // when there is no ancestor to forward to — let the native
      // bounce animation play normally.
      if (isPlatformBouncingScrollPhysics && !_hasAncestorScrollable()) {
        _transitionTo(ScrollPhysicsPhase.normal);
        return;
      }

      _lockedEdgeDirection = edgeResult;
      // Don't block physics for trackpad — Flutter's own
      // _targetScrollOffsetForPointerScroll already skips the inner
      // Scrollable when the target offset equals the current pixels,
      // letting PointerScrollEvents propagate to outer scrollables.
      // Blocking physics here would prevent both inner and outer from
      // scrolling, causing the "completely locked" feeling in nested
      // scenarios.  The edgeLocked phase still suppresses the
      // overscroll indicator via the NotificationListener check.

      _transitionTo(
        ScrollPhysicsPhase.edgeLocked,
        edgeLockingDelay,
        _unlockScroll,
      );

      return;
    }

    _transitionTo(ScrollPhysicsPhase.normal);
  }

  void _checkEdgeLockOnTouchUp() {
    if (_disposed || !clientController.hasClients) return;
    if (!_canScroll(clientController)) return;
    if (_physicsPhase != ScrollPhysicsPhase.normal &&
        _physicsPhase != ScrollPhysicsPhase.edgeCheckPending &&
        _physicsPhase != ScrollPhysicsPhase.overscrollLocked) {
      return;
    }

    final int edgeResult = _checkOffsetAtEdge(currentInputSpeed);
    if (edgeResult == 0) return;

    _lockedEdgeDirection = edgeResult;
    if (debugMode) {
      debugPrint(
        '[SilkyScroll] _checkEdgeLockOnTouchUp → LOCKED '
        'edge=$_lockedEdgeDirection (${edgeResult == -1 ? "top" : "bottom"})'
        ' currentInputSpeed=$currentInputSpeed',
      );
    }

    // On BouncingScrollPhysics with no ancestor scrollable, skip
    // edge-locking entirely — let the native bounce play.
    if (isPlatformBouncingScrollPhysics && !_hasAncestorScrollable()) {
      return;
    }

    // If the offset is currently in the overscroll region (past the
    // edge on a bouncing-physics platform), do NOT block physics.
    // Blocking would cause createBallisticSimulation() to return null
    // when goBallistic fires — which happens AFTER this Listener
    // callback in the pointer-up dispatch order — killing the
    // bounce-back animation and leaving the offset stuck.
    final bool isOverscrolled = !_isWithinScrollExtent();

    // Don't block physics on BouncingScrollPhysics platforms (iOS) —
    // blocking would suppress createBallisticSimulation(), killing the
    // native bounce-back animation.  The edgeLocked phase alone is
    // enough to suppress the overscroll indicator and forward outward
    // deltas to the ancestor scrollable.
    if (!isPlatformBouncingScrollPhysics && !isOverscrolled) {
      _setBlocked(true);
    }

    _transitionTo(
      ScrollPhysicsPhase.edgeLocked,
      edgeLockingDelay,
      _unlockScroll,
    );
  }

  /// Checks whether the latest scroll delta is in the inward direction
  /// (away from the locked edge) to release the lock.
  ///
  /// Uses the immediate [lastDelta] rather than the averaged scroll
  /// speed so that direction changes on trackpads are detected without
  /// the latency of the 1-second sample window.
  ///
  /// Called from [handleTrackpadScroll] and [handleTouchDragScroll]
  /// on every trackpad / touch event while the scroll is edge-locked.
  /// Returns `true` if the lock was released.
  bool _tryGestureUnlock(double lastDelta) {
    if (_physicsPhase != ScrollPhysicsPhase.edgeLocked ||
        _lockedEdgeDirection == 0) {
      return false;
    }

    // Delta sign indicates direction in scroll coordinates:
    //   top edge  (-1): inward delta is positive  → product < 0
    //   bottom edge (1): inward delta is negative → product < 0

    final bool isInward =
        currentInputSpeed.abs() > 2 && (_lockedEdgeDirection * lastDelta < 0);

    if (debugMode) {
      debugPrint(
        '[SilkyScroll] tryGestureUnlock | '
        'edge=$_lockedEdgeDirection delta=${lastDelta.toStringAsFixed(1)} '
        'inward=$isInward',
      );
    }

    if (isInward) {
      if (debugMode) debugPrint('[SilkyScroll] ★ UNLOCKED by gesture');
      _unlockScroll();
      return true;
    }
    return false;
  }

  void _unlockScroll() {
    if (!_disposed) {
      _lockedEdgeDirection = 0;
      final bool wasBlocked = _blockingState.isBlocked;
      _setBlocked(false);
      _transitionTo(ScrollPhysicsPhase.normal);

      // If physics were blocked while the offset was in the overscroll
      // region, the bounce-back simulation may have been suppressed.
      // Trigger goBallistic(0) so the platform physics can create a
      // new simulation to bring the scroll back into bounds.
      if (wasBlocked &&
          clientController.hasClients &&
          !_isWithinScrollExtent()) {
        silkyScrollController.currentSilkyScrollPosition?.goBallistic(0.0);
      }
    }
  }

  // ── Ancestor forwarding ──────────────────────────────────────────

  /// Whether an ancestor [Scrollable] exists above this widget.
  ///
  /// Used to avoid edge-locking when there is nothing to forward to.
  bool _hasAncestorScrollable() {
    final BuildContext? ctx = _widgetContext;
    if (ctx == null || !ctx.mounted) return false;
    return Scrollable.maybeOf(ctx) != null;
  }

  /// Whether the scroll position is within its normal scroll extent
  /// (i.e. not in a BouncingScrollPhysics overscroll region).
  ///
  /// Returns `true` when `pixels` is between [minScrollExtent] and
  /// [maxScrollExtent] within a small tolerance.  Used to distinguish
  /// "at edge" from "mid-bounce" on bouncing platforms.
  static const double _kExtentTolerance = 0.5;
  bool _isWithinScrollExtent() {
    if (!clientController.hasClients) return false;
    final ScrollPosition pos = clientController.position;
    return pos.pixels >= pos.minScrollExtent - _kExtentTolerance &&
        pos.pixels <= pos.maxScrollExtent + _kExtentTolerance;
  }

  bool _canAcceptUserOffset(ScrollPosition position) {
    return position.physics.shouldAcceptUserOffset(position);
  }

  /// Forwards [delta] to the nearest ancestor [Scrollable]'s
  /// [ScrollPosition] when this scrollable is edge-locked.
  ///
  /// Returns `true` if the delta was successfully forwarded.
  bool _forwardDeltaToAncestor(double delta) {
    final BuildContext? ctx = _widgetContext;
    if (ctx == null || !ctx.mounted) return false;

    final ScrollableState? ancestor = Scrollable.maybeOf(ctx);
    if (ancestor == null) return false;

    // When sameAxisOnly, only forward if the ancestor shares our axis.
    if (edgeForwardingMode == EdgeForwardingMode.sameAxisOnly) {
      final Axis ancestorAxis = ancestor.position.axis;
      final Axis myAxis = isVertical ? Axis.vertical : Axis.horizontal;
      if (ancestorAxis != myAxis) return false;
    }

    final ScrollPosition pos = ancestor.position;
    if (!_canAcceptUserOffset(pos)) return false;

    // Compute the new offset, clamped to the ancestor's scroll extent.
    final double newOffset = (pos.pixels + delta).clamp(
      pos.minScrollExtent,
      pos.maxScrollExtent,
    );
    if ((newOffset - pos.pixels).abs().toInt() == 0) return false;

    pos.jumpTo(newOffset);
    if (debugMode) {
      debugPrint(
        '[SilkyScroll] ★ Forwarded delta=${delta.toStringAsFixed(1)} '
        'to ancestor (${pos.pixels.toStringAsFixed(1)}→'
        '${newOffset.toStringAsFixed(1)})',
      );
    }
    return true;
  }

  /// Forwards an unhandled vertical mouse-wheel delta to a vertical ancestor.
  ///
  /// This is intentionally separate from edge forwarding: a horizontal
  /// SilkyScroll that rejects a regular vertical mouse wheel should let the
  /// surrounding vertical page scroll naturally even when edge forwarding is
  /// configured as [EdgeForwardingMode.sameAxisOnly].
  @override
  MouseWheelForwardingResult forwardUnhandledMouseWheelVerticalDelta(
    double delta,
  ) {
    final BuildContext? ctx = _widgetContext;
    if (ctx == null || !ctx.mounted) {
      return MouseWheelForwardingResult.noVerticalAncestor;
    }

    final ScrollableState? ancestor = Scrollable.maybeOf(ctx);
    if (ancestor == null || ancestor.position.axis != Axis.vertical) {
      return MouseWheelForwardingResult.noVerticalAncestor;
    }

    final ScrollPosition pos = ancestor.position;
    if (!_canAcceptUserOffset(pos)) {
      return MouseWheelForwardingResult.blockedByAncestorPhysics;
    }

    if (pos is SilkyScrollPosition && pos.delegateMouseWheel(delta)) {
      return MouseWheelForwardingResult.forwarded;
    }

    final double newOffset = (pos.pixels + delta).clamp(
      pos.minScrollExtent,
      pos.maxScrollExtent,
    );
    if ((newOffset - pos.pixels).abs().toInt() == 0) {
      return MouseWheelForwardingResult.blockedAtAncestorExtent;
    }

    pos.jumpTo(newOffset);
    if (debugMode) {
      debugPrint(
        '[SilkyScroll] ★ Forwarded mouse wheel delta='
        '${delta.toStringAsFixed(1)} to vertical ancestor '
        '(${pos.pixels.toStringAsFixed(1)}→'
        '${newOffset.toStringAsFixed(1)})',
      );
    }
    return MouseWheelForwardingResult.forwarded;
  }

  /// Forwards an `always` horizontal mouse-wheel delta to the nearest ancestor
  /// when this scrollable is already at the edge for that delta.
  ///
  /// Unlike rejected regular vertical-wheel forwarding, this path is axis
  /// agnostic: `always` means mouse wheel input first belongs to this
  /// horizontal scrollable, then hands off to the nearest parent at the edge.
  /// [EdgeForwardingMode.none] still disables that handoff.
  @override
  MouseWheelForwardingResult forwardAlwaysMouseWheelDeltaAtEdge(double delta) {
    if (_checkOffsetAtEdge(delta) == 0 ||
        edgeForwardingMode == EdgeForwardingMode.none) {
      return MouseWheelForwardingResult.noVerticalAncestor;
    }

    final BuildContext? ctx = _widgetContext;
    if (ctx == null || !ctx.mounted) {
      return MouseWheelForwardingResult.noVerticalAncestor;
    }

    final ScrollableState? ancestor = Scrollable.maybeOf(ctx);
    if (ancestor == null) return MouseWheelForwardingResult.noVerticalAncestor;

    onEdgeOverScroll?.call(delta);

    final ScrollPosition pos = ancestor.position;
    if (!_canAcceptUserOffset(pos)) {
      return MouseWheelForwardingResult.blockedByAncestorPhysics;
    }

    if (pos is SilkyScrollPosition && pos.delegateMouseWheel(delta)) {
      return MouseWheelForwardingResult.forwarded;
    }

    final double newOffset = (pos.pixels + delta).clamp(
      pos.minScrollExtent,
      pos.maxScrollExtent,
    );
    if ((newOffset - pos.pixels).abs().toInt() == 0) {
      return MouseWheelForwardingResult.blockedAtAncestorExtent;
    }

    pos.jumpTo(newOffset);
    if (debugMode) {
      debugPrint(
        '[SilkyScroll] ★ Forwarded always mouse wheel delta='
        '${delta.toStringAsFixed(1)} to ancestor '
        '(${pos.pixels.toStringAsFixed(1)}→'
        '${newOffset.toStringAsFixed(1)})',
      );
    }
    return MouseWheelForwardingResult.forwarded;
  }

  // ── Shared edge-forwarding ───────────────────────────────────────

  /// Forwards outward deltas to the ancestor [Scrollable] when
  /// edge-locked. Returns `true` if the delta was consumed.
  ///
  /// Used by both [handleTrackpadScroll] and [handleTouchDragScroll].
  bool _handleLockedEdgeForwarding(double delta) {
    if (edgeForwardingMode == EdgeForwardingMode.none ||
        _physicsPhase != ScrollPhysicsPhase.edgeLocked ||
        _lockedEdgeDirection == 0) {
      return false;
    }
    final bool isOutward = _lockedEdgeDirection * delta > 0;
    if (!isOutward) return false;

    // On BouncingScrollPhysics, physics were not blocked at lock
    // time to preserve the bounce-back animation.  Now that an
    // outward delta arrives while still edge-locked, block
    // physics dynamically so the inner scrollable stops
    // responding and only the ancestor receives the delta.
    if (isPlatformBouncingScrollPhysics && !_blockingState.isBlocked) {
      _setBlocked(true);
    }
    if (!_forwardDeltaToAncestor(delta) && isPlatformBouncingScrollPhysics) {
      // No ancestor or ancestor at its edge — unlock so the
      // native bounce can play instead of staying blocked.
      _unlockScroll();
    }
    return true;
  }

  // ── Trackpad scroll ──────────────────────────────────────────────

  @override
  void handleTrackpadScroll(double delta) {
    _recordDelta(delta);

    final int edgeResult = _checkOffsetAtEdge(delta);
    if (edgeResult != 0) {
      onEdgeOverScroll?.call(delta);
    }

    if (_tryGestureUnlock(delta)) return;
    if (_handleLockedEdgeForwarding(delta)) return;

    // Don't start a new edge-check timer when an edge-lock or
    // overscroll-lock timer is already running — doing so would cancel
    // the pending _unlockScroll callback and leave currentScrollPhysics
    // permanently stuck as BlockedScrollPhysics (NeverScrollableScrollPhysics),
    // completely disabling touch and trackpad scrolling.
    if (_physicsPhase != ScrollPhysicsPhase.normal) return;

    _transitionTo(
      ScrollPhysicsPhase.edgeCheckPending,
      const Duration(milliseconds: _kScrollDisableCheckDelayMs),
      _checkNeedLocking,
    );
  }

  // ── Touch drag scroll ────────────────────────────────────────────

  @override
  void handleTouchDragScroll(double delta) {
    _recordDelta(delta);

    final int edgeResult = _checkOffsetAtEdge(delta);
    if (edgeResult != 0) {
      onEdgeOverScroll?.call(delta);
    }

    if (_tryGestureUnlock(delta)) return;
    if (_handleLockedEdgeForwarding(delta)) return;

    // BouncingScrollPhysics + edge forwarding: when the position has
    // settled at the edge and the delta is outward, lock physics and
    // forward to ancestor.
    if (edgeForwardingMode != EdgeForwardingMode.none &&
        isPlatformBouncingScrollPhysics &&
        edgeResult != 0 &&
        _isWithinScrollExtent()) {
      final bool isOutward = edgeResult * delta > 0;
      if (isOutward && _hasAncestorScrollable()) {
        _lockedEdgeDirection = edgeResult;
        _setBlocked(true);
        if (_physicsPhase != ScrollPhysicsPhase.edgeLocked) {
          _transitionTo(
            ScrollPhysicsPhase.edgeLocked,
            edgeLockingDelay,
            _unlockScroll,
          );
        }
        _forwardDeltaToAncestor(delta);
        return;
      } else if (_physicsPhase == ScrollPhysicsPhase.edgeLocked) {
        // Inward scroll → unlock
        _unlockScroll();
      }
    }
  }

  // ── Mouse scroll ─────────────────────────────────────────────────

  @override
  void handleMouseScroll(double delta, double scrollSpeed) {
    _handleMouseScroll(delta, scrollSpeed);
  }

  /// Handles a mouse-wheel delta explicitly delegated from a nested child.
  ///
  /// The regular mouse path honors the hover stack so only the deepest hovered
  /// SilkyScroll reacts. Delegated deltas have already been rejected by that
  /// child, so the ancestor should run its normal smooth-scroll pipeline even
  /// while the pointer remains over the child.
  bool handleDelegatedMouseWheelScroll(double delta) {
    setPointerDeviceKind(PointerDeviceKind.mouse);
    onScroll?.call(delta);
    _handleMouseScroll(delta, scrollSpeed, bypassHoverStack: true);
    silkyScrollGlobalManager.clearTrackpadMemory();
    return true;
  }

  void _handleMouseScroll(
    double delta,
    double scrollSpeed, {
    bool bypassHoverStack = false,
  }) {
    _recordDelta(delta);

    if (_blockingState.isBlocked) {
      _setBlocked(false);
    }

    if (!clientController.hasClients ||
        !_canAcceptUserOffset(clientController.position)) {
      return;
    }

    final double scrollDelta = delta;
    final bool isEdge = _checkOffsetAtEdge(scrollDelta) != 0;
    final bool needBlocking =
        widgetScrollPhysics is BlockedScrollPhysics || isEdge;

    if (instanceKey == silkyScrollGlobalManager.reserveKey) {
      if (!isOnSilkyScrolling) {
        if (needBlocking) {
          if (isEdge) onEdgeOverScroll?.call(delta);
          silkyScrollGlobalManager.reservingKey(instanceKey);
          return;
        }
        silkyScrollGlobalManager.reserveKey = null;
        silkyScrollGlobalManager.enteredKey(instanceKey);
      }
    }
    if (!isOnSilkyScrolling && needBlocking) {
      if (isEdge) onEdgeOverScroll?.call(delta);
      silkyScrollGlobalManager.reservingKey(instanceKey);
      return;
    }

    if (!bypassHoverStack &&
        silkyScrollGlobalManager.keyStack.isNotEmpty &&
        instanceKey != silkyScrollGlobalManager.keyStack.last) {
      return;
    }

    _animator.animateToScroll(scrollDelta, scrollSpeed);
  }

  // ── Physics management ───────────────────────────────────────────

  void setWidgetScrollPhysics({required ScrollPhysics scrollPhysics}) {
    _transitionTo(ScrollPhysicsPhase.normal);
    _setBlocked(false);
    widgetScrollPhysics = scrollPhysics;
    currentScrollPhysics = DynamicBlockingScrollPhysics(
      parent: scrollPhysics,
      blockingState: _blockingState,
    );
    notifyListeners();
  }

  /// Activate overscroll-lock phase for [duration].
  ///
  /// While active, the overscroll stretch indicator is suppressed.
  void beginOverscrollLock(Duration duration) {
    isOverScrolling = false;
    _transitionTo(
      ScrollPhysicsPhase.overscrollLocked,
      duration,
      () => _transitionTo(ScrollPhysicsPhase.normal),
    );
  }

  // ── Scroll position sync ────────────────────────────────────────

  void _onScrollUpdate() {
    if (!isOnSilkyScrolling) {
      futurePosition = clientController.offset;
    }
  }

  // ── Lifecycle ────────────────────────────────────────────────────

  @override
  void dispose() {
    // 1. Mark as disposed first to guard all timer/listener callbacks.
    _disposed = true;
    _widgetContext = null;

    // 2. Cancel all pending timers and clear samples.
    _phaseTimer?.cancel();
    _phaseTimer = null;
    _recentInputDeltaSamples.clear();

    // 3. Remove our listener *before* disposing controllers, so that
    //    any position detach during dispose does not trigger our callback.
    clientController.removeListener(_onScrollUpdate);

    // 4. Detach our key from the global manager.
    silkyScrollGlobalManager.detachKey(instanceKey);

    // 5. Dispose the animator (stops Ticker).
    _animator.dispose();

    // 6. Dispose silkyScrollController (detaches positions from both
    //    controllers via the guarded attach/detach overrides).
    silkyScrollController.dispose();

    // 7. Only dispose the client controller if we own it.
    if (isControllerOwn) {
      clientController.dispose();
    }

    super.dispose();
  }
}
