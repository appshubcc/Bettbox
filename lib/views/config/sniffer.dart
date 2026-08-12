import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/clash_config.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverrideSnifferItem extends ConsumerWidget {
  const OverrideSnifferItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final override = ref.watch(overrideSnifferProvider);
    return ListItem.switchItem(
      title: Text(appLocalizations.overrideSniffer),
      subtitle: Text(appLocalizations.overrideSnifferDesc),
      delegate: SwitchDelegate(
        value: override,
        onChanged: (bool value) async {
          ref.read(overrideSnifferProvider.notifier).value = value;
        },
      ),
    );
  }
}

class SnifferStatusItem extends ConsumerWidget {
  const SnifferStatusItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final enable = ref.watch(
      patchClashConfigProvider.select((state) => state.sniffer.enable),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.snifferStatus),
      subtitle: Text(appLocalizations.snifferStatusDesc),
      delegate: SwitchDelegate(
        value: enable,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith.sniffer(enable: value));
        },
      ),
    );
  }
}

class ForceDnsMappingItem extends ConsumerWidget {
  const ForceDnsMappingItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final forceDnsMapping = ref.watch(
      patchClashConfigProvider.select((state) => state.sniffer.forceDnsMapping),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.forceDnsMapping),
      delegate: SwitchDelegate(
        value: forceDnsMapping,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState(
                (state) => state.copyWith.sniffer(forceDnsMapping: value),
              );
        },
      ),
    );
  }
}

class ParsePureIpItem extends ConsumerWidget {
  const ParsePureIpItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final parsePureIp = ref.watch(
      patchClashConfigProvider.select((state) => state.sniffer.parsePureIp),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.parsePureIp),
      delegate: SwitchDelegate(
        value: parsePureIp,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState(
                (state) => state.copyWith.sniffer(parsePureIp: value),
              );
        },
      ),
    );
  }
}

class OverrideDestinationItem extends ConsumerWidget {
  const OverrideDestinationItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final overrideDest = ref.watch(
      patchClashConfigProvider.select((state) => state.sniffer.overrideDest),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.overrideDestination),
      delegate: SwitchDelegate(
        value: overrideDest,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState(
                (state) => state.copyWith.sniffer(overrideDest: value),
              );
        },
      ),
    );
  }
}

class HttpPortSnifferItem extends ConsumerWidget {
  const HttpPortSnifferItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final httpConfig = ref.watch(
      patchClashConfigProvider.select((state) => state.sniffer.sniff['HTTP']),
    );
    final ports = httpConfig?.ports.join(', ') ?? '';

    return ListItem(
      title: Text(appLocalizations.httpPortSniffer),
      subtitle: Text(ports.isEmpty ? '80, 8080-8880' : ports),
      onTap: () => _showHttpDialog(context, ref, httpConfig),
    );
  }

  void _showHttpDialog(
    BuildContext context,
    WidgetRef ref,
    SnifferConfig? httpConfig,
  ) async {
    final ports = httpConfig?.ports.join(', ') ?? '';
    final overrideDest = httpConfig?.overrideDest ?? true; // HTTP 默认为 true

    await globalState.showCommonDialog(
      child: _SnifferPortDialog(
        title: appLocalizations.httpPortSniffer,
        ports: ports,
        overrideDest: overrideDest,
        onSave: (newPorts, newOverrideDest) {
          final portList = newPorts
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          final newSniff = Map<String, SnifferConfig>.from(
            ref.read(patchClashConfigProvider).sniffer.sniff,
          );
          newSniff['HTTP'] = SnifferConfig(
            ports: portList,
            overrideDest: newOverrideDest,
          );
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith.sniffer(sniff: newSniff));
        },
      ),
    );
  }
}

class TlsPortSnifferItem extends ConsumerWidget {
  const TlsPortSnifferItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final tlsConfig = ref.watch(
      patchClashConfigProvider.select((state) => state.sniffer.sniff['TLS']),
    );
    final ports = tlsConfig?.ports.join(', ') ?? '';

    return ListItem(
      title: Text(appLocalizations.tlsPortSniffer),
      subtitle: Text(ports.isEmpty ? '443, 8443' : ports),
      onTap: () => _showTlsDialog(context, ref, tlsConfig),
    );
  }

  void _showTlsDialog(
    BuildContext context,
    WidgetRef ref,
    SnifferConfig? tlsConfig,
  ) async {
    final ports = tlsConfig?.ports.join(', ') ?? '';
    final overrideDest = tlsConfig?.overrideDest ?? false;

    await globalState.showCommonDialog(
      child: _SnifferPortDialog(
        title: appLocalizations.tlsPortSniffer,
        ports: ports,
        overrideDest: overrideDest,
        onSave: (newPorts, newOverrideDest) {
          final portList = newPorts
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          final newSniff = Map<String, SnifferConfig>.from(
            ref.read(patchClashConfigProvider).sniffer.sniff,
          );
          newSniff['TLS'] = SnifferConfig(
            ports: portList,
            overrideDest: newOverrideDest,
          );
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith.sniffer(sniff: newSniff));
        },
      ),
    );
  }
}

class QuicPortSnifferItem extends ConsumerWidget {
  const QuicPortSnifferItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final quicConfig = ref.watch(
      patchClashConfigProvider.select((state) => state.sniffer.sniff['QUIC']),
    );
    final ports = quicConfig?.ports.join(', ') ?? '';

    return ListItem(
      title: Text(appLocalizations.quicPortSniffer),
      subtitle: Text(ports.isEmpty ? '443, 8443' : ports),
      onTap: () => _showQuicDialog(context, ref, quicConfig),
    );
  }

  void _showQuicDialog(
    BuildContext context,
    WidgetRef ref,
    SnifferConfig? quicConfig,
  ) async {
    final ports = quicConfig?.ports.join(', ') ?? '';
    final overrideDest = quicConfig?.overrideDest ?? false;

    await globalState.showCommonDialog(
      child: _SnifferPortDialog(
        title: appLocalizations.quicPortSniffer,
        ports: ports,
        overrideDest: overrideDest,
        onSave: (newPorts, newOverrideDest) {
          final portList = newPorts
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          final newSniff = Map<String, SnifferConfig>.from(
            ref.read(patchClashConfigProvider).sniffer.sniff,
          );
          newSniff['QUIC'] = SnifferConfig(
            ports: portList,
            overrideDest: newOverrideDest,
          );
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith.sniffer(sniff: newSniff));
        },
      ),
    );
  }
}

class _SnifferPortDialog extends StatefulWidget {
  final String title;
  final String ports;
  final bool overrideDest;
  final Function(String ports, bool overrideDest) onSave;

  const _SnifferPortDialog({
    required this.title,
    required this.ports,
    required this.overrideDest,
    required this.onSave,
  });

  @override
  State<_SnifferPortDialog> createState() => _SnifferPortDialogState();
}

class _SnifferPortDialogState extends State<_SnifferPortDialog> {
  late TextEditingController _portsController;
  late bool _overrideDest;

  @override
  void initState() {
    super.initState();
    _portsController = TextEditingController(text: widget.ports);
    _overrideDest = widget.overrideDest;
  }

  @override
  void dispose() {
    _portsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: widget.title,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(_portsController.text, _overrideDest);
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.save),
        ),
      ],
      child: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _portsController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.snifferPorts,
                hintText: '443, 8443',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appLocalizations.overrideDestination),
                Switch(
                  value: _overrideDest,
                  onChanged: (value) {
                    setState(() {
                      _overrideDest = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ForceDomainWidget extends ConsumerWidget {
  const ForceDomainWidget({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ListItem.next(
      title: Text(appLocalizations.forceDomain),
      delegate: NextDelegate(
        blur: false,
        title: appLocalizations.forceDomain,
        widget: Consumer(
          builder: (_, ref, _) {
            final forceDomain = ref.watch(
              patchClashConfigProvider.select(
                (state) => state.sniffer.forceDomain,
              ),
            );
            return ListInputPage(
              title: appLocalizations.forceDomain,
              items: forceDomain,
              titleBuilder: (item) => Text(item),
              onChange: (items) {
                ref
                    .read(patchClashConfigProvider.notifier)
                    .updateState(
                      (state) =>
                          state.copyWith.sniffer(forceDomain: List.from(items)),
                    );
              },
            );
          },
        ),
      ),
    );
  }
}

class SkipDomainWidget extends ConsumerWidget {
  const SkipDomainWidget({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ListItem.next(
      title: Text(appLocalizations.skipDomain),
      delegate: NextDelegate(
        blur: false,
        title: appLocalizations.skipDomain,
        widget: Consumer(
          builder: (_, ref, _) {
            final skipDomain = ref.watch(
              patchClashConfigProvider.select(
                (state) => state.sniffer.skipDomain,
              ),
            );
            return ListInputPage(
              title: appLocalizations.skipDomain,
              items: skipDomain,
              titleBuilder: (item) => Text(item),
              onChange: (items) {
                ref
                    .read(patchClashConfigProvider.notifier)
                    .updateState(
                      (state) =>
                          state.copyWith.sniffer(skipDomain: List.from(items)),
                    );
              },
            );
          },
        ),
      ),
    );
  }
}

class SkipSrcAddressWidget extends ConsumerWidget {
  const SkipSrcAddressWidget({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ListItem.next(
      title: Text(appLocalizations.skipSrcAddress),
      delegate: NextDelegate(
        blur: false,
        title: appLocalizations.skipSrcAddress,
        widget: Consumer(
          builder: (_, ref, _) {
            final skipSrcAddress = ref.watch(
              patchClashConfigProvider.select(
                (state) => state.sniffer.skipSrcAddress,
              ),
            );
            return ListInputPage(
              title: appLocalizations.skipSrcAddress,
              items: skipSrcAddress,
              titleBuilder: (item) => Text(item),
              onChange: (items) {
                ref
                    .read(patchClashConfigProvider.notifier)
                    .updateState(
                      (state) => state.copyWith.sniffer(
                        skipSrcAddress: List.from(items),
                      ),
                    );
              },
            );
          },
        ),
      ),
    );
  }
}

class SkipDstAddressWidget extends ConsumerWidget {
  const SkipDstAddressWidget({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ListItem.next(
      title: Text(appLocalizations.skipDstAddress),
      delegate: NextDelegate(
        blur: false,
        title: appLocalizations.skipDstAddress,
        widget: Consumer(
          builder: (_, ref, _) {
            final skipDstAddress = ref.watch(
              patchClashConfigProvider.select(
                (state) => state.sniffer.skipDstAddress,
              ),
            );
            return ListInputPage(
              title: appLocalizations.skipDstAddress,
              items: skipDstAddress,
              titleBuilder: (item) => Text(item),
              onChange: (items) {
                ref
                    .read(patchClashConfigProvider.notifier)
                    .updateState(
                      (state) => state.copyWith.sniffer(
                        skipDstAddress: List.from(items),
                      ),
                    );
              },
            );
          },
        ),
      ),
    );
  }
}

final snifferItems = <Widget>[
  const OverrideSnifferItem(),
  ...generateSection(
    title: appLocalizations.options,
    items: const [
      SnifferStatusItem(),
      ForceDnsMappingItem(),
      ParsePureIpItem(),
      OverrideDestinationItem(),
      HttpPortSnifferItem(),
      TlsPortSnifferItem(),
      QuicPortSnifferItem(),
      ForceDomainWidget(),
      SkipDomainWidget(),
      SkipSrcAddressWidget(),
      SkipDstAddressWidget(),
    ],
  ),
];

class SnifferListView extends ConsumerWidget {
  const SnifferListView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return generateListView(snifferItems);
  }
}
