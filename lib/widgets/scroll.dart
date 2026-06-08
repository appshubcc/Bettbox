import 'dart:async';

import 'package:collection/collection.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/material.dart';
import 'package:silky_scroll/silky_scroll.dart';

class CommonScrollBar extends StatelessWidget {
  final ScrollController? controller;
  final Widget child;
  final bool trackVisibility;
  final bool thumbVisibility;

  const CommonScrollBar({
    super.key,
    required this.child,
    required this.controller,
    this.trackVisibility = false,
    this.thumbVisibility = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasController = controller != null;
    return Scrollbar(
      controller: controller,
      thumbVisibility: hasController ? thumbVisibility : false,
      trackVisibility: hasController ? trackVisibility : false,
      thickness: 8,
      radius: const Radius.circular(8),
      interactive: hasController,
      child: child,
    );
  }
}

class ScrollToEndBox<T> extends StatefulWidget {
  final ScrollController controller;
  final List<T> dataSource;
  final Widget child;
  final bool enable;
  final VoidCallback? onCancelToEnd;

  const ScrollToEndBox({
    super.key,
    required this.child,
    required this.controller,
    required this.dataSource,
    this.onCancelToEnd,
    this.enable = true,
  });

  @override
  State<ScrollToEndBox<T>> createState() => _ScrollToEndBoxState<T>();
}

class _ScrollToEndBoxState<T> extends State<ScrollToEndBox<T>> {
  final _equals = ListEquality<T>();
  var _isFastToEnd = false;

  Future<void> _handleTryToEnd() async {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted && widget.controller.hasClients) {
        final pos = widget.controller.position;
        if (pos.pixels != pos.maxScrollExtent) {
          await widget.controller.animateTo(
            pos.maxScrollExtent,
            duration: kThemeAnimationDuration,
            curve: Curves.easeOut,
          );
        }
      }
      completer.complete();
    });
    return completer.future;
  }

  @override
  void didUpdateWidget(ScrollToEndBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enable && !oldWidget.enable) {
      _isFastToEnd = true;
      _handleTryToEnd().then((_) => _isFastToEnd = false);
      return;
    }
    if (widget.enable && !_equals.equals(oldWidget.dataSource, widget.dataSource)) {
      _handleTryToEnd();
    }
  }

  @override
  Widget build(BuildContext context) => NotificationListener<UserScrollNotification>(
    onNotification: (n) {
      if (!_isFastToEnd && widget.onCancelToEnd != null) {
        widget.onCancelToEnd!();
      }
      return false;
    },
    child: widget.child,
  );
}

class CacheItemExtentListView extends StatefulWidget {
  final NullableIndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final String Function(int index) keyBuilder;
  final double Function(int index) itemExtentBuilder;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool reverse;
  final ScrollController controller;
  final CacheTag tag;

  const CacheItemExtentListView({
    super.key,
    this.physics,
    this.reverse = false,
    this.shrinkWrap = false,
    required this.itemBuilder,
    required this.controller,
    required this.keyBuilder,
    required this.itemCount,
    required this.itemExtentBuilder,
    required this.tag,
  });

  @override
  State<CacheItemExtentListView> createState() => _CacheItemExtentListViewState();
}

class _CacheItemExtentListViewState extends State<CacheItemExtentListView> {
  @override
  void initState() {
    super.initState();
    _updateCache();
  }

  void _updateCache() {
    globalState.computeHeightMapCache[widget.tag]?.updateMaxLength(widget.itemCount);
    globalState.computeHeightMapCache[widget.tag] ??= FixedMap(widget.itemCount);
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
    itemBuilder: widget.itemBuilder,
    itemCount: widget.itemCount,
    physics: widget.physics,
    reverse: widget.reverse,
    shrinkWrap: widget.shrinkWrap,
    controller: widget.controller,
    itemExtentBuilder: (index, _) {
      _updateCache();
      return globalState.computeHeightMapCache[widget.tag]?.updateCacheValue(
        widget.keyBuilder(index),
        () => widget.itemExtentBuilder(index),
      );
    },
  );
}

class CacheItemExtentSliverReorderableList extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final String Function(int index) keyBuilder;
  final double Function(int index) itemExtentBuilder;
  final ReorderCallback onReorder;
  final ReorderItemProxyDecorator? proxyDecorator;
  final CacheTag tag;

  const CacheItemExtentSliverReorderableList({
    super.key,
    required this.itemBuilder,
    required this.keyBuilder,
    required this.itemCount,
    required this.itemExtentBuilder,
    required this.onReorder,
    this.proxyDecorator,
    required this.tag,
  });

  @override
  State<CacheItemExtentSliverReorderableList> createState() =>
      _CacheItemExtentSliverReorderableListState();
}

class _CacheItemExtentSliverReorderableListState
    extends State<CacheItemExtentSliverReorderableList> {
  @override
  void initState() {
    super.initState();
    _updateCache();
  }

  void _updateCache() {
    globalState.computeHeightMapCache[widget.tag]?.updateMaxLength(widget.itemCount);
    globalState.computeHeightMapCache[widget.tag] ??= FixedMap(widget.itemCount);
  }

  @override
  Widget build(BuildContext context) {
    _updateCache();
    return SliverReorderableList(
      itemBuilder: widget.itemBuilder,
      itemCount: widget.itemCount,
      itemExtentBuilder: (index, _) => globalState.computeHeightMapCache[widget.tag]?.updateCacheValue(
        widget.keyBuilder(index),
        () => widget.itemExtentBuilder(index),
      ),
      // ignore: deprecated_member_use
      onReorder: widget.onReorder,
      proxyDecorator: widget.proxyDecorator,
    );
  }
}

class AdaptiveListView extends StatelessWidget {
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool reverse;
  final int? itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final bool shrinkWrap;

  const AdaptiveListView.builder({
    super.key,
    this.controller,
    this.physics,
    this.reverse = false,
    this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.itemExtent,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    if (system.isAndroid || reverse) {
      return ListView.builder(
        controller: controller,
        physics: physics,
        reverse: reverse,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        padding: padding,
        itemExtent: itemExtent,
        shrinkWrap: shrinkWrap,
      );
    }
    return SilkyListView.builder(
      controller: controller,
      physics: physics ?? const ScrollPhysics(),
      reverse: reverse,
      silkyConfig: silkyScrollConfig,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      padding: padding,
      itemExtent: itemExtent,
      shrinkWrap: shrinkWrap,
    );
  }
}
