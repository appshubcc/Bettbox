import 'package:flutter_test/flutter_test.dart';
import 'package:silky_scroll/src/scroll_delta_sample.dart';
import 'package:silky_scroll/src/scroll_delta_sample_analyzer.dart';

void main() {
  group('ScrollDeltaSample', () {
    test('stores delta and timeMs', () {
      const sample = ScrollDeltaSample(5.0, 1000);
      expect(sample.delta, 5.0);
      expect(sample.timeMs, 1000);
    });
  });

  group('ScrollDeltaSampleAnalyzer.filterSamples', () {
    test('keeps samples within retention window', () {
      final samples = [
        const ScrollDeltaSample(1, 100),
        const ScrollDeltaSample(2, 500),
        const ScrollDeltaSample(3, 900),
      ];
      final result = ScrollDeltaSampleAnalyzer.filterSamples(
        samples,
        1000,
        600,
      );
      expect(result.length, 2);
      expect(result.first.delta, 2);
    });

    test('returns empty when all samples are too old', () {
      final samples = [
        const ScrollDeltaSample(1, 100),
        const ScrollDeltaSample(2, 200),
      ];
      final result = ScrollDeltaSampleAnalyzer.filterSamples(
        samples,
        1000,
        100,
      );
      expect(result, isEmpty);
    });
  });

  group('ScrollDeltaSampleAnalyzer.calculateAverageSpeed', () {
    test('returns 0 for empty or single sample', () {
      expect(ScrollDeltaSampleAnalyzer.calculateAverageSpeed([]), 0.0);
      expect(
        ScrollDeltaSampleAnalyzer.calculateAverageSpeed([
          const ScrollDeltaSample(5, 100),
        ]),
        0.0,
      );
    });

    test('computes non-zero speed for steady scrolling', () {
      // Simulate regular deltas every 50 ms over 1 second.
      final samples = List.generate(20, (i) => ScrollDeltaSample(10.0, i * 50));
      final speed = ScrollDeltaSampleAnalyzer.calculateAverageSpeed(samples);
      expect(speed.abs(), greaterThan(0));
    });
  });
}
