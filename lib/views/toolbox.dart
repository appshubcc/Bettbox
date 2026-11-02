import 'package:bett_box/common/common.dart';
import 'package:bett_box/pages/pages.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const _unitHeight = 92.0;
const _spacing = 8.0;

enum _TileSize {
  small(1, 1),
  wide(2, 1),
  tall(1, 2);

  final int cross;
  final int main;

  const _TileSize(this.cross, this.main);

  _TileSize get next => values[(index + 1) % values.length];
}

class _Tile {
  final _ToolItem item;
  final _TileSize size;

  const _Tile(this.item, this.size);

  String get value => '${item.id}:${size.name}';
}

List<_Tile> _resolveTiles(List<_ToolItem> tools, List<String> saved) {
  final byId = {for (final tool in tools) tool.id: tool};
  final seen = <String>{};
  final tiles = <_Tile>[];
  for (final entry in saved) {
    final parts = entry.split(':');
    final tool = byId[parts.first];
    if (tool == null || !seen.add(tool.id)) continue;
    final size = _TileSize.values.firstWhere(
      (size) => size.name == parts.elementAtOrNull(1),
      orElse: () => tool.size,
    );
    tiles.add(_Tile(tool, size));
  }
  for (final tool in tools) {
    if (seen.add(tool.id)) tiles.add(_Tile(tool, tool.size));
  }
  return tiles;
}

typedef ToolboxEntry = ({
  IconData icon,
  Color color,
  String title,
  void Function(BuildContext context) open,
});

List<ToolboxEntry> orderedToolboxEntries(List<String> saved) => [
  for (final tile in _resolveTiles(_buildTools(), saved))
    (
      icon: tile.item.icon,
      color: tile.item.color,
      title: tile.item.title,
      open: tile.item.open,
    ),
];

class _ToolItem {
  final String id;
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final _TileSize size;
  final void Function(BuildContext context) open;

  const _ToolItem({
    required this.id,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.open,
    this.size = _TileSize.small,
  });
}

List<_ToolItem> _buildTools() {
  void push(BuildContext context, Widget page) =>
      BaseNavigator.push(context, page);
  return [
    _ToolItem(
      id: 'speedTest',
      icon: Icons.speed_rounded,
      color: const Color(0xFF2F80ED),
      title: appLocalizations.speedTest,
      description: appLocalizations.toolSpeedTestDesc,
      size: _TileSize.wide,
      open: (context) => push(context, const SpeedTestPage()),
    ),
    _ToolItem(
      id: 'routeTrace',
      icon: Icons.route_rounded,
      color: const Color(0xFF7B61FF),
      title: appLocalizations.routeTrace,
      description: appLocalizations.routeTraceDesc,
      size: _TileSize.tall,
      open: (context) => push(context, const RouteTracePage()),
    ),
    _ToolItem(
      id: 'ipLookup',
      icon: Icons.travel_explore_rounded,
      color: const Color(0xFF00A3A3),
      title: appLocalizations.ipLookup,
      description: appLocalizations.ipLookupDesc,
      open: (context) => push(context, const IpLookupPage()),
    ),
    _ToolItem(
      id: 'mrsLookup',
      icon: Icons.manage_search_rounded,
      color: const Color(0xFFE58A00),
      title: appLocalizations.mrsLookup,
      description: appLocalizations.mrsLookupDesc,
      open: (context) => push(context, const MrsLookupPage()),
    ),
    _ToolItem(
      id: 'dnsQuery',
      icon: Icons.dns_rounded,
      color: const Color(0xFF3B9C4A),
      title: appLocalizations.dnsQuery,
      description: appLocalizations.dnsQueryDesc,
      open: (context) => push(context, const DnsQueryPage()),
    ),
    _ToolItem(
      id: 'natTest',
      icon: Icons.hub_rounded,
      color: const Color(0xFFD9466F),
      title: appLocalizations.natTest,
      description: appLocalizations.natTestDesc,
      open: (context) => push(context, const NatTestPage()),
    ),
    _ToolItem(
      id: 'localPing',
      icon: Icons.network_ping_rounded,
      color: const Color(0xFF2E7DD7),
      title: appLocalizations.localPing,
      description: appLocalizations.localPingDesc,
      open: (context) => push(context, const LocalPingPage()),
    ),
    _ToolItem(
      id: 'iperf',
      icon: Icons.lan_rounded,
      color: const Color(0xFFC2571A),
      title: appLocalizations.iperfTest,
      description: appLocalizations.iperfTestDesc,
      open: (context) => push(context, const IperfPage()),
    ),
    _ToolItem(
      id: 'ageTool',
      icon: Icons.lock_rounded,
      color: const Color(0xFF5C6BC0),
      title: appLocalizations.ageTool,
      description: appLocalizations.ageToolDesc,
      open: (context) => push(context, const AgeToolPage()),
    ),
    _ToolItem(
      id: 'connectivity',
      icon: Icons.wifi_tethering_rounded,
      color: const Color(0xFF0097D6),
      title: appLocalizations.mediaUnlock,
      description: appLocalizations.toolConnectivityDesc,
      open: (context) => showExtend(
        context,
        builder: (_, type) => MediaUnlockPage(type: type),
      ),
    ),
    _ToolItem(
      id: 'trafficStats',
      icon: Icons.data_usage_rounded,
      color: const Color(0xFFAA47BC),
      title: appLocalizations.trafficUsage,
      description: appLocalizations.trafficStatsDesc,
      open: (context) => push(context, const TrafficStatsPage()),
    ),
  ];
}

class ToolboxView extends ConsumerStatefulWidget {
  const ToolboxView({super.key});

  @override
  ConsumerState<ToolboxView> createState() => _ToolboxViewState();
}

class _ToolboxViewState extends ConsumerState<ToolboxView> {
  bool _editing = false;

  List<_Tile> _tiles() => _resolveTiles(
    _buildTools(),
    ref.read(appSettingProvider.select((state) => state.toolboxTiles)),
  );

  void _save(List<_Tile> tiles) {
    ref
        .read(appSettingProvider.notifier)
        .updateState(
          (state) => state.copyWith(
            toolboxTiles: [for (final tile in tiles) tile.value],
          ),
        );
  }

  void _setEditing(bool value) {
    if (_editing == value) return;
    setState(() => _editing = value);
  }

  void _resize(_Tile target) {
    _save([
      for (final tile in _tiles())
        tile.item.id == target.item.id
            ? _Tile(tile.item, tile.size.next)
            : tile,
    ]);
  }

  void _move(_Tile from, _Tile to) {
    final tiles = _tiles();
    final source = tiles.indexWhere((tile) => tile.item.id == from.item.id);
    final target = tiles.indexWhere((tile) => tile.item.id == to.item.id);
    if (source < 0 || target < 0 || source == target) return;
    tiles.insert(target, tiles.removeAt(source));
    _save(tiles);
  }

  void _reset() {
    ref
        .read(appSettingProvider.notifier)
        .updateState((state) => state.copyWith(toolboxTiles: const []));
  }

  @override
  Widget build(BuildContext context) {
    final columns = ref.watch(getProxiesColumnsProvider);
    final saved = ref.watch(
      appSettingProvider.select((state) => state.toolboxTiles),
    );
    final tiles = _resolveTiles(_buildTools(), saved);
    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _editing
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ToolNote(
                      icon: Icons.touch_app_outlined,
                      text: globalState.isAndroidTV
                          ? appLocalizations.toolboxEditTipTv
                          : system.isDesktop
                          ? appLocalizations.toolboxEditTipDesktop
                          : appLocalizations.toolboxEditTip,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          EditableGrid<_Tile>(
            items: tiles,
            editing: _editing,
            crossAxisCount: columns,
            crossAxisSpacing: _spacing,
            mainAxisSpacing: _spacing,
            mainAxisExtent: _unitHeight + _spacing,
            keyOf: (tile) => tile.item.id,
            crossAxisCellCountOf: (tile) => tile.size.cross,
            mainAxisCellCountOf: (tile) => tile.size.main,
            canResize: (_) => true,
            onResize: _resize,
            onMove: _move,
            itemBuilder: (context, tile) =>
                _ToolCard(tile: tile, onTap: () => tile.item.open(context)),
          ),
        ],
      ),
    );
    return CommonScaffold(
      title: appLocalizations.toolbox,
      actions: _editing
          ? [
              IconButton(
                tooltip: appLocalizations.reset,
                onPressed: _reset,
                icon: const Icon(Icons.restart_alt_rounded),
              ),
              IconButton(
                tooltip: appLocalizations.save,
                onPressed: () => _setEditing(false),
                icon: const Icon(Icons.check_rounded),
              ),
            ]
          : [
              IconButton(
                tooltip: appLocalizations.edit,
                onPressed: () => _setEditing(true),
                icon: const Icon(Icons.dashboard_customize_outlined),
              ),
            ],
      body: _editing
          ? SystemBackBlock(
              child: CommonPopScope(
                onPop: () {
                  _setEditing(false);
                  return false;
                },
                child: body,
              ),
            )
          : body,
    );
  }
}

class _ToolCard extends StatefulWidget {
  final _Tile tile;
  final VoidCallback onTap;

  const _ToolCard({required this.tile, required this.onTap});

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final item = widget.tile.item;
    final size = widget.tile.size;
    final active = _hovered || _pressed || _focused;
    final iconColor = active ? item.color : colorScheme.onSurfaceVariant;
    Widget iconBox(double dimension, double iconSize) => AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: active
            ? item.color.withValues(alpha: 0.14)
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(dimension * 0.3),
      ),
      child: TweenAnimationBuilder<Color?>(
        duration: const Duration(milliseconds: 180),
        tween: ColorTween(end: iconColor),
        builder: (_, color, _) => Icon(item.icon, size: iconSize, color: color),
      ),
    );
    Widget watermark(double iconSize) => TweenAnimationBuilder<Color?>(
      duration: const Duration(milliseconds: 220),
      tween: ColorTween(
        end: active
            ? item.color.withValues(alpha: 0.16)
            : colorScheme.onSurface.withValues(alpha: 0.05),
      ),
      builder: (_, color, _) => Icon(item.icon, size: iconSize, color: color),
    );
    final title = context.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    );
    final description = context.textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.3,
    );
    final content = switch (size) {
      _TileSize.small => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                iconBox(30, 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: title,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: description,
            ),
          ],
        ),
      ),
      _TileSize.wide => Stack(
        children: [
          PositionedDirectional(end: -14, bottom: -22, child: watermark(104)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                iconBox(46, 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
        ],
      ),
      _TileSize.tall => Stack(
        children: [
          PositionedDirectional(end: -18, top: -18, child: watermark(96)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconBox(42, 24),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.bottomStart,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? item.color.withValues(alpha: 0.14)
                          : colorScheme.surfaceContainerHigh,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    };
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onFocusChange: (focused) {
            if (focused != _focused) setState(() => _focused = focused);
          },
          child: CommonCard(
            onPressed: widget.onTap,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween(begin: 0.94, end: 1.0).animate(animation),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(size),
                child: SizedBox.expand(child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
