import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/proxies/common.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

  bool get _isNonTestableProxy {
    final name = proxy.name.toUpperCase();
    return name == 'REJECT' || name == 'REJECT-DROP' || name == 'PASS';
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

          // REJECT, REJECT-DROP, PASS 节点不显示测试按钮
          if (_isNonTestableProxy) {
            return const SizedBox(
              height: 0,
              width: 0,
            );
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
      DelayAnimationType.rotatingCircle =>
        SpinKitRotatingCircle(color: color, size: size),
      DelayAnimationType.pulse => SpinKitPulse(color: color, size: size),
      DelayAnimationType.spinningLines =>
        SpinKitSpinningLines(color: color, size: size),
      DelayAnimationType.threeInOut =>
        SpinKitThreeInOut(color: color, size: size),
      DelayAnimationType.threeBounce =>
        SpinKitThreeBounce(color: color, size: size),
      DelayAnimationType.circle => SpinKitCircle(color: color, size: size),
      DelayAnimationType.fadingCircle =>
        SpinKitFadingCircle(color: color, size: size),
      DelayAnimationType.fadingFour =>
        SpinKitFadingFour(color: color, size: size),
      DelayAnimationType.wave => SpinKitWave(color: color, size: size),
      DelayAnimationType.doubleBounce =>
        SpinKitDoubleBounce(color: color, size: size),
    };
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
    final proxyNameText = _buildProxyNameText(context);
    final delayText = _buildDelayText(context);
    return RepaintBoundary(
      child: Stack(
        children: [
          Consumer(
            builder: (_, ref, child) {
              final selectedProxyName = ref.watch(
                getSelectedProxyNameProvider(groupName),
              );
              return CommonCard(
                onPressed: () {
                  _changeProxy(ref);
                },
                isSelected: selectedProxyName == proxy.name,
                child: child!,
              );
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  proxyNameText,
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
                                style: context.textTheme.bodySmall?.copyWith(
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
          if (groupType.isComputedSelected)
            Positioned(
              top: 0,
              right: 0,
              child: _ProxyComputedMark(groupName: groupName, proxy: proxy),
            ),
        ],
      ),
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
    return Ink(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerHighest.opacity50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: colorScheme.outlineVariant.opacity30),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.labelSmall?.copyWith(
          height: 1,
          color: colorScheme.onSurfaceVariant.opacity80,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _ProxyComputedMark extends ConsumerWidget {
  final String groupName;
  final Proxy proxy;

  const _ProxyComputedMark({required this.groupName, required this.proxy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxyName = ref.watch(getProxyNameProvider(groupName));
    if (proxyName != proxy.name) {
      return const SizedBox();
    }
    return Container(
      alignment: Alignment.topRight,
      margin: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: const SelectIcon(),
      ),
    );
  }
}
