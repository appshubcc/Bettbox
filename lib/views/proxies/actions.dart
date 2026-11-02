import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/media_unlock.dart';
import 'package:bett_box/pages/speed_test.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showProxyActions(
  BuildContext context, {
  required String groupName,
  required GroupType groupType,
  required Proxy proxy,
  required String? testUrl,
  required bool locked,
  required bool coreRunning,
  Group? proxyGroup,
  String proxyGroupSelected = '',
  Offset? position,
}) async {
  final items = [
    if (proxyGroup != null)
      _buildGroupItem(context, proxyGroup, proxyGroupSelected),
    PopupMenuItemData(
      icon: Icons.speed_rounded,
      label: appLocalizations.speedTest,
      onPressed: () {
        if (!context.mounted) return;
        if (globalState.appState.viewMode != ViewMode.mobile) {
          BaseNavigator.push(context, SpeedTestPage(initialProxy: proxy.name));
          return;
        }
        showSheet<void>(
          context: context,
          props: const SheetProps(initialFraction: 0.86),
          builder: (_, type) =>
              SpeedTestPage(initialProxy: proxy.name, type: type),
        );
      },
    ),
    PopupMenuItemData(
      icon: Icons.travel_explore_rounded,
      label: appLocalizations.mediaUnlock,
      onPressed: coreRunning
          ? () {
              if (!context.mounted) return;
              showNodeMediaUnlock(context, proxy.name);
            }
          : null,
    ),
    PopupMenuItemData(
      icon: Icons.shield_outlined,
      label: appLocalizations.ipRiskCheck,
      onPressed: coreRunning ? () => _checkIpRisk(context, proxy.name) : null,
    ),
    if (groupType.isComputedSelected)
      PopupMenuItemData(
        icon: locked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
        label: locked
            ? appLocalizations.unlockProxy
            : appLocalizations.lockProxy,
        onPressed: () {
          final next = locked ? '' : proxy.name;
          final appController = globalState.appController;
          appController.updateCurrentSelectedMap(groupName, next);
          appController.changeProxyDebounce(groupName, next);
        },
      ),
  ];
  final anchor = position == null ? _anchorOf(context) : null;
  if (position == null && anchor == null) return;
  await showContextMenu(
    context,
    position: position,
    anchor: anchor,
    items: items,
    header: proxyGroup == null ? _ProxyMenuHeader(proxy.name) : null,
  );
}

PopupMenuItemData _buildGroupItem(
  BuildContext context,
  Group group,
  String selectedName,
) {
  final textTheme = context.textTheme;
  final colorScheme = context.colorScheme;
  final appController = globalState.appController;
  final current = group.getCurrentSelectedName(selectedName);
  final selectable =
      group.type == GroupType.Selector || group.type.isComputedSelected;
  final proxies = appController.getSortProxies(
    proxies: group.all,
    sortType: globalState.config.proxiesStyle.sortType,
    testUrl: group.testUrl,
  );
  final delayStyle = textTheme.labelSmall?.copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  return PopupMenuItemData(
    label: group.name,
    onPressed: null,
    trailing: current.isEmpty
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: EmojiText(
                  current,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
    children: [
      for (final item in proxies)
        PopupMenuItemData(
          icon: item.name == current
              ? Icons.check_circle_rounded
              : Icons.circle_outlined,
          label: item.name,
          trailing: switch (appController.getTrayProxyDelay(
            proxyName: item.name,
            testUrl: group.testUrl,
          )) {
            null => null,
            0 => Text('...', style: delayStyle),
            final delay => Text(
              delay < 0 ? '×' : '${delay}ms',
              style: delayStyle?.copyWith(color: utils.getDelayColor(delay)),
            ),
          },
          onPressed: () {
            if (!selectable) {
              globalState.showNotifier(appLocalizations.notSelectedTip);
              return;
            }
            appController.updateCurrentSelectedMap(group.name, item.name);
            appController.changeProxyDebounce(group.name, item.name);
          },
        ),
    ],
  );
}

Rect? _anchorOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

Future<void> _checkIpRisk(BuildContext context, String proxyName) async {
  final info = await globalState.appController.safeRun(() async {
    final port = await clashCore.startToolProxy();
    try {
      if (port <= 0) throw appLocalizations.checkFailed;
      final res = await request.checkIp(
        proxy: clashCore.toolProxyRoute(proxyName, port),
        timeout: const Duration(seconds: 8),
      );
      final info = res.data;
      if (res.isError || info == null) {
        throw res.message.isEmpty ? appLocalizations.checkFailed : res.message;
      }
      return info;
    } finally {
      clashCore.stopToolProxy();
    }
  }, needLoading: true);
  if (info == null || !context.mounted) return;
  await showIpDetailDialog(
    context,
    info.ip,
    preloaded: info,
    showRisk: true,
    followRiskSetting: false,
  );
}

class _ProxyMenuHeader extends StatelessWidget {
  final String name;

  const _ProxyMenuHeader(this.name);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 22, 8),
      child: Row(
        children: [
          Icon(Icons.public_rounded, size: 20, color: colorScheme.primary),
          const SizedBox(width: 14),
          Flexible(
            child: EmojiText(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
