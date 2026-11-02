import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';
import 'package:material_ui/material_ui.dart';

class SegmentOption<T> {
  final T value;
  final String label;
  final Widget? icon;
  final String? tooltip;
  final Color? color;

  const SegmentOption({
    required this.value,
    required this.label,
    this.icon,
    this.tooltip,
    this.color,
  });
}

class SegmentButton extends StatelessWidget {
  static const defaultHeight = 36.0;

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;
  final Color? color;
  final String? tooltip;
  final bool faded;
  final bool first;
  final bool last;
  final double? height;

  const SegmentButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
    this.trailing,
    this.color,
    this.tooltip,
    this.faded = false,
    this.first = true,
    this.last = true,
    this.height = defaultHeight,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final accent = color ?? colorScheme.primary;
    final foreground = selected
        ? accent
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.82);

    Widget buildButton(double currentHeight) {
      final full = Radius.circular(currentHeight / 2);
      const inner = Radius.circular(8);
      final shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: selected || first ? full : inner,
          right: selected || last ? full : inner,
        ),
      );
      return Focus(
        child: Builder(
          builder: (context) {
            final isFocused =
                globalState.isAndroidTV && Focus.of(context).hasFocus;
            final button = Opacity(
              opacity: faded && !selected ? 0.5 : 1,
              child: AnimatedContainer(
                duration: midDuration,
                curve: Curves.easeOutCubic,
                height: height,
                decoration: ShapeDecoration(
                  color: selected
                      ? accent.withValues(alpha: isLight ? 0.12 : 0.20)
                      : colorScheme.onSurface.withValues(
                          alpha: isLight ? 0.04 : 0.06,
                        ),
                  shape: shape.copyWith(
                    side: isFocused
                        ? BorderSide(color: accent, width: 2)
                        : BorderSide.none,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: shape,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: IconTheme.merge(
                        data: IconThemeData(color: foreground, size: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 6,
                          children: [
                            ?leading,
                            Flexible(
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: foreground,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            ?trailing,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            if (tooltip == null) return button;
            return Tooltip(message: tooltip, child: button);
          },
        ),
      );
    }

    if (height != null) {
      return buildButton(height!);
    }
    return LayoutBuilder(
      builder: (context, constraints) => buildButton(constraints.maxHeight),
    );
  }
}

class SegmentButtonGroup<T> extends StatelessWidget {
  final List<SegmentOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final double? height;
  final double? maxWidth;
  final bool expand;
  final AlignmentGeometry alignment;

  const SegmentButtonGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.height = 40.0,
    this.maxWidth,
    this.expand = true,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    Widget buildItem(int i, SegmentOption<T> option) {
      final item = SegmentButton(
        height: height,
        label: option.label,
        selected: option.value == selected,
        onTap: () => onSelected(option.value),
        leading: option.icon,
        color: option.color,
        tooltip: option.tooltip,
        first: i == 0,
        last: i == options.length - 1,
      );
      return expand ? Expanded(child: item) : item;
    }

    Widget content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: height == null
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.center,
      spacing: 2,
      children: [
        for (final (i, option) in options.indexed) buildItem(i, option),
      ],
    );

    if (maxWidth != null) {
      content = Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: content,
        ),
      );
    }

    return content;
  }
}
