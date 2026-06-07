import 'dart:typed_data';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bett_box/providers/providers.dart';

final _iconCache = <String, Uint8List?>{};
final _iconCacheKeys = <String>[];
const _maxIconCacheSize = 50;
Uint8List? _defaultIconCache;
Future<Uint8List?>? _defaultIconFuture;

void _addToIconCache(String key, Uint8List? value) {
  if (_iconCache.containsKey(key)) {
    _iconCacheKeys.remove(key);
    _iconCacheKeys.add(key);
    _iconCache[key] = value;
    return;
  }

  while (_iconCacheKeys.length >= _maxIconCacheSize) {
    final oldestKey = _iconCacheKeys.removeAt(0);
    _iconCache.remove(oldestKey);
  }

  _iconCacheKeys.add(key);
  _iconCache[key] = value;
}

class TrackerInfoItem extends ConsumerWidget {
  final TrackerInfo trackerInfo;
  final Function(String)? onClickKeyword;
  final Widget? trailing;
  final String detailTitle;

  const TrackerInfoItem({
    super.key,
    required this.trackerInfo,
    this.onClickKeyword,
    this.trailing,
    required this.detailTitle,
  });

  static double get subTitleHeight {
    return globalState.measure.bodySmallHeight + 20;
  }

  static double get height {
    final measure = globalState.measure;
    return measure.bodyMediumHeight +
        8 +
        8 +
        measure.bodyLargeHeight +
        subTitleHeight +
        16 * 2;
  }

  String _getSourceText(TrackerInfo trackerInfo) {
    final progress = trackerInfo.progressText.isNotEmpty
        ? '${trackerInfo.progressText} · '
        : '';
    final traffic = Traffic(up: trackerInfo.upload, down: trackerInfo.download);
    return '$progress${traffic.toString()}';
  }

  @override
  Widget build(BuildContext context, ref) {
    final value = ref.watch(
      patchClashConfigProvider.select(
        (state) =>
            state.findProcessMode == FindProcessMode.always && system.isAndroid,
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
                style: context.textTheme.bodyLarge,
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
        const SizedBox(height: 6),
        Text(
          _getSourceText(trackerInfo),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
    final subTitle = SizedBox(
      height: subTitleHeight,
      child: Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: ListView.separated(
              separatorBuilder: (_, _) => SizedBox(width: 6),
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: trackerInfo.chains.length,
              itemBuilder: (_, index) {
                final chain = trackerInfo.chains[index];
                return CommonChip(
                  label: chain,
                  labelStyle: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    if (onClickKeyword == null) return;
                    onClickKeyword!(chain);
                  },
                );
              },
            ),
          ),
          ?trailing,
        ],
      ),
    );
    final icon = value
        ? _ProcessIcon(
            process: trackerInfo.metadata.process,
            onClick: onClickKeyword,
          )
        : null;
    return RepaintBoundary(
      child: ListItem(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () {
        showExtend(
          context,
          builder: (_, type) {
            return AdaptiveSheetScaffold(
              type: type,
              body: TrackerInfoDetailView(trackerInfo: trackerInfo, detailTitle: detailTitle),
              title: detailTitle,
            );
          },
        );
      },
      title: Column(
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
  }
}

Future<Uint8List?> _getPackageIcon(String process) async {
  if (process.isEmpty) {
    return _getDefaultPackageIcon();
  }
  final cachedIcon = _iconCache[process];
  if (cachedIcon != null) {
    return cachedIcon;
  }
  final icon = await app.getPackageIcon(process);
  if (icon != null) {
    _addToIconCache(process, icon);
    return icon;
  }
  return _getDefaultPackageIcon();
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
  final Function(String)? onClick;

  const _ProcessIcon({required this.process, this.onClick});

  @override
  State<_ProcessIcon> createState() => _ProcessIconState();
}

class _ProcessIconState extends State<_ProcessIcon> {
  late Future<Uint8List?> _iconFuture;

  @override
  void initState() {
    super.initState();
    _iconFuture = _getPackageIcon(widget.process);
  }

  @override
  void didUpdateWidget(_ProcessIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.process != widget.process) {
      _iconFuture = _getPackageIcon(widget.process);
    }
  }

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheSize = (42 * devicePixelRatio).ceil();

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          if (widget.process.isEmpty) return;
          widget.onClick?.call(widget.process);
        },
        child: Container(
          margin: const EdgeInsets.only(top: 4),
          width: 42,
          height: 42,
          alignment: Alignment.center,
          child: FutureBuilder<Uint8List?>(
            future: _iconFuture,
            builder: (context, snapshot) {
              final iconBytes = snapshot.data;
              if (iconBytes == null) {
                return const SizedBox(width: 42, height: 42);
              }
              return Image(
                image: ResizeImage(
                  MemoryImage(iconBytes),
                  width: cacheSize,
                  height: cacheSize,
                  allowUpscaling: false,
                ),
                width: 42,
                height: 42,
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

  const TrackerInfoDetailView({super.key, required this.trackerInfo, required this.detailTitle});

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

  String _getSourceText(TrackerInfo info) {
    final sourceIP = info.metadata.sourceIP;
    if (sourceIP.isEmpty) {
      return '';
    }
    final sourcePort = info.metadata.sourcePort;
    if (sourcePort.isNotEmpty) {
      return '$sourceIP:$sourcePort';
    }
    return sourceIP;
  }

  String _getDestinationText(TrackerInfo info) {
    final destinationIP = info.metadata.destinationIP;
    if (destinationIP.isEmpty) {
      return '';
    }
    final destinationPort = info.metadata.destinationPort;
    if (destinationPort.isNotEmpty) {
      return '$destinationIP:$destinationPort';
    }
    return destinationIP;
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
          Flexible(child: Text(desc, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = ref.watch(connectionsProvider);
    final info = connections.firstWhere(
      (e) => e.id == trackerInfo.id,
      orElse: () => trackerInfo,
    );

    final items = [
      _buildItem(
        title: appLocalizations.creationTime,
        desc: info.start.showFull,
      ),
      if (_getProgressText(info).isNotEmpty)
        _buildItem(title: appLocalizations.progress, desc: _getProgressText(info)),
      _buildItem(
        title: appLocalizations.networkType,
        desc: info.metadata.network,
      ),
      _buildItem(title: appLocalizations.rule, desc: _getRuleText(info)),
      if (info.metadata.host.isNotEmpty)
        _buildItem(
          title: appLocalizations.host,
          desc: info.metadata.host,
        ),
      if (_getSourceText(info).isNotEmpty)
        _buildItem(title: appLocalizations.source, desc: _getSourceText(info)),
      if (_getDestinationText(info).isNotEmpty)
        _buildItem(
          title: appLocalizations.destination,
          desc: _getDestinationText(info),
        ),
      _buildItem(
        title: appLocalizations.upload,
        desc: TrafficValue(value: info.upload).show,
      ),
      _buildItem(
        title: appLocalizations.download,
        desc: TrafficValue(value: info.download).show,
      ),
      if (detailTitle.contains(appLocalizations.connection))
        _buildItem(
          title: appLocalizations.realTimeSpeed,
          desc: Traffic(up: info.uploadSpeed, down: info.downloadSpeed).toString(),
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
        _buildItem(
          title: appLocalizations.remoteDestination,
          desc: info.metadata.remoteDestination,
        ),
      _buildChains(info),
    ];
    return SelectionArea(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 12),
        itemCount: items.length,
        itemBuilder: (_, index) {
          return items[index];
        },
      ),
    );
  }
}
