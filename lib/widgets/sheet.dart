import 'dart:async';
import 'dart:math' as math;

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
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
    true => _showBottomSheet<T>(context, builder: builder, props: props),
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

Future<T?> _showBottomSheet<T>(
  BuildContext context, {
  required SheetBuilder builder,
  required SheetProps props,
}) {
  final navigator = Navigator.of(context);
  final localizations = MaterialLocalizations.of(context);
  return navigator.push(
    _SheetRoute<T>(
      vsync: LeadTickerProvider(navigator),
      builder: (sheetContext) => _SheetScope(
        props: props,
        child: SafeArea(
          bottom: false,
          child: builder(sheetContext, SheetType.bottomSheet),
        ),
      ),
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      barrierLabel: localizations.scrimLabel,
      barrierOnTapHint: localizations.scrimOnTapHint(
        localizations.bottomSheetLabel,
      ),
      modalBarrierColor: Theme.of(context).bottomSheetTheme.modalBarrierColor,
      useSafeArea: props.useSafeArea,
    ),
  );
}

class _SheetRoute<T> extends ModalBottomSheetRoute<T>
    with ArrivalHoldRouteMixin<T> {
  final LeadTickerProvider _vsync;

  _SheetRoute({
    required LeadTickerProvider vsync,
    required super.builder,
    super.capturedThemes,
    super.barrierLabel,
    super.barrierOnTapHint,
    super.modalBarrierColor,
    super.useSafeArea,
  }) : _vsync = vsync,
       super(
         isScrollControlled: true,
         backgroundColor: Colors.transparent,
         showDragHandle: false,
         transitionAnimationController: BottomSheet.createAnimationController(
           vsync,
         ),
       );

  @override
  Ticker? get arrivalTicker => _vsync.ticker;

  @override
  AnimationController createAnimationController() {
    final controller = super.createAnimationController();
    willDisposeAnimationController = true;
    return controller;
  }
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
      actions: genActions(context, [
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
    with TickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 260);
  static const _minFraction = 0.4;

  late final AnimationController _controller;
  late final AnimationController _offset;
  late final AnimationController _morph;
  double _travel = 0;
  double _sheetHeight = 0;
  double _collapsedHeight = 0;
  double _maxHeight = double.infinity;
  bool _canExpand = false;
  bool _scrollDragging = false;
  double _headerHeight = 0;
  double _bodyHeight = 0;
  double _overflow = 0;
  int _overflowDepth = 1 << 30;
  double? _contentHeight;
  double _from = 0;
  bool _syncScheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _offset = AnimationController.unbounded(vsync: this);
    _morph = AnimationController(vsync: this, duration: _duration, value: 1);
  }

  @override
  void dispose() {
    _morph.dispose();
    _offset.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    scheduleMicrotask(_sync);
  }

  void _sync() {
    _syncScheduled = false;
    if (!mounted) return;
    final content = _headerHeight + _bodyHeight + _overflow;
    final previous = _contentHeight;
    if (previous != null && (content - previous).abs() < 0.5) return;
    if (previous != null) {
      _from = _sheetHeight;
      _morph.forward(from: 0);
    }
    if (content <= _maxHeight && _controller.value != 0) {
      _controller.stop();
      _controller.value = 0;
    }
    setState(() => _contentHeight = content);
  }

  void _onHeaderHeight(double height) {
    _headerHeight = height;
    _scheduleSync();
  }

  void _onBodyHeight(double height) {
    _bodyHeight = height;
    _scheduleSync();
  }

  bool _handleMetrics(ScrollMetricsNotification notification) {
    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) return false;
    if (notification.depth > _overflowDepth) return false;
    _overflowDepth = notification.depth;
    _overflow = metrics.maxScrollExtent - metrics.minScrollExtent;
    _scheduleSync();
    return false;
  }

  bool get _isExpanded => _controller.value >= 0.5;

  void _expand() {
    if (!mounted) return;
    HapticFeedback.selectionClick();
    _controller.animateTo(1, curve: Curves.easeOutCubic);
  }

  void _collapse() {
    if (!mounted) return;
    HapticFeedback.selectionClick();
    _controller.animateTo(0, curve: Curves.easeOutCubic);
  }

  void _dismiss() {
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _handleTap() {
    if (_canExpand && !_isExpanded) {
      _expand();
      return;
    }
    _dismiss();
  }

  void _dragBy(double dy) {
    _controller.stop();
    _offset.stop();
    var remaining = dy;
    if (remaining < 0 && _offset.value > 0) {
      final next = math.max(0.0, _offset.value + remaining);
      remaining += _offset.value - next;
      _offset.value = next;
    }
    if (_canExpand && remaining != 0 && _offset.value == 0) {
      final next = (_controller.value - remaining / _travel).clamp(0.0, 1.0);
      remaining += (next - _controller.value) * _travel;
      _controller.value = next;
    }
    if (remaining > 0) {
      _offset.value += remaining;
    }
  }

  void _dragEnd(double vy) {
    if (_offset.value > 0) {
      if (vy > 700 || (vy > -250 && _offset.value > _sheetHeight * 0.3)) {
        _dismiss();
        return;
      }
      _offset.animateTo(0, duration: _duration, curve: Curves.easeOutCubic);
      return;
    }
    if (!_canExpand) return;
    if (vy < -250) {
      _expand();
    } else if (vy > 250) {
      _collapse();
    } else {
      _controller.value >= 0.4 ? _expand() : _collapse();
    }
  }

  bool _handleScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification is OverscrollNotification &&
        notification.dragDetails != null &&
        notification.overscroll < 0) {
      _scrollDragging = true;
      _dragBy(-notification.overscroll);
    } else if (notification is ScrollEndNotification && _scrollDragging) {
      _scrollDragging = false;
      _dragEnd(notification.dragDetails?.velocity.pixelsPerSecond.dy ?? 0);
    }
    return false;
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
    final lowerHeight = math.min(
      screenHeight * math.min(_minFraction, initialFraction),
      maxHeight,
    );
    _maxHeight = maxHeight;
    final contentHeight = _contentHeight;
    if (contentHeight == null || contentHeight <= maxHeight) {
      _canExpand = false;
      _travel = 0;
      _collapsedHeight = math.min(
        math.max(contentHeight ?? lowerHeight, lowerHeight),
        maxHeight,
      );
    } else {
      _travel = maxHeight - initialHeight;
      _canExpand = expandable && _travel > 0;
      _collapsedHeight = _canExpand
          ? initialHeight
          : math.max(initialHeight, maxHeight);
    }

    final appBar = AppBar(
      forceMaterialTransparency: true,
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: _SheetTitle(title: widget.title, badge: widget.badge),
      actions: genActions(context, widget.actions),
    );

    final header = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: _HeightReporter(
        onHeight: _onHeaderHeight,
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
      ),
    );

    final backgroundColor = context.colorScheme.surfaceContainerLow;
    final isTv = globalState.isAndroidTV;

    final sheetContent = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) => _dragBy(details.delta.dy),
      onVerticalDragEnd: (details) =>
          _dragEnd(details.velocity.pixelsPerSecond.dy),
      child: Container(
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
            Flexible(
              flex: 1,
              child: NotificationListener<ScrollMetricsNotification>(
                onNotification: _handleMetrics,
                child: NotificationListener<ScrollNotification>(
                  onNotification: _handleScroll,
                  child: _HeightReporter(
                    onHeight: _onBodyHeight,
                    child: widget.body,
                  ),
                ),
              ),
            ),
            SizedBox(height: insets),
          ],
        ),
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
        animation: Listenable.merge([_controller, _offset, _morph]),
        child: RepaintBoundary(child: RouteSnapshot(child: sheetContent)),
        builder: (context, child) {
          final base = _collapsedHeight + _travel * _controller.value;
          final height = _morph.isCompleted
              ? base
              : _from +
                    (base - _from) *
                        Curves.easeOutCubic.transform(_morph.value);
          _sheetHeight = height;

          return Transform.translate(
            offset: Offset(0, _offset.value),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: height + insets,
                maxHeight: height + insets,
                minWidth: double.infinity,
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _HeightReporter extends SingleChildRenderObjectWidget {
  final ValueChanged<double> onHeight;

  const _HeightReporter({required this.onHeight, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeightReporter(onHeight);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderHeightReporter renderObject,
  ) {
    renderObject.onHeight = onHeight;
  }
}

class _RenderHeightReporter extends RenderProxyBox {
  _RenderHeightReporter(this.onHeight);

  ValueChanged<double> onHeight;
  double? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final height = size.height;
    if (height == _reported) return;
    _reported = height;
    SchedulerBinding.instance.addPostFrameCallback((_) => onHeight(height));
  }
}
