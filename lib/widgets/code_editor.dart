import 'dart:math' as math;

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/common.dart';
import 'package:code_forge/code_forge.dart'
    show CodeForgeController, CodeForgeSuggestionDetails;
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:material_ui/material_ui.dart';

class CaretPopupLayout extends SingleChildLayoutDelegate {
  final Rect caretRect;
  final EdgeInsets padding;
  final double maxWidth;
  final double maxHeight;
  final double gap;
  final double margin;

  const CaretPopupLayout({
    required this.caretRect,
    this.padding = EdgeInsets.zero,
    this.maxWidth = 400,
    this.maxHeight = 400,
    this.gap = 4,
    this.margin = 8,
  });

  double get _below => caretRect.bottom + gap;

  double get _above => caretRect.top - gap;

  double get _top => padding.top + margin;

  double _bottom(double height) => height - padding.bottom - margin;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final room = math.max(
      _bottom(constraints.maxHeight) - _below,
      _above - _top,
    );
    return BoxConstraints(
      maxWidth: math.min(
        maxWidth,
        math.max(0.0, constraints.maxWidth - padding.horizontal - margin * 2),
      ),
      maxHeight: room.clamp(0.0, maxHeight),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final spaceBelow = _bottom(size.height) - _below;
    final spaceAbove = _above - _top;
    final opensBelow =
        childSize.height <= spaceBelow || spaceBelow >= spaceAbove;
    final top = opensBelow ? _below : _above - childSize.height;
    return Offset(
      _clampInto(
        caretRect.left,
        childSize.width,
        padding.left + margin,
        size.width - padding.right - margin,
      ),
      _clampInto(top, childSize.height, _top, _bottom(size.height)),
    );
  }

  double _clampInto(double start, double extent, double min, double max) =>
      start.clamp(min, math.max(min, max - extent));

  @override
  bool shouldRelayout(CaretPopupLayout oldDelegate) {
    return caretRect != oldDelegate.caretRect ||
        padding != oldDelegate.padding ||
        maxWidth != oldDelegate.maxWidth ||
        maxHeight != oldDelegate.maxHeight ||
        gap != oldDelegate.gap ||
        margin != oldDelegate.margin;
  }
}

const _suggestionInset = 8.0;
const _suggestionItemGap = 4.0;
const _suggestionItemPadding = 10.0;
const _suggestionMinWidth = 160.0;
const _suggestionDetailGap = 16.0;
const _suggestionItemShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
);
const _suggestionShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(8 + _suggestionInset)),
);

class EditorCompletionPopup extends StatefulWidget {
  final CodeForgeSuggestionDetails details;
  final TextStyle textStyle;

  const EditorCompletionPopup({
    super.key,
    required this.details,
    required this.textStyle,
  });

  @override
  State<EditorCompletionPopup> createState() => _EditorCompletionPopupState();
}

class _EditorCompletionPopupState extends State<EditorCompletionPopup> {
  final _scrollController = ScrollController();

  TextStyle get _detailStyle => widget.textStyle.copyWith(
    fontSize: (widget.textStyle.fontSize ?? 14) * 0.85,
  );

  double get _itemExtent =>
      (widget.textStyle.fontSize ?? 14) * 2 + _suggestionItemGap;

  static const _listPadding = _suggestionInset - _suggestionItemGap / 2;

  static const _itemInset = _suggestionItemPadding + _suggestionInset;

  @override
  void didUpdateWidget(covariant EditorCompletionPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.details.selectedIndex != oldWidget.details.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _revealSelected() {
    final index = widget.details.selectedIndex;
    if (!mounted || index == null || !_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    final top = index * _itemExtent;
    final bottom = top + _itemExtent + _listPadding * 2;
    final target = math.max(
      math.min(position.pixels, top),
      bottom - position.viewportDimension,
    );
    if (target != position.pixels) {
      _scrollController.jumpTo(
        target.clamp(position.minScrollExtent, position.maxScrollExtent),
      );
    }
  }

  ({List<double> labels, double content}) _measureWidths(BuildContext context) {
    final painter = TextPainter(
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    );
    final widths = [
      for (final suggestion in widget.details.suggestions)
        _measure(painter, suggestion.label, widget.textStyle),
    ];
    var widest = 0.0;
    for (final (index, suggestion) in widget.details.suggestions.indexed) {
      var width = widths[index];
      if (suggestion.detail case final detail? when detail.isNotEmpty) {
        width += _suggestionDetailGap + _measure(painter, detail, _detailStyle);
      }
      widest = math.max(widest, width);
    }
    painter.dispose();
    return (labels: widths, content: widest + _itemInset * 2);
  }

  double _measure(TextPainter painter, String text, TextStyle style) {
    painter.text = TextSpan(text: text, style: style);
    painter.layout();
    return painter.width.ceilToDouble();
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    double labelWidth,
    double rowWidth,
  ) {
    final colorScheme = context.colorScheme;
    final selected = index == widget.details.selectedIndex;
    final suggestion = widget.details.suggestions[index];
    final detail = suggestion.detail;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _suggestionItemGap / 2),
      child: InkWell(
        canRequestFocus: false,
        customBorder: _suggestionItemShape,
        splashColor: Colors.transparent,
        onTap: () => widget.details.onAccept(index),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: _suggestionItemPadding,
          ),
          decoration: ShapeDecoration(
            color: selected ? colorScheme.secondaryContainer : null,
            shape: _suggestionItemShape,
          ),
          child: Row(
            children: [
              SizedBox(
                width: math.min(labelWidth, rowWidth),
                child: Text(
                  suggestion.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: widget.textStyle.copyWith(
                    color: selected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              if (detail != null &&
                  detail.isNotEmpty &&
                  rowWidth - labelWidth > _suggestionDetailGap) ...[
                const SizedBox(width: _suggestionDetailGap),
                Expanded(
                  child: Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: _detailStyle.copyWith(
                      color: selected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final widths = _measureWidths(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final width = widths.content
            .clamp(math.min(_suggestionMinWidth, maxWidth), maxWidth)
            .toDouble();
        final rowWidth = math.max(0.0, width - _itemInset * 2);
        return Material(
          type: MaterialType.card,
          elevation: 8,
          color: context.colorScheme.surfaceContainer,
          textStyle: widget.textStyle,
          clipBehavior: Clip.antiAlias,
          shape: _suggestionShape,
          child: SizedBox(
            width: width,
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                horizontal: _suggestionInset,
                vertical: _listPadding,
              ),
              itemExtent: _itemExtent,
              itemCount: widget.details.suggestions.length,
              itemBuilder: (context, index) =>
                  _buildItem(context, index, widths.labels[index], rowWidth),
            ),
          ),
        );
      },
    );
  }
}

class EditorMenuRoute extends PopupRoute<void> {
  final Offset anchor;
  final WidgetBuilder builder;

  EditorMenuRoute({
    required this.anchor,
    required this.builder,
    required this.barrierLabel,
  }) : super(requestFocus: false);

  @override
  final String? barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return CustomSingleChildLayout(
      delegate: _EditorMenuLayout(anchor: anchor),
      child: builder(context),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }
}

class _EditorMenuLayout extends SingleChildLayoutDelegate {
  final Offset anchor;

  const _EditorMenuLayout({required this.anchor});

  static const _margin = 8.0;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.loosen();
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    var top = anchor.dy;
    if (top + childSize.height > size.height - _margin) {
      top -= _margin + childSize.height;
    }
    final maxLeft = math.max(_margin, size.width - _margin - childSize.width);
    final maxTop = math.max(_margin, size.height - _margin - childSize.height);
    return Offset(
      anchor.dx.clamp(_margin, maxLeft),
      top.clamp(_margin, maxTop),
    );
  }

  @override
  bool shouldRelayout(_EditorMenuLayout oldDelegate) {
    return anchor != oldDelegate.anchor;
  }
}

class EditorSelectionToolbar extends StatelessWidget {
  final Offset anchorAbove;
  final Offset anchorBelow;
  final List<PopupMenuItemData> items;
  final Color backgroundColor;
  final Color? foregroundColor;
  final VoidCallback onDismiss;

  const EditorSelectionToolbar({
    super.key,
    required this.anchorAbove,
    required this.anchorBelow,
    required this.items,
    required this.backgroundColor,
    required this.onDismiss,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) => onDismiss(),
      child: TextSelectionToolbar(
        anchorAbove: anchorAbove,
        anchorBelow: anchorBelow,
        toolbarBuilder: (context, child) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: backgroundColor,
          ),
          child: child,
        ),
        children: [
          for (final item in items)
            TextSelectionToolbarTextButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: () {
                onDismiss();
                item.onPressed?.call();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.icon case final icon?) ...[
                    Icon(icon, size: 16, color: foregroundColor),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    item.label,
                    style: TextStyle(color: foregroundColor, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class EditorZoomMenuItem extends StatefulWidget {
  final double zoom;
  final double minZoom;
  final double maxZoom;
  final ValueChanged<double> onChanged;

  const EditorZoomMenuItem({
    super.key,
    required this.zoom,
    required this.minZoom,
    required this.maxZoom,
    required this.onChanged,
  });

  @override
  State<EditorZoomMenuItem> createState() => _EditorZoomMenuItemState();
}

class _EditorZoomMenuItemState extends State<EditorZoomMenuItem> {
  static const _step = 0.1;
  static const _tolerance = 0.2;

  late double _zoom = widget.zoom;

  void _stepBy(int direction) {
    final level = _zoom / _step;
    final next = direction > 0
        ? (level + _tolerance).floor() + 1
        : (level - _tolerance).ceil() - 1;
    final zoom = (next * _step).clamp(widget.minZoom, widget.maxZoom);
    setState(() => _zoom = zoom);
    widget.onChanged(zoom);
  }

  Widget _button(IconData icon, bool enabled, int direction) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      iconSize: 20,
      onPressed: enabled ? () => _stepBy(direction) : null,
      icon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          _button(Icons.remove, _zoom - widget.minZoom > _step / 2, -1),
          Expanded(
            child: Text(
              '${(_zoom * 100).round()}%',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface,
                fontSize: 15,
              ),
            ),
          ),
          _button(Icons.add, widget.maxZoom - _zoom > _step / 2, 1),
        ],
      ),
    );
  }
}

class EditorMagnifier extends StatelessWidget {
  final CodeForgeController controller;
  final ValueListenable<MagnifierInfo> magnifierInfo;
  final TextSpan? Function(int line, String text)? lineSpan;
  final TextStyle textStyle;
  final Color backgroundColor;
  final Color borderColor;
  final Color caretColor;
  final Color selectionColor;

  const EditorMagnifier({
    super.key,
    required this.controller,
    required this.magnifierInfo,
    required this.textStyle,
    required this.backgroundColor,
    required this.borderColor,
    required this.caretColor,
    required this.selectionColor,
    this.lineSpan,
  });

  static const _context = 10;
  static const _scale = 1.5;

  static int _unitsBefore(String text, int columns) {
    var units = 0;
    for (final rune in text.runes) {
      if (columns-- <= 0) break;
      units += rune > 0xFFFF ? 2 : 1;
    }
    return units;
  }

  ({
    int line,
    String text,
    int start,
    int end,
    int caret,
    int selectionStart,
    int selectionEnd,
  })
  _preview() {
    final selection = controller.selection;
    final length = controller.length;
    final offset = selection.extentOffset.clamp(0, length);
    final line = controller.getLineAtOffset(offset);
    final text = controller.getLineText(line);
    final lineStart = controller.getLineStartOffset(line);
    final caret = _unitsBefore(text, offset - lineStart);
    var start = math.max(0, caret - _context);
    var end = math.min(text.length, caret + _context);
    if (start > 0 && text.codeUnitAt(start) & 0xFC00 == 0xDC00) start--;
    if (end < text.length && text.codeUnitAt(end) & 0xFC00 == 0xDC00) end++;
    int unitsAt(int position) =>
        _unitsBefore(text, position.clamp(0, length) - lineStart);
    return (
      line: line,
      text: text,
      start: start,
      end: end,
      caret: caret,
      selectionStart: unitsAt(selection.start).clamp(start, end),
      selectionEnd: unitsAt(selection.end).clamp(start, end),
    );
  }

  List<InlineSpan> _slice(TextSpan span, int start, int end) {
    final pieces = <InlineSpan>[];
    var position = 0;
    void walk(InlineSpan node, TextStyle? inherited) {
      if (node is! TextSpan) return;
      final style = inherited?.merge(node.style) ?? node.style;
      final text = node.text;
      if (text != null) {
        final from = math.max(start, position);
        final to = math.min(end, position + text.length);
        if (from < to) {
          pieces.add(
            TextSpan(
              text: text.substring(from - position, to - position),
              style: style,
            ),
          );
        }
        position += text.length;
      }
      for (final child in node.children ?? const <InlineSpan>[]) {
        walk(child, style);
      }
    }

    walk(span, null);
    return pieces;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MagnifierInfo>(
      valueListenable: magnifierInfo,
      builder: (context, info, _) {
        final preview = _preview();
        final highlighted = lineSpan?.call(preview.line, preview.text);
        final span = TextSpan(
          style: textStyle,
          children: highlighted == null
              ? [
                  TextSpan(
                    text: preview.text.substring(preview.start, preview.end),
                  ),
                ]
              : _slice(highlighted, preview.start, preview.end),
        );
        final painter = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
          textScaler: const TextScaler.linear(_scale),
          maxLines: 1,
        )..layout();
        final caretDx = painter
            .getOffsetForCaret(
              TextPosition(offset: preview.caret - preview.start),
              Rect.zero,
            )
            .dx;
        final selectionBoxes = preview.selectionEnd > preview.selectionStart
            ? painter.getBoxesForSelection(
                TextSelection(
                  baseOffset: preview.selectionStart - preview.start,
                  extentOffset: preview.selectionEnd - preview.start,
                ),
              )
            : const <TextBox>[];
        final textHeight = painter.height;
        final textWidth = painter.width;
        painter.dispose();
        final bounds = info.fieldBounds;
        final caretRect = info.caretRect;
        final width = math.min(textWidth + 16, bounds.width * 0.6);
        final height = textHeight + 12;
        final handleX = caretRect.center.dx;
        final textLeft = handleX - caretDx;
        final left = (textLeft - 8)
            .clamp(bounds.left, math.max(bounds.left, bounds.right - width))
            .toDouble();
        final handleY = caretRect.bottom;
        var top = handleY - height - caretRect.height * 2;
        if (top < bounds.top + 4) top = handleY + caretRect.height;
        return Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    for (final box in selectionBoxes)
                      Positioned(
                        left: textLeft - left + box.left,
                        top: 6 + box.top,
                        width: box.right - box.left,
                        height: box.bottom - box.top,
                        child: ColoredBox(color: selectionColor),
                      ),
                    Positioned(
                      left: textLeft - left,
                      top: 6,
                      child: Text.rich(
                        span,
                        maxLines: 1,
                        softWrap: false,
                        textScaler: const TextScaler.linear(_scale),
                      ),
                    ),
                    Positioned(
                      left: handleX - left - 1,
                      top: 6,
                      width: 2,
                      height: textHeight,
                      child: ColoredBox(color: caretColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
