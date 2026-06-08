import 'dart:ui';
import 'package:flutter/material.dart';

/// A [ScrollController] that intercepts mouse‑wheel events.
///
/// [SilkyScroll] creates this controller internally. It delegates
/// position management to the user-supplied (or auto-created)
/// [clientController] so that offsets stay in sync.
final class SilkyScrollController extends ScrollController {
  SilkyScrollController({
    required this.clientController,
    this.onDelegatedMouseWheel,
  });

  late final ScrollController clientController;
  final bool Function(double delta)? onDelegatedMouseWheel;

  SilkyScrollPosition? currentSilkyScrollPosition;

  void setPointerDeviceKind(PointerDeviceKind pointerDeviceKind) {
    if (currentSilkyScrollPosition != null) {
      currentSilkyScrollPosition!.kind = pointerDeviceKind;
    }
  }

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    currentSilkyScrollPosition = SilkyScrollPosition(
      physics: physics,
      context: context,
      oldPosition: oldPosition,
      initialPixels: initialScrollOffset,
      onDelegatedMouseWheel: onDelegatedMouseWheel,
    );
    return currentSilkyScrollPosition!;
  }

  @override
  void attach(ScrollPosition position) {
    // Guard: only attach to clientController if not already attached,
    // preventing duplicate position registration.
    if (!clientController.positions.contains(position)) {
      clientController.attach(position);
    }

    super.attach(position);
  }

  @override
  void detach(ScrollPosition position) {
    // Guard: only detach from clientController if still attached.
    if (clientController.positions.contains(position)) {
      clientController.detach(position);
    }
    super.detach(position);
  }
}

/// A scroll position that filters [pointerScroll] based on the
/// current [PointerDeviceKind], allowing [SilkyScroll] to handle
/// mouse-wheel events with its own animation pipeline.
final class SilkyScrollPosition extends ScrollPositionWithSingleContext {
  SilkyScrollPosition({
    required super.physics,
    required super.context,
    super.oldPosition,
    required double super.initialPixels,
    this.onDelegatedMouseWheel,
  });

  PointerDeviceKind kind = PointerDeviceKind.trackpad;
  final bool Function(double delta)? onDelegatedMouseWheel;

  /// When `true`, [goBallistic] is suppressed to prevent Flutter's
  /// physics-based spring simulation from fighting with the
  /// Ticker-driven smooth-scroll / recoil animation.
  ///
  /// Without this, every [jumpTo] call during overscroll triggers
  /// [BouncingScrollPhysics.createBallisticSimulation], which starts
  /// a spring that pulls the offset back — while our Ticker pushes
  /// it forward.  The two fight each other every frame, producing
  /// visible stutter.
  bool silkyTickerActive = false;

  @override
  void correctBy(double correction) {
    // _RenderSingleChildViewport.performLayout() clamps pixels to
    // [minScrollExtent, maxScrollExtent] via correctBy() BEFORE
    // applyContentDimensions is called.  On BouncingScrollPhysics
    // platforms (iOS/macOS) this kills an in-progress overscroll
    // bounce whenever the child content relayouts (e.g. a timer
    // tick rebuilding a descendant widget).
    //
    // Suppress the correction when all of the following are true:
    //   • the correction is non-zero,
    //   • pixels are already initialised,
    //   • the position is currently in the overscroll region,
    //   • a scroll activity is in progress (drag or ballistic).

    if (correction != 0.0 &&
        hasPixels &&
        outOfRange &&
        activity != null &&
        activity!.isScrolling) {
      debugPrint('[SilkyScroll] correctBy BLOCKED (overscroll + scrolling)');
      return;
    }
    super.correctBy(correction);
  }

  @override
  void goBallistic(double velocity) {
    if (silkyTickerActive) return;
    super.goBallistic(velocity);
  }

  @override
  void pointerScroll(double delta) {
    if (kind != PointerDeviceKind.mouse) {
      super.pointerScroll(delta);

      return;
    }
  }

  bool delegateMouseWheel(double delta) {
    final handler = onDelegatedMouseWheel;
    if (handler == null) return false;
    return handler(delta);
  }
}
