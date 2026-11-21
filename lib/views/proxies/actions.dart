import 'dart:async';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/editor.dart';
import 'package:bett_box/pages/media_unlock.dart';
import 'package:bett_box/pages/speed_test.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/profiles/nodes.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

const _uriShareTypes = {
  'shadowsocks',
  'shadowsocksr',
  'vmess',
  'vless',
  'trojan',
  'hysteria',
  'hysteria2',
  'tuic',
  'anytls',
  'socks5',
  'http',
  'mieru',
};

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
  VoidCallback? onLocateGroup,
  Offset? position,
}) async {
  final anchor = position == null ? _anchorOf(context) : null;
  if (position == null && anchor == null) return;
  if (proxyGroup != null) {
    await showContextMenu(
      context,
      position: position,
      anchor: anchor,
      items: _groupProxyItems(context, proxyGroup, proxyGroupSelected),
      header: _ProxyMenuHeader(
        proxyGroup.name,
        type: proxyGroup.type.name,
        onTap: onLocateGroup,
      ),
    );
    return;
  }
  final items = [
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
    _buildConfigItem(context, proxy),
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
  await showContextMenu(
    context,
    position: position,
    anchor: anchor,
    items: items,
    header: _ProxyMenuHeader(proxy.name),
  );
}

List<PopupMenuItemData> _groupProxyItems(
  BuildContext context,
  Group group,
  String selectedName,
) {
  final textTheme = context.textTheme;
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
  return [
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
  ];
}

ProxyNode? _libraryNodeOf(String name) {
  final config = globalState.config;
  final profileId = config.currentProfileId;
  final profile = config.currentProfile;
  if (profileId == null || profile == null) return null;
  for (final node in config.nodes) {
    if (node.name == name &&
        node.activeOf(profileId, managed: profile.isManaged)) {
      return node;
    }
  }
  return null;
}

PopupMenuItemData _buildConfigItem(BuildContext context, Proxy proxy) {
  final node = _libraryNodeOf(proxy.name);
  return PopupMenuItemData(
    icon: Icons.description_outlined,
    label: appLocalizations.configInfo,
    children: [
      PopupMenuItemData(
        icon: Icons.qr_code_2_rounded,
        label: appLocalizations.generateQrCode,
        onPressed: () => _showQrCode(proxy.name),
      ),
      PopupMenuItemData(
        icon: Icons.link_rounded,
        label: appLocalizations.nodeShareUri,
        onPressed: _uriShareTypes.contains(proxy.type.toLowerCase())
            ? () => _copyConfig(proxy.name, uri: true)
            : null,
      ),
      if (node != null)
        PopupMenuItemData(
          icon: Icons.edit_rounded,
          label: appLocalizations.configViewEdit,
          onPressed: () {
            if (!context.mounted) return;
            showEditNode(context, node);
          },
        )
      else
        PopupMenuItemData(
          icon: Icons.code,
          label: appLocalizations.configViewReadOnly,
          onPressed: () => _viewConfig(context, proxy.name),
        ),
      PopupMenuItemData(
        icon: Icons.content_copy,
        label: appLocalizations.configShareYaml,
        onPressed: () => _copyConfig(proxy.name, uri: false),
      ),
    ],
  );
}

Future<({String yaml, String uri})?> _loadConfig(String name) => globalState
    .appController
    .safeRun(() => globalState.getProxyConfig(name), needLoading: true);

Future<void> _copyConfig(String name, {required bool uri}) async {
  final config = await _loadConfig(name);
  if (config == null) return;
  final text = uri ? config.uri : config.yaml;
  if (text.isEmpty) {
    globalState.showNotifier(appLocalizations.uriShareUnsupported);
    return;
  }
  await Clipboard.setData(ClipboardData(text: text));
  globalState.showNotifier(appLocalizations.copySuccess);
}

Future<void> _viewConfig(BuildContext context, String name) async {
  final config = await _loadConfig(name);
  if (config == null || !context.mounted) return;
  await BaseNavigator.push(
    context,
    EditorPage(title: name, content: config.yaml, readOnly: true),
  );
}

Future<void> _showQrCode(String name) async {
  final config = await _loadConfig(name);
  if (config == null) return;
  final isUri = config.uri.isNotEmpty;
  final data = isUri ? config.uri : config.yaml;
  await globalState.showCommonDialog<void>(
    child: Builder(
      builder: (context) {
        final colorScheme = context.colorScheme;
        return CommonDialog(
          title: name,
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: data));
                globalState.showNotifier(appLocalizations.copySuccess);
              },
              child: Text(appLocalizations.copy),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(appLocalizations.close),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrCodeWidget(data: data, size: 220),
              ),
              const SizedBox(height: 14),
              Text(
                isUri ? 'URI' : 'YAML',
                style: context.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    ),
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
      unawaited(clashCore.stopToolProxy());
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
  final String? type;
  final VoidCallback? onTap;

  const _ProxyMenuHeader(this.name, {this.type, this.onTap});

  void _handleTap(BuildContext context, VoidCallback onTap) {
    final route = ModalRoute.of(context);
    Navigator.of(context).pop();
    if (route == null) {
      onTap();
      return;
    }
    route.completed.then((_) => onTap());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final style = context.textTheme.bodyMedium?.copyWith(fontSize: 15);
    final type = this.type;
    final onTap = this.onTap;
    final content = Padding(
      padding: EdgeInsets.fromLTRB(16, 12, onTap == null ? 22 : 12, 10),
      child: Row(
        children: [
          Flexible(
            child: EmojiText(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (type != null)
            Text(
              ' - $type',
              style: style?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          if (onTap != null) ...[
            const Spacer(),
            AppIcon(
              Icons.chevron_right_rounded,
              size: 22,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      customBorder: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onTap: () => _handleTap(context, onTap),
      child: content,
    );
  }
}
