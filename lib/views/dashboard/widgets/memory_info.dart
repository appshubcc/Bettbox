import 'dart:async';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/common.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

import 'core_status_dialog.dart';
import 'tile.dart';

class MemoryInfo extends StatefulWidget {
  final DashboardTileSize? size;

  const MemoryInfo({super.key, this.size});

  @override
  State<MemoryInfo> createState() => _MemoryInfoState();
}

class _MemoryInfoState extends State<MemoryInfo> {
  late final VoidCallback _tickListener;
  // Cache last memory value to avoid showing 0 on rebuild
  static TrafficValue _lastMemoryValue = TrafficValue(value: 0);
  static final List<double> _history = [];
  static const _averageWindow = Duration(minutes: 10);
  static final List<(DateTime, int)> _samples = [];
  TrafficValue _memoryValue = _lastMemoryValue;
  Timer? _initTimer;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _tickListener = _updateMemory;
    dashboardRefreshManager.tick2s.addListener(_tickListener);

    // Get immediately on first open, otherwise delay 1000ms
    if (_lastMemoryValue.value == 0) {
      _retryUpdateMemory();
    } else {
      // Has cached value, delay
      _initTimer = Timer(const Duration(milliseconds: 1000), _updateMemory);
    }
  }

  Future<void> _retryUpdateMemory() async {
    for (int i = 0; i < 5; i++) {
      if (!mounted) return;
      await _updateMemory();
      if (_memoryValue.value > 0) break;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    dashboardRefreshManager.tick2s.removeListener(_tickListener);
    super.dispose();
  }

  Future<void> _updateMemory() async {
    if (!mounted) return;
    if (_isUpdating) return;
    _isUpdating = true;

    try {
      final memoryValue = await clashCore.getMemory();
      // Update only if valid (non-zero)
      if (memoryValue > 0) {
        final adjustedValue = memoryValue;

        if (mounted) {
          pushDashboardSample(_history, adjustedValue.toDouble(), max: 30);
          _recordSample(adjustedValue);
          setState(() {
            _memoryValue = TrafficValue(value: adjustedValue);
            _lastMemoryValue = _memoryValue; // Cache latest valid value
          });
        }
      }
      // If 0, keep last valid value
    } catch (e) {
      // Ignore error, keep current value
    } finally {
      _isUpdating = false;
    }
  }

  static void _recordSample(int value) {
    final now = DateTime.now();
    _samples
      ..add((now, value))
      ..removeWhere((sample) => now.difference(sample.$1) > _averageWindow);
  }

  int get _average {
    final now = DateTime.now();
    final recent = [
      for (final (time, value) in _samples)
        if (now.difference(time) <= _averageWindow) value,
    ];
    if (recent.isEmpty) return _memoryValue.value;
    return recent.reduce((a, b) => a + b) ~/ recent.length;
  }

  Future<void> _showMemoryInfoDialog(BuildContext context) async {
    await globalState.showCommonDialog<void>(
      child: CommonDialog(
        title: appLocalizations.memoryInfo,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(appLocalizations.confirm),
          ),
        ],
        child: Text(appLocalizations.memoryInfoDesc),
      ),
    );
  }

  Widget _buildTile(BuildContext context, DashboardTileSize size) {
    final isTall = size == DashboardTileSize.tall;
    final colorScheme = context.colorScheme;
    final value = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          _memoryValue.showValue,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _memoryValue.showUnit,
          style: context.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
    final peak = Text(
      appLocalizations.dashboardAverage(TrafficValue(value: _average).show),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
    return DashboardTileCard(
      size: size,
      info: Info(label: appLocalizations.memoryInfo, iconData: Icons.memory),
      mark: DashboardDecor.icon(context, Icons.memory, 80),
      markAngle: 0.28,
      onPressed: () => showCoreStatusDialog(context),
      actions: [
        SizedBox.square(
          dimension: 24,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showMemoryInfoDialog(context),
            icon: Icon(
              size: 16.ap,
              Icons.info_outline,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
      child: isTall
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  value,
                  const SizedBox(height: 4),
                  peak,
                  const SizedBox(height: 12),
                  Expanded(child: DashboardTrendLine(values: _history)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 72, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        value,
                        const SizedBox(width: 10),
                        Flexible(child: peak),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 96,
                    height: 28,
                    child: DashboardTrendLine(values: _history),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.size case final size?) return _buildTile(context, size);
    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: CommonCard(
        onPressed: () => showCoreStatusDialog(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: globalState.measure.titleMediumHeight + 16,
              padding: baseInfoEdgeInsets.copyWith(bottom: 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.memory,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 1,
                    child: TooltipText(
                      text: Text(
                        appLocalizations.memoryInfo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  AspectRatio(
                    aspectRatio: 1,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showMemoryInfoDialog(context),
                      icon: Icon(
                        size: 16.ap,
                        Icons.info_outline,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: baseInfoEdgeInsets.copyWith(top: 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: globalState.measure.bodyMediumHeight + 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          _memoryValue.showValue,
                          style: context.textTheme.bodyMedium?.toLight
                              .adjustSize(1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _memoryValue.showUnit,
                          style: context.textTheme.bodyMedium?.toLight
                              .adjustSize(1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
