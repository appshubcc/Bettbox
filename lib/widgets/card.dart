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

const _lightSubtleShadows = [
  BoxShadow(color: Color(0x0E000000), offset: Offset(0, 1.5), blurRadius: 3),
];

const _darkSubtleShadows = [
  BoxShadow(color: Color(0x30000000), offset: Offset(0, 1.5), blurRadius: 3.5),
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
    this.subtle = false,
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
  final bool subtle;

  // final WidgetStateProperty<Color?>? backgroundColor;
  // final WidgetStateProperty<BorderSide?>? borderSide;

  BorderSide getBorderSide(BuildContext context, Set<WidgetState> states) {
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
    if (elevated && !isSelected && !subtle) return BorderSide.none;
    final isLight = colorScheme.brightness == Brightness.light;
    final alpha = isSelected
        ? 1.0
        : (subtle
              ? (isLight ? 0.35 : 0.15)
              : (elevated ? (isLight ? 0.65 : 0.35) : (isLight ? 0.8 : 0.4)));
    return BorderSide(
      color: isSelected
          ? colorScheme.primary
          : colorScheme.outlineVariant.withValues(alpha: alpha),
      strokeAlign: BorderSide.strokeAlignInside,
    );
  }

  Color? getBackgroundColor(BuildContext context, Set<WidgetState> states) {
    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final base = isSelected
        ? (type == CommonCardType.filled
              ? colorScheme.secondaryContainer.opacity80
              : colorScheme.secondaryContainer)
        : (isLight
              ? Color.lerp(
                  colorScheme.surface,
                  colorScheme.surfaceContainerLowest,
                  0.5,
                )
              : colorScheme.surfaceContainerHigh);
    final tint = states.contains(WidgetState.pressed)
        ? 0.07
        : (states.contains(WidgetState.hovered) ? 0.03 : 0.0);
    if (base == null || tint == 0) return base;
    return Color.alphaBlend(colorScheme.primary.withValues(alpha: tint), base);
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
    Widget buildCard(WidgetStatesController? controller) {
      Widget card = OutlinedButton(
        statesController: controller,
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
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          minimumSize: WidgetStatePropertyAll(isInteractive ? null : Size.zero),
          tapTargetSize: isInteractive
              ? null
              : MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed,
        child: childWidget,
      );

      final hasShadows = elevated || subtle;
      if (hasShadows) {
        final shadows = subtle
            ? (isLight ? _lightSubtleShadows : _darkSubtleShadows)
            : (isLight ? _lightShadows : _darkShadows);
        card = DecoratedBox(
          decoration: ShapeDecoration(shape: shape, shadows: shadows),
          child: card,
        );
      }
      return card;
    }

    final card = isInteractive
        ? _CardPressScale(builder: buildCard)
        : buildCard(null);

    return switch (enterAnimated) {
      true => FadeScaleEnterBox(child: card),
      false => card,
    };
  }
}

class _CardPressScale extends StatefulWidget {
  const _CardPressScale({required this.builder});

  final Widget Function(WidgetStatesController controller) builder;

  @override
  State<_CardPressScale> createState() => _CardPressScaleState();
}

class _CardPressScaleState extends State<_CardPressScale> {
  final _controller = WidgetStatesController();
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleStates);
  }

  void _handleStates() {
    final pressed = _controller.value.contains(WidgetState.pressed);
    if (pressed == _pressed) return;
    setState(() => _pressed = pressed);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStates);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: _pressed
          ? const Duration(milliseconds: 100)
          : const Duration(milliseconds: 260),
      curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
      child: widget.builder(_controller),
    );
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
