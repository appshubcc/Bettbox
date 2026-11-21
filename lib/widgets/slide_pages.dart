import 'package:bett_box/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'scaffold.dart';

class SlidePages extends ConsumerStatefulWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final List<Widget> children;
  final bool animate;
  final bool scrollable;

  const SlidePages({
    super.key,
    required this.index,
    this.animate = true,
    this.scrollable = true,
    required this.onChanged,
    required this.children,
  });

  @override
  ConsumerState<SlidePages> createState() => _SlidePagesState();
}

class _SlidePagesState extends ConsumerState<SlidePages> {
  late final _controller = PageController(initialPage: widget.index);
  late bool _scrollable = widget.scrollable;

  bool get _isScrolling =>
      _controller.hasClients && _controller.position.isScrollingNotifier.value;

  bool _handleScrollEnd(ScrollEndNotification notification) {
    if (notification.depth == 0 && _scrollable != widget.scrollable) {
      setState(() => _scrollable = widget.scrollable);
    }
    return false;
  }

  @override
  void didUpdateWidget(SlidePages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isScrolling) {
      _scrollable = widget.scrollable;
    }
    final index = widget.index;
    if (oldWidget.index == index ||
        !_controller.hasClients ||
        _controller.page?.round() == index) {
      return;
    }
    if (widget.animate &&
        ref.read(isMobileViewProvider) &&
        ref.read(appSettingProvider).enableNavBarHapticFeedback &&
        !MediaQuery.reduceMotionOf(context)) {
      _controller.animateToPage(
        index,
        duration: kTabScrollDuration,
        curve: Curves.easeOut,
      );
    } else {
      _controller.jumpToPage(index);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: _handleScrollEnd,
      child: PageView(
        controller: _controller,
        physics: _scrollable ? null : const NeverScrollableScrollPhysics(),
        scrollBehavior: ScrollConfiguration.of(context)
            .copyWith(scrollbars: false),
        onPageChanged: widget.onChanged,
        children: [
          for (final (index, child) in widget.children.indexed)
            SlideSnapshot(
              controller: _controller,
              position: index,
              child: ScrollEdgeSource(child: child),
            ),
        ],
      ),
    );
  }
}

class SlideSnapshot extends StatefulWidget {
  final PageController controller;
  final int position;
  final Widget child;

  const SlideSnapshot({
    super.key,
    required this.controller,
    required this.position,
    required this.child,
  });

  @override
  State<SlideSnapshot> createState() => _SlideSnapshotState();
}

class _SlideSnapshotState extends State<SlideSnapshot> {
  final _snapshot = SnapshotController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
    _update();
  }

  @override
  void didUpdateWidget(SlideSnapshot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_update);
      widget.controller.addListener(_update);
    }
    _update();
  }

  void _update() {
    final controller = widget.controller;
    final metrics = controller.hasClients ? controller.position : null;
    final offset =
        metrics != null &&
            metrics.hasPixels &&
            metrics.hasViewportDimension &&
            metrics.viewportDimension > 0
        ? (metrics.pixels / metrics.viewportDimension - widget.position).abs()
        : 0.0;
    _snapshot.allowSnapshotting = offset > 0.001 && offset < 0.999;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    _snapshot.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SnapshotWidget(
      controller: _snapshot,
      mode: SnapshotMode.permissive,
      autoresize: true,
      child: widget.child,
    );
  }
}
