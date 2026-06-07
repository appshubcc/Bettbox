import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'common.dart';

class ProxiesListView extends ConsumerWidget {
  const ProxiesListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(proxiesListStateProvider);

    if (state.groups.isEmpty) {
      return NullStatus(
        label: appLocalizations.nullTip(appLocalizations.proxies),
      );
    }

    return _ProxyGroupsList(
      groups: state.groups,
      columns: state.columns,
      cardType: state.proxyCardType,
      sortType: state.proxiesSortType,
      currentUnfoldSet: state.currentUnfoldSet,
    );
  }
}

class _ProxyGroupsList extends ConsumerStatefulWidget {
  final List<Group> groups;
  final int columns;
  final ProxyCardType cardType;
  final ProxiesSortType sortType;
  final Set<String> currentUnfoldSet;

  const _ProxyGroupsList({
    required this.groups,
    required this.columns,
    required this.cardType,
    required this.sortType,
    required this.currentUnfoldSet,
  });

  @override
  ConsumerState<_ProxyGroupsList> createState() => _ProxyGroupsListState();
}

abstract class _FlatItem {
  double getHeight(double headerHeight, double itemHeight);
}

class _HeaderItem extends _FlatItem {
  final Group group;
  _HeaderItem(this.group);

  @override
  double getHeight(double headerHeight, double itemHeight) => headerHeight;
}

class _SpacingItem extends _FlatItem {
  final double height;
  _SpacingItem(this.height);

  @override
  double getHeight(double headerHeight, double itemHeight) => height;
}

class _RowItem extends _FlatItem {
  final Group group;
  final List<Proxy> proxies;
  _RowItem(this.group, this.proxies);

  @override
  double getHeight(double headerHeight, double itemHeight) => itemHeight + 8.0;
}

class _ProxyGroupsListState extends ConsumerState<_ProxyGroupsList> {
  final ScrollController _scrollController = ScrollController();

  void _handleToggle(String groupName) {
    final tempUnfoldSet = Set<String>.from(widget.currentUnfoldSet);
    if (tempUnfoldSet.contains(groupName)) {
      tempUnfoldSet.remove(groupName);
    } else {
      tempUnfoldSet.add(groupName);
    }
    globalState.appController.updateCurrentUnfoldSet(tempUnfoldSet);
  }

  double _getHeaderHeight() {
    final measure = globalState.measure;
    final contentRowHeight = [40.0, measure.titleMediumHeight + 4 + measure.labelMediumHeight]
        .reduce((a, b) => a > b ? a : b);
    return 24.0 + contentRowHeight;
  }

  void _scrollToSelected(String groupName) {
    if (!_scrollController.hasClients) return;
    final selectedName = ref.read(getSelectedProxyNameProvider(groupName)).getSafeValue('');
    if (selectedName.isEmpty) return;

    final headerHeight = _getHeaderHeight();
    final itemHeight = getItemHeight(widget.cardType);

    final tempFlatItems = _buildFlatItems();
    var targetIndex = -1;
    for (var i = 0; i < tempFlatItems.length; i++) {
      final item = tempFlatItems[i];
      if (item is _HeaderItem && item.group.name == groupName) {
        targetIndex = i;
        break;
      }
    }
    if (targetIndex < 0) return;

    var targetOffset = 0.0;
    for (var i = 0; i < targetIndex; i++) {
      targetOffset += tempFlatItems[i].getHeight(headerHeight, itemHeight);
    }

    final group = widget.groups.firstWhere((g) => g.name == groupName);
    final sortedProxies = globalState.appController.getSortProxies(
      proxies: group.all,
      sortType: widget.sortType,
      testUrl: group.testUrl,
    );
    final proxyIndex = sortedProxies.indexWhere((p) => p.name == selectedName);
    if (proxyIndex >= 0) {
      final rowIndex = proxyIndex ~/ widget.columns;
      targetOffset += headerHeight + 8.0;
      targetOffset += rowIndex * (itemHeight + 8.0);
    }

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  List<_FlatItem> _buildFlatItems() {
    final flatItems = <_FlatItem>[];
    for (final group in widget.groups) {
      flatItems.add(_HeaderItem(group));
      flatItems.add(_SpacingItem(8.0));

      final isExpand = widget.currentUnfoldSet.contains(group.name);
      if (isExpand) {
        final sortedProxies = globalState.appController.getSortProxies(
          proxies: group.all,
          sortType: widget.sortType,
          testUrl: group.testUrl,
        );

        for (var i = 0; i < sortedProxies.length; i += widget.columns) {
          final end = (i + widget.columns < sortedProxies.length)
              ? i + widget.columns
              : sortedProxies.length;
          final chunk = sortedProxies.sublist(i, end);
          flatItems.add(_RowItem(group, chunk));
        }
      }
    }
    return flatItems;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flatItems = _buildFlatItems();
    final headerHeight = _getHeaderHeight();
    final itemHeight = getItemHeight(widget.cardType);

    return CommonScrollBar(
      controller: _scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: flatItems.length,
        itemExtentBuilder: (index, _) {
          return flatItems[index].getHeight(headerHeight, itemHeight);
        },
        itemBuilder: (context, index) {
          final item = flatItems[index];
          if (item is _HeaderItem) {
            final isExpand = widget.currentUnfoldSet.contains(item.group.name);
            return _GroupHeader(
              key: ValueKey('header_${item.group.name}'),
              group: item.group,
              isExpand: isExpand,
              onToggle: () => _handleToggle(item.group.name),
              cardType: widget.cardType,
              columns: widget.columns,
              onScrollToSelected: () => _scrollToSelected(item.group.name),
            );
          } else if (item is _SpacingItem) {
            return SizedBox(height: item.height);
          } else if (item is _RowItem) {
            final cardWidgets = <Widget>[];
            for (var i = 0; i < widget.columns; i++) {
              if (i < item.proxies.length) {
                final proxy = item.proxies[i];
                cardWidgets.add(
                  Expanded(
                    child: ProxyCard(
                      key: ValueKey('${item.group.name}.${proxy.name}'),
                      proxy: proxy,
                      groupName: item.group.name,
                      type: widget.cardType,
                      groupType: item.group.type,
                      testUrl: item.group.testUrl,
                    ),
                  ),
                );
              } else {
                cardWidgets.add(const Expanded(child: SizedBox()));
              }
            }

            final rowChildren = <Widget>[];
            for (var i = 0; i < cardWidgets.length; i++) {
              rowChildren.add(cardWidgets[i]);
              if (i < cardWidgets.length - 1) {
                rowChildren.add(const SizedBox(width: 8));
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                height: itemHeight,
                child: Row(
                  children: rowChildren,
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
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
    final iconMap = ref.watch(
      proxiesStyleSettingProvider.select((s) => s.iconMap),
    );
    final icon = _getIcon(iconStyle, iconMap);
    final selectedProxyName = ref.watch(
      getSelectedProxyNameProvider(group.name),
    ).getSafeValue('');

    final selectedProxyIcon = ref.watch(
      groupsProvider.select((groups) {
        if (selectedProxyName.isEmpty) return '';
        return groups.getGroup(selectedProxyName)?.icon ?? '';
      }),
    );

    return CommonCard(
      radius: 16,
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
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        group.type.name,
                        style: context.textTheme.labelMedium?.toLight,
                      ),
                      if (selectedProxyName.isNotEmpty) ...[
                        Text(
                          '  •  ',
                          style: context.textTheme.labelMedium?.toLight,
                        ),
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
                            style: context.textTheme.labelMedium?.toLight,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isExpand) ...[
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.adjust),
                onPressed: onScrollToSelected,
                tooltip: 'Scroll to selected',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.network_ping),
                onPressed: () => _delayTest(context),
                tooltip: 'Delay test',
              ),
            ],
            IconButton.filledTonal(
              visualDensity: VisualDensity.compact,
              icon: CommonExpandIcon(expand: isExpand),
              onPressed: onToggle,
            ),
          ],
        ),
      ),
    );
  }

  String _getIcon(ProxiesIconStyle style, Map<String, String> iconMap) {
    if (style == ProxiesIconStyle.none) return '';
    for (final entry in iconMap.entries) {
      try {
        if (RegExp(entry.key).hasMatch(group.name)) {
          return entry.value;
        }
      } catch (_) {}
    }
    return group.icon;
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
        child: CommonTargetIcon(
          src: icon,
          size: iconSize - 12,
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: iconSize,
      height: iconSize,
      alignment: Alignment.center,
      child: CommonTargetIcon(
        src: icon,
        size: iconSize - 8,
      ),
    );
  }

  Future<void> _delayTest(BuildContext context) async {
    await delayTest(group.all, group.testUrl);
  }
}