import 'dart:math' as math;

import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'builder.dart';
import 'grid.dart';

typedef EditableGridWrapper = Widget Function(Widget child);

class EditableGrid<T extends Object> extends StatefulWidget {
  final List<T> items;
  final bool editing;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double? mainAxisExtent;
  final Object Function(T item) keyOf;
  final int Function(T item) crossAxisCellCountOf;
  final num? Function(T item)? mainAxisCellCountOf;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final bool Function(T item)? canResize;
  final ValueChanged<T>? onResize;
  final bool Function(T item)? canDelete;
  final ValueChanged<T>? onDelete;
  final void Function(T from, T to)? onMove;
  final VoidCallback? onLongPress;
  final EditableGridWrapper? overlayWrapper;

  const EditableGrid({
    super.key,
    required this.items,
    required this.editing,
    required this.crossAxisCount,
    required this.keyOf,
    required this.crossAxisCellCountOf,
    required this.itemBuilder,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.mainAxisExtent,
    this.mainAxisCellCountOf,
    this.canResize,
    this.onResize,
    this.canDelete,
    this.onDelete,
    this.onMove,
    this.onLongPress,
    this.overlayWrapper,
  });

  @override
  State<EditableGrid<T>> createState() => _EditableGridState<T>();
}

class _EditableGridState<T extends Object> extends State<EditableGrid<T>>
    with SingleTickerProviderStateMixin {
  final _gridKey = GlobalKey();
  late final _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: 0.5,
  );
  DateTime _lastMove = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    if (widget.editing) _shake.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(EditableGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editing == widget.editing) return;
    if (widget.editing) {
      _shake.repeat(reverse: true);
    } else {
      _shake.stop();
      _shake.value = 0.5;
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _move(T from, T to) {
    final now = DateTime.now();
    if (now.difference(_lastMove) < const Duration(milliseconds: 220)) return;
    _lastMove = now;
    widget.onMove?.call(from, to);
  }

  Widget _buildTile(BuildContext context, T item, int index) {
    final child = widget.itemBuilder(context, item);
    if (!widget.editing) {
      final onLongPress = widget.onLongPress;
      if (onLongPress == null) return child;
      return GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onLongPress();
        },
        child: child,
      );
    }
    final canResize = widget.canResize?.call(item) ?? false;
    final canDelete = widget.canDelete?.call(item) ?? false;
    final onResize = widget.onResize;
    final onDelete = widget.onDelete;
    return _EditTile<T>(
      item: item,
      keyOf: widget.keyOf,
      shake: _shake,
      phase: index * 1.7,
      cells: math.max(1, widget.crossAxisCellCountOf(item)),
      onResize: canResize && onResize != null
          ? () {
              HapticFeedback.selectionClick();
              onResize(item);
            }
          : null,
      onDelete: canDelete && onDelete != null ? () => onDelete(item) : null,
      onMove: widget.onMove == null ? null : _move,
      overlayWrapper: widget.overlayWrapper,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DeferredPointerHandler(
      child: Grid(
        key: _gridKey,
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
        mainAxisExtent: widget.mainAxisExtent,
        children: [
          for (final (index, item) in widget.items.indexed)
            GridItem(
              key: ValueKey(widget.keyOf(item)),
              crossAxisCellCount: math.min(
                widget.crossAxisCellCountOf(item),
                widget.crossAxisCount,
              ),
              mainAxisCellCount: widget.mainAxisCellCountOf?.call(item),
              child: _FlipTile(
                gridKey: _gridKey,
                child: _buildTile(context, item, index),
              ),
            ),
        ],
      ),
    );
  }
}

class _FlipTile extends StatefulWidget {
  final GlobalKey gridKey;
  final Widget child;

  const _FlipTile({required this.gridKey, required this.child});

  @override
  State<_FlipTile> createState() => _FlipTileState();
}

class _FlipTileState extends State<_FlipTile>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
    value: 1,
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  Offset? _last;
  Offset _from = Offset.zero;

  Offset get _offset =>
      Offset.lerp(_from, Offset.zero, _curve.value) ?? Offset.zero;

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _check(Duration _) {
    if (!mounted) return;
    final box = context.findRenderObject();
    final grid = widget.gridKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize || grid == null) return;
    final position = box.localToGlobal(Offset.zero, ancestor: grid);
    final last = _last;
    _last = position;
    if (last == null || (last - position).distance < 0.5) return;
    _from = _offset + last - position;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(_check);
    return AnimatedBuilder(
      animation: _curve,
      builder: (_, child) => Transform.translate(offset: _offset, child: child),
      child: widget.child,
    );
  }
}

class _EditTile<T extends Object> extends StatelessWidget {
  final T item;
  final Object Function(T item) keyOf;
  final Animation<double> shake;
  final double phase;
  final int cells;
  final VoidCallback? onResize;
  final VoidCallback? onDelete;
  final void Function(T from, T to)? onMove;
  final EditableGridWrapper? overlayWrapper;
  final Widget child;

  const _EditTile({
    required this.item,
    required this.keyOf,
    required this.shake,
    required this.phase,
    required this.cells,
    required this.onResize,
    required this.onDelete,
    required this.onMove,
    required this.overlayWrapper,
    required this.child,
  });

  Widget _badge(BuildContext context, IconData icon, Color color, Color fg) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(icon, size: 13, color: fg),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isTv = globalState.isAndroidTV;
    final onResize = this.onResize;
    final onDelete = this.onDelete;
    final content = AbsorbPointer(child: child);
    final tappable = isTv
        ? FocusStateBuilder(
            builder: (context, focused) => DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: focused
                    ? Border.all(color: colorScheme.primary, width: 2.5)
                    : null,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onDelete ?? onResize,
                child: ExcludeFocus(child: content),
              ),
            ),
          )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onResize,
            child: content,
          );
    final decorated = Stack(
      clipBehavior: Clip.none,
      children: [
        tappable,
        if (onResize != null)
          PositionedDirectional(
            top: 6,
            end: 6,
            child: IgnorePointer(
              child: _badge(
                context,
                ReIcons.maximize,
                colorScheme.primary,
                colorScheme.onPrimary,
              ),
            ),
          ),
        if (onDelete != null)
          PositionedDirectional(
            top: -8,
            start: -8,
            child: DeferPointer(
              child: GestureDetector(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: _badge(
                    context,
                    ReIcons.x,
                    colorScheme.error,
                    colorScheme.onError,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
    final jiggle = AnimatedBuilder(
      animation: shake,
      builder: (_, child) => Transform.rotate(
        angle: math.sin(shake.value * math.pi + phase) * 0.012 / cells,
        child: child,
      ),
      child: decorated,
    );
    final onMove = this.onMove;
    if (onMove == null || isTv) return jiggle;
    final target = DragTarget<T>(
      onWillAcceptWithDetails: (details) {
        if (keyOf(details.data) != keyOf(item)) onMove(details.data, item);
        return false;
      },
      builder: (_, _, _) => jiggle,
    );
    final feedback = Builder(
      builder: (_) {
        final box = context.findRenderObject();
        final size = box is RenderBox && box.hasSize ? box.size : null;
        Widget lifted = Transform.scale(
          scale: 1.04,
          child: SizedBox(
            width: size?.width,
            height: size?.height,
            child: AbsorbPointer(child: child),
          ),
        );
        lifted = overlayWrapper?.call(lifted) ?? lifted;
        return Material(type: MaterialType.transparency, child: lifted);
      },
    );
    final placeholder = Opacity(opacity: 0.3, child: content);
    return system.isDesktop
        ? Draggable<T>(
            data: item,
            feedback: feedback,
            childWhenDragging: placeholder,
            child: target,
          )
        : LongPressDraggable<T>(
            data: item,
            delay: const Duration(milliseconds: 200),
            feedback: feedback,
            childWhenDragging: placeholder,
            child: target,
          );
  }
}
