import 'dart:ui';
import 'package:bett_box/common/color.dart';
import 'package:flutter/material.dart';

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);
}

class LineChart extends StatefulWidget {
  final List<Point> points;
  final Color color;
  final Duration duration;
  final bool gradient;

  const LineChart({
    super.key,
    this.gradient = false,
    required this.points,
    required this.color,
    this.duration = Duration.zero,
  });

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  List<Point> prevPoints = [];
  List<Point> points = [];
  bool get _hasAnimation => widget.duration != Duration.zero;

  @override
  void initState() {
    super.initState();
    points = widget.points;
    prevPoints = points;

    // Create AnimationController only if needed
    if (_hasAnimation) {
      _controller = AnimationController(vsync: this, duration: widget.duration);
    }
  }

  @override
  void didUpdateWidget(LineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.points != points) {
      prevPoints = points;
      points = widget.points;

      // Trigger animation if needed
      if (_hasAnimation) {
        _controller?.forward(from: 0);
      } else {
        // Direct repaint without animation
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (_, container) {
          if (!_hasAnimation) {
            return CustomPaint(
              painter: LineChartPainter(
                prevPoints: points,
                points: points,
                progress: 1.0,
                gradient: widget.gradient,
                color: widget.color,
                hasAnimation: false,
              ),
              child: SizedBox(
                height: container.maxHeight,
                width: container.maxWidth,
              ),
            );
          }

          return AnimatedBuilder(
            animation: _controller!.view,
            builder: (_, _) {
              return CustomPaint(
                painter: LineChartPainter(
                  prevPoints: prevPoints,
                  points: points,
                  progress: _controller!.value,
                  gradient: widget.gradient,
                  color: widget.color,
                  hasAnimation: true,
                ),
                child: SizedBox(
                  height: container.maxHeight,
                  width: container.maxWidth,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<Point> prevPoints;
  final List<Point> points;
  final double progress;
  final Color color;
  final bool gradient;
  final bool hasAnimation;

  late Paint _strokePaint;
  late Paint _fillPaint;
  List<Point>? _cachedRenderPoints;
  List<Point>? _cachedPointsKey;

  LineChartPainter({
    required this.prevPoints,
    required this.points,
    required this.progress,
    required this.color,
    required this.gradient,
    this.hasAnimation = true,
  }) {
    _strokePaint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    _fillPaint = Paint()..style = PaintingStyle.fill;
  }

  List<Point> getRenderPoints(List<Point> points) {
    if (identical(points, _cachedPointsKey) && _cachedRenderPoints != null) {
      return _cachedRenderPoints!;
    }
    if (points.isEmpty) return [];
    double maxX = points[0].x;
    double minX = points[0].x;
    double maxY = points[0].y;
    double minY = points[0].y;

    for (final point in points) {
      if (point.x > maxX) maxX = point.x;
      if (point.x < minX) minX = point.x;
      if (point.y > maxY) maxY = point.y;
      if (point.y < minY) minY = point.y;
    }

    final result = points.map((e) {
      var x = (e.x - minX) / (maxX - minX);
      if (x.isNaN) x = 0;
      var y = (e.y - minY) / (maxY - minY);
      if (y.isNaN) y = 0;
      return Point(x, y);
    }).toList();

    _cachedPointsKey = points;
    _cachedRenderPoints = result;
    return result;
  }

  List<Point> getInterpolatePoints(
    List<Point> prevPoints,
    List<Point> points,
    double t,
  ) {
    final renderPrevPoints = getRenderPoints(prevPoints);
    final renderPoints = getRenderPoints(points);

    return List.generate(renderPoints.length, (i) {
      if (i > renderPrevPoints.length - 1) {
        return renderPoints[i];
      }
      final x = lerpDouble(renderPrevPoints[i].x, renderPoints[i].x, t)!;
      final y = lerpDouble(renderPrevPoints[i].y, renderPoints[i].y, t)!;
      return Point(x, y);
    });
  }

  Path getPath(List<Point> points, Size size) {
    final path = Path()
      ..moveTo(points[0].x * size.width, (1 - points[0].y) * size.height);

    for (var i = 1; i < points.length - 1; i++) {
      final nextPoint = points[i + 1];
      final currentPoint = points[i];
      final midX = (currentPoint.x + nextPoint.x) / 2;
      final midY = (currentPoint.y + nextPoint.y) / 2;

      path.quadraticBezierTo(
        currentPoint.x * size.width,
        (1 - currentPoint.y) * size.height,
        midX * size.width,
        (1 - midY) * size.height,
      );
    }

    path.lineTo(points.last.x * size.width, (1 - points.last.y) * size.height);
    return path;
  }

  Path getAnimatedPath(Size size) {
    final interpolatedPoints = getInterpolatePoints(
      prevPoints,
      points,
      progress,
    );
    final path = getPath(interpolatedPoints, size);

    // Expensive operation: only with animation
    final metric = path.computeMetrics().first;
    final length = metric.length;
    return metric.extractPath(0, length);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final chartSize = Size(size.width, size.height * 0.7);

    final Path path;
    if (!hasAnimation || progress >= 1.0) {
      final renderPoints = getRenderPoints(points);
      path = getPath(renderPoints, chartSize);
    } else {
      path = getAnimatedPath(chartSize);
    }

    if (gradient) {
      final fillPath = Path.from(path);
      fillPath.lineTo(size.width, size.height + _strokePaint.strokeWidth * 2);
      fillPath.lineTo(0, size.height + _strokePaint.strokeWidth * 2);
      fillPath.close();

      final shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.opacity38, color.opacity10],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height + _strokePaint.strokeWidth * 2),
      );

      canvas.drawPath(
        fillPath,
        _fillPaint..shader = shader,
      );
    }

    canvas.drawPath(
      path,
      _strokePaint..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.prevPoints != prevPoints ||
        oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.gradient != gradient;
  }
}
