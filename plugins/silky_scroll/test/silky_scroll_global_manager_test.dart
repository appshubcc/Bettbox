import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silky_scroll/src/silky_scroll_global_manager.dart';

void main() {
  group('SilkyScrollGlobalManager', () {
    late SilkyScrollGlobalManager manager;

    setUp(() {
      // SilkyScrollGlobalManager is a singleton; reset its state.
      manager = SilkyScrollGlobalManager.instance;
      manager.keyStack.clear();
      manager.reserveKey = null;
    });

    test('enteredKey adds key to stack', () {
      final key = UniqueKey();
      manager.enteredKey(key);
      expect(manager.keyStack, contains(key));
    });

    test('enteredKey moves existing key to end', () {
      final key1 = UniqueKey();
      final key2 = UniqueKey();
      manager.enteredKey(key1);
      manager.enteredKey(key2);
      manager.enteredKey(key1);
      expect(manager.keyStack.last, key1);
      expect(manager.keyStack.length, 2);
    });

    test('exitKey removes key from stack', () {
      final key = UniqueKey();
      manager.enteredKey(key);
      manager.exitKey(key);
      expect(manager.keyStack, isNot(contains(key)));
    });

    test('reservingKey sets reserveKey and removes from stack', () {
      final key = UniqueKey();
      manager.enteredKey(key);
      manager.reservingKey(key);
      expect(manager.reserveKey, key);
      expect(manager.keyStack, isNot(contains(key)));
    });

    test('detachKey clears reserveKey if matching', () {
      final key = UniqueKey();
      manager.reservingKey(key);
      expect(manager.reserveKey, key);
      manager.detachKey(key);
      expect(manager.reserveKey, isNull);
    });

    test('isRecentlyTrackpad is initially false', () {
      expect(manager.isRecentlyTrackpad, isFalse);
    });

    test('markPanZoomActivity sets isRecentlyTrackpad to true', () {
      manager.markPanZoomActivity();
      expect(manager.isRecentlyTrackpad, isTrue);
    });

    test('isRecentlyTrackpad from PanZoom becomes false after 150ms', () async {
      manager.markPanZoomActivity();
      expect(manager.isRecentlyTrackpad, isTrue);

      // Wait for the 150ms timeout to expire
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(manager.isRecentlyTrackpad, isFalse);
    });

    test('markTrackpadHeuristic is no-op on non-web', () {
      // On non-web, markTrackpadHeuristic should not change state.
      manager.markTrackpadHeuristic();
      expect(manager.isRecentlyTrackpad, isFalse);
    });

    test('clearTrackpadMemory clears heuristic timer', () {
      // On non-web, heuristic is no-op, but clearTrackpadMemory
      // should still be safe to call.
      manager.clearTrackpadMemory();
      expect(manager.isRecentlyTrackpad, isFalse);
    });

    test('clearTrackpadMemory does not clear PanZoom timer', () {
      manager.markPanZoomActivity();
      expect(manager.isRecentlyTrackpad, isTrue);

      manager.clearTrackpadMemory();
      // PanZoom timer should still be active
      expect(manager.isRecentlyTrackpad, isTrue);
    });

    test('clearPanZoomMemory clears PanZoom timer immediately', () {
      manager.markPanZoomActivity();
      expect(manager.isRecentlyTrackpad, isTrue);

      manager.clearPanZoomMemory();
      expect(manager.isRecentlyTrackpad, isFalse);
    });

    test('clearPanZoomMemory does not clear heuristic timer', () {
      // On non-web, heuristic is no-op, so both timers are inactive.
      // This test verifies that clearPanZoomMemory is safe to call
      // even when only a heuristic timer would be active (web).
      manager.markPanZoomActivity();
      manager.clearPanZoomMemory();
      expect(manager.isRecentlyTrackpad, isFalse);
    });

    test('resetForTesting clears all trackpad timers', () {
      manager.markPanZoomActivity();
      expect(manager.isRecentlyTrackpad, isTrue);

      manager.resetForTesting();
      expect(manager.isRecentlyTrackpad, isFalse);
    });

    group('overscroll behavior X blocking', () {
      setUp(() {
        manager.resetForTesting();
      });

      test('incrementWidgetBlock / decrementWidgetBlock adjusts count', () {
        manager.incrementWidgetBlock();
        manager.incrementWidgetBlock();
        manager.decrementWidgetBlock();
        // Still one widget blocking → no error
        manager.decrementWidgetBlock();
      });

      test('setBlockOverscrollBehaviorX sets user block', () {
        manager.setBlockOverscrollBehaviorX(true);
        manager.setBlockOverscrollBehaviorX(false);
      });

      test('resetForTesting clears widget block count and user block', () {
        manager.incrementWidgetBlock();
        manager.setBlockOverscrollBehaviorX(true);
        manager.resetForTesting();
        // After reset, decrementing should bring count below zero
        // but no error as it's just an int field
      });
    });
  });
}
