import 'dart:math';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

String toolEffectiveProxy(List<Group> groups, String proxy) {
  if (proxy.isEmpty || proxy == 'DIRECT') return proxy;
  final exists = groups.any(
    (group) =>
        group.name == proxy || group.all.any((item) => item.name == proxy),
  );
  return exists ? proxy : '';
}

String toolOutboundNode({
  required bool isStart,
  required String proxy,
  SpeedTestOutbound? outbound,
}) {
  if (!isStart || proxy == 'DIRECT') return appLocalizations.direct;
  final chains = outbound?.chains ?? const <String>[];
  if (chains.isNotEmpty) {
    final node = chains.last;
    return node == 'DIRECT' ? appLocalizations.direct : node;
  }
  return proxy.isEmpty ? '—' : proxy;
}

String toolOutboundRoute({
  required bool isStart,
  required String proxy,
  SpeedTestOutbound? outbound,
}) {
  if (!isStart) return appLocalizations.speedTestCoreStopped;
  final chains = outbound?.chains ?? const <String>[];
  if (proxy.isNotEmpty) {
    final target = proxy == 'DIRECT' ? appLocalizations.direct : proxy;
    final isNode = chains.length == 1 && proxy != 'DIRECT';
    return isNode
        ? appLocalizations.speedTestManual
        : '${appLocalizations.speedTestManual} › $target';
  }
  final rule = outbound?.rule ?? '';
  final payload = outbound?.rulePayload ?? '';
  final head = rule.isEmpty
      ? appLocalizations.speedTestFollowRules
      : payload.isEmpty
      ? rule
      : '$rule($payload)';
  return chains.length > 1 ? '$head › ${chains.first}' : head;
}

Color toolFocusColor(BuildContext context) =>
    context.colorScheme.primary.withValues(alpha: 0.18);

WidgetStateBorderSide toolChipSide(
  BuildContext context, {
  bool selected = false,
  BorderSide? idle,
}) {
  final colorScheme = context.colorScheme;
  return WidgetStateBorderSide.resolveWith(
    (states) => states.contains(WidgetState.focused)
        ? BorderSide(
            color: selected ? colorScheme.onSurface : colorScheme.primary,
            width: 2,
          )
        : idle,
  );
}

class ToolTvField extends StatelessWidget {
  final TextEditingController controller;
  final Widget child;

  const ToolTvField({super.key, required this.controller, required this.child});

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (!globalState.isAndroidTV || event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }
    final value = controller.value;
    final text = value.text;
    final selection = value.selection;
    final offset = selection.isValid
        ? selection.extentOffset.clamp(0, text.length)
        : text.length;
    final collapsed = !selection.isValid || selection.isCollapsed;
    final direction = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowUp
          when !text.substring(0, offset).contains('\n') =>
        TraversalDirection.up,
      LogicalKeyboardKey.arrowDown
          when !text.substring(offset).contains('\n') =>
        TraversalDirection.down,
      LogicalKeyboardKey.arrowLeft when collapsed && offset == 0 =>
        TraversalDirection.left,
      LogicalKeyboardKey.arrowRight when collapsed && offset >= text.length =>
        TraversalDirection.right,
      _ => null,
    };
    if (direction == null) return KeyEventResult.ignored;
    final focused = FocusManager.instance.primaryFocus;
    if (focused == null || !focused.focusInDirection(direction)) {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKeyEvent,
      child: child,
    );
  }
}

class ToolOutboundRow {
  final IconData icon;
  final String label;
  final String value;
  final bool primary;
  final Color? color;
  final VoidCallback? onTap;

  const ToolOutboundRow({
    required this.icon,
    required this.label,
    required this.value,
    this.primary = false,
    this.color,
    this.onTap,
  });
}

class ToolOutboundCard extends StatelessWidget {
  final List<ToolOutboundRow> rows;
  final bool enabled;
  final bool showChevron;
  final bool loading;
  final VoidCallback? onTap;

  const ToolOutboundCard({
    super.key,
    required this.rows,
    this.enabled = true,
    this.showChevron = true,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final labelStyle = context.textTheme.labelMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final valueStyle = context.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface,
    );
    return ToolSurface(
      onTap: enabled ? onTap : null,
      padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
      child: Row(
        children: [
          Expanded(
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                for (final (index, row) in rows.indexed)
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: 14,
                          top: index == 0 ? 0 : 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              row.icon,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(row.label, style: labelStyle),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: index == 0 ? 0 : 6),
                        child: ToolOutboundValue(
                          text: row.value,
                          loading: loading,
                          onTap: row.onTap,
                          skeletonWidth: 80.0 + 30 * index,
                          style: valueStyle?.copyWith(
                            color: row.color,
                            fontWeight: row.primary ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (showChevron)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 6),
              child: Icon(
                Icons.unfold_more_rounded,
                size: 20,
                color: enabled
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.outlineVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class ToolSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool busy;
  final ValueChanged<String> onSubmitted;
  final Widget? trailing;

  const ToolSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
    this.busy = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return ToolSurface(
      padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: ToolTvField(
              controller: controller,
              child: TextField(
                controller: controller,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) => onSubmitted(value.trim()),
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                ),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, value, _) => value.text.isEmpty || busy
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: controller.clear,
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
          ),
          ?trailing,
          busy
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton.filledTonal(
                  onPressed: () => onSubmitted(controller.text.trim()),
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
        ],
      ),
    );
  }
}

class ToolInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  final Widget? valueWidget;
  final VoidCallback? onTap;

  const ToolInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
    this.valueWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final accent = color ?? colorScheme.primary;
    return ToolSurface(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: colorScheme.outline,
                ),
            ],
          ),
          const SizedBox(height: 10),
          valueWidget ??
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium,
              ),
        ],
      ),
    );
  }
}

class ToolInfoGrid extends StatelessWidget {
  final List<Widget> children;
  final double minTileWidth;

  const ToolInfoGrid({
    super.key,
    required this.children,
    this.minTileWidth = 160,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final columns = max(
          2,
          ((constraints.maxWidth + gap) / (minTileWidth + gap)).floor(),
        );
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class ToolNote extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const ToolNote({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? context.colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.labelMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class ToolPageBody extends StatelessWidget {
  final List<Widget> children;
  final Widget? bottom;
  final double maxWidth;

  const ToolPageBody({
    super.key,
    required this.children,
    this.bottom,
    this.maxWidth = 720,
  });

  @override
  Widget build(BuildContext context) {
    Widget constrain(Widget child) => Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              constrain(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ],
          ),
        ),
        if (bottom case final bottom?)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: constrain(SizedBox(width: double.infinity, child: bottom)),
            ),
          ),
      ],
    );
  }
}

class ToolSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const ToolSectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class ToolSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  const ToolSurface({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return CommonCard(
      onPressed: onTap,
      child: IconTheme.merge(
        data: IconThemeData(color: colorScheme.onSurfaceVariant),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: colorScheme.onSurface),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class ToolOutboundValue extends StatelessWidget {
  final String text;
  final bool loading;
  final TextStyle? style;
  final double skeletonWidth;
  final VoidCallback? onTap;

  const ToolOutboundValue({
    super.key,
    required this.text,
    required this.loading,
    required this.style,
    required this.skeletonWidth,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: loading ? 0 : 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            focusColor: toolFocusColor(context),
            onTap: loading ? null : onTap,
            child: Row(
              children: [
                Flexible(
                  child: EmojiText(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: colorScheme.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (loading)
          Container(
            width: skeletonWidth,
            height: 10,
            decoration: BoxDecoration(
              color: context.colorScheme.onSurface.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
      ],
    );
  }
}

class ToolSegmented<T> extends StatelessWidget {
  final List<T> values;
  final T value;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;
  final bool enabled;
  final bool Function(T value)? isEnabled;
  final IconData? Function(T value)? iconOf;

  const ToolSegmented({
    super.key,
    required this.values,
    required this.value,
    required this.labelOf,
    required this.onChanged,
    this.enabled = true,
    this.isEnabled,
    this.iconOf,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final index = max(values.indexOf(value), 0);
    final baseStyle = context.textTheme.labelMedium ?? const TextStyle();
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / values.length;
          return Stack(
            children: [
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                start: width * index,
                top: 0,
                bottom: 0,
                width: width,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.opacity12,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final item in values)
                    Expanded(
                      child: FocusStateBuilder(
                        builder: (context, focused) {
                          final active =
                              enabled && (isEnabled?.call(item) ?? true);
                          final color = item == value
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant.withValues(
                                  alpha: active ? 1 : 0.5,
                                );
                          final icon = iconOf?.call(item);
                          final ring = focused && globalState.isAndroidTV;
                          return DecoratedBox(
                            position: DecorationPosition.foreground,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: ring
                                  ? Border.all(
                                      color: colorScheme.primary,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              focusColor: toolFocusColor(context),
                              onTap: active ? () => onChanged(item) : null,
                              child: Center(
                                child: icon != null
                                    ? Icon(
                                        icon,
                                        size: 16,
                                        color: color,
                                        semanticLabel: labelOf(item),
                                      )
                                    : AnimatedDefaultTextStyle(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        style: baseStyle.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: color,
                                        ),
                                        child: Text(
                                          labelOf(item),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class ToolNumberSegmented extends StatelessWidget {
  static const _custom = -1;

  final List<int> presets;
  final int value;
  final String Function(int value) labelOf;
  final ValueChanged<int> onChanged;
  final String title;
  final int min;
  final int max;
  final String? unit;
  final bool enabled;

  const ToolNumberSegmented({
    super.key,
    required this.presets,
    required this.value,
    required this.labelOf,
    required this.onChanged,
    required this.title,
    required this.min,
    required this.max,
    this.unit,
    this.enabled = true,
  });

  Future<void> _input() async {
    final text = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: title,
        value: '$value',
        hintText: '$min–$max',
        suffixText: unit,
        keyboardType: TextInputType.number,
        validator: (text) {
          final next = int.tryParse(text?.trim() ?? '');
          return next == null || next < min || next > max
              ? appLocalizations.numberRangeInvalid(min, max)
              : null;
        },
      ),
    );
    final next = int.tryParse(text?.trim() ?? '');
    if (next != null && next >= min && next <= max) onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final custom = !presets.contains(value);
    return ToolSegmented<int>(
      values: [...presets, _custom],
      value: custom ? _custom : value,
      enabled: enabled,
      labelOf: (item) => item != _custom
          ? labelOf(item)
          : custom
          ? labelOf(value)
          : appLocalizations.custom,
      iconOf: (item) => item == _custom && !custom ? Icons.edit_rounded : null,
      onChanged: (item) => item == _custom ? _input() : onChanged(item),
    );
  }
}

mixin ToolHistoryMixin<T extends StatefulWidget> on State<T> {
  String get historyKey;

  List<String> history = const [];

  void loadHistory() {
    ToolHistoryStore.instance.load(historyKey).then((items) {
      if (!mounted) return;
      setState(() => history = items);
    });
  }

  void addHistory(String value) {
    if (value.isEmpty) return;
    ToolHistoryStore.instance.add(historyKey, value).then((items) {
      if (!mounted) return;
      setState(() => history = items);
    });
  }

  void clearHistory() {
    setState(() => history = const []);
    ToolHistoryStore.instance.clear(historyKey);
  }
}

class ToolHistoryBar extends StatelessWidget {
  final List<String> items;
  final ValueChanged<String> onSelected;
  final VoidCallback onClear;

  const ToolHistoryBar({
    super.key,
    required this.items,
    required this.onSelected,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: items.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 34,
                child: Row(
                  children: [
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (rect) => LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.white.withValues(alpha: 0),
                          ],
                          stops: const [0, 0.92, 1],
                        ).createShader(rect),
                        blendMode: BlendMode.dstIn,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsetsDirectional.only(end: 16),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 6),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ActionChip(
                              visualDensity: VisualDensity.compact,
                              side: toolChipSide(context),
                              avatar: Icon(
                                Icons.history_rounded,
                                size: 15,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              label: Text(
                                item,
                                style: context.textTheme.labelMedium,
                              ),
                              onPressed: () => onSelected(item),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: appLocalizations.toolHistoryClear,
                      onPressed: onClear,
                      icon: Icon(
                        Icons.delete_sweep_outlined,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class ToolLoadingSwitcher extends StatelessWidget {
  final bool loading;
  final Widget child;
  final double loadingHeight;

  const ToolLoadingSwitcher({
    super.key,
    required this.loading,
    required this.child,
    this.loadingHeight = 180,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        fit: StackFit.passthrough,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: loading
          ? SizedBox(
              key: const ValueKey('loading'),
              height: loadingHeight,
              child: const Center(
                child: SyncedLoading(
                  size: 36,
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          : KeyedSubtree(key: const ValueKey('content'), child: child),
    );
  }
}

const toolGoodColor = Color(0xFF22A06B);
const toolFairColor = Color(0xFFE59A1A);
const toolPoorColor = Color(0xFFE5602B);

Color toolGrade(double value, double good, double fair) => value <= good
    ? toolGoodColor
    : value <= fair
    ? toolFairColor
    : toolPoorColor;

class ToolRingCard extends StatelessWidget {
  final List<Widget> rings;

  const ToolRingCard({super.key, required this.rings});

  @override
  Widget build(BuildContext context) {
    return ToolSurface(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(children: [for (final ring in rings) Expanded(child: ring)]),
    );
  }
}

class ToolRing extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final double ratio;
  final Color? color;
  final double size;

  const ToolRing({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.ratio,
    this.color,
    this.size = 76,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final accent = color ?? colorScheme.outline;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RingChart(
          size: size,
          strokeWidth: 6,
          total: 1,
          trackColor: accent.withValues(alpha: 0.12),
          segments: [
            if (color != null)
              RingSegment(value: ratio.clamp(0.04, 1.0), color: accent),
          ],
          centerChild: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  if (unit.isNotEmpty)
                    Text(
                      unit,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.1,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
