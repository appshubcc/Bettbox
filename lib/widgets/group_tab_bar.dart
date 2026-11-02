import 'package:bett_box/common/common.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'effect.dart';
import 'google_bottom_nav_bar.dart';
import 'text.dart';

class GroupTabBar extends ConsumerStatefulWidget {
  static const double height = 36;

  final TabController controller;
  final List<String> labels;
  final VoidCallback? onMore;
  final ValueListenable<bool>? moreOpen;

  const GroupTabBar({
    super.key,
    required this.controller,
    required this.labels,
    this.onMore,
    this.moreOpen,
  });

  @override
  ConsumerState<GroupTabBar> createState() => _GroupTabBarState();
}

class _GroupTabBarState extends ConsumerState<GroupTabBar> {
  final _scrollController = ScrollController();
  final _rowKey = GlobalKey();
  final _haptic = SelectionHaptic();
  late final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(
    widget.controller.index,
  );
  List<GlobalKey> _itemKeys = [];
  Animation<double>? _animation;
  bool _overflow = false;
  bool _feedback = true;
  double? _scrollTarget;

  @override
  void initState() {
    super.initState();
    _itemKeys = _createKeys();
    _attach();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _reveal(_selectedIndex.value, animate: false),
    );
  }

  @override
  void didUpdateWidget(covariant GroupTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.labels, widget.labels)) {
      _itemKeys = _createKeys();
    }
    if (oldWidget.controller != widget.controller) {
      _detach(oldWidget.controller);
      _attach();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _reveal(_selectedIndex.value, animate: false),
      );
    }
  }

  @override
  void dispose() {
    _detach(widget.controller);
    _scrollController.dispose();
    _selectedIndex.dispose();
    super.dispose();
  }

  List<GlobalKey> _createKeys() =>
      List.generate(widget.labels.length, (_) => GlobalKey());

  void _attach() {
    final controller = widget.controller;
    _selectedIndex.value = controller.index;
    controller.addListener(_onControllerTick);
    _animation = controller.animation?..addListener(_onControllerTick);
  }

  void _detach(TabController controller) {
    controller.removeListener(_onControllerTick);
    _animation?.removeListener(_onControllerTick);
    _animation = null;
  }

  void _onControllerTick() {
    final controller = widget.controller;
    if (controller.length == 0) return;
    final animation = _animation;
    final index = controller.indexIsChanging || animation == null
        ? controller.index
        : animation.value.round().clamp(0, controller.length - 1);
    if (index == _selectedIndex.value) return;
    _selectedIndex.value = index;
    _reveal(index);
  }

  void _reveal(int index, {bool animate = true}) {
    if (!mounted || !_scrollController.hasClients) return;
    if (index < 0 || index >= _itemKeys.length) return;
    final rowBox = _rowKey.currentContext?.findRenderObject();
    final itemBox = _itemKeys[index].currentContext?.findRenderObject();
    if (rowBox is! RenderBox ||
        !rowBox.hasSize ||
        itemBox is! RenderBox ||
        !itemBox.hasSize) {
      return;
    }
    _scrollTarget = null;
    final position = _scrollController.position;
    if (!position.hasContentDimensions) return;
    final itemCenter =
        itemBox.localToGlobal(Offset.zero, ancestor: rowBox).dx +
        itemBox.size.width / 2;
    final target = (itemCenter - position.viewportDimension / 2).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if ((target - position.pixels).abs() < 1) return;
    if (!animate) {
      _scrollController.jumpTo(target);
      return;
    }
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;
    final delta = event.scrollDelta.dx.abs() > event.scrollDelta.dy.abs()
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;
    if (delta == 0) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      if (!mounted || !_scrollController.hasClients) return;
      final pos = _scrollController.position;
      final base = (_scrollTarget ?? pos.pixels).clamp(
        pos.minScrollExtent,
        pos.maxScrollExtent,
      );
      final target = (base + delta * 1.2).clamp(
        pos.minScrollExtent,
        pos.maxScrollExtent,
      );
      if ((target - pos.pixels).abs() < 0.5) {
        _scrollTarget = null;
        return;
      }
      _scrollTarget = target;
      _scrollController
          .animateTo(
            target,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() {
            if (_scrollTarget == target) {
              _scrollTarget = null;
            }
          });
    });
  }

  bool _onScrollMetrics(ScrollMetricsNotification notification) {
    final overflow = notification.metrics.maxScrollExtent > 0;
    if (overflow != _overflow) {
      setState(() => _overflow = overflow);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _reveal(_selectedIndex.value, animate: false),
      );
    }
    return false;
  }

  void _select(int index) {
    final controller = widget.controller;
    if (index == _selectedIndex.value && !controller.indexIsChanging) {
      return;
    }
    _selectedIndex.value = index;
    _reveal(index);
    if (index != controller.index) {
      controller.animateTo(
        index,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Widget _buildEdgeFade(Widget child) {
    if (!_scrollController.hasClients) return child;
    final position = _scrollController.position;
    if (!position.hasContentDimensions || position.maxScrollExtent <= 0) {
      return child;
    }
    final leftFactor = (position.pixels / 20).clamp(0.0, 1.0);
    final rightFactor =
        ((position.maxScrollExtent - position.pixels) / 20).clamp(0.0, 1.0);
    if (leftFactor <= 0 && rightFactor <= 0) return child;
    return ShaderMask(
      shaderCallback: (bounds) {
        if (bounds.width <= 0) {
          return const LinearGradient(
            colors: [Colors.white, Colors.white],
          ).createShader(bounds);
        }
        final leftStop = (18 * leftFactor / bounds.width).clamp(0.0, 0.15);
        final rightStop =
            (1.0 - (24 * rightFactor / bounds.width)).clamp(0.82, 1.0);
        return LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 1 - leftFactor),
            Colors.white,
            Colors.white,
            Colors.white.withValues(alpha: 1 - rightFactor),
          ],
          stops: [0.0, leftStop, rightStop, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }

  Widget _buildMoreButton({
    required Color backgroundColor,
    required Color borderColor,
    required Color iconColor,
    required bool isMobileView,
  }) {
    final moreOpen = widget.moreOpen;
    return PressScale(
      child: Material(
        color: backgroundColor,
        shape: CircleBorder(
          side: BorderSide(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            _haptic(_feedback);
            widget.onMore?.call();
          },
          child: SizedBox.square(
            dimension: GroupTabBar.height,
            child: IconTheme.merge(
              data: IconThemeData(color: iconColor, size: 18),
              child: isMobileView && moreOpen != null
                  ? ValueListenableBuilder(
                      valueListenable: moreOpen,
                      builder: (_, open, _) => CommonExpandIcon(
                        expand: open,
                        duration: const Duration(milliseconds: 320),
                      ),
                    )
                  : Icon(
                      isMobileView ? Icons.expand_more : Icons.chevron_right,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _feedback = ref.watch(
      appSettingProvider.select((state) => state.enableNavBarHapticFeedback),
    );
    final isMobileView = ref.watch(isMobileViewProvider);
    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;

    final unselectedBg = isLight
        ? colorScheme.surfaceContainerLowest
        : colorScheme.surfaceContainerLow;
    final selectedBg = isLight
        ? Color.alphaBlend(
            colorScheme.secondaryContainer.withValues(alpha: 0.78),
            colorScheme.surfaceContainerLowest,
          )
        : Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.18),
            unselectedBg,
          );
    final unselectedBorder = colorScheme.outlineVariant.withValues(
      alpha: isLight ? 0.35 : 0.16,
    );
    final selectedBorder = colorScheme.primary.withValues(
      alpha: isLight ? 0.45 : 0.55,
    );
    final unselectedText = colorScheme.onSurfaceVariant;
    final selectedText = isLight
        ? colorScheme.onSecondaryContainer
        : colorScheme.primary;

    final textStyle = context.textTheme.bodyMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );

    final count = widget.labels.length;
    final showMore = _overflow && widget.onMore != null;

    return SizedBox(
      height: GroupTabBar.height,
      child: Row(
        children: [
          Expanded(
            child: Listener(
              onPointerSignal: _onPointerSignal,
              child: NotificationListener<ScrollMetricsNotification>(
                onNotification: _onScrollMetrics,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                      PointerDeviceKind.stylus,
                    },
                    scrollbars: false,
                  ),
                  child: AnimatedBuilder(
                    animation: _scrollController,
                    builder: (_, child) => _buildEdgeFade(child!),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        key: _rowKey,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var index = 0; index < count; index++) ...[
                            if (index > 0) const SizedBox(width: 7),
                            _GroupTabChip(
                              key: _itemKeys[index],
                              label: widget.labels[index],
                              index: index,
                              selectedIndex: _selectedIndex,
                              style: textStyle,
                              unselectedBg: unselectedBg,
                              selectedBg: selectedBg,
                              unselectedBorder: unselectedBorder,
                              selectedBorder: selectedBorder,
                              unselectedText: unselectedText,
                              selectedText: selectedText,
                              onTap: () => _select(index),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showMore) ...[
            const SizedBox(width: 8),
            _buildMoreButton(
              backgroundColor: unselectedBg,
              borderColor: unselectedBorder,
              iconColor: unselectedText,
              isMobileView: isMobileView,
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupTabChip extends StatefulWidget {
  final String label;
  final int index;
  final ValueListenable<int> selectedIndex;
  final TextStyle? style;
  final Color unselectedBg;
  final Color selectedBg;
  final Color unselectedBorder;
  final Color selectedBorder;
  final Color unselectedText;
  final Color selectedText;
  final VoidCallback onTap;

  const _GroupTabChip({
    super.key,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.style,
    required this.unselectedBg,
    required this.selectedBg,
    required this.unselectedBorder,
    required this.selectedBorder,
    required this.unselectedText,
    required this.selectedText,
    required this.onTap,
  });

  @override
  State<_GroupTabChip> createState() => _GroupTabChipState();
}

class _GroupTabChipState extends State<_GroupTabChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
    reverseDuration: const Duration(milliseconds: 110),
    value: widget.selectedIndex.value == widget.index ? 1.0 : 0.0,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeOutQuad,
  );
  bool _selected = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedIndex.value == widget.index;
    widget.selectedIndex.addListener(_onSelectedChanged);
  }

  @override
  void didUpdateWidget(covariant _GroupTabChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      oldWidget.selectedIndex.removeListener(_onSelectedChanged);
      widget.selectedIndex.addListener(_onSelectedChanged);
    }
    _syncSelected();
  }

  @override
  void dispose() {
    widget.selectedIndex.removeListener(_onSelectedChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSelectedChanged() => _syncSelected();

  void _syncSelected() {
    final selected = widget.selectedIndex.value == widget.index;
    if (selected == _selected) return;
    _selected = selected;
    if (selected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        if (_pressed) setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (_, _) {
            final t = _animation.value;
            final bgColor = Color.lerp(
              widget.unselectedBg,
              widget.selectedBg,
              t,
            )!;
            final borderColor = Color.lerp(
              widget.unselectedBorder,
              widget.selectedBorder,
              t,
            )!;
            final textColor = Color.lerp(
              widget.unselectedText,
              widget.selectedText,
              t,
            )!;
            return Container(
              constraints: const BoxConstraints(
                minWidth: 64,
                minHeight: GroupTabBar.height,
                maxHeight: GroupTabBar.height,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: ShapeDecoration(
                color: bgColor,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(GroupTabBar.height / 2),
                  side: BorderSide(
                    color: borderColor,
                    width: 1.0 + 0.15 * t,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: EmojiText(
                widget.label,
                maxLines: 1,
                style: widget.style?.copyWith(color: textColor),
              ),
            );
          },
        ),
      ),
    );
  }
}
