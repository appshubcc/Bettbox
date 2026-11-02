import 'dart:io';
import 'dart:typed_data';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/pages.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bett_box/providers/providers.dart';

final _iconCache = <String, Uint8List?>{};
final _iconPending = <String, Future<Uint8List?>>{};
const _maxIconCacheSize = 100;
Uint8List? _defaultIconCache;
Future<Uint8List?>? _defaultIconFuture;

void _addToIconCache(String key, Uint8List? value) {
  _iconCache.remove(key);
  while (_iconCache.length >= _maxIconCacheSize) {
    final evicted = _iconCache.remove(_iconCache.keys.first);
    if (evicted != null) {
      imageCache.evict(MemoryImage(evicted), includeLive: false);
    }
  }
  _iconCache[key] = value;
}

class TrackerInfoItem extends ConsumerWidget {
  final TrackerInfo trackerInfo;
  final Function(String)? onClickKeyword;
  final Widget? trailing;
  final String detailTitle;
  final int index;
  final int count;
  final bool reversed;
  final bool showSpeed;

  const TrackerInfoItem({
    super.key,
    required this.trackerInfo,
    this.onClickKeyword,
    this.trailing,
    required this.detailTitle,
    required this.index,
    required this.count,
    this.reversed = false,
    this.showSpeed = false,
  });

  static double get subTitleHeight {
    return globalState.measure.bodySmallHeight + 12;
  }

  static double get height {
    final measure = globalState.measure;
    return measure.bodyMediumHeight +
        4 +
        8 +
        measure.bodyLargeHeight +
        subTitleHeight +
        12 * 2;
  }

  static ThemeData? _cachedBaseTheme;
  static ThemeData? _cachedItemTheme;

  static ThemeData _getItemTheme(ThemeData baseTheme) {
    if (identical(_cachedBaseTheme, baseTheme) && _cachedItemTheme != null) {
      return _cachedItemTheme!;
    }
    _cachedBaseTheme = baseTheme;
    _cachedItemTheme = baseTheme.copyWith(
      visualDensity: VisualDensity.compact,
      canvasColor: baseTheme.colorScheme.onSurfaceVariant.withValues(
        alpha: 0.08,
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
    return _cachedItemTheme!;
  }

  String _getSourceText(TrackerInfo trackerInfo) {
    final progress = trackerInfo.progressText.isNotEmpty
        ? '${trackerInfo.progressText} · '
        : '';
    if (showSpeed) {
      final upSpeed = TrafficValue(value: trackerInfo.uploadSpeed).toString();
      final downSpeed = TrafficValue(
        value: trackerInfo.downloadSpeed,
      ).toString();
      return '$progress$upSpeed/s↑ $downSpeed/s↓';
    }
    final up = TrafficValue(value: trackerInfo.upload).toString();
    final down = TrafficValue(value: trackerInfo.download).toString();
    return '$progress$up↑ $down↓';
  }

  @override
  Widget build(BuildContext context, ref) {
    final value = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.findProcessMode == FindProcessMode.always,
      ),
    );
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 8,
          children: [
            Flexible(
              child: Text(
                trackerInfo.desc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              trackerInfo.start.lastUpdateTimeDesc,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.opacity60,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _getSourceText(trackerInfo),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            fontSize: 12.5,
            color: context.colorScheme.onSurfaceVariant.opacity80,
          ),
        ),
      ],
    );
    final chains = trackerInfo.chains;
    final labelStyle = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    final subTitle = SizedBox(
      height: subTitleHeight,
      child: Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Theme(
                data: _getItemTheme(Theme.of(context)),
                child: Row(
                  spacing: 6,
                  children: [
                    for (final chain in chains)
                      CommonChip(
                        label: chain,
                        labelStyle: labelStyle,
                        onPressed: () {
                          if (onClickKeyword == null) return;
                          onClickKeyword!(chain);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
    final icon = value
        ? ConnectionProcessIcon(
            process: trackerInfo.metadata.process,
            path: trackerInfo.metadata.processPath,
            port: trackerInfo.metadata.destinationPort,
            onClick: onClickKeyword,
          )
        : null;
    final listItem = InkWell(
      focusColor: context.colorScheme.primary.withValues(alpha: 0.18),
      onTap: () {
        showExtend(
          context,
          builder: (_, type) {
            return AdaptiveSheetScaffold(
              type: type,
              body: TrackerInfoDetailView(
                trackerInfo: trackerInfo,
                detailTitle: detailTitle,
              ),
              title: detailTitle,
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12,
              children: [
                ?icon,
                Flexible(child: title),
              ],
            ),
            const SizedBox(height: 8),
            subTitle,
          ],
        ),
      ),
    );
    return ContinuousListItem(
      index: index,
      count: count,
      reversed: reversed,
      child: listItem,
    );
  }
}

Future<Uint8List?> _loadIcon(String key) async {
  if (system.isDesktop) {
    return processIcon.get(key);
  }
  return await app.getPackageIcon(key) ?? await _getDefaultPackageIcon();
}

Future<Uint8List?> _getIcon(String key) {
  if (key.isEmpty) {
    return system.isDesktop ? Future.value() : _getDefaultPackageIcon();
  }
  if (_iconCache.containsKey(key)) {
    final icon = _iconCache[key];
    _addToIconCache(key, icon);
    return Future.value(icon);
  }
  return _iconPending[key] ??= _loadIcon(key)
      .then((icon) {
        if (icon != null || system.isDesktop) {
          _addToIconCache(key, icon);
        }
        return icon;
      })
      .whenComplete(() {
        _iconPending.remove(key);
      });
}

Future<Uint8List?> _getDefaultPackageIcon() {
  final cachedIcon = _defaultIconCache;
  if (cachedIcon != null) {
    return Future.value(cachedIcon);
  }
  return _defaultIconFuture ??= app.getPackageIcon('').then((icon) {
    if (icon != null) {
      _defaultIconCache = icon;
    }
    _defaultIconFuture = null;
    return icon;
  });
}

class ConnectionProcessIcon extends StatefulWidget {
  final String process;
  final String path;
  final String port;
  final Function(String)? onClick;

  const ConnectionProcessIcon({
    super.key,
    required this.process,
    required this.path,
    required this.port,
    this.onClick,
  });

  @override
  State<ConnectionProcessIcon> createState() => _ConnectionProcessIconState();
}

class _ConnectionProcessIconState extends State<ConnectionProcessIcon> {
  late Future<Uint8List?> _iconFuture;

  String get _cacheKey =>
      system.isDesktop ? processIcon.keyOf(widget.path) : widget.process;

  @override
  void initState() {
    super.initState();
    _iconFuture = _getIcon(_cacheKey);
  }

  IconData get _fallbackIcon {
    if (widget.port == '53') return Icons.dns_outlined;
    if (widget.path.isNotEmpty) return Icons.settings_suggest_outlined;
    return Icons.terminal;
  }

  @override
  void didUpdateWidget(ConnectionProcessIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.process != widget.process || oldWidget.path != widget.path) {
      _iconFuture = _getIcon(_cacheKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheSize = (38 * devicePixelRatio).ceil();

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          if (widget.process.isEmpty) return;
          widget.onClick?.call(widget.process);
        },
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          child: FutureBuilder<Uint8List?>(
            initialData: _iconCache[_cacheKey],
            future: _iconFuture,
            builder: (context, snapshot) {
              final iconBytes = snapshot.data;
              if (iconBytes == null) {
                if (system.isDesktop &&
                    snapshot.connectionState == ConnectionState.done) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colorScheme.onSurfaceVariant.opacity10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: Icon(
                        _fallbackIcon,
                        size: 22,
                        color: context.colorScheme.onSurfaceVariant.opacity80,
                      ),
                    ),
                  );
                }
                return const SizedBox(width: 38, height: 38);
              }
              if (system.isDesktop) {
                return Image.memory(
                  iconBytes,
                  width: 38,
                  height: 38,
                  filterQuality: FilterQuality.medium,
                  gaplessPlayback: true,
                );
              }
              return Image(
                image: ResizeImage(
                  MemoryImage(iconBytes),
                  width: cacheSize,
                  height: cacheSize,
                  allowUpscaling: false,
                ),
                width: 38,
                height: 38,
                gaplessPlayback: true,
              );
            },
          ),
        ),
      ),
    );
  }
}

class TrackerInfoDetailView extends ConsumerWidget {
  final TrackerInfo trackerInfo;
  final String detailTitle;

  const TrackerInfoDetailView({
    super.key,
    required this.trackerInfo,
    required this.detailTitle,
  });

  String _getRuleText(TrackerInfo info) {
    final rule = info.rule;
    final rulePayload = info.rulePayload;
    if (rulePayload.isNotEmpty) {
      return '$rule($rulePayload)';
    }
    return rule;
  }

  String _getProgressText(TrackerInfo info) {
    final process = info.metadata.process;
    final uid = info.metadata.uid;
    if (uid != 0) {
      return '$process($uid)';
    }
    return process;
  }

  String? _getInboundText(Metadata metadata) {
    switch (metadata.type) {
      case '':
        return null;
      case 'Tun':
        return 'TUN';
      case 'Inner':
        return appLocalizations.internalTraffic;
    }
    final type = metadata.type == 'HTTPS' ? 'HTTP' : metadata.type;
    final inboundName = metadata.inboundName;
    final name = inboundName.startsWith('DEFAULT-') && inboundName.length > 8
        ? inboundName[8] + inboundName.substring(9).toLowerCase()
        : inboundName;
    final port = metadata.inboundPort;
    final text = [
      if (name.isNotEmpty && !type.toLowerCase().startsWith(name.toLowerCase()))
        name,
      type,
      if (port.isNotEmpty && port != '0') port,
    ].join(' · ');
    final user = metadata.inboundUser;
    if (user.isEmpty) return text;
    return appLocalizations.inboundWithUser(text, user);
  }

  String _getDnsModeText(DnsMode mode) => switch (mode) {
    DnsMode.normal => 'normal',
    DnsMode.fakeIp => 'fake-ip',
    DnsMode.redirHost => 'redir-host',
    DnsMode.hosts => 'hosts',
  };

  bool _isIpAddress(String str) {
    return InternetAddress.tryParse(str) != null;
  }

  (String, String?)? _parseIpAndPort(String text) {
    var raw = text.trim();
    if (raw.isEmpty) return null;
    if (raw.startsWith('[') && raw.contains(']')) {
      final end = raw.indexOf(']');
      final ip = raw.substring(1, end);
      final rest = raw.substring(end + 1);
      final port = rest.startsWith(':') ? rest.substring(1) : null;
      if (_isIpAddress(ip)) return (ip, port);
    }
    if (raw.contains(':')) {
      final parts = raw.split(':');
      if (parts.length == 2 && int.tryParse(parts[1]) != null) {
        if (_isIpAddress(parts[0])) return (parts[0], parts[1]);
      }
    }
    if (_isIpAddress(raw)) return (raw, null);
    return null;
  }

  Widget _buildChains(TrackerInfo info) {
    return ListItem(
      title: _LeadingWrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(appLocalizations.proxyChains),
          ),
          for (final chain in info.chains)
            CommonChip(label: chain, onPressed: () {}),
        ],
      ),
    );
  }

  Widget? _buildToolbox(BuildContext context, TrackerInfo info) {
    final metadata = info.metadata;
    final host = metadata.host.trim();
    final target = host.isNotEmpty ? host : metadata.destinationIP.trim();
    if (target.isEmpty) return null;
    final isDomain = !_isIpAddress(target);
    void open(Widget page) => BaseNavigator.push(context, page);
    Widget chip(IconData icon, String label, Widget Function() page) =>
        CommonChip(
          avatar: Icon(icon, size: 16, color: context.colorScheme.primary),
          label: label,
          onPressed: () => open(page()),
        );
    return ListItem(
      title: _LeadingWrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(appLocalizations.toolbox),
          ),
          chip(
            Icons.route_rounded,
            appLocalizations.routeTrace,
            () => RouteTracePage(
              initialTarget: target,
              initialNetwork: metadata.network,
              initialPort: int.tryParse(metadata.destinationPort),
            ),
          ),
          if (isDomain)
            chip(
              Icons.dns_rounded,
              appLocalizations.dnsQuery,
              () => DnsQueryPage(initialDomain: target),
            ),
          chip(
            Icons.manage_search_rounded,
            appLocalizations.mrsLookup,
            () => MrsLookupPage(initialQuery: target),
          ),
          chip(
            Icons.travel_explore_rounded,
            appLocalizations.ipLookup,
            () => IpLookupPage(initialQuery: target),
          ),
        ],
      ),
    );
  }

  Widget _buildIpItem(
    BuildContext context, {
    required String title,
    required String ip,
    String? port,
  }) {
    final category = utils.classifyIp(ip);
    final IconData icon = switch (category) {
      IpCategory.tun => Icons.stacked_line_chart,
      IpCategory.lan => Icons.shuffle,
      IpCategory.public => Icons.search_rounded,
    };

    return ListItem(
      title: Row(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: context.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      showIpDetailDialog(context, ip, followRiskSetting: false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 14,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              ip,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (port != null && port.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(':$port', style: context.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String title,
    required String desc,
    bool quickCopy = false,
  }) {
    return ListItem(
      title: Row(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 4,
            children: [
              Text(title),
              if (quickCopy)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.content_copy, size: 18),
                    onPressed: () {},
                  ),
                ),
            ],
          ),
          Flexible(child: EmojiText(desc, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = trackerInfo;

    final remoteDestParsed = _parseIpAndPort(info.metadata.remoteDestination);
    final inboundText = _getInboundText(info.metadata);
    final dnsMode = info.metadata.dnsMode;

    final isLight = context.colorScheme.brightness == Brightness.light;
    final divider = Divider(
      height: 1,
      thickness: 1,
      color: context.colorScheme.outlineVariant.withValues(
        alpha: isLight ? 0.45 : 0.25,
      ),
      indent: 16,
      endIndent: 16,
    );

    final items = [
      _buildItem(
        title: appLocalizations.creationTime,
        desc: info.start.showFull,
      ),
      if (_getProgressText(info).isNotEmpty)
        _buildItem(
          title: appLocalizations.progress,
          desc: _getProgressText(info),
        ),
      if (system.isDesktop && info.metadata.processPath.isNotEmpty)
        _buildItem(
          title: appLocalizations.processPath,
          desc: info.metadata.processPath,
        ),
      _buildItem(
        title: appLocalizations.networkType,
        desc: info.metadata.network,
      ),
      if (inboundText != null)
        _buildItem(title: appLocalizations.inbound, desc: inboundText),
      _buildItem(title: appLocalizations.rule, desc: _getRuleText(info)),
      if (info.metadata.host.isNotEmpty)
        _isIpAddress(info.metadata.host)
            ? _buildIpItem(
                context,
                title: appLocalizations.host,
                ip: info.metadata.host,
              )
            : _buildItem(
                title: appLocalizations.host,
                desc: info.metadata.host,
              ),
      if (info.metadata.sniffHost.isNotEmpty)
        _buildItem(
          title: appLocalizations.sniffHost,
          desc: info.metadata.sniffHost,
        ),
      if (info.metadata.sourceIP.isNotEmpty)
        _buildIpItem(
          context,
          title: appLocalizations.source,
          ip: info.metadata.sourceIP,
          port: info.metadata.sourcePort.isNotEmpty
              ? info.metadata.sourcePort
              : null,
        ),
      if (info.metadata.destinationIP.isNotEmpty)
        _buildIpItem(
          context,
          title: appLocalizations.destination,
          ip: info.metadata.destinationIP,
          port: info.metadata.destinationPort.isNotEmpty
              ? info.metadata.destinationPort
              : null,
        ),
      Consumer(
        builder: (context, ref, _) {
          final liveInfo = ref.watch(
            connectionsProvider.select(
              (list) => list.firstWhereOrNull((e) => e.id == trackerInfo.id),
            ),
          );
          final upload = liveInfo?.upload ?? trackerInfo.upload;
          final download = liveInfo?.download ?? trackerInfo.download;
          final isAlive = liveInfo != null;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildItem(
                title: appLocalizations.upload,
                desc: TrafficValue(value: upload).show,
              ),
              divider,
              _buildItem(
                title: appLocalizations.download,
                desc: TrafficValue(value: download).show,
              ),
              if (isAlive) ...[
                divider,
                _buildItem(
                  title: appLocalizations.realTimeSpeed,
                  desc: Traffic(
                    up: liveInfo.uploadSpeed,
                    down: liveInfo.downloadSpeed,
                  ).toString(),
                ),
              ],
            ],
          );
        },
      ),
      if (info.metadata.destinationGeoIP.isNotEmpty)
        _buildItem(
          title: appLocalizations.destinationGeoIP,
          desc: info.metadata.destinationGeoIP.join(' '),
        ),
      if (info.metadata.destinationIPASN.isNotEmpty)
        _buildItem(
          title: appLocalizations.destinationIPASN,
          desc: info.metadata.destinationIPASN,
        ),
      if (dnsMode != null)
        _buildItem(
          title: appLocalizations.dnsMode,
          desc: _getDnsModeText(dnsMode),
        ),
      if (info.metadata.specialProxy.isNotEmpty)
        _buildItem(
          title: appLocalizations.specialProxy,
          desc: info.metadata.specialProxy,
        ),
      if (info.metadata.specialRules.isNotEmpty)
        _buildItem(
          title: appLocalizations.specialRules,
          desc: info.metadata.specialRules,
        ),
      if (info.metadata.remoteDestination.isNotEmpty)
        remoteDestParsed != null
            ? _buildIpItem(
                context,
                title: appLocalizations.remoteDestination,
                ip: remoteDestParsed.$1,
                port: remoteDestParsed.$2,
              )
            : _buildItem(
                title: appLocalizations.remoteDestination,
                desc: info.metadata.remoteDestination,
              ),
      if (info.chains.isNotEmpty) _buildChains(info),
      ?_buildToolbox(context, info),
    ];
    return SelectionArea(
      child: ScrollEdgeRise(
        builder: (_, rise) => ListView(
          padding: EdgeInsets.fromLTRB(16, 12 + rise, 16, 12),
          children: [
            CommonCard(
              type: CommonCardType.filled,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    items[i],
                    if (i != items.length - 1) divider,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadingWrap extends MultiChildRenderObjectWidget {
  final double spacing;
  final double runSpacing;

  const _LeadingWrap({
    required this.spacing,
    required this.runSpacing,
    required super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderLeadingWrap(spacing: spacing, runSpacing: runSpacing);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderLeadingWrap renderObject,
  ) {
    renderObject
      ..spacing = spacing
      ..runSpacing = runSpacing;
  }
}

class _LeadingWrapParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderLeadingWrap extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _LeadingWrapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _LeadingWrapParentData> {
  _RenderLeadingWrap({required double spacing, required double runSpacing})
    : _spacing = spacing,
      _runSpacing = runSpacing;

  double _spacing;
  double _runSpacing;

  set spacing(double value) {
    if (value == _spacing) return;
    _spacing = value;
    markNeedsLayout();
  }

  set runSpacing(double value) {
    if (value == _runSpacing) return;
    _runSpacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _LeadingWrapParentData) {
      child.parentData = _LeadingWrapParentData();
    }
  }

  Size _layout(BoxConstraints constraints, ChildLayouter layoutChild) {
    final leading = firstChild;
    if (leading == null) return constraints.smallest;
    final maxWidth = constraints.maxWidth;
    final childConstraints = BoxConstraints(maxWidth: maxWidth);
    final leadingSize = layoutChild(leading, childConstraints);
    final runs = <List<(RenderBox, Size)>>[[]];
    var runWidth = leadingSize.width;
    var child = childAfter(leading);
    while (child != null) {
      final childSize = layoutChild(child, childConstraints);
      final run = runs.last;
      final isFirstRun = runs.length == 1;
      final hasContent = run.isNotEmpty || isFirstRun;
      final nextWidth = hasContent
          ? runWidth + _spacing + childSize.width
          : childSize.width;
      if (hasContent && nextWidth > maxWidth) {
        runs.add([(child, childSize)]);
        runWidth = childSize.width;
      } else {
        run.add((child, childSize));
        runWidth = nextWidth;
      }
      child = childAfter(child);
    }
    var y = 0.0;
    for (var i = 0; i < runs.length; i++) {
      final run = runs[i];
      var runHeight = i == 0 ? leadingSize.height : 0.0;
      var itemsWidth = 0.0;
      for (final (_, size) in run) {
        runHeight = runHeight > size.height ? runHeight : size.height;
        itemsWidth += size.width;
      }
      if (run.isNotEmpty) itemsWidth += _spacing * (run.length - 1);
      if (layoutChild == ChildLayoutHelper.layoutChild) {
        if (i == 0) {
          (leading.parentData as _LeadingWrapParentData).offset = Offset(
            0,
            (runHeight - leadingSize.height) / 2,
          );
        }
        var x = maxWidth - itemsWidth;
        for (final (box, size) in run) {
          (box.parentData as _LeadingWrapParentData).offset = Offset(
            x,
            y + (runHeight - size.height) / 2,
          );
          x += size.width + _spacing;
        }
      }
      y += runHeight + (i == runs.length - 1 ? 0 : _runSpacing);
    }
    return constraints.constrain(Size(maxWidth, y));
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) =>
      _layout(constraints, ChildLayoutHelper.dryLayoutChild);

  @override
  void performLayout() {
    size = _layout(constraints, ChildLayoutHelper.layoutChild);
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
