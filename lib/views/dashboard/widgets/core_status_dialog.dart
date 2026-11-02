import 'dart:async';
import 'dart:math';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/pages.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

Future<void> showCoreStatusDialog(BuildContext context) async {
  await globalState.showAdaptiveSheet<void>(child: const CoreStatusDialog());
}

class CoreStatusDialog extends StatefulWidget {
  const CoreStatusDialog({super.key});

  @override
  State<CoreStatusDialog> createState() => _CoreStatusDialogState();
}

class _CoreStatusDialogState extends State<CoreStatusDialog> {
  CoreStatus? _status;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _fetchStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    try {
      final status = await clashCore.getCoreStatus();
      if (!mounted) return;
      if (status != null && status != _status) {
        setState(() {
          _status = status;
        });
      }
    } catch (_) {}
  }

  Future<String> _handleForceGc() async {
    final before = _status?.physical ?? 0;
    await clashCore.requestGc(forceFreeOSMemory: true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final after = await clashCore.getCoreStatus();
    if (after == null) return appLocalizations.success;
    if (mounted) setState(() => _status = after);
    final freed = before - after.physical;
    if (freed <= 0) return appLocalizations.memoryAlreadyOptimal;
    return appLocalizations.memoryFreed(_formatBytes(freed));
  }

  String _formatBytes(int bytes) {
    return TrafficValue(value: bytes).shortShow;
  }

  String _formatCount(int count) {
    return NumberFormat.decimalPattern().format(count);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(
        '[ $title ]',
        style: context.textTheme.labelMedium?.copyWith(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
    required String percent,
    required bool isTight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isTight)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                '($percent)',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.outline,
                  fontSize: 11,
                ),
              ),
            ],
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 13),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                if (isTight) ...[
                  const SizedBox(width: 4),
                  Text(
                    '($percent)',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.outline,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryCard({
    required int inUse,
    required int reclaimable,
    required int physical,
  }) {
    final totalMemory = (inUse + reclaimable) > 0
        ? (inUse + reclaimable)
        : physical;
    final totalTraffic = TrafficValue(value: totalMemory);
    final inUseTraffic = _formatBytes(inUse);
    final reclaimableTraffic = _formatBytes(reclaimable);

    final allocatedPercent = totalMemory > 0
        ? (inUse / totalMemory * 100).toStringAsFixed(1)
        : '0.0';
    final reclaimablePercent = totalMemory > 0
        ? (reclaimable / totalMemory * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: panelTileDecoration(context),
      child: Row(
        children: [
          RingChart(
            segments: [
              RingSegment(
                value: inUse.toDouble(),
                color: context.colorScheme.primary,
              ),
              RingSegment(
                value: reclaimable.toDouble(),
                color: context.colorScheme.tertiary,
              ),
            ],
            trackColor: context.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.35,
            ),
            centerChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  totalTraffic.showValue,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.5,
                    height: 1.0,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalTraffic.showUnit,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontSize: 9.5,
                    height: 1.0,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fontSize =
                    context.textTheme.labelMedium?.fontSize ?? 12.0;
                final reclaimText =
                    '${appLocalizations.reclaimableMemory} ($reclaimablePercent%)';
                final allocText =
                    '${appLocalizations.allocatedMemory} ($allocatedPercent%)';
                final maxChars = max(reclaimText.length, allocText.length);
                final maxNeededWidth = maxChars * (fontSize * 0.85) + 18;
                final isTight = maxNeededWidth > constraints.maxWidth;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem(
                      color: context.colorScheme.primary,
                      label: appLocalizations.allocatedMemory,
                      value: inUseTraffic,
                      percent: '$allocatedPercent%',
                      isTight: isTight,
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      color: context.colorScheme.tertiary,
                      label: appLocalizations.reclaimableMemory,
                      value: reclaimableTraffic,
                      percent: '$reclaimablePercent%',
                      isTight: isTight,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: panelTileDecoration(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingCard(List<(String, int?)> items) {
    final total = items.fold<int>(0, (sum, item) => sum + (item.$2 ?? 0));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: panelTileDecoration(context),
      child: Row(
        children: [
          for (final (label, count) in items)
            Expanded(
              child: ToolRing(
                size: 62,
                label: label,
                value: count != null ? _formatCount(count) : '-',
                unit: '',
                ratio: total > 0 ? (count ?? 0) / total : 0,
                color: count != null ? context.colorScheme.primary : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGridItem(_MetricItem item, {bool isFullWidth = false}) {
    final color = item.color ?? context.colorScheme.primary;
    final valueWidget =
        item.valueChild ??
        Text(
          item.value,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: panelTileDecoration(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isFullWidth) ...[const SizedBox(height: 1), valueWidget],
              ],
            ),
          ),
          if (isFullWidth) ...[const SizedBox(width: 8), valueWidget],
        ],
      ),
    );
  }

  Widget _buildMetricGrid(List<_MetricItem> items) {
    final rows = <Widget>[];
    var i = 0;
    while (i < items.length) {
      if (i == items.length - 1) {
        rows.add(_buildGridItem(items[i], isFullWidth: true));
        i++;
      } else {
        final item1 = items[i];
        final item2 = items[i + 1];
        rows.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildGridItem(item1)),
                const SizedBox(width: 8),
                Expanded(child: _buildGridItem(item2)),
              ],
            ),
          ),
        );
        i += 2;
      }

      if (i < items.length) {
        rows.add(const SizedBox(height: 8));
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  Widget _buildGeodataChips(String geodataUse) {
    final chips = <Widget>[];
    final isNone = geodataUse.isEmpty || geodataUse == 'None';

    if (isNone) {
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            appLocalizations.none,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ),
      );
    } else {
      final parts = geodataUse
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);
      for (final part in parts) {
        chips.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              part,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        );
      }
    }

    return Wrap(spacing: 3, runSpacing: 3, children: chips);
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final inUse = status?.inUse ?? 0;
    final reclaimable = status?.reclaimable ?? 0;
    final physical = status?.physical ?? 0;

    final goroutinesText = status != null
        ? _formatCount(status.goroutines)
        : '-';
    final heapObjectsText = status != null
        ? _formatCount(status.heapObjects)
        : '-';
    final ruleProvidersText = status != null
        ? _formatCount(status.ruleProviders)
        : '-';
    final proxyProvidersText = status != null
        ? _formatCount(status.proxyProviders)
        : '-';
    final geodataUseText = status?.geodataUse ?? 'None';

    final ringItems = [
      (appLocalizations.rulesCount, status?.rules),
      (appLocalizations.proxiesCount, status?.proxies),
      (appLocalizations.proxyGroupsCount, status?.proxyGroups),
    ];

    final metricItems = <_MetricItem>[
      if ((status?.ruleProviders ?? 0) > 0)
        _MetricItem(
          icon: Icons.library_books_rounded,
          label: appLocalizations.ruleProvidersCount,
          value: ruleProvidersText,
        ),
      if ((status?.proxyProviders ?? 0) > 0)
        _MetricItem(
          icon: Icons.cloud_sync_rounded,
          label: appLocalizations.proxyProvidersCount,
          value: proxyProvidersText,
        ),
      _MetricItem(
        icon: Icons.travel_explore_rounded,
        color: context.colorScheme.secondary,
        label: appLocalizations.geodataUse,
        value: geodataUseText,
        valueChild: _buildGeodataChips(geodataUseText),
      ),
    ];

    return CommonDialog(
      title: appLocalizations.coreStatus,
      titleTrailing: CleanButton(
        tooltip: appLocalizations.forceGCTitle,
        onClean: _handleForceGc,
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      actions: isInBottomSheet(context)
          ? null
          : [
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Text(appLocalizations.confirm),
              ),
            ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(appLocalizations.memoryAndRuntime),
          _buildMemoryCard(
            inUse: inUse,
            reclaimable: reclaimable,
            physical: physical,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  icon: Icons.alt_route_rounded,
                  iconColor: context.colorScheme.primary,
                  label: appLocalizations.activeGoroutines,
                  value: goroutinesText,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatCard(
                  icon: Icons.layers_rounded,
                  iconColor: context.colorScheme.tertiary,
                  label: appLocalizations.heapObjects,
                  value: heapObjectsText,
                ),
              ),
            ],
          ),
          _buildSectionHeader(appLocalizations.profileAndRules),
          _buildRingCard(ringItems),
          const SizedBox(height: 8),
          _buildMetricGrid(metricItems),
        ],
      ),
    );
  }
}

class _MetricItem {
  final IconData icon;
  final Color? color;
  final String label;
  final String value;
  final Widget? valueChild;

  const _MetricItem({
    required this.icon,
    this.color,
    required this.label,
    required this.value,
    this.valueChild,
  });
}
