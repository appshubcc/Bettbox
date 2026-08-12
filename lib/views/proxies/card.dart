import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/proxies/common.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:emoji_regex/emoji_regex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

final proxyIconProvider = Provider.family<String, String>((ref, proxyName) {
  if (proxyName.isEmpty) return '';
  final style = ref.watch(
    proxiesStyleSettingProvider.select((s) => s.iconStyle),
  );
  if (style == ProxiesIconStyle.none) return '';

  final iconMap = ref.watch(
    proxiesStyleSettingProvider.select((s) => s.iconMap),
  );
  for (final entry in iconMap.entries) {
    try {
      if (RegExp(entry.key).hasMatch(proxyName)) {
        return entry.value;
      }
    } catch (_) {}
  }

  final groups = ref.watch(groupsProvider);
  return groups.getGroup(proxyName)?.icon ?? '';
});

class ProxyCard extends StatelessWidget {
  static final _emojiRegex = emojiRegex();
  static final Map<String, bool> _emojiMatchCache = {};

  static bool _hasEmoji(String name) {
    return _emojiMatchCache.putIfAbsent(
      name,
      () => _emojiRegex.hasMatch(name),
    );
  }

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

  bool get _isNonTestableProxy {
    final name = proxy.name.toUpperCase();
    return name == 'REJECT' ||
        name == 'REJECT-DROP' ||
        name == 'PASS' ||
        proxy.type.toUpperCase() == 'REMATCH';
  }

  void _handleTestCurrentDelay() {
    if (_isNonTestableProxy) return;
    proxyDelayTest(proxy, testUrl);
  }

  Widget _buildDelayText(BuildContext context) {
    return SizedBox(
      height: measure.labelSmallHeight,
      child: Consumer(
        builder: (_, ref, _) {
          final delay = ref.watch(
            getDelayProvider(proxyName: proxy.name, testUrl: testUrl),
          );
          final delayAnimation = ref.watch(
            proxiesStyleSettingProvider.select((s) => s.delayAnimation),
          );

          if (_isNonTestableProxy) {
            return const SizedBox(height: 0, width: 0);
          }

          if (delay == 0) {
            return SizedBox(
              height: measure.labelSmallHeight,
              width: measure.labelSmallHeight,
              child: delayAnimation == DelayAnimationType.none
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : _buildDelayAnimation(
                      delayAnimation,
                      measure.labelSmallHeight,
                      context.colorScheme.primary,
                    ),
            );
          }

          if (delay == null) {
            return SizedBox(
              height: measure.labelSmallHeight,
              width: measure.labelSmallHeight,
              child: IconButton(
                icon: const Icon(Icons.bolt),
                iconSize: measure.labelSmallHeight,
                padding: EdgeInsets.zero,
                onPressed: _handleTestCurrentDelay,
              ),
            );
          }

          return GestureDetector(
            onTap: _handleTestCurrentDelay,
            child: Text(
              delay > 0 ? '$delay ms' : 'Timeout',
              style: context.textTheme.labelSmall?.copyWith(
                overflow: TextOverflow.ellipsis,
                color: utils.getDelayColor(delay),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDelayAnimation(
    DelayAnimationType animationType,
    double size,
    Color color,
  ) {
    return switch (animationType) {
      DelayAnimationType.none => Icon(Icons.bolt, size: size),
      DelayAnimationType.rotatingCircle => SpinKitRotatingCircle(
        color: color,
        size: size,
      ),
      DelayAnimationType.pulse => SpinKitPulse(color: color, size: size),
      DelayAnimationType.spinningLines => SpinKitSpinningLines(
        color: color,
        size: size,
      ),
      DelayAnimationType.threeInOut => SpinKitThreeInOut(
        color: color,
        size: size,
      ),
      DelayAnimationType.threeBounce => SpinKitThreeBounce(
        color: color,
        size: size,
      ),
      DelayAnimationType.circle => SpinKitCircle(color: color, size: size),
      DelayAnimationType.fadingCircle => SpinKitFadingCircle(
        color: color,
        size: size,
      ),
      DelayAnimationType.fadingFour => SpinKitFadingFour(
        color: color,
        size: size,
      ),
      DelayAnimationType.wave => SpinKitWave(color: color, size: size),
      DelayAnimationType.doubleBounce => SpinKitDoubleBounce(
        color: color,
        size: size,
      ),
    };
  }

  Widget _buildProxyNameWithIcon(
    BuildContext context,
    WidgetRef ref, {
    required bool showComputedMark,
  }) {
    final nameWidget = _buildProxyNameText(context);

    Widget wrapPadding(Widget child) {
      if (showComputedMark) {
        return Padding(
          padding: const EdgeInsets.only(right: 28),
          child: child,
        );
      }
      return child;
    }

    if (_hasEmoji(proxy.name)) {
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
      getSelectedProxyNameProvider(groupName).select(
        (name) => name == proxy.name,
      ),
    );
  }

  bool _isComputedMatch(WidgetRef ref) {
    return ref.watch(
      getProxyNameProvider(groupName).select(
        (name) => name == proxy.name,
      ),
    );
  }

  Widget _buildProxyNameText(BuildContext context) {
    if (type == ProxyCardType.min) {
      return SizedBox(
        height: measure.bodyMediumHeight * 1,
        child: EmojiText(
          proxy.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium,
        ),
      );
    } else {
      return SizedBox(
        height: measure.bodyMediumHeight * 2,
        child: EmojiText(
          proxy.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium,
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final delayText = _buildDelayText(context);
    return Consumer(
      builder: (_, ref, child) {
        final isSelected = _isSelectedProxy(ref);
        final isComputedMatch = groupType.isComputedSelected &&
            _isComputedMatch(ref);
        final proxyNameWidget = _buildProxyNameWithIcon(
          context,
          ref,
          showComputedMark: isComputedMatch,
        );
        return Stack(
          children: [
            CommonCard(
              onPressed: () {
                _changeProxy(ref);
              },
              isSelected: isSelected,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    proxyNameWidget,
                    if (type == ProxyCardType.expand) ...[
                      SizedBox(
                        height: measure.labelSmallHeight * 2 + 4,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            SizedBox(
                              height: measure.labelSmallHeight,
                              child: _ProxyDesc(proxy: proxy),
                            ),
                            SizedBox(
                              height: measure.labelSmallHeight,
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
                      ),
                    ] else
                      SizedBox(
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
                                  style: context.textTheme.bodySmall
                                      ?.copyWith(
                                        overflow: TextOverflow.ellipsis,
                                        color: context
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.opacity80,
                                      ),
                                ),
                              ),
                            ),
                            delayText,
                          ],
                        ),
                      ),
                  ],
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
      },
    );
  }
}

class _ProxyDesc extends ConsumerWidget {
  final Proxy proxy;

  const _ProxyDesc({required this.proxy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(
      groupsProvider.select((groups) => groups.getGroup(proxy.name)),
    );
    if (group == null) return const SizedBox.shrink();
    final selectedName = ref
        .watch(getProxyCardStateProvider(proxy.name))
        .proxyName;
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
    return Container(
      alignment: Alignment.topRight,
      margin: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: Icon(
          Icons.lock_outline,
          size: 18,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
