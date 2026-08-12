import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/open_container.dart';
import 'package:flutter/material.dart';

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

  final String? resetValue;

  const InputDelegate({
    required this.title,
    required this.value,
    this.suffixText,
    this.hintText,
    required this.onChanged,
    this.resetValue,
    this.validator,
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
    this.tileTitleAlignment = ListTileTitleAlignment.center,
  }) : leading = null,
       onTap = null;

  Widget _buildListTile({
    void Function()? onTap,
    Widget? trailing,
    Widget? leading,
    bool enabled = true,
  }) {
    return ListTile(
      key: key,
      dense: dense,
      enabled: enabled,
      titleTextStyle: titleTextStyle,
      subtitleTextStyle: subtitleTextStyle,
      leading: leading ?? this.leading,
      horizontalTitleGap: horizontalTitleGap,
      title: title,
      minVerticalPadding: 12,
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

          return _buildListTile(onTap: openAction);
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
            Switch(
              value: switchDelegate.value,
              onChanged: switchDelegate.onChanged,
            ),
          ],
        ),
      );
    }
    if (delegate is RadioDelegate) {
      final radioDelegate = delegate as RadioDelegate<T>;
      final isSelected = radioDelegate.value == radioDelegate.groupValue;
      return _buildListTile(
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

    return _buildListTile(onTap: onTap);
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
                            ? 0.3
                            : 0.2,
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
    final dividerColor = context.colorScheme.outlineVariant.withValues(
      alpha: context.colorScheme.brightness == Brightness.light ? 0.3 : 0.2,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasTightHeight = constraints.hasTightHeight;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasTightHeight)
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: child,
                  ),
                )
              else
                child,
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: isLast ? Colors.transparent : dividerColor,
              ),
            ],
          );
        },
      ),
    );
  }
}

List<Widget> generateSection({
  String? title,
  required Iterable<Widget> items,
  List<Widget>? actions,
  bool separated = true,
  bool plain = false,
}) {
  return [
    SectionContainer(
      title: title,
      items: items.toList(),
      actions: actions,
      separated: separated,
      plain: plain,
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
  return Builder(
    builder: (context) {
      final bottomPadding = MediaQuery.of(context).padding.bottom;

      final cleanItems = items.where((widget) => widget is! Divider).toList();
      if (cleanItems.isEmpty) return const SizedBox.shrink();

      return ListView.builder(
        padding: EdgeInsets.only(bottom: 24 + bottomPadding, top: 12),
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
