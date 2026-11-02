import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/common.dart';
import 'package:material_ui/material_ui.dart';

class CommonPopupRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;
  ValueNotifier<Offset> offsetNotifier;

  CommonPopupRoute({
    required this.barrierLabel,
    required this.builder,
    required this.offsetNotifier,
  });

  @override
  String? barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: offsetNotifier,
        builder: (_, value, child) {
          return Align(
            alignment: Alignment.topRight,
            child: CustomSingleChildLayout(
              delegate: OverflowAwareLayoutDelegate(
                offset: value.translate(48, -8),
              ),
              child: child,
            ),
          );
        },
        child: _PopupTransition(
          animation: animation,
          duration: transitionDuration,
          child: child,
        ),
      ),
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);
}

class _PopupTransition extends StatefulWidget {
  final Animation<double> animation;
  final Duration duration;
  final Widget child;

  const _PopupTransition({
    required this.animation,
    required this.duration,
    required this.child,
  });

  @override
  State<_PopupTransition> createState() => _PopupTransitionState();
}

class _PopupTransitionState extends State<_PopupTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: AnimationMin(widget.animation, _enter),
    curve: Curves.easeIn,
  );
  late final Animation<double> _opacity = Tween<double>(
    begin: 0.1,
    end: 1,
  ).animate(_curve);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _enter.forward();
      }
    });
  }

  @override
  void dispose() {
    _curve.dispose();
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: AnimatedBuilder(
        animation: _curve,
        builder: (_, child) {
          final value = _curve.value;
          return Transform.scale(
            alignment: Alignment.topRight,
            scale: 0.7 + 0.3 * value,
            child: Transform.translate(
              offset: Offset(0, -10 * (1 - value)),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class PopupController extends ValueNotifier<bool> {
  PopupController() : super(false);

  void open() {
    value = true;
  }

  void close() {
    value = false;
  }
}

typedef PopupOpen = Future<void> Function({Offset offset});

class CommonPopupBox extends StatefulWidget {
  final Widget Function(PopupOpen open) targetBuilder;
  final Widget popup;

  const CommonPopupBox({
    super.key,
    required this.targetBuilder,
    required this.popup,
  });

  @override
  State<CommonPopupBox> createState() => _CommonPopupBoxState();
}

class _CommonPopupBoxState extends State<CommonPopupBox> {
  bool _isOpen = false;
  final _targetOffsetValueNotifier = ValueNotifier<Offset>(Offset.zero);
  Offset _offset = Offset.zero;
  CommonPopupRoute? _route;

  Future<void> _open({Offset offset = Offset.zero}) {
    _offset = offset;
    _updateOffset();
    _isOpen = true;
    final route = _route = CommonPopupRoute(
      barrierLabel: utils.id,
      builder: (BuildContext context) {
        return widget.popup;
      },
      offsetNotifier: _targetOffsetValueNotifier,
    );
    return Navigator.of(context).push(route).then((_) {
      _isOpen = false;
    });
  }

  @override
  void dispose() {
    final route = _route;
    if (route == null) {
      _targetOffsetValueNotifier.dispose();
    } else {
      route.completed.whenComplete(_targetOffsetValueNotifier.dispose);
    }
    super.dispose();
  }

  void _updateOffset() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }
    final viewPadding = MediaQuery.viewPaddingOf(context);
    _targetOffsetValueNotifier.value = renderBox
        .localToGlobal(
          Offset.zero.translate(viewPadding.right, viewPadding.top),
        )
        .translate(_offset.dx, _offset.dy);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isOpen && mounted) {
            _updateOffset();
          }
        });
        return widget.targetBuilder(_open);
      },
    );
  }
}

class OverflowAwareLayoutDelegate extends SingleChildLayoutDelegate {
  final Offset offset;

  OverflowAwareLayoutDelegate({required this.offset});

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final safeOffset = Offset(16, 16);
    double x = (offset.dx - childSize.width).clamp(
      0,
      size.width - safeOffset.dx - childSize.width,
    );
    double y = (offset.dy).clamp(
      0,
      size.height - safeOffset.dy - childSize.height,
    );
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(covariant OverflowAwareLayoutDelegate oldDelegate) {
    return oldDelegate.offset != offset;
  }
}

class CommonPopupMenu extends StatelessWidget {
  final List<PopupMenuItemData> items;
  final Widget? footer;
  final double minWidth;
  final double minItemVerticalPadding;
  final double fontSize;

  const CommonPopupMenu({
    super.key,
    required this.items,
    this.footer,
    this.minWidth = 148,
    this.minItemVerticalPadding = 13,
    this.fontSize = 15,
  });

  Widget _popupMenuItem(
    BuildContext context, {
    required PopupMenuItemData item,
    required int index,
  }) {
    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final onPressed = item.onPressed;
    final disabled = onPressed == null;
    final color = disabled
        ? colorScheme.onSurface.opacity30
        : colorScheme.onSurface;
    final iconColor = disabled
        ? colorScheme.onSurface.opacity30
        : item.icon == Icons.check_circle_rounded
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    return InkWell(
      customBorder: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      hoverColor: colorScheme.primary.withValues(alpha: isLight ? 0.08 : 0.12),
      highlightColor: colorScheme.primary.withValues(
        alpha: isLight ? 0.10 : 0.16,
      ),
      splashColor: colorScheme.primary.withValues(alpha: isLight ? 0.08 : 0.12),
      onTap: onPressed != null
          ? () {
              final route = ModalRoute.of(context);
              Navigator.of(context).pop();
              if (route == null) {
                onPressed();
                return;
              }
              route.completed.then((_) => onPressed());
            }
          : null,
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth),
        padding: EdgeInsets.only(
          left: 14,
          right: 22,
          top: minItemVerticalPadding,
          bottom: minItemVerticalPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: fontSize + 5, color: iconColor),
              const SizedBox(width: 14),
            ],
            Flexible(
              child: Text(
                item.label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    return IntrinsicHeight(
      child: IntrinsicWidth(
        child: Material(
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: isLight ? 0.5 : 0.8),
          color: isLight
              ? colorScheme.surfaceContainerLowest
              : colorScheme.surfaceContainerHighest,
          clipBehavior: Clip.antiAlias,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(26),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(
                alpha: isLight ? 0.45 : 0.25,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in items.asMap().entries) ...[
                  _popupMenuItem(context, item: item.value, index: item.key),
                  if (item.value != items.last) const SizedBox(height: 2),
                ],
                if (footer case final footer?) ...[
                  const Divider(height: 9, indent: 8, endIndent: 8),
                  footer,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
