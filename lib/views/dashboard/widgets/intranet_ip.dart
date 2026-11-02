import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/providers/app.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tile.dart';

class IntranetIP extends StatelessWidget {
  final DashboardTileSize? size;

  const IntranetIP({super.key, this.size});

  void _showMoreIpInfoDialog(BuildContext context) {
    globalState.showAdaptiveSheet(child: const _IntranetIpInfoDialog());
  }

  Widget _buildItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value.isEmpty ? '—' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.toLight,
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, DashboardTileSize size) {
    final isTall = size == DashboardTileSize.tall;
    return Consumer(
      builder: (_, ref, _) {
        final info = ref.watch(localNetworkProvider);
        final ip = info == null
            ? '…'
            : info.ip.isEmpty
            ? appLocalizations.noNetwork
            : info.ip;
        final local = [
          appLocalizations.natLocalIp,
          if (info?.type.isNotEmpty ?? false) info?.type,
        ].join(' · ');
        final gateway = info?.gateway ?? '';
        return DashboardTileCard(
          size: size,
          info: Info(
            label: appLocalizations.intranetIP,
            iconData: Icons.devices,
          ),
          mark: DashboardDecor.icon(context, Icons.devices, 80),
          markBottom: isTall,
          markAngle: isTall ? 0.3 : -0.3,
          onPressed: () => _showMoreIpInfoDialog(context),
          child: isTall
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final item in [
                        _buildItem(context, local, ip),
                        _buildItem(
                          context,
                          appLocalizations.defaultGateway,
                          gateway,
                        ),
                        _buildItem(
                          context,
                          appLocalizations.systemDns,
                          info?.dns.firstOrNull ?? '',
                        ),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: item,
                        ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 48, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (info?.type.isNotEmpty ?? false) ...[
                            Text(
                              info?.type ?? '',
                              maxLines: 1,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                ip,
                                maxLines: 1,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        [
                          if (gateway.isNotEmpty)
                            '${appLocalizations.defaultGateway} $gateway',
                          if (info?.dns.firstOrNull case final dns?)
                            '${appLocalizations.systemDns} $dns',
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = this.size;
    if (size != null) return _buildTile(context, size);
    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: CommonCard(
        info: Info(label: appLocalizations.intranetIP, iconData: Icons.devices),
        onPressed: () => _showMoreIpInfoDialog(context),
        child: Container(
          padding: baseInfoEdgeInsets.copyWith(top: 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: globalState.measure.bodyMediumHeight + 2,
                child: Consumer(
                  builder: (_, ref, _) {
                    final localIp = ref.watch(
                      localNetworkProvider.select((state) => state?.ip),
                    );
                    return FadeThroughBox(
                      child: localIp != null
                          ? TooltipText(
                              text: Text(
                                localIp.isNotEmpty
                                    ? localIp
                                    : appLocalizations.noNetwork,
                                style: context.textTheme.bodyMedium?.toLight
                                    .adjustSize(1),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(2),
                              child: const AspectRatio(
                                aspectRatio: 1,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntranetIpInfoDialog extends ConsumerStatefulWidget {
  const _IntranetIpInfoDialog();

  @override
  ConsumerState<_IntranetIpInfoDialog> createState() =>
      _IntranetIpInfoDialogState();
}

class _IntranetIpInfoDialogState extends ConsumerState<_IntranetIpInfoDialog> {
  @override
  void initState() {
    super.initState();
    globalState.appController.updateLocalNetwork(silent: true);
  }

  Widget _buildSectionHeader(String title, {bool isFirst = false}) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 2 : 14, bottom: 8),
      child: Text(
        '[ $title ]',
        style: context.textTheme.labelMedium?.copyWith(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required Color iconColor,
    String label = '',
    required String value,
    Widget? action,
    Widget? customValue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: panelTileDecoration(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: label.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      customValue ??
                          SelectableText(
                            value,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                          ),
                    ],
                  )
                : (customValue ??
                      SelectableText(
                        value,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      )),
          ),
          if (action != null) ...[const SizedBox(width: 4), action],
        ],
      ),
    );
  }

  Widget _buildLanSharingTile(bool allowLan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: panelTileDecoration(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (allowLan ? Colors.green : context.colorScheme.outline)
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.share_rounded,
              size: 14,
              color: allowLan ? Colors.green : context.colorScheme.outline,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              appLocalizations.lanSharing,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Switch(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: allowLan,
            onChanged: (value) => ref
                .read(patchClashConfigProvider.notifier)
                .updateState((state) => state.copyWith(allowLan: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      icon: Icon(icon, size: 15, color: context.colorScheme.onSurfaceVariant),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }

  bool _canOpenGateway(String gateway, String networkType) {
    if (gateway.isEmpty || gateway == '0.0.0.0') return false;

    final lowerType = networkType.toLowerCase();
    if (lowerType.contains('cellular')) {
      return false;
    }

    final parts = gateway.split('.');
    if (parts.length != 4) return false;

    final o1 = int.tryParse(parts[0]);
    final o2 = int.tryParse(parts[1]);
    final o3 = int.tryParse(parts[2]);
    final o4 = int.tryParse(parts[3]);

    if (o1 == null || o2 == null || o3 == null || o4 == null) return false;
    if (o1 < 0 ||
        o1 > 255 ||
        o2 < 0 ||
        o2 > 255 ||
        o3 < 0 ||
        o3 > 255 ||
        o4 < 0 ||
        o4 > 255) {
      return false;
    }

    if (o1 == 127 || (o1 == 169 && o2 == 254)) return false;
    if (o1 == 100 && o2 >= 64 && o2 <= 127) return false;
    if (o1 == 198 && (o2 == 18 || o2 == 19)) return false;

    if (o1 == 192 && o2 == 168) return true;
    if (o1 == 10) return true;
    if (o1 == 172 && o2 >= 16 && o2 <= 31) return true;

    return false;
  }

  IconData _resolveNetworkIcon(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('ethernet')) {
      return Icons.lan_rounded;
    }
    if (lower.contains('cellular')) {
      return Icons.signal_cellular_alt_rounded;
    }
    return Icons.wifi_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final network = ref.watch(localNetworkProvider);
    final allowLan = ref.watch(
      patchClashConfigProvider.select((state) => state.allowLan),
    );
    final mixedPort = ref.watch(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );

    final placeholder = network == null ? '...' : '-';
    final type = network?.type ?? '';
    final interfaceName = network?.interfaceName ?? '';
    final localIp = network?.ip ?? '';
    final gateway = network?.gateway ?? '';
    final networkType = [
      type,
      if (interfaceName.toLowerCase() != type.toLowerCase())
        type.isEmpty ? interfaceName : '($interfaceName)',
    ].where((e) => e.isNotEmpty).join(' ');
    final canOpenGateway = _canOpenGateway(gateway, type);
    final sharedAddress = '$localIp:$mixedPort';
    final systemDnsText = network?.dns.join(', ') ?? '';

    return CommonDialog(
      title: appLocalizations.moreIpInfo,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      actions: isInBottomSheet(context)
          ? null
          : [
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Text(appLocalizations.confirm),
              ),
            ],
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              appLocalizations.intranetAndGateway,
              isFirst: true,
            ),
            _buildStatTile(
              icon: _resolveNetworkIcon(type),
              iconColor: context.colorScheme.primary,
              label: appLocalizations.networkType,
              value: networkType.isNotEmpty
                  ? networkType
                  : (network == null ? '...' : appLocalizations.noNetwork),
            ),
            const SizedBox(height: 8),
            _buildStatTile(
              icon: Icons.devices_rounded,
              iconColor: context.colorScheme.secondary,
              label: appLocalizations.intranetIP,
              value: localIp.isNotEmpty ? localIp : placeholder,
            ),
            const SizedBox(height: 8),
            _buildStatTile(
              icon: Icons.router_rounded,
              iconColor: context.colorScheme.tertiary,
              label: appLocalizations.defaultGateway,
              value: gateway.isNotEmpty ? gateway : placeholder,
              action: canOpenGateway
                  ? _buildIconButton(
                      icon: Icons.open_in_new,
                      tooltip: appLocalizations.openRouterAdmin,
                      onPressed: () {
                        globalState.openUrl('http://$gateway');
                      },
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            _buildStatTile(
              icon: Icons.dns_rounded,
              iconColor: context.colorScheme.primary,
              label: appLocalizations.systemDns,
              value: systemDnsText,
              customValue: SelectableText(
                systemDnsText.isNotEmpty ? systemDnsText : placeholder,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  height: 1.3,
                ),
              ),
            ),
            _buildSectionHeader(appLocalizations.allowLan),
            _buildLanSharingTile(allowLan),
            if (allowLan && canOpenGateway && localIp.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildStatTile(
                icon: Icons.cable_rounded,
                iconColor: context.colorScheme.primary,
                value: sharedAddress,
                action: _buildIconButton(
                  icon: Icons.copy_rounded,
                  tooltip: appLocalizations.copy,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: sharedAddress));
                    if (context.mounted) {
                      context.showNotifier(appLocalizations.copySuccess);
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
