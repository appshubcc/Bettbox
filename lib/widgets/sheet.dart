import 'dart:math' as math;

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'pop_scope.dart';
import 'scaffold.dart';
import 'side_sheet.dart';
import 'text.dart';

@immutable
class SheetProps {
  final double? maxWidth;
  final double? maxHeight;
  final bool isScrollControlled;
  final bool useSafeArea;
  final bool blur;
  final Color? barrierColor;
  final bool expandable;
  final double initialFraction;
  final double maxFraction;

  const SheetProps({
    this.maxWidth,
    this.maxHeight,
    this.useSafeArea = true,
    this.isScrollControlled = false,
    this.blur = false,
    this.barrierColor,
    this.expandable = true,
    this.initialFraction = 0.58,
    this.maxFraction = 0.92,
  });
}

class _SheetScope extends InheritedWidget {
  final SheetProps props;

  const _SheetScope({required this.props, required super.child});

  static SheetProps? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SheetScope>()?.props;
  }

  @override
  bool updateShouldNotify(_SheetScope oldWidget) => props != oldWidget.props;
}

@immutable
class ExtendProps {
  final double? maxWidth;
  final bool useSafeArea;
  final bool blur;
  final bool forceFull;

  const ExtendProps({
    this.maxWidth,
    this.useSafeArea = true,
    this.blur = false,
    this.forceFull = false,
  });
}

enum SheetType { page, bottomSheet, sideSheet }

bool isInBottomSheet(BuildContext context) =>
    _SheetScope.maybeOf(context) != null;

ShapeDecoration panelTileDecoration(BuildContext context) {
  final colorScheme = context.colorScheme;
  final borderRadius = BorderRadius.circular(20);
  if (!isInBottomSheet(context)) {
    return ShapeDecoration(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedSuperellipseBorder(borderRadius: borderRadius),
    );
  }
  final isLight = colorScheme.brightness == Brightness.light;
  return ShapeDecoration(
    color: isLight
        ? Color.lerp(
            colorScheme.surface,
            colorScheme.surfaceContainerLowest,
            0.5,
          )
        : colorScheme.surfaceContainerHigh,
    shape: RoundedSuperellipseBorder(
      borderRadius: borderRadius,
      side: BorderSide(
        color: colorScheme.outlineVariant.withValues(
          alpha: isLight ? 0.8 : 0.4,
        ),
      ),
    ),
  );
}

typedef SheetBuilder = Widget Function(BuildContext context, SheetType type);

Future<T?> showSheet<T>({
  required BuildContext context,
  required SheetBuilder builder,
  SheetProps props = const SheetProps(),
}) {
  final isMobile = globalState.appState.viewMode == ViewMode.mobile;
  return switch (isMobile) {
    true => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _SheetScope(
          props: props,
          child: SafeArea(
            bottom: false,
            child: builder(sheetContext, SheetType.bottomSheet),
          ),
        );
      },
      showDragHandle: false,
      useSafeArea: props.useSafeArea,
    ),
    false => showModalSideSheet<T>(
      useSafeArea: props.useSafeArea,
      isScrollControlled: props.isScrollControlled,
      barrierColor: props.barrierColor,
      context: context,
      constraints: BoxConstraints(maxWidth: props.maxWidth ?? 360),
      filter: props.blur ? commonFilter : null,
      builder: (_) {
        return builder(context, SheetType.sideSheet);
      },
    ),
  };
}

Future<T?> showExtend<T>(
  BuildContext context, {
  required SheetBuilder builder,
  ExtendProps props = const ExtendProps(),
}) {
  final isMobile = globalState.appState.viewMode == ViewMode.mobile;
  return switch (isMobile || props.forceFull) {
    true => BaseNavigator.push(context, builder(context, SheetType.page)),
    false => showModalSideSheet<T>(
      useSafeArea: props.useSafeArea,
      context: context,
      constraints: BoxConstraints(maxWidth: props.maxWidth ?? 360),
      filter: props.blur ? commonFilter : null,
      builder: (context) {
        return builder(context, SheetType.sideSheet);
      },
    ),
  };
}

class AdaptiveSheetScaffold extends StatelessWidget {
  final SheetType type;
  final Widget body;
  final String title;
  final String? badge;
  final List<Widget> actions;
  final bool? expandable;
  final double? initialFraction;
  final double? maxFraction;

  const AdaptiveSheetScaffold({
    super.key,
    required this.type,
    required this.body,
    required this.title,
    this.badge,
    this.actions = const [],
    this.expandable,
    this.initialFraction,
    this.maxFraction,
  });

  @override
  Widget build(BuildContext context) {
    if (type == SheetType.bottomSheet) {
      return _ExpandableBottomSheet(
        title: title,
        badge: badge,
        body: body,
        actions: actions,
        expandable: expandable,
        initialFraction: initialFraction,
        maxFraction: maxFraction,
      );
    }

    final sideSheet = type == SheetType.sideSheet;
    final backgroundColor = sideSheet
        ? context.colorScheme.surfaceContainerLow
        : null;
    final appBar = AppBar(
      automaticallyImplyLeading: actions.isEmpty && sideSheet ? false : true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: _SheetTitle(title: title, badge: badge),
      actions: genActions([
        if (actions.isEmpty && sideSheet) const CloseButton(),
        ...actions,
      ]),
    );

    final isTv = globalState.isAndroidTV;
    return PopScope(
      canPop: !isTv,
      onPopInvokedWithResult: !isTv
          ? null
          : (didPop, result) {
              if (didPop) return;
              if (dismissTvInputFocus()) return;
              if (ModalRoute.of(context)?.isCurrent != true) return;
              Navigator.of(context).pop();
            },
      child: CommonScaffold(
        appBar: appBar,
        backgroundColor: backgroundColor,
        body: body,
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  final String title;
  final String? badge;

  const _SheetTitle({required this.title, this.badge});

  @override
  Widget build(BuildContext context) {
    final badge = this.badge;
    if (badge == null) return EmojiText(title);
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Flexible(
          child: EmojiText(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            badge,
            style: context.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpandableBottomSheet extends StatefulWidget {
  final String title;
  final String? badge;
  final Widget body;
  final List<Widget> actions;
  final bool? expandable;
  final double? initialFraction;
  final double? maxFraction;

  const _ExpandableBottomSheet({
    required this.title,
    this.badge,
    required this.body,
    required this.actions,
    this.expandable,
    this.initialFraction,
    this.maxFraction,
  });

  @override
  State<_ExpandableBottomSheet> createState() => _ExpandableBottomSheetState();
}

class _ExpandableBottomSheetState extends State<_ExpandableBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curve;
  double _dragStartY = 0.0;
  double _dragStartValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _isExpanded => _controller.value >= 0.5;

  void _expand() {
    if (!mounted) return;
    HapticFeedback.selectionClick();
    _controller.forward();
  }

  void _collapse() {
    if (!mounted) return;
    HapticFeedback.selectionClick();
    _controller.reverse();
  }

  void _toggle() {
    _isExpanded ? _collapse() : _expand();
  }

  @override
  Widget build(BuildContext context) {
    final scopeProps = _SheetScope.maybeOf(context) ?? const SheetProps();
    final expandable = widget.expandable ?? scopeProps.expandable;
    final initialFraction =
        widget.initialFraction ?? scopeProps.initialFraction;
    final maxFraction = widget.maxFraction ?? scopeProps.maxFraction;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    final initialHeight = screenHeight * initialFraction;
    final maxHeight = scopeProps.maxHeight ?? (screenHeight * maxFraction);
    final travel = maxHeight - initialHeight;

    final appBar = AppBar(
      forceMaterialTransparency: true,
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: _SheetTitle(title: widget.title, badge: widget.badge),
      actions: genActions(widget.actions),
    );

    final header = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: expandable && travel > 0 ? _toggle : null,
      onVerticalDragStart: (details) {
        if (!expandable || travel <= 0) return;
        _dragStartY = details.globalPosition.dy;
        _dragStartValue = _controller.value;
      },
      onVerticalDragUpdate: (details) {
        if (!expandable || travel <= 0) return;
        final delta = _dragStartY - details.globalPosition.dy;
        _controller.value = (_dragStartValue + delta / travel).clamp(0.0, 1.0);
      },
      onVerticalDragEnd: (details) {
        if (!expandable || travel <= 0) return;
        final vy = details.velocity.pixelsPerSecond.dy;
        if (vy < -250) {
          _expand();
        } else if (vy > 250) {
          if (_dragStartValue > 0.5) {
            _collapse();
          } else {
            Navigator.of(context).pop();
          }
        } else {
          _controller.value >= 0.4 ? _expand() : _collapse();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              alignment: Alignment.center,
              height: 4,
              width: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          appBar,
        ],
      ),
    );

    Widget bodyContent = widget.body;
    if (expandable && travel > 0) {
      bodyContent = NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (notification.metrics.pixels <= 0 &&
                (notification.scrollDelta ?? 0) < -12 &&
                _controller.value > 0.5) {
              _collapse();
            }
          } else if (notification is OverscrollNotification) {
            if (notification.overscroll < -10 && _controller.value > 0.5) {
              _collapse();
            }
          }
          return false;
        },
        child: bodyContent,
      );
    }

    final backgroundColor = context.colorScheme.surfaceContainerLow;
    final isTv = globalState.isAndroidTV;

    final sheetContent = Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: const RoundedSuperellipseBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          Flexible(flex: 1, child: bodyContent),
          SizedBox(height: insets),
        ],
      ),
    );

    return PopScope(
      canPop: !isTv && !_isExpanded,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isExpanded) {
          _collapse();
          return;
        }
        if (isTv) {
          if (dismissTvInputFocus()) return;
          if (ModalRoute.of(context)?.isCurrent != true) return;
          Navigator.of(context).pop();
        }
      },
      child: AnimatedBuilder(
        animation: _curve,
        child: sheetContent,
        builder: (context, child) {
          final currentMaxHeight = (expandable && travel > 0)
              ? initialHeight + travel * _curve.value
              : math.max(initialHeight, maxHeight);

          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: initialHeight + insets,
              maxHeight: currentMaxHeight + insets,
              minWidth: double.infinity,
            ),
            child: child,
          );
        },
      ),
    );
  }
}
