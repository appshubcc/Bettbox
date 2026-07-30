import 'dart:async';
import 'dart:io';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/about.dart';
import 'package:bett_box/views/access.dart';
import 'package:bett_box/views/application_setting.dart';
import 'package:bett_box/views/config/config.dart';
import 'package:bett_box/views/config/dns.dart';
import 'package:bett_box/views/config/experimental.dart';
import 'package:bett_box/views/config/general.dart';
import 'package:bett_box/views/config/network.dart';
import 'package:bett_box/views/config/ntp.dart';
import 'package:bett_box/views/config/sniffer.dart';
import 'package:bett_box/views/config/tunnel.dart';
import 'package:bett_box/views/connection/connections.dart';
import 'package:bett_box/views/hotkey.dart';
import 'package:bett_box/views/other_setting.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' show dirname, join;

import 'backup_and_recovery.dart';
import 'developer.dart';
import 'theme.dart';

class _SearchItem {
  final String title;
  final String? subtitle;
  final String category;
  final Widget? leading;
  final void Function(BuildContext context, WidgetRef ref) onTap;

  const _SearchItem({
    required this.title,
    this.subtitle,
    required this.category,
    this.leading,
    required this.onTap,
  });
}

class _GeneralListView extends StatelessWidget {
  const _GeneralListView();

  @override
  Widget build(BuildContext context) {
    return generateListView(generalItems);
  }
}

class ToolsView extends ConsumerStatefulWidget {
  const ToolsView({super.key});

  @override
  ConsumerState<ToolsView> createState() => _ToolViewState();
}

class _ToolViewState extends ConsumerState<ToolsView> {
  Widget _buildNavigationPage(NavigationItem navigationItem) {
    if (navigationItem.label == PageLabel.connections) {
      return const ConnectionsView(respectCurrentPage: false);
    }
    return navigationItem.builder(context);
  }

  Widget _buildNavigationMenuItem(NavigationItem navigationItem) {
    return ListItem.next(
      leading: navigationItem.icon,
      title: Text(Intl.message(navigationItem.label.name)),
      subtitle: navigationItem.description != null
          ? Text(Intl.message(navigationItem.description!))
          : null,
      delegate: NextDelegate(
        title: Intl.message(navigationItem.label.name),
        builder: (_) => _buildNavigationPage(navigationItem),
        wrap: false,
      ),
    );
  }

  Widget _buildModernSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListHeader(
            title: title,
            padding: const EdgeInsets.only(left: 8, bottom: 8),
          ),
          CommonCard(
            type: CommonCardType.filled,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  items[i],
                  if (i != items.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: context.colorScheme.outlineVariant.withValues(
                        alpha:
                            context.colorScheme.brightness == Brightness.light
                            ? 0.3
                            : 0.2,
                      ),
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _query = '';
  List<_SearchItem>? _cachedSearchItems;
  String _cachedMoreItemsKey = '';
  Timer? _searchTimer;

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchTimer?.cancel();
    if (query.isEmpty) {
      if (_query.isNotEmpty || _cachedSearchItems != null) {
        setState(() {
          _query = '';
          _cachedSearchItems = null;
          _cachedMoreItemsKey = '';
        });
      }
      return;
    }
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _query = query.toLowerCase();
      });
    });
  }

  String _moreItemsKey(List<NavigationItem> items) {
    return items
        .map((item) => '${item.label.name}\x00${item.description ?? ''}')
        .join('\x01');
  }

  List<_SearchItem> _getSearchItems(List<NavigationItem> moreItems) {
    if (_query.isEmpty) {
      return const [];
    }
    final key = _moreItemsKey(moreItems);
    if (_cachedSearchItems != null && _cachedMoreItemsKey == key) {
      return _cachedSearchItems!;
    }
    _cachedMoreItemsKey = key;
    _cachedSearchItems = _buildSearchItems(moreItems);
    return _cachedSearchItems!;
  }

  void _pushPage(BuildContext context, String title, Widget page) {
    showExtend(
      context,
      builder: (_, type) =>
          AdaptiveSheetScaffold(type: type, title: title, body: page),
    );
  }

  List<_SearchItem> _buildSearchItems(List<NavigationItem> moreItems) {
    final items = <_SearchItem>[];
    final settingsCategory = appLocalizations.settings;
    final configCategory = '$settingsCategory/${appLocalizations.basicConfig}';
    final themeCategory = '$settingsCategory/${appLocalizations.theme}';
    final backupCategory =
        '$settingsCategory/${appLocalizations.backupAndRecovery}';
    final appCategory = '$settingsCategory/${appLocalizations.application}';
    final otherCategory = appLocalizations.other;
    final otherSettingsCategory =
        '$settingsCategory/${appLocalizations.otherSettings}';

    for (final item in moreItems) {
      items.add(
        _SearchItem(
          title: Intl.message(item.label.name),
          subtitle: item.description != null
              ? Intl.message(item.description!)
              : null,
          category: appLocalizations.more,
          leading: item.icon,
          onTap: (context, _) => _pushPage(
            context,
            Intl.message(item.label.name),
            _buildNavigationPage(item),
          ),
        ),
      );
    }

    items.addAll([
      _SearchItem(
        title: appLocalizations.language,
        subtitle: appLocalizations.language,
        category: settingsCategory,
        leading: const Icon(Icons.language_outlined),
        onTap: (context, _) =>
            _pushPage(context, appLocalizations.language, const _LocaleItem()),
      ),
      _SearchItem(
        title: appLocalizations.theme,
        subtitle: appLocalizations.themeDesc,
        category: settingsCategory,
        leading: const Icon(Icons.style),
        onTap: (context, _) =>
            _pushPage(context, appLocalizations.theme, const ThemeView()),
      ),
      _SearchItem(
        title: appLocalizations.backupAndRecovery,
        subtitle: appLocalizations.backupAndRecoveryDesc,
        category: settingsCategory,
        leading: const Icon(Icons.cloud_sync),
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.backupAndRecovery,
          const BackupAndRecovery(),
        ),
      ),
      if (system.isDesktop)
        _SearchItem(
          title: appLocalizations.hotkeyManagement,
          subtitle: appLocalizations.hotkeyManagementDesc,
          category: settingsCategory,
          leading: const Icon(Icons.keyboard),
          onTap: (context, _) => _pushPage(
            context,
            appLocalizations.hotkeyManagement,
            const HotKeyView(),
          ),
        ),
      if (system.isWindows)
        _SearchItem(
          title: appLocalizations.loopback,
          subtitle: appLocalizations.loopbackDesc,
          category: settingsCategory,
          leading: const Icon(Icons.lock),
          onTap: (context, _) {
            windows?.runas(
              '"${join(dirname(Platform.resolvedExecutable), "WindowsLoopbackManager.exe")}"',
              '',
              showWindow: true,
            );
          },
        ),
      if (system.isAndroid)
        _SearchItem(
          title: appLocalizations.accessControl,
          subtitle: appLocalizations.accessControlDesc,
          category: settingsCategory,
          leading: const Icon(Icons.view_list),
          onTap: (context, _) => _pushPage(
            context,
            appLocalizations.appAccessControl,
            const AccessView(),
          ),
        ),
      _SearchItem(
        title: appLocalizations.basicConfig,
        subtitle: appLocalizations.basicConfigDesc,
        category: settingsCategory,
        leading: const Icon(Icons.edit),
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.basicConfig,
          const ConfigView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.otherSettings,
        subtitle: appLocalizations.otherSettingsDesc,
        category: settingsCategory,
        leading: const Icon(Icons.settings_suggest_outlined),
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.otherSettings,
          const OtherSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.application,
        subtitle: appLocalizations.applicationDesc,
        category: settingsCategory,
        leading: const Icon(Icons.settings),
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.application,
          const ApplicationSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.disclaimer,
        category: otherCategory,
        leading: const Icon(Icons.gavel),
        onTap: (context, _) async {
          final accepted = await globalState.appController.showDisclaimer();
          if (!accepted) {
            globalState.appController.handleExit();
          }
        },
      ),
      _SearchItem(
        title: appLocalizations.about,
        category: otherCategory,
        leading: const Icon(Icons.info),
        onTap: (context, _) =>
            _pushPage(context, appLocalizations.about, const AboutView()),
      ),
      _SearchItem(
        title: appLocalizations.developerMode,
        category: otherCategory,
        leading: const Icon(Icons.developer_board),
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.developerMode,
          const DeveloperView(),
        ),
      ),
    ]);

    items.addAll([
      _SearchItem(
        title: appLocalizations.themeMode,
        category: themeCategory,
        onTap: (context, _) =>
            _pushPage(context, appLocalizations.theme, const ThemeView()),
      ),
      _SearchItem(
        title: appLocalizations.themeColor,
        category: themeCategory,
        onTap: (context, _) =>
            _pushPage(context, appLocalizations.theme, const ThemeView()),
      ),
      _SearchItem(
        title: appLocalizations.pureBlackMode,
        category: themeCategory,
        onTap: (context, _) =>
            _pushPage(context, appLocalizations.theme, const ThemeView()),
      ),
      _SearchItem(
        title: appLocalizations.harmonyFont,
        subtitle: appLocalizations.harmonyFontDesc,
        category: themeCategory,
        onTap: (context, _) =>
            _pushPage(context, appLocalizations.theme, const ThemeView()),
      ),
      _SearchItem(
        title: appLocalizations.lightIcon,
        subtitle: appLocalizations.lightIconDesc,
        category: themeCategory,
        onTap: (context, _) =>
            _pushPage(context, appLocalizations.theme, const ThemeView()),
      ),
      if (system.isWindows)
        _SearchItem(
          title: appLocalizations.trayIconInvert,
          subtitle: appLocalizations.trayIconInvertDesc,
          category: themeCategory,
          onTap: (context, _) =>
              _pushPage(context, appLocalizations.theme, const ThemeView()),
        ),
      _SearchItem(
        title: appLocalizations.textScale,
        category: themeCategory,
        onTap: (context, _) =>
            _pushPage(context, appLocalizations.theme, const ThemeView()),
      ),
    ]);

    items.addAll([
      _SearchItem(
        title: appLocalizations.remote,
        category: backupCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.backupAndRecovery,
          const BackupAndRecovery(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.local,
        category: backupCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.backupAndRecovery,
          const BackupAndRecovery(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.recoveryStrategy,
        category: backupCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.backupAndRecovery,
          const BackupAndRecovery(),
        ),
      ),
    ]);

    items.addAll([
      _SearchItem(
        title: appLocalizations.autoLaunch,
        subtitle: appLocalizations.autoLaunchDesc,
        category: appCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.application,
          const ApplicationSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.silentLaunch,
        subtitle: appLocalizations.silentLaunchDesc,
        category: appCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.application,
          const ApplicationSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.autoRun,
        subtitle: appLocalizations.autoRunDesc,
        category: appCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.application,
          const ApplicationSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.exclude,
        subtitle: appLocalizations.excludeDesc,
        category: appCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.application,
          const ApplicationSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.alwaysShowTitleBar,
        subtitle: appLocalizations.alwaysShowTitleBarDesc,
        category: appCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.application,
          const ApplicationSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.showStartSwitch,
        subtitle: appLocalizations.showStartSwitchDesc,
        category: appCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.application,
          const ApplicationSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.navBarHapticFeedback,
        subtitle: appLocalizations.navBarHapticFeedbackDesc,
        category: appCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.application,
          const ApplicationSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.autoCloseConnections,
        subtitle: appLocalizations.autoCloseConnectionsDesc,
        category: appCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.application,
          const ApplicationSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.onlyStatisticsProxy,
        subtitle: appLocalizations.onlyStatisticsProxyDesc,
        category: appCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.application,
          const ApplicationSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.autoCheckUpdate,
        subtitle: appLocalizations.autoCheckUpdateDesc,
        category: appCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.application,
          const ApplicationSettingView(),
        ),
      ),
    ]);

    items.addAll([
      _SearchItem(
        title: appLocalizations.smartAutoStop,
        subtitle: appLocalizations.smartAutoStopDesc,
        category: otherSettingsCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.otherSettings,
          const OtherSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.networkMatch,
        subtitle: appLocalizations.networkMatchHint,
        category: otherSettingsCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.otherSettings,
          const OtherSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.dozeSuspend,
        subtitle: appLocalizations.dozeSuspendDesc,
        category: otherSettingsCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.otherSettings,
          const OtherSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.quickResponse,
        subtitle: appLocalizations.quickResponseDesc,
        category: otherSettingsCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.otherSettings,
          const OtherSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.storeFix,
        subtitle: appLocalizations.storeFixDesc,
        category: otherSettingsCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.otherSettings,
          const OtherSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.disableQuic,
        subtitle: appLocalizations.disableQuicDesc,
        category: otherSettingsCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.otherSettings,
          const OtherSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.excludeChina,
        subtitle: appLocalizations.excludeChinaDesc,
        category: otherSettingsCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.otherSettings,
          const OtherSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.networkSpeedNotification,
        subtitle: appLocalizations.networkSpeedNotificationDesc,
        category: otherSettingsCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.otherSettings,
          const OtherSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.trayEnhancement,
        subtitle: appLocalizations.trayEnhancementDesc,
        category: otherSettingsCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.otherSettings,
          const OtherSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.highPriority,
        subtitle: appLocalizations.highPriorityDesc,
        category: otherSettingsCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.otherSettings,
          const OtherSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.networkFix,
        subtitle: appLocalizations.networkFixDesc,
        category: otherSettingsCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.otherSettings,
          const OtherSettingView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.batteryOptimization,
        subtitle: appLocalizations.batteryOptimizationDesc,
        category: otherSettingsCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.otherSettings,
          const OtherSettingView(),
        ),
      ),
    ]);

    final generalCategory = '$configCategory/${appLocalizations.general}';
    items.addAll([
      _SearchItem(
        title: appLocalizations.logLevel,
        category: generalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.general,
          const _GeneralListView(),
        ),
      ),
      _SearchItem(
        title: 'UA',
        category: generalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.general,
          const _GeneralListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.keepAliveIntervalDesc,
        subtitle: appLocalizations.interval,
        category: generalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.general,
          const _GeneralListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.testUrl,
        category: generalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.general,
          const _GeneralListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.port,
        category: generalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.general,
          const _GeneralListView(),
        ),
      ),
      _SearchItem(
        title: 'IPv6',
        subtitle: appLocalizations.ipv6Desc,
        category: generalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.general,
          const _GeneralListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.allowLan,
        subtitle: appLocalizations.allowLanDesc,
        category: generalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.general,
          const _GeneralListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.unifiedDelay,
        subtitle: appLocalizations.unifiedDelayDesc,
        category: generalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.general,
          const _GeneralListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.findProcessMode,
        subtitle: appLocalizations.findProcessModeDesc,
        category: generalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.general,
          const _GeneralListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.tcpConcurrent,
        subtitle: appLocalizations.tcpConcurrentDesc,
        category: generalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.general,
          const _GeneralListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.geodataLoader,
        subtitle: appLocalizations.geodataLoaderDesc,
        category: generalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.general,
          const _GeneralListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.externalController,
        subtitle: appLocalizations.externalControllerDesc,
        category: generalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.general,
          const _GeneralListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.controlSecret,
        subtitle: appLocalizations.controlSecretDesc,
        category: generalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.general,
          const _GeneralListView(),
        ),
      ),
    ]);

    final networkCategory = '$configCategory/${appLocalizations.network}';
    items.addAll([
      _SearchItem(
        title: 'VPN',
        subtitle: appLocalizations.vpnEnableDesc,
        category: networkCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.network,
          const NetworkListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.allowBypass,
        subtitle: appLocalizations.allowBypassDesc,
        category: networkCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.network,
          const NetworkListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.systemProxy,
        subtitle: appLocalizations.systemProxyDesc,
        category: networkCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.network,
          const NetworkListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.bypassDomain,
        subtitle: appLocalizations.bypassDomainDesc,
        category: networkCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.network,
          const NetworkListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.tun,
        subtitle: appLocalizations.tunDesc,
        category: networkCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.network,
          const NetworkListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.autoSetSystemDns,
        category: networkCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.network,
          const NetworkListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.strictRoute,
        subtitle: appLocalizations.strictRouteDesc,
        category: networkCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.network,
          const NetworkListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.icmpForwarding,
        subtitle: appLocalizations.icmpForwardingDesc,
        category: networkCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.network,
          const NetworkListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.dnsHijack,
        subtitle: appLocalizations.dnsHijackDesc,
        category: networkCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.network,
          const NetworkListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.endpointIndependentNat,
        subtitle: appLocalizations.endpointIndependentNatDesc,
        category: networkCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.network,
          const NetworkListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.stackMode,
        category: networkCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.network,
          const NetworkListView(),
        ),
      ),
      _SearchItem(
        title: 'MTU',
        category: networkCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.network,
          const NetworkListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.bypassPrivateRoute,
        subtitle: appLocalizations.bypassPrivateRouteDesc,
        category: networkCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.network,
          const NetworkListView(),
        ),
      ),
    ]);

    final dnsCategory = '$configCategory/DNS';
    items.addAll([
      _SearchItem(
        title: appLocalizations.overrideDns,
        subtitle: appLocalizations.overrideDnsDesc,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.status,
        subtitle: appLocalizations.statusDesc,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.listen,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.cacheAlgorithm,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.useHosts,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.useSystemHosts,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: 'IPv6',
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.respectRules,
        subtitle: appLocalizations.respectRulesDesc,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: 'PreferH3',
        subtitle: appLocalizations.preferH3Desc,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.dnsMode,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.fakeipRange,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.fakeipRangeV6,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.fakeIpFilterMode,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.fakeipFilter,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.fakeipTtl,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.defaultNameserver,
        subtitle: appLocalizations.defaultNameserverDesc,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.nameserverPolicy,
        subtitle: appLocalizations.nameserverPolicyDesc,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.nameserver,
        subtitle: appLocalizations.nameserverDesc,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.fallback,
        subtitle: appLocalizations.fallbackDesc,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.proxyNameserver,
        subtitle: appLocalizations.proxyNameserverDesc,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.directNameserver,
        subtitle: appLocalizations.directNameserverDesc,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.directNameserverFollowPolicy,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: 'Geoip',
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.geoipCode,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.fallbackConcurrent,
        subtitle: appLocalizations.fallbackConcurrentDesc,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.ipcidr,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
      _SearchItem(
        title: appLocalizations.domain,
        category: dnsCategory,
        onTap: (context, _) => _pushPage(context, 'DNS', const DnsListView()),
      ),
    ]);

    final ntpCategory = '$configCategory/NTP';
    items.addAll([
      _SearchItem(
        title: appLocalizations.overrideNtp,
        subtitle: appLocalizations.overrideNtpDesc,
        category: ntpCategory,
        onTap: (context, _) => _pushPage(context, 'NTP', const NtpListView()),
      ),
      _SearchItem(
        title: appLocalizations.ntpStatus,
        subtitle: appLocalizations.ntpStatusDesc,
        category: ntpCategory,
        onTap: (context, _) => _pushPage(context, 'NTP', const NtpListView()),
      ),
      _SearchItem(
        title: appLocalizations.writeToSystem,
        subtitle: appLocalizations.writeToSystemDesc,
        category: ntpCategory,
        onTap: (context, _) => _pushPage(context, 'NTP', const NtpListView()),
      ),
      _SearchItem(
        title: appLocalizations.ntpServer,
        category: ntpCategory,
        onTap: (context, _) => _pushPage(context, 'NTP', const NtpListView()),
      ),
      _SearchItem(
        title: appLocalizations.ntpPort,
        category: ntpCategory,
        onTap: (context, _) => _pushPage(context, 'NTP', const NtpListView()),
      ),
      _SearchItem(
        title: appLocalizations.ntpInterval,
        category: ntpCategory,
        onTap: (context, _) => _pushPage(context, 'NTP', const NtpListView()),
      ),
    ]);

    items.add(
      _SearchItem(
        title: 'Hosts',
        subtitle: appLocalizations.hostsDesc,
        category: '$configCategory/Hosts',
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.basicConfig,
          const ConfigView(),
        ),
      ),
    );

    final snifferCategory = '$configCategory/${appLocalizations.sniffer}';
    items.addAll([
      _SearchItem(
        title: appLocalizations.overrideSniffer,
        subtitle: appLocalizations.overrideSnifferDesc,
        category: snifferCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.sniffer,
          const SnifferListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.snifferStatus,
        subtitle: appLocalizations.snifferStatusDesc,
        category: snifferCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.sniffer,
          const SnifferListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.forceDnsMapping,
        category: snifferCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.sniffer,
          const SnifferListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.parsePureIp,
        category: snifferCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.sniffer,
          const SnifferListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.overrideDestination,
        category: snifferCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.sniffer,
          const SnifferListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.httpPortSniffer,
        category: snifferCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.sniffer,
          const SnifferListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.tlsPortSniffer,
        category: snifferCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.sniffer,
          const SnifferListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.quicPortSniffer,
        category: snifferCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.sniffer,
          const SnifferListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.forceDomain,
        category: snifferCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.sniffer,
          const SnifferListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.skipDomain,
        category: snifferCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.sniffer,
          const SnifferListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.skipSrcAddress,
        category: snifferCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.sniffer,
          const SnifferListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.skipDstAddress,
        category: snifferCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.sniffer,
          const SnifferListView(),
        ),
      ),
    ]);

    items.add(
      _SearchItem(
        title: appLocalizations.tunnel,
        subtitle: appLocalizations.tunnelDesc,
        category: '$configCategory/${appLocalizations.tunnel}',
        onTap: (context, _) =>
            _pushPage(context, appLocalizations.tunnel, const TunnelListView()),
      ),
    );

    final experimentalCategory =
        '$configCategory/${appLocalizations.experimental}';
    items.addAll([
      _SearchItem(
        title: appLocalizations.overrideExperimental,
        subtitle: appLocalizations.overrideExperimentalDesc,
        category: experimentalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.experimental,
          const ExperimentalListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.quicGoDisableGso,
        category: experimentalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.experimental,
          const ExperimentalListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.quicGoDisableEcn,
        category: experimentalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.experimental,
          const ExperimentalListView(),
        ),
      ),
      _SearchItem(
        title: appLocalizations.dialerIp4pConvert,
        category: experimentalCategory,
        onTap: (context, _) => _pushPage(
          context,
          appLocalizations.experimental,
          const ExperimentalListView(),
        ),
      ),
    ]);

    return items;
  }

  List<Widget> _buildSearchResults(List<_SearchItem> items) {
    final query = _query.toLowerCase();
    final filtered = items.where((item) {
      return item.title.toLowerCase().contains(query) ||
          (item.subtitle?.toLowerCase().contains(query) ?? false) ||
          item.category.toLowerCase().contains(query);
    }).toList();

    if (filtered.isEmpty) {
      return [Center(child: NullStatus(label: appLocalizations.noData))];
    }

    final groups = <String, List<_SearchItem>>{};
    for (final item in filtered) {
      groups.putIfAbsent(item.category, () => []).add(item);
    }

    final sections = <Widget>[];
    for (final entry in groups.entries) {
      sections.add(
        _buildModernSection(
          context,
          title: entry.key,
          items: entry.value
              .map(
                (item) => ListItem(
                  leading: item.leading,
                  title: Text(item.title),
                  subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                  onTap: () => item.onTap(context, ref),
                ),
              )
              .toList(),
        ),
      );
    }
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final vm2 = ref.watch(
      appSettingProvider.select(
        (state) => VM2(a: state.locale, b: state.developerMode),
      ),
    );
    final isMobileView = ref.watch(isMobileViewProvider);
    final moreItems = ref.watch(
      moreToolsSelectorStateProvider.select((state) => state.navigationItems),
    );
    final searchItems = _getSearchItems(moreItems);
    final searchResults = _query.isEmpty
        ? const <Widget>[]
        : _buildSearchResults(searchItems);

    final items = [
      Consumer(
        builder: (_, ref, _) {
          final state = ref.watch(moreToolsSelectorStateProvider);
          if (state.navigationItems.isEmpty) {
            return Container();
          }
          return _buildModernSection(
            context,
            title: appLocalizations.more,
            items: state.navigationItems
                .map((item) => _buildNavigationMenuItem(item))
                .toList(),
          );
        },
      ),
      _buildModernSection(
        context,
        title: appLocalizations.settings,
        items: [
          _LocaleItem(),
          _ThemeItem(),
          _BackupItem(),
          if (system.isDesktop) _HotkeyItem(),
          if (system.isWindows) _LoopbackItem(),
          if (system.isAndroid) _AccessItem(),
          _ConfigItem(),
          _OtherSettingItem(),
          _SettingItem(),
        ],
      ),
      _buildModernSection(
        context,
        title: appLocalizations.other,
        items: [_DisclaimerItem(), if (vm2.b) _DeveloperItem(), _InfoItem()],
      ),
    ];

    return CommonScaffold(
      title: appLocalizations.tools,
      searchState: AppBarSearchState(onSearch: _onSearchChanged),
      body: ListView.builder(
        key: _query.isEmpty ? toolsStoreKey : null,
        itemCount: _query.isEmpty ? items.length : searchResults.length,
        itemBuilder: (_, index) {
          return _query.isEmpty ? items[index] : searchResults[index];
        },
        padding: EdgeInsets.only(
          bottom:
              20 +
              (isMobileView ? getFloatingBottomBarReserveHeight(context) : 0),
          top: 8,
        ),
      ),
    );
  }
}

class _LocaleItem extends ConsumerWidget {
  const _LocaleItem();

  static final List<Locale> _localeOptions = _getOrderedLocales();

  static List<Locale> _getOrderedLocales() {
    final priority = ['zh_CN', 'zh_TC', 'en', 'ru', 'fa', 'ja', 'ko'];
    final locales = List<Locale>.from(AppLocalizations.delegate.supportedLocales);
    locales.sort((a, b) {
      final aKey = a.toString();
      final bKey = b.toString();
      final aIndex = priority.indexOf(aKey);
      final bIndex = priority.indexOf(bKey);
      if (aIndex != -1 && bIndex != -1) return aIndex.compareTo(bIndex);
      if (aIndex != -1) return -1;
      if (bIndex != -1) return 1;
      return aKey.compareTo(bKey);
    });
    return locales;
  }

  String _getLocaleString(Locale locale) {
    return Intl.message(locale.toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(
      appSettingProvider.select((state) => state.locale),
    );
    final currentLocale =
        utils.getLocaleForString(locale) ?? utils.getSystemLocale();
    return ListItem<Locale>.options(
      leading: const Icon(Icons.language_outlined),
      title: Text(appLocalizations.language),
      subtitle: Text(Intl.message(currentLocale.toString())),
      delegate: OptionsDelegate(
        title: appLocalizations.language,
        options: _localeOptions,
        onChanged: (Locale? locale) {
          if (locale == null) return;
          ref
              .read(appSettingProvider.notifier)
              .updateState(
                (state) => state.copyWith(locale: locale.toString()),
              );
        },
        textBuilder: (locale) => _getLocaleString(locale),
        value: currentLocale,
      ),
    );
  }
}

class _ThemeItem extends StatelessWidget {
  const _ThemeItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.style),
      title: Text(appLocalizations.theme),
      subtitle: Text(appLocalizations.themeDesc),
      delegate: NextDelegate(
        title: appLocalizations.theme,
        builder: (_) => const ThemeView(),
      ),
    );
  }
}

class _BackupItem extends StatelessWidget {
  const _BackupItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.cloud_sync),
      title: Text(appLocalizations.backupAndRecovery),
      subtitle: Text(appLocalizations.backupAndRecoveryDesc),
      delegate: NextDelegate(
        title: appLocalizations.backupAndRecovery,
        builder: (_) => const BackupAndRecovery(),
      ),
    );
  }
}

class _HotkeyItem extends StatelessWidget {
  const _HotkeyItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.keyboard),
      title: Text(appLocalizations.hotkeyManagement),
      subtitle: Text(appLocalizations.hotkeyManagementDesc),
      delegate: NextDelegate(
        title: appLocalizations.hotkeyManagement,
        builder: (_) => const HotKeyView(),
      ),
    );
  }
}

class _LoopbackItem extends StatelessWidget {
  const _LoopbackItem();

  @override
  Widget build(BuildContext context) {
    return ListItem(
      leading: const Icon(Icons.lock),
      title: Text(appLocalizations.loopback),
      subtitle: Text(appLocalizations.loopbackDesc),
      onTap: () {
        windows?.runas(
          '"${join(dirname(Platform.resolvedExecutable), "WindowsLoopbackManager.exe")}"',
          '',
          showWindow: true,
        );
      },
    );
  }
}

class _AccessItem extends StatelessWidget {
  const _AccessItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.view_list),
      title: Text(appLocalizations.accessControl),
      subtitle: Text(appLocalizations.accessControlDesc),
      delegate: NextDelegate(
        title: appLocalizations.appAccessControl,
        builder: (_) => const AccessView(),
      ),
    );
  }
}

class _ConfigItem extends StatelessWidget {
  const _ConfigItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.edit),
      title: Text(appLocalizations.basicConfig),
      subtitle: Text(appLocalizations.basicConfigDesc),
      delegate: NextDelegate(
        title: appLocalizations.basicConfig,
        builder: (_) => const ConfigView(),
      ),
    );
  }
}

class _OtherSettingItem extends StatelessWidget {
  const _OtherSettingItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.settings_suggest_outlined),
      title: Text(appLocalizations.otherSettings),
      subtitle: Text(appLocalizations.otherSettingsDesc),
      delegate: NextDelegate(
        title: appLocalizations.otherSettings,
        builder: (_) => const OtherSettingView(),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.settings),
      title: Text(appLocalizations.application),
      subtitle: Text(appLocalizations.applicationDesc),
      delegate: NextDelegate(
        title: appLocalizations.application,
        builder: (_) => const ApplicationSettingView(),
      ),
    );
  }
}

class _DisclaimerItem extends StatelessWidget {
  const _DisclaimerItem();

  @override
  Widget build(BuildContext context) {
    return ListItem(
      leading: const Icon(Icons.gavel),
      title: Text(appLocalizations.disclaimer),
      onTap: () async {
        final isDisclaimerAccepted = await globalState.appController
            .showDisclaimer();
        if (!isDisclaimerAccepted) {
          globalState.appController.handleExit();
        }
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.info),
      title: Text(appLocalizations.about),
      delegate: NextDelegate(
        title: appLocalizations.about,
        builder: (_) => const AboutView(),
      ),
    );
  }
}

class _DeveloperItem extends StatelessWidget {
  const _DeveloperItem();

  @override
  Widget build(BuildContext context) {
    return ListItem.next(
      leading: const Icon(Icons.developer_board),
      title: Text(appLocalizations.developerMode),
      delegate: NextDelegate(
        title: appLocalizations.developerMode,
        builder: (_) => const DeveloperView(),
      ),
    );
  }
}
