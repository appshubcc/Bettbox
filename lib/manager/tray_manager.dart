import 'package:bett_box/common/common.dart';
import 'package:bett_box/providers/proxy_delay_provider.dart';
import 'package:bett_box/providers/state.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';

class TrayManager extends ConsumerStatefulWidget {
  final Widget child;

  const TrayManager({super.key, required this.child});

  @override
  ConsumerState<TrayManager> createState() => _TrayContainerState();
}

class _TrayContainerState extends ConsumerState<TrayManager> with TrayListener {
  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);

    // trayState 变化（模式切换、节点切换等）：走 debounce 普通刷新
    ref.listenManual(trayStateProvider, (prev, next) {
      if (prev != next) globalState.appController.updateTray(false);
    });

    // 测速状态/结果变化：
    // testing 状态变化 → 立即刷新（跳过 debounce），确保下次打开菜单即见"测速中..."
    // done 状态变化   → 走 debounce 正常刷新
    ref.listenManual(proxyDelayNotifierProvider, (prev, next) {
      if (prev == next) return;

      final hasNewTesting = next.entries.any(
        (e) => e.value.testState == DelayTestState.testing && prev?[e.key]?.testState != DelayTestState.testing,
      );

      globalState.appController.updateTray(hasNewTesting);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void onTrayIconRightMouseDown() {
    // ignore: deprecated_member_use
    trayManager.popUpContextMenu(bringAppToFront: true);
  }

  @override
  void onTrayIconMouseDown() {
    window?.show();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }
}
