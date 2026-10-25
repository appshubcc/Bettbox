import 'dart:math';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/toolbox/traffic_stats.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tile.dart';

class TrafficUsage extends ConsumerStatefulWidget {
  final DashboardTileSize? size;

  const TrafficUsage({super.key, this.size});

  @override
  ConsumerState<TrafficUsage> createState() => _TrafficUsageState();
}

class _TrafficUsageState extends ConsumerState<TrafficUsage> {
  final _donutKey = GlobalKey<DonutChartState>();
  // cache text measurement results
  Size? _uploadTextSize;
  Size? _downloadTextSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // dependency changes when clear cache
    _uploadTextSize = null;
    _downloadTextSize = null;
  }

  Size _getUploadTextSize(BuildContext context) {
    return _uploadTextSize ??= globalState.measure.computeTextSize(
      Text(
        appLocalizations.upload,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodySmall,
      ),
    );
  }

  Size _getDownloadTextSize(BuildContext context) {
    return _downloadTextSize ??= globalState.measure.computeTextSize(
      Text(
        appLocalizations.download,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodySmall,
      ),
    );
  }

  Widget _buildTrafficDataItem(
    BuildContext context,
    Icon icon,
    TrafficValue trafficValue,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          flex: 1,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              icon,
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: Text(
                  trafficValue.showValue,
                  style: context.textTheme.bodySmall,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        Text(
          trafficValue.showUnit,
          style: context.textTheme.bodySmall?.toLighter,
        ),
      ],
    );
  }

  Widget _legend(BuildContext context, Color color, String label, String v) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            v,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWide(BuildContext context, DashboardTileSize size) {
    final primaryColor = globalState.theme.darken3PrimaryContainer;
    final secondaryColor = globalState.theme.darken2SecondaryContainer;
    return SizedBox(
      height: getWidgetHeight(context, size.rows),
      child: CommonCard(
        onPressed: () => BaseNavigator.push(context, const TrafficStatsPage()),
        child: DashboardDecor(
          mark: DashboardDecor.icon(context, Icons.data_saver_off, 80),
          bottom: true,
          angle: 0.12,
          child: ValueListenableBuilder<int>(
            valueListenable: dashboardRefreshManager.tick1s,
            builder: (_, _, _) {
              final totalTraffic = ref.read(totalTrafficProvider);
              final up = totalTraffic.up;
              final down = totalTraffic.down;
              final total = TrafficValue(value: up.value + down.value);
              return Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 72, 10),
                child: Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: DonutChart(
                        key: _donutKey,
                        trackColor: context.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.35),
                        data: [
                          DonutChartData(
                            value: up.value.toDouble(),
                            color: primaryColor,
                          ),
                          DonutChartData(
                            value: down.value.toDouble(),
                            color: secondaryColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _legend(
                            context,
                            primaryColor,
                            appLocalizations.upload,
                            up.show,
                          ),
                          _legend(
                            context,
                            secondaryColor,
                            appLocalizations.download,
                            down.show,
                          ),
                          _legend(
                            context,
                            context.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.4,
                            ),
                            appLocalizations.dashboardTotal,
                            total.show,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PageLabel>(currentPageLabelProvider, (prev, next) {
      if (next == PageLabel.dashboard && prev != PageLabel.dashboard) {
        _donutKey.currentState?.replayEntryAnimation();
      }
    });

    if (widget.size case final size?) return _buildWide(context, size);
    final primaryColor = globalState.theme.darken3PrimaryContainer;
    final secondaryColor = globalState.theme.darken2SecondaryContainer;
    return SizedBox(
      height: getWidgetHeight(context, 2),
      child: CommonCard(
        info: Info(
          label: appLocalizations.trafficUsage,
          iconData: Icons.data_saver_off,
        ),
        onPressed: () => BaseNavigator.push(context, const TrafficStatsPage()),
        child: ValueListenableBuilder<int>(
          valueListenable: dashboardRefreshManager.tick1s,
          builder: (_, _, _) {
            final totalTraffic = ref.read(totalTrafficProvider);
            final upTotalTrafficValue = totalTraffic.up;
            final downTotalTrafficValue = totalTraffic.down;
            return Padding(
              padding: baseInfoEdgeInsets.copyWith(top: 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: DonutChart(
                              key: _donutKey,
                              trackColor: context
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.35),
                              data: [
                                DonutChartData(
                                  value: upTotalTrafficValue.value.toDouble(),
                                  color: primaryColor,
                                ),
                                DonutChartData(
                                  value: downTotalTrafficValue.value.toDouble(),
                                  color: secondaryColor,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: LayoutBuilder(
                              builder: (_, container) {
                                final uploadTextSize = _getUploadTextSize(
                                  context,
                                );
                                final downloadTextSize = _getDownloadTextSize(
                                  context,
                                );
                                final maxTextWidth = max(
                                  uploadTextSize.width,
                                  downloadTextSize.width,
                                );
                                if (maxTextWidth + 24 > container.maxWidth) {
                                  return Container();
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          maxLines: 1,
                                          appLocalizations.upload,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: secondaryColor,
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          maxLines: 1,
                                          appLocalizations.download,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildTrafficDataItem(
                    context,
                    Icon(Icons.arrow_upward, color: primaryColor, size: 14),
                    upTotalTrafficValue,
                  ),
                  const SizedBox(height: 8),
                  _buildTrafficDataItem(
                    context,
                    Icon(Icons.arrow_downward, color: secondaryColor, size: 14),
                    downTotalTrafficValue,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
