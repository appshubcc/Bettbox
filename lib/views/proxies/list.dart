import 'dart:math' as math;

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'card.dart';
import 'common.dart';

class ProxiesListView extends StatefulWidget {
  const ProxiesListView({super.key});

  @override
  State<ProxiesListView> createState() => ProxiesListViewState();
}

class ProxiesListViewState extends State<ProxiesListView> {
  final _groupsListKey = GlobalKey<_ProxyGroupsListState>();

  void collapseAll() => _groupsListKey.currentState?.collapseAll();

  @override
  Widget build(BuildContext context) {
    return ActiveConsumer(
      builder: (_, ref) {
        final state = ref.watch(proxiesListStateProvider);

        if (state.groups.isEmpty) {
          return NullStatus(
            label: appLocalizations.nullTip(appLocalizations.proxies),
            icon: Icons.cloud_off_outlined,
          );
        }

        return _ProxyGroupsList(
          key: _groupsListKey,
          groups: state.groups,
          columns: state.columns,
          cardType: state.proxyCardType,
          currentUnfoldSet: state.currentUnfoldSet,
        );
      },
    );
  }
}

class _ProxyGroupsList extends ConsumerStatefulWidget {
  final List<Group> groups;
  final int columns;
  final ProxyCardType cardType;
  final Set<String> currentUnfoldSet;

  const _ProxyGroupsList({
    super.key,
    required this.groups,
    required this.columns,
    required this.cardType,
    required this.currentUnfoldSet,
  });

  @override
  ConsumerState<_ProxyGroupsList> createState() => _ProxyGroupsListState();
}

class _ProxyGroupsListState extends ConsumerState<_ProxyGroupsList>
    with SingleTickerProviderStateMixin {
  static final _expandSlide = Tween<Offset>(
    begin: const Offset(0, -0.16),
    end: Offset.zero,
  );
  static final List<CurveTween> _rowFadeTweens = List<CurveTween>.generate(7, (
    index,
  ) {
    final begin = index * 0.07;
    return CurveTween(
      curve: Interval(begin, begin + 0.58, curve: Curves.easeOutCubic),
    );
  }, growable: false);

  final ScrollController _scrollController = ScrollController();
  final _sliverCache = <String, (Group, Object, Widget)>{};
  late final AnimationController _expandController;
  String? _expandingGroup;
  bool _pendingScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: 1,
    );
  }

  Set<String> _groupsWithRows(_ProxyGroupsList target) {
    return {
      for (final group in target.groups)
        if (target.currentUnfoldSet.contains(group.name) &&
            group.all.isNotEmpty)
          group.name,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sliverCache.clear();
  }

  @override
  void didUpdateWidget(_ProxyGroupsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.columns != widget.columns ||
        oldWidget.cardType != widget.cardType) {
      _sliverCache.clear();
    } else if (!identical(oldWidget.groups, widget.groups)) {
      final names = {for (final group in widget.groups) group.name};
      _sliverCache.removeWhere((name, _) => !names.contains(name));
    }
    if (_pendingScrollToTop && widget.currentUnfoldSet.isEmpty) {
      _pendingScrollToTop = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTop());
    }
    final added = _groupsWithRows(
      widget,
    ).difference(_groupsWithRows(oldWidget));
    if (added.length != 1 || !TickerMode.valuesOf(context).enabled) return;
    _expandingGroup = added.first;
    _expandController.forward(from: 0);
  }

  void _handleToggle(String groupName) {
    final tempUnfoldSet = Set<String>.from(widget.currentUnfoldSet);
    if (tempUnfoldSet.contains(groupName)) {
      tempUnfoldSet.remove(groupName);
    } else {
      tempUnfoldSet.add(groupName);
    }
    globalState.appController.updateCurrentUnfoldSet(tempUnfoldSet);
  }

  void collapseAll() {
    if (widget.currentUnfoldSet.isEmpty) return;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        _collapsedAnchorOffset(_scrollController.position),
      );
    }
    _pendingScrollToTop = true;
    globalState.appController.updateCurrentUnfoldSet({});
  }

  double _collapsedAnchorOffset(ScrollPosition position) {
    final offset = position.pixels;
    final top = 16.0 + _rise;
    final headerExtent = _getHeaderHeight() + 8.0;
    final rowExtent = getItemHeight(widget.cardType) + 8.0;
    final groups = widget.groups;
    var anchor = offset;
    var start = top;
    for (var i = 0; i < groups.length; i++) {
      final group = groups[i];
      final rowCount = widget.currentUnfoldSet.contains(group.name)
          ? (group.all.length / widget.columns).ceil()
          : 0;
      final extent = headerExtent + rowCount * rowExtent;
      if (offset < start + extent) {
        final delta = offset - start;
        final collapsedStart = top + i * headerExtent;
        anchor = delta < headerExtent ? collapsedStart + delta : collapsedStart;
        break;
      }
      start += extent;
    }
    final collapsedMax =
        top +
        groups.length * headerExtent +
        _bottomPadding(ref.read(isMobileViewProvider)) -
        position.viewportDimension;
    return anchor.clamp(0.0, math.max(0.0, collapsedMax));
  }

  void _scrollToTop() {
    if (!mounted || !_scrollController.hasClients) return;
    final distance = _scrollController.offset;
    if (distance <= 0) return;
    _scrollController.animateTo(
      0,
      duration: Duration(
        milliseconds: (240 + distance * 0.12).clamp(240, 560).round(),
      ),
      curve: Curves.easeInOutCubic,
    );
  }

  double _bottomPadding(bool isMobileView) {
    return 16.0 +
        (isMobileView ? getFloatingBottomBarReserveHeight(context) : 0);
  }

  double _getHeaderHeight() {
    final measure = globalState.measure;
    final contentRowHeight = math.max(
      40.0,
      measure.titleMediumHeight + 4 + measure.labelMediumHeight,
    );
    return 28.0 + contentRowHeight;
  }

  static const _pinnedInset = 8.0;
  static const _edgeFadeInset = 16.0;
  double _rise = 0;

  void _scrollToSelected(String groupName) {
    if (!_scrollController.hasClients) return;
    final selectedName = ref
        .read(getSelectedProxyNameProvider(groupName))
        .getSafeValue('');
    if (selectedName.isEmpty) return;

    final headerHeight = _getHeaderHeight();
    final itemHeight = getItemHeight(widget.cardType);
    final autoStickyHeader = ref.read(
      proxiesStyleSettingProvider.select((s) => s.autoStickyHeader),
    );

    var targetOffset = 16.0;
    Group? targetGroup;
    for (final group in widget.groups) {
      if (group.name == groupName) {
        targetGroup = group;
        break;
      }
      final isExpand = widget.currentUnfoldSet.contains(group.name);
      final rowCount = isExpand
          ? (group.all.length / widget.columns).ceil()
          : 0;
      targetOffset += headerHeight + 8.0 + rowCount * (itemHeight + 8.0);
    }
    final group = targetGroup;
    if (group == null) return;

    final proxyIndex = group.all.indexWhere((p) => p.name == selectedName);
    if (proxyIndex >= 0) {
      final rowIndex = proxyIndex ~/ widget.columns;
      if (autoStickyHeader) {
        targetOffset += rowIndex * (itemHeight + 8.0) - _pinnedInset;
      } else {
        targetOffset += headerHeight + 8.0 + rowIndex * (itemHeight + 8.0);
        if (_rise > 0) targetOffset -= _edgeFadeInset;
      }
    }

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  Widget _buildRow(
    Group group,
    List<Proxy> sortedProxies,
    int rowIndex,
    double itemHeight,
  ) {
    final columns = widget.columns;
    final start = rowIndex * columns;
    final totalLength = sortedProxies.length;

    final rowChildren = <Widget>[];
    for (var i = 0; i < columns; i++) {
      if (i > 0) {
        rowChildren.add(const SizedBox(width: 8));
      }
      final proxyIndex = start + i;
      if (proxyIndex < totalLength) {
        final proxy = sortedProxies[proxyIndex];
        rowChildren.add(
          Expanded(
            child: ProxyCard(
              key: ValueKey('${group.name}.${proxy.name}'),
              proxy: proxy,
              groupName: group.name,
              type: widget.cardType,
              groupType: group.type,
              testUrl: group.testUrl,
            ),
          ),
        );
      } else {
        rowChildren.add(const Expanded(child: SizedBox()));
      }
    }

    final rowWidget = Row(children: rowChildren);
    final Widget content = switch (group.name == _expandingGroup) {
      true => () {
        final animation = _expandController.drive(
          _rowFadeTweens[math.min(rowIndex, 6)],
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(_expandSlide),
            child: rowWidget,
          ),
        );
      }(),
      false => rowWidget,
    };

    return Padding(
      key: ValueKey('row_${group.name}_$rowIndex'),
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(height: itemHeight, child: content),
    );
  }

  Widget _buildGroupSliver(
    Group group,
    double headerHeight,
    double itemHeight,
    bool autoStickyHeader,
  ) {
    final isExpand = widget.currentUnfoldSet.contains(group.name);
    final cacheKey = (
      isExpand,
      group.name == _expandingGroup,
      headerHeight,
      itemHeight,
      autoStickyHeader,
    );
    final cached = _sliverCache[group.name];
    if (cached != null &&
        identical(cached.$1, group) &&
        cached.$2 == cacheKey) {
      return cached.$3;
    }
    final sortedProxies = isExpand ? group.all : const <Proxy>[];
    final rowCount = (sortedProxies.length / widget.columns).ceil();

    final sliver = SliverPadding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
      sliver: SliverStickyHeader(
        key: ValueKey('group_${group.name}'),
        pinned: autoStickyHeader,
        spacing: 8,
        pinnedInset: _pinnedInset,
        headerRadius: 16,
        pinnedShadow: BoxShadow(
          color: Colors.black.withValues(
            alpha: context.colorScheme.brightness == Brightness.light
                ? 0.10
                : 0.32,
          ),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
        header: SizedBox(
          height: headerHeight,
          child: _GroupHeader(
            key: ValueKey('header_${group.name}'),
            group: group,
            isExpand: isExpand,
            onToggle: () => _handleToggle(group.name),
            cardType: widget.cardType,
            columns: widget.columns,
            onScrollToSelected: () => _scrollToSelected(group.name),
          ),
        ),
        sliver: SliverFixedExtentList(
          itemExtent: itemHeight + 8,
          delegate: SliverChildBuilderDelegate(
            (context, rowIndex) =>
                _buildRow(group, sortedProxies, rowIndex, itemHeight),
            childCount: rowCount,
          ),
        ),
      ),
    );
    _sliverCache[group.name] = (group, cacheKey, sliver);
    return sliver;
  }

  @override
  void dispose() {
    _expandController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobileView = ref.watch(isMobileViewProvider);
    final autoStickyHeader = ref.watch(
      proxiesStyleSettingProvider.select((s) => s.autoStickyHeader),
    );
    final itemHeight = getItemHeight(widget.cardType);
    final headerHeight = _getHeaderHeight();

    return ScrollEdgeRise(
      builder: (context, rise) {
        _rise = rise;
        return CommonScrollBar(
          controller: _scrollController,
          child: CustomScrollView(
            key: const PageStorageKey<String>('proxies_list'),
            controller: _scrollController,
            clipBehavior: Clip.hardEdge,
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 16 + rise)),
              for (final group in widget.groups)
                _buildGroupSliver(
                  group,
                  headerHeight,
                  itemHeight,
                  autoStickyHeader,
                ),
              SliverPadding(
                padding: EdgeInsets.only(bottom: _bottomPadding(isMobileView)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GroupHeader extends ConsumerWidget {
  final Group group;
  final bool isExpand;
  final VoidCallback onToggle;
  final ProxyCardType cardType;
  final int columns;
  final VoidCallback? onScrollToSelected;

  const _GroupHeader({
    super.key,
    required this.group,
    required this.isExpand,
    required this.onToggle,
    required this.cardType,
    required this.columns,
    this.onScrollToSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconStyle = ref.watch(
      proxiesStyleSettingProvider.select((s) => s.iconStyle),
    );
    final icon = ref.watch(proxyIconProvider(group.name));
    final selectedProxyName = ref
        .watch(getSelectedProxyNameProvider(group.name))
        .getSafeValue('');

    final selectedProxyIcon = ref.watch(proxyIconProvider(selectedProxyName));

    final showFilled = iconStyle == ProxiesIconStyle.none;
    final expandIcon = CommonExpandIcon(
      expand: isExpand,
      duration: const Duration(milliseconds: 320),
    );
    final primaryColor = context.colorScheme.primary;
    final expandButtonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return primaryColor.withValues(alpha: 0.2);
        }
        return null;
      }),
    );
    void handleToggle() {
      if (system.isAndroid &&
          ref.read(
            appSettingProvider.select((s) => s.enableNavBarHapticFeedback),
          )) {
        HapticFeedback.selectionClick();
      }
      onToggle();
    }

    final textTheme = context.textTheme;
    final labelLightStyle = textTheme.labelMedium?.toLight;

    return CommonCard(
      radius: 20.0,
      subtle: true,
      elevated: false,
      type: CommonCardType.filled,
      onPressed: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildIcon(context, iconStyle, icon),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  EmojiText(
                    group.name,
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(group.type.name, style: labelLightStyle),
                      if (selectedProxyName.isNotEmpty) ...[
                        Text('  •  ', style: labelLightStyle),
                        if (selectedProxyIcon.isNotEmpty) ...[
                          CommonTargetIcon(
                            src: selectedProxyIcon,
                            size: globalState.measure.labelMediumHeight,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: EmojiText(
                            selectedProxyName,
                            style: labelLightStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isExpand)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 6),
                  PressScale(
                    child: SizedBox.square(
                      dimension: 36,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.adjust),
                        onPressed: onScrollToSelected,
                        tooltip: appLocalizations.locate,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: delayTestCoordinator,
                    builder: (_, _) {
                      final isTestingThisGroup = delayTestCoordinator
                          .isTestingGroup(group.name);
                      return PressScale(
                        enabled: !delayTestCoordinator.isTesting,
                        child: SizedBox(
                          width: 44,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            icon: isTestingThisGroup
                                ? const RepaintBoundary(
                                    child: SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.network_ping),
                            onPressed: delayTestCoordinator.isTesting
                                ? null
                                : () => _delayTest(context),
                            tooltip: appLocalizations.startTest,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            PressScale(
              child: SizedBox.square(
                dimension: 36,
                child: showFilled
                    ? IconButton.filledTonal(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        icon: expandIcon,
                        onPressed: handleToggle,
                        style: expandButtonStyle,
                      )
                    : IconButton(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        icon: expandIcon,
                        onPressed: handleToggle,
                        style: expandButtonStyle,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, ProxiesIconStyle style, String icon) {
    if (style == ProxiesIconStyle.none) return const SizedBox();
    const iconSize = 40.0;
    if (style == ProxiesIconStyle.standard) {
      return Container(
        margin: const EdgeInsets.only(right: 16),
        width: iconSize,
        height: iconSize,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: context.colorScheme.secondaryContainer,
        ),
        clipBehavior: Clip.antiAlias,
        child: CommonTargetIcon(src: icon, size: iconSize - 12),
      );
    }
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: iconSize,
      height: iconSize,
      alignment: Alignment.center,
      child: CommonTargetIcon(src: icon, size: iconSize - 8),
    );
  }

  Future<void> _delayTest(BuildContext context) async {
    final currentGroups = globalState.appController.getCurrentGroups();
    final targetGroup = currentGroups.getGroup(group.name) ?? group;
    await delayTest(
      targetGroup.all,
      testUrl: targetGroup.testUrl,
      groupName: targetGroup.name,
    );
  }
}
