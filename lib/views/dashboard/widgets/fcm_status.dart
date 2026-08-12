import 'dart:async';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';

class FcmStatusData {
  final int? minutes;
  final bool isConnected;

  const FcmStatusData({this.minutes, required this.isConnected});
}

final _fcmStatusNotifier = ValueNotifier<FcmStatusData>(
  const FcmStatusData(isConnected: false),
);

class FcmStatus extends StatefulWidget {
  const FcmStatus({super.key});

  @override
  State<FcmStatus> createState() => _FcmStatusState();
}

class _FcmStatusState extends State<FcmStatus> {
  late final VoidCallback _tickListener;
  Timer? _initTimer;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _tickListener = _updateFcmStatus;
    dashboardRefreshManager.tick5s.addListener(_tickListener);
    _initTimer = Timer(const Duration(milliseconds: 1000), _updateFcmStatus);
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    dashboardRefreshManager.tick5s.removeListener(_tickListener);
    super.dispose();
  }

  Future<void> _updateFcmStatus() async {
    if (!mounted) return;
    if (_isUpdating) return;
    _isUpdating = true;

    try {
      final connections = await clashCore.getConnections();

      final fcmConnections = connections.where((conn) {
        final host = conn.metadata.host.toLowerCase();
        final port = conn.metadata.destinationPort;
        return host.contains('google.com') &&
            (port == '5228' || port == '5229' || port == '5230');
      }).toList();

      if (fcmConnections.isEmpty) {
        _fcmStatusNotifier.value = const FcmStatusData(isConnected: false);
      } else {
        final longestConnection = fcmConnections.reduce(
          (a, b) => a.start.isBefore(b.start) ? a : b,
        );
        final duration = DateTime.now().difference(longestConnection.start);
        final minutes = duration.inMinutes;
        _fcmStatusNotifier.value = FcmStatusData(
          minutes: minutes,
          isConnected: true,
        );
      }
    } catch (e) {
      // Ignore error, keep current value
    } finally {
      _isUpdating = false;
    }
  }

  Future<void> _showFcmInfoDialog(BuildContext context) async {
    await globalState.showCommonDialog<void>(
      child: CommonDialog(
        title: 'FCM',
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(appLocalizations.confirm),
          ),
        ],
        child: Text(appLocalizations.fcmTip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: getWidgetHeight(1),
        child: CommonCard(
          onLongPress: system.isAndroid ? () => app.openFcmDiagnostics() : null,
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
                      Icons.cloud_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 1,
                      child: TooltipText(
                        text: Text(
                          'FCM',
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
                        onPressed: () => _showFcmInfoDialog(context),
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
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: ValueListenableBuilder<FcmStatusData>(
                    valueListenable: _fcmStatusNotifier,
                    builder: (_, status, _) {
                      if (status.isConnected && status.minutes != null) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${status.minutes}',
                              style: context.textTheme.bodyLarge?.toLight
                                  .adjustSize(2),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ' Minutes',
                              style: context.textTheme.bodyMedium?.toLight
                                  .adjustSize(0),
                            ),
                          ],
                        );
                      } else {
                        return Text(
                          appLocalizations.noStatusAvailable,
                          style: context.textTheme.bodyMedium?.toLight.adjustSize(
                            0,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
