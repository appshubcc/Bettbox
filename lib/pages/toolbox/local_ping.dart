import 'dart:math' as math;

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'common.dart';

const localPingMaxCount = 9999;
const localPingMinInterval = 100;
const localPingMaxInterval = 10000;
const localPingMaxSize = 65000;
const _visibleReplies = 50;

String formatPingMillis(double value) => value.toStringAsFixed(
  value < 1
      ? 2
      : value < 100
      ? 1
      : 0,
);

String _intervalLabel(int value) =>
    value % 1000 == 0 ? '${value ~/ 1000}s' : '${value}ms';

String localPingErrorText(String error) => switch (error) {
  'invalid' => appLocalizations.ipLookupInvalid,
  'resolve' => appLocalizations.localPingErrorResolve,
  'denied' => appLocalizations.localPingErrorDenied,
  _ => appLocalizations.localPingErrorNetwork,
};

String _protocolText(LocalPingProtocol protocol, int port) =>
    protocol == LocalPingProtocol.icmp
    ? 'ICMP'
    : '${protocol.name.toUpperCase()} :$port';

String localPingReplyText(LocalPingReply reply, [String address = '']) =>
    switch (reply.status) {
      LocalPingStatus.ok => [
        if (address.isNotEmpty) appLocalizations.localPingFrom(address),
        '${formatPingMillis(reply.rtt)} ms',
        if (reply.ttl > 0) 'TTL ${reply.ttl}',
        if (reply.bytes > 0) appLocalizations.localPingBytes(reply.bytes),
      ].join(' · '),
      LocalPingStatus.closed => [
        if (address.isNotEmpty) appLocalizations.localPingFrom(address),
        appLocalizations.localPingClosed,
        '${formatPingMillis(reply.rtt)} ms',
      ].join(' · '),
      LocalPingStatus.timeout => appLocalizations.localPingTimeout,
      LocalPingStatus.unreachable => appLocalizations.localPingUnreachable,
      LocalPingStatus.error => appLocalizations.localPingFailed,
    };

String _subtitle(LocalPingState state) => [
  state.address.isEmpty || state.address == state.target
      ? state.target
      : '${state.target} (${state.address})',
  _protocolText(state.protocol, state.port),
  if (state.size > 0 && state.protocol != LocalPingProtocol.tcp)
    appLocalizations.localPingBytes(state.size),
].join(' · ');

String localPingReport(LocalPingState state, List<LocalPingReply> replies) {
  final stats = LocalPingStats.of(state.sent, replies);
  final address = state.address.isEmpty ? state.target : state.address;
  final lines = <String>[
    'Ping ${_subtitle(state)}',
    for (final reply in replies)
      '#${reply.seq} ${localPingReplyText(reply, address)}',
    '',
    appLocalizations.localPingStats(state.target),
    appLocalizations.localPingSummary(
      stats.completed,
      stats.received,
      stats.lost,
      (stats.loss * 100).toStringAsFixed(stats.loss == 0 ? 0 : 1),
    ),
  ];
  if (stats.avg case final avg?) {
    lines.add(
      appLocalizations.localPingRttSummary(
        formatPingMillis(stats.min ?? avg),
        formatPingMillis(avg),
        formatPingMillis(stats.max ?? avg),
        formatPingMillis(stats.jitter ?? 0),
      ),
    );
  }
  return lines.join('\n');
}

class LocalPingPage extends ConsumerStatefulWidget {
  const LocalPingPage({super.key});

  @override
  ConsumerState<LocalPingPage> createState() => _LocalPingPageState();
}

class _LocalPingPageState extends ConsumerState<LocalPingPage>
    with AppMessageListener, ToolHistoryMixin<LocalPingPage> {
  @override
  String get historyKey => 'localPing';

  final _target = TextEditingController();
  LocalPingState? _state;
  final _replies = <LocalPingReply>[];
  int _sent = 0;
  int _session = 0;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    clashMessage.addListener(this);
    loadHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalState.appController.updateLocalNetwork(silent: true);
    });
  }

  @override
  void dispose() {
    clashMessage.removeListener(this);
    _target.dispose();
    if (_running) {
      clashCore.cancelLocalPing();
      globalState.appController.holdWakelock(false);
    }
    super.dispose();
  }

  void _insert(LocalPingReply reply) {
    var index = _replies.length;
    while (index > 0 && _replies[index - 1].seq > reply.seq) {
      index--;
    }
    if (index > 0 && _replies[index - 1].seq == reply.seq) {
      _replies[index - 1] = reply;
    } else {
      _replies.insert(index, reply);
    }
  }

  @override
  void onLocalPing(LocalPingState state) {
    if (!mounted || !_running) return;
    if (_session == 0) _session = state.session;
    if (state.session != _session) return;
    setState(() {
      _state = state.copyWith(reply: null, replies: const []);
      _sent = math.max(_sent, state.sent);
      if (state.reply case final reply?) _insert(reply);
    });
  }

  void _updateOptions(
    LocalPingOptions Function(LocalPingOptions options) builder,
  ) {
    ref
        .read(appSettingProvider.notifier)
        .updateState(
          (state) =>
              state.copyWith(localPingOptions: builder(state.localPingOptions)),
        );
  }

  void _pick(String address, {required bool dns}) {
    if (_running) return;
    _target.text = address;
    _updateOptions(
      (options) => switch (options.protocol) {
        LocalPingProtocol.icmp => options,
        LocalPingProtocol.tcp => options.copyWith(tcpPort: dns ? 53 : 80),
        LocalPingProtocol.udp => options.copyWith(udpPort: 53),
      },
    );
  }

  Future<void> _editPort(LocalPingOptions options) async {
    final value = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.port,
        value: '${options.port}',
        keyboardType: TextInputType.number,
        validator: (value) {
          final port = int.tryParse(value?.trim() ?? '');
          return port == null || port < 1 || port > 65535
              ? appLocalizations.iperfPortInvalid
              : null;
        },
      ),
    );
    final port = int.tryParse(value?.trim() ?? '');
    if (port == null || !mounted) return;
    _updateOptions(
      (options) => options.protocol == LocalPingProtocol.tcp
          ? options.copyWith(tcpPort: port)
          : options.copyWith(udpPort: port),
    );
  }

  Future<void> _start() async {
    if (_running) return;
    final target = _target.text.trim();
    if (target.isEmpty || target.contains(' ')) {
      context.showNotifier(appLocalizations.ipLookupInvalid);
      return;
    }
    FocusScope.of(context).unfocus();
    final options = ref.read(
      appSettingProvider.select((state) => state.localPingOptions),
    );
    setState(() {
      _running = true;
      _session = 0;
      _sent = 0;
      _replies.clear();
      _state = LocalPingState(
        target: target,
        protocol: options.protocol,
        port: options.port,
        size: options.usesSize ? options.size : 0,
        count: options.count,
        interval: options.interval,
      );
    });
    globalState.appController.holdWakelock(true);
    LocalPingState? result;
    try {
      result = await clashCore.startLocalPing(target: target, options: options);
    } catch (_) {
      result = null;
    }
    globalState.appController.holdWakelock(false);
    if (!mounted) return;
    final finished =
        result ??
        _state?.copyWith(phase: LocalPingPhase.done, error: 'network');
    if (result != null &&
        result.error != 'invalid' &&
        result.error != 'resolve') {
      addHistory(target);
    }
    setState(() {
      _running = false;
      if (result != null && result.error.isEmpty) {
        _replies
          ..clear()
          ..addAll(result.replies);
        _sent = result.sent;
      }
      _state = finished?.copyWith(reply: null, replies: const []);
    });
  }

  Future<void> _stop() async {
    await clashCore.cancelLocalPing();
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    context.showNotifier(appLocalizations.copySuccess);
  }

  @override
  Widget build(BuildContext context) {
    final options = ref.watch(
      appSettingProvider.select((state) => state.localPingOptions),
    );
    final network = ref.watch(localNetworkProvider);
    final state = _state;
    final stats = LocalPingStats.of(_sent, _replies);
    return CommonScaffold(
      title: appLocalizations.localPing,
      actions: [
        if (state != null && !_running && _replies.isNotEmpty)
          IconButton(
            tooltip: appLocalizations.natCopyResult,
            onPressed: () => _copy(localPingReport(state, _replies)),
            icon: const Icon(ReIcons.copy),
          ),
      ],
      body: ToolPageBody(
        bottom: SizedBox(
          height: 52,
          child: _running
              ? FilledButton.tonal(
                  onPressed: _stop,
                  child: Text(appLocalizations.stop),
                )
              : FilledButton(
                  onPressed: _start,
                  child: Text(
                    state?.isDone ?? false
                        ? appLocalizations.iperfRetest
                        : appLocalizations.localPingStart,
                  ),
                ),
        ),
        children: [
          ToolSegmented<LocalPingProtocol>(
            values: LocalPingProtocol.values,
            value: options.protocol,
            enabled: !_running,
            labelOf: (value) => value.name.toUpperCase(),
            onChanged: (value) =>
                _updateOptions((options) => options.copyWith(protocol: value)),
          ),
          const SizedBox(height: 12),
          _TargetField(
            controller: _target,
            enabled: !_running,
            port: options.protocol == LocalPingProtocol.icmp
                ? null
                : options.port,
            onEditPort: () => _editPort(options),
            onSubmitted: _start,
          ),
          _QuickTargets(
            network: network,
            onSelected: (address, dns) => _pick(address, dns: dns),
          ),
          ToolHistoryBar(
            items: history,
            onSelected: (value) {
              if (_running) return;
              _target.text = value;
            },
            onClear: clearHistory,
          ),
          const SizedBox(height: 12),
          _OptionsCard(
            options: options,
            enabled: !_running,
            onChanged: _updateOptions,
          ),
          const SizedBox(height: 12),
          _LiveCard(state: state, sent: _sent, replies: _replies),
          if (_replies.isNotEmpty && state != null) ...[
            const SizedBox(height: 12),
            _ResultRings(stats: stats),
            const SizedBox(height: 12),
            _StatsGrid(state: state, stats: stats),
            const SizedBox(height: 12),
            _ReplyList(replies: _replies),
          ],
          if (options.protocol != LocalPingProtocol.icmp) ...[
            const SizedBox(height: 12),
            ToolNote(
              icon: ReIcons.infoCircle,
              text: options.protocol == LocalPingProtocol.tcp
                  ? appLocalizations.localPingTcpTip
                  : appLocalizations.localPingUdpTip,
            ),
          ],
        ],
      ),
    );
  }
}

class _TargetField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final int? port;
  final VoidCallback onEditPort;
  final VoidCallback onSubmitted;

  const _TargetField({
    required this.controller,
    required this.enabled,
    required this.port,
    required this.onEditPort,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final port = this.port;
    return ToolSurface(
      padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
      child: Row(
        children: [
          Icon(ReIcons.gps, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: ToolTvField(
              controller: controller,
              child: TextField(
                controller: controller,
                enabled: enabled,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => onSubmitted(),
                decoration: InputDecoration(
                  hintText: appLocalizations.localPingTargetHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                ),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, value, _) => value.text.isEmpty || !enabled
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: controller.clear,
                    icon: const Icon(ReIcons.x, size: 18),
                  ),
          ),
          if (port != null)
            TextButton(
              onPressed: enabled ? onEditPort : null,
              child: Text(
                ':$port',
                style: const TextStyle(
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickTargets extends StatelessWidget {
  final NetworkInfo? network;
  final void Function(String address, bool dns) onSelected;

  const _QuickTargets({required this.network, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final network = this.network;
    final items = <(IconData, String, String, bool)>[];
    if (network != null) {
      if (network.gateway.isNotEmpty) {
        items.add((
          ReIcons.router,
          appLocalizations.localPingGateway,
          network.gateway,
          false,
        ));
      }
      final dns = [
        ...network.dns.where((item) => !item.contains(':')),
        ...network.dns.where((item) => item.contains(':')),
      ];
      for (final server in dns.toSet().take(3)) {
        items.add((ReIcons.globalSearch, 'DNS', server, true));
      }
    }
    final colorScheme = context.colorScheme;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: items.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 34,
                child: ShaderMask(
                  shaderCallback: (rect) => LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white,
                      Colors.white.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.92, 1],
                  ).createShader(rect),
                  blendMode: BlendMode.dstIn,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsetsDirectional.only(end: 16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final (icon, label, address, dns) = items[index];
                      return ActionChip(
                        visualDensity: VisualDensity.compact,
                        side: toolChipSide(context),
                        avatar: Icon(
                          icon,
                          size: 15,
                          color: colorScheme.primary,
                        ),
                        label: Text(
                          '$label $address',
                          style: context.textTheme.labelMedium,
                        ),
                        onPressed: () => onSelected(address, dns),
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}

class _OptionsCard extends StatelessWidget {
  final LocalPingOptions options;
  final bool enabled;
  final void Function(LocalPingOptions Function(LocalPingOptions options))
  onChanged;

  const _OptionsCard({
    required this.options,
    required this.enabled,
    required this.onChanged,
  });

  TableRow _row(
    BuildContext context,
    String label,
    Widget child, {
    bool last = false,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(end: 14, bottom: last ? 0 : 10),
          child: Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: last ? 0 : 10),
          child: child,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = options.usesSize;
    return ToolSurface(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Table(
          columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            _row(
              context,
              appLocalizations.localPingCount,
              ToolNumberSegmented(
                presets: const [5, 10, 50],
                value: options.count,
                enabled: enabled,
                title: appLocalizations.localPingCount,
                min: 1,
                max: localPingMaxCount,
                labelOf: (value) => '$value',
                onChanged: (value) =>
                    onChanged((options) => options.copyWith(count: value)),
              ),
            ),
            _row(
              context,
              appLocalizations.interval,
              ToolNumberSegmented(
                presets: const [200, 500, 1000],
                value: options.interval,
                enabled: enabled,
                title: appLocalizations.interval,
                min: localPingMinInterval,
                max: localPingMaxInterval,
                unit: 'ms',
                labelOf: _intervalLabel,
                onChanged: (value) =>
                    onChanged((options) => options.copyWith(interval: value)),
              ),
              last: !size,
            ),
            if (size)
              _row(
                context,
                appLocalizations.localPingSize,
                ToolNumberSegmented(
                  presets: const [32, 56, 1472],
                  value: options.size,
                  enabled: enabled,
                  title: appLocalizations.localPingSize,
                  min: 0,
                  max: localPingMaxSize,
                  unit: appLocalizations.localPingBytes('').trim(),
                  labelOf: (value) => '$value',
                  onChanged: (value) =>
                      onChanged((options) => options.copyWith(size: value)),
                ),
                last: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _LiveCard extends StatelessWidget {
  final LocalPingState? state;
  final int sent;
  final List<LocalPingReply> replies;

  const _LiveCard({
    required this.state,
    required this.sent,
    required this.replies,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final state = this.state;
    final hasError = state != null && state.hasError;
    final active = state != null && !state.isDone;
    final color = hasError ? colorScheme.error : colorScheme.primary;
    final title = state == null || hasError
        ? appLocalizations.localPingResult
        : switch (state.phase) {
            LocalPingPhase.resolving => appLocalizations.localPingResolving,
            LocalPingPhase.running => appLocalizations.localPingRunning,
            LocalPingPhase.done => appLocalizations.localPingDone,
          };
    final total = state == null
        ? 0
        : active
        ? state.count
        : sent;
    return ToolSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                child: active
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: color,
                        ),
                      )
                    : Icon(
                        hasError
                            ? ReIcons.alertCircle
                            : state == null
                            ? ReIcons.pulse
                            : ReIcons.check,
                        color: color,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      state == null
                          ? appLocalizations.localPingReady
                          : _subtitle(state),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (state != null && total > 0 && !hasError)
                Text(
                  '${replies.length} / $total',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
          if (hasError) ...[
            const SizedBox(height: 14),
            ToolNote(
              icon: ReIcons.alertCircle,
              text: localPingErrorText(state.error),
              color: colorScheme.error,
            ),
          ],
          if (active && state.phase == LocalPingPhase.running) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: state.count > 0
                    ? (replies.length / state.count).clamp(0.0, 1.0)
                    : null,
              ),
            ),
          ],
          if (replies.isNotEmpty) ...[
            const SizedBox(height: 14),
            LocalPingChart(replies: replies),
          ],
        ],
      ),
    );
  }
}

class LocalPingChart extends StatelessWidget {
  final List<LocalPingReply> replies;
  final double height;

  const LocalPingChart({super.key, required this.replies, this.height = 88});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _ChartPainter(
          replies: replies.length > 60
              ? replies.sublist(replies.length - 60)
              : replies,
          okColor: colorScheme.primary,
          closedColor: toolFairColor,
          lostColor: colorScheme.error,
          gridColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<LocalPingReply> replies;
  final Color okColor;
  final Color closedColor;
  final Color lostColor;
  final Color gridColor;

  _ChartPainter({
    required this.replies,
    required this.okColor,
    required this.closedColor,
    required this.lostColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (replies.isEmpty) return;
    final peak = replies
        .where((reply) => reply.reachable)
        .fold<double>(0, (value, reply) => math.max(value, reply.rtt));
    final slots = math.max(replies.length, 20);
    final slot = size.width / slots;
    final barWidth = math.max(2.0, slot * 0.62);
    final radius = Radius.circular(math.min(3, barWidth / 2));
    for (var i = 0; i < replies.length; i++) {
      final reply = replies[i];
      final left = i * slot + (slot - barWidth) / 2;
      if (!reply.reachable) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(left, 0, barWidth, size.height),
            radius,
          ),
          Paint()..color = lostColor.withValues(alpha: 0.18),
        );
        continue;
      }
      final ratio = peak <= 0 ? 0.0 : reply.rtt / peak;
      final height = math.max(3.0, size.height * ratio);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, size.height - height, barWidth, height),
          radius,
        ),
        Paint()
          ..color = reply.status == LocalPingStatus.ok ? okColor : closedColor,
      );
    }
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) =>
      oldDelegate.replies.length != replies.length ||
      !identical(oldDelegate.replies.lastOrNull, replies.lastOrNull) ||
      oldDelegate.okColor != okColor;
}

class _ResultRings extends StatelessWidget {
  final LocalPingStats stats;

  const _ResultRings({required this.stats});

  @override
  Widget build(BuildContext context) {
    final avg = stats.avg;
    final jitter = stats.jitter;
    final loss = stats.loss;
    return ToolRingCard(
      rings: [
        ToolRing(
          label: appLocalizations.localPingAverage,
          value: avg == null ? '—' : formatPingMillis(avg),
          unit: avg == null ? '' : 'ms',
          ratio: avg == null ? 0 : 1 - avg / 300,
          color: avg == null ? null : toolGrade(avg, 50, 150),
        ),
        ToolRing(
          label: appLocalizations.speedTestPacketLoss,
          value: (loss * 100).toStringAsFixed(
            loss == 0
                ? 0
                : loss < 0.1
                ? 1
                : 0,
          ),
          unit: '%',
          ratio: 1 - loss,
          color: stats.completed == 0 ? null : toolGrade(loss, 0.01, 0.05),
        ),
        ToolRing(
          label: appLocalizations.speedTestJitter,
          value: jitter == null ? '—' : formatPingMillis(jitter),
          unit: jitter == null ? '' : 'ms',
          ratio: jitter == null ? 0 : 1 - jitter / 50,
          color: jitter == null ? null : toolGrade(jitter, 10, 30),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final LocalPingState state;
  final LocalPingStats stats;

  const _StatsGrid({required this.state, required this.stats});

  String _ms(double? value) =>
      value == null ? '—' : '${formatPingMillis(value)} ms';

  @override
  Widget build(BuildContext context) {
    return ToolInfoGrid(
      children: [
        ToolInfoTile(
          icon: ReIcons.transferV,
          label:
              '${appLocalizations.localPingSent} / ${appLocalizations.localPingReceived}',
          value: '${stats.sent} / ${stats.received}',
        ),
        state.protocol == LocalPingProtocol.icmp
            ? ToolInfoTile(
                icon: ReIcons.route,
                label: 'TTL',
                value: stats.ttl > 0 ? '${stats.ttl}' : '—',
              )
            : ToolInfoTile(
                icon: ReIcons.plug,
                label: appLocalizations.port,
                value: '${state.port}',
              ),
        ToolInfoTile(
          icon: ReIcons.arrowDown,
          label: appLocalizations.localPingMin,
          value: _ms(stats.min),
        ),
        ToolInfoTile(
          icon: ReIcons.arrowUp,
          label: appLocalizations.localPingMax,
          value: _ms(stats.max),
        ),
      ],
    );
  }
}

class _ReplyList extends StatelessWidget {
  final List<LocalPingReply> replies;

  const _ReplyList({required this.replies});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final visible = replies.reversed.take(_visibleReplies).toList();
    return ToolSurface(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final reply in visible)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      '#${reply.seq}',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, right: 8),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: switch (reply.status) {
                          LocalPingStatus.ok => toolGrade(reply.rtt, 50, 150),
                          LocalPingStatus.closed => toolFairColor,
                          _ => colorScheme.error,
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      localPingReplyText(reply),
                      style: textTheme.bodySmall?.copyWith(
                        color: reply.reachable ? null : colorScheme.error,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (replies.length > _visibleReplies) ...[
            const SizedBox(height: 6),
            Text(
              appLocalizations.localPingListLimit(_visibleReplies),
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

@visibleForTesting
Widget buildLocalPingPreviewForTesting({
  required LocalPingState state,
  required List<LocalPingReply> replies,
  LocalPingOptions options = const LocalPingOptions(),
  NetworkInfo? network,
}) {
  final stats = LocalPingStats.of(state.sent, replies);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ToolSegmented<LocalPingProtocol>(
        values: LocalPingProtocol.values,
        value: options.protocol,
        labelOf: (value) => value.name.toUpperCase(),
        onChanged: (_) {},
      ),
      const SizedBox(height: 12),
      _TargetField(
        controller: TextEditingController(text: state.target),
        enabled: true,
        port: options.protocol == LocalPingProtocol.icmp ? null : options.port,
        onEditPort: () {},
        onSubmitted: () {},
      ),
      _QuickTargets(network: network, onSelected: (_, _) {}),
      const SizedBox(height: 12),
      _OptionsCard(options: options, enabled: true, onChanged: (_) {}),
      const SizedBox(height: 12),
      _LiveCard(state: state, sent: state.sent, replies: replies),
      if (replies.isNotEmpty) ...[
        const SizedBox(height: 12),
        _ResultRings(stats: stats),
        const SizedBox(height: 12),
        _StatsGrid(state: state, stats: stats),
        const SizedBox(height: 12),
        _ReplyList(replies: replies),
      ],
    ],
  );
}
