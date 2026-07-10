import 'dart:async';
import 'dart:io';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/proxies/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:restart_app/restart_app.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'common.dart';

class Tray {
  Timer? _debounceTimer;
  TrayState? _pendingState;
  bool _isUpdating = false;
  bool _pendingFocus = false;
  bool _pendingSilent = false;

  static const _debounceDelay = Duration(milliseconds: 300);

  Timer? _loadingTimer;
  int _loadingFrame = 0;
  final List<String> _loadingFrames = ['.', '..', '...'];

  bool _isTesting = false;
  String? _testingGroupId;

  void dispose() {
    _debounceTimer?.cancel();
    _loadingTimer?.cancel();
  }
  Future _updateSystemTray({
    required Brightness? brightness,
    required bool isStart,
    bool force = false,
  }) async {
    if (system.isAndroid) {
      return;
    }
    if (force) {
      await trayManager.destroy();
    }
    await trayManager.setIcon(
      utils.getTrayIconPath(
        brightness:
            brightness ??
            WidgetsBinding.instance.platformDispatcher.platformBrightness,
        isStart: isStart,
        invertTrayIcon:
            system.isWindows && globalState.config.themeProps.invertTrayIcon,
      ),
      isTemplate: system.isMacOS,
    );
    if (!Platform.isLinux) {
      await trayManager.setToolTip(appName);
    }
  }

  Future<void> update({
    required TrayState trayState,
    bool focus = false,
    bool silent = false,
  }) async {
    if (system.isAndroid) {
      return;
    }

    _debounceTimer?.cancel();

    if (_isUpdating) {
      _pendingState = trayState;
      _pendingFocus = focus;
      _pendingSilent = silent;
      return;
    }

    if (focus) {
      await _doUpdate(trayState: trayState, focus: focus, silent: silent);
    } else if (silent) {
      _debounceTimer = Timer(const Duration(milliseconds: 50), () async {
        await _doUpdate(trayState: trayState, focus: focus, silent: silent);
      });
    } else {
      _debounceTimer = Timer(_debounceDelay, () async {
        await _doUpdate(trayState: trayState, focus: focus);
      });
    }
  }

  Future<void> _doUpdate({
    required TrayState trayState,
    bool focus = false,
    bool silent = false,
  }) async {
    if (_isUpdating) return;
    _isUpdating = true;

    try {
      if (!silent && !Platform.isLinux) {
        await _updateSystemTray(
          brightness: trayState.brightness,
          isStart: trayState.isStart,
          force: focus,
        );
      }
    List<MenuItem> menuItems = [];
    final showMenuItem = MenuItem(
      label: appLocalizations.show,
      onClick: (_) {
        window?.show();
      },
    );
    menuItems.add(showMenuItem);
    final startMenuItem = MenuItem.checkbox(
      label: trayState.isStart ? appLocalizations.stop : appLocalizations.start,
      onClick: (_) async {
        globalState.appController.updateStart();
      },
      checked: false,
    );
    menuItems.add(startMenuItem);
    menuItems.add(MenuItem.separator());
    for (final mode in Mode.values) {
      menuItems.add(
        MenuItem.checkbox(
          label: Intl.message(mode.name),
          onClick: (_) {
            globalState.appController.changeMode(mode);
          },
          checked: mode == trayState.mode,
        ),
      );
    }
    menuItems.add(MenuItem.separator());
    if (trayState.trayEnhancement) {
      for (final group in trayState.groups) {
        List<MenuItem> subMenuItems = [];

        final isTestingThisGroup = _isTesting && _testingGroupId == group.name;

        subMenuItems.add(
          MenuItem(
            label: isTestingThisGroup
                ? '⚡ ${appLocalizations.startTest}...'
                : '⚡ ${appLocalizations.startTest}',
            disabled: _isTesting,
            onClick: (_) => _testGroupDelay(group),
          ),
        );

        subMenuItems.add(MenuItem.separator());

        final proxies = globalState.appController.getSortProxies(
          proxies: group.all,
          sortType: globalState.config.proxiesStyle.sortType,
          testUrl: group.testUrl,
        );
        for (final proxy in proxies) {
          final delay = globalState.appController.getTrayProxyDelay(
            proxyName: proxy.name,
            testUrl: group.testUrl,
          );

          subMenuItems.add(
            MenuItem.checkbox(
              label: proxy.name,
              sublabel: _formatProxySublabel(delay),
              checked: group.getCurrentSelectedName(trayState.selectedMap[group.name] ?? '') == proxy.name,
              onClick: (_) {
                final appController = globalState.appController;
                appController.updateCurrentSelectedMap(group.name, proxy.name);
                appController.changeProxy(
                  groupName: group.name,
                  proxyName: proxy.name,
                );
              },
            ),
          );
        }
        menuItems.add(
          MenuItem.submenu(
            label: group.name,
            submenu: Menu(items: subMenuItems),
          ),
        );
      }
      if (trayState.groups.isNotEmpty) {
        menuItems.add(MenuItem.separator());
      }
    }
    if (trayState.isStart) {
      menuItems.add(
        MenuItem.checkbox(
          label: appLocalizations.tun,
          onClick: (_) {
            globalState.appController.updateTun();
          },
          checked: trayState.tunEnable,
        ),
      );
      menuItems.add(
        MenuItem.checkbox(
          label: appLocalizations.systemProxy,
          onClick: (_) {
            globalState.appController.updateSystemProxy();
          },
          checked: trayState.systemProxy,
        ),
      );
      menuItems.add(MenuItem.separator());
    }
    final restartMenuItem = MenuItem(
      label: appLocalizations.restartApp,
      onClick: (_) async {
        await Restart.restartApp();
      },
    );
    menuItems.add(restartMenuItem);

    final List<MenuItem> moreMenuItems = [
      MenuItem.checkbox(
        label: appLocalizations.autoLaunch,
        onClick: (_) async {
          globalState.appController.updateAutoLaunch();
        },
        checked: trayState.autoLaunch,
      ),
      _buildCopyEnvSubmenu(trayState.port),
      MenuItem(
        label: appLocalizations.restartCoreTitle,
        onClick: (_) async {
          await globalState.appController.restartCore();
        },
      ),
    ];

    if (!system.isAndroid) {
      moreMenuItems.add(
        MenuItem.checkbox(
          label: appLocalizations.wakelock,
          onClick: (_) async {
            await _toggleWakelock(trayState.wakelockEnabled);
          },
          checked: trayState.wakelockEnabled,
        ),
      );
    }

    menuItems.add(
      MenuItem.submenu(
        label: appLocalizations.tools,
        submenu: Menu(items: moreMenuItems),
      ),
    );

    menuItems.add(MenuItem.separator());
    final exitMenuItem = MenuItem(
      label: appLocalizations.exit,
      onClick: (_) async {
        await globalState.appController.handleExit();
      },
    );
    menuItems.add(exitMenuItem);
    final menu = Menu(items: menuItems);
    await trayManager.setContextMenu(
      menu,
      keepMenuOpen: silent,
      brightness: trayState.brightness,
    );
    if (Platform.isLinux) {
      await _updateSystemTray(
        brightness: trayState.brightness,
        isStart: trayState.isStart,
        force: focus,
      );
    }
    } finally {
      _isUpdating = false;

      if (_pendingState != null) {
        final pending = _pendingState;
        final pendingFocus = _pendingFocus;
        final pendingSilent = _pendingSilent;
        _pendingState = null;
        _pendingFocus = false;
        _pendingSilent = false;
        await _doUpdate(
          trayState: pending!,
          focus: pendingFocus,
          silent: pendingSilent,
        );
      }
    }
  }

  MenuItem _buildCopyEnvSubmenu(int port) {
    final items = <MenuItem>[];

    final shells = <({String label, Future<void> Function() action})>[
      (label: 'PowerShell', action: () => _copyEnvPowerShell(port)),
      (label: 'CMD', action: () => _copyEnvCmd(port)),
      (label: 'Bash', action: () => _copyEnvBash(port)),
      (label: 'Fish', action: () => _copyEnvFish(port)),
    ];

    for (final shell in shells) {
      items.add(
        MenuItem(
          label: shell.label,
          onClick: (_) async {
            await shell.action();
          },
        ),
      );
    }

    return MenuItem.submenu(
      label: appLocalizations.copyEnvVar,
      submenu: Menu(items: items),
    );
  }

  Future<void> _copyEnvPowerShell(int port) async {
    final url = 'http://127.0.0.1:$port';
    final cmd = '\$env:http_proxy="$url"\n'
        '\$env:https_proxy="$url"\n'
        '\$env:all_proxy="$url"';
    await Clipboard.setData(ClipboardData(text: cmd));
  }

  Future<void> _copyEnvCmd(int port) async {
    final url = 'http://127.0.0.1:$port';
    final cmd = 'set http_proxy=$url\n'
        'set https_proxy=$url\n'
        'set all_proxy=$url';
    await Clipboard.setData(ClipboardData(text: cmd));
  }

  Future<void> _copyEnvBash(int port) async {
    final url = 'http://127.0.0.1:$port';
    final cmd = 'export http_proxy=$url\n'
        'export https_proxy=$url\n'
        'export all_proxy=$url';
    await Clipboard.setData(ClipboardData(text: cmd));
  }

  Future<void> _copyEnvFish(int port) async {
    final url = 'http://127.0.0.1:$port';
    final cmd = 'set -gx http_proxy $url\n'
        'set -gx https_proxy $url\n'
        'set -gx all_proxy $url';
    await Clipboard.setData(ClipboardData(text: cmd));
  }

  Future<void> _toggleWakelock(bool currentEnabled) async {
    try {
      if (currentEnabled) {
        try {
          await WakelockPlus.disable();
        } catch (e) {
          commonPrint.log('WakeLock disable OS error: $e');
        }
        globalState.appController.stopWakelockAutoRecovery();
      } else {
        try {
          await WakelockPlus.enable();
        } catch (e) {
          commonPrint.log('WakeLock enable OS error: $e');
        }
        globalState.appController.startWakelockAutoRecovery();
      }
      globalState.updateWakelockState(!currentEnabled);
      await globalState.appController.updateTray();
    } catch (e) {
      commonPrint.log('WakeLock toggle error: $e');
    }
  }

  String _formatProxySublabel(int? delay) {
    if (delay == null) {
      return '';
    } else if (delay == 0) {
      return system.isMacOS ? _loadingFrames[_loadingFrame] : '...';
    } else if (delay < 0) {
      return '×';
    } else {
      return '${delay}ms';
    }
  }

  void _startLoadingAnimation() {
    if (!system.isMacOS) {
      return;
    }
    _loadingTimer?.cancel();
    _loadingFrame = 0;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!_isTesting) return;
      _scheduleLoadingUpdate();
    });
  }

  void _scheduleLoadingUpdate() {
    if (!_isTesting || !system.isMacOS) return;
    _loadingTimer = Timer(const Duration(milliseconds: 300), () async {
      if (trayManager.isMenuOpen) {
        _loadingFrame = (_loadingFrame + 1) % _loadingFrames.length;
        await globalState.appController.updateTray(false, true);
      }
      _scheduleLoadingUpdate();
    });
  }

  void _stopLoadingAnimation() {
    _loadingTimer?.cancel();
    _loadingTimer = null;
    _loadingFrame = 0;
  }

  Future<void> _testGroupDelay(Group group) async {
    if (_isTesting) return;

    final appController = globalState.appController;
    final testableProxies = group.all.where((p) {
      final name = p.name.toUpperCase();
      return name != 'REJECT' &&
          name != 'REJECT-DROP' &&
          name != 'PASS' &&
          p.type.toUpperCase() != 'REMATCH';
    }).toList();

    _isTesting = true;
    _testingGroupId = group.name;

    try {
      final testingEntries = <String>{};

      for (final proxy in testableProxies) {
        final state = appController.getProxyCardState(proxy.name);
        final name = state.proxyName;
        if (name.isEmpty || _isNonTestableProxyName(name)) continue;
        final url = appController.getRealTestUrl(
          state.testUrl.getSafeValue(group.testUrl ?? ''),
        );
        final entryKey = '$url\n$name';
        if (!testingEntries.add(entryKey)) continue;
        appController.setDelay(Delay(url: url, name: name, value: 0));
      }

      _startLoadingAnimation();

      await appController.updateTray(false, true);

      await delayTest(
        testableProxies,
        group.testUrl,
        system.isMacOS ? () => appController.updateTray(false, true) : null,
      );
    } catch (e) {
      commonPrint.log('Delay test error: $e');
      for (final proxy in testableProxies) {
        final state = appController.getProxyCardState(proxy.name);
        final name = state.proxyName;
        if (name.isEmpty || _isNonTestableProxyName(name)) continue;
        final url = appController.getRealTestUrl(
          state.testUrl.getSafeValue(group.testUrl ?? ''),
        );
        appController.setDelay(Delay(url: url, name: name, value: -1));
      }
    } finally {
      _stopLoadingAnimation();

      _isTesting = false;
      _testingGroupId = null;

      await appController.updateTray(false, true);
    }
  }

  bool _isNonTestableProxyName(String proxyName) {
    final name = proxyName.toUpperCase();
    if (name == 'REJECT' || name == 'REJECT-DROP' || name == 'PASS') {
      return true;
    }
    final groups = globalState.appController.getCurrentGroups();
    for (final group in groups) {
      for (final proxy in group.all) {
        if (proxy.name == proxyName) {
          return proxy.type.toUpperCase() == 'REMATCH';
        }
      }
    }
    return false;
  }
}

final tray = Tray();
