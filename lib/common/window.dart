import 'dart:io';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

Future<String> get ssdPreferencePath async {
  final dir = await appPath.homeDirPath;
  return join(dir, 'prefer_ssd');
}

Future<bool> isServerSideDecorationEnabled() async {
  if (!system.isLinux) return false;
  try {
    final content = await File(await ssdPreferencePath).readAsString();
    return content.trim() == '1';
  } catch (_) {
    return false;
  }
}

bool _ssdEnabled = false;

bool get ssdEnabled => _ssdEnabled;

class Window {
  Future<void> init() async {
    final props = globalState.config.windowProps;
    if (system.isWindows) {
      protocol.register('clash');
      protocol.register('clashmeta');
      protocol.register('bettbox');
    }
    await windowManager.ensureInitialized();
    _ssdEnabled = await isServerSideDecorationEnabled();
    WindowOptions windowOptions = WindowOptions(
      size: Size(props.width, props.height),
      minimumSize: const Size(380, 400),
    );
    if (!_ssdEnabled) {
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    }
    await windowManager.setAlwaysOnTop(props.isPinned);
    if (!system.isMacOS) {
      final left = props.left;
      final top = props.top;
      if (left == null || top == null || (left == 0 && top == 0)) {
        await windowManager.setAlignment(Alignment.center);
      } else {
        bool isPositionValid = false;
        try {
          final displays = await screenRetriever.getAllDisplays();
          isPositionValid = displays.any((display) {
            final pos = display.visiblePosition;
            final size = display.visibleSize ?? display.size;
            if (pos == null) return false;
            return Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height)
                .contains(Offset(left, top));
          });
        } catch (_) {}
        if (isPositionValid) {
          await windowManager.setPosition(Offset(left, top));
        } else {
          await windowManager.setAlignment(Alignment.center);
        }
      }
    }
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setPreventClose(true);
    });
  }

  void updateMacOSBrightness(Brightness brightness) {
  }

  Future<void> show() async {
    globalState.handleForeground();
    render?.resume();
    await windowManager.show();
    await windowManager.focus();
    if (!system.isMacOS) {
      await windowManager.setSkipTaskbar(false);
    }
    await globalState.resumeForegroundUpdates();
    await globalState.appController.syncWakelockIfNeeded();
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
      commonPrint.log('The tray icon has been destroyed.');
    } catch (e) {
      commonPrint.log('Failed to destroy the tray icon: $e');
    }

    exit(0);
  }

  Future<void> hide() async {
    await windowManager.hide();
    if (!system.isMacOS) {
      await windowManager.setSkipTaskbar(true);
    }
    await globalState.handleBackground();
  }
}

final window = system.isDesktop ? Window() : null;