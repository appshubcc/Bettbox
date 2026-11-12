import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class FrameProbe {
  FrameProbe._();

  static const _frames = 40;

  static String? _label;
  static int _remaining = 0;
  static int? _lastBuildStart;
  static bool _attached = false;

  static void mark(String label) {
    if (!kProfileMode) return;
    if (!_attached) {
      _attached = true;
      SchedulerBinding.instance.addTimingsCallback(_onTimings);
    }
    _label = label;
    _remaining = _frames;
    _lastBuildStart = null;
  }

  static String _ms(int microseconds) =>
      (microseconds / 1000).toStringAsFixed(1);

  static void _onTimings(List<FrameTiming> timings) {
    final label = _label;
    if (label == null) return;
    for (final timing in timings) {
      if (_remaining <= 0) break;
      final start = timing.timestampInMicroseconds(FramePhase.buildStart);
      final last = _lastBuildStart;
      _lastBuildStart = start;
      _remaining--;
      debugPrint(
        '[frame] $label '
        'build=${_ms(timing.buildDuration.inMicroseconds)} '
        'raster=${_ms(timing.rasterDuration.inMicroseconds)} '
        'gap=${last == null ? '-' : _ms(start - last)}',
      );
    }
    if (_remaining <= 0) _label = null;
  }
}
