import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/providers/config.dart';
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
    ref.listenManual(trayStateProvider, (prev, next) {
      if (prev != next) {
        globalState.appController.updateTray();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<void> _handleTrayIconClick({required bool isRightClick}) async {
    final trayState = ref.read(trayStateProvider);
    final showHiddenItems = ref.read(
      proxiesStyleSettingProvider.select((state) => state.showHiddenItems),
    );
    final includeHiddenItems =
        system.isMacOS && !showHiddenItems && trayManager.isOptionKeyPressed;
    final clickBehavior = isRightClick
        ? trayState.trayRightClickBehavior
        : trayState.trayLeftClickBehavior;
    if (includeHiddenItems || clickBehavior == TrayClickBehavior.showMenu) {
      await globalState.appController.showTrayMenu(
        includeHiddenItems: includeHiddenItems,
      );
      return;
    }
    window?.show();
  }

  @override
  void onTrayIconRightMouseDown() {
    unawaited(_handleTrayIconClick(isRightClick: true));
  }

  @override
  void onTrayIconMouseDown() {
    unawaited(_handleTrayIconClick(isRightClick: false));
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    // 该刷新仅用于兼容 Linux 后台托盘首次回调。macOS 会自行实时更新菜单，
    // 在这里重建菜单会与延迟测试的静默更新竞争。
    if (!system.isLinux || !globalState.backgroundMode.value) {
      return;
    }
    unawaited(globalState.appController.updateTray(false, false, true));
  }

  @override
  dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }
}
