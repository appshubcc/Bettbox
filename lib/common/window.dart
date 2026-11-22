import 'dart:io';
import 'dart:math' as math;

import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_ext/window_ext.dart';
import 'package:window_manager/window_manager.dart';

class Window {
  Future<void> init() async {
    final props = globalState.config.windowProps;
    if (system.isWindows && !appPath.isPortable) {
      protocol.register('clash');
      protocol.register('clashmeta');
      protocol.register('flclash');
      protocol.register('bettbox');
    }
    await windowManager.ensureInitialized();
    if (system.isMacOS && !globalState.config.appSetting.keepDockIcon) {
      try {
        await windowExtManager.setDockIconVisible(false);
      } catch (e) {
        commonPrint.warn('Apply dock icon failed: $e', module: 'System');
      }
    }
    const minimumSize = Size(372, 492);
    WindowOptions windowOptions = WindowOptions(
      size: Size(props.width, math.max(props.height, minimumSize.height)),
      minimumSize: minimumSize,
    );
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setAlwaysOnTop(props.isPinned);
    if (!system.isMacOS) {
      final left = props.left;
      final top = props.top;
      if (left == null || top == null) {
        await windowManager.setAlignment(Alignment.center);
      } else {
        final savedDpr = props.scaleFactor;
        final currentDpr = windowManager.getDevicePixelRatio();

        final physLeft = left * savedDpr;
        final physTop = top * savedDpr;
        final physRight = physLeft + props.width * savedDpr;
        final physBottom = physTop + props.height * savedDpr;

        bool isPositionValid = false;
        try {
          final displays = await screenRetriever.getAllDisplays();
          isPositionValid = displays.any((display) {
            final pos = display.visiblePosition;
            if (pos == null) return false;
            final sf = (display.scaleFactor ?? 1.0).toDouble();
            final physDisplayBounds = Rect.fromLTWH(
              pos.dx * sf,
              pos.dy * sf,
              display.size.width * sf,
              display.size.height * sf,
            );
            return physDisplayBounds.contains(Offset(physLeft, physTop)) ||
                physDisplayBounds.contains(Offset(physRight, physBottom));
          });
        } catch (_) {}
        if (isPositionValid) {
          await windowManager.setPosition(
            Offset(physLeft / currentDpr, physTop / currentDpr),
          );
        } else {
          await windowManager.setAlignment(Alignment.center);
        }
      }
    }
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setPreventClose(true);
    });
  }

  void updateMacOSBrightness(Brightness brightness) {}

  Future<void> show() async {
    globalState.handleForeground();
    render?.resume();
    if (await isMinimized) {
      await windowManager.restore();
    }
    await windowManager.show();
    await windowManager.focus();
    if (!system.isMacOS) {
      await windowManager.setSkipTaskbar(false);
    }
    await _syncDockIcon(true);
    await globalState.resumeForegroundUpdates();
    await globalState.appController.syncWakelockIfNeeded();
  }

  Future<void> _syncDockIcon(bool visible) async {
    if (!system.isMacOS || globalState.config.appSetting.keepDockIcon) return;
    try {
      await windowExtManager.setDockIconVisible(visible);
    } catch (e) {
      commonPrint.warn('Sync dock icon failed: $e', module: 'System');
    }
  }

  Future<bool> get isVisible async {
    return await windowManager.isVisible();
  }

  Future<bool> get isMinimized async {
    return await windowManager.isMinimized();
  }

  Future<void> close() async {
    try {
      await trayManager.destroy();
      commonPrint.debug('Tray destroyed', module: 'System');
    } catch (e) {
      commonPrint.warn('Destroy tray failed: $e', module: 'System');
    }

    exit(0);
  }

  Future<void> hide() async {
    await windowManager.hide();
    if (!system.isMacOS) {
      await windowManager.setSkipTaskbar(true);
    }
    await _syncDockIcon(false);
    await globalState.handleBackground();
  }
}

final window = system.isDesktop ? Window() : null;
