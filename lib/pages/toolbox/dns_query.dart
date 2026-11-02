import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'common.dart';
import 'ip_lookup.dart';

enum _DnsMode { follow, system, custom }

const _dnsTypes = ['A', 'AAAA', 'CNAME', 'HTTPS', 'TXT', 'MX', 'NS'];

const dnsPresetServers = [
  '223.5.5.5',
  '119.29.29.29',
  'https://dns.alidns.com/dns-query',
  '1.1.1.1',
  '8.8.8.8',
  'https://cloudflare-dns.com/dns-query',
  'tls://dns.google',
  'quic://dns.adguard-dns.com',
];

String _modeLabel(_DnsMode mode) => switch (mode) {
  _DnsMode.follow => appLocalizations.speedTestFollowRules,
  _DnsMode.system => appLocalizations.dnsQuerySystem,
  _DnsMode.custom => appLocalizations.custom,
};

class DnsQueryPage extends ConsumerStatefulWidget {
  final String? initialDomain;

  const DnsQueryPage({super.key, this.initialDomain});

  @override
  ConsumerState<DnsQueryPage> createState() => _DnsQueryPageState();
}

class _DnsQueryPageState extends ConsumerState<DnsQueryPage>
    with ToolHistoryMixin<DnsQueryPage> {
  static String _server = dnsPresetServers.first;
  static _DnsMode? _lastMode;
  static String _type = 'A';
  static bool _compare = false;

  final _controller = TextEditingController();
  late final _serverController = TextEditingController(text: _server);
  late _DnsMode _mode =
      _lastMode ?? (globalState.isStart ? _DnsMode.follow : _DnsMode.system);
  List<(_DnsMode, DnsQueryResult)> _results = [];
  Map<String, IpInfo> _ipInfos = const {};
  bool _querying = false;
  String _error = '';
  int _serial = 0;

  @override
  String get historyKey => 'dns';

  @override
  void initState() {
    super.initState();
    loadHistory();
    final initial = widget.initialDomain?.trim() ?? '';
    if (initial.isNotEmpty) {
      _controller.text = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) => _query(initial));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _serverController.dispose();
    super.dispose();
  }

  Future<void> _query(String raw) async {
    final domain = raw.trim();
    if (domain.isEmpty) return;
    final isStart = ref.read(runTimeProvider) != null;
    final server = _serverController.text.trim();
    final modes = _compare
        ? [if (isStart) _DnsMode.follow, _DnsMode.system, _DnsMode.custom]
        : [_mode == _DnsMode.follow && !isStart ? _DnsMode.system : _mode];
    if (modes.contains(_DnsMode.custom) && server.isEmpty) {
      setState(() => _error = appLocalizations.dnsQueryServerInvalid);
      return;
    }
    _server = server;
    final serial = ++_serial;
    FocusScope.of(context).unfocus();
    setState(() {
      _querying = true;
      _error = '';
    });
    final results = await Future.wait([
      for (final mode in modes)
        clashCore
            .dnsQuery(
              domain: domain,
              type: _type,
              mode: mode.name,
              server: server,
            )
            .then((result) => (mode, result)),
    ]);
    if (!mounted || serial != _serial) return;
    if (results.any((item) => item.$2.error.isEmpty)) addHistory(domain);
    final ips = {
      for (final (_, result) in results)
        for (final record in result.answers)
          if ((record.type == 'A' || record.type == 'AAAA') &&
              utils.classifyIp(record.data) == IpCategory.public)
            record.data,
    };
    final infos = <String, IpInfo>{};
    await Future.wait([
      for (final ip in ips.take(16))
        request
            .queryIpDetail(ip)
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () => Result.error('timeout'),
            )
            .then((res) {
              if (res.data case final info? when !res.isError) infos[ip] = info;
            }),
    ]);
    if (!mounted || serial != _serial) return;
    setState(() {
      _querying = false;
      _results = results;
      _ipInfos = infos;
    });
  }

  Future<void> _pickServer() async {
    final result = await globalState.showAdaptiveSheet<String>(
      child: OptionsDialog<String>(
        title: appLocalizations.dnsQueryServer,
        options: dnsPresetServers,
        value: _serverController.text.trim(),
        textBuilder: (server) => server,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _serverController.text = result;
      _mode = _DnsMode.custom;
      _lastMode = _mode;
    });
  }

  Future<String> _flushCache() async {
    await globalState.appController.flushDns();
    return appLocalizations.dnsCacheCleared;
  }

  @override
  Widget build(BuildContext context) {
    final isStart = ref.watch(runTimeProvider.select((state) => state != null));
    final colorScheme = context.colorScheme;
    final showServer = _compare || _mode == _DnsMode.custom;
    return CommonScaffold(
      title: appLocalizations.dnsQuery,
      actions: [
        CleanButton(
          tooltip: appLocalizations.clearCacheTitle,
          onClean: isStart ? _flushCache : null,
        ),
      ],
      body: ToolPageBody(
        children: [
          ToolSearchField(
            controller: _controller,
            hintText: appLocalizations.dnsQueryHint,
            busy: _querying,
            onSubmitted: _query,
          ),
          const SizedBox(height: 12),
          ToolSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ToolSegmented<_DnsMode>(
                  values: _DnsMode.values,
                  value: _mode == _DnsMode.follow && !isStart
                      ? _DnsMode.system
                      : _mode,
                  enabled: !_compare,
                  isEnabled: (mode) => mode != _DnsMode.follow || isStart,
                  labelOf: _modeLabel,
                  onChanged: (mode) => setState(() {
                    _mode = mode;
                    _lastMode = mode;
                  }),
                ),
                if (showServer) ...[
                  const SizedBox(height: 12),
                  ToolTvField(
                    controller: _serverController,
                    child: TextField(
                      controller: _serverController,
                      autocorrect: false,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: appLocalizations.dnsQueryServer,
                        hintText: appLocalizations.dnsQueryServerHint,
                        suffixIcon: IconButton(
                          onPressed: _pickServer,
                          icon: const Icon(Icons.expand_more_rounded),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final type in _dnsTypes)
                      ChoiceChip(
                        label: Text(type),
                        selected: _type == type,
                        side: toolChipSide(context),
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) => setState(() => _type = type),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: _compare,
                  title: Text(appLocalizations.dnsQueryCompare),
                  subtitle: Text(appLocalizations.dnsQueryCompareDesc),
                  onChanged: (value) => setState(() => _compare = value),
                ),
                if (!isStart)
                  ToolNote(
                    icon: Icons.info_outline_rounded,
                    text: appLocalizations.dnsQueryStopped,
                    color: colorScheme.tertiary,
                  ),
              ],
            ),
          ),
          ToolHistoryBar(
            items: history,
            onSelected: (value) {
              _controller.text = value;
              _query(value);
            },
            onClear: clearHistory,
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),
            ToolNote(
              icon: Icons.error_outline_rounded,
              text: _error,
              color: colorScheme.error,
            ),
          ],
          ToolLoadingSwitcher(
            loading: _querying,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (mode, result) in _results) ...[
                  const SizedBox(height: 12),
                  _DnsResultCard(mode: mode, result: result, infos: _ipInfos),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DnsResultCard extends StatelessWidget {
  final _DnsMode mode;
  final DnsQueryResult result;
  final Map<String, IpInfo> infos;

  const _DnsResultCard({
    required this.mode,
    required this.result,
    this.infos = const {},
  });

  String _error() => switch (result.error) {
    'stopped' => appLocalizations.dnsQueryStopped,
    'server' => appLocalizations.dnsQueryServerInvalid,
    'invalid' => appLocalizations.ipLookupInvalid,
    final error => error,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    return ToolSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _modeLabel(mode),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (result.server.isNotEmpty && result.server != 'system')
                      Text(
                        result.server,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                  ],
                ),
              ),
              if (result.error.isEmpty)
                Text(
                  '${result.rcode} · ${result.elapsed.round()} ms',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (result.error.isNotEmpty)
            ToolNote(
              icon: Icons.error_outline_rounded,
              text: _error(),
              color: colorScheme.error,
            )
          else if (result.answers.isEmpty)
            ToolNote(
              icon: Icons.inbox_outlined,
              text: appLocalizations.dnsQueryNoRecords,
            )
          else
            for (final record in result.answers)
              _DnsRecordRow(record: record, info: infos[record.data]),
          if (_routeTip(result) case final tip?) ...[
            const SizedBox(height: 8),
            ToolNote(
              icon: Icons.info_outline_rounded,
              text: tip,
              color: colorScheme.tertiary,
            ),
          ],
        ],
      ),
    );
  }
}

String? _routeTip(DnsQueryResult result) {
  if (result.error.isNotEmpty) return null;
  if (result.type != 'A' && result.type != 'AAAA') return null;
  final fake = result.route == 'fake-ip';
  final reason = switch ((result.filterMode, fake)) {
    ('whitelist', true) => appLocalizations.dnsQueryFilterWhiteHit,
    ('whitelist', false) => appLocalizations.dnsQueryFilterWhiteMiss,
    ('rule', true) => appLocalizations.dnsQueryFilterRuleFake,
    ('rule', false) => appLocalizations.dnsQueryFilterRuleReal,
    (_, true) => appLocalizations.dnsQueryFilterBlackMiss,
    (_, false) => appLocalizations.dnsQueryFilterBlackHit,
  };
  final mode = switch (result.route) {
    'hosts' => appLocalizations.dnsQueryHostsHit(result.hosts.join(', ')),
    'fake-ip' => appLocalizations.dnsQueryFakeIpOn(
      reason,
      result.fakeIpRange.isEmpty ? '198.18.0.0/15' : result.fakeIpRange,
    ),
    'real-ip' => appLocalizations.dnsQueryFakeIpOff(reason),
    'mapping' => appLocalizations.dnsQueryRedirHost,
    'normal' => appLocalizations.dnsQueryNormalMode,
    _ => null,
  };
  if (mode == null) return null;
  final hosts = result.route == 'hosts';
  final outbound = switch (result.outboundType) {
    '' => null,
    'Direct' =>
      hosts
          ? appLocalizations.dnsQueryViaDirectHosts
          : appLocalizations.dnsQueryViaDirect,
    'Reject' || 'RejectDrop' => appLocalizations.dnsQueryViaReject,
    _ =>
      hosts
          ? appLocalizations.dnsQueryViaProxyHosts(result.outbound)
          : appLocalizations.dnsQueryViaProxy(result.outbound),
  };
  return outbound == null ? mode : '$mode\n$outbound';
}

class _DnsRecordRow extends StatelessWidget {
  final DnsQueryRecord record;
  final IpInfo? info;

  const _DnsRecordRow({required this.record, this.info});

  bool get _isAddress => record.type == 'A' || record.type == 'AAAA';

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final info = this.info;
    final meta = info == null
        ? ''
        : [
            [
              if (info.country?.isNotEmpty ?? false) info.country,
              if ((info.city?.isNotEmpty ?? false)) info.city,
            ].join(' · '),
            if (info.asn?.isNotEmpty ?? false) info.asn,
            if (info.isp?.isNotEmpty ?? false) info.isp,
          ].where((item) => item?.isNotEmpty ?? false).join(' · ');
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      focusColor: toolFocusColor(context),
      onTap: _isAddress
          ? () => showIpDetailDialog(context, record.data, preloaded: info)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              padding: const EdgeInsets.symmetric(vertical: 2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                record.type,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (info != null) toolFlag(info.countryCode),
                      Flexible(
                        child: SelectableText(
                          record.data,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  if (meta.isNotEmpty)
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'TTL ${record.ttl}',
              style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

@visibleForTesting
Widget buildDnsResultForTesting(DnsQueryResult result) =>
    _DnsResultCard(mode: _DnsMode.follow, result: result);
