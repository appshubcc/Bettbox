import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> _handleNetworkConfigChange(WidgetRef ref) async {
  final bool isVpnOrTunEnabled;
  if (system.isAndroid) {
    isVpnOrTunEnabled = ref.read(vpnSettingProvider).enable;
  } else {
    isVpnOrTunEnabled = ref.read(patchClashConfigProvider).tun.enable;
  }
  
  final isCoreRunning = ref.read(runTimeProvider) != null;

  if (isVpnOrTunEnabled && isCoreRunning) {
    final tipMessage = system.isAndroid
        ? appLocalizations.vpnTip
        : appLocalizations.restartTip;
    globalState.showNotifier(
      tipMessage,
      actionLabel: appLocalizations.restart,
      showCountdown: true,
      onAction: () async {
        await globalState.appController.restartCore();
        globalState.showNotifier(appLocalizations.success);
      },
    );
  } else {
    globalState.appController.updateClashConfig();
  }
}

class VPNItem extends ConsumerWidget {
  const VPNItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final enable = ref.watch(
      vpnSettingProvider.select((state) => state.enable),
    );
    return ListItem.switchItem(
      title: const Text('VPN'),
      subtitle: Text(appLocalizations.vpnEnableDesc),
      delegate: SwitchDelegate(
        value: enable,
        onChanged: (value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(enable: value));
        },
      ),
    );
  }
}

class TUNItem extends ConsumerWidget {
  const TUNItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final enable = ref.watch(
      patchClashConfigProvider.select((state) => state.tun.enable),
    );

    return ListItem.switchItem(
      title: Text(appLocalizations.tun),
      subtitle: Text(appLocalizations.tunDesc),
      delegate: SwitchDelegate(
        value: enable,
        onChanged: (value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith.tun(enable: value));
        },
      ),
    );
  }
}

class AllowBypassItem extends ConsumerWidget {
  const AllowBypassItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final allowBypass = ref.watch(
      vpnSettingProvider.select((state) => state.allowBypass),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.allowBypass),
      subtitle: Text(appLocalizations.allowBypassDesc),
      delegate: SwitchDelegate(
        value: allowBypass,
        onChanged: (bool value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(allowBypass: value));
          await _handleNetworkConfigChange(ref);
        },
      ),
    );
  }
}

class VpnSystemProxyItem extends ConsumerWidget {
  const VpnSystemProxyItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final systemProxy = ref.watch(
      vpnSettingProvider.select((state) => state.systemProxy),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.systemProxy),
      subtitle: Text(appLocalizations.systemProxyDesc),
      delegate: SwitchDelegate(
        value: systemProxy,
        onChanged: (bool value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .updateState((state) => state.copyWith(systemProxy: value));
        },
      ),
    );
  }
}

class SystemProxyItem extends ConsumerWidget {
  const SystemProxyItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final systemProxy = ref.watch(
      networkSettingProvider.select((state) => state.systemProxy),
    );

    return ListItem.switchItem(
      title: Text(appLocalizations.systemProxy),
      subtitle: Text(appLocalizations.systemProxyDesc),
      delegate: SwitchDelegate(
        value: systemProxy,
        onChanged: (bool value) async {
          ref
              .read(networkSettingProvider.notifier)
              .updateState((state) => state.copyWith(systemProxy: value));
        },
      ),
    );
  }
}

class AutoSetSystemDnsItem extends ConsumerWidget {
  const AutoSetSystemDnsItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final autoSetSystemDns = ref.watch(
      networkSettingProvider.select((state) => state.autoSetSystemDns),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.autoSetSystemDns),
      delegate: SwitchDelegate(
        value: autoSetSystemDns,
        onChanged: (bool value) async {
          ref
              .read(networkSettingProvider.notifier)
              .updateState((state) => state.copyWith(autoSetSystemDns: value));
        },
      ),
    );
  }
}

class StrictRouteItem extends ConsumerWidget {
  const StrictRouteItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strictRoute = ref.watch(
      patchClashConfigProvider.select((state) => state.tun.strictRoute),
    );

    return ListItem.switchItem(
      title: Text(appLocalizations.strictRoute),
      subtitle: Text(appLocalizations.strictRouteDesc),
      delegate: SwitchDelegate(
        value: strictRoute,
        onChanged: (value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith.tun(strictRoute: value));

          await _handleNetworkConfigChange(ref);
        },
      ),
    );
  }
}

class IcmpForwardingItem extends ConsumerWidget {
  const IcmpForwardingItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: inverted because disableIcmpForwarding=true means disabled
    // UI shows "Enable ICMP forwarding"
    final icmpForwarding = ref.watch(
      patchClashConfigProvider.select(
        (state) => !state.tun.disableIcmpForwarding,
      ),
    );

    return ListItem.switchItem(
      title: Text(appLocalizations.icmpForwarding),
      subtitle: Text(appLocalizations.icmpForwardingDesc),
      delegate: SwitchDelegate(
        value: icmpForwarding,
        onChanged: (value) async {
          // Invert before passing to core
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState(
                (state) => state.copyWith.tun(disableIcmpForwarding: !value),
              );

          await _handleNetworkConfigChange(ref);
        },
      ),
    );
  }
}


class DnsHijackItem extends ConsumerWidget {
  const DnsHijackItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dnsHijack = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.tun.dnsHijack.isNotEmpty,
      ),
    );

    return ListItem.switchItem(
      title: Text(appLocalizations.dnsHijack),
      subtitle: Text(appLocalizations.dnsHijackDesc),
      delegate: SwitchDelegate(
        value: dnsHijack,
        onChanged: (value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState(
                (state) => state.copyWith.tun(
                  dnsHijack: value ? ['any:53', 'tcp://any:53'] : [],
                ),
              );
          await _handleNetworkConfigChange(ref);
        },
      ),
    );
  }
}

class EndpointIndependentNatItem extends ConsumerWidget {
  const EndpointIndependentNatItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final endpointIndependentNat = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.tun.endpointIndependentNat,
      ),
    );

    return ListItem.switchItem(
      title: Text(appLocalizations.endpointIndependentNat),
      subtitle: Text(appLocalizations.endpointIndependentNatDesc),
      delegate: SwitchDelegate(
        value: endpointIndependentNat,
        onChanged: (value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState(
                (state) => state.copyWith.tun(endpointIndependentNat: value),
              );
          await _handleNetworkConfigChange(ref);
        },
      ),
    );
  }
}

class TunStackItem extends ConsumerWidget {
  const TunStackItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final stack = ref.watch(
      patchClashConfigProvider.select((state) => state.tun.stack),
    );

    return ListItem.options(
      title: Text(appLocalizations.stackMode),
      subtitle: Text(stack.name),
      delegate: OptionsDelegate<TunStack>(
        value: stack,
        options: TunStack.values,
        textBuilder: (value) => value.name,
        onChanged: (value) async {
          if (value == null) {
            return;
          }
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith.tun(stack: value));
          await _handleNetworkConfigChange(ref);
        },
        title: appLocalizations.stackMode,
      ),
    );
  }
}

class MtuItem extends ConsumerWidget {
  const MtuItem({super.key});

  Future<void> _showCustomMtuDialog(
    BuildContext context,
    WidgetRef ref,
    int currentMtu,
  ) async {
    String inputValue = '$currentMtu';
    String? errorText;
    final controller = TextEditingController(text: inputValue);

    final result = await globalState.showCommonDialog<bool>(
      child: StatefulBuilder(
        builder: (context, setState) {
          return CommonDialog(
            title: 'MTU',
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(appLocalizations.cancel),
              ),
              TextButton(
                onPressed: errorText == null && inputValue.isNotEmpty
                    ? () {
                        Navigator.of(context).pop(true);
                      }
                    : null,
                child: Text(appLocalizations.confirm),
              ),
            ],
            child: TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              controller: controller,
              decoration: InputDecoration(
                labelText: 'MTU',
                errorText: errorText,
                hintText: '1280-65535',
              ),
              onChanged: (value) {
                inputValue = value;
                // Real-time validation
                if (value.isEmpty) {
                  setState(() {
                    errorText = appLocalizations.emptyTip('MTU');
                  });
                } else {
                  final intValue = int.tryParse(value);
                  if (intValue == null) {
                    setState(() {
                      errorText = appLocalizations.numberTip('MTU');
                    });
                  } else if (intValue < 1280 || intValue > 65535) {
                    setState(() {
                      errorText = 'MTU Must be 1280-65535';
                    });
                  } else {
                    setState(() {
                      errorText = null;
                    });
                  }
                }
              },
              onSubmitted: (value) {
                if (errorText == null && value.isNotEmpty) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
          );
        },
      ),
    );

    // Clean up controller
    controller.dispose();

    if (result == true && inputValue.isNotEmpty) {
      final intValue = int.tryParse(inputValue);
      if (intValue != null && intValue >= 1280 && intValue <= 65535) {
        ref
            .read(patchClashConfigProvider.notifier)
            .updateState((state) => state.copyWith.tun(mtu: intValue));
        await _handleNetworkConfigChange(ref);
      }
    }
  }

  @override
  Widget build(BuildContext context, ref) {
    final mtu = ref.watch(
      patchClashConfigProvider.select((state) => state.tun.mtu),
    );

    // Preset options
    final presetOptions = [1480, 4064, 9000];
    final isCustom = !presetOptions.contains(mtu);

    return ListItem.options(
      title: const Text('MTU'),
      subtitle: Text(isCustom ? '$mtu (${appLocalizations.custom})' : '$mtu'),
      delegate: OptionsDelegate<String>(
        value: isCustom ? 'custom' : '$mtu',
        options: ['1480', '4064', '9000', 'custom'],
        textBuilder: (value) {
          if (value == 'custom') {
            return '${appLocalizations.custom}...';
          }
          return value;
        },
        onChanged: (value) async {
          if (value == null) return;

          // If custom option selected
          if (value == 'custom') {
            await _showCustomMtuDialog(context, ref, mtu);
          } else {
            // Apply preset value directly
            final intValue = int.parse(value);
            ref
                .read(patchClashConfigProvider.notifier)
                .updateState((state) => state.copyWith.tun(mtu: intValue));
            await _handleNetworkConfigChange(ref);
          }
        },
        title: 'MTU',
      ),
    );
  }
}

class BypassDomainItem extends StatelessWidget {
  const BypassDomainItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem.open(
      title: Text(appLocalizations.bypassDomain),
      subtitle: Text(appLocalizations.bypassDomainDesc),
      delegate: OpenDelegate(
        blur: false,
        actions: [
          Consumer(
            builder: (_, ref, _) {
              return IconButton(
                onPressed: () async {
                  final res = await globalState.showMessage(
                    title: appLocalizations.reset,
                    message: TextSpan(text: appLocalizations.resetTip),
                  );
                  if (res != true) {
                    return;
                  }
                  ref
                      .read(networkSettingProvider.notifier)
                      .updateState(
                        (state) =>
                            state.copyWith(bypassDomain: defaultBypassDomain),
                      );
                },
                tooltip: appLocalizations.reset,
                icon: const Icon(Icons.replay),
              );
            },
          ),
        ],
        title: appLocalizations.bypassDomain,
        widget: Consumer(
          builder: (_, ref, _) {
            final bypassDomain = ref.watch(
              networkSettingProvider.select((state) => state.bypassDomain),
            );
            return ListInputPage(
              title: appLocalizations.bypassDomain,
              items: bypassDomain,
              titleBuilder: (item) => Text(item),
              onChange: (items) {
                ref
                    .read(networkSettingProvider.notifier)
                    .updateState(
                      (state) => state.copyWith(bypassDomain: List.from(items)),
                    );
              },
            );
          },
        ),
      ),
    );
  }
}

class BypassPrivateRouteItem extends ConsumerWidget {
  const BypassPrivateRouteItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final bypassPrivateRoute = ref.watch(
      networkSettingProvider.select((state) => state.bypassPrivateRoute),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.bypassPrivateRoute),
      subtitle: Text(appLocalizations.bypassPrivateRouteDesc),
      delegate: SwitchDelegate(
        value: bypassPrivateRoute,
        onChanged: (value) async {
          ref
              .read(networkSettingProvider.notifier)
              .updateState((state) => state.copyWith(bypassPrivateRoute: value));
          await _handleNetworkConfigChange(ref);
        },
      ),
    );
  }
}



final networkItems = [
  if (system.isAndroid) const VPNItem(),
  if (system.isAndroid)
    ...generateSection(
      title: 'VPN',
      items: [const AllowBypassItem()],
    ),
  if (system.isDesktop)
    ...generateSection(
      title: appLocalizations.system,
      items: [SystemProxyItem(), BypassDomainItem()],
    ),
  ...generateSection(
    title: appLocalizations.options,
    items: [
      if (system.isDesktop) const TUNItem(),
      if (system.isMacOS) const AutoSetSystemDnsItem(),
      if (!system.isAndroid) const StrictRouteItem(),
      const IcmpForwardingItem(),
      const DnsHijackItem(),
      const EndpointIndependentNatItem(),
      const TunStackItem(),
      const MtuItem(),
      const BypassPrivateRouteItem(),
    ],
  ),
];

class NetworkListView extends StatelessWidget {
  const NetworkListView({super.key});

  @override
  Widget build(BuildContext context) {
    return generateListView(networkItems);
  }
}
