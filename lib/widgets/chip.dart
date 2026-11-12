import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'text.dart';

class CommonChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ChipType type;
  final Widget? avatar;
  final TextStyle? labelStyle;

  const CommonChip({
    super.key,
    required this.label,
    this.labelStyle,
    this.onPressed,
    this.avatar,
    this.type = ChipType.action,
  });

  @override
  Widget build(BuildContext context) {
    if (type == ChipType.action) {
      return _ActionChip(
        label: label,
        labelStyle: labelStyle,
        avatar: avatar,
        onPressed: onPressed,
      );
    }
    final focusedBorder = WidgetStateBorderSide.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return BorderSide(color: context.colorScheme.primary, width: 2);
      }
      return null;
    });
    final focusedColor = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return context.colorScheme.primary.withValues(alpha: 0.2);
      }
      return null;
    });
    return Chip(
      avatar: avatar == null ? null : context.resolveIconWidget(avatar),
      side: focusedBorder,
      color: focusedColor,
      labelPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
      clipBehavior: Clip.antiAlias,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onDeleted: onPressed ?? () {},
      labelStyle: labelStyle,
      label: EmojiText(label),
    );
  }
}

class _ActionChip extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? avatar;
  final TextStyle? labelStyle;

  const _ActionChip({
    required this.label,
    this.labelStyle,
    this.onPressed,
    this.avatar,
  });

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
  static const _minContentHeight = 16.0;
  static const _defaultShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  bool _focused = false;
  bool _pressed = false;

  void _handleFocusChange(bool value) {
    if (value == _focused) return;
    setState(() {
      _focused = value;
    });
  }

  void _setPressed(bool value) {
    if (value == _pressed) return;
    setState(() {
      _pressed = value;
    });
  }

  void _handleTap() {
    final onPressed = widget.onPressed;
    if (onPressed == null) return;
    Feedback.forTap(context);
    onPressed();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key != LogicalKeyboardKey.enter &&
        key != LogicalKeyboardKey.numpadEnter &&
        key != LogicalKeyboardKey.space &&
        key != LogicalKeyboardKey.select &&
        key != LogicalKeyboardKey.gameButtonA) {
      return KeyEventResult.ignored;
    }
    _handleTap();
    return KeyEventResult.handled;
  }

  OutlinedBorder _resolveShape(ThemeData theme, ChipThemeData chipTheme) {
    final colorScheme = theme.colorScheme;
    final states = {if (_focused) WidgetState.focused};
    final shape =
        WidgetStateProperty.resolveAs<OutlinedBorder?>(
          chipTheme.shape,
          states,
        ) ??
        _defaultShape;
    if (_focused) {
      return shape.copyWith(
        side: BorderSide(color: colorScheme.primary, width: 2),
      );
    }
    final side = WidgetStateProperty.resolveAs<BorderSide?>(
      chipTheme.side,
      states,
    );
    if (side != null) return shape.copyWith(side: side);
    if (shape.side != BorderSide.none) return shape;
    return shape.copyWith(side: BorderSide(color: colorScheme.outlineVariant));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipTheme = ChipTheme.of(context);
    final colorScheme = theme.colorScheme;
    final shape = _resolveShape(theme, chipTheme);
    final labelStyle =
        (chipTheme.labelStyle ??
                theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                ) ??
                const TextStyle())
            .merge(widget.labelStyle);
    final density = theme.visualDensity.baseSizeAdjustment.dy / 4;
    final label = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: DefaultTextStyle(
          overflow: TextOverflow.fade,
          textAlign: TextAlign.start,
          maxLines: 1,
          softWrap: false,
          style: labelStyle,
          child: EmojiText(widget.label),
        ),
      ),
    );
    final avatar = widget.avatar;
    final Widget content = avatar == null
        ? label
        : IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: IconTheme.merge(
                      data: IconThemeData(
                        color: colorScheme.primary,
                        size: 18,
                      ).merge(chipTheme.iconTheme),
                      child: context.resolveIconWidget(avatar) ?? avatar,
                    ),
                  ),
                ),
                Flexible(child: label),
              ],
            ),
          );
    final background = _focused
        ? Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.2),
            theme.canvasColor,
          )
        : theme.canvasColor;
    final border = ShapeDecoration(shape: shape);
    return Semantics(
      button: true,
      container: true,
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Focus(
          onFocusChange: _handleFocusChange,
          onKeyEvent: _handleKeyEvent,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleTap,
              onTapDown: (_) => _setPressed(true),
              onTapUp: (_) => _setPressed(false),
              onTapCancel: () => _setPressed(false),
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: _pressed
                      ? Color.alphaBlend(
                          colorScheme.onSurface.withValues(alpha: 0.1),
                          background,
                        )
                      : background,
                  shape: shape.copyWith(side: BorderSide.none),
                ),
                child: ClipPath(
                  clipper: ShapeBorderClipper(shape: shape),
                  child: DecoratedBox(
                    decoration: border,
                    child: DecoratedBox(
                      decoration: border,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8 + density,
                        ).add(shape.dimensions),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: _minContentHeight,
                          ),
                          child: content,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
