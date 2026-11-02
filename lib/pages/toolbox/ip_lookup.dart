import 'dart:async';
import 'dart:io';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'common.dart';

class _IpEntry {
  final String label;
  final String ip;
  final IpInfo? info;
  final bool loading;
  final bool failed;

  const _IpEntry({
    required this.label,
    this.ip = '',
    this.info,
    this.loading = false,
    this.failed = false,
  });

  _IpEntry copyWith({String? ip, IpInfo? info, bool? loading, bool? failed}) =>
      _IpEntry(
        label: label,
        ip: ip ?? this.ip,
        info: info ?? this.info,
        loading: loading ?? this.loading,
        failed: failed ?? this.failed,
      );
}

Future<List<String>> toolResolveHost(String host, {bool ipv6 = true}) async {
  if (globalState.isStart) {
    final ips = <String>[];
    for (final type in ['A', if (ipv6) 'AAAA']) {
      final result = await clashCore.dnsQuery(
        domain: host,
        type: type,
        mode: 'follow',
      );
      ips.addAll(
        result.answers
            .where((record) => record.type == type)
            .map((record) => record.data),
      );
    }
    if (ips.isNotEmpty) return ips;
  }
  try {
    final addresses = await InternetAddress.lookup(host);
    return addresses.map((address) => address.address).toList();
  } catch (_) {
    return [];
  }
}

class IpLookupPage extends ConsumerStatefulWidget {
  final String? initialQuery;

  const IpLookupPage({super.key, this.initialQuery});

  @override
  ConsumerState<IpLookupPage> createState() => _IpLookupPageState();
}

class _IpLookupPageState extends ConsumerState<IpLookupPage>
    with ToolHistoryMixin<IpLookupPage> {
  @override
  String get historyKey => 'ip';

  final _controller = TextEditingController();
  _IpEntry _proxyExit = _IpEntry(label: appLocalizations.ipLookupProxyExit);
  _IpEntry _domesticExit = _IpEntry(
    label: appLocalizations.ipLookupDomesticExit,
  );
  bool _mineLoading = true;
  final _showDomestic = Intl.getCurrentLocale().toLowerCase().startsWith('zh');
  List<_IpEntry>? _results;
  String _query = '';
  String _error = '';
  bool _searching = false;
  int _serial = 0;
  int _mineSerial = 0;

  @override
  void initState() {
    super.initState();
    loadHistory();
    final initial = widget.initialQuery?.trim() ?? '';
    if (initial.isNotEmpty) {
      _controller.text = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) => _search(initial));
    }
    _loadMine();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadMine() async {
    final serial = ++_mineSerial;
    setState(() => _mineLoading = true);
    Future<_IpEntry> load(
      Future<Result<IpInfo?>> future,
      _IpEntry entry,
    ) async {
      final res = await future;
      final info = res.data;
      return res.isError || info == null
          ? entry.copyWith(loading: false, failed: true)
          : entry.copyWith(ip: info.ip, info: info, loading: false);
    }

    final network = globalState.appController
        .updateLocalNetwork(silent: true)
        .timeout(const Duration(seconds: 4), onTimeout: () {});
    final results = await Future.wait([
      load(
        request.checkIp(timeout: const Duration(seconds: 6)),
        _IpEntry(label: _proxyExit.label),
      ),
      if (_showDomestic)
        load(
          request.checkIpDomestic(timeout: const Duration(seconds: 6)),
          _IpEntry(label: _domesticExit.label),
        ),
    ]);
    await network;
    if (!mounted || serial != _mineSerial) return;
    setState(() {
      _proxyExit = results[0];
      if (results.elementAtOrNull(1) case final domestic?) {
        _domesticExit = domestic;
      }
      _mineLoading = false;
    });
  }

  Future<void> _search(String raw) async {
    final value = raw.trim();
    if (value.isEmpty) {
      setState(() {
        _results = null;
        _error = '';
      });
      return;
    }
    final serial = ++_serial;
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _error = '';
      _query = value;
    });
    final target = _parseTarget(value);
    if (target == null) {
      setState(() {
        _searching = false;
        _results = null;
        _error = appLocalizations.ipLookupInvalid;
      });
      return;
    }
    final ips = InternetAddress.tryParse(target) != null
        ? [target]
        : await toolResolveHost(target);
    if (!mounted || serial != _serial) return;
    if (ips.isEmpty) {
      setState(() {
        _searching = false;
        _results = null;
        _error = appLocalizations.ipLookupResolveFailed;
      });
      return;
    }
    addHistory(value);
    final entries = await Future.wait([
      for (final ip in ips.take(6)) _queryEntry(target, ip),
    ]);
    if (!mounted || serial != _serial) return;
    setState(() {
      _searching = false;
      _results = entries;
    });
  }

  Future<_IpEntry> _queryEntry(String label, String ip) async {
    final entry = _IpEntry(label: label, ip: ip);
    if (utils.classifyIp(ip) != IpCategory.public) return entry;
    final res = await request.queryIpDetail(ip);
    return res.isError || res.data == null
        ? entry.copyWith(failed: true)
        : entry.copyWith(info: res.data);
  }

  String? _parseTarget(String value) {
    var text = value;
    final scheme = text.indexOf('://');
    if (scheme >= 0) text = text.substring(scheme + 3);
    final slash = text.indexOf(RegExp(r'[/?#]'));
    if (slash >= 0) text = text.substring(0, slash);
    if (text.startsWith('[') && text.contains(']')) {
      text = text.substring(1, text.indexOf(']'));
    } else if (':'.allMatches(text).length == 1) {
      text = text.substring(0, text.indexOf(':'));
    }
    text = text.trim().toLowerCase();
    if (text.isEmpty) return null;
    if (InternetAddress.tryParse(text) != null) return text;
    final domain = RegExp(
      r'^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$',
    );
    return domain.hasMatch(text) ? text : null;
  }

  @override
  Widget build(BuildContext context) {
    final localNetwork = ref.watch(localNetworkProvider);
    final results = _results;
    final showResults = results != null && results.isNotEmpty;
    return CommonScaffold(
      title: appLocalizations.ipLookup,
      actions: [
        IconButton(
          tooltip: appLocalizations.retry,
          onPressed: _mineLoading ? null : _loadMine,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      body: ToolPageBody(
        children: [
          ToolSearchField(
            controller: _controller,
            hintText: appLocalizations.ipLookupHint,
            busy: _searching,
            onSubmitted: _search,
          ),
          ToolHistoryBar(
            items: history,
            onSelected: (value) {
              _controller.text = value;
              _search(value);
            },
            onClear: clearHistory,
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),
            ToolNote(
              icon: Icons.error_outline_rounded,
              text: _error,
              color: context.colorScheme.error,
            ),
          ],
          ToolLoadingSwitcher(
            loading: _searching || (!showResults && _mineLoading),
            child: showResults
                ? Column(
                    key: ValueKey('results-$_serial'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ToolSectionHeader(
                        '${appLocalizations.ipLookupResult} · $_query',
                        trailing: TextButton(
                          onPressed: () {
                            _controller.clear();
                            setState(() => _results = null);
                          },
                          child: Text(appLocalizations.ipLookupMine),
                        ),
                      ),
                      for (final entry in results) ...[
                        _IpCard(entry: entry, showLabel: false),
                        const SizedBox(height: 12),
                      ],
                    ],
                  )
                : Column(
                    key: const ValueKey('mine'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ToolSectionHeader(appLocalizations.ipLookupMine),
                      _IpCard(entry: _proxyExit, onRetry: _loadMine),
                      const SizedBox(height: 12),
                      if (_showDomestic) ...[
                        _IpCard(entry: _domesticExit, onRetry: _loadMine),
                        const SizedBox(height: 12),
                      ],
                      _LocalNetworkCard(info: localNetwork),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class ToolKeyValue extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? leading;

  const ToolKeyValue({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 15, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                ?leading,
                Flexible(
                  child: SelectableText(
                    value,
                    style: context.textTheme.bodyMedium,
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

Widget toolFlag(String countryCode, {double size = 14}) {
  if (countryCode.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(right: 6),
    child: Text(
      utils.countryCodeToEmoji(countryCode),
      style: TextStyle(
        fontFamily: FontFamily.twEmoji.value,
        fontFamilyFallback: [FontFamily.twEmoji.value],
        fontSize: size,
      ),
    ),
  );
}

List<Widget> buildIpInfoRows(IpInfo info) {
  final country = [
    if (info.country?.isNotEmpty ?? false) info.country,
    if (info.countryCode.isNotEmpty) info.countryCode,
  ].join(' · ');
  final region = [
    if (info.province?.isNotEmpty ?? false) info.province,
    if ((info.city?.isNotEmpty ?? false) && info.city != info.province)
      info.city,
  ].join(' · ');
  final operator = [
    if ((info.asName?.isNotEmpty ?? false) &&
        info.asName != info.isp &&
        info.asName != info.asDomain)
      info.asName,
    if (info.asn?.isNotEmpty ?? false) info.asn,
  ].join(' · ');
  return [
    if (country.isNotEmpty)
      ToolKeyValue(
        icon: Icons.flag_rounded,
        label: appLocalizations.countryOrRegion,
        value: country,
        leading: toolFlag(info.countryCode),
      ),
    if (region.isNotEmpty)
      ToolKeyValue(
        icon: Icons.location_city_rounded,
        label: appLocalizations.provinceAndCity,
        value: region,
      ),
    if (operator.isNotEmpty)
      ToolKeyValue(
        icon: Icons.business_rounded,
        label: appLocalizations.operatorOrAsn,
        value: operator,
      ),
    if (info.isp?.isNotEmpty ?? false)
      ToolKeyValue(
        icon: Icons.router_rounded,
        label: appLocalizations.isp,
        value: info.isp ?? '',
      ),
    if (info.asDomain?.isNotEmpty ?? false)
      ToolKeyValue(
        icon: Icons.link_rounded,
        label: appLocalizations.organizationDomain,
        value: info.asDomain ?? '',
      ),
  ];
}

class _IpCard extends StatefulWidget {
  final _IpEntry entry;
  final bool showLabel;
  final VoidCallback? onRetry;

  const _IpCard({required this.entry, this.showLabel = true, this.onRetry});

  @override
  State<_IpCard> createState() => _IpCardState();
}

class _IpCardState extends State<_IpCard> {
  String? _riskIp;
  IpRisk? _risk;
  bool _riskLoading = false;
  bool _riskFailed = false;

  @override
  void didUpdateWidget(covariant _IpCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entry.ip != _riskIp) {
      _riskIp = null;
      _risk = null;
      _riskLoading = false;
      _riskFailed = false;
    }
  }

  Future<void> _toggleRisk() async {
    final ip = widget.entry.ip;
    if (_riskIp == ip && !_riskFailed) {
      setState(() => _riskIp = null);
      return;
    }
    setState(() {
      _riskIp = ip;
      _riskLoading = true;
      _riskFailed = false;
    });
    final res = await request.queryIpRisk(ip);
    if (!mounted || _riskIp != ip) return;
    setState(() {
      _risk = res.data;
      _riskLoading = false;
      _riskFailed = res.isError || res.data == null;
    });
  }

  List<Widget> _buildRisk(BuildContext context) {
    final risk = _risk;
    if (_riskIp == null) return const [];
    return [
      const SizedBox(height: 8),
      const Divider(height: 1),
      const SizedBox(height: 10),
      if (_riskLoading)
        const LinearProgressIndicator(minHeight: 2)
      else if (_riskFailed || risk == null)
        ToolNote(
          icon: Icons.error_outline_rounded,
          text: appLocalizations.networkErrorRetryLater,
          color: context.colorScheme.error,
        )
      else ...[
        IpRiskScore(risk: risk),
        if (risk.checks.isNotEmpty) ...[
          const SizedBox(height: 10),
          IpRiskChecks(risk: risk),
        ],
        if (risk.hostname.isNotEmpty) ...[
          const SizedBox(height: 6),
          ToolKeyValue(
            icon: Icons.dns_rounded,
            label: appLocalizations.ipRiskHostname,
            value: risk.hostname,
          ),
        ],
        const IpRiskSource(),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final showLabel = widget.showLabel;
    final onRetry = widget.onRetry;
    final colorScheme = context.colorScheme;
    final info = entry.info;
    final category = entry.ip.isEmpty ? null : utils.classifyIp(entry.ip);
    final rows = info != null ? buildIpInfoRows(info) : const <Widget>[];
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
                    if (showLabel)
                      Text(
                        entry.label,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (entry.loading && entry.ip.isEmpty)
                      Container(
                        width: 140,
                        height: 14,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      )
                    else
                      Row(
                        children: [
                          toolFlag(info?.countryCode ?? '', size: 18),
                          Flexible(
                            child: SelectableText(
                              entry.ip.isEmpty
                                  ? appLocalizations.networkErrorRetryLater
                                  : entry.ip,
                              style: entry.ip.isEmpty
                                  ? context.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.error,
                                    )
                                  : context.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (category == IpCategory.public && !entry.loading)
                IconButton(
                  tooltip: appLocalizations.ipRiskCheck,
                  onPressed: _riskLoading ? null : _toggleRisk,
                  icon: Icon(
                    _riskIp != null
                        ? Icons.shield_rounded
                        : Icons.shield_outlined,
                    size: 18,
                    color: _riskIp != null ? colorScheme.primary : null,
                  ),
                ),
              if (entry.ip.isNotEmpty)
                IconButton(
                  tooltip: appLocalizations.copy,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: entry.ip));
                    context.showNotifier(appLocalizations.copySuccess);
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                )
              else if (entry.failed && onRetry != null)
                IconButton(
                  tooltip: appLocalizations.retry,
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                ),
            ],
          ),
          if (entry.loading && entry.ip.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: LinearProgressIndicator(minHeight: 2),
            )
          else if (category == IpCategory.lan || category == IpCategory.tun)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ToolKeyValue(
                icon: Icons.shuffle_rounded,
                label: appLocalizations.privateIp,
                value: category == IpCategory.tun
                    ? appLocalizations.tunVirtualAddress
                    : 'LAN / Private Network',
              ),
            )
          else if (rows.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 6),
            ...rows,
          ] else if (entry.failed && entry.ip.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ToolNote(
                icon: Icons.error_outline_rounded,
                text: appLocalizations.networkErrorRetryLater,
                color: colorScheme.error,
              ),
            ),
          ..._buildRisk(context),
        ],
      ),
    );
  }
}

class _LocalNetworkCard extends StatelessWidget {
  final NetworkInfo? info;

  const _LocalNetworkCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final info = this.info;
    return ToolSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            appLocalizations.ipLookupLocal,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          if (info == null || info.ip.isEmpty)
            ToolKeyValue(
              icon: Icons.wifi_off_rounded,
              label: appLocalizations.networkType,
              value: info == null ? '…' : appLocalizations.noNetwork,
            )
          else ...[
            ToolKeyValue(
              icon: Icons.wifi_rounded,
              label: appLocalizations.networkType,
              value: [
                if (info.type.isNotEmpty) info.type,
                if (info.interfaceName.isNotEmpty) info.interfaceName,
              ].join(' · '),
            ),
            ToolKeyValue(
              icon: Icons.lan_rounded,
              label: appLocalizations.intranetIP,
              value: info.ip,
            ),
            if (info.gateway.isNotEmpty)
              ToolKeyValue(
                icon: Icons.router_rounded,
                label: appLocalizations.defaultGateway,
                value: info.gateway,
              ),
            if (info.dns.isNotEmpty)
              ToolKeyValue(
                icon: Icons.dns_rounded,
                label: appLocalizations.systemDns,
                value: info.dns.join('\n'),
              ),
          ],
        ],
      ),
    );
  }
}
