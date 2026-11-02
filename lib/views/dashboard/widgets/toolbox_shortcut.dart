import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/views/toolbox.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'tile.dart';

class ToolboxShortcut extends ConsumerWidget {
  final DashboardTileSize? size;

  const ToolboxShortcut({super.key, this.size});

  void _openToolbox(BuildContext context) {
    showExtend(
      context,
      props: const ExtendProps(forceFull: true),
      builder: (_, _) => const ToolboxView(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = this.size ?? DashboardTileSize.small;
    final saved = ref.watch(
      appSettingProvider.select((state) => state.toolboxTiles),
    );
    final items = orderedToolboxEntries(saved);
    final child = switch (size) {
      DashboardTileSize.tall => Padding(
        padding: const EdgeInsets.fromLTRB(9, 8, 9, 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final item in items.take(3))
              _ToolEntry(item: item, showLabel: true),
          ],
        ),
      ),
      _ => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final item in items.take(size.cross * 3))
                _ToolEntry(item: item),
            ],
          ),
        ),
      ),
    };
    return DashboardTileCard(
      size: size,
      info: Info(
        iconData: Icons.handyman_outlined,
        label: appLocalizations.toolbox,
      ),
      mark: size == DashboardTileSize.small
          ? null
          : DashboardDecor.icon(context, Icons.handyman_rounded, 80),
      markAngle: -0.32,
      onPressed: () => _openToolbox(context),
      child: child,
    );
  }
}

class _ToolEntry extends StatefulWidget {
  final ToolboxEntry item;
  final bool showLabel;

  const _ToolEntry({required this.item, this.showLabel = false});

  @override
  State<_ToolEntry> createState() => _ToolEntryState();
}

class _ToolEntryState extends State<_ToolEntry> {
  static const _duration = Duration(milliseconds: 180);

  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final item = widget.item;
    final active = _hovered || _pressed || _focused;
    final icon = TweenAnimationBuilder<Color?>(
      duration: _duration,
      tween: ColorTween(
        end: active ? item.color : colorScheme.onSurfaceVariant,
      ),
      builder: (_, color, _) => Icon(item.icon, size: 20, color: color),
    );
    final child = AnimatedContainer(
      duration: _duration,
      curve: Curves.easeOut,
      height: widget.showLabel ? 34 : 32,
      width: widget.showLabel ? null : 44,
      padding: widget.showLabel
          ? const EdgeInsets.symmetric(horizontal: 7)
          : EdgeInsets.zero,
      decoration: ShapeDecoration(
        color: item.color.withValues(alpha: active ? 0.14 : 0),
        shape: const StadiumBorder(),
      ),
      child: widget.showLabel
          ? Row(
              children: [
                icon,
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: active
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            )
          : icon,
    );
    final entry = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: InkWell(
          customBorder: const StadiumBorder(),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onTap: () => item.open(context),
          onFocusChange: (value) => setState(() => _focused = value),
          child: child,
        ),
      ),
    );
    if (widget.showLabel) return entry;
    return Tooltip(message: item.title, child: entry);
  }
}
