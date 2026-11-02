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

import '../speed_test.dart';
import 'common.dart';

const natPresetServers = [
  'stun.voipgate.com:3478',
  'stun.miwifi.com:3478',
  'stun.cloudflare.com:3478',
  'stun.l.google.com:19302',
  'stun.nextcloud.com:443',
  'stun.sonetel.com:3478',
  'stun.12voip.com:3478',
  'stun.ringostat.com:3478',
];

final _hostPort = RegExp(r'^[A-Za-z0-9._-]+:\d{1,5}$');

bool isValidStunServer(String value) {
  if (!_hostPort.hasMatch(value)) return false;
  final port = int.tryParse(value.split(':').last) ?? 0;
  return port > 0 && port <= 65535;
}

String natTypeName(NatType type) => switch (type) {
  NatType.open => appLocalizations.natTypeOpen,
  NatType.fullCone => appLocalizations.natTypeFullCone,
  NatType.restricted => appLocalizations.natTypeRestricted,
  NatType.portRestricted => appLocalizations.natTypePortRestricted,
  NatType.symmetric => appLocalizations.natTypeSymmetric,
  NatType.cone => appLocalizations.natTypeCone,
  NatType.blocked => appLocalizations.natTypeBlocked,
  NatType.unknown => appLocalizations.natTypeUnknown,
};

String natTypeBadge(NatType type) => switch (type) {
  NatType.open => 'OPEN',
  NatType.fullCone => 'NAT1',
  NatType.restricted => 'NAT2',
  NatType.portRestricted => 'NAT3',
  NatType.symmetric => 'NAT4',
  NatType.cone => 'NAT1-3',
  NatType.blocked => 'UDP',
  NatType.unknown => '?',
};

String natTypeDescription(NatType type) => switch (type) {
  NatType.open => appLocalizations.natDescOpen,
  NatType.fullCone => appLocalizations.natDescFullCone,
  NatType.restricted => appLocalizations.natDescRestricted,
  NatType.portRestricted => appLocalizations.natDescPortRestricted,
  NatType.symmetric => appLocalizations.natDescSymmetric,
  NatType.cone => appLocalizations.natDescCone,
  NatType.blocked => appLocalizations.natDescBlocked,
  NatType.unknown => appLocalizations.natDescUnknown,
};

Color natTypeColor(BuildContext context, NatType type) {
  final colorScheme = context.colorScheme;
  return switch (type) {
    NatType.open || NatType.fullCone => const Color(0xFF22A06B),
    NatType.restricted => const Color(0xFF5BAA3C),
    NatType.portRestricted => const Color(0xFFE59A1A),
    NatType.symmetric => const Color(0xFFE5602B),
    NatType.blocked => colorScheme.error,
    NatType.cone => colorScheme.primary,
    NatType.unknown => colorScheme.outline,
  };
}

String natBehaviorName(String value) => switch (value) {
  'independent' => appLocalizations.natMappingIndependent,
  'address' => appLocalizations.natMappingAddress,
  'address-port' => appLocalizations.natMappingAddressPort,
  'dependent' => appLocalizations.natMappingDependent,
  _ => '—',
};

String natReport(StunTestState state) {
  final lines = <String>[
    '${appLocalizations.natType}: ${natTypeName(state.natType)} (${natTypeBadge(state.natType)})',
    '${appLocalizations.natServer}: ${state.server}',
    if (state.externalIp.isNotEmpty)
      '${appLocalizations.natExternalIp}: ${state.externalIp}',
    if (state.externalPort > 0)
      '${appLocalizations.natExternalPort}: ${state.externalPort}',
    if (state.localIp.isNotEmpty)
      '${appLocalizations.natLocalIp}: ${state.localIp}',
    '${appLocalizations.natMapping}: ${natBehaviorName(state.mapping)}',
    '${appLocalizations.natFiltering}: ${natBehaviorName(state.filtering)}',
    if (state.latency >= 0)
      '${appLocalizations.delay}: ${state.latency.round()} ms',
    if (state.packetLoss >= 0)
      '${appLocalizations.speedTestPacketLoss}: ${(state.packetLoss * 100).toStringAsFixed(0)}%',
  ];
  return lines.join('\n');
}

class NatTestPage extends ConsumerStatefulWidget {
  const NatTestPage({super.key});

  @override
  ConsumerState<NatTestPage> createState() => _NatTestPageState();
}

class _NatTestPageState extends ConsumerState<NatTestPage>
    with AppMessageListener {
  static String _lastServer = natPresetServers.first;

  String _server = _lastServer;
  String _proxy = '';
  StunTestState? _state;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    clashMessage.addListener(this);
  }

  @override
  void dispose() {
    clashMessage.removeListener(this);
    if (_testing) {
      clashCore.cancelStunTest();
    }
    super.dispose();
  }

  @override
  void onStunTest(StunTestState state) {
    if (!mounted || !_testing) return;
    setState(() => _state = state);
  }

  List<Group> _groups() => ref.read(currentGroupsStateProvider).value;

  String _effectiveProxy(List<Group> groups) =>
      toolEffectiveProxy(groups, _proxy);

  Future<void> _selectOutbound() async {
    if (_testing) return;
    final groups = _groups();
    final result = await showOutboundPicker(
      selected: _effectiveProxy(groups),
      groups: groups,
    );
    if (result == null || !mounted || result == _proxy) return;
    setState(() {
      _proxy = result;
      _state = null;
    });
  }

  Future<void> _selectServer() async {
    if (_testing) return;
    final result = await globalState.showAdaptiveSheet<String>(
      child: _ServerDialog(selected: _server),
    );
    if (result == null || !mounted || result == _server) return;
    setState(() {
      _server = result;
      _lastServer = result;
      _state = null;
    });
  }

  Future<void> _start() async {
    if (_testing) return;
    final isStart = ref.read(runTimeProvider) != null;
    final proxy = isStart ? _effectiveProxy(_groups()) : '';
    setState(() {
      _testing = true;
      _state = StunTestState(server: _server, direct: !isStart);
    });
    StunTestState? result;
    try {
      result = await clashCore.startStunTest(server: _server, proxy: proxy);
    } catch (_) {
      result = StunTestState(
        server: _server,
        error: 'unavailable',
        phase: StunTestPhase.done,
      );
    }
    if (!mounted) return;
    setState(() {
      _testing = false;
      _state = result?.error == 'cancelled' ? null : result;
    });
  }

  Future<void> _stop() async {
    await clashCore.cancelStunTest();
  }

  void _copy(StunTestState state) {
    Clipboard.setData(ClipboardData(text: natReport(state)));
    context.showNotifier(appLocalizations.copySuccess);
  }

  @override
  Widget build(BuildContext context) {
    final isStart = ref.watch(runTimeProvider.select((state) => state != null));
    final groups = ref.watch(
      currentGroupsStateProvider.select((state) => state.value),
    );
    final proxy = _effectiveProxy(groups);
    final state = _state;
    final result = state != null && state.hasResult ? state : null;
    return CommonScaffold(
      title: appLocalizations.natTest,
      actions: [
        if (result != null)
          IconButton(
            tooltip: appLocalizations.natCopyResult,
            onPressed: () => _copy(result),
            icon: const Icon(Icons.copy_rounded),
          ),
      ],
      body: ToolPageBody(
        bottom: SizedBox(
          height: 52,
          child: _testing
              ? FilledButton.tonal(
                  onPressed: _stop,
                  child: Text(appLocalizations.stop),
                )
              : FilledButton(
                  onPressed: _start,
                  child: Text(
                    (state?.isFinished ?? false)
                        ? appLocalizations.natRetest
                        : appLocalizations.natStart,
                  ),
                ),
        ),
        children: [
          ToolOutboundCard(
            enabled: isStart && !_testing,
            showChevron: isStart,
            onTap: _selectOutbound,
            rows: [
              ToolOutboundRow(
                icon: Icons.arrow_outward_rounded,
                label: appLocalizations.speedTestExitNode,
                value: toolOutboundNode(
                  isStart: isStart,
                  proxy: proxy,
                  outbound: state?.outbound,
                ),
                primary: true,
              ),
              ToolOutboundRow(
                icon: Icons.alt_route_rounded,
                label: appLocalizations.speedTestRoute,
                value: toolOutboundRoute(
                  isStart: isStart,
                  proxy: proxy,
                  outbound: state?.outbound,
                ),
                color: isStart ? null : context.colorScheme.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ServerCard(
            server: _server,
            enabled: !_testing,
            onTap: _selectServer,
          ),
          const SizedBox(height: 12),
          _ResultCard(state: state, testing: _testing),
          if (result != null) ...[
            const SizedBox(height: 12),
            _InfoGrid(state: result),
            const SizedBox(height: 12),
            _QualityCard(state: result),
          ],
        ],
      ),
    );
  }
}

class _ServerCard extends StatelessWidget {
  final String server;
  final bool enabled;
  final VoidCallback onTap;

  const _ServerCard({
    required this.server,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return ToolSurface(
      onTap: enabled ? onTap : null,
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
      child: Row(
        children: [
          Icon(
            Icons.dns_rounded,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            appLocalizations.natServer,
            style: context.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              server,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium,
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: enabled
                ? colorScheme.onSurfaceVariant
                : colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final StunTestState? state;
  final bool testing;

  const _ResultCard({required this.state, required this.testing});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final state = this.state;
    final hasError = state != null && state.error.isNotEmpty;
    final result = state != null && state.hasResult ? state : null;
    final color = result != null
        ? natTypeColor(context, result.natType)
        : hasError
        ? colorScheme.error
        : colorScheme.primary;
    final icon = result != null
        ? (result.natType == NatType.blocked ||
                  result.natType == NatType.unknown
              ? Icons.error_outline_rounded
              : Icons.check_rounded)
        : hasError
        ? Icons.error_outline_rounded
        : Icons.radar_rounded;

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
                child: testing
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: color,
                        ),
                      )
                    : Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  appLocalizations.natResult,
                  style: context.textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (testing)
            _PhaseSteps(state: state)
          else if (hasError)
            Text(
              state.error == 'unsupported'
                  ? appLocalizations.natErrorUnsupported
                  : appLocalizations.natErrorUnavailable,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
              ),
            )
          else if (result != null)
            _Verdict(state: result, color: color)
          else
            Text(
              appLocalizations.natReady,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _Verdict extends StatelessWidget {
  final StunTestState state;
  final Color color;

  const _Verdict({required this.state, required this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.72)],
            ),
          ),
          child: Text(
            natTypeBadge(state.natType),
            style: textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          natTypeName(state.natType),
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          natTypeDescription(state.natType),
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (!state.direct) ...[
          const SizedBox(height: 10),
          ToolNote(
            icon: Icons.alt_route_rounded,
            text: appLocalizations.natProxyTip,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );
  }
}

class _PhaseSteps extends StatelessWidget {
  final StunTestState? state;

  const _PhaseSteps({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final phase = state?.phase ?? StunTestPhase.connecting;
    final steps = [
      (StunTestPhase.binding, appLocalizations.natPhaseBinding),
      (StunTestPhase.filtering, appLocalizations.natPhaseFiltering),
      (StunTestPhase.mapping, appLocalizations.natPhaseMapping),
    ];
    final current = steps.indexWhere((step) => step.$1 == phase);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final (index, step) in steps.indexed)
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      index < current
                          ? Icons.check_circle_rounded
                          : index == current
                          ? Icons.radio_button_checked_rounded
                          : Icons.circle_outlined,
                      size: 16,
                      color: index <= current
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      step.$2,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: index <= current
                            ? colorScheme.onSurface
                            : colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            minHeight: 4,
            value: switch (state?.progress) {
              final progress? when progress > 0 => progress,
              _ => null,
            },
          ),
        ),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final StunTestState state;

  const _InfoGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final tiles = <ToolInfoTile>[
      if (state.externalIp.isNotEmpty)
        ToolInfoTile(
          icon: Icons.public_rounded,
          label: appLocalizations.natExternalIp,
          value: state.externalIp,
          onTap: () => showIpDetailDialog(context, state.externalIp),
        ),
      if (state.externalPort > 0)
        ToolInfoTile(
          icon: Icons.router_rounded,
          label: appLocalizations.natExternalPort,
          value: '${state.externalPort}',
        ),
      if (state.localIp.isNotEmpty)
        ToolInfoTile(
          icon: Icons.wifi_rounded,
          label: appLocalizations.natLocalIp,
          value: state.localIp,
        ),
      ToolInfoTile(
        icon: Icons.swap_horiz_rounded,
        label: appLocalizations.natMapping,
        value: natBehaviorName(state.mapping),
      ),
      ToolInfoTile(
        icon: Icons.filter_alt_rounded,
        label: appLocalizations.natFiltering,
        value: natBehaviorName(state.filtering),
      ),
      if (state.portPreserved >= 0)
        ToolInfoTile(
          icon: Icons.pin_outlined,
          label: appLocalizations.natPortPreserve,
          value: state.portPreserved == 1
              ? appLocalizations.natPreserved
              : appLocalizations.natRandomized,
        ),
    ];
    return ToolInfoGrid(children: tiles);
  }
}

class _QualityCard extends StatelessWidget {
  final StunTestState state;

  const _QualityCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final hasLatency = state.latency >= 0;
    final hasLoss = state.packetLoss >= 0;
    return ToolRingCard(
      rings: [
        ToolRing(
          label: appLocalizations.delay,
          value: hasLatency ? '${state.latency.round()}' : '—',
          unit: hasLatency ? 'ms' : '',
          ratio: hasLatency ? 1 - state.latency / 500 : 0,
          color: hasLatency ? toolGrade(state.latency, 100, 250) : null,
        ),
        ToolRing(
          label: appLocalizations.speedTestJitter,
          value: hasLatency ? state.jitter.toStringAsFixed(1) : '—',
          unit: hasLatency ? 'ms' : '',
          ratio: hasLatency ? 1 - state.jitter / 100 : 0,
          color: hasLatency ? toolGrade(state.jitter, 20, 50) : null,
        ),
        ToolRing(
          label: appLocalizations.speedTestPacketLoss,
          value: hasLoss ? (state.packetLoss * 100).toStringAsFixed(0) : '—',
          unit: hasLoss ? '%' : '',
          ratio: hasLoss ? 1 - state.packetLoss : 0,
          color: hasLoss ? toolGrade(state.packetLoss, 0.02, 0.1) : null,
        ),
      ],
    );
  }
}

class _ServerDialog extends StatefulWidget {
  final String selected;

  const _ServerDialog({required this.selected});

  @override
  State<_ServerDialog> createState() => _ServerDialogState();
}

class _ServerDialogState extends State<_ServerDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: natPresetServers.contains(widget.selected) ? '' : widget.selected,
  );
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitCustom() {
    final value = _controller.text.trim();
    if (!isValidStunServer(value)) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.natServer,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
      overrideScroll: true,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          for (final server in natPresetServers)
            OptionItem(
              text: server,
              selected: server == widget.selected,
              onTap: () => Navigator.of(context).pop(server),
            ),
          const SizedBox(height: 8),
          ToolTvField(
            controller: _controller,
            child: TextField(
              controller: _controller,
              autocorrect: false,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (_invalid) setState(() => _invalid = false);
              },
              onSubmitted: (_) => _submitCustom(),
              decoration: InputDecoration(
                labelText: appLocalizations.natServerCustom,
                hintText: appLocalizations.natServerHint,
                errorText: _invalid ? appLocalizations.natServerInvalid : null,
                suffixIcon: IconButton(
                  onPressed: _submitCustom,
                  icon: const Icon(Icons.check_rounded),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@visibleForTesting
Widget buildNatResultForTesting(StunTestState state, {bool testing = false}) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResultCard(state: state, testing: testing),
        if (state.hasResult) ...[
          const SizedBox(height: 12),
          _InfoGrid(state: state),
          const SizedBox(height: 12),
          _QualityCard(state: state),
        ],
      ],
    );
