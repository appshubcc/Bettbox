import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/clash_config.dart';
import 'package:bett_box/models/config.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/config/dns.dart';
import 'package:bett_box/views/config/general.dart';
import 'package:bett_box/views/config/network.dart';
import 'package:bett_box/views/config/ntp.dart';
import 'package:bett_box/views/config/sniffer.dart';
import 'package:bett_box/views/config/tunnel.dart';
import 'package:bett_box/views/config/experimental.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfigView extends StatefulWidget {
  const ConfigView({super.key});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  @override
  Widget build(BuildContext context) {
    List<Widget> items = [
      ListItem.next(
        title: Text(appLocalizations.general),
        subtitle: Text(appLocalizations.generalDesc),
        leading: const Icon(Icons.build),
        delegate: NextDelegate(
          title: appLocalizations.general,
          builder: (_) => generateListView(generalItems),
          blur: false,
        ),
      ),
      ListItem.next(
        title: Text(appLocalizations.network),
        subtitle: Text(appLocalizations.networkDesc),
        leading: const Icon(Icons.vpn_key),
        delegate: NextDelegate(
          title: appLocalizations.network,
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
                        .read(vpnSettingProvider.notifier)
                        .updateState(
                          (state) => defaultVpnProps.copyWith(
                            accessControl: state.accessControl,
                            enable: state.enable,
                            systemProxy: state.systemProxy,
                          ),
                        );
                    ref
                        .read(patchClashConfigProvider.notifier)
                        .updateState(
                          (state) => state.copyWith(
                            tun: defaultTun.copyWith(enable: state.tun.enable),
                          ),
                        );
                  },
                  tooltip: appLocalizations.reset,
                  icon: const Icon(Icons.replay),
                );
              },
            ),
          ],
          builder: (_) => const NetworkListView(),
        ),
      ),
      ListItem.next(
        title: const Text('DNS'),
        subtitle: Text(appLocalizations.dnsDesc),
        leading: const Icon(Icons.dns),
        delegate: NextDelegate(
          title: 'DNS',
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
                        .read(patchClashConfigProvider.notifier)
                        .updateState(
                          (state) => state.copyWith(dns: defaultDns),
                        );
                  },
                  tooltip: appLocalizations.reset,
                  icon: const Icon(Icons.replay),
                );
              },
            ),
          ],
          builder: (_) => const DnsListView(),
          blur: false,
        ),
      ),
      ListItem.next(
        title: const Text('NTP'),
        subtitle: Text(appLocalizations.ntpDesc),
        leading: const Icon(Icons.access_time),
        delegate: NextDelegate(
          title: 'NTP',
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
                        .read(patchClashConfigProvider.notifier)
                        .updateState(
                          (state) => state.copyWith(ntp: defaultNtp),
                        );
                  },
                  tooltip: appLocalizations.reset,
                  icon: const Icon(Icons.replay),
                );
              },
            ),
          ],
          builder: (_) => const NtpListView(),
          blur: false,
        ),
      ),
      ListItem.next(
        title: const Text('Hosts'),
        subtitle: Text(appLocalizations.hostsDesc),
        leading: const Icon(Icons.view_list_outlined),
        delegate: NextDelegate(
          blur: false,
          title: 'Hosts',
          builder: (_) => Consumer(
            builder: (_, ref, _) {
              final hosts = ref.watch(
                patchClashConfigProvider.select((state) => state.hosts),
              );
              final storeFix = ref.watch(
                vpnSettingProvider.select((state) => state.storeFix),
              );
              final networkFix = ref.watch(
                vpnSettingProvider.select((state) => state.networkFix),
              );
              return MapInputPage(
                title: 'Hosts',
                map: hosts,
                titleBuilder: (item) => Text(item.key),
                subtitleBuilder: (item) => Text(item.value),
                canDelete: (item) =>
                    !(storeFix && item.key == 'services.googleapis.cn') &&
                    !(networkFix && item.key == 'dns.msftncsi.com'),
                onChange: (value) {
                  ref
                      .read(patchClashConfigProvider.notifier)
                      .updateState((state) => state.copyWith(hosts: value));
                },
              );
            },
          ),
        ),
      ),
      ListItem.next(
        title: Text(appLocalizations.sniffer),
        subtitle: Text(appLocalizations.snifferDesc),
        leading: const Icon(Icons.radar),
        delegate: NextDelegate(
          title: appLocalizations.sniffer,
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
                        .read(patchClashConfigProvider.notifier)
                        .updateState(
                          (state) => state.copyWith(sniffer: defaultSniffer),
                        );
                  },
                  tooltip: appLocalizations.reset,
                  icon: const Icon(Icons.replay),
                );
              },
            ),
          ],
          builder: (_) => const SnifferListView(),
          blur: false,
        ),
      ),
      ListItem.next(
        title: Text(appLocalizations.tunnel),
        subtitle: Text(appLocalizations.tunnelDesc),
        leading: const Icon(Icons.swap_horiz),
        delegate: NextDelegate(
          title: appLocalizations.tunnel,
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
                        .read(patchClashConfigProvider.notifier)
                        .updateState(
                          (state) => state.copyWith(tunnels: defaultTunnel),
                        );
                  },
                  tooltip: appLocalizations.reset,
                  icon: const Icon(Icons.replay),
                );
              },
            ),
          ],
          builder: (_) => const TunnelListView(),
          blur: false,
        ),
      ),
      ListItem.next(
        title: Text(appLocalizations.experimental),
        subtitle: Text(appLocalizations.experimentalDesc),
        leading: const Icon(Icons.science),
        delegate: NextDelegate(
          title: appLocalizations.experimental,
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
                        .read(patchClashConfigProvider.notifier)
                        .updateState(
                          (state) =>
                              state.copyWith(experimental: defaultExperimental),
                        );
                  },
                  tooltip: appLocalizations.reset,
                  icon: const Icon(Icons.replay),
                );
              },
            ),
          ],
          builder: (_) => const ExperimentalListView(),
          blur: false,
        ),
      ),
    ];

    return generateListView(items.separated(const Divider(height: 0)).toList());
  }
}
