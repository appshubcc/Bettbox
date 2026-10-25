import 'dart:async';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/connection/connections.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

import 'tile.dart';

class ConnectionsCount extends StatefulWidget {
  final DashboardTileSize? size;

  const ConnectionsCount({super.key, this.size});

  @override
  State<ConnectionsCount> createState() => _ConnectionsCountState();
}

class _ConnectionsCountState extends State<ConnectionsCount> {
  static int? _lastCount;
  static int _lastTcp = 0;
  static int _lastUdp = 0;
  static final List<double> _history = [];
  int _count = _lastCount ?? 0;
  late final VoidCallback _tickListener;
  Timer? _initTimer;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _tickListener = _updateConnections;
    dashboardRefreshManager.tick2s.addListener(_tickListener);
    _initTimer = Timer(const Duration(milliseconds: 1000), _updateConnections);
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    dashboardRefreshManager.tick2s.removeListener(_tickListener);
    super.dispose();
  }

  Future<void> _updateConnections() async {
    if (!mounted) return;
    if (_isUpdating) return;
    _isUpdating = true;

    try {
      final summary = await clashCore.getConnectionsSummary();
      _lastCount = summary.total;
      _lastUdp = summary.udp;
      _lastTcp = summary.tcp;
      pushDashboardSample(_history, summary.total.toDouble());
      if (mounted) {
        setState(() {
          _count = summary.total;
        });
      }
    } catch (e) {
      // Ignore error, keep current value
    } finally {
      _isUpdating = false;
    }
  }

  void _openConnections() {
    showExtend(
      context,
      builder: (_, type) => const ConnectionsView(respectCurrentPage: false),
    );
  }

  Widget _buildTile(BuildContext context, DashboardTileSize size) {
    final isTall = size == DashboardTileSize.tall;
    final colorScheme = context.colorScheme;
    final count = Text(
      '$_count',
      style: context.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    final split = Text(
      'TCP $_lastTcp · UDP $_lastUdp',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
    return DashboardTileCard(
      size: size,
      info: Info(
        iconData: Icons.cable_rounded,
        label: appLocalizations.connection,
      ),
      mark: DashboardDecor.icon(context, Icons.cable_rounded, 80),
      markAngle: -0.32,
      onPressed: _openConnections,
      child: isTall
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  count,
                  const SizedBox(height: 4),
                  split,
                  const SizedBox(height: 12),
                  Expanded(
                    child: DashboardCapsules(values: _history, count: 12),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 72, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  count,
                  const SizedBox(width: 10),
                  Expanded(child: split),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 96,
                    height: 28,
                    child: DashboardCapsules(values: _history, count: 10),
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
        info: Info(
          iconData: Icons.cable_rounded,
          label: appLocalizations.connection,
        ),
        onPressed: () {
          showExtend(
            context,
            builder: (_, type) {
              return const ConnectionsView(respectCurrentPage: false);
            },
          );
        },
        child: Container(
          padding: baseInfoEdgeInsets.copyWith(top: 0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$_count',
                  style: context.textTheme.bodyLarge?.toLight.adjustSize(2),
                ),
                const SizedBox(width: 4),
                Text(
                  ' Connections',
                  style: context.textTheme.bodyMedium?.toLight.adjustSize(0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
