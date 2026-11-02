import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/connection/item.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'common.dart';
import 'dns_query.dart';
import 'ip_lookup.dart';
import 'mrs_lookup.dart';
import 'route_trace.dart';

enum _Period { day, week, month }

enum _Rank { hosts, processes, nodes, profiles }

typedef _Range = ({DateTime start, DateTime end});

const _rankLimit = 20;

String _two(int value) => value.toString().padLeft(2, '0');

String _dayKey(DateTime date) =>
    '${date.year}-${_two(date.month)}-${_two(date.day)}';

_Range _rangeOf(_Period period, int offset) {
  final now = DateTime.now();
  switch (period) {
    case _Period.day:
      final day = DateTime(now.year, now.month, now.day - offset);
      return (start: day, end: day);
    case _Period.week:
      final start = DateTime(
        now.year,
        now.month,
        now.day - (now.weekday - 1) - offset * 7,
      );
      return (
        start: start,
        end: DateTime(start.year, start.month, start.day + 6),
      );
    case _Period.month:
      final start = DateTime(now.year, now.month - offset, 1);
      return (start: start, end: DateTime(start.year, start.month + 1, 0));
  }
}

String _rangeLabel(_Period period, _Range range) => switch (period) {
  _Period.day => _dayKey(range.start),
  _Period.week =>
    '${_dayKey(range.start).substring(5)} ~ ${_dayKey(range.end).substring(5)}',
  _Period.month => _dayKey(range.start).substring(0, 7),
};

String _bytes(int value) => TrafficValue(value: value).show;

String _retentionLabel(int days) => '$days ${appLocalizations.days(days)}';

bool _isAddress(String value) => InternetAddress.tryParse(value) != null;

class TrafficStatsPage extends ConsumerStatefulWidget {
  const TrafficStatsPage({super.key});

  @override
  ConsumerState<TrafficStatsPage> createState() => _TrafficStatsPageState();
}

class _TrafficStatsPageState extends ConsumerState<TrafficStatsPage> {
  _Period _period = _Period.day;
  int _offset = 0;
  _Rank _rank = _Rank.hosts;
  TrafficStatsResult? _result;
  Timer? _timer;
  int _serial = 0;

  _Range get _range => _rangeOf(_period, _offset);

  bool get _isLive => _period == _Period.day && _offset == 0;

  @override
  void initState() {
    super.initState();
    globalState.backgroundMode.addListener(_handleBackgroundMode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.afterRouteTransition(_load);
    });
    _syncTimer();
  }

  @override
  void dispose() {
    globalState.backgroundMode.removeListener(_handleBackgroundMode);
    _timer?.cancel();
    super.dispose();
  }

  void _handleBackgroundMode() {
    if (!globalState.backgroundMode.value && _isLive) _load();
    _syncTimer();
  }

  void _syncTimer() {
    if (!_isLive || globalState.backgroundMode.value) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _timer ??= Timer.periodic(const Duration(seconds: 30), (_) => _load());
  }

  Future<void> _load() async {
    final serial = ++_serial;
    final range = _range;
    TrafficStatsResult result;
    try {
      result = await clashCore.getTrafficStats(
        start: _dayKey(range.start),
        end: _dayKey(range.end),
      );
    } catch (_) {
      result = const TrafficStatsResult();
    }
    if (!mounted || serial != _serial) return;
    setState(() => _result = result);
  }

  void _select(_Period period, int offset) {
    setState(() {
      _period = period;
      _offset = offset;
      _result = null;
    });
    _load();
    _syncTimer();
  }

  void _openSettings() {
    globalState.showAdaptiveSheet(
      child: _TrafficStatsSettingsDialog(onCleared: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (enable, siteIcon) = ref.watch(
      trafficStatsSettingProvider.select(
        (state) => (state.enable, state.siteIcon),
      ),
    );
    final result = _result;
    final range = _range;
    final since = result?.since ?? '';
    final canBack =
        since.isNotEmpty && _dayKey(range.start).compareTo(since) > 0;
    return CommonScaffold(
      title: appLocalizations.trafficUsage,
      actions: [
        IconButton(
          tooltip: appLocalizations.settings,
          onPressed: _openSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      body: ToolPageBody(
        children: [
          if (!enable) ...[
            ToolSurface(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListItem.switchItem(
                title: Text(appLocalizations.trafficStatsEnable),
                subtitle: Text(appLocalizations.trafficStatsDisabledTip),
                delegate: SwitchDelegate(
                  value: false,
                  onChanged: (value) => ref
                      .read(trafficStatsSettingProvider.notifier)
                      .updateState((state) => state.copyWith(enable: value)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          ToolSegmented<_Period>(
            values: _Period.values,
            value: _period,
            labelOf: (period) => switch (period) {
              _Period.day => appLocalizations.today,
              _Period.week => appLocalizations.thisWeek,
              _Period.month => appLocalizations.thisMonth,
            },
            onChanged: (period) => _select(period, 0),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                onPressed: canBack ? () => _select(_period, _offset + 1) : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  _rangeLabel(_period, range),
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              IconButton(
                onPressed: _offset > 0
                    ? () => _select(_period, _offset - 1)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ToolLoadingSwitcher(
            loading: result == null,
            child: result == null
                ? const SizedBox.shrink()
                : _buildContent(context, result, range, siteIcon),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TrafficStatsResult result,
    _Range range,
    bool siteIcon,
  ) {
    final ranks = [
      _Rank.hosts,
      if (result.processes.isNotEmpty) _Rank.processes,
      _Rank.nodes,
      if (result.profiles.isNotEmpty) _Rank.profiles,
    ];
    final rank = ranks.contains(_rank) ? _rank : _Rank.hosts;
    final items = switch (rank) {
      _Rank.hosts => result.hosts,
      _Rank.processes => result.processes,
      _Rank.nodes => result.nodes,
      _Rank.profiles => result.profiles,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToolSurface(child: _Overview(result: result)),
        ToolSectionHeader(appLocalizations.ruleHits),
        _RuleHits(
          key: ValueKey('${_period.name}:$_offset'),
          rules: result.rules.take(_rankLimit).toList(),
          total: result.ruleHits,
        ),
        ToolSectionHeader(appLocalizations.trafficRanking),
        if (ranks.length > 1) ...[
          ToolSegmented<_Rank>(
            values: ranks,
            value: rank,
            labelOf: (rank) => switch (rank) {
              _Rank.hosts => appLocalizations.domain,
              _Rank.processes => appLocalizations.process,
              _Rank.nodes => appLocalizations.node,
              _Rank.profiles => appLocalizations.profile,
            },
            onChanged: (rank) => setState(() => _rank = rank),
          ),
          const SizedBox(height: 10),
        ],
        ToolSurface(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: items.isEmpty
              ? const _NoData()
              : Column(
                  children: [
                    for (final item in items.take(_rankLimit))
                      _RankRow(
                        key: ValueKey('${rank.name}:${item.name}'),
                        leading: _buildLeading(rank, item, siteIcon),
                        name: item.name,
                        total: item.total,
                        ratio: item.total / math.max(items.first.total, 1),
                        onTap: rank == _Rank.hosts
                            ? () => _showHostDetail(
                                context,
                                host: item.name,
                                range: range,
                                hourly: _period == _Period.day,
                                siteIcon: siteIcon,
                              )
                            : null,
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildLeading(_Rank rank, TrafficStatsItem item, bool siteIcon) {
    return switch (rank) {
      _Rank.hosts => SiteIcon(domain: item.name, size: 32, enabled: siteIcon),
      _Rank.processes => ConnectionProcessIcon(
        process: item.name,
        path: item.path,
        port: '',
      ),
      _Rank.nodes => const _TonalIcon(Icons.hub_outlined),
      _Rank.profiles => const _TonalIcon(Icons.description_outlined),
    };
  }
}

void _showHostDetail(
  BuildContext context, {
  required String host,
  required _Range range,
  required bool hourly,
  required bool siteIcon,
}) {
  showSheet(
    context: context,
    builder: (_, type) => AdaptiveSheetScaffold(
      type: type,
      title: host,
      body: _HostDetail(
        host: host,
        range: range,
        hourly: hourly,
        siteIcon: siteIcon,
      ),
    ),
  );
}

class _Overview extends StatelessWidget {
  final TrafficStatsResult result;

  const _Overview({required this.result});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final upColor = globalState.theme.darken3PrimaryContainer;
    final downColor = globalState.theme.darken2SecondaryContainer;
    final total = TrafficValue(value: result.total);
    final muted = context.textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    return Row(
      children: [
        RingChart(
          size: 112,
          strokeWidth: 10,
          total: math.max(result.total, 1).toDouble(),
          trackColor: colorScheme.onSurface.withValues(alpha: 0.06),
          segments: [
            if (result.up > 0)
              RingSegment(value: result.up.toDouble(), color: upColor),
            if (result.down > 0)
              RingSegment(value: result.down.toDouble(), color: downColor),
          ],
          centerChild: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                total.showValue,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              Text(total.showUnit, style: muted),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Legend(
                color: upColor,
                label: appLocalizations.upload,
                value: _bytes(result.up),
              ),
              const SizedBox(height: 10),
              _Legend(
                color: downColor,
                label: appLocalizations.download,
                value: _bytes(result.down),
              ),
              const SizedBox(height: 14),
              Text(
                '${appLocalizations.proxies} ${_bytes(result.proxyTotal)}  ·  '
                '${appLocalizations.direct} ${_bytes(math.max(result.total - result.proxyTotal, 0))}',
                maxLines: 2,
                style: muted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _Legend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _NoData extends StatelessWidget {
  const _NoData();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          appLocalizations.noData,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _RuleHits extends StatelessWidget {
  final List<TrafficStatsItem> rules;
  final int total;

  const _RuleHits({super.key, required this.rules, required this.total});

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) {
      return const ToolSurface(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: _NoData(),
      );
    }
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: rules.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, index) => _RuleCard(
          key: ValueKey(rules[index].name),
          rule: rules[index],
          total: total,
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final TrafficStatsItem rule;
  final int total;

  const _RuleCard({super.key, required this.rule, required this.total});

  String _percent(double ratio) {
    final value = ratio * 100;
    if (value > 0 && value < 1) return '<1%';
    return '${value >= 10 ? value.round() : value.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final primary = colorScheme.primary;
    final separator = rule.name.indexOf(',');
    final type = separator < 0 ? rule.name : rule.name.substring(0, separator);
    final payload = separator < 0 ? '' : rule.name.substring(separator + 1);
    final ratio = rule.hits / math.max(total, 1);
    final muted = context.textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return SizedBox(
      width: 136,
      child: ToolSurface(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
        child: Column(
          children: [
            RingChart(
              size: 56,
              strokeWidth: 5,
              total: 1,
              trackColor: primary.withValues(alpha: 0.12),
              segments: [
                if (rule.hits > 0)
                  RingSegment(value: ratio.clamp(0.0, 1.0), color: primary),
              ],
              centerChild: Text(
                _percent(ratio),
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 8),
            EmojiText(
              payload.isEmpty ? type : payload,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(payload.isEmpty ? ' ' : type, maxLines: 1, style: muted),
            const SizedBox(height: 4),
            Text(
              '${appLocalizations.hitCount(rule.hits)} · ${_bytes(rule.total)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChart extends StatefulWidget {
  final List<TrafficStatsPoint> series;
  final bool hourly;

  const _TrendChart({required this.series, required this.hourly});

  @override
  State<_TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<_TrendChart> {
  int? _selected;

  @override
  void didUpdateWidget(_TrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.series.length != widget.series.length) _selected = null;
  }

  String _axisLabel(TrafficStatsPoint point) {
    if (widget.hourly) return point.label;
    return int.tryParse(point.label.split('-').last)?.toString() ?? point.label;
  }

  String _title(TrafficStatsPoint point) => widget.hourly
      ? '${_two(int.tryParse(point.label) ?? 0)}:00'
      : point.label.substring(5);

  bool _showLabel(int index) {
    final length = widget.series.length;
    if (length <= 7) return true;
    if (widget.hourly) return index % 6 == 0 || index == length - 1;
    return index == 0 || (index + 1) % 5 == 0 || index == length - 1;
  }

  void _pick(Offset position, double width) {
    final length = widget.series.length;
    if (length == 0 || width <= 0) return;
    final index = (position.dx / width * length).floor().clamp(0, length - 1);
    setState(() => _selected = index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final series = widget.series;
    final selected = _selected;
    final point = selected != null && selected < series.length
        ? series[selected]
        : null;
    final muted = context.textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 18,
          child: point == null
              ? null
              : Text(
                  '${_title(point)}   ↑ ${_bytes(point.up)}   ↓ ${_bytes(point.down)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: muted?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (_, constraints) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) =>
                _pick(details.localPosition, constraints.maxWidth),
            onHorizontalDragUpdate: (details) =>
                _pick(details.localPosition, constraints.maxWidth),
            child: SizedBox(
              height: 128,
              width: constraints.maxWidth,
              child: CustomPaint(
                painter: _TrendPainter(
                  series: series,
                  selected: selected,
                  upColor: globalState.theme.darken3PrimaryContainer,
                  downColor: globalState.theme.darken2SecondaryContainer,
                  trackColor: colorScheme.onSurface.withValues(alpha: 0.05),
                  labelStyle: muted ?? const TextStyle(fontSize: 11),
                  labels: [
                    for (final (index, point) in series.indexed)
                      _showLabel(index) ? _axisLabel(point) : '',
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<TrafficStatsPoint> series;
  final int? selected;
  final Color upColor;
  final Color downColor;
  final Color trackColor;
  final TextStyle labelStyle;
  final List<String> labels;

  const _TrendPainter({
    required this.series,
    required this.selected,
    required this.upColor,
    required this.downColor,
    required this.trackColor,
    required this.labelStyle,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;
    const labelHeight = 18.0;
    final chartHeight = size.height - labelHeight;
    final slot = size.width / series.length;
    final barWidth = math.min(math.max(slot * 0.56, 2.0), 18.0);
    final peak = series.fold<int>(
      0,
      (value, point) => math.max(value, point.up + point.down),
    );
    final radius = Radius.circular(math.min(barWidth / 2, 4));
    for (final (index, point) in series.indexed) {
      final left = slot * index + (slot - barWidth) / 2;
      final dim = selected != null && selected != index;
      canvas.drawRRect(
        RRect.fromLTRBR(left, 0, left + barWidth, chartHeight, radius),
        Paint()..color = trackColor,
      );
      final total = point.up + point.down;
      if (peak > 0 && total > 0) {
        final height = math.max(chartHeight * total / peak, 2.0);
        final downHeight = height * point.down / total;
        final top = chartHeight - height;
        final rect = RRect.fromLTRBR(
          left,
          top,
          left + barWidth,
          chartHeight,
          radius,
        );
        canvas.save();
        canvas.clipRRect(rect);
        canvas.drawRect(
          Rect.fromLTRB(left, top, left + barWidth, chartHeight - downHeight),
          Paint()..color = upColor.withValues(alpha: dim ? 0.35 : 1),
        );
        canvas.drawRect(
          Rect.fromLTRB(
            left,
            chartHeight - downHeight,
            left + barWidth,
            chartHeight,
          ),
          Paint()..color = downColor.withValues(alpha: dim ? 0.35 : 1),
        );
        canvas.restore();
      }
      final label = index < labels.length ? labels[index] : '';
      if (label.isEmpty) continue;
      final painter = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      final x = (slot * index + slot / 2 - painter.width / 2)
          .clamp(0.0, math.max(size.width - painter.width, 0.0))
          .toDouble();
      painter.paint(canvas, Offset(x, chartHeight + 4));
    }
  }

  @override
  bool shouldRepaint(_TrendPainter oldDelegate) =>
      oldDelegate.series != series ||
      oldDelegate.selected != selected ||
      oldDelegate.upColor != upColor ||
      oldDelegate.downColor != downColor ||
      oldDelegate.trackColor != trackColor;
}

class _TonalIcon extends StatelessWidget {
  final IconData icon;

  const _TonalIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, size: 18, color: primary),
    );
  }
}

class _RankRow extends StatelessWidget {
  final Widget leading;
  final String name;
  final int total;
  final double ratio;
  final VoidCallback? onTap;

  const _RankRow({
    super.key,
    required this.leading,
    required this.name,
    required this.total,
    required this.ratio,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final primary = colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            SizedBox.square(dimension: 38, child: Center(child: leading)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: EmojiText(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _bytes(total),
                        style: context.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      height: 4,
                      alignment: Alignment.centerLeft,
                      color: primary.withValues(alpha: 0.12),
                      child: FractionallySizedBox(
                        widthFactor: ratio.clamp(0.0, 1.0),
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HostDetail extends StatefulWidget {
  final String host;
  final _Range range;
  final bool hourly;
  final bool siteIcon;

  const _HostDetail({
    required this.host,
    required this.range,
    required this.hourly,
    required this.siteIcon,
  });

  @override
  State<_HostDetail> createState() => _HostDetailState();
}

class _HostDetailState extends State<_HostDetail> {
  TrafficStatsResult? _result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.afterRouteTransition(_load);
    });
  }

  Future<void> _load() async {
    if (!mounted) return;
    TrafficStatsResult result;
    try {
      result = await clashCore.getTrafficStats(
        start: _dayKey(widget.range.start),
        end: _dayKey(widget.range.end),
        host: widget.host,
      );
    } catch (_) {
      result = const TrafficStatsResult();
    }
    if (!mounted) return;
    setState(() => _result = result);
  }

  Widget _buildTools(BuildContext context) {
    final host = widget.host;
    final isAddress = _isAddress(host);
    void open(Widget page) => BaseNavigator.push(context, page);
    Widget chip(IconData icon, String label, Widget Function() page) =>
        CommonChip(
          avatar: Icon(icon, size: 16, color: context.colorScheme.primary),
          label: label,
          onPressed: () => open(page()),
        );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip(
          Icons.route_rounded,
          appLocalizations.routeTrace,
          () => RouteTracePage(initialTarget: host),
        ),
        if (!isAddress)
          chip(
            Icons.dns_rounded,
            appLocalizations.dnsQuery,
            () => DnsQueryPage(initialDomain: host),
          ),
        chip(
          Icons.manage_search_rounded,
          appLocalizations.mrsLookup,
          () => MrsLookupPage(initialQuery: host),
        ),
        if (isAddress)
          chip(
            Icons.travel_explore_rounded,
            appLocalizations.ipLookup,
            () => IpLookupPage(initialQuery: host),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final colorScheme = context.colorScheme;
    final subs = result?.hosts.firstOrNull?.subs ?? const <TrafficStatsItem>[];
    final maxSub = subs.isEmpty ? 1 : math.max(subs.first.total, 1);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        Row(
          children: [
            SiteIcon(domain: widget.host, size: 40, enabled: widget.siteIcon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _bytes(result?.total ?? 0),
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '↑ ${_bytes(result?.up ?? 0)}   ↓ ${_bytes(result?.down ?? 0)}',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ToolSectionHeader(appLocalizations.toolbox),
        _buildTools(context),
        if (!widget.hourly && (result?.series.isNotEmpty ?? false)) ...[
          ToolSectionHeader(appLocalizations.trafficTrend),
          ToolSurface(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: _TrendChart(
              series: result?.series ?? const [],
              hourly: false,
            ),
          ),
        ],
        if (subs.isNotEmpty) ...[
          ToolSectionHeader(appLocalizations.subdomains),
          ToolSurface(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              children: [
                for (final sub in subs)
                  _RankRow(
                    key: ValueKey(sub.name),
                    leading: SiteIcon(
                      domain: widget.host,
                      size: 24,
                      enabled: widget.siteIcon,
                    ),
                    name: sub.name,
                    total: sub.total,
                    ratio: sub.total / maxSub,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TrafficStatsSettingsDialog extends ConsumerWidget {
  final VoidCallback onCleared;

  const _TrafficStatsSettingsDialog({required this.onCleared});

  Future<void> _clear() async {
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.trafficStatsClearTip),
    );
    if (res != true) return;
    await globalState.appController.safeRun(() async {
      await clashCore.clearTrafficStats();
      await siteIconCache.clear();
    });
    onCleared();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final props = ref.watch(trafficStatsSettingProvider);
    void update(TrafficStatsProps Function(TrafficStatsProps state) builder) =>
        ref.read(trafficStatsSettingProvider.notifier).updateState(builder);
    return CommonDialog(
      title: appLocalizations.settings,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListItem.switchItem(
            title: Text(appLocalizations.trafficStatsEnable),
            delegate: SwitchDelegate(
              value: props.enable,
              onChanged: (value) =>
                  update((state) => state.copyWith(enable: value)),
            ),
          ),
          ListItem.switchItem(
            title: Text(appLocalizations.trafficStatsDetail),
            subtitle: Text(appLocalizations.trafficStatsDetailDesc),
            delegate: SwitchDelegate(
              value: props.detail,
              onChanged: (value) =>
                  update((state) => state.copyWith(detail: value)),
            ),
          ),
          ListItem.switchItem(
            title: Text(appLocalizations.trafficStatsSiteIcon),
            subtitle: Text(appLocalizations.trafficStatsSiteIconDesc),
            delegate: SwitchDelegate(
              value: props.siteIcon,
              onChanged: (value) =>
                  update((state) => state.copyWith(siteIcon: value)),
            ),
          ),
          ListItem<int>.options(
            title: Text(appLocalizations.trafficStatsRetention),
            subtitle: Text(_retentionLabel(props.retentionDays)),
            delegate: OptionsDelegate<int>(
              title: appLocalizations.trafficStatsRetention,
              options: trafficStatsRetentionOptions,
              value: props.retentionDays,
              textBuilder: _retentionLabel,
              onChanged: (days) {
                if (days == null) return;
                update((state) => state.copyWith(retentionDays: days));
              },
            ),
          ),
          ListItem(
            title: Text(
              appLocalizations.clearData,
              style: TextStyle(color: context.colorScheme.error),
            ),
            onTap: _clear,
          ),
        ],
      ),
    );
  }
}
