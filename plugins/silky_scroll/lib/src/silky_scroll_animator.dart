import 'dart:math';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

/// Snap threshold: when the remaining distance is below this value
/// (in logical pixels), the scroll jumps to the target and stops.
const double _kSnapThreshold = 0.9;

/// Default value for [SilkyScrollAnimator.decayLogFactor].
///
/// Used to derive an exponential-decay rate from [silkyScrollDuration].
/// Higher values make the scroll converge faster toward [futurePosition].
const double kDefaultDecayLogFactor = 12;

/// Callback interface used by [SilkyScrollAnimator] to communicate
/// state changes back to the owning [SilkyScrollState].
abstract interface class SilkyScrollAnimatorDelegate {
  ScrollController get clientController;

  Curve get animationCurve;

  Duration get silkyScrollDuration;

  double get decayLogFactor;

  bool get isPlatformBouncingScrollPhysics;

  double get futurePosition;

  set futurePosition(double value);

  bool get prevDeltaPositive;

  set prevDeltaPositive(bool value);

  bool get isOnSilkyScrolling;

  set isOnSilkyScrolling(bool value);

  bool get isDisposed;

  bool get reverse;

  /// Toggle the ballistic-suppression flag on the scroll position.
  ///
  /// While `true`, [SilkyScrollPosition.goBallistic] is a no-op,
  /// preventing Flutter's physics from fighting with our Ticker.
  void setSilkyTickerActive(bool active);

  /// Triggers Flutter's native ballistic simulation on the current
  /// scroll position, allowing [BouncingScrollPhysics] to animate
  /// the overscrolled offset back to the nearest edge.
  void triggerNativeBounce();
}

/// Handles smooth-scroll animation using a single [Ticker].
///
/// Instead of calling `controller.animateTo()` per wheel event (which
/// cancels the previous animation and restarts the easing curve from
/// its slow start), this class runs a **single [Ticker]** that
/// interpolates towards [futurePosition] every frame using
/// frame-rate-independent exponential smoothing.
///
/// New wheel events simply update [futurePosition] — the Ticker
/// naturally tracks the moving target without any restart, producing
/// the silky-smooth feel of browser smooth-scroll implementations
/// (Chrome, Firefox).
final class SilkyScrollAnimator {
  SilkyScrollAnimator(
    this._delegate,
    TickerProvider vsync, {
    required this.maxBounceOvershoot,
  }) {
    _ticker = vsync.createTicker(_onTick);
  }

  final SilkyScrollAnimatorDelegate _delegate;
  final double maxBounceOvershoot;

  /// Exponential decay rate derived from [silkyScrollDuration].
  /// Higher values → faster convergence to [futurePosition].
  double get _smoothingFactor {
    final durationSeconds =
        _delegate.silkyScrollDuration.inMilliseconds / 1000.0;
    return _delegate.decayLogFactor / durationSeconds;
  }

  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  /// Animates the scroll towards a new position based on [scrollDelta].
  ///
  /// Unlike the previous `animateTo()`-based approach, this merely
  /// updates [futurePosition] and ensures the Ticker is running.
  /// The per-frame [_onTick] callback handles the actual interpolation.
  void animateToScroll(double scrollDelta, double scrollSpeed) {
    final controller = _delegate.clientController;

    // In reverse scrollables, flip the delta so the animation
    // moves in the same visual direction as normal scrollables.
    final effectiveDelta = _delegate.reverse ? -scrollDelta : scrollDelta;

    // ── Update futurePosition ───────────────────────────────────
    if (effectiveDelta > 0 != _delegate.prevDeltaPositive) {
      _delegate.prevDeltaPositive = !_delegate.prevDeltaPositive;
      _delegate.futurePosition =
          controller.offset + (effectiveDelta * scrollSpeed);
    } else {
      _delegate.futurePosition =
          _delegate.futurePosition + (effectiveDelta * scrollSpeed);
    }

    // ── Clamp to edges ± maxBounceOvershoot ─────────────────────
    final double overshoot = _delegate.isPlatformBouncingScrollPhysics
        ? maxBounceOvershoot
        : 0;
    _delegate.futurePosition = _delegate.futurePosition.clamp(
      controller.position.minScrollExtent - overshoot,
      controller.position.maxScrollExtent + overshoot,
    );

    // Start the ticker if not already running.
    _delegate.isOnSilkyScrolling = true;
    _ensureTickerRunning();
  }

  // ── Ticker lifecycle ──────────────────────────────────────────

  void _ensureTickerRunning() {
    if (!_ticker.isActive && !_delegate.isDisposed) {
      _lastElapsed = Duration.zero;
      _delegate.setSilkyTickerActive(true);
      _ticker.start();
    }
  }

  void _stopTicker() {
    _delegate.setSilkyTickerActive(false);
    if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  // ── Per-frame callback ────────────────────────────────────────

  void _onTick(Duration elapsed) {
    if (_delegate.isDisposed || !_delegate.clientController.hasClients) {
      _stopTicker();
      return;
    }

    final double dt = _lastElapsed == Duration.zero
        ? 1.0 /
              60.0 // assume 60 fps for the very first frame
        : (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    // Guard against bad frame times (tab switch, debugger pause, etc.)
    if (dt <= 0 || dt > 0.1) return;

    final controller = _delegate.clientController;

    // ── Normal smooth-scroll phase ──
    _tickScroll(controller, dt);
  }

  void _tickScroll(ScrollController controller, double dt) {
    final double target = _delegate.futurePosition;
    final double current = controller.offset;
    final double diff = target - current;

    if (diff.abs() < _kSnapThreshold) {
      controller.jumpTo(target);
      _delegate.isOnSilkyScrolling = false;
      _stopTicker();
      _triggerNativeBounceIfNeeded(controller);
      return;
    }

    // Exponential smoothing: move a proportional fraction of the
    // remaining distance each frame.  The formula
    //   factor = 1 - e^(-smoothingFactor * dt)
    // guarantees frame-rate independence.
    final double factor = 1.0 - exp(-_smoothingFactor * dt);
    controller.jumpTo(current + diff * factor);
  }

  /// After the smooth-scroll ticker stops, delegates any overscroll
  /// bounce-back to Flutter's native [BouncingScrollPhysics].
  ///
  /// Calls [ScrollPosition.goBallistic] which creates a
  /// [BouncingScrollSimulation] that animates the offset back to the
  /// nearest edge.
  void _triggerNativeBounceIfNeeded(ScrollController controller) {
    if (!_delegate.isPlatformBouncingScrollPhysics) return;

    final pos = controller.position;
    if (pos.pixels < pos.minScrollExtent || pos.pixels > pos.maxScrollExtent) {
      _delegate.triggerNativeBounce();
    }
  }

  /// Immediately cancels any in-progress animation (scroll or recoil).
  void cancel() {
    _stopTicker();
    if (_delegate.isOnSilkyScrolling) {
      _delegate.isOnSilkyScrolling = false;
    }
  }

  /// Disposes the internal [Ticker].
  void dispose() {
    _stopTicker();
    _ticker.dispose();
  }
}
