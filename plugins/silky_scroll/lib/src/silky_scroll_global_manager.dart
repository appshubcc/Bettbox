import 'dart:async';

import 'package:flutter/foundation.dart';
import 'silky_scroll_web_helper/silky_scroll_non_web_helper.dart'
    if (dart.library.js_interop) 'silky_scroll_web_helper/silky_scroll_web_helper.dart';
import 'silky_scroll_web_helper/silky_scroll_web_helper_interface.dart';

final class SilkyScrollGlobalManager {
  SilkyScrollGlobalManager._internal() {
    silkyScrollWebManager = SilkyScrollWebManager();
  }

  static final SilkyScrollGlobalManager instance =
      SilkyScrollGlobalManager._internal();

  UniqueKey? reserveKey;
  final List<UniqueKey> keyStack = [];
  late final SilkyScrollWebManager silkyScrollWebManager;

  // ── Overscroll behavior X ──
  int _widgetBlockCount = 0;
  bool _userBlock = false;

  // ── Trackpad detection timers ──
  //
  // Two independent signals feed a single [isRecentlyTrackpad] getter:
  //
  // 1. _panZoomTimer (_kPanZoomTimeoutMs, native only)
  //    PointerPanZoomUpdate is generated exclusively by native trackpads,
  //    so it is a high-confidence, short-lived signal.
  //
  // 2. _heuristicTrackpadTimer (_kHeuristicTrackpadTimeoutMs, web only)
  //    On web, PointerPanZoomUpdate is never generated.  We rely on
  //    heuristic matches (small delta, horizontal component) as a
  //    longer-lived "memory" signal for subsequent ambiguous events.

  Timer? _panZoomTimer;
  Timer? _heuristicTrackpadTimer;

  static const int _kPanZoomTimeoutMs = 150;
  static const int _kHeuristicTrackpadTimeoutMs = 800;

  /// Whether recent input was from a trackpad — from *any* detection source.
  ///
  /// Combines PanZoom activity (native, _kPanZoomTimeoutMs) and heuristic-based
  /// detection (web, _kHeuristicTrackpadTimeoutMs) into a single check.
  bool get isRecentlyTrackpad =>
      (_panZoomTimer?.isActive ?? false) ||
      (_heuristicTrackpadTimer?.isActive ?? false);

  /// Records PanZoom activity (native trackpads only, _kPanZoomTimeoutMs window).
  void markPanZoomActivity() {
    _panZoomTimer?.cancel();
    _panZoomTimer = Timer(
      const Duration(milliseconds: _kPanZoomTimeoutMs),
      () {},
    );
  }

  /// Records a heuristic-based trackpad detection (web only).
  ///
  /// On native platforms this is a no-op because [_panZoomTimer] already
  /// provides a more precise, shorter-lived signal.  Activating the
  /// _kHeuristicTrackpadTimeoutMs heuristic timer on native would delay trackpad → mouse
  /// transitions unnecessarily.
  void markTrackpadHeuristic() {
    if (!silkyScrollWebManager.isWebPlatform) return;
    _heuristicTrackpadTimer?.cancel();
    _heuristicTrackpadTimer = Timer(
      const Duration(milliseconds: _kHeuristicTrackpadTimeoutMs),
      () {},
    );
  }

  /// Clears heuristic-based trackpad memory.
  ///
  /// Called when mouse input is confirmed so that subsequent events
  /// are not misclassified as trackpad.  Does not touch [_panZoomTimer]
  /// because PanZoom events are hardware-sourced and self-expire in _kPanZoomTimeoutMs.
  void clearTrackpadMemory() {
    _heuristicTrackpadTimer?.cancel();
    _heuristicTrackpadTimer = null;
  }

  /// Clears PanZoom-based trackpad memory immediately.
  ///
  /// Called when [PointerPanZoomEnd] fires (native only), meaning the
  /// user lifted their hand from the trackpad.  Clearing the timer
  /// right away — instead of waiting for the [_kPanZoomTimeoutMs]
  /// window to expire — allows the very next scroll event to be
  /// correctly identified as mouse input.
  void clearPanZoomMemory() {
    _panZoomTimer?.cancel();
    _panZoomTimer = null;
  }

  void reservingKey(UniqueKey key) {
    reserveKey = key;
    exitKey(key);
  }

  void enteredKey(UniqueKey key) {
    if (keyStack.contains(key)) {
      keyStack.remove(key);
    }
    keyStack.add(key);
  }

  void exitKey(UniqueKey key) {
    keyStack.removeWhere((item) => item == key);
  }

  void detachKey(UniqueKey key) {
    if (reserveKey == key) {
      reserveKey = null;
    }
    exitKey(key);
  }

  /// Called by [SilkyScroll] widget on mount when
  /// `blockWebOverscrollBehaviorX` is `true`.
  void incrementWidgetBlock() {
    _widgetBlockCount++;
    _syncOverscrollBehaviorX();
  }

  /// Called by [SilkyScroll] widget on dispose when
  /// `blockWebOverscrollBehaviorX` is `true`.
  void decrementWidgetBlock() {
    _widgetBlockCount--;
    _syncOverscrollBehaviorX();
  }

  /// Explicitly sets or clears the user-level overscroll-behavior-x block.
  ///
  /// When [value] is `true`, `overscroll-behavior-x: none` is applied.
  /// When `false`, the CSS is restored to `auto` (unless widgets still
  /// request blocking).
  void setBlockOverscrollBehaviorX(bool value) {
    _userBlock = value;
    _syncOverscrollBehaviorX();
  }

  /// Applies the CSS property based on the combined block state.
  void _syncOverscrollBehaviorX() {
    final shouldBlock = (_widgetBlockCount > 0) || _userBlock;
    silkyScrollWebManager.setOverscrollBehaviorX(
      shouldBlock ? OverscrollBehaviorX.none : OverscrollBehaviorX.auto,
    );
  }

  /// Resets all mutable state for test isolation.
  ///
  /// Only intended for use in test tearDown/setUp.
  @visibleForTesting
  void resetForTesting() {
    reserveKey = null;
    keyStack.clear();
    _widgetBlockCount = 0;
    _userBlock = false;
    _panZoomTimer?.cancel();
    _panZoomTimer = null;
    _heuristicTrackpadTimer?.cancel();
    _heuristicTrackpadTimer = null;
  }
}
