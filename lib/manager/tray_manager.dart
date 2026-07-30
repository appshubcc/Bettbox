import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
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

  void _handleTrayIconClick() {
    final behavior = ref.read(trayStateProvider).trayClickBehavior;
    if (behavior == TrayClickBehavior.showMenu) {
      trayManager.popUpContextMenu();
      return;
    }
    window?.show();
  }

  @override
  void onTrayIconRightMouseDown() {
    _handleTrayIconClick();
  }

  @override
  void onTrayIconMouseDown() {
    _handleTrayIconClick();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (globalState.backgroundMode.value) {
      globalState.appController.updateTray(false, false, true);
    }
  }

  @override
  dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }
}
