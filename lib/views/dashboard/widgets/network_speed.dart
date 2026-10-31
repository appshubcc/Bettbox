import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/app.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/pages/speed_test.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tile.dart';

class NetworkSpeed extends ConsumerWidget {
  final DashboardTileSize? size;

  const NetworkSpeed({super.key, this.size});

  // Cache as const
  static const _initPoints = [Point(0, 0), Point(1, 0)];

  static List<Point> _getPoints(List<Traffic> traffics) {
    if (traffics.isEmpty) return _initPoints;
    final count = traffics.length;
    return List<Point>.generate(count + 2, (index) {
      if (index == 0) return _initPoints[0];
      if (index == 1) return _initPoints[1];
      return Point(index.toDouble(), traffics[index - 2].speed.toDouble());
    }, growable: false);
  }

  static Traffic _getLastTraffic(List<Traffic> traffics) {
    if (traffics.isEmpty) return Traffic();
    return traffics.last;
  }

  Widget _speedValue(
    BuildContext context,
    IconData icon,
    TrafficValue value, {
    required bool primary,
  }) {
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          icon,
          size: primary ? 16 : 14,
          color: primary ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        Text(
          value.showValue,
          style: primary
              ? context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                )
              : context.textTheme.titleSmall?.copyWith(
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
        ),
        const SizedBox(width: 3),
        Text(
          '${value.showUnit}/s',
          style: context.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context,
    WidgetRef ref,
    DashboardTileSize size,
  ) {
    final isTall = size == DashboardTileSize.tall;
    final primaryColor = context.colorScheme.primary;
    return DashboardTileCard(
      size: size,
      info: Info(
        label: appLocalizations.networkSpeed,
        iconData: ReIcons.speedometer,
      ),
      mark: DashboardDecor.icon(context, ReIcons.speedometer, 80),
      markAngle: -0.2,
      onPressed: () => BaseNavigator.push(context, const SpeedTestPage()),
      child: RepaintBoundary(
        child: ValueListenableBuilder<int>(
          valueListenable: dashboardRefreshManager.tick1s,
          builder: (_, _, _) {
            final traffics = ref.read(trafficsProvider).list;
            final points = _getPoints(traffics);
            final traffic = _getLastTraffic(traffics);
            final down = _speedValue(
              context,
              ReIcons.arrowDown,
              traffic.down,
              primary: true,
            );
            final up = _speedValue(
              context,
              ReIcons.arrowUp,
              traffic.up,
              primary: false,
            );
            final chart = LineChart(
              gradient: true,
              color: primaryColor,
              points: points,
            );
            if (isTall) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [down, const SizedBox(height: 6), up],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: chart),
                ],
              );
            }
            return LayoutBuilder(
              builder: (_, box) => Stack(
                children: [
                  PositionedDirectional(
                    end: 0,
                    bottom: 0,
                    width: box.maxWidth * 0.42,
                    height: box.maxHeight * 0.85,
                    child: chart,
                  ),
                  PositionedDirectional(
                    start: 16,
                    bottom: 14,
                    width: box.maxWidth * 0.58 - 24,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [down, const SizedBox(width: 14), up],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = this.size;
    if (size != null) return _buildTile(context, ref, size);
    final color = context.colorScheme.onSurfaceVariant.opacity80;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: getWidgetHeight(context, 2),
      child: CommonCard(
        onPressed: () => BaseNavigator.push(context, const SpeedTestPage()),
        info: Info(
          label: appLocalizations.networkSpeed,
          iconData: ReIcons.speedometer,
        ),
        child: RepaintBoundary(
          child: ValueListenableBuilder<int>(
            valueListenable: dashboardRefreshManager.tick1s,
            builder: (_, _, _) {
              final traffics = ref.read(trafficsProvider).list;
              final points = _getPoints(traffics);
              final speedText = _getLastTraffic(traffics).toSpeedText();
              return Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 0,
                        right: 0,
                        bottom: 0,
                      ),
                      child: LineChart(
                        gradient: true,
                        color: primaryColor,
                        points: points,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Transform.translate(
                      offset: const Offset(-16, -20),
                      child: Text(
                        speedText,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: color,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
