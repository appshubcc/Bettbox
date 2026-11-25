import 'dart:async';

import 'package:bett_box/state.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

typedef TvTextFieldParams = ({
  FocusNode? focusNode,
  bool readOnly,
  bool? showCursor,
});

class TvTextField extends StatefulWidget {
  final FocusNode? focusNode;
  final bool readOnly;
  final Widget Function(TvTextFieldParams params) builder;

  const TvTextField({
    super.key,
    this.focusNode,
    this.readOnly = false,
    required this.builder,
  });

  @override
  State<TvTextField> createState() => _TvTextFieldState();
}

class _TvTextFieldState extends State<TvTextField> {
  static final _activateKeys = {
    LogicalKeyboardKey.select,
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.numpadEnter,
  };

  FocusNode? _ownedNode;
  bool _editing = false;

  FocusNode get _node => widget.focusNode ?? (_ownedNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    if (globalState.isAndroidTV) {
      _node.addListener(_handleFocusChange);
    }
  }

  @override
  void didUpdateWidget(TvTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!globalState.isAndroidTV || oldWidget.focusNode == widget.focusNode) {
      return;
    }
    (oldWidget.focusNode ?? _ownedNode)?.removeListener(_handleFocusChange);
    _node.addListener(_handleFocusChange);
    _editing = false;
  }

  @override
  void dispose() {
    if (globalState.isAndroidTV) {
      _node.removeListener(_handleFocusChange);
    }
    _ownedNode?.dispose();
    super.dispose();
  }

  void _setEditing(bool value) {
    if (_editing == value || !mounted) return;
    setState(() => _editing = value);
  }

  void _handleFocusChange() {
    if (!_node.hasFocus) _setEditing(false);
  }

  void _handlePointerEnd(PointerEvent _) {
    Timer.run(() {
      if (mounted && !_node.hasFocus) _setEditing(false);
    });
  }

  KeyEventResult _onKeyEvent(FocusNode _, KeyEvent event) {
    if (event is KeyUpEvent || !_node.hasPrimaryFocus) {
      return KeyEventResult.ignored;
    }
    final editable = _node.context
        ?.findAncestorStateOfType<EditableTextState>();
    if (editable == null) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.select ||
        (!_editing && _activateKeys.contains(key))) {
      if (event is KeyDownEvent && !widget.readOnly) {
        if (_editing) {
          editable.requestKeyboard();
        } else {
          _setEditing(true);
        }
      }
      return KeyEventResult.handled;
    }
    final direction = _direction(key, editable.textEditingValue);
    if (direction == null || !_node.focusInDirection(direction)) {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  TraversalDirection? _direction(
    LogicalKeyboardKey key,
    TextEditingValue value,
  ) {
    final direction = switch (key) {
      LogicalKeyboardKey.arrowUp => TraversalDirection.up,
      LogicalKeyboardKey.arrowDown => TraversalDirection.down,
      LogicalKeyboardKey.arrowLeft => TraversalDirection.left,
      LogicalKeyboardKey.arrowRight => TraversalDirection.right,
      _ => null,
    };
    if (direction == null || !_editing) return direction;
    final text = value.text;
    final selection = value.selection;
    final offset = selection.isValid
        ? selection.extentOffset.clamp(0, text.length)
        : text.length;
    final collapsed = !selection.isValid || selection.isCollapsed;
    final atEdge = switch (direction) {
      TraversalDirection.up => !text.substring(0, offset).contains('\n'),
      TraversalDirection.down => !text.substring(offset).contains('\n'),
      TraversalDirection.left => collapsed && offset == 0,
      TraversalDirection.right => collapsed && offset >= text.length,
    };
    return atEdge ? direction : null;
  }

  @override
  Widget build(BuildContext context) {
    if (!globalState.isAndroidTV) {
      return widget.builder((
        focusNode: widget.focusNode,
        readOnly: widget.readOnly,
        showCursor: null,
      ));
    }
    final locked = !widget.readOnly && !_editing;
    return Listener(
      onPointerDown: widget.readOnly ? null : (_) => _setEditing(true),
      onPointerUp: _handlePointerEnd,
      onPointerCancel: _handlePointerEnd,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: _onKeyEvent,
        child: widget.builder((
          focusNode: _node,
          readOnly: widget.readOnly || locked,
          showCursor: locked ? true : null,
        )),
      ),
    );
  }
}
