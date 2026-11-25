import 'package:bett_box/common/common.dart';
import 'package:bett_box/helper/helper.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

final lanFirewallClientProvider = Provider<HelperClient>((ref) => helperClient);
final lanFirewallCorePathProvider = Provider<String>((ref) => appPath.corePath);

final _statusProvider = FutureProvider.autoDispose<LanFirewallStatus>((ref) {
  final port = ref.watch(patchClashConfigProvider.select((s) => s.mixedPort));
  return ref.watch(lanFirewallClientProvider).lanFirewallStatus(port);
}, retry: (_, _) => null);

class LanFirewallItem extends ConsumerStatefulWidget {
  const LanFirewallItem({super.key});

  @override
  ConsumerState<LanFirewallItem> createState() => _LanFirewallItemState();
}

class _LanFirewallItemState extends ConsumerState<LanFirewallItem> {
  bool _busy = false;

  Future<void> _change({int? allowPort}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final client = ref.read(lanFirewallClientProvider);
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      if (allowPort == null) {
        await client.disableLanFirewall();
      } else {
        final corePath = ref.read(lanFirewallCorePathProvider);
        final legacy =
            ref.read(_statusProvider).asData?.value == LanFirewallStatus.legacy;
        final confirmed = await globalState.showCommonDialog<bool>(
          child: _LanFirewallConfirmation(
            port: allowPort,
            corePath: corePath,
            replacesLegacy: legacy,
          ),
        );
        if (!mounted || confirmed != true) return;
        final config = ref.read(patchClashConfigProvider);
        if (config.mixedPort != allowPort) return;
        await client.allowLanFirewall(allowPort, corePath);
      }
    } catch (error) {
      globalState.showNotifier(error.toString());
    } finally {
      container.invalidate(_statusProvider);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final port = ref.watch(patchClashConfigProvider.select((s) => s.mixedPort));
    final status = ref.watch(_statusProvider);
    final rule = status.asData?.value;
    final canChange = !_busy && !status.isLoading && rule != null;
    final enabled = rule == LanFirewallStatus.scoped;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(appLocalizations.lanFirewall, style: context.textTheme.titleSmall),
        const SizedBox(height: 4),
        status.when(
          skipLoadingOnRefresh: false,
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Tooltip(
            message: error.toString(),
            child: Text(appLocalizations.lanFirewallUnavailable),
          ),
          data: (state) => Text(switch (state) {
            LanFirewallStatus.legacy => appLocalizations.lanFirewallLegacy,
            LanFirewallStatus.inactive => appLocalizations.lanFirewallInactive,
            LanFirewallStatus.scoped => appLocalizations.lanFirewallActive,
            LanFirewallStatus.needsReview => appLocalizations.lanFirewallReview,
          }),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          children: [
            OutlinedButton.icon(
              onPressed: canChange && (enabled || (port > 0 && port <= 65535))
                  ? () => _change(allowPort: enabled ? null : port)
                  : null,
              icon: const AppIcon(
                Icons.admin_panel_settings_outlined,
                size: 18,
              ),
              label: Text(
                enabled
                    ? appLocalizations.lanFirewallDisable
                    : appLocalizations.lanFirewallAllow,
              ),
            ),
            if (rule == LanFirewallStatus.legacy ||
                rule == LanFirewallStatus.needsReview)
              TextButton(
                onPressed: canChange ? () => _change() : null,
                child: Text(appLocalizations.lanFirewallDisable),
              ),
            if (status.hasError)
              TextButton(
                onPressed: () => ref.invalidate(_statusProvider),
                child: Text(appLocalizations.retry),
              ),
          ],
        ),
      ],
    );
  }
}

class _LanFirewallConfirmation extends StatelessWidget {
  const _LanFirewallConfirmation({
    required this.port,
    required this.corePath,
    required this.replacesLegacy,
  });

  final int port;
  final String corePath;
  final bool replacesLegacy;

  @override
  Widget build(BuildContext context) {
    final l10n = appLocalizations;
    final fields = [
      (l10n.port, '$port'),
      (l10n.protocol, 'TCP/UDP'),
      (l10n.networkType, l10n.lanFirewallNetworks),
      (l10n.source, l10n.lanFirewallSources),
      (l10n.program, corePath),
      if (replacesLegacy)
        (l10n.lanFirewallOldRule, l10n.lanFirewallDisableLegacy),
    ];
    return CommonDialog(
      title: l10n.lanFirewallConfirm,
      maxContentWidth: 440,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.confirm),
        ),
      ],
      child: Table(
        columnWidths: const {
          0: MinColumnWidth(IntrinsicColumnWidth(), FractionColumnWidth(0.4)),
          1: FlexColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          for (final (label, value) in fields)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 6,
                    bottom: 6,
                    end: 16,
                  ),
                  child: Text(label),
                ),
                SelectableText(
                  value,
                  maxLines: 1,
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
