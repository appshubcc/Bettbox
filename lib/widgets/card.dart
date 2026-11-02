import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/widgets/fade_box.dart';
import 'package:material_ui/material_ui.dart';

import 'text.dart';

class Info {
  final String label;
  final IconData? iconData;
  final TextStyle? style;

  const Info({required this.label, this.iconData, this.style});
}

class InfoHeader extends StatelessWidget {
  final Info info;
  final List<Widget> actions;
  final EdgeInsetsGeometry? padding;

  const InfoHeader({
    super.key,
    required this.info,
    this.padding,
    List<Widget>? actions,
  }) : actions = actions ?? const [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? baseInfoEdgeInsets,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (info.iconData != null) ...[
                  Icon(
                    info.iconData,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  flex: 1,
                  child: TooltipText(
                    text: EmojiText(
                      info.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (info.style ?? Theme.of(context).textTheme.titleSmall)
                              ?.copyWith(
                                color:
                                    info.style?.color ??
                                    context.colorScheme.onSurfaceVariant,
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [...actions],
          ),
        ],
      ),
    );
  }
}

const _lightShadows = [
  BoxShadow(color: Color(0x0D000000), offset: Offset(0, 0.5)),
  BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 4),
  BoxShadow(
    color: Color(0x14000000),
    offset: Offset(0, 10),
    blurRadius: 26,
    spreadRadius: -6,
  ),
];

const _darkShadows = [
  BoxShadow(color: Color(0x80000000), offset: Offset(0, 1)),
  BoxShadow(
    color: Color(0x80000000),
    offset: Offset(0, 8),
    blurRadius: 22,
    spreadRadius: -6,
  ),
];

class CommonCard extends StatelessWidget {
  const CommonCard({
    super.key,
    bool? isSelected,
    this.type = CommonCardType.plain,
    this.onPressed,
    this.onLongPress,
    this.selectWidget,
    this.radius,
    required this.child,
    this.padding,
    this.enterAnimated = false,
    this.info,
    this.clipBehavior = Clip.antiAlias,
    this.elevated = true,
  }) : isSelected = isSelected ?? false;

  final bool enterAnimated;
  final bool isSelected;
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final Widget? selectWidget;
  final Widget child;
  final EdgeInsets? padding;
  final Info? info;
  final CommonCardType type;
  final double? radius;
  final Clip clipBehavior;
  final bool elevated;

  // final WidgetStateProperty<Color?>? backgroundColor;
  // final WidgetStateProperty<BorderSide?>? borderSide;

  BorderSide getBorderSide(BuildContext context, Set<WidgetState> states) {
    if (elevated && !isSelected) return BorderSide.none;
    final colorScheme = context.colorScheme;
    final hoverColor = isSelected
        ? colorScheme.primary.opacity80
        : colorScheme.primary.opacity60;
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused) ||
        states.contains(WidgetState.pressed)) {
      return BorderSide(
        color: hoverColor,
        strokeAlign: BorderSide.strokeAlignInside,
      );
    }
    final isLight = colorScheme.brightness == Brightness.light;
    return BorderSide(
      color: isSelected
          ? colorScheme.primary
          : colorScheme.outlineVariant.withValues(
              alpha: elevated ? (isLight ? 0.65 : 0.35) : (isLight ? 0.8 : 0.4),
            ),
      strokeAlign: BorderSide.strokeAlignInside,
    );
  }

  Color? getBackgroundColor(BuildContext context, Set<WidgetState> states) {
    final colorScheme = context.colorScheme;
    if (isSelected) {
      return type == CommonCardType.filled
          ? colorScheme.secondaryContainer.opacity80
          : colorScheme.secondaryContainer;
    }
    final isLight = colorScheme.brightness == Brightness.light;
    return isLight
        ? Color.lerp(
            colorScheme.surface,
            colorScheme.surfaceContainerLowest,
            0.5,
          )
        : colorScheme.surfaceContainerHigh;
  }

  @override
  Widget build(BuildContext context) {
    final actualRadius = radius ?? 24.0;
    var childWidget = child;

    if (info != null) {
      childWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoHeader(
            padding: baseInfoEdgeInsets.copyWith(bottom: 0),
            info: info!,
          ),
          Flexible(flex: 1, child: child),
        ],
      );
    }

    if (selectWidget != null && isSelected) {
      final List<Widget> children = [];
      children.add(childWidget);
      children.add(Positioned.fill(child: selectWidget!));
      childWidget = Stack(children: children);
    }

    final isInteractive = onPressed != null || onLongPress != null;
    final isLight = context.colorScheme.brightness == Brightness.light;
    final shape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(actualRadius),
    );
    Widget card = OutlinedButton(
      onLongPress: onLongPress,
      clipBehavior: clipBehavior,
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: WidgetStatePropertyAll(shape),
        iconColor: WidgetStatePropertyAll(context.colorScheme.primary),
        iconSize: WidgetStateProperty.all(20),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => getBackgroundColor(context, states),
        ),
        side: WidgetStateProperty.resolveWith(
          (states) => getBorderSide(context, states),
        ),
        minimumSize: WidgetStatePropertyAll(isInteractive ? null : Size.zero),
        tapTargetSize: isInteractive ? null : MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: childWidget,
    );

    if (elevated) {
      card = DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape,
          shadows: isLight ? _lightShadows : _darkShadows,
        ),
        child: card,
      );
    }

    return switch (enterAnimated) {
      true => FadeScaleEnterBox(child: card),
      false => card,
    };
  }
}

class SelectIcon extends StatelessWidget {
  const SelectIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.inversePrimary,
      shape: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: const Icon(Icons.check, size: 16),
      ),
    );
  }
}

class SettingsBlock extends StatelessWidget {
  final String title;
  final List<Widget> settings;

  const SettingsBlock({super.key, required this.title, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          InfoHeader(info: Info(label: title)),
          Card(
            color: context.colorScheme.surfaceContainer,
            clipBehavior: Clip.antiAlias,
            child: Column(children: settings),
          ),
        ],
      ),
    );
  }
}
