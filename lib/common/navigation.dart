import 'reicons.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/views/views.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Navigation {
  static Navigation? _instance;

  List<NavigationItem> getItems({
    bool openLogs = false,
    bool hasProxies = false,
  }) {
    return [
      NavigationItem(
        keep: false,
        icon: const Icon(ReIcons.house),
        label: PageLabel.dashboard,
        builder: (_) =>
            DashboardView(key: const GlobalObjectKey(PageLabel.dashboard)),
      ),
      NavigationItem(
        icon: const Icon(ReIcons.discover),
        label: PageLabel.proxies,
        builder: (_) => ProviderScope(
          overrides: [queryProvider.overrideWith(() => Query())],
          child: ProxiesView(key: const GlobalObjectKey(PageLabel.proxies)),
        ),
        modes: hasProxies
            ? [NavigationItemMode.mobile, NavigationItemMode.desktop]
            : [],
      ),
      NavigationItem(
        icon: const Icon(ReIcons.folderCloud),
        label: PageLabel.profiles,
        builder: (_) =>
            ProfilesView(key: const GlobalObjectKey(PageLabel.profiles)),
      ),
      NavigationItem(
        icon: Icon(ReIcons.plug),
        label: PageLabel.connections,
        builder: (_) =>
            ConnectionsView(key: const GlobalObjectKey(PageLabel.connections)),
        description: 'connectionsDesc',
        modes: [NavigationItemMode.desktop, NavigationItemMode.more],
      ),
      NavigationItem(
        icon: const Icon(ReIcons.driver),
        label: PageLabel.resources,
        description: 'resourcesDesc',
        builder: (_) =>
            ResourcesView(key: const GlobalObjectKey(PageLabel.resources)),
        modes: [NavigationItemMode.more],
      ),
      NavigationItem(
        icon: const Icon(ReIcons.terminalSquare),
        label: PageLabel.script,
        description: 'scriptDesc',
        builder: (_) =>
            ScriptsView(key: const GlobalObjectKey(PageLabel.script)),
        modes: [NavigationItemMode.more],
      ),
      NavigationItem(
        icon: const Icon(ReIcons.designtools),
        label: PageLabel.toolbox,
        description: 'toolboxDesc',
        builder: (_) =>
            ToolboxView(key: const GlobalObjectKey(PageLabel.toolbox)),
        modes: [NavigationItemMode.desktop, NavigationItemMode.more],
      ),
      NavigationItem(
        icon: const Icon(ReIcons.bug),
        label: PageLabel.logs,
        builder: (_) => LogsView(key: const GlobalObjectKey(PageLabel.logs)),
        description: 'logsDesc',
        modes: [NavigationItemMode.desktop, NavigationItemMode.more],
      ),
      NavigationItem(
        icon: Icon(ReIcons.element4),
        label: PageLabel.tools,
        builder: (_) => ToolsView(key: const GlobalObjectKey(PageLabel.tools)),
        modes: [NavigationItemMode.desktop, NavigationItemMode.mobile],
      ),
    ];
  }

  Navigation._internal();

  factory Navigation() {
    _instance ??= Navigation._internal();
    return _instance!;
  }
}

final navigation = Navigation();
