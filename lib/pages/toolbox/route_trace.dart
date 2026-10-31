import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'common.dart';

class RouteTracePage extends ConsumerStatefulWidget {
  final String? initialTarget;
  final String? initialNetwork;
  final int? initialPort;

  const RouteTracePage({
    super.key,
    this.initialTarget,
    this.initialNetwork,
    this.initialPort,
  });

  @override
  ConsumerState<RouteTracePage> createState() => _RouteTracePageState();
}

class _RouteTracePageState extends ConsumerState<RouteTracePage>
    with ToolHistoryMixin<RouteTracePage> {
  static String _lastNetwork = 'tcp';
  static int _lastPort = 443;

  @override
  String get historyKey => 'route';

  final _controller = TextEditingController();
  late String _network = switch (widget.initialNetwork?.toLowerCase()) {
    final network? when network == 'tcp' || network == 'udp' => network,
    _ => _lastNetwork,
  };
  late final _portController = TextEditingController(
    text: '${widget.initialPort ?? _lastPort}',
  );
  RouteTraceResult? _result;
  bool _tracing = false;

  @override
  void initState() {
    super.initState();
    loadHistory();
    final initial = widget.initialTarget?.trim() ?? '';
    if (initial.isNotEmpty) {
      _controller.text = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) => _trace(initial));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _trace(String raw) async {
    final target = raw.trim();
    if (target.isEmpty || _tracing) return;
    final port = (int.tryParse(_portController.text.trim()) ?? 443).clamp(
      1,
      65535,
    );
    _lastPort = port;
    _lastNetwork = _network;
    _portController.text = '$port';
    FocusScope.of(context).unfocus();
    setState(() => _tracing = true);
    final result = await clashCore.routeTrace(
      target: target,
      network: _network,
      port: port,
    );
    if (!mounted) return;
    if (result.error.isEmpty) addHistory(target);
    setState(() {
      _tracing = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isStart = ref.watch(runTimeProvider.select((state) => state != null));
    final result = _result;
    final colorScheme = context.colorScheme;
    return CommonScaffold(
      title: appLocalizations.routeTrace,
      body: ToolPageBody(
        children: [
          ToolSearchField(
            controller: _controller,
            hintText: appLocalizations.routeTraceHint,
            busy: _tracing,
            onSubmitted: _trace,
          ),
          const SizedBox(height: 12),
          ToolSurface(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: ToolSegmented<String>(
                    values: const ['tcp', 'udp'],
                    value: _network,
                    labelOf: (value) => value.toUpperCase(),
                    onChanged: (value) => setState(() => _network = value),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 96,
                  child: ToolTvField(
                    controller: _portController,
                    child: TextField(
                      controller: _portController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: appLocalizations.port,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ToolHistoryBar(
            items: history,
            onSelected: (value) {
              _controller.text = value;
              _trace(value);
            },
            onClear: clearHistory,
          ),
          if (!isStart) ...[
            const SizedBox(height: 12),
            ToolNote(
              icon: ReIcons.infoCircle,
              text: appLocalizations.routeTraceStopped,
              color: colorScheme.tertiary,
            ),
          ],
          ToolLoadingSwitcher(
            loading: _tracing,
            child: result == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: result.error.isNotEmpty
                        ? ToolNote(
                            icon: ReIcons.alertCircle,
                            text: result.error == 'stopped'
                                ? appLocalizations.routeTraceStopped
                                : appLocalizations.ipLookupInvalid,
                            color: colorScheme.error,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _VerdictCard(result: result),
                              const SizedBox(height: 12),
                              _TimelineCard(result: result),
                            ],
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

String _stepText(RouteTraceStep step) =>
    step.payload.isEmpty ? step.type : '${step.type},${step.payload}';

class _VerdictCard extends StatelessWidget {
  final RouteTraceResult result;

  const _VerdictCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final chains = result.chains;
    final last = chains.isEmpty ? null : chains.last;
    final matched = result.matched;
    final isDirect = last?.type == 'Direct';
    final isReject = last?.type.startsWith('Reject') ?? false;
    final color = isReject
        ? colorScheme.error
        : isDirect
        ? const Color(0xFF22A06B)
        : colorScheme.primary;
    return ToolSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.14),
                ),
                child: Icon(
                  isReject
                      ? ReIcons.ban
                      : isDirect
                      ? ReIcons.arrowUpRight
                      : ReIcons.route,
                  color: color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLocalizations.routeTraceFinal,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    EmojiText(
                      last == null
                          ? '—'
                          : last.name == 'DIRECT'
                          ? appLocalizations.direct
                          : last.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (last != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    last.type,
                    style: textTheme.labelSmall?.copyWith(color: color),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                icon: ReIcons.listCheck,
                text: switch (result.mode) {
                  'global' => appLocalizations.routeTraceModeGlobal,
                  'direct' => appLocalizations.routeTraceModeDirect,
                  _ =>
                    matched == null
                        ? appLocalizations.routeTraceNoMatch
                        : _stepText(matched),
                },
              ),
              _Chip(
                icon: ReIcons.timer,
                text:
                    '${result.matchTime < 1 ? result.matchTime.clamp(0.01, 1).toStringAsFixed(2) : result.matchTime.toStringAsFixed(1)} ms',
              ),
              _Chip(
                icon: ReIcons.sitemap,
                text: '${result.network.toUpperCase()} · ${result.port}',
              ),
              if (result.network == 'udp' && !result.supportUdp)
                _Chip(
                  icon: ReIcons.warning,
                  text: appLocalizations.routeTraceUdpUnsupported,
                  color: colorScheme.error,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _Chip({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? context.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: EmojiText(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEntry {
  final IconData icon;
  final String title;
  final String detail;
  final Color? color;
  final Widget? extra;

  const _TimelineEntry({
    required this.icon,
    required this.title,
    required this.detail,
    this.color,
    this.extra,
  });
}

class _TimelineCard extends StatelessWidget {
  final RouteTraceResult result;

  const _TimelineCard({required this.result});

  void _showRules(BuildContext context) {
    showSheet<void>(
      context: context,
      props: const SheetProps(maxWidth: 520),
      builder: (_, type) => AdaptiveSheetScaffold(
        type: type,
        title: appLocalizations.routeTraceCheckedRules,
        body: _RulesList(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isRuleMode = result.mode != 'global' && result.mode != 'direct';
    final target = result.host.isNotEmpty ? result.host : result.dstIp;
    final matched = result.matched;
    final dnsDetail = result.host.isEmpty
        ? appLocalizations.routeTraceDnsIp
        : result.hostsIps.isNotEmpty
        ? appLocalizations.routeTraceHostsHit(result.hostsIps.join(', '))
        : result.resolvedBy >= 0
        ? [
            appLocalizations.routeTraceDnsBy(
              result.resolvedBy + 1,
              result.resolveTime.toStringAsFixed(1),
            ),
            if (result.resolveError.isNotEmpty)
              result.resolveError
            else
              result.resolvedIps.join(', '),
          ].join('\n')
        : appLocalizations.routeTraceDnsSkipped;
    final entries = [
      _TimelineEntry(
        icon: ReIcons.flag,
        title: appLocalizations.routeTraceInput,
        detail: [
          target,
          if (result.dnsMode.isNotEmpty) 'DNS · ${result.dnsMode}',
        ].join('\n'),
      ),
      _TimelineEntry(
        icon: ReIcons.globalSearch,
        title: appLocalizations.routeTraceDns,
        detail: dnsDetail,
        color: result.resolveError.isNotEmpty ? colorScheme.error : null,
      ),
      if (isRuleMode)
        _TimelineEntry(
          icon: ReIcons.listCheck,
          title: appLocalizations.routeTraceRules,
          detail: [
            if (matched != null) ...[
              appLocalizations.routeTraceRulesSummary(
                result.total,
                matched.index + 1,
              ),
              '${_stepText(matched)} → ${matched.adapter}',
            ] else ...[
              appLocalizations.routeTraceRulesTotal(result.total),
              appLocalizations.routeTraceNoMatch,
            ],
          ].join('\n'),
          color: matched == null ? colorScheme.tertiary : null,
          extra: result.steps.isEmpty
              ? null
              : Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => _showRules(context),
                    icon: const Icon(ReIcons.listSquare, size: 16),
                    label: Text(appLocalizations.routeTraceViewRules),
                  ),
                ),
        )
      else
        _TimelineEntry(
          icon: ReIcons.listCheck,
          title: appLocalizations.routeTraceRules,
          detail: result.mode == 'global'
              ? appLocalizations.routeTraceModeGlobal
              : appLocalizations.routeTraceModeDirect,
        ),
      _TimelineEntry(
        icon: ReIcons.hierarchy,
        title: appLocalizations.routeTraceChain,
        detail: result.chains
            .map((chain) => '${chain.name}  (${chain.type})')
            .join('\n↓\n'),
      ),
    ];
    return ToolSurface(
      child: Column(
        children: [
          for (final (index, entry) in entries.indexed)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 30,
                    child: Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (entry.color ?? colorScheme.primary)
                                .withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            entry.icon,
                            size: 15,
                            color: entry.color ?? colorScheme.primary,
                          ),
                        ),
                        if (index < entries.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 4,
                        bottom: index < entries.length - 1 ? 16 : 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.title,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          EmojiText(
                            entry.detail,
                            style: context.textTheme.bodySmall?.copyWith(
                              color:
                                  entry.color ?? colorScheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                          ?entry.extra,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RulesList extends StatelessWidget {
  final RouteTraceResult result;

  const _RulesList({required this.result});

  String? _skipText(String value) => switch (value) {
    'pass' => appLocalizations.routeTraceSkipPass,
    'udp' => appLocalizations.routeTraceSkipUdp,
    'missing' => appLocalizations.routeTraceSkipMissing,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final steps = result.steps;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: steps.length + (result.truncated ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= steps.length) {
          return ToolNote(
            icon: ReIcons.moreHCircle,
            text: appLocalizations.routeTraceTruncated,
          );
        }
        final step = steps[index];
        final skip = _skipText(step.skipped);
        final color = step.matched
            ? colorScheme.primary
            : skip != null
            ? colorScheme.tertiary
            : colorScheme.onSurfaceVariant;
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: step.matched
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.onSurface.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '#${step.index + 1}',
                  style: context.textTheme.labelSmall?.copyWith(color: color),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EmojiText(
                      _stepText(step),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: step.matched ? colorScheme.primary : null,
                        fontWeight: step.matched ? FontWeight.w600 : null,
                      ),
                    ),
                    if (step.resolve || skip != null)
                      Text(
                        [
                          if (step.resolve) appLocalizations.routeTraceTrigger,
                          ?skip,
                        ].join(' · '),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colorScheme.tertiary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: EmojiText(
                  step.adapter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

@visibleForTesting
Widget buildRouteTraceResultForTesting(RouteTraceResult result) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    _VerdictCard(result: result),
    const SizedBox(height: 12),
    _TimelineCard(result: result),
  ],
);
