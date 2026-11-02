import 'dart:math' as math;

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/common.dart';
import 'package:material_ui/material_ui.dart';

import 'text.dart';

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
  final ValueGetter<Alignment>? resolveAlignment;

  const _PopupTransition({
    required this.animation,
    required this.duration,
    required this.child,
    this.resolveAlignment,
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
            alignment: widget.resolveAlignment?.call() ?? Alignment.topRight,
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

Future<void> showContextMenu(
  BuildContext context, {
  Offset? position,
  Rect? anchor,
  required List<PopupMenuItemData> items,
  Widget? header,
  double maxWidth = 300,
}) {
  final rect = anchor ?? (position ?? Offset.zero) & Size.zero;
  return Navigator.of(context, rootNavigator: true).push(
    _ContextMenuRoute(
      barrierLabel: utils.id,
      anchor: rect,
      items: items,
      header: header,
      maxWidth: maxWidth,
    ),
  );
}

class _ContextMenuRoute<T> extends PopupRoute<T> {
  final Rect anchor;
  final List<PopupMenuItemData> items;
  final Widget? header;
  final double maxWidth;

  _ContextMenuRoute({
    required this.barrierLabel,
    required this.anchor,
    required this.items,
    required this.header,
    required this.maxWidth,
  });

  @override
  String? barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _CascadeMenu(
      animation: animation,
      duration: transitionDuration,
      anchor: anchor,
      items: items,
      header: header,
      maxWidth: maxWidth,
    );
  }
}

class _CascadeMenu extends StatefulWidget {
  final Animation<double> animation;
  final Duration duration;
  final Rect anchor;
  final List<PopupMenuItemData> items;
  final Widget? header;
  final double maxWidth;

  const _CascadeMenu({
    required this.animation,
    required this.duration,
    required this.anchor,
    required this.items,
    required this.header,
    required this.maxWidth,
  });

  @override
  State<_CascadeMenu> createState() => _CascadeMenuState();
}

class _CascadeMenuState extends State<_CascadeMenu> {
  final _placement = _MenuPlacement();
  PopupMenuItemData? _submenu;
  Rect? _submenuAnchor;

  void _handleSubmenu(PopupMenuItemData? item, Rect? anchor) {
    if (identical(item, _submenu)) return;
    setState(() {
      _submenu = item;
      _submenuAnchor = item == null ? null : anchor;
    });
  }

  Widget _buildBackHeader(PopupMenuItemData item) {
    final colorScheme = context.colorScheme;
    return InkWell(
      customBorder: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onTap: () => _handleSubmenu(null, null),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 22, 10),
        child: Row(
          children: [
            Icon(
              Icons.chevron_left_rounded,
              size: 24,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: EmojiText(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
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
    final submenu = _submenu;
    final children = submenu?.children;
    final padding = MediaQuery.paddingOf(context);
    final drillDown = MediaQuery.sizeOf(context).width < 600;
    final Widget menu = drillDown && submenu != null && children != null
        ? CommonPopupMenu(
            key: ObjectKey(submenu),
            items: children,
            header: _buildBackHeader(submenu),
            scrollable: true,
            bare: true,
          )
        : CommonPopupMenu(
            key: const ValueKey('main'),
            items: widget.items,
            header: widget.header,
            scrollable: true,
            bare: true,
            activeSubmenu: drillDown ? null : submenu,
            hoverSubmenu: !drillDown,
            onSubmenu: _handleSubmenu,
          );
    final submenuAnchor = _submenuAnchor;
    return Stack(
      children: [
        Positioned.fill(
          child: CustomSingleChildLayout(
            delegate: _ContextMenuLayoutDelegate(
              anchor: widget.anchor,
              padding: padding,
              maxWidth: widget.maxWidth,
              placement: _placement,
            ),
            child: _PopupTransition(
              animation: widget.animation,
              duration: widget.duration,
              resolveAlignment: () => _placement.alignment,
              child: CommonPopupMenu.surface(
                context,
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  alignment: _placement.alignment,
                  clipBehavior: Clip.none,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 120),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.topLeft,
                      children: [...previous, ?current],
                    ),
                    child: menu,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!drillDown && children != null && submenuAnchor != null)
          Positioned.fill(
            child: CustomSingleChildLayout(
              delegate: _SubmenuLayoutDelegate(
                submenuAnchor,
                padding: padding,
                maxWidth: widget.maxWidth,
              ),
              child: TweenAnimationBuilder<double>(
                key: ObjectKey(submenu),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                builder: (_, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(-6 * (1 - value), 0),
                    child: child,
                  ),
                ),
                child: CommonPopupMenu(
                  items: children,
                  scrollable: true,
                  minItemVerticalPadding: 10,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MenuPlacement {
  Alignment alignment = Alignment.topLeft;
}

const _menuMargin = 8.0;
const _menuMinHeight = 160.0;

class _ContextMenuLayoutDelegate extends SingleChildLayoutDelegate {
  final Rect anchor;
  final EdgeInsets padding;
  final double maxWidth;
  final _MenuPlacement placement;

  _ContextMenuLayoutDelegate({
    required this.anchor,
    required this.padding,
    required this.maxWidth,
    required this.placement,
  });

  double get _gap => anchor.isEmpty ? 2 : 6;

  Rect _area(Size size) => padding
      .add(const EdgeInsets.all(_menuMargin))
      .resolve(TextDirection.ltr)
      .deflateRect(Offset.zero & size);

  double _below(Rect area) => area.bottom - anchor.bottom - _gap;

  double _above(Rect area) => anchor.top - _gap - area.top;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final area = _area(constraints.biggest);
    final space = math.max(_below(area), _above(area));
    return BoxConstraints(
      maxWidth: math.max(0, math.min(area.width, maxWidth)),
      maxHeight: math.max(
        0,
        space < _menuMinHeight ? area.height : math.min(space, area.height),
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final area = _area(size);
    final below = _below(area);
    final above = _above(area);
    final atBottom =
        childSize.height > below &&
        (childSize.height <= above || above > below);
    final atRight = anchor.left + childSize.width > area.right;
    final x = atRight ? anchor.right - childSize.width : anchor.left;
    final y = atBottom
        ? anchor.top - _gap - childSize.height
        : anchor.bottom + _gap;
    placement.alignment = switch ((atBottom, atRight)) {
      (false, false) => Alignment.topLeft,
      (false, true) => Alignment.topRight,
      (true, false) => Alignment.bottomLeft,
      (true, true) => Alignment.bottomRight,
    };
    return Offset(
      x.clamp(area.left, math.max(area.left, area.right - childSize.width)),
      y.clamp(area.top, math.max(area.top, area.bottom - childSize.height)),
    );
  }

  @override
  bool shouldRelayout(_ContextMenuLayoutDelegate oldDelegate) {
    return oldDelegate.anchor != anchor ||
        oldDelegate.padding != padding ||
        oldDelegate.maxWidth != maxWidth;
  }
}

class _SubmenuLayoutDelegate extends SingleChildLayoutDelegate {
  final Rect anchor;
  final EdgeInsets padding;
  final double maxWidth;

  _SubmenuLayoutDelegate(
    this.anchor, {
    required this.padding,
    required this.maxWidth,
  });

  Rect _area(Size size) => padding
      .add(const EdgeInsets.all(_menuMargin))
      .resolve(TextDirection.ltr)
      .deflateRect(Offset.zero & size);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final area = _area(constraints.biggest);
    return BoxConstraints(
      maxWidth: math.max(0, math.min(area.width, maxWidth)),
      maxHeight: math.max(0, area.height),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final area = _area(size);
    final right = anchor.right + 8;
    final left = anchor.left - childSize.width - 8;
    final x = right + childSize.width <= area.right || left < area.left
        ? right
        : left;
    return Offset(
      x.clamp(area.left, math.max(area.left, area.right - childSize.width)),
      (anchor.top - 6).clamp(
        area.top,
        math.max(area.top, area.bottom - childSize.height),
      ),
    );
  }

  @override
  bool shouldRelayout(_SubmenuLayoutDelegate oldDelegate) {
    return oldDelegate.anchor != anchor ||
        oldDelegate.padding != padding ||
        oldDelegate.maxWidth != maxWidth;
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
  final Widget? header;
  final Widget? footer;
  final double minWidth;
  final double minItemVerticalPadding;
  final double fontSize;
  final bool scrollable;
  final PopupMenuItemData? activeSubmenu;
  final void Function(PopupMenuItemData? item, Rect? anchor)? onSubmenu;
  final bool hoverSubmenu;
  final bool bare;

  const CommonPopupMenu({
    super.key,
    required this.items,
    this.header,
    this.footer,
    this.minWidth = 148,
    this.minItemVerticalPadding = 13,
    this.fontSize = 15,
    this.scrollable = false,
    this.activeSubmenu,
    this.onSubmenu,
    this.hoverSubmenu = true,
    this.bare = false,
  });

  void _select(BuildContext context, VoidCallback onPressed) {
    final route = ModalRoute.of(context);
    Navigator.of(context).pop();
    if (route == null) {
      onPressed();
      return;
    }
    route.completed.then((_) => onPressed());
  }

  Widget _popupMenuItem(
    BuildContext context, {
    required PopupMenuItemData item,
    required int index,
  }) {
    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final onPressed = item.onPressed;
    final submenu = item.children != null;
    final disabled = onPressed == null && !submenu;
    final active = submenu && identical(activeSubmenu, item);
    final onSubmenu = this.onSubmenu;
    final highlight = colorScheme.primary.withValues(
      alpha: isLight ? 0.08 : 0.12,
    );
    final color = disabled
        ? colorScheme.onSurface.opacity30
        : colorScheme.onSurface;
    final iconColor = disabled
        ? colorScheme.onSurface.opacity30
        : item.icon == Icons.check_circle_rounded
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    final trailing = item.trailing;
    final label = EmojiText(
      item.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.bodyMedium?.copyWith(
        color: color,
        fontSize: fontSize,
      ),
    );
    return Builder(
      builder: (itemContext) {
        Rect? rectOf() {
          final box = itemContext.findRenderObject();
          if (box is! RenderBox || !box.hasSize) return null;
          return box.localToGlobal(Offset.zero) & box.size;
        }

        return InkWell(
          customBorder: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onHover: onSubmenu == null || !hoverSubmenu
              ? null
              : (hovering) {
                  if (!hovering) return;
                  onSubmenu(submenu ? item : null, submenu ? rectOf() : null);
                },
          hoverColor: highlight,
          highlightColor: colorScheme.primary.withValues(
            alpha: isLight ? 0.10 : 0.16,
          ),
          splashColor: highlight,
          onTap: submenu
              ? () => onSubmenu?.call(active ? null : item, rectOf())
              : onPressed != null
              ? () => _select(context, onPressed)
              : null,
          child: Container(
            constraints: BoxConstraints(minWidth: minWidth),
            decoration: active
                ? ShapeDecoration(
                    color: highlight,
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  )
                : null,
            padding: EdgeInsets.only(
              left: 14,
              right: submenu || trailing != null ? 10 : 22,
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
                if (submenu)
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (trailing != null) ...[
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 140),
                            child: label,
                          ),
                          const SizedBox(width: 8),
                          Flexible(child: trailing),
                        ] else
                          Flexible(child: label),
                      ],
                    ),
                  )
                else if (trailing != null) ...[
                  Expanded(child: label),
                  const SizedBox(width: 16),
                  trailing,
                ] else
                  Flexible(child: label),
                if (submenu) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: fontSize + 5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final header = this.header;
    final footer = this.footer;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) ...[
          header,
          const Divider(height: 9, indent: 8, endIndent: 8),
        ],
        for (final item in items.asMap().entries) ...[
          _popupMenuItem(context, item: item.value, index: item.key),
          if (item.value != items.last) const SizedBox(height: 2),
        ],
        if (footer != null) ...[
          const Divider(height: 9, indent: 8, endIndent: 8),
          footer,
        ],
      ],
    );
    final body = scrollable
        ? SingleChildScrollView(
            padding: const EdgeInsets.all(6),
            child: content,
          )
        : Padding(padding: const EdgeInsets.all(6), child: content);
    if (bare) return IntrinsicWidth(child: body);
    final menu = IntrinsicWidth(child: surface(context, body));
    if (scrollable) return menu;
    return IntrinsicHeight(child: menu);
  }

  static Widget surface(BuildContext context, Widget child) {
    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    return Material(
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
      child: child,
    );
  }
}
