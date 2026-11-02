import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/proxies/actions.dart';
import 'package:bett_box/views/proxies/common.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

final _proxyIconMatchersProvider = Provider.autoDispose<List<(RegExp, String)>>(
  (ref) {
    final iconMap = ref.watch(
      proxiesStyleSettingProvider.select((s) => s.iconMap),
    );
    final matchers = <(RegExp, String)>[];
    for (final entry in iconMap.entries) {
      try {
        matchers.add((RegExp(entry.key), entry.value));
      } catch (_) {}
    }
    return matchers;
  },
);

final proxyIconProvider = Provider.autoDispose.family<String, String>((
  ref,
  proxyName,
) {
  if (proxyName.isEmpty) return '';
  final style = ref.watch(
    proxiesStyleSettingProvider.select((s) => s.iconStyle),
  );
  if (style == ProxiesIconStyle.none) return '';

  for (final (pattern, icon) in ref.watch(_proxyIconMatchersProvider)) {
    if (pattern.hasMatch(proxyName)) {
      return icon;
    }
  }

  return ref.watch(
    groupsProvider.select((groups) => groups.getGroup(proxyName)?.icon ?? ''),
  );
});

class ProxyDelayText extends StatelessWidget {
  final Proxy proxy;
  final String? testUrl;
  final bool enableTest;

  const ProxyDelayText({
    super.key,
    required this.proxy,
    this.testUrl,
    this.enableTest = true,
  });

  bool get _isNonTestableProxy {
    return switch (proxy.name.toUpperCase()) {
      'REJECT' || 'REJECT-DROP' || 'PASS' => true,
      _ => proxy.type.toUpperCase() == 'REMATCH',
    };
  }

  void _handleTestCurrentDelay() {
    if (_isNonTestableProxy) return;
    proxyDelayTest(proxy, testUrl);
  }

  @override
  Widget build(BuildContext context) {
    if (_isNonTestableProxy) {
      return const SizedBox.shrink();
    }
    final labelSmallHeight = globalState.measure.labelSmallHeight;
    return SizedBox(
      height: labelSmallHeight,
      child: Consumer(
        builder: (context, ref, _) {
          final delay = ref.watch(
            getDelayProvider(proxyName: proxy.name, testUrl: testUrl),
          );

          if (delay == 0) {
            final delayAnimation = ref.watch(
              proxiesStyleSettingProvider.select((s) => s.delayAnimation),
            );
            return RepaintBoundary(
              child: SizedBox.square(
                dimension: labelSmallHeight,
                child: DelayAnimation(
                  type: delayAnimation,
                  size: labelSmallHeight,
                  color: context.colorScheme.primary,
                ),
              ),
            );
          }

          if (delay == null) {
            if (!enableTest) return const SizedBox.shrink();
            return SizedBox.square(
              dimension: labelSmallHeight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _handleTestCurrentDelay,
                child: Icon(
                  Icons.bolt,
                  size: labelSmallHeight,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          final text = Text(
            delay > 0 ? '$delay ms' : 'Timeout',
            style: context.textTheme.labelSmall?.copyWith(
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w600,
              color: utils.getDelayColor(delay),
            ),
          );

          if (!enableTest) return text;

          return GestureDetector(onTap: _handleTestCurrentDelay, child: text);
        },
      ),
    );
  }
}

class ProxyCard extends StatelessWidget {
  final String groupName;
  final Proxy proxy;
  final GroupType groupType;
  final ProxyCardType type;
  final String? testUrl;

  const ProxyCard({
    super.key,
    required this.groupName,
    required this.testUrl,
    required this.proxy,
    required this.groupType,
    required this.type,
  });

  Measure get measure => globalState.measure;

  Widget _buildProxyNameWithIcon(
    WidgetRef ref, {
    required Widget nameWidget,
    required bool showComputedMark,
  }) {
    Widget wrapPadding(Widget child) {
      if (showComputedMark) {
        return Padding(padding: const EdgeInsets.only(right: 28), child: child);
      }
      return child;
    }

    if (EmojiText.hasEmoji(proxy.name)) {
      return wrapPadding(nameWidget);
    }

    final subGroupIcon = ref.watch(proxyIconProvider(proxy.name));
    if (subGroupIcon.isEmpty) {
      return wrapPadding(nameWidget);
    }
    return wrapPadding(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonTargetIcon(src: subGroupIcon, size: measure.bodyMediumHeight),
          const SizedBox(width: 4),
          Flexible(child: nameWidget),
        ],
      ),
    );
  }

  bool _isSelectedProxy(WidgetRef ref) {
    return ref.watch(
      getSelectedProxyNameProvider(
        groupName,
      ).select((name) => name == proxy.name),
    );
  }

  bool _isComputedMatch(WidgetRef ref) {
    return ref.watch(
      getProxyNameProvider(groupName).select((name) => name == proxy.name),
    );
  }

  Widget _buildProxyNameText(BuildContext context) {
    final maxLines = type == ProxyCardType.min ? 1 : 2;
    return SizedBox(
      height: measure.bodyMediumHeight * maxLines,
      child: EmojiText(
        proxy.name,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildFooter(BuildContext context, Widget delayText) {
    if (type == ProxyCardType.expand) {
      final labelSmallHeight = measure.labelSmallHeight;
      return SizedBox(
        height: labelSmallHeight * 2 + 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            SizedBox(
              height: labelSmallHeight,
              child: _ProxyDesc(proxy: proxy),
            ),
            SizedBox(
              height: labelSmallHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _ProxyMetaTag(proxy.type),
                    ),
                  ),
                  delayText,
                ],
              ),
            ),
          ],
        ),
      );
    }
    final bodySmallStyle = context.textTheme.bodySmall;
    return SizedBox(
      height: measure.bodySmallHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: TooltipText(
              text: Text(
                proxy.type,
                style: bodySmallStyle?.copyWith(
                  overflow: TextOverflow.ellipsis,
                  color: bodySmallStyle.color?.opacity80,
                ),
              ),
            ),
          ),
          delayText,
        ],
      ),
    );
  }

  Future<void> _changeProxy(WidgetRef ref) async {
    final isComputedSelected = groupType.isComputedSelected;
    final isSelector = groupType == GroupType.Selector;
    if (isComputedSelected || isSelector) {
      final currentProxyName = ref.read(getProxyNameProvider(groupName));
      final nextProxyName = switch (isComputedSelected) {
        true => currentProxyName == proxy.name ? '' : proxy.name,
        false => proxy.name,
      };
      final appController = globalState.appController;
      appController.updateCurrentSelectedMap(groupName, nextProxyName);
      appController.changeProxyDebounce(groupName, nextProxyName);
      return;
    }
    globalState.showNotifier(appLocalizations.notSelectedTip);
  }

  bool get _hasActions {
    return switch (proxy.name.toUpperCase()) {
      'REJECT' || 'REJECT-DROP' || 'PASS' => false,
      _ => proxy.type.toUpperCase() != 'REMATCH',
    };
  }

  void _openActions(BuildContext context, WidgetRef ref, {Offset? position}) {
    showProxyActions(
      context,
      groupName: groupName,
      groupType: groupType,
      proxy: proxy,
      testUrl: testUrl,
      locked:
          groupType.isComputedSelected &&
          ref.read(getProxyNameProvider(groupName)) == proxy.name,
      coreRunning: ref.read(runTimeProvider) != null,
      proxyGroup: ref.read(groupsProvider).getGroup(proxy.name),
      proxyGroupSelected: ref.read(selectedMapProvider)[proxy.name] ?? '',
      position: position,
    );
  }

  @override
  Widget build(BuildContext context) {
    final delayText = ProxyDelayText(proxy: proxy, testUrl: testUrl);
    final nameTextWidget = _buildProxyNameText(context);
    final footerWidget = _buildFooter(context, delayText);
    return Consumer(
      builder: (context, ref, _) {
        final isSelected = _isSelectedProxy(ref);
        final hasActions = _hasActions;
        final isComputedMatch =
            groupType.isComputedSelected && _isComputedMatch(ref);
        final proxyNameWidget = _buildProxyNameWithIcon(
          ref,
          nameWidget: nameTextWidget,
          showComputedMark: isComputedMatch,
        );
        final card = Stack(
          children: [
            CommonCard(
              radius: 20.0,
              subtle: true,
              elevated: false,
              clipBehavior: Clip.none,
              onPressed: () => _changeProxy(ref),
              onLongPress: hasActions ? () => _openActions(context, ref) : null,
              isSelected: isSelected,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [proxyNameWidget, footerWidget],
                ),
              ),
            ),
            if (isComputedMatch)
              const Positioned(
                top: 0,
                right: 0,
                child: _ProxyComputedMarkIcon(),
              ),
          ],
        );
        if (!hasActions) return card;
        return GestureDetector(
          onSecondaryTapUp: (details) =>
              _openActions(context, ref, position: details.globalPosition),
          child: card,
        );
      },
    );
  }
}

class _ProxyDesc extends ConsumerWidget {
  final Proxy proxy;

  const _ProxyDesc({required this.proxy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGroup = ref.watch(
      groupsProvider.select((groups) => groups.getGroup(proxy.name) != null),
    );
    if (!isGroup) return const SizedBox.shrink();
    final selectedName = ref.watch(
      getProxyCardStateProvider(proxy.name).select((s) => s.proxyName),
    );
    if (selectedName.isEmpty) return const SizedBox.shrink();
    return _ProxyMetaTag(selectedName);
  }
}

class _ProxyMetaTag extends StatelessWidget {
  final String text;

  const _ProxyMetaTag(this.text);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return EmojiText(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.labelSmall?.copyWith(
        height: 1,
        color: colorScheme.onSurfaceVariant.opacity80,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _ProxyComputedMarkIcon extends StatelessWidget {
  const _ProxyComputedMarkIcon();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.topRight,
      margin: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.secondaryContainer,
        ),
        child: Icon(
          Icons.lock_outline,
          size: 18,
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
