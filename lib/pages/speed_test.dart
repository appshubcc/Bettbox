import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show Intl;
import 'package:material_ui/material_ui.dart';

import '../views/proxies/card.dart' show ProxyDelayText, proxyIconProvider;
import 'toolbox/common.dart';

const _gaugeMarks = [0.0, 5.0, 10.0, 50.0, 100.0, 250.0, 500.0, 750.0, 1000.0];
const _durations = [5, 10, 15, 20];

String formatSpeedValue(double bps) {
  final mbps = bps / 1e6;
  if (mbps >= 1000) return (mbps / 1000).toStringAsFixed(2);
  return mbps.toStringAsFixed(1);
}

String formatSpeedUnit(double bps) => bps / 1e6 >= 1000 ? 'Gbps' : 'Mbps';

String _formatMs(double value) => value.round().toString();

String _providerName(SpeedTestProvider provider) => switch (provider) {
  SpeedTestProvider.apple => 'Apple',
  SpeedTestProvider.cloudflare => 'Cloudflare',
  SpeedTestProvider.speedtest => 'Speedtest',
};

String _phaseLabel(SpeedTestPhase phase) => switch (phase) {
  SpeedTestPhase.connecting => appLocalizations.speedTestConnecting,
  SpeedTestPhase.latency => appLocalizations.delay,
  SpeedTestPhase.download => appLocalizations.download,
  SpeedTestPhase.upload => appLocalizations.upload,
  SpeedTestPhase.done => appLocalizations.download,
};

double _speedTestHeroScale({required double width, double? availableHeight}) {
  if (width < 480) return 1.0;
  final widthProgress = ((width - 480.0) / 360.0).clamp(0.0, 1.0);
  final heightProgress =
      availableHeight != null && availableHeight.isFinite && availableHeight > 0
      ? ((availableHeight - 436.0) / 200.0).clamp(0.0, 1.0)
      : widthProgress;
  final progress = min(widthProgress, heightProgress);
  return (1.0 + progress * 0.20).clamp(1.0, 1.20);
}

String _loadedLatencyText(SpeedTestState state) {
  final parts = [
    if (state.downloadLatency > 0) '↓${_formatMs(state.downloadLatency)}',
    if (state.uploadLatency > 0) '↑${_formatMs(state.uploadLatency)}',
  ];
  return '${parts.join(' ')} ms';
}

String _serverText(SpeedTestServer? server, [SpeedTestProvider? provider]) {
  if (server == null) return '';
  final providerName = provider != null ? _providerName(provider) : '';
  final country = server.country;
  return [
    if (RegExp(r'^[A-Z]{2}$').hasMatch(country) && country != 'XX')
      '${utils.countryCodeToEmoji(country)} $country'
    else if (country.length > 2)
      country,
    if (server.city.isNotEmpty) server.city,
    if (server.colo.isNotEmpty) server.colo,
    if (server.sponsor.isNotEmpty) server.sponsor,
    if (providerName.isNotEmpty) providerName,
  ].join(' · ');
}

double speedGaugeFraction(double bps) {
  final mbps = bps / 1e6;
  if (mbps <= 0) return 0;
  final segments = _gaugeMarks.length - 1;
  for (var i = 0; i < segments; i++) {
    final low = _gaugeMarks[i];
    final high = _gaugeMarks[i + 1];
    if (mbps <= high) return (i + (mbps - low) / (high - low)) / segments;
  }
  return 1;
}

double _computePeak(
  List<(double, double)> download,
  List<(double, double)> upload,
) {
  var peak = 0.0;
  for (var i = 0; i < download.length; i++) {
    final v = download[i].$2;
    if (v > peak) peak = v;
  }
  for (var i = 0; i < upload.length; i++) {
    final v = upload[i].$2;
    if (v > peak) peak = v;
  }
  return peak;
}

class SpeedTestPage extends ConsumerStatefulWidget {
  const SpeedTestPage({super.key});

  @override
  ConsumerState<SpeedTestPage> createState() => _SpeedTestPageState();
}

class _SpeedTestPageState extends ConsumerState<SpeedTestPage>
    with AppMessageListener, TickerProviderStateMixin {
  late final AnimationController _intro;
  late final Animation<double> _introSweep;
  late final AnimationController _spinner;
  SpeedTestSettings _settings = const SpeedTestSettings();
  String _proxy = '';
  SpeedTestState? _state;
  SpeedTestState? _probe;
  bool _probing = false;
  int _probeSerial = 0;
  bool _testing = false;
  List<SpeedTestRecord> _records = [];
  List<(double, double)> _downloadPoints = const [];
  List<(double, double)> _uploadPoints = const [];

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _introSweep = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 38,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 12),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 50,
      ),
    ]).animate(_intro);
    _spinner = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    clashMessage.addListener(this);
    _intro.addStatusListener((_) {
      if (mounted) setState(() {});
    });
    _intro.forward();
    _load();
  }

  @override
  void dispose() {
    clashMessage.removeListener(this);
    if (_testing || _probing) {
      clashCore.cancelSpeedTest();
    }
    _intro.dispose();
    _spinner.dispose();
    super.dispose();
  }

  bool get _introRunning => _intro.isAnimating;

  Future<void> _load() async {
    final data = await speedTestStore.load();
    if (!mounted) return;
    setState(() {
      _settings = data.settings.normalized;
      _records = data.records;
    });
    _runProbe();
  }

  List<Group> _groups() => ref.read(currentGroupsStateProvider).value;

  String _effectiveProxy(List<Group> groups) {
    if (_proxy.isEmpty || _proxy == 'DIRECT') return _proxy;
    final exists = groups.any(
      (group) =>
          group.name == _proxy ||
          group.all.any((proxy) => proxy.name == _proxy),
    );
    return exists ? _proxy : '';
  }

  String _requestProxy() {
    final isStart = ref.read(runTimeProvider) != null;
    return isStart ? _effectiveProxy(_groups()) : '';
  }

  Future<String?> _resolveSystemDnsFallback() async {
    try {
      final addresses = await InternetAddress.lookup('mensura.cdn-apple.com');
      for (final addr in addresses) {
        if (utils.classifyIp(addr.address) == IpCategory.public) {
          return addr.address;
        }
      }
    } catch (_) {}
    try {
      final response = await request.getTextResponseForUrl(
        'https://223.5.5.5/resolve?name=mensura.cdn-apple.com&type=A',
      );
      final body = response.data;
      final json = body is Map
          ? body as Map<String, dynamic>
          : (body is String ? jsonDecode(body) as Map<String, dynamic> : null);
      final answers = json?['Answer'];
      if (answers is List) {
        for (final item in answers) {
          final data = item is Map ? item['data']?.toString() ?? '' : '';
          if (utils.classifyIp(data) == IpCategory.public) {
            return data;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<SpeedTestState?> _refineAppleServer(SpeedTestState? state) async {
    if (state == null || state.provider != SpeedTestProvider.apple) {
      return state;
    }
    final server = state.server;
    if (server == null) return state;
    final proxy = _requestProxy();
    if (!_settings.useSystemDns && proxy.isNotEmpty && proxy != 'DIRECT') {
      return state;
    }

    var ip = server.ip;
    if ((ip.isEmpty || utils.classifyIp(ip) != IpCategory.public) &&
        _settings.useSystemDns) {
      final resolved = await _resolveSystemDnsFallback();
      if (resolved != null && resolved.isNotEmpty) {
        ip = resolved;
      }
    }
    if (ip.isEmpty || utils.classifyIp(ip) != IpCategory.public) {
      return state;
    }

    final res = await request.queryIpDetail(ip);
    final ipInfo = res.data;
    if (ipInfo == null) {
      return state;
    }

    final country = ipInfo.countryCode;
    final city = ipInfo.city?.isNotEmpty == true
        ? ipInfo.city!
        : (ipInfo.province ?? '');
    return state.copyWith(
      server: server.copyWith(
        ip: ip,
        country: country.isNotEmpty ? country : server.country,
        city: city.isNotEmpty ? city : server.city,
        colo: country == 'CN' ? '' : server.colo,
      ),
    );
  }

  Future<void> _runProbe() async {
    if (_testing) return;
    final serial = ++_probeSerial;
    setState(() {
      _probing = true;
      _probe = null;
    });
    final result = await clashCore.probeSpeedTest(
      settings: _settings,
      proxy: _requestProxy(),
    );
    if (!mounted || serial != _probeSerial) return;
    final refined = await _refineAppleServer(result);
    if (!mounted || serial != _probeSerial) return;
    setState(() {
      _probing = false;
      _probe = refined;
    });
  }

  @override
  void onSpeedTest(SpeedTestState state) {
    if (!_testing || !mounted) return;
    setState(() {
      _state = state.copyWith(
        exitInfo: _probe?.exitInfo,
        server: _probe?.server ?? state.server,
      );
      final point = (state.progress, state.speed);
      if (state.phase == SpeedTestPhase.download) {
        if (_downloadPoints.isEmpty || _downloadPoints.last != point) {
          _downloadPoints = [..._downloadPoints, point];
        }
      } else if (state.phase == SpeedTestPhase.upload) {
        if (_uploadPoints.isEmpty || _uploadPoints.last != point) {
          _uploadPoints = [..._uploadPoints, point];
        }
      }
    });
    _syncSpinner(state);
  }

  void _syncSpinner(SpeedTestState? state) {
    final spinning =
        state != null &&
        state.isRunning &&
        state.phase != SpeedTestPhase.download &&
        state.phase != SpeedTestPhase.upload;
    if (spinning && !_spinner.isAnimating) {
      _spinner.repeat(reverse: true);
    } else if (!spinning && _spinner.isAnimating) {
      _spinner.stop();
    }
  }

  void _updateSettings(SpeedTestSettings settings) {
    final reprobe =
        settings.provider != _settings.provider ||
        settings.useSystemDns != _settings.useSystemDns ||
        settings.server != _settings.server;
    setState(() {
      _settings = settings;
      _state = null;
    });
    speedTestStore.saveSettings(settings);
    if (reprobe) _runProbe();
  }

  Future<void> _start() async {
    if (_testing || _introRunning) return;
    if (await utils.isCellularNetwork()) {
      final res = await globalState.showMessage(
        message: TextSpan(text: appLocalizations.speedTestMobileDataTip),
        confirmText: appLocalizations.speedTestStart,
      );
      if (res != true || !mounted) return;
    }
    final isStart = ref.read(runTimeProvider) != null;
    final proxy = _requestProxy();
    final settings = _settings;
    final exitInfo = _probe?.exitInfo;
    final initial = SpeedTestState(
      provider: settings.provider,
      direct: !isStart,
      outbound: _probe?.outbound,
      server: _probe?.server,
      exitInfo: exitInfo,
    );
    _probeSerial++;
    setState(() {
      _testing = true;
      _probing = false;
      _state = initial;
      _downloadPoints = const [];
      _uploadPoints = const [];
    });
    _syncSpinner(initial);
    final result = await clashCore.startSpeedTest(
      settings: settings,
      proxy: proxy,
    );
    if (!mounted) return;
    final finalState = (result ?? (_state ?? initial)).copyWith(
      error: result == null ? 'unavailable' : result.error,
      exitInfo: exitInfo,
      server: _probe?.server ?? result?.server,
    );
    final refined = await _refineAppleServer(finalState) ?? finalState;
    if (!mounted) return;
    setState(() {
      _testing = false;
      _state = refined;
      _probe = refined;
    });
    _syncSpinner(refined);
    if (refined.phase != SpeedTestPhase.done || refined.error.isNotEmpty) {
      return;
    }
    final data = await speedTestStore.addRecord(
      SpeedTestRecord(
        time: DateTime.now().millisecondsSinceEpoch,
        proxy: proxy,
        result: refined,
      ),
    );
    if (!mounted) return;
    setState(() => _records = data.records);
  }

  Future<void> _selectOutbound() async {
    if (_testing) return;
    final groups = _groups();
    final result = await globalState.showAdaptiveSheet<String>(
      child: _OutboundPicker(selected: _effectiveProxy(groups), groups: groups),
    );
    if (result == null || !mounted || result == _proxy) return;
    setState(() {
      _proxy = result;
      _state = null;
    });
    _runProbe();
  }

  Future<void> _openSettings() async {
    if (_testing) return;
    final result = await globalState.showCommonDialog<SpeedTestSettings>(
      child: _SettingsDialog(settings: _settings, proxy: _requestProxy()),
    );
    if (result == null || !mounted || result == _settings) return;
    _updateSettings(result);
  }

  Future<bool> _clearHistory() async {
    final res = await globalState.showMessage(
      message: TextSpan(text: appLocalizations.speedTestClearHistoryTip),
      confirmText: appLocalizations.clear,
    );
    if (res != true) return false;
    final data = await speedTestStore.clearRecords();
    if (mounted) setState(() => _records = data.records);
    return true;
  }

  Future<void> _openHistory() async {
    await showSheet<void>(
      context: context,
      props: const SheetProps(maxWidth: 420),
      builder: (_, type) =>
          _HistorySheet(type: type, records: _records, onClear: _clearHistory),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStart = ref.watch(runTimeProvider.select((state) => state != null));
    final groups = ref.watch(
      currentGroupsStateProvider.select((state) => state.value),
    );
    ref.listen(runTimeProvider.select((state) => state != null), (_, _) {
      if (!_testing) _runProbe();
    });
    final proxy = _effectiveProxy(groups);
    final state = _state;
    final error = (state ?? _probe)?.error ?? '';
    final showError = error.isNotEmpty && error != 'cancelled';
    final current = state?.error == 'cancelled' ? null : state;

    final outbound = _OutboundCard(
      isStart: isStart,
      proxy: proxy,
      state: current ?? _probe,
      provider: _settings.provider,
      probing: _probing,
      enabled: !_testing && isStart,
      isError: showError,
      onTap: _selectOutbound,
      onShowExitInfo: _exitInfoAction(current ?? _probe),
    );
    final chart = _downloadPoints.isEmpty && _uploadPoints.isEmpty
        ? null
        : _ChartCard(
            download: _downloadPoints,
            upload: _uploadPoints,
            state: current,
          );
    final credit = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ToolNote(
        icon: Icons.info_outline_rounded,
        text: appLocalizations.speedTestCredit,
        color: context.colorScheme.tertiary,
      ),
    );

    return CommonScaffold(
      title: appLocalizations.speedTest,
      actions: [
        _ProviderSelector(
          value: _settings.provider,
          enabled: !_testing,
          onChanged: (provider) {
            if (_testing) return;
            _updateSettings(_settings.copyWith(provider: provider));
          },
        ),
        IconButton(
          tooltip: appLocalizations.speedTestHistory,
          onPressed: _openHistory,
          icon: const Icon(Icons.history_rounded),
        ),
        IconButton(
          tooltip: appLocalizations.speedTestSettings,
          onPressed: _testing ? null : _openSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final availableHeight = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : null;
          final heroWidth = wide
              ? (min(constraints.maxWidth - 48, 1160.0) - 20) * 11 / 20 - 40
              : constraints.maxWidth - 72;
          final scale = _speedTestHeroScale(
            width: heroWidth,
            availableHeight: availableHeight,
          );
          final hero = _HeroPanel(
            settings: _settings,
            state: current,
            introSweep: _introSweep,
            spinner: _spinner,
            introRunning: _introRunning,
            probing: _probing,
            testing: _testing,
            scale: scale,
            onStart: _start,
            onStop: clashCore.cancelSpeedTest,
            onMultiThreadChanged: _testing || _introRunning
                ? null
                : (value) {
                    _updateSettings(_settings.copyWith(multiThread: value));
                    globalState.showNotifier(
                      '${appLocalizations.speedTestConnections}: ${value ? appLocalizations.speedTestMultiThread : appLocalizations.speedTestSingleThread}',
                    );
                  },
          );
          final heroSurface = ToolSurface(
            padding: EdgeInsets.symmetric(
              horizontal: (20 * scale).roundToDouble(),
              vertical: (18 * scale).roundToDouble(),
            ),
            child: hero,
          );
          if (wide) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 11,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [heroSurface],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            outbound,
                            if (chart != null) ...[
                              const SizedBox(height: 12),
                              chart,
                            ],
                            const SizedBox(height: 16),
                            credit,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              outbound,
              const SizedBox(height: 12),
              heroSurface,
              if (chart != null) ...[const SizedBox(height: 12), chart],
              const SizedBox(height: 16),
              credit,
            ],
          );
        },
      ),
    );
  }

  bool _preferDomesticIp(SpeedTestState? state) {
    if (state == null) return false;
    if (!Intl.getCurrentLocale().toLowerCase().startsWith('zh')) return false;
    final direct =
        state.direct ||
        ref.read(runTimeProvider) == null ||
        state.outbound?.chains.lastOrNull == 'DIRECT';
    return direct || state.server?.country.toUpperCase() == 'CN';
  }

  Future<void> _showDomesticIp(IpInfo? fallback) async {
    final res = await globalState.appController.safeRun(
      () => request.checkIpDomestic(timeout: const Duration(seconds: 6)),
      needLoading: true,
    );
    if (!mounted) return;
    final info = res?.data ?? fallback;
    if (info == null || info.ip.isEmpty) return;
    showIpDetailDialog(context, info.ip, preloaded: info);
  }

  VoidCallback? _exitInfoAction(SpeedTestState? state) {
    final data = state?.exitInfo;
    final info = data == null ? null : IpInfo.fromJson(data);
    if (_preferDomesticIp(state)) return () => _showDomesticIp(info);
    if (info == null || info.ip.isEmpty) return null;
    return () => showIpDetailDialog(context, info.ip, preloaded: info);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle(this.title, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final SpeedTestSettings settings;
  final SpeedTestState? state;
  final Animation<double> introSweep;
  final Animation<double> spinner;
  final bool introRunning;
  final bool probing;
  final bool testing;
  final double scale;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final ValueChanged<bool>? onMultiThreadChanged;

  const _HeroPanel({
    required this.settings,
    required this.state,
    required this.introSweep,
    required this.spinner,
    required this.introRunning,
    required this.probing,
    required this.testing,
    this.scale = 1.0,
    required this.onStart,
    required this.onStop,
    required this.onMultiThreadChanged,
  });

  @override
  Widget build(BuildContext context) {
    final state = this.state;
    final finished = state?.isFinished ?? false;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 480;
        final button = _StartButton(
          testing: testing,
          enabled: !introRunning,
          again: finished,
          onStart: onStart,
          onStop: onStop,
          width: wide
              ? (156 * scale).roundToDouble()
              : (200 * scale).roundToDouble(),
          height: wide
              ? (40 * scale).roundToDouble()
              : (46 * scale).roundToDouble(),
          scale: scale,
        );

        if (wide) {
          final gaugeSize = (212.0 * scale).roundToDouble();
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: gaugeSize + (20 * scale).roundToDouble(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SpeedGauge(
                      size: gaugeSize,
                      state: state,
                      introSweep: introSweep,
                      spinner: spinner,
                      introRunning: introRunning,
                      probing: probing,
                      multiThread: settings.multiThread,
                      onMultiThreadChanged: onMultiThreadChanged,
                    ),
                    SizedBox(height: (10 * scale).roundToDouble()),
                    button,
                  ],
                ),
              ),
              SizedBox(width: (18 * scale).roundToDouble()),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PhaseSteps(state: state, scale: scale),
                    SizedBox(height: (14 * scale).roundToDouble()),
                    _SpeedTiles(state: state, scale: scale),
                  ],
                ),
              ),
            ],
          );
        }

        final size = min(constraints.maxWidth, 300.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: _SpeedGauge(
                size: size,
                state: state,
                introSweep: introSweep,
                spinner: spinner,
                introRunning: introRunning,
                probing: probing,
                multiThread: settings.multiThread,
                onMultiThreadChanged: onMultiThreadChanged,
              ),
            ),
            const SizedBox(height: 8),
            _PhaseSteps(state: state, scale: scale),
            const SizedBox(height: 14),
            Center(child: button),
            const SizedBox(height: 16),
            _SpeedTiles(state: state, scale: scale),
          ],
        );
      },
    );
  }
}

class _ProviderSelector extends StatelessWidget {
  final SpeedTestProvider value;
  final bool enabled;
  final ValueChanged<SpeedTestProvider> onChanged;

  const _ProviderSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CommonPopupBox(
      targetBuilder: (open) {
        return IconButton(
          tooltip: _providerName(value),
          onPressed: enabled ? () => open(offset: const Offset(0, 20)) : null,
          icon: const Icon(Icons.speed_rounded),
        );
      },
      popup: CommonPopupMenu(
        items: [
          for (final provider in SpeedTestProvider.values)
            PopupMenuItemData(
              icon: provider == value
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              label: _providerName(provider),
              onPressed: () => onChanged(provider),
            ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final bool testing;
  final bool enabled;
  final bool again;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final double width;
  final double height;
  final double scale;

  const _StartButton({
    required this.testing,
    required this.enabled,
    required this.again,
    required this.onStart,
    required this.onStop,
    this.width = 200,
    this.height = 48,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final label = testing
        ? appLocalizations.stop
        : again
        ? appLocalizations.speedTestAgain
        : appLocalizations.speedTestStart;
    final isCompact = height < 44;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: enabled ? 1 : 0.4,
      child: SizedBox(
        width: width,
        height: height,
        child: FilledButton(
          style: FilledButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.zero,
            backgroundColor: testing
                ? colorScheme.error.opacity12
                : colorScheme.primary.opacity12,
            foregroundColor: testing ? colorScheme.error : colorScheme.primary,
            disabledBackgroundColor: colorScheme.primary.opacity12,
            disabledForegroundColor: colorScheme.primary,
            shape: const StadiumBorder(),
          ),
          onPressed: !enabled ? null : (testing ? onStop : onStart),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Row(
              key: ValueKey(label),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  testing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: (isCompact ? 18.0 : 20.0) * scale,
                ),
                SizedBox(width: (6 * scale).roundToDouble()),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: (isCompact ? 13.5 : 15.0) * scale,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeedGauge extends StatelessWidget {
  final double size;
  final SpeedTestState? state;
  final Animation<double> introSweep;
  final Animation<double> spinner;
  final bool introRunning;
  final bool probing;
  final bool multiThread;
  final ValueChanged<bool>? onMultiThreadChanged;

  const _SpeedGauge({
    required this.size,
    required this.state,
    required this.introSweep,
    required this.spinner,
    required this.introRunning,
    required this.probing,
    required this.multiThread,
    required this.onMultiThreadChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final state = this.state;
    final phase = state?.phase;
    final isUpload = phase == SpeedTestPhase.upload;
    final color = isUpload ? colorScheme.tertiary : colorScheme.primary;
    final startColor = Color.lerp(
      color,
      isUpload ? colorScheme.primary : colorScheme.tertiary,
      0.55,
    );
    final value = switch (phase) {
      SpeedTestPhase.download || SpeedTestPhase.upload => state?.speed ?? 0,
      SpeedTestPhase.done => state?.download ?? 0,
      _ => 0.0,
    };
    final hasValue =
        phase == SpeedTestPhase.download ||
        phase == SpeedTestPhase.upload ||
        phase == SpeedTestPhase.done;
    final label = introRunning || (probing && state == null)
        ? appLocalizations.speedTestProbing
        : state == null
        ? appLocalizations.speedTestReady
        : _phaseLabel(state.phase);
    final labelStyle = (context.textTheme.labelLarge ?? const TextStyle())
        .copyWith(
          fontSize: size / 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.outline.withValues(alpha: 0.75),
        );

    final onMultiThreadChanged = this.onMultiThreadChanged;
    final iconSize = size / 16;

    return SizedBox(
      width: size,
      height: size * 0.92,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: speedGaugeFraction(value)),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, fraction, _) {
          return AnimatedBuilder(
            animation: Listenable.merge([introSweep, spinner]),
            builder: (context, _) {
              final shown = introRunning ? introSweep.value : fraction;
              final shownBps = value;
              final showNumber = hasValue && !introRunning;
              return CustomPaint(
                painter: _GaugePainter(
                  fraction: shown,
                  color: color,
                  startColor: startColor ?? color,
                  trackColor: colorScheme.surfaceContainerHighest,
                  needleColor: colorScheme.onSurface,
                  labelStyle: labelStyle,
                  passedLabelColor: colorScheme.onSurface,
                  spin: spinner.isAnimating
                      ? Curves.easeInOut.transform(spinner.value)
                      : null,
                  showNeedle: showNumber || introRunning,
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: size * 0.56),
                  child: Column(
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: showNumber || introRunning ? 0 : 1,
                        child: Text(
                          label,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        showNumber ? formatSpeedValue(shownBps) : '—',
                        style: context.textTheme.displayMedium?.copyWith(
                          fontSize: size / 7.2,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -0.5,
                          height: 1.05,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          customBorder: const StadiumBorder(),
                          onTap: onMultiThreadChanged == null
                              ? null
                              : () => onMultiThreadChanged(!multiThread),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: multiThread
                                      ? CustomPaint(
                                          key: ValueKey((isUpload, true)),
                                          size: Size(
                                            iconSize * 30 / 24,
                                            iconSize,
                                          ),
                                          painter: _MultiArrowCapsulePainter(
                                            color: color,
                                            up: isUpload,
                                          ),
                                        )
                                      : Icon(
                                          isUpload
                                              ? Icons.arrow_circle_up_outlined
                                              : Icons
                                                    .arrow_circle_down_outlined,
                                          key: ValueKey((isUpload, false)),
                                          size: iconSize,
                                          color: color,
                                        ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  formatSpeedUnit(shownBps),
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(
                                        fontSize: size / 19,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MultiArrowCapsulePainter extends CustomPainter {
  final Color color;
  final bool up;

  const _MultiArrowCapsulePainter({required this.color, required this.up});

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.height / 24;
    final center = size.center(Offset.zero);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: unit * 28, height: unit * 18),
        Radius.circular(unit * 9),
      ),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = unit * 2,
    );
    final direction = up ? -1.0 : 1.0;
    final arrows = Path();
    for (final offset in const [-5.0, 5.0]) {
      final x = center.dx + offset * unit;
      arrows
        ..moveTo(x - unit, center.dy - direction * unit * 4)
        ..lineTo(x + unit, center.dy - direction * unit * 4)
        ..lineTo(x + unit, center.dy)
        ..lineTo(x + unit * 4, center.dy)
        ..lineTo(x, center.dy + direction * unit * 4)
        ..lineTo(x - unit * 4, center.dy)
        ..lineTo(x - unit, center.dy)
        ..close();
    }
    canvas.drawPath(arrows, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_MultiArrowCapsulePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.up != up;
}

class _GaugePainter extends CustomPainter {
  final double fraction;
  final Color color;
  final Color startColor;
  final Color trackColor;
  final Color needleColor;
  final TextStyle labelStyle;
  final Color passedLabelColor;
  final double? spin;
  final bool showNeedle;

  _GaugePainter({
    required this.fraction,
    required this.color,
    required this.startColor,
    required this.trackColor,
    required this.needleColor,
    required this.labelStyle,
    required this.passedLabelColor,
    required this.spin,
    required this.showNeedle,
  });

  static const _start = pi * 0.75;
  static const _sweep = pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width / 13;
    final center = Offset(size.width / 2, size.width / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, _start, _sweep, false, stroke..color = trackColor);

    final sweep = _sweep * fraction;
    if (fraction > 0.002) {
      canvas.drawArc(
        rect,
        _start,
        sweep,
        false,
        stroke
          ..shader = SweepGradient(
            endAngle: _sweep,
            colors: [startColor, color],
            transform: const GradientRotation(_start),
          ).createShader(rect),
      );
      stroke.shader = null;
    }

    final spin = this.spin;
    if (spin != null) {
      const length = pi / 5;
      canvas.drawArc(
        rect,
        _start + (_sweep - length) * spin,
        length,
        false,
        stroke..color = color.withValues(alpha: 0.7),
      );
    }

    final labelRadius = radius - strokeWidth / 2 - size.width * 0.085;
    final segments = _gaugeMarks.length - 1;
    for (var i = 0; i < _gaugeMarks.length; i++) {
      final position = i / segments;
      final angle = _start + _sweep * position;
      final mark = _gaugeMarks[i];
      final text = i == segments ? '1G+' : mark.toStringAsFixed(0);
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: position <= fraction + 0.001
              ? labelStyle.copyWith(color: passedLabelColor)
              : labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelCenter = center + Offset(cos(angle), sin(angle)) * labelRadius;
      painter.paint(
        canvas,
        labelCenter - Offset(painter.width / 2, painter.height / 2),
      );
    }

    if (!showNeedle) return;
    final angle = _start + sweep;
    final direction = Offset(cos(angle), sin(angle));
    final normal = Offset(-direction.dy, direction.dx);
    final outer = size.width / 2;
    final base = center - direction * outer * 0.1;
    final tip = center + direction * outer * 0.5;
    final baseHalf = outer * 0.06;
    final tipHalf = outer * 0.038;
    final needle = Path()
      ..moveTo(base.dx + normal.dx * baseHalf, base.dy + normal.dy * baseHalf)
      ..lineTo(tip.dx + normal.dx * tipHalf, tip.dy + normal.dy * tipHalf)
      ..lineTo(tip.dx - normal.dx * tipHalf, tip.dy - normal.dy * tipHalf)
      ..lineTo(base.dx - normal.dx * baseHalf, base.dy - normal.dy * baseHalf)
      ..close();
    canvas.drawPath(
      needle,
      Paint()
        ..shader = ui.Gradient.linear(
          base,
          tip,
          [
            needleColor.withValues(alpha: 0),
            needleColor.withValues(alpha: 0.35),
            needleColor.withValues(alpha: 0.9),
          ],
          const [0, 0.4, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.color != color ||
        oldDelegate.startColor != startColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.needleColor != needleColor ||
        oldDelegate.passedLabelColor != passedLabelColor ||
        oldDelegate.spin != spin ||
        oldDelegate.showNeedle != showNeedle ||
        oldDelegate.labelStyle != labelStyle;
  }
}

class _PhaseSteps extends StatelessWidget {
  final SpeedTestState? state;
  final double scale;

  const _PhaseSteps({required this.state, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    const phases = [
      SpeedTestPhase.latency,
      SpeedTestPhase.download,
      SpeedTestPhase.upload,
    ];
    final phase = state?.phase;
    final currentIndex = phase == null
        ? -1
        : phase == SpeedTestPhase.done
        ? phases.length
        : phases.indexOf(phase);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < phases.length; i++) ...[
          if (i > 0)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: (16 * scale).roundToDouble(),
              height: 1.5 * scale,
              margin: EdgeInsets.symmetric(
                horizontal: (5 * scale).roundToDouble(),
              ),
              color: i <= currentIndex
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant,
            ),
          _PhaseDot(
            label: _phaseLabel(phases[i]),
            done: i < currentIndex,
            active: i == currentIndex,
            scale: scale,
          ),
        ],
      ],
    );
  }
}

class _PhaseDot extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  final double scale;

  const _PhaseDot({
    required this.label,
    required this.done,
    required this.active,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = done || active ? colorScheme.primary : colorScheme.outline;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: active
              ? (14 * scale).roundToDouble()
              : (6 * scale).roundToDouble(),
          height: (6 * scale).roundToDouble(),
          decoration: BoxDecoration(
            color: done || active ? color : colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular((3 * scale).roundToDouble()),
          ),
        ),
        SizedBox(width: (4 * scale).roundToDouble()),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: (context.textTheme.labelSmall ?? const TextStyle()).copyWith(
            color: color,
            fontSize: (context.textTheme.labelSmall?.fontSize ?? 11) * scale,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}

class _SpeedTiles extends StatelessWidget {
  final SpeedTestState? state;
  final double scale;

  const _SpeedTiles({required this.state, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final state = this.state;
    final phase = state?.phase;
    final colorScheme = context.colorScheme;

    final download = phase == SpeedTestPhase.download
        ? state?.speed
        : (state?.download ?? 0) > 0
        ? state?.download
        : null;
    final upload = phase == SpeedTestPhase.upload
        ? state?.speed
        : (state?.upload ?? 0) != 0
        ? state?.upload
        : null;
    final latency = (state?.latency ?? 0) > 0 ? state?.latency : null;
    final jitter = (state?.latency ?? 0) > 0 ? state?.jitter : null;

    final downloadTile = _SpeedTile(
      icon: Icons.arrow_downward_rounded,
      color: colorScheme.primary,
      label: appLocalizations.download,
      value: download != null ? formatSpeedValue(download) : '—',
      unit: download != null ? formatSpeedUnit(download) : 'Mbps',
      active: phase == SpeedTestPhase.download,
      scale: scale,
    );
    final uploadTile = _SpeedTile(
      icon: Icons.arrow_upward_rounded,
      color: colorScheme.tertiary,
      label: appLocalizations.upload,
      value: upload != null ? formatSpeedValue(upload) : '—',
      unit: upload != null ? formatSpeedUnit(upload) : 'Mbps',
      active: phase == SpeedTestPhase.upload,
      scale: scale,
    );
    final latencyTile = _SpeedTile(
      icon: Icons.timer_outlined,
      color: colorScheme.primary,
      label: appLocalizations.delay,
      value: latency != null ? _formatMs(latency) : '—',
      unit: latency != null ? 'ms' : '',
      active: phase == SpeedTestPhase.latency,
      scale: scale,
    );
    final jitterTile = _SpeedTile(
      icon: Icons.show_chart_rounded,
      color: colorScheme.secondary,
      label: appLocalizations.speedTestJitter,
      value: jitter != null ? jitter.toStringAsFixed(1) : '—',
      unit: jitter != null ? 'ms' : '',
      scale: scale,
    );

    final gap = (7 * scale).roundToDouble();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: downloadTile),
            SizedBox(width: gap),
            Expanded(child: uploadTile),
          ],
        ),
        SizedBox(height: gap),
        Row(
          children: [
            Expanded(child: latencyTile),
            SizedBox(width: gap),
            Expanded(child: jitterTile),
          ],
        ),
      ],
    );
  }
}

class _SpeedTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String unit;
  final bool active;
  final double scale;

  const _SpeedTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.unit = '',
    this.active = false,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: (10 * scale).roundToDouble(),
        vertical: (7 * scale).roundToDouble(),
      ),
      decoration: BoxDecoration(
        color: active
            ? color.withValues(alpha: 0.12)
            : colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(13 * scale),
        border: active
            ? Border.all(
                color: color.withValues(alpha: 0.45),
                width: 1.2 * scale,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all((5 * scale).roundToDouble()),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14 * scale, color: color),
          ),
          SizedBox(width: (7 * scale).roundToDouble()),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10.5 * scale,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: value,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize:
                                (context.textTheme.titleSmall?.fontSize ?? 14) *
                                scale,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (unit.isNotEmpty)
                          TextSpan(
                            text: ' $unit',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 10 * scale,
                            ),
                          ),
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

class _OutboundCard extends StatelessWidget {
  final bool isStart;
  final String proxy;
  final SpeedTestState? state;
  final SpeedTestProvider provider;
  final bool probing;
  final bool enabled;
  final bool isError;
  final VoidCallback onTap;
  final VoidCallback? onShowExitInfo;

  const _OutboundCard({
    required this.isStart,
    required this.proxy,
    required this.state,
    required this.provider,
    required this.probing,
    required this.enabled,
    this.isError = false,
    required this.onTap,
    this.onShowExitInfo,
  });

  String _node(List<String> chains) {
    if (!isStart) return appLocalizations.direct;
    if (chains.isEmpty) return '—';
    final node = chains.last;
    return node == 'DIRECT' ? appLocalizations.direct : node;
  }

  String _route(SpeedTestOutbound? outbound, List<String> chains) {
    if (!isStart) return appLocalizations.speedTestCoreStopped;
    if (proxy.isNotEmpty) {
      final target = proxy == 'DIRECT' ? appLocalizations.direct : proxy;
      final isNode = chains.length == 1 && proxy != 'DIRECT';
      return isNode
          ? appLocalizations.speedTestManual
          : '${appLocalizations.speedTestManual} › $target';
    }
    if (chains.isEmpty) return appLocalizations.speedTestFollowRules;
    final rule = outbound?.rule ?? '';
    final payload = outbound?.rulePayload ?? '';
    final head = rule.isEmpty
        ? appLocalizations.speedTestFollowRules
        : payload.isEmpty
        ? rule
        : '$rule($payload)';
    return chains.length > 1 ? '$head › ${chains.first}' : head;
  }

  String _server(SpeedTestServer? server) {
    if (isError) return appLocalizations.speedTestErrorUnavailable;
    if (server == null) return '—';
    final text = _serverText(server, state?.provider ?? provider);
    return text.isEmpty ? '—' : text;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final outbound = state?.outbound;
    final chains = outbound?.chains ?? const <String>[];
    final loading =
        !isError && probing && outbound == null && state?.server == null;
    final rows = [
      (
        Icons.arrow_outward_rounded,
        appLocalizations.speedTestExitNode,
        _node(chains),
        true,
        false,
      ),
      (
        Icons.alt_route_rounded,
        appLocalizations.speedTestRoute,
        _route(outbound, chains),
        false,
        false,
      ),
      (
        Icons.dns_rounded,
        appLocalizations.speedTestServer,
        _server(state?.server),
        false,
        isError,
      ),
    ];
    final labelStyle = context.textTheme.labelMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final valueStyle = context.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface,
    );
    return ToolSurface(
      onTap: enabled ? onTap : null,
      padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
      child: Row(
        children: [
          Expanded(
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                for (final (index, (icon, label, value, primary, error))
                    in rows.indexed)
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: 14,
                          top: index == 0 ? 0 : 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(label, style: labelStyle),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: index == 0 ? 0 : 6),
                        child: ToolOutboundValue(
                          text: value,
                          loading: loading,
                          onTap: primary ? onShowExitInfo : null,
                          style: error
                              ? valueStyle?.copyWith(color: colorScheme.error)
                              : primary
                              ? valueStyle?.copyWith(
                                  fontWeight: FontWeight.w600,
                                )
                              : !isStart && index == 1
                              ? valueStyle?.copyWith(
                                  color: colorScheme.tertiary,
                                )
                              : valueStyle,
                          skeletonWidth: 80.0 + 30 * index,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (isStart)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 6),
              child: Icon(
                Icons.unfold_more_rounded,
                size: 20,
                color: enabled
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.outlineVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<(double, double)> download;
  final List<(double, double)> upload;
  final SpeedTestState? state;

  const _ChartCard({
    required this.download,
    required this.upload,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return ToolSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(
            appLocalizations.speedTestRealtime,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChartLegend(
                  color: colorScheme.primary,
                  label: appLocalizations.download,
                ),
                const SizedBox(width: 12),
                ChartLegend(
                  color: colorScheme.tertiary,
                  label: appLocalizations.upload,
                ),
              ],
            ),
          ),
          ThroughputChart(download: download, upload: upload),
        ],
      ),
    );
  }
}

class ThroughputChart extends StatelessWidget {
  final List<(double, double)> download;
  final List<(double, double)> upload;
  final double height;

  const ThroughputChart({
    super.key,
    required this.download,
    required this.upload,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final peak = _computePeak(download, upload);
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _ThroughputPainter(
          download: download,
          upload: upload,
          downloadColor: colorScheme.primary,
          uploadColor: colorScheme.tertiary,
          gridColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        child: Align(
          alignment: AlignmentDirectional.topEnd,
          child: peak > 0
              ? Text(
                  '${formatSpeedValue(peak)} ${formatSpeedUnit(peak)}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const ChartLegend({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ThroughputPainter extends CustomPainter {
  static const int _maxRenderPoints = 64;

  static final Path _uploadStrokePath = Path();
  static final Path _uploadFillPath = Path();
  static final Path _downloadStrokePath = Path();
  static final Path _downloadFillPath = Path();

  static final Paint _gridPaint = Paint()..strokeWidth = 1;
  static final Paint _fillPaint = Paint();
  static final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeJoin = StrokeJoin.round;

  static final List<(double, double)> _sampleBuffer = List.filled(
    _maxRenderPoints,
    (0.0, 0.0),
  );

  static Size? _cachedSize;
  static Color? _cachedDownloadColor;
  static Color? _cachedUploadColor;
  static ui.Shader? _downloadShader;
  static ui.Shader? _uploadShader;

  final List<(double, double)> download;
  final List<(double, double)> upload;
  final Color downloadColor;
  final Color uploadColor;
  final Color gridColor;

  _ThroughputPainter({
    required this.download,
    required this.upload,
    required this.downloadColor,
    required this.uploadColor,
    required this.gridColor,
  });

  static void _ensureShaders(
    Size size,
    Color downloadColor,
    Color uploadColor,
  ) {
    final sizeChanged = _cachedSize != size;
    if (sizeChanged ||
        _cachedDownloadColor != downloadColor ||
        _downloadShader == null) {
      _downloadShader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          downloadColor.withValues(alpha: 0.28),
          downloadColor.withValues(alpha: 0),
        ],
      ).createShader(Offset.zero & size);
      _cachedDownloadColor = downloadColor;
    }
    if (sizeChanged ||
        _cachedUploadColor != uploadColor ||
        _uploadShader == null) {
      _uploadShader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          uploadColor.withValues(alpha: 0.28),
          uploadColor.withValues(alpha: 0),
        ],
      ).createShader(Offset.zero & size);
      _cachedUploadColor = uploadColor;
    }
    _cachedSize = size;
  }

  static int _downsample(
    List<(double, double)> points,
    double width,
    double scaleY,
  ) {
    final len = points.length;
    if (len < 2) return 0;

    if (len <= _maxRenderPoints) {
      _sampleBuffer[0] = points[0];
      var outCount = 1;
      var prevX = points[0].$1.clamp(0.0, 1.0) * width;
      var prevY = points[0].$2 * scaleY;
      final lastIndex = len - 1;
      for (var i = 1; i < lastIndex; i++) {
        final pt = points[i];
        final curX = pt.$1.clamp(0.0, 1.0) * width;
        final curY = pt.$2 * scaleY;
        if ((curX - prevX).abs() < 0.25 && (curY - prevY).abs() < 0.25) {
          continue;
        }
        _sampleBuffer[outCount++] = pt;
        prevX = curX;
        prevY = curY;
      }
      _sampleBuffer[outCount++] = points[lastIndex];
      return outCount;
    }

    var peakIndex = 0;
    var peakValue = -1.0;
    for (var i = 0; i < len; i++) {
      final y = points[i].$2;
      if (y > peakValue) {
        peakValue = y;
        peakIndex = i;
      }
    }

    _sampleBuffer[0] = points[0];
    final bucketCount = _maxRenderPoints - 2;
    final bucketSize = (len - 2) / bucketCount;
    var a = 0;

    for (var i = 0; i < bucketCount; i++) {
      final rangeStart = (i * bucketSize).floor() + 1;
      final rangeEnd = min(((i + 1) * bucketSize).floor() + 1, len - 1);

      if (peakIndex >= rangeStart && peakIndex < rangeEnd) {
        _sampleBuffer[i + 1] = points[peakIndex];
        a = peakIndex;
        continue;
      }

      final avgStart = rangeEnd;
      final avgEnd = min(((i + 2) * bucketSize).floor() + 1, len);
      var avgX = 0.0;
      var avgY = 0.0;
      final avgLen = avgEnd - avgStart;
      if (avgLen > 0) {
        for (var j = avgStart; j < avgEnd; j++) {
          final pt = points[j];
          avgX += pt.$1;
          avgY += pt.$2;
        }
        avgX /= avgLen;
        avgY /= avgLen;
      } else {
        final last = points[len - 1];
        avgX = last.$1;
        avgY = last.$2;
      }

      final pointA = points[a];
      final ax = pointA.$1;
      final ay = pointA.$2;
      var maxArea = -1.0;
      var nextA = rangeStart;

      for (var j = rangeStart; j < rangeEnd; j++) {
        final pt = points[j];
        final area = ((ax - avgX) * (pt.$2 - ay) - (ax - pt.$1) * (avgY - ay))
            .abs();
        if (area > maxArea) {
          maxArea = area;
          nextA = j;
        }
      }

      _sampleBuffer[i + 1] = points[nextA];
      a = nextA;
    }

    _sampleBuffer[_maxRenderPoints - 1] = points[len - 1];
    return _maxRenderPoints;
  }

  static void _drawSeries(
    Canvas canvas,
    Size size,
    List<(double, double)> points,
    double scaleY,
    Color color,
    ui.Shader shader,
    Path strokePath,
    Path fillPath,
  ) {
    final count = _downsample(points, size.width, scaleY);
    if (count < 2) return;

    strokePath.reset();
    fillPath.reset();

    final width = size.width;
    final height = size.height;

    final p0 = _sampleBuffer[0];
    var prevX = p0.$1.clamp(0.0, 1.0) * width;
    var prevY = height - p0.$2 * scaleY;
    final firstX = prevX;

    strokePath.moveTo(prevX, prevY);
    for (var i = 1; i < count; i++) {
      final pt = _sampleBuffer[i];
      final curX = pt.$1.clamp(0.0, 1.0) * width;
      final curY = height - pt.$2 * scaleY;
      final midX = (prevX + curX) * 0.5;
      strokePath.cubicTo(midX, prevY, midX, curY, curX, curY);
      prevX = curX;
      prevY = curY;
    }

    fillPath
      ..addPath(strokePath, Offset.zero)
      ..lineTo(prevX, height)
      ..lineTo(firstX, height)
      ..close();

    _fillPaint.shader = shader;
    canvas.drawPath(fillPath, _fillPaint);

    _strokePaint.color = color;
    canvas.drawPath(strokePath, _strokePaint);
  }

  static bool _seriesChanged(
    List<(double, double)> a,
    List<(double, double)> b,
  ) {
    if (identical(a, b)) return false;
    final len = a.length;
    if (len != b.length) return true;
    if (len == 0) return false;
    return a.last != b.last || a.first != b.first || a[len >> 1] != b[len >> 1];
  }

  @override
  void paint(Canvas canvas, Size size) {
    _gridPaint.color = gridColor;
    final quarterHeight = size.height * 0.25;
    for (var i = 1; i <= 3; i++) {
      final y = quarterHeight * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _gridPaint);
    }

    final peak = _computePeak(download, upload);
    if (peak <= 0) return;

    final scaleY = size.height / (peak * 1.15);
    _ensureShaders(size, downloadColor, uploadColor);

    if (upload.length >= 2) {
      _drawSeries(
        canvas,
        size,
        upload,
        scaleY,
        uploadColor,
        _uploadShader!,
        _uploadStrokePath,
        _uploadFillPath,
      );
    }
    if (download.length >= 2) {
      _drawSeries(
        canvas,
        size,
        download,
        scaleY,
        downloadColor,
        _downloadShader!,
        _downloadStrokePath,
        _downloadFillPath,
      );
    }
  }

  @override
  bool shouldRepaint(_ThroughputPainter oldDelegate) {
    return _seriesChanged(oldDelegate.download, download) ||
        _seriesChanged(oldDelegate.upload, upload) ||
        oldDelegate.downloadColor != downloadColor ||
        oldDelegate.uploadColor != uploadColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class _SettingsDialog extends StatefulWidget {
  final SpeedTestSettings settings;
  final String proxy;

  const _SettingsDialog({required this.settings, required this.proxy});

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late SpeedTestSettings _settings = widget.settings;

  Future<void> _pickServer() async {
    final result = await globalState.showAdaptiveSheet<SpeedTestNode>(
      child: _SpeedTestServerPicker(
        selected: _settings.server,
        proxy: widget.proxy,
      ),
    );
    if (result == null || !mounted) return;
    setState(
      () => _settings = _settings.copyWith(
        server: result.host.isEmpty ? null : result.copyWith(latency: 0),
      ),
    );
  }

  Widget _item({required String title, String? desc, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: context.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          child,
          if (desc != null) ...[
            const SizedBox(height: 6),
            Text(
              desc,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.speedTestSettings,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_settings),
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_settings.provider == SpeedTestProvider.speedtest)
            _item(
              title: appLocalizations.speedTestServer,
              child: _QuickOutboundCard(
                title: switch (_settings.server) {
                  final server? => _speedTestNodeTitle(server),
                  null => appLocalizations.auto,
                },
                subtitle: switch (_settings.server) {
                  final server? => _speedTestNodeSubtitle(server),
                  null => appLocalizations.speedTestServerAutoDesc,
                },
                icon: Icons.dns_rounded,
                isSelected: false,
                onTap: _pickServer,
              ),
            ),
          _item(
            title: appLocalizations.speedTestDuration,
            child: ToolSegmented<int>(
              values: _durations,
              value: _settings.duration,
              labelOf: (value) => '${value}s',
              onChanged: (value) => setState(
                () => _settings = _settings.copyWith(duration: value),
              ),
            ),
          ),
          _item(
            title: appLocalizations.speedTestConnections,
            desc: appLocalizations.speedTestConnectionsDesc(
              SpeedTestSettingsExt.multiThreadStreams,
            ),
            child: ToolSegmented<bool>(
              values: const [false, true],
              value: _settings.multiThread,
              labelOf: (value) => value
                  ? appLocalizations.speedTestMultiThread
                  : appLocalizations.speedTestSingleThread,
              onChanged: (value) => setState(
                () => _settings = _settings.copyWith(multiThread: value),
              ),
            ),
          ),
          _item(
            title: appLocalizations.speedTestProtocol,
            desc: appLocalizations.speedTestProtocolDesc,
            child: ToolSegmented<SpeedTestProtocol>(
              values: const [SpeedTestProtocol.http2, SpeedTestProtocol.http3],
              value: _settings.protocol,
              labelOf: (value) => value == SpeedTestProtocol.http3
                  ? '${value.label} (QUIC)'
                  : value.label,
              onChanged: (value) => setState(
                () => _settings = _settings.copyWith(protocol: value),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            appLocalizations.speedTestUseSystemDns,
                            style: context.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!globalState.isAndroidTV)
                          Tooltip(
                            message: appLocalizations.speedTestUseSystemDnsDesc,
                            triggerMode: TooltipTriggerMode.tap,
                            showDuration: const Duration(seconds: 5),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.info_outline_rounded,
                                size: 15,
                                color: context.colorScheme.outline,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (globalState.isAndroidTV) ...[
                      const SizedBox(height: 6),
                      Text(
                        appLocalizations.speedTestUseSystemDnsDesc,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: _settings.useSystemDns,
                onChanged: (value) => setState(
                  () => _settings = _settings.copyWith(useSystemDns: value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _speedTestNodeTitle(SpeedTestNode node) => [
  if (node.cc.length == 2) utils.countryCodeToEmoji(node.cc.toUpperCase()),
  node.name,
].join(' ');

String _speedTestNodeSubtitle(SpeedTestNode node, {bool latency = false}) => [
  if (node.sponsor.isNotEmpty) node.sponsor,
  if (latency) node.latency > 0 ? '${_formatMs(node.latency)} ms' : '—',
].join(' · ');

class _SpeedTestServerPicker extends StatefulWidget {
  final SpeedTestNode? selected;
  final String proxy;

  const _SpeedTestServerPicker({required this.selected, required this.proxy});

  @override
  State<_SpeedTestServerPicker> createState() => _SpeedTestServerPickerState();
}

class _SpeedTestServerPickerState extends State<_SpeedTestServerPicker> {
  final _controller = TextEditingController();
  List<SpeedTestNode> _servers = const [];
  bool _loading = true;
  int _serial = 0;

  @override
  void initState() {
    super.initState();
    _load('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load(String search) async {
    final serial = ++_serial;
    setState(() => _loading = true);
    final servers = await clashCore.getSpeedTestServers(
      proxy: widget.proxy,
      search: search,
    );
    if (!mounted || serial != _serial) return;
    setState(() {
      _loading = false;
      _servers = servers;
    });
  }

  Widget _card(SpeedTestNode node, {bool latency = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _QuickOutboundCard(
        title: _speedTestNodeTitle(node),
        subtitle: _speedTestNodeSubtitle(node, latency: latency),
        icon: Icons.dns_rounded,
        isSelected: widget.selected?.host == node.host,
        onTap: () => Navigator.of(context).pop(node),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final pinned =
        selected != null && !_servers.any((item) => item.host == selected.host)
        ? selected
        : null;
    return CommonDialog(
      title: appLocalizations.speedTestServer,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      overrideScroll: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSearchField(
            controller: _controller,
            hintText: appLocalizations.search,
            busy: _loading,
            onSubmitted: _load,
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _QuickOutboundCard(
                    title: appLocalizations.auto,
                    subtitle: appLocalizations.speedTestServerAutoDesc,
                    icon: Icons.auto_awesome_rounded,
                    isSelected: selected == null,
                    onTap: () =>
                        Navigator.of(context).pop(const SpeedTestNode()),
                  ),
                ),
                if (pinned != null) _card(pinned, latency: false),
                ToolLoadingSwitcher(
                  loading: _loading,
                  loadingHeight: 160,
                  child: _servers.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: Text(appLocalizations.noData)),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [for (final node in _servers) _card(node)],
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

const _hiddenProxyTypes = {'Reject', 'RejectDrop', 'Pass', 'Compatible'};

@visibleForTesting
Widget buildSpeedTestOutboundPickerForTesting({
  required String selected,
  required List<Group> groups,
  bool batch = false,
}) => _OutboundPicker(selected: selected, groups: groups, batch: batch);

class _OutboundPicker extends StatefulWidget {
  final String selected;
  final List<Group> groups;
  final bool batch;

  const _OutboundPicker({
    required this.selected,
    required this.groups,
    this.batch = false,
  });

  @override
  State<_OutboundPicker> createState() => _OutboundPickerState();
}

class _OutboundPickerState extends State<_OutboundPicker> {
  late final Set<String> _expandedGroups = {
    ...widget.groups
        .where(
          (group) =>
              group.name == widget.selected ||
              group.all.any((proxy) => proxy.name == widget.selected),
        )
        .map((group) => group.name),
  };

  void _select(String value) => Navigator.of(
    context,
  ).pop(widget.batch ? (scope: OutboundBatchScope.node, name: value) : value);

  void _pickGroup(String name) =>
      Navigator.of(context).pop((scope: OutboundBatchScope.group, name: name));

  void _toggleGroup(String name) {
    setState(() {
      if (_expandedGroups.contains(name)) {
        _expandedGroups.remove(name);
      } else {
        _expandedGroups.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final batch = widget.batch;
    return CommonDialog(
      title: batch
          ? appLocalizations.mediaBatchScope
          : appLocalizations.speedTestOutbound,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      overrideScroll: true,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          if (batch)
            _QuickOutboundCard(
              title: appLocalizations.mediaBatchAll,
              subtitle: appLocalizations.mediaBatchAllDesc,
              icon: Icons.done_all_rounded,
              isSelected: false,
              onTap: () => Navigator.of(
                context,
              ).pop((scope: OutboundBatchScope.all, name: '')),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _QuickOutboundCard(
                    title: appLocalizations.speedTestFollowRules,
                    subtitle: appLocalizations.speedTestRoute,
                    icon: Icons.alt_route_rounded,
                    isSelected: widget.selected.isEmpty,
                    onTap: () => _select(''),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickOutboundCard(
                    title: appLocalizations.direct,
                    subtitle: 'DIRECT',
                    icon: Icons.arrow_outward_rounded,
                    isSelected: widget.selected == 'DIRECT',
                    onTap: () => _select('DIRECT'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          for (final group in widget.groups) ...[
            _OutboundGroupCard(
              group: group,
              isExpanded: _expandedGroups.contains(group.name),
              isSelected: !batch && widget.selected == group.name,
              onToggle: () => _toggleGroup(group.name),
              onPick: batch ? () => _pickGroup(group.name) : null,
            ),
            if (_expandedGroups.contains(group.name)) ...[
              const SizedBox(height: 8),
              _OutboundProxyGrid(
                group: group,
                proxies: group.all
                    .where(
                      (p) =>
                          !_hiddenProxyTypes.contains(p.type) &&
                          !(batch &&
                              outboundBatchExcludedTypes.contains(p.type)),
                    )
                    .toList(),
                testUrl: group.testUrl,
                selected: widget.selected,
                highlightActive: !batch,
                onSelect: _select,
              ),
            ],
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _QuickOutboundCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickOutboundCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return FocusStateBuilder(
      builder: (context, hasFocus) {
        final focused = hasFocus && globalState.isAndroidTV;
        return Stack(
          children: [
            Container(
              height: 64,
              decoration: ShapeDecoration(
                color: isSelected
                    ? colorScheme.secondaryContainer
                    : colorScheme.surface,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected || focused
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withValues(alpha: 0.55),
                    width: focused ? 2.5 : (isSelected ? 1.5 : 1),
                  ),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: 0.15)
                              : colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          size: 19,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: isSelected ? 12 : 0,
                              ),
                              child: EmojiText(
                                title,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                  fontSize: 13.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 2),
                            EmojiText(
                              subtitle,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.outline,
                                fontSize: 10.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OutboundGroupCard extends ConsumerWidget {
  final Group group;
  final bool isExpanded;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback? onPick;

  const _OutboundGroupCard({
    required this.group,
    required this.isExpanded,
    required this.isSelected,
    required this.onToggle,
    this.onPick,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final icon = ref.watch(proxyIconProvider(group.name));

    final activeProxyName =
        ref.watch(getSelectedProxyNameProvider(group.name)) ?? group.now ?? '';

    return FocusStateBuilder(
      builder: (context, hasFocus) {
        final focused = hasFocus && globalState.isAndroidTV;
        return Stack(
          children: [
            Container(
              height: 56,
              decoration: ShapeDecoration(
                color: isSelected
                    ? colorScheme.secondaryContainer.withValues(alpha: 0.7)
                    : colorScheme.surface,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected || focused
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withValues(alpha: 0.55),
                    width: focused ? 2.5 : (isSelected ? 1.5 : 1),
                  ),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: icon.isNotEmpty
                            ? CommonTargetIcon(src: icon, size: 18)
                            : Icon(
                                Icons.hub_outlined,
                                size: 17,
                                color: colorScheme.primary,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EmojiText(
                              group.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                            if (activeProxyName.isNotEmpty) ...[
                              const SizedBox(height: 1),
                              EmojiText(
                                activeProxyName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.outline,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (onPick case final onPick?)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 4),
                          child: FilledButton.tonal(
                            onPressed: onPick,
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              minimumSize: const Size(0, 30),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: textTheme.labelMedium,
                            ),
                            child: Text(appLocalizations.mediaBatchGroup),
                          ),
                        ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OutboundProxyGrid extends ConsumerWidget {
  final Group group;
  final List<Proxy> proxies;
  final String? testUrl;
  final String selected;
  final bool highlightActive;
  final ValueChanged<String> onSelect;

  const _OutboundProxyGrid({
    required this.group,
    required this.proxies,
    this.testUrl,
    required this.selected,
    this.highlightActive = true,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProxyName =
        ref.watch(getSelectedProxyNameProvider(group.name)) ?? group.now ?? '';
    final hasManualSelection = proxies.any((p) => p.name == selected);

    const columns = 2;
    final rowCount = (proxies.length / columns).ceil();

    return Column(
      children: [
        for (var i = 0; i < rowCount; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var c = 0; c < columns; c++) ...[
                if (c > 0) const SizedBox(width: 8),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final idx = i * columns + c;
                      if (idx >= proxies.length) return const SizedBox();
                      final proxy = proxies[idx];
                      final isSelected = hasManualSelection
                          ? selected == proxy.name
                          : highlightActive &&
                                (activeProxyName == proxy.name ||
                                    selected == proxy.name);
                      return _OutboundProxyCard(
                        proxy: proxy,
                        testUrl: testUrl,
                        isSelected: isSelected,
                        onTap: () => onSelect(proxy.name),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _OutboundProxyCard extends StatelessWidget {
  final Proxy proxy;
  final String? testUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _OutboundProxyCard({
    required this.proxy,
    this.testUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return FocusStateBuilder(
      builder: (context, hasFocus) {
        final focused = hasFocus && globalState.isAndroidTV;
        return Stack(
          children: [
            Container(
              height: 56,
              decoration: ShapeDecoration(
                color: isSelected
                    ? colorScheme.secondaryContainer
                    : colorScheme.surface,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected || focused
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: focused ? 2.5 : (isSelected ? 1.5 : 1),
                  ),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: isSelected ? 12 : 0),
                        child: EmojiText(
                          proxy.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: EmojiText(
                              proxy.type,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.outline,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                          ProxyDelayText(
                            proxy: proxy,
                            testUrl: testUrl,
                            enableTest: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HistorySheet extends StatefulWidget {
  final SheetType type;
  final List<SpeedTestRecord> records;
  final Future<bool> Function() onClear;

  const _HistorySheet({
    required this.type,
    required this.records,
    required this.onClear,
  });

  @override
  State<_HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<_HistorySheet> {
  late List<SpeedTestRecord> _records = widget.records;
  int? _expanded;

  Future<void> _clear() async {
    final cleared = await widget.onClear();
    if (!cleared || !mounted) return;
    setState(() => _records = const []);
  }

  @override
  Widget build(BuildContext context) {
    final records = _records;
    return AdaptiveSheetScaffold(
      type: widget.type,
      title: appLocalizations.speedTestHistory,
      actions: [
        if (records.isNotEmpty)
          IconButton(
            tooltip: appLocalizations.clear,
            onPressed: _clear,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
      ],
      body: records.isEmpty
          ? Padding(
              padding: EdgeInsets.only(
                top: 48,
                bottom: 48 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 36,
                    color: context.colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appLocalizations.speedTestHistoryEmpty,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              itemCount: records.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      appLocalizations.speedTestHistoryRetention,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.outline,
                      ),
                    ),
                  );
                }
                final record = records[index - 1];
                return _HistoryItem(
                  key: ValueKey(record.time),
                  record: record,
                  expanded: _expanded == record.time,
                  onTap: () => setState(() {
                    _expanded = _expanded == record.time ? null : record.time;
                  }),
                );
              },
            ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final SpeedTestRecord record;
  final bool expanded;
  final VoidCallback onTap;

  const _HistoryItem({
    super.key,
    required this.record,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final result = record.result;
    final chains = result.outbound?.chains ?? const <String>[];
    final outbound = result.direct
        ? appLocalizations.direct
        : chains.isNotEmpty
        ? chains.last
        : record.proxy.isEmpty
        ? appLocalizations.speedTestFollowRules
        : record.proxy;
    final time = DateTime.fromMillisecondsSinceEpoch(
      record.time,
    ).showFull.substring(5, 16);
    final valueStyle = context.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.bold,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          focusColor: toolFocusColor(context),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
                              '$time · ${_providerName(result.provider)} · ${result.protocolLabel}',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 2),
                            EmojiText(
                              outbound,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '↓ ${formatSpeedValue(result.download)} ${formatSpeedUnit(result.download)}',
                            style: valueStyle?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            result.upload >= 0
                                ? '↑ ${formatSpeedValue(result.upload)} ${formatSpeedUnit(result.upload)}'
                                : '↑ —',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: colorScheme.tertiary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (expanded) ...[
                    const SizedBox(height: 8),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    const SizedBox(height: 8),
                    _HistoryDetails(record: record),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryDetails extends StatelessWidget {
  final SpeedTestRecord record;

  const _HistoryDetails({required this.record});

  @override
  Widget build(BuildContext context) {
    final result = record.result;
    final chains = result.outbound?.chains ?? const <String>[];
    final server = _serverText(result.server, result.provider);
    final rows = <(String, String)>[
      (appLocalizations.delay, '${_formatMs(result.latency)} ms'),
      (
        appLocalizations.speedTestJitter,
        '${result.jitter.toStringAsFixed(1)} ms',
      ),
      if (result.downloadLatency > 0 || result.uploadLatency > 0)
        (appLocalizations.speedTestLoadedLatency, _loadedLatencyText(result)),
      if (result.rpm > 0)
        (appLocalizations.speedTestResponsiveness, '${result.rpm} RPM'),
      if (chains.length > 1)
        (appLocalizations.speedTestOutbound, chains.join(' › ')),
      if (server.isNotEmpty) (appLocalizations.speedTestServer, server),
      (
        appLocalizations.speedTestConnections,
        appLocalizations.speedTestStreams(result.streams),
      ),
      (
        appLocalizations.speedTestDataUsed,
        TrafficValue(value: result.bytes).shortShow,
      ),
    ];
    final labelStyle = context.textTheme.labelSmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    final valueStyle = context.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
    );
    return Column(
      children: [
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(width: 12),
                Expanded(
                  child: EmojiText(
                    value,
                    textAlign: TextAlign.end,
                    style: valueStyle,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

Future<String?> showOutboundPicker({
  required String selected,
  required List<Group> groups,
}) => globalState.showAdaptiveSheet<String>(
  child: _OutboundPicker(selected: selected, groups: groups),
);

enum OutboundBatchScope { all, group, node }

typedef OutboundBatchTarget = ({OutboundBatchScope scope, String name});

const outboundBatchExcludedTypes = {
  'Direct',
  'Reject',
  'RejectDrop',
  'Pass',
  'Compatible',
  'Dns',
};

Future<OutboundBatchTarget?> showBatchOutboundPicker({
  required List<Group> groups,
}) async {
  final value = await globalState.showAdaptiveSheet<Object>(
    child: _OutboundPicker(selected: '', groups: groups, batch: true),
  );
  return value is OutboundBatchTarget ? value : null;
}

List<String> collectBatchNodes(List<Group> groups, OutboundBatchTarget target) {
  final byName = {for (final group in groups) group.name: group};
  final names = <String>{};
  void visit(Group group, Set<String> seen) {
    if (!seen.add(group.name)) return;
    for (final proxy in group.all) {
      if (byName[proxy.name] case final child?) {
        visit(child, seen);
      } else if (!outboundBatchExcludedTypes.contains(proxy.type)) {
        names.add(proxy.name);
      }
    }
  }

  switch (target.scope) {
    case OutboundBatchScope.all:
      for (final group in groups) {
        for (final proxy in group.all) {
          if (!byName.containsKey(proxy.name) &&
              !outboundBatchExcludedTypes.contains(proxy.type)) {
            names.add(proxy.name);
          }
        }
      }
    case OutboundBatchScope.group:
      if (byName[target.name] case final group?) visit(group, {});
    case OutboundBatchScope.node:
      names.add(target.name);
  }
  return names.toList();
}
