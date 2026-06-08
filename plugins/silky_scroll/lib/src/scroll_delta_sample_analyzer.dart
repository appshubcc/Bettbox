import 'scroll_delta_sample.dart';

/// Default retention window for scroll-delta samples.
const int kDefaultSampleRetentionMs = 1000;

/// Default time-window size for grouping samples in V3 speed calc.
const int kDefaultWindowMs = 60;

/// Default minimum speed threshold (px/s) below which a segment
/// is considered stationary and excluded from the average.
const double kDefaultMinSpeedThresholdPxS = 1.0;

/// Stateless utility that analyses [ScrollDeltaSample] lists.
///
/// Modelled after `PositionSampleAnalyzer` (Kotlin) but adapted for
/// scroll-delta semantics: samples carry a *delta* (px per event)
/// rather than an absolute position, so "speed" is derived by
/// accumulating deltas over time.
///
/// All methods are static — the class holds no mutable state.
abstract final class ScrollDeltaSampleAnalyzer {
  // ── Filtering ─────────────────────────────────────────────────

  /// Removes samples older than [retentionMs] relative to [currentTimeMs].
  static List<ScrollDeltaSample> filterSamples(
    List<ScrollDeltaSample> samples,
    int currentTimeMs, [
    int retentionMs = kDefaultSampleRetentionMs,
  ]) {
    final int cutoff = currentTimeMs - retentionMs;
    return samples.where((s) => s.timeMs >= cutoff).toList();
  }

  // ── Speed calculation ─────────────────────────────────────────

  /// Returns the average scroll speed in **logical-pixels / second**.
  ///
  /// Groups samples into [windowMs]-wide buckets, computes per-window
  /// speeds, and filters out stationary segments.
  /// Positive = forward / down.
  ///
  /// Assumes [samples] are already in chronological order (as maintained
  /// by `_recordDelta`).  Falls back to sorting only when the first
  /// sample's timestamp exceeds the last — which should not happen in
  /// normal operation.
  static double calculateAverageSpeed(
    List<ScrollDeltaSample> samples, {
    int windowMs = kDefaultWindowMs,
    double minSpeedThresholdPxS = kDefaultMinSpeedThresholdPxS,
  }) {
    if (samples.length < 2) return 0.0;

    // Fast-path: samples are expected to be time-sorted already.
    // Only sort when the invariant is violated (defensive guard).
    List<ScrollDeltaSample> sorted;
    if (samples.first.timeMs <= samples.last.timeMs) {
      sorted = samples;
    } else {
      sorted = List.of(samples)..sort((a, b) => a.timeMs.compareTo(b.timeMs));
    }

    final int totalTimeDiffMs = sorted.last.timeMs - sorted.first.timeMs;
    if (totalTimeDiffMs <= 0) return 0.0;

    // Single-pass: accumulate per-window aggregates (delta sum, time
    // sum, count) without allocating intermediate group lists.
    // Then compute inter-window speeds inline.

    // Window aggregate accumulators.
    int prevTimeSum = 0;
    int prevCount = 0;

    double curDeltaSum = 0.0;
    int curTimeSum = 0;
    int curCount = 0;
    int windowStart = sorted.first.timeMs;

    // Speed accumulators (avoid allocating a List<double>).
    double speedSum = 0.0;
    int speedCount = 0;
    double movementSpeedSum = 0.0;
    int movementSpeedCount = 0;

    bool firstWindowDone = false;

    void flushWindow() {
      if (curCount == 0) return;
      if (!firstWindowDone) {
        // Store as previous; no speed to compute yet.
        prevTimeSum = curTimeSum;
        prevCount = curCount;
        firstWindowDone = true;
      } else {
        final double prevAvgTime = prevTimeSum / prevCount;
        final double curAvgTime = curTimeSum / curCount;
        final double dt = curAvgTime - prevAvgTime;
        if (dt > 0) {
          final double speed = (curDeltaSum / dt) * 1000.0;
          speedSum += speed;
          speedCount++;
          if (speed.abs() > minSpeedThresholdPxS) {
            movementSpeedSum += speed;
            movementSpeedCount++;
          }
        }
        // Shift current → previous.
        prevTimeSum = curTimeSum;
        prevCount = curCount;
      }
    }

    for (final sample in sorted) {
      if (sample.timeMs < windowStart + windowMs) {
        curDeltaSum += sample.delta;
        curTimeSum += sample.timeMs;
        curCount++;
      } else {
        flushWindow();
        curDeltaSum = sample.delta;
        curTimeSum = sample.timeMs;
        curCount = 1;
        windowStart = sample.timeMs;
      }
    }
    // Flush the last window.
    flushWindow();

    if (speedCount == 0) {
      // Fewer than 2 windows — fall back to total delta / total time.
      double totalDelta = 0.0;
      for (final s in sorted) {
        totalDelta += s.delta;
      }
      return (totalDelta / totalTimeDiffMs) * 1000.0;
    }

    if (movementSpeedCount == 0) return speedSum / speedCount;
    return movementSpeedSum / movementSpeedCount;
  }
}
