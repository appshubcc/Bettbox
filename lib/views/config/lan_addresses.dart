import 'dart:io';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/common/windows_lan_addresses.dart';
import 'package:bett_box/models/common.dart';
import 'package:bett_box/providers/app.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/widgets/sheet.dart' show panelTileDecoration;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

final lanInterfacesProvider = FutureProvider.autoDispose<List<CoreInterface>>((
  ref,
) {
  ref.watch(localNetworkProvider);
  if (Platform.isWindows) return getWindowsLanAddresses();
  return utils.getNetworkInterfaces(
    includeVirtual: true,
    includeLinkLocal: true,
  );
}, retry: (_, _) => null);

class LanAddresses extends ConsumerWidget {
  const LanAddresses({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interfaces = ref.watch(lanInterfacesProvider);
    final (allowLan, port) = ref.watch(
      patchClashConfigProvider.select((s) => (s.allowLan, s.mixedPort)),
    );
    final activePort = allowLan && port > 0 ? port : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                appLocalizations.lanAddresses,
                style: context.textTheme.titleSmall,
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: MaterialLocalizations.of(context)
                  .refreshIndicatorSemanticLabel,
              onPressed: interfaces.isLoading
                  ? null
                  : () => ref.invalidate(lanInterfacesProvider),
              icon: const AppIcon(Icons.refresh, size: 18),
            ),
          ],
        ),
        interfaces.when(
          skipLoadingOnRefresh: false,
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Tooltip(
            message: error.toString(),
            child: Text(appLocalizations.networkErrorRetryLater),
          ),
          data: (items) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (items.isEmpty) Text(appLocalizations.lanNoAddresses),
              for (final item in items) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(item.name, style: context.textTheme.labelMedium),
                ),
                for (final ip
                    in item.addresses.map((ip) => ip.split('%').first).toSet())
                  _AddressRow(address: ip, port: activePort),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({required this.address, required this.port});

  final String address;
  final int? port;

  @override
  Widget build(BuildContext context) {
    final host = address.contains(':') ? '[$address]' : address;
    final value = port == null ? address : '$host:$port';
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
      decoration: panelTileDecoration(context),
      child: Row(
        children: [
          Expanded(child: SelectableText(value)),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: appLocalizations.copy,
            icon: const AppIcon(Icons.copy_rounded, size: 16),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (context.mounted) {
                await context.showNotifier(appLocalizations.copySuccess);
              }
            },
          ),
        ],
      ),
    );
  }
}
