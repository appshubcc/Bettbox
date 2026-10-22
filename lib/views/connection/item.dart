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
import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bett_box/providers/providers.dart';

final _iconCache = <String, ProcessIconData?>{};
final _iconPending = <String, Future<ProcessIconData?>>{};
const _maxIconCacheSize = 100;
Uint8List? _defaultIconCache;
Future<Uint8List?>? _defaultIconFuture;

void _addToIconCache(String key, ProcessIconData? value) {
  _iconCache.remove(key);
  while (_iconCache.length >= _maxIconCacheSize) {
    final evicted = _iconCache.remove(_iconCache.keys.first);
    final bytes = evicted?.bytes;
    if (bytes != null) {
      imageCache.evict(MemoryImage(bytes), includeLive: false);
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
        ? _ProcessIcon(
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

Future<ProcessIconData?> _loadIcon(String key) async {
  if (system.isDesktop) {
    return processIcon.get(key);
  }
  final bytes = await app.getPackageIcon(key) ?? await _getDefaultPackageIcon();
  return bytes == null ? null : ProcessIconData.bytes(bytes);
}

Future<ProcessIconData?> _getIcon(String key) {
  if (key.isEmpty) {
    if (system.isDesktop) return Future.value();
    return _getDefaultPackageIcon().then(
      (bytes) => bytes == null ? null : ProcessIconData.bytes(bytes),
    );
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

class _ProcessIcon extends StatefulWidget {
  final String process;
  final String path;
  final String port;
  final Function(String)? onClick;

  const _ProcessIcon({
    required this.process,
    required this.path,
    required this.port,
    this.onClick,
  });

  @override
  State<_ProcessIcon> createState() => _ProcessIconState();
}

class _ProcessIconState extends State<_ProcessIcon> {
  late Future<ProcessIconData?> _iconFuture;

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

  Widget get _fallbackIconWidget {
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

  @override
  void didUpdateWidget(_ProcessIcon oldWidget) {
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
          child: FutureBuilder<ProcessIconData?>(
            initialData: _iconCache[_cacheKey],
            future: _iconFuture,
            builder: (context, snapshot) {
              final icon = snapshot.data;
              if (icon == null) {
                if (system.isDesktop &&
                    snapshot.connectionState == ConnectionState.done) {
                  return _fallbackIconWidget;
                }
                return const SizedBox(width: 38, height: 38);
              }
              if (system.isDesktop) {
                final path = icon.path;
                if (path != null) {
                  final file = File(path);
                  if (icon.isSvg) {
                    return SvgPicture.file(
                      file,
                      width: 38,
                      height: 38,
                      fit: BoxFit.contain,
                      placeholderBuilder: (_) =>
                          const SizedBox(width: 38, height: 38),
                      errorBuilder: (_, error, _) {
                        commonPrint.warn('Failed to load SVG $path: $error');
                        return _fallbackIconWidget;
                      },
                    );
                  }
                  return Image.file(
                    file,
                    width: 38,
                    height: 38,
                    // Decoding exactly at the 38px slot aliases thin diagonal
                    // strokes into a wavy staircase. Decode at a few times the
                    // slot size and let the renderer downscale with mipmaps.
                    cacheWidth: cacheSize * 4,
                    filterQuality: FilterQuality.medium,
                    gaplessPlayback: true,
                    errorBuilder: (_, error, _) {
                      commonPrint.warn('Failed to load icon $path: $error');
                      return _fallbackIconWidget;
                    },
                  );
                }
                final bytes = icon.bytes;
                if (bytes == null) {
                  return const SizedBox(width: 38, height: 38);
                }
                return Image.memory(
                  bytes,
                  width: 38,
                  height: 38,
                  filterQuality: FilterQuality.medium,
                  gaplessPlayback: true,
                );
              }
              final bytes = icon.bytes;
              if (bytes == null) {
                return const SizedBox(width: 38, height: 38);
              }
              return Image(
                image: ResizeImage(
                  MemoryImage(bytes),
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
    final chains = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        for (final chain in info.chains)
          CommonChip(label: chain, onPressed: () {}),
      ],
    );
    return ListItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(appLocalizations.proxyChains),
          Flexible(child: chains),
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
      title: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(appLocalizations.toolbox),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
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
                      showIpDetailDialog(context, ip);
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
      _buildItem(
        title: appLocalizations.networkType,
        desc: info.metadata.network,
      ),
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
      if (info.metadata.dnsMode != null)
        _buildItem(
          title: appLocalizations.dnsMode,
          desc: info.metadata.dnsMode!.name,
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
