import 'dart:math' as math;

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/open_container.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

import 'card.dart';
import 'input.dart';
import 'scaffold.dart';
import 'sheet.dart';

class Delegate {
  const Delegate();
}

class RadioDelegate<T> extends Delegate {
  final T value;
  final T groupValue;
  final void Function(T?)? onChanged;

  const RadioDelegate({
    required this.value,
    required this.groupValue,
    this.onChanged,
  });
}

class SwitchDelegate<T> extends Delegate {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SwitchDelegate({required this.value, this.onChanged});
}

class CheckboxDelegate<T> extends Delegate {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const CheckboxDelegate({this.value = false, this.onChanged});
}

class OpenDelegate extends Delegate {
  final Widget? widget;
  final WidgetBuilder? builder;
  final String title;
  final double? maxWidth;
  final List<Widget> actions;
  final bool blur;
  final bool wrap;
  final bool forceFull;

  const OpenDelegate({
    required this.title,
    this.widget,
    this.builder,
    this.maxWidth,
    this.actions = const [],
    this.blur = false,
    this.wrap = true,
    this.forceFull = true,
  }) : assert(widget != null || builder != null);
}

class NextDelegate extends Delegate {
  final Widget? widget;
  final WidgetBuilder? builder;
  final String title;
  final double? maxWidth;
  final List<Widget> actions;
  final bool blur;
  final bool wrap;
  final bool forceFull;

  const NextDelegate({
    required this.title,
    this.widget,
    this.builder,
    this.maxWidth,
    this.actions = const [],
    this.blur = false,
    this.wrap = true,
    this.forceFull = true,
  }) : assert(widget != null || builder != null);
}

class OptionsDelegate<T> extends Delegate {
  final List<T> options;
  final String title;
  final T value;
  final String Function(T value) textBuilder;
  final Function(T? value) onChanged;

  const OptionsDelegate({
    required this.title,
    required this.options,
    required this.textBuilder,
    required this.value,
    required this.onChanged,
  });
}

class InputDelegate extends Delegate {
  final String title;
  final String value;
  final String? suffixText;
  final String? hintText;
  final Function(String? value)? onChanged;
  final FormFieldValidator<String>? validator;
  final bool obscureText;

  final String? resetValue;

  const InputDelegate({
    required this.title,
    required this.value,
    this.suffixText,
    this.hintText,
    required this.onChanged,
    this.resetValue,
    this.validator,
    this.obscureText = false,
  });
}

class ListItem<T> extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final EdgeInsets padding;
  final ListTileTitleAlignment tileTitleAlignment;
  final bool? dense;
  final Widget? trailing;
  final Delegate delegate;
  final double? horizontalTitleGap;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final ShapeBorder? shape;
  final void Function()? onTap;

  const ListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    this.horizontalTitleGap,
    this.dense,
    this.onTap,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.shape,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : delegate = const Delegate();

  const ListItem.open({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    required OpenDelegate this.delegate,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.shape,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : onTap = null;

  const ListItem.next({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    required NextDelegate this.delegate,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.shape,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : onTap = null;

  const ListItem.options({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    required OptionsDelegate<T> this.delegate,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.shape,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : onTap = null;

  const ListItem.input({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.trailing,
    required InputDelegate this.delegate,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.shape,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : onTap = null;

  const ListItem.checkbox({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsets.only(left: 16, right: 8),
    required CheckboxDelegate<T> this.delegate,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.shape,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : trailing = null,
       onTap = null;

  const ListItem.switchItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.only(left: 16, right: 8),
    required SwitchDelegate<T> this.delegate,
    this.horizontalTitleGap,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.shape,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : onTap = null;

  const ListItem.radio({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.only(left: 12, right: 16),
    required RadioDelegate<T> this.delegate,
    this.horizontalTitleGap = 8,
    this.dense,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.shape,
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : leading = null,
       onTap = null;

  Widget _buildListTile(
    BuildContext context, {
    void Function()? onTap,
    Widget? trailing,
    Widget? leading,
    bool enabled = true,
  }) {
    return ListTile(
      key: key,
      dense: dense,
      enabled: enabled,
      focusColor: context.colorScheme.primary.withValues(alpha: 0.18),
      shape: shape,
      titleTextStyle:
          titleTextStyle ??
          context.textTheme.bodyLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
      subtitleTextStyle:
          subtitleTextStyle ??
          context.textTheme.bodyMedium?.copyWith(
            fontSize: 12.5,
            color: context.colorScheme.onSurfaceVariant.opacity80,
          ),
      leading: leading ?? this.leading,
      horizontalTitleGap: horizontalTitleGap ?? 12,
      title: title,
      minVerticalPadding: 10,
      minTileHeight: 52,
      subtitle: subtitle,
      titleAlignment: tileTitleAlignment,
      onTap: onTap,
      trailing: trailing ?? this.trailing,
      contentPadding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (delegate is OpenDelegate) {
      final openDelegate = delegate as OpenDelegate;
      Widget buildChild(BuildContext context) {
        return openDelegate.builder?.call(context) ?? openDelegate.widget!;
      }

      return OpenContainer(
        closedBuilder: (_, action) {
          openAction() {
            final isMobile = globalState.appState.viewMode == ViewMode.mobile;
            if (!isMobile || system.isDesktop) {
              showExtend(
                context,
                props: ExtendProps(
                  blur: openDelegate.blur,
                  maxWidth: openDelegate.maxWidth,
                  forceFull: openDelegate.forceFull,
                ),
                builder: (_, type) {
                  final child = buildChild(context);
                  return openDelegate.wrap
                      ? AdaptiveSheetScaffold(
                          actions: openDelegate.actions,
                          type: type,
                          body: child,
                          title: openDelegate.title,
                        )
                      : child;
                },
              );
              return;
            }
            action();
          }

          return _buildListTile(context, onTap: openAction);
        },
        openBuilder: (context, action) {
          final child = buildChild(context);
          return openDelegate.wrap
              ? CommonScaffold(
                  key: Key(openDelegate.title),
                  title: openDelegate.title,
                  body: child,
                  actions: openDelegate.actions,
                )
              : child;
        },
      );
    }
    if (delegate is NextDelegate) {
      final nextDelegate = delegate as NextDelegate;
      Widget buildChild(BuildContext context) {
        return nextDelegate.builder?.call(context) ?? nextDelegate.widget!;
      }

      return _buildListTile(
        context,
        onTap: () {
          showExtend(
            context,
            props: ExtendProps(
              blur: nextDelegate.blur,
              maxWidth: nextDelegate.maxWidth,
              forceFull: nextDelegate.forceFull,
            ),
            builder: (_, type) {
              final child = buildChild(context);
              return nextDelegate.wrap
                  ? AdaptiveSheetScaffold(
                      actions: nextDelegate.actions,
                      type: type,
                      body: child,
                      title: nextDelegate.title,
                    )
                  : child;
            },
          );
        },
      );
    }
    if (delegate is OptionsDelegate) {
      final optionsDelegate = delegate as OptionsDelegate<T>;
      return _buildListTile(
        context,
        onTap: () async {
          final value = await globalState.showCommonDialog<T>(
            child: OptionsDialog<T>(
              title: optionsDelegate.title,
              options: optionsDelegate.options,
              textBuilder: optionsDelegate.textBuilder,
              value: optionsDelegate.value,
            ),
          );
          optionsDelegate.onChanged(value);
        },
      );
    }
    if (delegate is InputDelegate) {
      final inputDelegate = delegate as InputDelegate;
      final isEnabled = inputDelegate.onChanged != null;
      return _buildListTile(
        context,
        enabled: isEnabled,
        onTap: isEnabled
            ? () async {
                final value = await globalState.showCommonDialog<String>(
                  child: InputDialog(
                    title: inputDelegate.title,
                    value: inputDelegate.value,
                    suffixText: inputDelegate.suffixText,
                    hintText: inputDelegate.hintText,
                    resetValue: inputDelegate.resetValue,
                    validator: inputDelegate.validator,
                    obscureText: inputDelegate.obscureText,
                  ),
                );
                inputDelegate.onChanged!(value);
              }
            : null,
      );
    }
    if (delegate is CheckboxDelegate) {
      final checkboxDelegate = delegate as CheckboxDelegate;
      return _buildListTile(
        context,
        onTap: () {
          if (checkboxDelegate.onChanged != null) {
            checkboxDelegate.onChanged!(!checkboxDelegate.value);
          }
        },
        trailing: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(
            checkboxDelegate.value
                ? Icons.check_circle_rounded
                : Icons.circle_outlined,
            size: 24,
            color: checkboxDelegate.value
                ? context.colorScheme.primary
                : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      );
    }
    if (delegate is SwitchDelegate) {
      final switchDelegate = delegate as SwitchDelegate;
      final isEnabled = switchDelegate.onChanged != null;
      return _buildListTile(
        context,
        enabled: isEnabled,
        onTap: isEnabled
            ? () {
                switchDelegate.onChanged!(!switchDelegate.value);
              }
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ?trailing,
            Transform.scale(
              scale: 0.86,
              alignment: Alignment.centerRight,
              child: Switch(
                value: switchDelegate.value,
                onChanged: switchDelegate.onChanged,
              ),
            ),
          ],
        ),
      );
    }
    if (delegate is RadioDelegate) {
      final radioDelegate = delegate as RadioDelegate<T>;
      final isSelected = radioDelegate.value == radioDelegate.groupValue;
      return _buildListTile(
        context,
        onTap: () {
          if (radioDelegate.onChanged != null) {
            radioDelegate.onChanged!(radioDelegate.value);
          }
        },
        leading: Icon(
          isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 21,
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        trailing: trailing,
      );
    }

    return _buildListTile(context, onTap: onTap);
  }
}

class ListHeader extends StatelessWidget {
  final String title;
  final String? subTitle;
  final List<Widget> actions;
  final EdgeInsets? padding;
  final double? space;

  const ListHeader({
    super.key,
    required this.title,
    this.subTitle,
    this.padding,
    List<Widget>? actions,
    this.space,
  }) : actions = actions ?? const [];

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding:
          padding ??
          const EdgeInsets.only(left: 16, right: 8, top: 24, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.opacity80,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subTitle != null)
                  Text(
                    subTitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [...genActions(actions, space: space)],
          ),
        ],
      ),
    );
  }
}

class SectionContainer extends StatelessWidget {
  final String? title;
  final List<Widget> items;
  final List<Widget>? actions;
  final bool separated;
  final bool plain;
  final bool isFirst;

  const SectionContainer({
    super.key,
    this.title,
    required this.items,
    this.actions,
    this.separated = true,
    this.plain = false,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final headerPadding = isFirst
        ? const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 8)
        : null;

    if (plain) {
      final genItems = separated
          ? items.separated(const Divider(height: 0))
          : items;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (items.isNotEmpty && title != null)
            ListHeader(title: title!, actions: actions, padding: headerPadding),
          ...genItems,
        ],
      );
    }

    final cleanItems = items.where((widget) => widget is! Divider).toList();
    if (cleanItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          ListHeader(title: title!, actions: actions, padding: headerPadding),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: CommonCard(
            type: CommonCardType.filled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < cleanItems.length; i++) ...[
                  cleanItems[i],
                  if (i != cleanItems.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: context.colorScheme.outlineVariant.withValues(
                        alpha:
                            context.colorScheme.brightness == Brightness.light
                            ? 0.45
                            : 0.25,
                      ),
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ContinuousListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final int count;
  final bool reversed;

  const ContinuousListItem({
    super.key,
    required this.child,
    required this.index,
    required this.count,
    this.reversed = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = reversed ? index == count - 1 : index == 0;
    final isLast = reversed ? index == 0 : index == count - 1;
    final isLight = context.colorScheme.brightness == Brightness.light;
    final dividerColor = context.colorScheme.outlineVariant.withValues(
      alpha: isLight ? 0.45 : 0.25,
    );

    return _ContinuousItemFrame(
      color: isLight
          ? Color.lerp(
              context.colorScheme.surface,
              context.colorScheme.surfaceContainerLowest,
              0.5,
            )!
          : context.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      dividerColor: isLast ? null : dividerColor,
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

class _ContinuousItemFrame extends SingleChildRenderObjectWidget {
  final Color color;
  final BorderRadius borderRadius;
  final Color? dividerColor;

  const _ContinuousItemFrame({
    required this.color,
    required this.borderRadius,
    required this.dividerColor,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderContinuousItemFrame(color, borderRadius, dividerColor);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderContinuousItemFrame renderObject,
  ) {
    renderObject
      ..color = color
      ..borderRadius = borderRadius
      ..dividerColor = dividerColor;
  }
}

class _RenderContinuousItemFrame extends RenderShiftedBox {
  static const _inset = 16.0;
  static const _dividerHeight = 1.0;

  Color _color;
  BorderRadius _borderRadius;
  Color? _dividerColor;

  _RenderContinuousItemFrame(
    this._color,
    this._borderRadius,
    this._dividerColor,
  ) : super(null);

  set color(Color value) {
    if (value == _color) return;
    _color = value;
    markNeedsPaint();
  }

  set borderRadius(BorderRadius value) {
    if (value == _borderRadius) return;
    _borderRadius = value;
    markNeedsPaint();
  }

  set dividerColor(Color? value) {
    if (value == _dividerColor) return;
    _dividerColor = value;
    markNeedsPaint();
  }

  ({Size size, Size child, Offset offset}) _computeLayout(
    BoxConstraints constraints,
    ChildLayouter layoutChild,
  ) {
    final inner = constraints.deflate(
      const EdgeInsets.symmetric(horizontal: _inset),
    );
    final tight = inner.hasTightHeight;
    final child = this.child;
    final childSize = child == null
        ? Size.zero
        : layoutChild(
            child,
            tight
                ? BoxConstraints(
                    maxWidth: inner.maxWidth,
                    maxHeight: math.max(0, inner.maxHeight - _dividerHeight),
                  )
                : BoxConstraints(maxWidth: inner.maxWidth),
          );
    final width = inner.constrainWidth(
      inner.hasBoundedWidth ? inner.maxWidth : childSize.width,
    );
    final height = tight
        ? inner.maxHeight
        : inner.constrainHeight(childSize.height + _dividerHeight);
    return (
      size: constraints.constrain(Size(width + _inset * 2, height)),
      child: childSize,
      offset: Offset(
        _inset + (width - childSize.width) / 2,
        tight ? (height - _dividerHeight - childSize.height) / 2 : 0,
      ),
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return super.computeMinIntrinsicWidth(height) + _inset * 2;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return super.computeMaxIntrinsicWidth(height) + _inset * 2;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return super.computeMinIntrinsicHeight(math.max(0, width - _inset * 2)) +
        _dividerHeight;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return super.computeMaxIntrinsicHeight(math.max(0, width - _inset * 2)) +
        _dividerHeight;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeLayout(constraints, ChildLayoutHelper.dryLayoutChild).size;
  }

  @override
  void performLayout() {
    final layout = _computeLayout(constraints, ChildLayoutHelper.layoutChild);
    size = layout.size;
    final child = this.child;
    if (child == null) return;
    (child.parentData! as BoxParentData).offset = layout.offset;
  }

  Rect get _frame => Rect.fromLTRB(_inset, 0, size.width - _inset, size.height);

  void _paintContent(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final dividerColor = _dividerColor;
    if (dividerColor == null) return;
    final frame = _frame;
    context.canvas.drawRect(
      Rect.fromLTRB(
        frame.left + _inset,
        frame.bottom - _dividerHeight,
        frame.right - _inset,
        frame.bottom,
      ).shift(offset),
      Paint()..color = dividerColor,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final frame = _frame;
    final paint = Paint()..color = _color;
    if (_borderRadius == BorderRadius.zero) {
      context.canvas.drawRect(frame.shift(offset), paint);
      layer = null;
      _paintContent(context, offset);
      return;
    }
    final rrect = _borderRadius.toRRect(frame);
    context.canvas.drawRRect(rrect.shift(offset), paint);
    layer = context.pushClipPath(
      needsCompositing,
      offset,
      frame,
      Path()..addRRect(rrect),
      _paintContent,
      oldLayer: layer as ClipPathLayer?,
    );
  }
}

List<Widget> generateSection({
  String? title,
  required Iterable<Widget> items,
  List<Widget>? actions,
  bool separated = true,
  bool plain = false,
  bool isFirst = false,
}) {
  return [
    SectionContainer(
      title: title,
      items: items.toList(),
      actions: actions,
      separated: separated,
      plain: plain,
      isFirst: isFirst,
    ),
  ];
}

Widget generateSectionV2({
  String? title,
  required Iterable<Widget> items,
  List<Widget>? actions,
  bool separated = true,
}) {
  return Column(
    children: [
      if (items.isNotEmpty && title != null)
        ListHeader(title: title, actions: actions),
      CommonCard(
        radius: 18,
        type: CommonCardType.filled,
        child: Column(children: [...items]),
      ),
    ],
  );
}

List<Widget> generateInfoSection({
  required Info info,
  required Iterable<Widget> items,
  List<Widget>? actions,
  bool separated = true,
}) {
  final genItems = separated
      ? items.separated(const Divider(height: 0))
      : items;
  return [
    if (items.isNotEmpty) InfoHeader(info: info, actions: actions),
    ...genItems,
  ];
}

Widget generateListView(List<Widget> items) {
  return ScrollEdgeRise(
    builder: (context, rise) {
      final bottomPadding = MediaQuery.paddingOf(context).bottom;

      final cleanItems = items.where((widget) => widget is! Divider).toList();
      if (cleanItems.isEmpty) return const SizedBox.shrink();

      return ListView.builder(
        padding: EdgeInsets.only(bottom: 24 + bottomPadding, top: 8 + rise),
        itemCount: cleanItems.length,
        itemBuilder: (context, index) {
          final item = cleanItems[index];

          if (item is SectionContainer) {
            if (index == 0 && !item.isFirst) {
              return SectionContainer(
                title: item.title,
                items: item.items,
                actions: item.actions,
                separated: item.separated,
                plain: item.plain,
                isFirst: true,
              );
            }
            return item;
          }

          if (item is ListHeader) {
            if (index == 0 && item.padding == null) {
              return ListHeader(
                title: item.title,
                subTitle: item.subTitle,
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 8,
                  top: 4,
                  bottom: 8,
                ),
                actions: item.actions,
                space: item.space,
              );
            }
            return item;
          }

          if (item is InfoHeader) {
            return item;
          }

          if (item is SizedBox) {
            return item;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CommonCard(type: CommonCardType.filled, child: item),
          );
        },
      );
    },
  );
}
