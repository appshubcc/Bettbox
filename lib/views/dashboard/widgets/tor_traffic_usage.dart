import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/plugins/tor.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';

class TorTrafficUsage extends StatefulWidget {
  const TorTrafficUsage({super.key});

  @override
  State<TorTrafficUsage> createState() => _TorTrafficUsageState();
}

class _TorTrafficUsageState extends State<TorTrafficUsage> {
  static const _tor = TorControl();
  static Traffic _lastTraffic = Traffic();

  late final VoidCallback _tickListener;
  Traffic _traffic = _lastTraffic;
  bool _isUpdating = false;
  Timer? _initTimer;

  @override
  void initState() {
    super.initState();
    _tickListener = _updateTraffic;
    dashboardRefreshManager.tick1s.addListener(_tickListener);
    _initTimer = Timer(const Duration(milliseconds: 300), _updateTraffic);
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    dashboardRefreshManager.tick1s.removeListener(_tickListener);
    super.dispose();
  }

  Future<void> _updateTraffic() async {
    if (!mounted || _isUpdating) return;
    _isUpdating = true;
    try {
      final traffic = await _tor.traffic();
      if (!mounted) return;
      setState(() {
        _traffic = traffic;
        _lastTraffic = traffic;
      });
    } catch (_) {
      // Keep the latest valid value while Tor is starting or stopped.
    } finally {
      _isUpdating = false;
    }
  }

  Widget _buildTrafficLine({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required TrafficValue value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value.showValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.toLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(value.showUnit, style: context.textTheme.bodySmall?.toLight),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final upColor = globalState.theme.darken3PrimaryContainer;
    final downColor = globalState.theme.darken2SecondaryContainer;

    return SizedBox(
      height: getWidgetHeight(1),
      child: CommonCard(
        onPressed: _updateTraffic,
        child: Padding(
          padding: baseInfoEdgeInsets.copyWith(top: 10, bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.donut_large,
                    size: 18,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TooltipText(
                      text: Text(
                        'Tor 流量',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _buildTrafficLine(
                context: context,
                icon: Icons.arrow_upward,
                color: upColor,
                value: _traffic.up,
              ),
              _buildTrafficLine(
                context: context,
                icon: Icons.arrow_downward,
                color: downColor,
                value: _traffic.down,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
