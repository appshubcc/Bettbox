import 'package:bett_box/common/common.dart';
import 'package:bett_box/common/network_matcher.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/plugins/service.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SmartAutoStopSection extends ConsumerWidget {
  const SmartAutoStopSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final smartAutoStop = ref.watch(
      vpnSettingProvider.select((state) => state.smartAutoStop),
    );
    final smartAutoStopNetworks = ref.watch(
      vpnSettingProvider.select((state) => state.smartAutoStopNetworks),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListItem.switchItem(
          title: Text(appLocalizations.smartAutoStop),
          subtitle: Text(appLocalizations.smartAutoStopDesc),
          delegate: SwitchDelegate(
            value: smartAutoStop,
            onChanged: (bool value) async {
              ref
                  .read(vpnSettingProvider.notifier)
                  .updateState((state) => state.copyWith(smartAutoStop: value));
            },
          ),
        ),
        if (smartAutoStop) ...[
          Divider(
            height: 1,
            thickness: 1,
            color: context.colorScheme.outlineVariant.withValues(
              alpha: context.colorScheme.brightness == Brightness.light
                  ? 0.6
                  : 0.45,
            ),
            indent: 16,
            endIndent: 16,
          ),
          ListItem.input(
            title: Text(appLocalizations.networkMatch),
            subtitle: Text(
              smartAutoStopNetworks.isEmpty
                  ? appLocalizations.networkMatchHint
                  : smartAutoStopNetworks,
            ),
            delegate: InputDelegate(
              title: appLocalizations.networkMatch,
              value: smartAutoStopNetworks,
              onChanged: (String? value) {
                if (value != null) {
                  ref
                      .read(vpnSettingProvider.notifier)
                      .updateState(
                        (state) => state.copyWith(smartAutoStopNetworks: value),
                      );
                }
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) return null;
                return NetworkMatcher.getValidationError(
                  value,
                  invalidFormatMsg: appLocalizations.invalidIpFormat,
                  tooManyRulesMsg: appLocalizations.tooManyRules,
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class DozeSuspendItem extends ConsumerWidget {
  const DozeSuspendItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dozeSuspend = ref.watch(
      vpnSettingProvider.select((state) => state.dozeSuspend),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.dozeSuspend),
      subtitle: Text(appLocalizations.dozeSuspendDesc),
      delegate: SwitchDelegate(
        value: dozeSuspend,
        onChanged: (bool value) {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(dozeSuspend: value));
        },
      ),
    );
  }
}

class StoreFixItem extends ConsumerWidget {
  const StoreFixItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeFix = ref.watch(
      vpnSettingProvider.select((state) => state.storeFix),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.storeFix),
      subtitle: Text(appLocalizations.storeFixDesc),
      delegate: SwitchDelegate(
        value: storeFix,
        onChanged: (bool value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(storeFix: value));

          final currentHosts = Map<String, String>.from(
            ref.read(patchClashConfigProvider).hosts,
          );

          if (value) {
            currentHosts['services.googleapis.cn'] = 'services.googleapis.com';
          } else {
            currentHosts.remove('services.googleapis.cn');
          }

          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith(hosts: currentHosts));
        },
      ),
    );
  }
}

class CloseConnectionsItem extends ConsumerWidget {
  const CloseConnectionsItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final closeConnections = ref.watch(
      appSettingProvider.select((state) => state.closeConnections),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.autoCloseConnections),
      subtitle: Text(appLocalizations.autoCloseConnectionsDesc),
      delegate: SwitchDelegate(
        value: closeConnections,
        onChanged: (value) async {
          ref
              .read(appSettingProvider.notifier)
              .updateState((state) => state.copyWith(closeConnections: value));
        },
      ),
    );
  }
}

class QuickResponseItem extends ConsumerWidget {
  const QuickResponseItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickResponse = ref.watch(
      vpnSettingProvider.select((state) => state.quickResponse),
    );

    return ListItem.switchItem(
      title: Text(appLocalizations.quickResponse),
      subtitle: Text(appLocalizations.quickResponseDesc),
      delegate: SwitchDelegate(
        value: quickResponse,
        onChanged: (bool value) {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(quickResponse: value));
        },
      ),
    );
  }
}

class NetworkFixItem extends ConsumerWidget {
  const NetworkFixItem({super.key});

  Future<void> _applyNetworkFix(bool enable) async {
    try {
      const regPath =
          r'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet';

      if (enable) {
        final commands = [
          'reg add "$regPath" /v ActiveDnsProbeContent /t REG_SZ /d "131.107.255.255" /f',
          'reg add "$regPath" /v ActiveDnsProbeContentV6 /t REG_SZ /d "fd3e:4f5a:5b81::1" /f',
          'reg add "$regPath" /v ActiveDnsProbeHost /t REG_SZ /d "dns.msftncsi.com" /f',
          'reg add "$regPath" /v ActiveDnsProbeHostV6 /t REG_SZ /d "dns.msftncsi.com" /f',
          'reg add "$regPath" /v ActiveWebProbeContent /t REG_SZ /d "" /f',
          'reg add "$regPath" /v ActiveWebProbeContentV6 /t REG_SZ /d "" /f',
          'reg add "$regPath" /v ActiveWebProbeHost /t REG_SZ /d "dns.alidns.com" /f',
          'reg add "$regPath" /v ActiveWebProbeHostV6 /t REG_SZ /d "dns.alidns.com" /f',
          'reg add "$regPath" /v ActiveWebProbePath /t REG_SZ /d "dns-query" /f',
          'reg add "$regPath" /v ActiveWebProbePathV6 /t REG_SZ /d "dns-query" /f',
          'reg add "$regPath" /v CaptivePortalTimer /t REG_DWORD /d 0x00000000 /f',
          'reg add "$regPath" /v CaptivePortalTimerBackOffIncrementsInSeconds /t REG_DWORD /d 0x00000001 /f',
          'reg add "$regPath" /v CaptivePortalTimerMaxInSeconds /t REG_DWORD /d 0x0000001e /f',
          'reg add "$regPath" /v EnableActiveProbing /t REG_DWORD /d 0x00000001 /f',
          'reg add "$regPath" /v PassivePollPeriod /t REG_DWORD /d 0x0000000f /f',
          'reg add "$regPath" /v StaleThreshold /t REG_DWORD /d 0x0000001e /f',
          'reg add "$regPath" /v WebTimeout /t REG_DWORD /d 0x00000023 /f',
        ];

        for (final cmd in commands) {
          windows?.runas(cmd, '', showWindow: false);
        }
      } else {
        final commands = [
          'reg add "$regPath" /v ActiveDnsProbeContent /t REG_SZ /d "131.107.255.255" /f',
          'reg add "$regPath" /v ActiveDnsProbeContentV6 /t REG_SZ /d "fd3e:4f5a:5b81::1" /f',
          'reg add "$regPath" /v ActiveDnsProbeHost /t REG_SZ /d "dns.msftncsi.com" /f',
          'reg add "$regPath" /v ActiveDnsProbeHostV6 /t REG_SZ /d "dns.msftncsi.com" /f',
          'reg add "$regPath" /v ActiveWebProbeContent /t REG_SZ /d "Microsoft NCSI" /f',
          'reg add "$regPath" /v ActiveWebProbeContentV6 /t REG_SZ /d "Microsoft NCSI" /f',
          'reg add "$regPath" /v ActiveWebProbeHost /t REG_SZ /d "www.msftncsi.com" /f',
          'reg add "$regPath" /v ActiveWebProbeHostV6 /t REG_SZ /d "ipv6.msftncsi.com" /f',
          'reg add "$regPath" /v ActiveWebProbePath /t REG_SZ /d "ncsi.txt" /f',
          'reg add "$regPath" /v ActiveWebProbePathV6 /t REG_SZ /d "ncsi.txt" /f',
          'reg add "$regPath" /v CaptivePortalTimer /t REG_DWORD /d 0x00000000 /f',
          'reg add "$regPath" /v CaptivePortalTimerBackOffIncrementsInSeconds /t REG_DWORD /d 0x00000001 /f',
          'reg add "$regPath" /v CaptivePortalTimerMaxInSeconds /t REG_DWORD /d 0x0000001e /f',
          'reg add "$regPath" /v EnableActiveProbing /t REG_DWORD /d 0x00000001 /f',
          'reg add "$regPath" /v PassivePollPeriod /t REG_DWORD /d 0x0000000f /f',
          'reg add "$regPath" /v StaleThreshold /t REG_DWORD /d 0x0000001e /f',
          'reg add "$regPath" /v WebTimeout /t REG_DWORD /d 0x00000023 /f',
        ];

        for (final cmd in commands) {
          windows?.runas(cmd, '', showWindow: false);
        }
      }
    } catch (e) {
      commonPrint.warn('Network fix error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkFix = ref.watch(
      vpnSettingProvider.select((state) => state.networkFix),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.networkFix),
      subtitle: Text(appLocalizations.networkFixDesc),
      delegate: SwitchDelegate(
        value: networkFix,
        onChanged: (bool value) async {
          try {
            await _applyNetworkFix(value);

            ref
                .read(vpnSettingProvider.notifier)
                .updateState((state) => state.copyWith(networkFix: value));
          } catch (e) {
            if (context.mounted) {
              context.showSnackBar('Network fix failed: $e');
            }
          }
        },
      ),
    );
  }
}

class HighPriorityItem extends ConsumerWidget {
  const HighPriorityItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableHighPriority = ref.watch(
      appSettingProvider.select((state) => state.enableHighPriority),
    );

    return ListItem.switchItem(
      title: Text(appLocalizations.highPriority),
      subtitle: Text(appLocalizations.highPriorityDesc),
      delegate: SwitchDelegate(
        value: enableHighPriority,
        onChanged: (bool value) async {
          ref
              .read(appSettingProvider.notifier)
              .updateState(
                (state) => state.copyWith(enableHighPriority: value),
              );

          if (system.isWindows) {
            try {
              await globalState.appController.setProcessPriority(value);
            } catch (e) {
              commonPrint.warn('Set process priority error: $e');
              if (context.mounted) {
                context.showSnackBar('Failed to set process priority: $e');
              }
            }
          }
        },
      ),
    );
  }
}

class BatteryOptimizationItem extends StatelessWidget {
  final VoidCallback onRequest;

  const BatteryOptimizationItem({super.key, required this.onRequest});

  @override
  Widget build(BuildContext context) {
    return ListItem.switchItem(
      title: Text(appLocalizations.batteryOptimization),
      subtitle: Text(appLocalizations.batteryOptimizationDesc),
      delegate: SwitchDelegate(value: false, onChanged: (_) => onRequest()),
    );
  }
}

class LoopbackProtectionItem extends ConsumerWidget {
  const LoopbackProtectionItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loopbackProtection = ref.watch(
      vpnSettingProvider.select((state) => state.loopbackProtection),
    );

    return ListItem.switchItem(
      title: Text(appLocalizations.loopbackProtection),
      subtitle: Text(appLocalizations.loopbackProtectionDesc),
      delegate: SwitchDelegate(
        value: loopbackProtection,
        onChanged: (bool value) {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState(
                (state) => state.copyWith(loopbackProtection: value),
              );
        },
      ),
    );
  }
}

class DisableQuicSection extends ConsumerWidget {
  const DisableQuicSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isManaged = ref.watch(
      currentProfileProvider.select((profile) => profile?.isManaged ?? false),
    );
    final disableQuic = ref.watch(
      vpnSettingProvider.select((state) => state.disableQuic),
    );
    final managedOptions = ref.watch(
      managedSettingProvider.select((state) => state.options),
    );
    final managedQuic =
        managedOptions['禁用内核QUIC流量'] ??
        managedOptions['屏蔽内核QUIC流量'] ??
        true;
    final enabled = isManaged ? managedQuic : disableQuic;

    return ListItem.switchItem(
      title: Text(appLocalizations.disableQuic),
      subtitle: Text(appLocalizations.disableQuicDesc),
      delegate: SwitchDelegate(
        value: enabled,
        onChanged: (bool value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(disableQuic: value));
          if (isManaged) {
            globalState.appController.updateManagedSetting(
              (state) => state.copyWith(
                options: {
                  ...state.options,
                  '禁用内核QUIC流量': value,
                }..remove('屏蔽内核QUIC流量'),
              ),
            );
          }
          globalState.appController.setupClashConfigDebounce();
        },
      ),
    );
  }
}

class HighPriorityNotificationItem extends ConsumerWidget {
  const HighPriorityNotificationItem({super.key});

  Future<bool> _showConfirmDialog(BuildContext context) async {
    final result = await globalState.showCommonDialog<bool>(
      child: CommonDialog(
        title: appLocalizations.notificationHighPriority,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(false);
            },
            child: Text(appLocalizations.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
            },
            child: Text(appLocalizations.confirm),
          ),
        ],
        child: Text(appLocalizations.notificationHighPriorityTip),
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highPriority = ref.watch(
      vpnSettingProvider.select((state) => state.highPriorityNotification),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.notificationHighPriority),
      subtitle: Text(appLocalizations.notificationHighPriorityDesc),
      delegate: SwitchDelegate(
        value: highPriority,
        onChanged: (bool value) async {
          if (value) {
            final confirm = await _showConfirmDialog(context);
            if (!confirm) return;
          }
          ref
              .read(vpnSettingProvider.notifier)
              .updateState(
                (state) => state.copyWith(highPriorityNotification: value),
              );
          if (system.isAndroid) {
            await service?.setHighPriorityNotification(value);
          }
        },
      ),
    );
  }
}

class NetworkSpeedNotificationItem extends ConsumerWidget {
  const NetworkSpeedNotificationItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkSpeedNotification = ref.watch(
      vpnSettingProvider.select((state) => state.networkSpeedNotification),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.networkSpeedNotification),
      subtitle: Text(appLocalizations.networkSpeedNotificationDesc),
      delegate: SwitchDelegate(
        value: networkSpeedNotification,
        onChanged: (bool value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState(
                (state) => state.copyWith(networkSpeedNotification: value),
              );
          if (!value && system.isAndroid) {
            await service?.restoreNotification();
          }
        },
      ),
    );
  }
}

class TraySection extends ConsumerWidget {
  const TraySection({super.key});

  Future<void> _showTrayClickBehaviorDialog(
    BuildContext context,
    WidgetRef ref, {
    required TrayClickBehavior leftBehavior,
    required TrayClickBehavior rightBehavior,
  }) async {
    final result = await globalState
        .showCommonDialog<
          ({TrayClickBehavior leftBehavior, TrayClickBehavior rightBehavior})
        >(
          child: _TrayClickBehaviorDialog(
            leftBehavior: leftBehavior,
            rightBehavior: rightBehavior,
          ),
        );
    if (result == null) return;
    ref
        .read(vpnSettingProvider.notifier)
        .updateState(
          (state) => state.copyWith(
            trayLeftClickBehavior: result.leftBehavior,
            trayRightClickBehavior: result.rightBehavior,
          ),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (trayEnhancement, leftBehavior, rightBehavior) = ref.watch(
      vpnSettingProvider.select(
        (state) => (
          state.trayEnhancement,
          state.trayLeftClickBehavior,
          state.trayRightClickBehavior,
        ),
      ),
    );
    final enableTraySpeed = ref.watch(
      vpnSettingProvider.select((state) => state.enableTraySpeed),
    );

    final showClickBehaviorSetting = system.isMacOS;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListItem.switchItem(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(appLocalizations.trayEnhancement),
              if (showClickBehaviorSetting) ...[
                TitleSettingButton(
                  tooltip: appLocalizations.trayClickBehavior,
                  onTap: () => _showTrayClickBehaviorDialog(
                    context,
                    ref,
                    leftBehavior: leftBehavior,
                    rightBehavior: rightBehavior,
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(appLocalizations.trayEnhancementDesc),
          delegate: SwitchDelegate(
            value: trayEnhancement,
            onChanged: (bool value) async {
              ref
                  .read(vpnSettingProvider.notifier)
                  .updateState(
                    (state) => state.copyWith(trayEnhancement: value),
                  );
              await globalState.appController.updateTray();
            },
          ),
        ),
        if (system.isMacOS) ...[
          Divider(
            height: 1,
            thickness: 1,
            color: context.colorScheme.outlineVariant.withValues(
              alpha: context.colorScheme.brightness == Brightness.light
                  ? 0.6
                  : 0.45,
            ),
            indent: 16,
            endIndent: 16,
          ),
          ListItem.switchItem(
            title: Text(appLocalizations.enableTraySpeed),
            subtitle: Text(appLocalizations.enableTraySpeedDesc),
            delegate: SwitchDelegate(
              value: enableTraySpeed,
              onChanged: (bool value) async {
                ref
                    .read(vpnSettingProvider.notifier)
                    .updateState(
                      (state) => state.copyWith(enableTraySpeed: value),
                    );
                await globalState.appController.updateTray();
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _TrayClickBehaviorDialog extends StatefulWidget {
  final TrayClickBehavior leftBehavior;
  final TrayClickBehavior rightBehavior;

  const _TrayClickBehaviorDialog({
    required this.leftBehavior,
    required this.rightBehavior,
  });

  @override
  State<_TrayClickBehaviorDialog> createState() =>
      _TrayClickBehaviorDialogState();
}

class _TrayClickBehaviorDialogState extends State<_TrayClickBehaviorDialog> {
  late TrayClickBehavior _leftBehavior;
  late TrayClickBehavior _rightBehavior;

  @override
  void initState() {
    super.initState();
    _leftBehavior = widget.leftBehavior;
    _rightBehavior = widget.rightBehavior;
  }

  List<SegmentOption<TrayClickBehavior>> get _options => [
    SegmentOption(
      value: TrayClickBehavior.showPanel,
      icon: const Icon(Icons.dashboard_outlined),
      label: appLocalizations.showPanel,
    ),
    SegmentOption(
      value: TrayClickBehavior.showMenu,
      icon: const Icon(Icons.menu),
      label: appLocalizations.showMenu,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.trayClickBehavior,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(
              context,
            ).pop((leftBehavior: _leftBehavior, rightBehavior: _rightBehavior));
          },
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalizations.leftClickBehavior,
            style: context.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SegmentButtonGroup<TrayClickBehavior>(
            options: _options,
            selected: _leftBehavior,
            onSelected: (behavior) => setState(() => _leftBehavior = behavior),
          ),
          const SizedBox(height: 20),
          Text(
            appLocalizations.rightClickBehavior,
            style: context.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SegmentButtonGroup<TrayClickBehavior>(
            options: _options,
            selected: _rightBehavior,
            onSelected: (behavior) => setState(() => _rightBehavior = behavior),
          ),
        ],
      ),
    );
  }
}

class OtherSettingView extends StatefulWidget {
  const OtherSettingView({super.key});

  @override
  State<OtherSettingView> createState() => _OtherSettingViewState();
}

class _OtherSettingViewState extends State<OtherSettingView>
    with WidgetsBindingObserver {
  bool _showBatteryOptimization = false;
  bool _isWaitingForSettings = false;

  @override
  void initState() {
    super.initState();
    if (!system.isAndroid) return;
    WidgetsBinding.instance.addObserver(this);
    _checkBatteryOptimization();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final maxRetries = _isWaitingForSettings ? 3 : 1;
    _isWaitingForSettings = false;
    _checkBatteryOptimization(maxRetries: maxRetries);
  }

  Future<void> _checkBatteryOptimization({int maxRetries = 1}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final isIgnoring = await app.isIgnoringBatteryOptimizations();
        if (!mounted) return;
        if (_showBatteryOptimization == isIgnoring) {
          setState(() => _showBatteryOptimization = !isIgnoring);
        }
        if (isIgnoring || attempt >= maxRetries - 1) return;
        await Future.delayed(const Duration(milliseconds: 666));
      } catch (e) {
        commonPrint.warn('Battery optimization check error: $e');
        return;
      }
    }
  }

  Future<void> _requestBatteryOptimization() async {
    _isWaitingForSettings = true;
    try {
      await app.requestIgnoreBatteryOptimizations();
    } catch (e) {
      commonPrint.warn('Battery optimization error: $e');
      _isWaitingForSettings = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [
      const SmartAutoStopSection(),
      if (system.isAndroid) const DozeSuspendItem(),
      if (system.isAndroid) const QuickResponseItem(),
      if (system.isAndroid) const StoreFixItem(),
      const LoopbackProtectionItem(),
      const DisableQuicSection(),
      if (system.isAndroid) const HighPriorityNotificationItem(),
      if (system.isAndroid) const NetworkSpeedNotificationItem(),
      if (!system.isAndroid) const TraySection(),
      if (system.isWindows) const HighPriorityItem(),
      if (system.isWindows) const NetworkFixItem(),
      if (system.isDesktop) const CloseConnectionsItem(),
      if (_showBatteryOptimization)
        BatteryOptimizationItem(onRequest: _requestBatteryOptimization),
    ];

    if (items.isEmpty) {
      return const Center(child: Text('No settings available'));
    }

    return generateListView(generateSection(items: items));
  }
}
