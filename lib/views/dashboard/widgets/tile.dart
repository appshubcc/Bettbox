import 'dart:math' as math;

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'connections_count.dart';
import 'intranet_ip.dart';
import 'memory_info.dart';
import 'network_detection.dart';
import 'network_speed.dart';
import 'profile_info.dart';
import 'start_button.dart';
import 'toolbox_shortcut.dart';
import 'traffic_usage.dart';

typedef DashboardTile = ({DashboardWidget widget, DashboardTileSize size});

DashboardTileSize resolveDashboardSize(
  DashboardWidget widget,
  Map<String, String> sizes,
) {
  final saved = sizes[widget.family.name];
  if (saved == null || widget != widget.family) return widget.nativeSize;
  final size = DashboardTileSize.values.where((item) => item.name == saved);
  if (size.isEmpty || !widget.sizes.contains(size.first)) {
    return widget.nativeSize;
  }
  return size.first;
}

Widget buildDashboardTile(DashboardTile tile) {
  final widget = tile.widget;
  final size = tile.size;
  if (size == widget.nativeSize) return widget.widget.child;
  final variant = widget.variants.where((item) => item.nativeSize == size);
  if (variant.isNotEmpty) return variant.first.widget.child;
  return switch (widget.family) {
    DashboardWidget.networkSpeed => NetworkSpeed(size: size),
    DashboardWidget.trafficUsage => TrafficUsage(size: size),
    DashboardWidget.profileInfo => ProfileInfo(size: size),
    DashboardWidget.networkDetection => NetworkDetection(size: size),
    DashboardWidget.intranetIp => IntranetIP(size: size),
    DashboardWidget.memoryInfo => MemoryInfo(size: size),
    DashboardWidget.connectionsCount => ConnectionsCount(size: size),
    DashboardWidget.startButton => StartButton(size: size),
    DashboardWidget.toolboxShortcut => ToolboxShortcut(size: size),
    _ => widget.widget.child,
  };
}

class DashboardDecor extends StatelessWidget {
  final Widget mark;
  final bool bottom;
  final double angle;
  final double size;
  final Widget child;

  const DashboardDecor({
    super.key,
    required this.mark,
    required this.child,
    this.bottom = false,
    this.angle = 0,
    this.size = 80,
  });

  static Widget icon(BuildContext context, IconData icon, double size) => Icon(
    icon,
    size: size,
    color: context.colorScheme.onSurface.withValues(alpha: 0.06),
  );

  static Widget flag(String countryCode, double size) => Opacity(
    opacity: 0.14,
    child: ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        0.33,
        0.33,
        0.33,
        0,
        0,
        0.33,
        0.33,
        0.33,
        0,
        0,
        0.33,
        0.33,
        0.33,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: Text(
        utils.countryCodeToEmoji(countryCode),
        style: TextStyle(
          fontFamily: FontFamily.twEmoji.value,
          fontFamilyFallback: [FontFamily.twEmoji.value],
          fontSize: size * 0.86,
          height: 1,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final offset = -size * 0.17;
    return Stack(
      children: [
        PositionedDirectional(
          end: offset,
          top: bottom ? null : offset,
          bottom: bottom ? offset : null,
          child: IgnorePointer(
            child: Transform.rotate(angle: angle, child: mark),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class DashboardTileCard extends StatelessWidget {
  final DashboardTileSize size;
  final Info info;
  final Widget? mark;
  final bool markBottom;
  final double markAngle;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final List<Widget> actions;
  final Widget child;

  const DashboardTileCard({
    super.key,
    required this.size,
    required this.info,
    required this.child,
    this.mark,
    this.markBottom = false,
    this.markAngle = 0,
    this.onPressed,
    this.onLongPress,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final mark = this.mark;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoHeader(
          info: info,
          actions: actions,
          padding: baseInfoEdgeInsets.copyWith(bottom: 0),
        ),
        Expanded(child: child),
      ],
    );
    return SizedBox(
      height: getWidgetHeight(context, size.rows),
      child: CommonCard(
        onPressed: onPressed,
        onLongPress: onLongPress,
        child: mark == null
            ? content
            : DashboardDecor(
                mark: mark,
                bottom: markBottom,
                angle: markAngle,
                child: content,
              ),
      ),
    );
  }
}

class DashboardCapsules extends StatelessWidget {
  final List<double> values;
  final int count;

  const DashboardCapsules({
    super.key,
    required this.values,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    final maxValue = values.fold<double>(0, math.max);
    final data = [
      for (var i = values.length; i < count; i++) 0.0,
      ...values.skip(math.max(0, values.length - count)),
    ];
    return LayoutBuilder(
      builder: (_, box) {
        const width = 6.0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (index, value) in data.indexed)
              AnimatedContainer(
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                width: width,
                height: math.max(
                  width,
                  maxValue <= 0 ? width : box.maxHeight * value / maxValue,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width),
                  color: index == data.length - 1
                      ? primary
                      : primary.withValues(alpha: 0.12 + 0.3 * index / count),
                ),
              ),
          ],
        );
      },
    );
  }
}

class DashboardTrendLine extends StatelessWidget {
  final List<double> values;

  const DashboardTrendLine({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _TrendLinePainter(
          values: List.of(values),
          color: context.colorScheme.primary,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _TrendLinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.isEmpty) return;
    final data = values.length == 1 ? [values.first, values.first] : values;
    final low = data.reduce(math.min);
    final high = data.reduce(math.max);
    final span = high - low;
    final bottom = span > 0 ? math.max(0.0, low - span * 1.2) : 0.0;
    final top = span > 0 ? high + span * 0.15 : high * 1.6;
    final range = top - bottom;
    const inset = 1.0;
    final height = size.height - inset * 2;
    double mapY(double value) => range <= 0
        ? size.height / 2
        : inset + (1 - (value - bottom) / range) * height;
    final step = size.width / (data.length - 1);
    final line = Path()..moveTo(0, mapY(data.first));
    for (var i = 1; i < data.length; i++) {
      line.lineTo(step * i, mapY(data[i]));
    }
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(area, Paint()..color = color.withValues(alpha: 0.08));
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TrendLinePainter oldDelegate) =>
      oldDelegate.color != color || !listEquals(oldDelegate.values, values);
}

class DashboardChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const DashboardChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(color: primary),
            ),
          ),
        ],
      ),
    );
  }
}

void pushDashboardSample(List<double> history, double value, {int max = 12}) {
  history.add(value);
  if (history.length > max) history.removeAt(0);
}
