import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_ext/window_ext.dart';

/// 处理 Windows WM_POWERBROADCAST 休眠/唤醒事件。
///
/// 系统休眠时若 VPN/TUN 正在运行，先停止以释放 Wintun 句柄；
/// 唤醒后延迟恢复，等待物理网卡和 Wintun 状态稳定。
class PowerManager extends ConsumerStatefulWidget {
  final Widget child;

  const PowerManager({super.key, required this.child});

  @override
  ConsumerState<PowerManager> createState() => _PowerManagerState();
}

class _PowerManagerState extends ConsumerState<PowerManager>
    with WindowExtListener {
  bool _wasVpnRunningBeforeSuspend = false;
  bool _suspendStopCompleted = false;
  Future<void> _powerTransition = Future.value();
  Timer? _resumeTimer;

  @override
  void initState() {
    super.initState();
    windowExtManager.addListener(this);
  }

  @override
  void onPowerSuspend() {
    _resumeTimer?.cancel();
    _resumeTimer = null;

    _enqueuePowerTransition(() async {
      _wasVpnRunningBeforeSuspend = globalState.isStart;
      _suspendStopCompleted = false;

      if (!_wasVpnRunningBeforeSuspend) {
        commonPrint.log('System Suspend: VPN not running, nothing to stop.');
        return;
      }

      commonPrint.log(
        'System Suspend: VPN running, stopping to release driver handles...',
      );

      try {
        await globalState.appController.updateStatus(false);
        _suspendStopCompleted = true;
        commonPrint.log('System Suspend: VPN stopped.');
      } catch (e) {
        commonPrint.log('System Suspend: stop VPN failed: $e');
      }
    });

    super.onPowerSuspend();
  }

  @override
  void onPowerResume() {
    _resumeTimer?.cancel();

    if (!_wasVpnRunningBeforeSuspend) {
      commonPrint.log('System Resume: VPN was not active before suspend.');
      super.onPowerResume();
      return;
    }

    commonPrint.log('System Resume: VPN was active, restarting in 3s...');

    _resumeTimer = Timer(const Duration(seconds: 3), () {
      _enqueuePowerTransition(() async {
        if (!mounted) return;

        if (!_suspendStopCompleted) {
          commonPrint.log(
            'System Resume: previous suspend stop did not complete, retrying clean stop...',
          );
          try {
            await globalState.appController.updateStatus(false);
          } catch (e) {
            commonPrint.log('System Resume: cleanup stop failed: $e');
          }
        }

        if (globalState.isStart) {
          _wasVpnRunningBeforeSuspend = false;
          _suspendStopCompleted = false;
          commonPrint.log('System Resume: VPN already running, skip restart.');
          return;
        }

        try {
          await globalState.appController.updateStatus(true);
          commonPrint.log('System Resume: VPN restarted.');
        } catch (e) {
          commonPrint.log('System Resume: restart VPN failed: $e');
        } finally {
          _wasVpnRunningBeforeSuspend = false;
          _suspendStopCompleted = false;
        }
      });
    });

    super.onPowerResume();
  }

  void _enqueuePowerTransition(Future<void> Function() action) {
    _powerTransition = _powerTransition.then((_) => action()).catchError((e) {
      commonPrint.log('Power transition error: $e');
    });
  }

  @override
  void dispose() {
    _resumeTimer?.cancel();
    windowExtManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
