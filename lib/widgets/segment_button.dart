import 'package:bett_box/common/common.dart';
import 'package:material_ui/material_ui.dart';

class SegmentButton extends StatelessWidget {
  static const height = 36.0;

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
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final accent = color ?? colorScheme.primary;
    final foreground = selected
        ? accent
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.82);
    const full = Radius.circular(height / 2);
    const inner = Radius.circular(8);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(
        left: selected || first ? full : inner,
        right: selected || last ? full : inner,
      ),
    );
    final button = Opacity(
      opacity: faded && !selected ? 0.5 : 1,
      child: AnimatedContainer(
        duration: midDuration,
        curve: Curves.easeOutCubic,
        height: height,
        decoration: ShapeDecoration(
          color: selected
              ? accent.withValues(alpha: isLight ? 0.12 : 0.20)
              : colorScheme.onSurface.withValues(alpha: isLight ? 0.04 : 0.06),
          shape: shape,
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
  }
}
