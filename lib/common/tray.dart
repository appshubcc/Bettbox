import 'dart:async';
import 'dart:io';

import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/providers/proxy_delay_provider.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'common.dart';

class Tray {
  Timer? _debounceTimer;
  TrayState? _pendingState;
  bool _isUpdating = false;
  bool _pendingFocus = false;

  static const _debounceDelay = Duration(milliseconds: 300);

  Future<void> _updateSystemTray({required Brightness? brightness, required bool isStart, bool force = false}) async {
    if (system.isAndroid) return;
    if (force) await trayManager.destroy();
    await trayManager.setIcon(
      utils.getTrayIconPath(
        brightness: brightness ?? WidgetsBinding.instance.platformDispatcher.platformBrightness,
        isStart: isStart,
      ),
      isTemplate: system.isMacOS,
    );
    if (!Platform.isLinux) await trayManager.setToolTip(appName);
  }

  Future<void> update({required TrayState trayState, bool focus = false}) async {
    if (system.isAndroid) return;

    _debounceTimer?.cancel();

    if (_isUpdating) {
      _pendingState = trayState;
      _pendingFocus = _pendingFocus || focus;
      return;
    }

    if (focus) {
      await _doUpdate(trayState: trayState, focus: true);
    } else {
      _debounceTimer = Timer(_debounceDelay, () async {
        await _doUpdate(trayState: trayState, focus: false);
      });
    }
  }

  Future<void> _doUpdate({required TrayState trayState, bool focus = false}) async {
    if (_isUpdating) return;
    _isUpdating = true;

    try {
      if (!Platform.isLinux) {
        await _updateSystemTray(brightness: trayState.brightness, isStart: trayState.isStart, force: false);
      }

      final List<MenuItem> menuItems = [];

      menuItems.add(
        MenuItem(
          label: appLocalizations.show,
          onClick: (_) {
            window?.show();
          },
        ),
      );
      menuItems.add(
        MenuItem.checkbox(
          label: trayState.isStart ? appLocalizations.stop : appLocalizations.start,
          onClick: (_) async {
            globalState.appController.updateStart();
          },
          checked: false,
        ),
      );
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

      if (system.isMacOS) {
        final delayNotifier = globalState.appController.ref.read(proxyDelayNotifierProvider.notifier);

        for (final group in trayState.groups) {
          // 直接从 state 读取，Riverpod 管理，不会因 rebuild 丢失
          final groupDelays = delayNotifier.getGroupDelays(group.name);
          final testState = delayNotifier.getGroupState(group.name);

          // ── 复制并排序节点列表：低延迟在前，timeout/null 在后，DIRECT 永远最后 ──
          final proxies = List<Proxy>.of(group.all)
            ..sort((a, b) {
              final delayA = groupDelays[a.name];
              final delayB = groupDelays[b.name];

              final isDirectA = a.name.toUpperCase().contains('DIRECT');
              final isDirectB = b.name.toUpperCase().contains('DIRECT');
              if (isDirectA != isDirectB) return isDirectA ? 1 : -1;

              int norm(int? d) => (d == null || d < 0) ? 1 << 30 : d;
              final diff = norm(delayA).compareTo(norm(delayB));
              if (diff != 0) return diff;
              return a.name.compareTo(b.name);
            });

          final List<MenuItem> subMenuItems = [];

          // ── 测速按钮（顶部）──
          subMenuItems.add(
            MenuItem(
              label: switch (testState) {
                DelayTestState.idle => '⚡ 延迟测速',
                DelayTestState.testing => '⏱ 测速中...',
                DelayTestState.done => '⚡ 重新测速',
              },
              disabled: testState == DelayTestState.testing,
              onClick: testState == DelayTestState.testing ? null : (_) => delayNotifier.testGroupDelay(group.name),
            ),
          );
          subMenuItems.add(MenuItem.separator());

          // ── 节点列表（排序后）──
          for (final proxy in proxies) {
            final delay = groupDelays[proxy.name];
            final isSelected = trayState.selectedMap[group.name] == proxy.name;

            subMenuItems.add(
              MenuItem.checkbox(
                label: _buildNodeLabel(proxy.name, delay),
                checked: isSelected,
                onClick: (_) {
                  final c = globalState.appController;
                  c.updateCurrentSelectedMap(group.name, proxy.name);
                  c.changeProxy(groupName: group.name, proxyName: proxy.name);
                },
              ),
            );
          }

          // ── 父菜单：组名 / 当前选中节点 ──
          final currentNode = trayState.selectedMap[group.name] ?? '';
          menuItems.add(
            MenuItem.submenu(
              label: _buildGroupLabel(group.name, currentNode),
              submenu: Menu(items: subMenuItems),
            ),
          );
        }

        if (trayState.groups.isNotEmpty) menuItems.add(MenuItem.separator());
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

      menuItems.add(
        MenuItem.checkbox(
          label: appLocalizations.autoLaunch,
          onClick: (_) async {
            globalState.appController.updateAutoLaunch();
          },
          checked: trayState.autoLaunch,
        ),
      );
      menuItems.add(
        MenuItem(
          label: appLocalizations.copyEnvVar,
          onClick: (_) async {
            await _copyEnv(trayState.port);
          },
        ),
      );

      if (!system.isAndroid) {
        menuItems.add(
          MenuItem.checkbox(
            label: appLocalizations.wakelock,
            onClick: (_) async {
              await _toggleWakelock();
            },
            checked: trayState.wakelockEnabled,
          ),
        );
      }

      menuItems.add(MenuItem.separator());
      menuItems.add(
        MenuItem(
          label: appLocalizations.exit,
          onClick: (_) async {
            await globalState.appController.handleExit();
          },
        ),
      );

      await trayManager.setContextMenu(Menu(items: menuItems));

      if (Platform.isLinux) {
        await _updateSystemTray(brightness: trayState.brightness, isStart: trayState.isStart, force: focus);
      }
    } finally {
      _isUpdating = false;
      if (_pendingState != null) {
        final pending = _pendingState!;
        final pendingFocus = _pendingFocus;
        _pendingState = null;
        _pendingFocus = false;
        await _doUpdate(trayState: pending, focus: pendingFocus);
      }
    }
  }

  Future<void> _copyEnv(int port) async {
    final httpUrl = 'http://127.0.0.1:$port';
    final socksUrl = 'socks5://127.0.0.1:$port';
    final cmdline = system.isWindows
        ? '\$env:https_proxy="$httpUrl"; \$env:http_proxy="$httpUrl"; \$env:all_proxy="$socksUrl"'
        : 'export https_proxy=$httpUrl;export http_proxy=$httpUrl;export all_proxy=$socksUrl';
    await Clipboard.setData(ClipboardData(text: cmdline));
  }

  Future<void> _toggleWakelock() async {
    try {
      final enabled = await WakelockPlus.enabled;
      if (enabled) {
        await WakelockPlus.disable();
        globalState.appController.stopWakelockAutoRecovery();
      } else {
        await WakelockPlus.enable();
        globalState.appController.startWakelockAutoRecovery();
      }
      globalState.updateWakelockState(!enabled);
      await globalState.appController.updateTray();
    } catch (e) {
      commonPrint.log('WakeLock toggle error: $e');
    }
  }

  String _delayTag(int? delay) {
    if (delay == null) return '';
    if (delay < 0) return 'timeout';
    return '${delay}ms';
  }

  String _buildNodeLabel(String nodeName, int? delay) {
    final tag = _delayTag(delay);
    if (tag.isEmpty) return nodeName;
    return '$nodeName  $tag';
  }

  String _buildGroupLabel(String groupName, String currentNode) {
    if (currentNode.isEmpty) return groupName;
    return '$groupName / $currentNode';
  }
}

final tray = Tray();
