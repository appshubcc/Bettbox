import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';

/// A custom two-dimensional viewport for the code editor.
///
/// This viewport is used internally by [CodeForge] to enable both vertical
/// and horizontal scrolling within the editor. It delegates to a
/// [Render2DCodeField] for layout and painting.
class CustomViewport extends TwoDimensionalViewport {
  final bool lineWrap;

  /// Creates a [CustomViewport] with the required scroll offsets and axes.
  const CustomViewport({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate super.delegate,
    required super.mainAxis,
    required this.lineWrap,
  });

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return Render2DCodeField(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      delegate: delegate,
      mainAxis: mainAxis,
      childManager: context as TwoDimensionalChildManager,
      lineWrap: lineWrap,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderTwoDimensionalViewport renderObject,
  ) {
    (renderObject as Render2DCodeField).lineWrap = lineWrap;
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..delegate = delegate
      ..mainAxis = mainAxis;
  }
}

/// The render object for the code editor's two-dimensional viewport.
///
/// This class handles the layout of the code editor content and manages
/// the content dimensions for both vertical and horizontal scrolling.
class Render2DCodeField extends RenderTwoDimensionalViewport {
  bool lineWrap;

  /// Creates a [Render2DCodeField] with the required scroll configuration.
  Render2DCodeField({
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.delegate,
    required super.mainAxis,
    required super.childManager,
    required this.lineWrap,
  });

  @override
  void layoutChildSequence() {
    final child = buildOrObtainChildFor(ChildVicinity(xIndex: 0, yIndex: 0));

    if (child != null) {
      child.layout(
        BoxConstraints(
          minHeight: 0,
          minWidth: 0,
          maxWidth: lineWrap ? viewportDimension.width : double.infinity,
          maxHeight: double.infinity,
        ),
        parentUsesSize: true,
      );
      parentDataOf(child).layoutOffset = Offset.zero;

      verticalOffset.applyContentDimensions(
        0.0,
        math.max(0.0, child.size.height - viewportDimension.height),
      );
      horizontalOffset.applyContentDimensions(
        0.0,
        math.max(0.0, child.size.width - viewportDimension.width),
      );
    }
  }
}

class CustomScrollbar extends RawScrollbar {
  final TextStyle lineNumberStyle;
  final bool showLineNumberIndicator;
  final ValueNotifier<int> lineNumberNotifier;
  final BorderRadius borderRadius;
  final TextDirection textDirection;

  const CustomScrollbar({
    super.key,
    required super.child,
    required super.controller,
    required this.lineNumberStyle,
    required this.lineNumberNotifier,
    required this.showLineNumberIndicator,
    required this.borderRadius,
    required this.textDirection,
    super.thumbVisibility,
    super.interactive,
    super.thumbColor,
    super.thickness,
    super.crossAxisMargin,
    super.mainAxisMargin,
    super.scrollbarOrientation,
    super.trackBorderColor,
    super.fadeDuration,
    super.timeToFade,
    super.trackRadius,
    super.trackVisibility,
    super.minOverscrollLength,
    super.minThumbLength,
    super.padding,
    super.pressDuration,
    super.trackColor,
    super.notificationPredicate,
  });

  @override
  RawScrollbarState<RawScrollbar> createState() => _CustomScrollbarState();
}

class _CustomScrollbarState extends RawScrollbarState<CustomScrollbar> {
  bool _isDragging = false;
  @override
  void initState() {
    super.initState();
    widget.lineNumberNotifier.addListener(_onLineNumberChanged);
  }

  @override
  void dispose() {
    widget.lineNumberNotifier.removeListener(_onLineNumberChanged);
    super.dispose();
  }

  void _onLineNumberChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void handleThumbPressStart(Offset localPosition) {
    super.handleThumbPressStart(localPosition);
    setState(() => _isDragging = true);
  }

  @override
  void handleThumbPressEnd(Offset localPosition, Velocity velocity) {
    super.handleThumbPressEnd(localPosition, velocity);
    setState(() => _isDragging = false);
  }

  @override
  void updateScrollbarPainter() {
    scrollbarPainter
      ..color = widget.thumbColor ?? Colors.grey.withAlpha(100)
      ..textDirection = Directionality.of(context)
      ..thickness = widget.thickness ?? 8.0
      ..shape = _CustomThumbBorder(
        isDragging: _isDragging,
        showLineNumberIndicator: widget.showLineNumberIndicator,
        color: widget.thumbColor ?? Colors.grey.withAlpha(100),
        lineNumber: widget.lineNumberNotifier.value,
        lineNumberStyle: widget.lineNumberStyle,
        borderRadius: widget.borderRadius,
        textDirection: widget.textDirection,
        thickness: widget.thickness ?? 15,
      );
  }
}

class _CustomThumbBorder extends RoundedRectangleBorder {
  final bool isDragging, showLineNumberIndicator;
  final Color color;
  final int lineNumber;
  final TextStyle lineNumberStyle;
  final TextDirection textDirection;
  final double thickness;

  late final TextPainter _lineNumberPainter;

  _CustomThumbBorder({
    required this.isDragging,
    required this.color,
    required this.lineNumber,
    required this.lineNumberStyle,
    required this.showLineNumberIndicator,
    required this.textDirection,
    required this.thickness,
    required super.borderRadius,
  }) : super(side: BorderSide.none) {
    _lineNumberPainter =
        TextPainter(
            text: TextSpan(text: lineNumber.toString(), style: lineNumberStyle),
          )
          ..textDirection = textDirection
          ..layout();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (!showLineNumberIndicator) return;

    final double w = max(_lineNumberPainter.width + 10, 100);
    final double h = max(_lineNumberPainter.height + 3, 30);

    final paint = Paint()..color = color;

    if (isDragging) {
      final isLtr = this.textDirection == TextDirection.ltr;
      final bubbleRect = Rect.fromLTWH(
        isLtr
            ? rect.center.dx - (105 + thickness)
            : rect.center.dx + thickness + 10,
        rect.center.dy - 15,
        w,
        h,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(bubbleRect, Radius.circular(15)),
        paint,
      );

      _lineNumberPainter.paint(
        canvas,
        Offset(
          bubbleRect.left + (bubbleRect.width - _lineNumberPainter.width) / 2,
          bubbleRect.top + (bubbleRect.height - _lineNumberPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is _CustomThumbBorder &&
        other.isDragging == isDragging &&
        other.showLineNumberIndicator == showLineNumberIndicator &&
        other.color == color &&
        other.lineNumber == lineNumber &&
        other.lineNumberStyle == lineNumberStyle &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(
    isDragging,
    showLineNumberIndicator,
    color,
    lineNumber,
    lineNumberStyle,
    borderRadius,
  );

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)));

  @override
  ShapeBorder scale(double t) => this;
}
