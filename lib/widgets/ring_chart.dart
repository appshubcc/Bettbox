import 'dart:math';

import 'package:bett_box/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

@immutable
class RingSegment {
  final double value;
  final Color color;

  const RingSegment({required this.value, required this.color});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RingSegment && value == other.value && color == other.color;

  @override
  int get hashCode => Object.hash(value, color);
}

class RingChart extends StatefulWidget {
  final List<RingSegment> segments;
  final double? total;
  final Color trackColor;
  final Widget? centerChild;
  final double size;
  final double strokeWidth;

  const RingChart({
    super.key,
    required this.segments,
    required this.trackColor,
    this.total,
    this.centerChild,
    this.size = 76,
    this.strokeWidth = 5.8,
  });

  @override
  State<RingChart> createState() => _RingChartState();
}

class _RingChartState extends State<RingChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _progress;
  late final VoidCallback _cancelEntrance;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _cancelEntrance = whenRouteEntered(context, _controller.forward);
  }

  @override
  void dispose() {
    _cancelEntrance();
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(
                segments: widget.segments,
                total: widget.total,
                trackColor: widget.trackColor,
                strokeWidth: widget.strokeWidth,
                progress: _progress,
              ),
            ),
          ),
          ?widget.centerChild,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final List<RingSegment> segments;
  final double? total;
  final Color trackColor;
  final double strokeWidth;
  final Animation<double> progress;

  _RingPainter({
    required this.segments,
    required this.total,
    required this.trackColor,
    required this.strokeWidth,
    required this.progress,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = trackColor,
    );

    final sum = segments.fold<double>(0, (acc, item) => acc + item.value);
    final fullTotal = max(sum, total ?? 0);
    if (fullTotal <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final visible = segments.where((item) => item.value > 0).length;
    final hasGap = visible > 1;
    final gap = hasGap ? (strokeWidth + 2.5) / radius : 0.0;
    final availableAngle = 2 * pi - gap * (hasGap ? visible : 0);

    final progress = this.progress.value;
    var startAngle = -pi / 2 + gap / 2;
    for (final segment in segments) {
      if (segment.value <= 0) continue;
      final sweepAngle = segment.value / fullTotal * availableAngle * progress;
      if (sweepAngle <= 0) continue;
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = segment.color,
      );
      startAngle += sweepAngle + gap;
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.total != total ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        !listEquals(oldDelegate.segments, segments);
  }
}
