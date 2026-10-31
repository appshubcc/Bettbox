import 'dart:math' as math;

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/scan.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../speed_test.dart';
import 'common.dart';

const iperfDefaultPort = 5201;
const iperfMaxStreams = 128;
const iperfMaxDuration = 3600;
const iperfMaxBandwidth = 100000;

typedef IperfTarget = ({String name, List<String> hosts, int port});

String buildIperfLink({
  required List<String> hosts,
  required int port,
  required String name,
}) => Uri(
  scheme: 'bettbox',
  host: 'iperf',
  queryParameters: {
    'addr': hosts.join(','),
    'port': '$port',
    if (name.isNotEmpty) 'name': name,
  },
).toString();

IperfTarget? parseIperfLink(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null || uri.scheme != 'bettbox' || uri.host != 'iperf') {
    return null;
  }
  final hosts = (uri.queryParameters['addr'] ?? '')
      .split(',')
      .map((host) => host.trim())
      .where((host) => host.isNotEmpty)
      .toList();
  final port = int.tryParse(uri.queryParameters['port'] ?? '') ?? 0;
  if (hosts.isEmpty || port < 1 || port > 65535) return null;
  return (name: uri.queryParameters['name'] ?? '', hosts: hosts, port: port);
}

({String host, int port})? parseIperfAddress(String value) {
  final text = value.trim();
  if (text.isEmpty || text.contains(RegExp(r'[\s/]'))) return null;
  int? parsePort(String raw) {
    final port = int.tryParse(raw);
    return port != null && port > 0 && port <= 65535 ? port : null;
  }

  if (text.startsWith('[')) {
    final end = text.indexOf(']');
    if (end <= 1) return null;
    final host = text.substring(1, end);
    final rest = text.substring(end + 1);
    if (rest.isEmpty) return (host: host, port: iperfDefaultPort);
    if (!rest.startsWith(':')) return null;
    final port = parsePort(rest.substring(1));
    return port == null ? null : (host: host, port: port);
  }
  if (':'.allMatches(text).length == 1) {
    final index = text.indexOf(':');
    final port = parsePort(text.substring(index + 1));
    if (port == null || index == 0) return null;
    return (host: text.substring(0, index), port: port);
  }
  return (host: text, port: iperfDefaultPort);
}

String formatIperfAddress(String host, int port) {
  if (port == iperfDefaultPort) return host;
  return host.contains(':') ? '[$host]:$port' : '$host:$port';
}

String iperfErrorText(String error, {int port = iperfDefaultPort}) {
  if (error.startsWith('server:')) {
    return appLocalizations.iperfErrorServer(error.substring(7));
  }
  return switch (error) {
    'busy' => appLocalizations.iperfErrorBusy,
    'refused' => appLocalizations.iperfErrorRefused,
    'timeout' => appLocalizations.iperfErrorTimeout,
    'udp' => appLocalizations.iperfErrorUdp,
    'protocol' => appLocalizations.iperfErrorProtocol,
    'interrupted' || 'cancelled' => appLocalizations.iperfErrorInterrupted,
    'port-in-use' => appLocalizations.iperfErrorPortInUse(port),
    'listen' => appLocalizations.iperfErrorListen,
    _ => appLocalizations.iperfErrorUnreachable,
  };
}

String iperfDirectionLabel(IperfDirection direction) => switch (direction) {
  IperfDirection.upload => appLocalizations.upload,
  IperfDirection.download => appLocalizations.download,
  IperfDirection.bidir => appLocalizations.iperfBidir,
};

String iperfFlowLabel(IperfRole role, {required bool upload}) =>
    role == IperfRole.server
    ? (upload ? appLocalizations.iperfReceive : appLocalizations.iperfSend)
    : (upload ? appLocalizations.upload : appLocalizations.download);

String _speedText(double bps) =>
    '${formatSpeedValue(bps)} ${formatSpeedUnit(bps)}';

String _bytesText(double bytes) => TrafficValue(value: bytes.round()).show;

String _summaryText(IperfState state) => [
  state.protocol.name.toUpperCase(),
  iperfDirectionLabel(state.direction),
  appLocalizations.iperfStreams(state.parallel),
].join(' · ');

int? _totalRetransmits(IperfState state) {
  final values = [
    state.uploadResult?.retransmits,
    state.downloadResult?.retransmits,
  ].whereType<int>().where((value) => value >= 0);
  return values.isEmpty ? null : values.reduce((a, b) => a + b);
}

String _msText(double value) =>
    value.toStringAsFixed(value < 10 ? 2 : (value < 100 ? 1 : 0));

String _rttText(IperfFlow flow) =>
    '${_msText(flow.rttMean)} ms (${_msText(flow.rttMin)}–${_msText(flow.rttMax)})';

String iperfReport(IperfState state) {
  final lines = <String>[
    'iPerf3 · ${_summaryText(state)}',
    '${appLocalizations.iperfPeer}: ${state.peer}',
  ];
  for (final (upload, flow) in [
    (true, state.uploadResult),
    (false, state.downloadResult),
  ]) {
    if (flow == null) continue;
    lines.add(
      [
        '${iperfFlowLabel(state.role, upload: upload)}: ${_speedText(flow.bitrate)}',
        _bytesText(flow.bytes),
        if (state.protocol == IperfProtocol.tcp && flow.retransmits >= 0)
          '${appLocalizations.iperfRetransmits} ${flow.retransmits}',
        if (state.protocol == IperfProtocol.tcp && flow.hasRtt)
          '${appLocalizations.iperfRtt} ${_rttText(flow)}',
        if (state.protocol == IperfProtocol.udp) ...[
          '${appLocalizations.speedTestJitter} ${flow.jitter.toStringAsFixed(2)} ms',
          '${appLocalizations.speedTestPacketLoss} ${appLocalizations.iperfLostPackets(flow.lost, flow.packets)}',
        ],
      ].join(' · '),
    );
  }
  return lines.join('\n');
}

enum _IperfMode { server, client }

class IperfPage extends ConsumerStatefulWidget {
  const IperfPage({super.key});

  @override
  ConsumerState<IperfPage> createState() => _IperfPageState();
}

class _IperfPageState extends ConsumerState<IperfPage>
    with AppMessageListener, ToolHistoryMixin<IperfPage> {
  static _IperfMode? _lastMode;

  @override
  String get historyKey => 'iperf';

  late _IperfMode _mode =
      _lastMode ??
      (system.isAndroid && !globalState.isAndroidTV
          ? _IperfMode.client
          : _IperfMode.server);
  final _address = TextEditingController();

  IperfTarget? _scanned;
  String _scannedText = '';
  IperfState? _client;
  bool _testing = false;
  final _clientUpload = <(double, double)>[];
  final _clientDownload = <(double, double)>[];

  IperfServerInfo? _server;
  bool _serverBusy = false;
  String _serverError = '';
  List<String> _addresses = const [];
  String _deviceName = '';
  IperfState? _session;
  final _sessionUpload = <(double, double)>[];
  final _sessionDownload = <(double, double)>[];

  bool get _canScan => system.isAndroid && !globalState.isAndroidTV;

  @override
  void initState() {
    super.initState();
    clashMessage.addListener(this);
    loadHistory();
  }

  @override
  void dispose() {
    clashMessage.removeListener(this);
    _address.dispose();
    if (_testing) clashCore.cancelIperfClient();
    if (_server != null) {
      clashCore.stopIperfServer();
      globalState.appController.holdWakelock(false);
    }
    super.dispose();
  }

  void _append(
    IperfState state,
    List<(double, double)> upload,
    List<(double, double)> download,
  ) {
    if (state.phase != IperfPhase.running ||
        state.duration <= 0 ||
        state.elapsed <= 0) {
      return;
    }
    final x = (state.elapsed / state.duration).clamp(0.0, 1.0);
    if (state.hasUpload) upload.add((x, state.upload));
    if (state.hasDownload) download.add((x, state.download));
  }

  @override
  void onIperf(IperfState state) {
    if (!mounted) return;
    if (state.role == IperfRole.server) {
      final current = _session;
      if (_server == null ||
          (current != null && state.session < current.session)) {
        return;
      }
      setState(() {
        if (current == null || current.session != state.session) {
          _sessionUpload.clear();
          _sessionDownload.clear();
        }
        _session = state;
        _append(state, _sessionUpload, _sessionDownload);
      });
      return;
    }
    if (!_testing) return;
    setState(() {
      _client = state;
      _append(state, _clientUpload, _clientDownload);
    });
  }

  void _updateOptions(IperfOptions Function(IperfOptions options) builder) {
    ref
        .read(appSettingProvider.notifier)
        .updateState(
          (state) => state.copyWith(iperfOptions: builder(state.iperfOptions)),
        );
  }

  void _applyTarget(IperfTarget target) {
    _scanned = target;
    _scannedText = formatIperfAddress(target.hosts.first, target.port);
    _address.text = _scannedText;
  }

  Future<void> _scan() async {
    final value = await BaseNavigator.push<String>(
      context,
      ScanPage(accept: (_) => true),
    );
    if (!mounted || value == null) return;
    final target = parseIperfLink(value);
    if (target == null) {
      context.showNotifier(appLocalizations.iperfScanInvalid);
      return;
    }
    setState(() => _applyTarget(target));
    await _start();
  }

  Future<void> _start() async {
    if (_testing) return;
    final link = parseIperfLink(_address.text);
    if (link != null) setState(() => _applyTarget(link));
    final text = _address.text.trim();
    final scanned = _scanned;
    final List<String> hosts;
    final int port;
    if (scanned != null && text == _scannedText) {
      hosts = scanned.hosts;
      port = scanned.port;
    } else {
      final address = parseIperfAddress(text);
      if (address == null) {
        context.showNotifier(
          text.isEmpty
              ? appLocalizations.iperfAddressRequired
              : appLocalizations.ipLookupInvalid,
        );
        return;
      }
      hosts = [address.host];
      port = address.port;
    }
    FocusScope.of(context).unfocus();
    final options = ref.read(
      appSettingProvider.select((state) => state.iperfOptions),
    );
    setState(() {
      _testing = true;
      _clientUpload.clear();
      _clientDownload.clear();
      _client = IperfState(
        protocol: options.protocol,
        direction: options.direction,
        parallel: options.parallel,
        duration: options.duration.toDouble(),
      );
    });
    IperfState? result;
    try {
      result = await clashCore.startIperfClient(
        hosts: hosts,
        port: port,
        options: options,
      );
    } catch (_) {
      result = const IperfState(phase: IperfPhase.done, error: 'unreachable');
    }
    if (!mounted) return;
    if (result != null && result.error.isEmpty && result.peer.isNotEmpty) {
      addHistory(
        scanned != null && text == _scannedText
            ? _scannedText
            : formatIperfAddress(result.peer, port),
      );
    }
    setState(() {
      _testing = false;
      _client = result?.error == 'cancelled' ? null : result;
    });
  }

  Future<void> _stop() async {
    await clashCore.cancelIperfClient();
  }

  Future<void> _editPort(int port) async {
    final value = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.iperfPort,
        value: '$port',
        resetValue: '$iperfDefaultPort',
        keyboardType: TextInputType.number,
        validator: (value) {
          final port = int.tryParse(value?.trim() ?? '');
          return port == null || port < 1 || port > 65535
              ? appLocalizations.iperfPortInvalid
              : null;
        },
      ),
    );
    final next = int.tryParse(value?.trim() ?? '');
    if (next == null || !mounted) return;
    _updateOptions((options) => options.copyWith(serverPort: next));
  }

  Future<void> _startServer() async {
    if (_serverBusy) return;
    final port = ref.read(
      appSettingProvider.select((state) => state.iperfOptions.serverPort),
    );
    setState(() {
      _serverBusy = true;
      _serverError = '';
    });
    IperfServerInfo info;
    try {
      info = await clashCore.startIperfServer(port);
    } catch (_) {
      info = const IperfServerInfo(error: 'listen');
    }
    final addresses = await utils.getLanAddresses();
    final name = await system.deviceName;
    if (!mounted) {
      if (info.error.isEmpty) clashCore.stopIperfServer();
      return;
    }
    if (info.error.isNotEmpty) {
      setState(() {
        _serverBusy = false;
        _serverError = iperfErrorText(info.error, port: port);
      });
      return;
    }
    globalState.appController.holdWakelock(true);
    setState(() {
      _serverBusy = false;
      _server = info;
      _addresses = addresses;
      _deviceName = name;
      _session = null;
      _sessionUpload.clear();
      _sessionDownload.clear();
    });
  }

  Future<void> _stopServer() async {
    if (_serverBusy) return;
    setState(() => _serverBusy = true);
    try {
      await clashCore.stopIperfServer();
    } catch (_) {}
    globalState.appController.holdWakelock(false);
    if (!mounted) return;
    setState(() {
      _serverBusy = false;
      _server = null;
    });
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    context.showNotifier(appLocalizations.copySuccess);
  }

  @override
  Widget build(BuildContext context) {
    final options = ref.watch(
      appSettingProvider.select((state) => state.iperfOptions),
    );
    final isServer = _mode == _IperfMode.server;
    final report = isServer ? _session : _client;
    return CommonScaffold(
      title: appLocalizations.iperfTest,
      actions: [
        if (report != null && report.hasResult)
          IconButton(
            tooltip: appLocalizations.natCopyResult,
            onPressed: () => _copy(iperfReport(report)),
            icon: const Icon(ReIcons.copy),
          ),
      ],
      body: ToolPageBody(
        bottom: SizedBox(
          height: 52,
          child: isServer ? _buildServerButton() : _buildClientButton(),
        ),
        children: [
          ToolSegmented<_IperfMode>(
            values: _IperfMode.values,
            value: _mode,
            enabled: !_testing,
            labelOf: (mode) => switch (mode) {
              _IperfMode.server => appLocalizations.iperfServer,
              _IperfMode.client => appLocalizations.iperfClient,
            },
            onChanged: (mode) => setState(() {
              _mode = mode;
              _lastMode = mode;
            }),
          ),
          const SizedBox(height: 12),
          ...isServer ? _buildServer(options) : _buildClient(options),
        ],
      ),
    );
  }

  Widget _buildClientButton() {
    if (_testing) {
      return FilledButton.tonal(
        onPressed: _stop,
        child: Text(appLocalizations.stop),
      );
    }
    return FilledButton(
      onPressed: _start,
      child: Text(
        (_client?.isDone ?? false)
            ? appLocalizations.iperfRetest
            : appLocalizations.iperfStart,
      ),
    );
  }

  Widget _buildServerButton() {
    final running = _server != null;
    final onPressed = _serverBusy
        ? null
        : running
        ? _stopServer
        : _startServer;
    final label = Text(
      running
          ? appLocalizations.iperfServerStop
          : appLocalizations.iperfServerStart,
    );
    return running
        ? FilledButton.tonal(onPressed: onPressed, child: label)
        : FilledButton(onPressed: onPressed, child: label);
  }

  List<Widget> _buildClient(IperfOptions options) {
    final client = _client;
    final scanned = _scanned;
    return [
      _AddressField(
        controller: _address,
        enabled: !_testing,
        onSubmitted: _start,
        onScan: _canScan && !_testing ? _scan : null,
      ),
      ValueListenableBuilder(
        valueListenable: _address,
        builder: (context, value, _) {
          final show =
              scanned != null &&
              scanned.name.isNotEmpty &&
              value.text.trim() == _scannedText;
          return AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: show
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _ScannedChip(
                        label: appLocalizations.iperfScanned(scanned.name),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          );
        },
      ),
      ToolHistoryBar(
        items: history,
        onSelected: (value) {
          if (_testing) return;
          _address.text = value;
        },
        onClear: clearHistory,
      ),
      const SizedBox(height: 12),
      _OptionsCard(
        options: options,
        enabled: !_testing,
        onChanged: _updateOptions,
      ),
      const SizedBox(height: 12),
      _LiveCard(
        state: client,
        idleText: appLocalizations.iperfReady,
        upload: _clientUpload,
        download: _clientDownload,
      ),
      if (client != null && client.hasResult) ..._buildResult(client),
    ];
  }

  List<Widget> _buildServer(IperfOptions options) {
    final server = _server;
    final session = _session;
    final colorScheme = context.colorScheme;
    return [
      _ServerCard(
        running: server != null,
        busy: _serverBusy,
        port: server?.port ?? options.serverPort,
        session: session,
        error: _serverError,
        onEditPort: server == null && !_serverBusy
            ? () => _editPort(options.serverPort)
            : null,
      ),
      if (session != null) ...[
        const SizedBox(height: 12),
        _LiveCard(
          state: session,
          idleText: appLocalizations.iperfWaiting,
          upload: _sessionUpload,
          download: _sessionDownload,
        ),
        if (session.hasResult) ..._buildResult(session),
      ],
      if (server != null) ...[
        const SizedBox(height: 12),
        _ConnectCard(
          addresses: _addresses,
          port: server.port,
          name: _deviceName,
          onCopy: _copy,
        ),
      ],
      const SizedBox(height: 12),
      ToolNote(icon: ReIcons.infoCircle, text: appLocalizations.iperfServerTip),
      if (system.isDesktop) ...[
        const SizedBox(height: 8),
        ToolNote(icon: ReIcons.shield, text: appLocalizations.iperfFirewallTip),
      ],
      if (server != null && !server.udp) ...[
        const SizedBox(height: 8),
        ToolNote(
          icon: ReIcons.warning,
          text: appLocalizations.iperfUdpUnavailable,
          color: colorScheme.tertiary,
        ),
      ],
    ];
  }

  List<Widget> _buildResult(IperfState state) => [
    const SizedBox(height: 12),
    _ResultRings(state: state),
    const SizedBox(height: 12),
    _ResultGrid(state: state),
  ];
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSubmitted;
  final VoidCallback? onScan;

  const _AddressField({
    required this.controller,
    required this.enabled,
    required this.onSubmitted,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return ToolSurface(
      padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
      child: Row(
        children: [
          Icon(ReIcons.server, size: 20, color: colorScheme.onSurfaceVariant),
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
                  hintText: appLocalizations.iperfAddressHint,
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
          if (onScan case final onScan?)
            IconButton.filledTonal(
              tooltip: appLocalizations.iperfScan,
              onPressed: onScan,
              icon: const Icon(ReIcons.scan),
            ),
        ],
      ),
    );
  }
}

class _ScannedChip extends StatelessWidget {
  final String label;

  const _ScannedChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ReIcons.qr, size: 15, color: primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelMedium?.copyWith(color: primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionsCard extends StatelessWidget {
  final IperfOptions options;
  final bool enabled;
  final void Function(IperfOptions Function(IperfOptions options)) onChanged;

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
    final udp = options.protocol == IperfProtocol.udp;
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
              appLocalizations.iperfProtocol,
              ToolSegmented<IperfProtocol>(
                values: IperfProtocol.values,
                value: options.protocol,
                enabled: enabled,
                labelOf: (value) => value.name.toUpperCase(),
                onChanged: (value) =>
                    onChanged((options) => options.copyWith(protocol: value)),
              ),
            ),
            _row(
              context,
              appLocalizations.iperfDirection,
              ToolSegmented<IperfDirection>(
                values: IperfDirection.values,
                value: options.direction,
                enabled: enabled,
                labelOf: iperfDirectionLabel,
                onChanged: (value) =>
                    onChanged((options) => options.copyWith(direction: value)),
              ),
            ),
            _row(
              context,
              appLocalizations.iperfParallel,
              ToolNumberSegmented(
                presets: const [1, 4, 8],
                value: options.parallel,
                enabled: enabled,
                title: appLocalizations.iperfParallel,
                min: 1,
                max: iperfMaxStreams,
                labelOf: (value) => '$value',
                onChanged: (value) =>
                    onChanged((options) => options.copyWith(parallel: value)),
              ),
            ),
            _row(
              context,
              appLocalizations.iperfDuration,
              ToolNumberSegmented(
                presets: const [5, 10, 30],
                value: options.duration,
                enabled: enabled,
                title: appLocalizations.iperfDuration,
                min: 1,
                max: iperfMaxDuration,
                unit: appLocalizations.iperfSeconds('').trim(),
                labelOf: (value) => appLocalizations.iperfSeconds(value),
                onChanged: (value) =>
                    onChanged((options) => options.copyWith(duration: value)),
              ),
              last: !udp,
            ),
            if (udp)
              _row(
                context,
                appLocalizations.iperfBandwidth,
                ToolNumberSegmented(
                  presets: const [10, 100, 500, 1000],
                  value: options.bandwidth,
                  enabled: enabled,
                  title: appLocalizations.iperfBandwidth,
                  min: 1,
                  max: iperfMaxBandwidth,
                  unit: 'Mbps',
                  labelOf: (value) => value >= 1000 && value % 1000 == 0
                      ? '${value ~/ 1000}G'
                      : '${value}M',
                  onChanged: (value) => onChanged(
                    (options) => options.copyWith(bandwidth: value),
                  ),
                ),
                last: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _ServerCard extends StatelessWidget {
  final bool running;
  final bool busy;
  final int port;
  final IperfState? session;
  final String error;
  final VoidCallback? onEditPort;

  const _ServerCard({
    required this.running,
    required this.busy,
    required this.port,
    required this.session,
    required this.error,
    required this.onEditPort,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final session = this.session;
    final testing = session != null && !session.isDone;
    final color = running ? colorScheme.primary : colorScheme.outline;
    final subtitle = !running
        ? appLocalizations.iperfServerOffHint
        : testing
        ? '${session.peer} · ${appLocalizations.iperfRunning}'
        : appLocalizations.iperfWaiting;
    return ToolSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.14),
                ),
                child: busy || testing
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: color,
                        ),
                      )
                    : Icon(
                        running ? ReIcons.radio : ReIcons.powerOff,
                        color: color,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      running
                          ? appLocalizations.iperfServerListening(port)
                          : appLocalizations.iperfServerOff,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onEditPort case final onEditPort?)
                TextButton.icon(
                  onPressed: onEditPort,
                  icon: const Icon(ReIcons.setting4, size: 16),
                  label: Text('${appLocalizations.iperfPort} $port'),
                ),
            ],
          ),
          if (error.isNotEmpty) ...[
            const SizedBox(height: 14),
            ToolNote(
              icon: ReIcons.alertCircle,
              text: error,
              color: colorScheme.error,
            ),
          ],
        ],
      ),
    );
  }
}

class _ConnectCard extends StatelessWidget {
  final List<String> addresses;
  final int port;
  final String name;
  final ValueChanged<String> onCopy;

  const _ConnectCard({
    required this.addresses,
    required this.port,
    required this.name,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    if (addresses.isEmpty) {
      return ToolSurface(
        child: ToolNote(
          icon: ReIcons.wifiOff,
          text: appLocalizations.iperfNoAddress,
          color: colorScheme.tertiary,
        ),
      );
    }
    final primary = addresses.first;
    final host = primary.contains(':') ? '[$primary]' : primary;
    final portArg = port == iperfDefaultPort ? '' : ' -p $port';
    final commands = [
      'iperf3 -c $host$portArg',
      'iperf3 -c $host$portArg -R',
      'iperf3 -c $host$portArg --bidir',
      'iperf3 -c $host$portArg -u -b 100M',
    ];
    return ToolSurface(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrCodeWidget(
                data: buildIperfLink(hosts: addresses, port: port, name: name),
                size: 168,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (name.isNotEmpty)
            Text(
              name,
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            appLocalizations.iperfScanHint,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          _CopyGroup(
            title: appLocalizations.iperfAddresses,
            items: [
              for (final address in addresses)
                formatIperfAddress(address, port),
            ],
            onCopy: onCopy,
          ),
          _CopyGroup(
            title: appLocalizations.iperfCommands,
            items: commands,
            onCopy: onCopy,
          ),
        ],
      ),
    );
  }
}

class _CopyGroup extends StatelessWidget {
  final String title;
  final List<String> items;
  final ValueChanged<String> onCopy;

  const _CopyGroup({
    required this.title,
    required this.items,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
          child: Text(
            title,
            style: context.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        for (final item in items)
          InkWell(
            borderRadius: BorderRadius.circular(8),
            focusColor: toolFocusColor(context),
            onTap: () => onCopy(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  Icon(
                    ReIcons.copy,
                    size: 15,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _LiveCard extends StatelessWidget {
  final IperfState? state;
  final String idleText;
  final List<(double, double)> upload;
  final List<(double, double)> download;

  const _LiveCard({
    required this.state,
    required this.idleText,
    required this.upload,
    required this.download,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final state = this.state;
    final hasError = state != null && state.error.isNotEmpty;
    final active = state != null && !state.isDone;
    final color = hasError ? colorScheme.error : colorScheme.primary;
    final title = state == null
        ? appLocalizations.iperfResult
        : hasError
        ? appLocalizations.iperfResult
        : switch (state.phase) {
            IperfPhase.connecting => appLocalizations.iperfConnecting,
            IperfPhase.running => appLocalizations.iperfRunning,
            IperfPhase.done => appLocalizations.iperfDone,
          };
    final subtitle = state == null
        ? idleText
        : [
            if (state.peer.isNotEmpty) state.peer,
            _summaryText(state),
          ].join(' · ');
    final showChart = upload.isNotEmpty || download.isNotEmpty;
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
                            ? ReIcons.transferV
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
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (state != null && state.elapsed > 0)
                Text(
                  state.duration > 0 && active
                      ? '${state.elapsed.toStringAsFixed(1)} / ${state.duration.toStringAsFixed(0)} s'
                      : '${state.elapsed.toStringAsFixed(1)} s',
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
              text: iperfErrorText(state.error),
              color: colorScheme.error,
            ),
          ],
          if (state != null &&
              (state.phase == IperfPhase.running || showChart)) ...[
            const SizedBox(height: 18),
            _SpeedRow(state: state),
            if (active) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  value: state.duration > 0
                      ? (state.elapsed / state.duration).clamp(0.0, 1.0)
                      : null,
                ),
              ),
            ],
            if (showChart) ...[
              const SizedBox(height: 14),
              ThroughputChart(download: download, upload: upload, height: 120),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (state.hasDownload)
                    ChartLegend(
                      color: colorScheme.primary,
                      label: iperfFlowLabel(state.role, upload: false),
                    ),
                  if (state.hasDownload && state.hasUpload)
                    const SizedBox(width: 12),
                  if (state.hasUpload)
                    ChartLegend(
                      color: colorScheme.tertiary,
                      label: iperfFlowLabel(state.role, upload: true),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SpeedRow extends StatelessWidget {
  final IperfState state;

  const _SpeedRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final done = state.isDone;
    return Row(
      children: [
        if (state.hasUpload)
          Expanded(
            child: _SpeedValue(
              label: iperfFlowLabel(state.role, upload: true),
              icon: ReIcons.arrowUpCircle,
              color: colorScheme.tertiary,
              bps: done ? (state.uploadResult?.bitrate ?? 0) : state.upload,
            ),
          ),
        if (state.hasDownload)
          Expanded(
            child: _SpeedValue(
              label: iperfFlowLabel(state.role, upload: false),
              icon: ReIcons.arrowCircleDown,
              color: colorScheme.primary,
              bps: done ? (state.downloadResult?.bitrate ?? 0) : state.download,
            ),
          ),
      ],
    );
  }
}

class _SpeedValue extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double bps;

  const _SpeedValue({
    required this.label,
    required this.icon,
    required this.color,
    required this.bps,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              formatSpeedValue(bps),
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w300,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              formatSpeedUnit(bps),
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultRings extends StatelessWidget {
  final IperfState state;

  const _ResultRings({required this.state});

  ToolRing _speed(
    IperfFlow? flow, {
    required bool upload,
    required Color color,
  }) {
    final bps = flow?.bitrate ?? 0;
    return ToolRing(
      label: iperfFlowLabel(state.role, upload: upload),
      value: flow == null ? '—' : formatSpeedValue(bps),
      unit: flow == null ? '' : formatSpeedUnit(bps),
      ratio: speedGaugeFraction(bps),
      color: flow == null ? null : color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final upload = state.uploadResult;
    final download = state.downloadResult;
    final rings = <Widget>[
      if (state.hasUpload)
        _speed(upload, upload: true, color: colorScheme.tertiary),
      if (state.hasDownload)
        _speed(download, upload: false, color: colorScheme.primary),
    ];
    if (state.protocol == IperfProtocol.tcp) {
      final retransmits = _totalRetransmits(state);
      rings.add(
        ToolRing(
          label: appLocalizations.iperfRetransmits,
          value: retransmits == null ? '—' : '$retransmits',
          unit: '',
          ratio: retransmits == null
              ? 0
              : 1 - math.log(retransmits + 1) / math.ln10 / 3,
          color: retransmits == null
              ? null
              : toolGrade(retransmits.toDouble(), 10, 200),
        ),
      );
      final rtts = [
        upload,
        download,
      ].whereType<IperfFlow>().where((flow) => flow.hasRtt);
      if (rtts.isNotEmpty) {
        final rtt = rtts.map((flow) => flow.rttMean).reduce(math.max);
        rings.add(
          ToolRing(
            label: appLocalizations.iperfRtt,
            value: _msText(rtt),
            unit: 'ms',
            ratio: 1 - rtt / 300,
            color: toolGrade(rtt, 50, 150),
          ),
        );
      }
    } else {
      final flows = [upload, download].whereType<IperfFlow>();
      final jitter = flows.fold<double>(
        0,
        (value, flow) => math.max(value, flow.jitter),
      );
      final loss = flows.fold<double>(
        0,
        (value, flow) => math.max(value, flow.lossRate),
      );
      rings.addAll([
        ToolRing(
          label: appLocalizations.speedTestJitter,
          value: jitter.toStringAsFixed(jitter < 10 ? 2 : 1),
          unit: 'ms',
          ratio: 1 - jitter / 50,
          color: toolGrade(jitter, 5, 20),
        ),
        ToolRing(
          label: appLocalizations.speedTestPacketLoss,
          value: (loss * 100).toStringAsFixed(
            loss == 0
                ? 0
                : loss < 0.01
                ? 2
                : loss < 0.1
                ? 1
                : 0,
          ),
          unit: '%',
          ratio: 1 - loss,
          color: toolGrade(loss, 0.01, 0.05),
        ),
      ]);
    }
    return ToolRingCard(rings: rings);
  }
}

class _ResultGrid extends StatelessWidget {
  final IperfState state;

  const _ResultGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final udp = state.protocol == IperfProtocol.udp;
    final tiles = <Widget>[
      ToolInfoTile(
        icon: ReIcons.devices,
        label: appLocalizations.iperfPeer,
        value: state.peer,
      ),
      ToolInfoTile(
        icon: ReIcons.timer,
        label: appLocalizations.iperfDuration,
        value: appLocalizations.iperfSeconds(state.elapsed.toStringAsFixed(1)),
      ),
      for (final (upload, flow) in [
        (true, state.uploadResult),
        (false, state.downloadResult),
      ])
        if (flow != null) ...[
          ToolInfoTile(
            icon: upload ? ReIcons.arrowUp : ReIcons.arrowDown,
            label:
                '${iperfFlowLabel(state.role, upload: upload)} · ${appLocalizations.iperfTransferred}',
            value: _bytesText(flow.bytes),
          ),
          if (!udp && flow.hasRtt)
            ToolInfoTile(
              icon: ReIcons.timer,
              label:
                  '${iperfFlowLabel(state.role, upload: upload)} · ${appLocalizations.iperfRtt}',
              value: _rttText(flow),
              valueWidget: Text.rich(
                TextSpan(
                  text: '${_msText(flow.rttMean)} ms',
                  children: [
                    TextSpan(
                      text: '  ${_msText(flow.rttMin)}–${_msText(flow.rttMax)}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium,
              ),
            ),
          if (udp)
            ToolInfoTile(
              icon: ReIcons.warning,
              label:
                  '${iperfFlowLabel(state.role, upload: upload)} · ${appLocalizations.speedTestPacketLoss}',
              value: appLocalizations.iperfLostPackets(flow.lost, flow.packets),
            ),
        ],
    ];
    return ToolInfoGrid(children: tiles);
  }
}

@visibleForTesting
Widget buildIperfPreviewForTesting({
  required IperfState state,
  List<(double, double)> upload = const [],
  List<(double, double)> download = const [],
  IperfOptions options = const IperfOptions(),
  List<String> addresses = const [],
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    if (addresses.isNotEmpty) ...[
      _ServerCard(
        running: true,
        busy: false,
        port: iperfDefaultPort,
        session: state,
        error: '',
        onEditPort: null,
      ),
      const SizedBox(height: 12),
    ] else ...[
      _OptionsCard(options: options, enabled: true, onChanged: (_) {}),
      const SizedBox(height: 12),
    ],
    _LiveCard(state: state, idleText: '', upload: upload, download: download),
    if (state.hasResult) ...[
      const SizedBox(height: 12),
      _ResultRings(state: state),
      const SizedBox(height: 12),
      _ResultGrid(state: state),
    ],
    if (addresses.isNotEmpty) ...[
      const SizedBox(height: 12),
      _ConnectCard(
        addresses: addresses,
        port: iperfDefaultPort,
        name: 'MacBook',
        onCopy: (_) {},
      ),
    ],
  ],
);
