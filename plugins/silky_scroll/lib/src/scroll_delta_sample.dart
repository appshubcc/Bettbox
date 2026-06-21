/// A single scroll-delta measurement paired with a timestamp.
///
/// Used by [ScrollDeltaSampleAnalyzer] to compute scroll velocity.
final class ScrollDeltaSample {
  const ScrollDeltaSample(this.delta, this.timeMs);

  /// Scroll delta in logical pixels (positive = forward/down).
  final double delta;

  /// Timestamp in milliseconds.
  final int timeMs;

  @override
  String toString() => 'ScrollDeltaSample(delta: $delta, timeMs: $timeMs)';
}
