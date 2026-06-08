import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silky_scroll/silky_scroll.dart';

void main() {
  group('SilkyScrollConfig', () {
    test('default values', () {
      const config = SilkyScrollConfig();
      expect(config.silkyScrollDuration, const Duration(milliseconds: 1600));
      expect(config.scrollSpeed, 1);
      expect(config.animationCurve, Curves.easeOutCirc);
      expect(config.direction, Axis.vertical);
      expect(config.edgeLockingDelay, const Duration(milliseconds: 650));
      expect(config.enableStretchEffect, isTrue);
      expect(config.edgeForwardingMode, EdgeForwardingMode.sameAxisOnly);
      expect(
        config.mouseWheelVerticalDeltaBehavior,
        MouseWheelVerticalDeltaBehavior.forwardToVerticalAncestorOrSelf,
      );
      expect(config.blockWebOverscrollBehaviorX, isTrue);
      expect(config.debugMode, isFalse);
    });

    test('copyWith replaces fields', () {
      const original = SilkyScrollConfig(scrollSpeed: 1.0);
      final modified = original.copyWith(
        scrollSpeed: 2.5,
        debugMode: true,
        edgeForwardingMode: EdgeForwardingMode.none,
        mouseWheelVerticalDeltaBehavior: MouseWheelVerticalDeltaBehavior.always,
        blockWebOverscrollBehaviorX: false,
      );
      expect(modified.scrollSpeed, 2.5);
      expect(modified.debugMode, isTrue);
      expect(modified.edgeForwardingMode, EdgeForwardingMode.none);
      expect(
        modified.mouseWheelVerticalDeltaBehavior,
        MouseWheelVerticalDeltaBehavior.always,
      );
      expect(modified.blockWebOverscrollBehaviorX, isFalse);
      // Unchanged fields
      expect(modified.silkyScrollDuration, original.silkyScrollDuration);
      expect(modified.animationCurve, original.animationCurve);
    });

    test('copyWith with no args returns equal config', () {
      const original = SilkyScrollConfig(scrollSpeed: 3.0);
      final copy = original.copyWith();
      expect(copy, equals(original));
      expect(copy.hashCode, original.hashCode);
    });

    test('equality', () {
      const a = SilkyScrollConfig(scrollSpeed: 2.0, debugMode: true);
      const b = SilkyScrollConfig(scrollSpeed: 2.0, debugMode: true);
      const c = SilkyScrollConfig(scrollSpeed: 1.0);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode consistency', () {
      const a = SilkyScrollConfig(scrollSpeed: 2.0);
      const b = SilkyScrollConfig(scrollSpeed: 2.0);
      expect(a.hashCode, b.hashCode);
    });

    test('toString contains key properties', () {
      const config = SilkyScrollConfig(scrollSpeed: 1.5, debugMode: true);
      final str = config.toString();
      expect(str, contains('SilkyScrollConfig'));
      expect(str, contains('scrollSpeed: 1.5'));
      expect(str, contains('debugMode: true'));
      expect(str, contains('blockWebOverscrollBehaviorX: true'));
      expect(
        str,
        contains(
          'mouseWheelVerticalDeltaBehavior: '
          'MouseWheelVerticalDeltaBehavior.forwardToVerticalAncestorOrSelf',
        ),
      );
      expect(
        str,
        contains('edgeForwardingMode: EdgeForwardingMode.sameAxisOnly'),
      );
    });
  });
}
