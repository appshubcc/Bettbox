import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:flutter/material.dart';

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
    final focusedBorder = WidgetStateBorderSide.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return BorderSide(
          color: context.colorScheme.primary,
          width: 2,
        );
      }
      return null;
    });
    final focusedColor = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return context.colorScheme.primary.withValues(alpha: 0.2);
      }
      return null;
    });

    if (type == ChipType.delete) {
      return Chip(
        avatar: avatar,
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
    return ActionChip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      avatar: avatar,
      side: focusedBorder,
      color: focusedColor,
      clipBehavior: Clip.antiAlias,
      labelPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
      onPressed: onPressed ?? () {},
      labelStyle: labelStyle,
      label: EmojiText(label),
    );
  }
}
