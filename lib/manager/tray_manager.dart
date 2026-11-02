import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/providers/state.dart';
import 'package:bett_box/state.dart';
import 'package:material_ui/material_ui.dart';
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
    if (system.isWindows) {
      if (isRightClick) {
        // ignore: deprecated_member_use
        await trayManager.popUpContextMenu(bringAppToFront: true);
      } else {
        window?.show();
      }
      return;
    }
    if (system.isLinux) {
      if (!isRightClick) {
        window?.show();
      }
      return;
    }
    final vpnProps = ref.read(vpnSettingProvider);
    final showHiddenItems = ref.read(
      proxiesStyleSettingProvider.select((state) => state.showHiddenItems),
    );
    if (trayManager.isOptionPressed &&
        vpnProps.trayEnhancement &&
        !showHiddenItems) {
      tray.showHiddenGroups = true;
      await globalState.appController.updateTray(false, false, true);
      await trayManager.popUpContextMenu();
      return;
    }
    final behavior = isRightClick
        ? vpnProps.trayRightClickBehavior
        : vpnProps.trayLeftClickBehavior;
    if (behavior == TrayClickBehavior.showMenu) {
      // ignore: deprecated_member_use
      await trayManager.popUpContextMenu(bringAppToFront: true);
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
    if (menuItem.submenu != null || trayManager.isMenuOpen) return;
    if (globalState.backgroundMode.value) {
      globalState.appController.updateTray(false, false, true);
    }
  }

  @override
  void onTrayMenuClose() {
    if (trayManager.isMenuOpen) return;
    if (tray.showHiddenGroups) {
      tray.showHiddenGroups = false;
      globalState.appController.updateTray(false, false, true);
      return;
    }
    if (trayManager.isMenuOutdated) {
      globalState.appController.updateTray();
    }
  }

  @override
  dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }
}
