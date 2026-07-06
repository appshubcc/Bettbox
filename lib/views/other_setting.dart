import 'package:bett_box/common/common.dart';
import 'package:bett_box/common/network_matcher.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/plugins/service.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SmartAutoStopItem extends ConsumerWidget {
  const SmartAutoStopItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final smartAutoStop = ref.watch(
      vpnSettingProvider.select((state) => state.smartAutoStop),
    );

    return ListItem.switchItem(
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
    );
  }
}

class NetworkMatchItem extends ConsumerWidget {
  const NetworkMatchItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final smartAutoStopNetworks = ref.watch(
      vpnSettingProvider.select((state) => state.smartAutoStopNetworks),
    );

    return ListItem.input(
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
        onChanged: (bool value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(quickResponse: value));

          if (system.isAndroid) {
            await service?.setQuickResponse(value);
          }
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
      commonPrint.log('Network fix error: $e');
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
              commonPrint.log('Set process priority error: $e');
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

class BatteryOptimizationItem extends ConsumerStatefulWidget {
  const BatteryOptimizationItem({super.key});

  @override
  ConsumerState<BatteryOptimizationItem> createState() =>
      _BatteryOptimizationItemState();
}

class _BatteryOptimizationItemState extends ConsumerState<BatteryOptimizationItem>
    with WidgetsBindingObserver {
  bool? _isIgnoring;
  bool _isWaitingForSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatus(maxRetries: _isWaitingForSettings ? 3 : 1);
    }
  }

  Future<void> _checkStatus({int maxRetries = 1}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final isIgnoring = await app.isIgnoringBatteryOptimizations();
        if (mounted) {
          setState(() {
            _isIgnoring = isIgnoring;
            if (isIgnoring) {
              _isWaitingForSettings = false;
            }
          });
        }
        if (isIgnoring || attempt >= maxRetries - 1) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: 666));
      } catch (e) {
        commonPrint.log('Battery optimization check error: $e');
        break;
      }
    }
    if (mounted && _isWaitingForSettings) {
      setState(() => _isWaitingForSettings = false);
    }
  }

  Future<void> _handleSwitchChanged(BuildContext context, bool value) async {
    final isIgnoring = _isIgnoring;
    if (isIgnoring == null) return;

    if (isIgnoring) {
      if (context.mounted) {
        context.showSnackBar(appLocalizations.alreadyInWhitelist);
      }
      setState(() {});
    } else {
      try {
        setState(() => _isWaitingForSettings = true);
        await app.requestIgnoreBatteryOptimizations();
      } catch (e) {
        commonPrint.log('Battery optimization error: $e');
        setState(() => _isWaitingForSettings = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIgnoring = _isIgnoring;

    return ListItem.switchItem(
      title: Text(appLocalizations.batteryOptimization),
      subtitle: Text(appLocalizations.batteryOptimizationDesc),
      delegate: SwitchDelegate(
        value: isIgnoring ?? false,
        onChanged: (value) => _handleSwitchChanged(context, value),
      ),
    );
  }
}

class DisableQuicItem extends ConsumerWidget {
  const DisableQuicItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableQuic = ref.watch(
      vpnSettingProvider.select((state) => state.disableQuic),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.disableQuic),
      subtitle: Text(appLocalizations.disableQuicDesc),
      delegate: SwitchDelegate(
        value: disableQuic,
        onChanged: (bool value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(disableQuic: value));
          globalState.appController.setupClashConfigDebounce();
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

class TrayEnhancementItem extends ConsumerWidget {
  const TrayEnhancementItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trayEnhancement = ref.watch(
      vpnSettingProvider.select((state) => state.trayEnhancement),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.trayEnhancement),
      subtitle: Text(appLocalizations.trayEnhancementDesc),
      delegate: SwitchDelegate(
        value: trayEnhancement,
        onChanged: (bool value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(trayEnhancement: value));
          await globalState.appController.updateTray();
        },
      ),
    );
  }
}

class ExcludeChinaItem extends ConsumerWidget {
  const ExcludeChinaItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final excludeChina = ref.watch(
      vpnSettingProvider.select((state) => state.excludeChina),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.excludeChina),
      subtitle: Text(appLocalizations.excludeChinaDesc),
      delegate: SwitchDelegate(
        value: excludeChina,
        onChanged: (bool value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(excludeChina: value));
          globalState.appController.setupClashConfigDebounce();
        },
      ),
    );
  }
}

class OtherSettingView extends ConsumerWidget {
  const OtherSettingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final smartAutoStop = ref.watch(
      vpnSettingProvider.select((state) => state.smartAutoStop),
    );
    final disableQuic = ref.watch(
      vpnSettingProvider.select((state) => state.disableQuic),
    );
    final locale = ref.watch(
      appSettingProvider.select((state) => state.locale),
    );
    final isRussian = locale?.toLowerCase().startsWith('ru') ?? false;

    List<Widget> items = [
      const SmartAutoStopItem(),
      if (smartAutoStop) const NetworkMatchItem(),
      if (system.isAndroid) const DozeSuspendItem(),
      if (system.isAndroid) const QuickResponseItem(),
      const StoreFixItem(),
      const DisableQuicItem(),
      if (system.isAndroid) const NetworkSpeedNotificationItem(),
      if (!system.isAndroid) const TrayEnhancementItem(),
      if (disableQuic && !isRussian) const ExcludeChinaItem(),
      if (system.isWindows) const HighPriorityItem(),
      if (system.isWindows) const NetworkFixItem(),
      if (system.isAndroid) const BatteryOptimizationItem(),
    ];

    if (items.isEmpty) {
      return const Center(child: Text('No settings available'));
    }

    return ListView.separated(
      itemBuilder: (_, index) {
        final item = items[index];
        return item;
      },
      separatorBuilder: (_, _) {
        return const Divider(height: 0);
      },
      itemCount: items.length,
    );
  }
}
