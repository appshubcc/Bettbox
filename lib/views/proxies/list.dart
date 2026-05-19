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

class _ProxyGroupsList extends StatelessWidget {
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

  void _handleToggle(String groupName) {
    final tempUnfoldSet = Set<String>.from(currentUnfoldSet);
    if (tempUnfoldSet.contains(groupName)) {
      tempUnfoldSet.remove(groupName);
    } else {
      tempUnfoldSet.add(groupName);
    }
    globalState.appController.updateCurrentUnfoldSet(tempUnfoldSet);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScrollBar(
      controller: null,
      thumbVisibility: true,
      trackVisibility: true,
      child: CustomScrollView(
        cacheExtent: 500,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final isExpand = currentUnfoldSet.contains(group.name);
                return _GroupSection(
                  key: ValueKey(group.name),
                  group: group,
                  columns: columns,
                  cardType: cardType,
                  sortType: sortType,
                  isExpand: isExpand,
                  onToggle: () => _handleToggle(group.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupSection extends StatelessWidget {
  final Group group;
  final int columns;
  final ProxyCardType cardType;
  final ProxiesSortType sortType;
  final bool isExpand;
  final VoidCallback onToggle;

  const _GroupSection({
    super.key,
    required this.group,
    required this.columns,
    required this.cardType,
    required this.sortType,
    required this.isExpand,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GroupHeader(
            group: group,
            isExpand: isExpand,
            onToggle: onToggle,
            cardType: cardType,
            columns: columns,
          ),
          if (isExpand) ...[
            const SizedBox(height: 8),
            _ProxyGrid(
              group: group,
              columns: columns,
              cardType: cardType,
              sortType: sortType,
            ),
          ],
        ],
        ),
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

  const _GroupHeader({
    required this.group,
    required this.isExpand,
    required this.onToggle,
    required this.cardType,
    required this.columns,
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

    // Resolve the icon of the selected proxy if it is a sub-group
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
                        const SizedBox(width: 8),
                        if (selectedProxyIcon.isNotEmpty) ...[
                          CommonTargetIcon(
                            src: selectedProxyIcon,
                            size: globalState.measure.labelMediumHeight,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: EmojiText(
                            '•  $selectedProxyName',
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
                onPressed: () => _scrollToSelected(context, ref),
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

  void _scrollToSelected(BuildContext context, WidgetRef ref) {
    final selectedName = ref.read(getSelectedProxyNameProvider(group.name)).getSafeValue('');
    if (selectedName.isEmpty) return;

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return;

    final proxyIndex = group.all.indexWhere((p) => p.name == selectedName);
    if (proxyIndex < 0) return;

    final itemHeight = getItemHeight(cardType);
    final offset = (proxyIndex ~/ columns) * (itemHeight + 8) + 100;

    scrollable.position.animateTo(
      offset.clamp(0, scrollable.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }
}

class _ProxyGrid extends StatelessWidget {
  final Group group;
  final int columns;
  final ProxyCardType cardType;
  final ProxiesSortType sortType;

  const _ProxyGrid({
    required this.group,
    required this.columns,
    required this.cardType,
    required this.sortType,
  });

  @override
  Widget build(BuildContext context) {
    final sortedProxies = globalState.appController.getSortProxies(
      proxies: group.all,
      sortType: sortType,
      testUrl: group.testUrl,
    );

    final itemHeight = getItemHeight(cardType);

    return SizedBox(
      height: ((sortedProxies.length / columns).ceil() * (itemHeight + 8)).toDouble(),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          mainAxisExtent: itemHeight,
        ),
        itemCount: sortedProxies.length,
        itemBuilder: (context, index) {
          final proxy = sortedProxies[index];
          return ProxyCard(
            key: ValueKey('${group.name}.${proxy.name}'),
            proxy: proxy,
            groupName: group.name,
            type: cardType,
            groupType: group.type,
            testUrl: group.testUrl,
          );
        },
      ),
    );
  }
}