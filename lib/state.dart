import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/theme.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/plugins/service.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/providers/state.dart' as providers_state;

import 'package:bett_box/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as flutter_riverpod;
import 'package:material_color_utilities/palettes/core_palette.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:synchronized/synchronized.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common/common.dart';
import 'controller.dart';
import 'models/models.dart';

typedef UpdateTasks = List<FutureOr Function()>;

class GlobalState {
  static GlobalState? _instance;
  Map<CacheTag, FixedMap<String, double>> computeHeightMapCache = {};
  bool isService = false;
  bool isExiting = false;
  Timer? timer;
  Timer? groupsUpdateTimer;
  late Config config;
  late AppState appState;
  bool isPre = true;
  String? coreSHA256;
  late PackageInfo packageInfo;
  Function? updateCurrentDelayDebounce;
  VoidCallback? focusDashboardStartSwitch;
  bool isDashboardStartSwitchFocused = false;
  late Measure measure;
  late CommonTheme theme;
  late Color accentColor;
  // ignore: deprecated_member_use
  CorePalette? corePalette;
  DateTime? startTime;
  UpdateTasks tasks = [];
  final navigatorKey = GlobalKey<NavigatorState>();
  final backgroundMode = ValueNotifier<bool>(false);
  final animationEnabled = ValueNotifier<bool>(true);
  AppController? _appController;
  bool? _isAndroidTV;
  int _taskLoopToken = 0;
  bool _isExecutingTasks = false;
  bool _needsTaskRestart = false;
  Timer? _backgroundCleanupTimer;
  final Lock _scriptEvaluateLock = Lock();
  bool isInit = false;

  bool get isStart => startTime != null && startTime!.isBeforeNow;

  AppController get appController => _appController!;

  set appController(AppController appController) {
    _appController = appController;
    isInit = true;
  }

  GlobalState._internal();

  factory GlobalState() {
    _instance ??= GlobalState._internal();
    return _instance!;
  }

  Future<void> initApp(int version) async {
    isExiting = false;
    coreSHA256 = const String.fromEnvironment('CORE_SHA256');
    if (system.isWindows && (coreSHA256 == null || coreSHA256!.isEmpty)) {
      coreSHA256 = await _calcCoreSHA256();
    }
    isPre = const String.fromEnvironment('APP_ENV') != 'stable';
    appState = AppState(
      brightness: WidgetsBinding.instance.platformDispatcher.platformBrightness,
      version: version,
      viewSize: Size.zero,
      requests: FixedList(maxLength),
      logs: FixedList(maxLength),
      traffics: FixedList(30),
      totalTraffic: Traffic(),
      systemUiOverlayStyle: const SystemUiOverlayStyle(),
    );
    await _initDynamicColor();
    await init();
  }

  Future<String?> _calcCoreSHA256() async {
    try {
      final file = File(appPath.corePath);
      if (!await file.exists()) return null;
      final digest = await sha256.bind(file.openRead()).first;
      return digest.toString();
    } catch (e) {
      commonPrint.log('Failed to calculate core SHA256: $e');
      return null;
    }
  }

  Future<void> _initDynamicColor() async {
    try {
      corePalette = await DynamicColorPlugin.getCorePalette();
      accentColor =
          await DynamicColorPlugin.getAccentColor() ??
          Color(defaultPrimaryColor);
    } catch (_) {}
  }

  Future<void> init() async {
    packageInfo = await PackageInfo.fromPlatform();
    if (system.isAndroid) {
      _isAndroidTV = await app.isAndroidTV();
    }
    config =
        await preferences.getConfig() ??
        Config(
          themeProps: defaultThemeProps,
          patchClashConfig: system.isAndroid
              ? const ClashConfig(findProcessMode: FindProcessMode.always)
              : defaultClashConfig,
          appSetting: defaultAppSettingProps.copyWith(
            showStartSwitch: _isAndroidTV ?? false,
          ),
        );
    await globalState.migrateOldData(config);
    if (system.isOhos) {
      final tun = config.patchClashConfig.tun;
      if (tun.stack != TunStack.gvisor || tun.mtu != 1480) {
        config = config.copyWith(
          patchClashConfig: config.patchClashConfig.copyWith.tun(
            stack: TunStack.gvisor,
            mtu: 1480,
          ),
        );
        await preferences.saveConfig(config);
      }
    }
    final locale =
        utils.getLocaleForString(config.appSetting.locale) ??
        utils.getSystemLocale();
    await AppLocalizations.load(locale);
  }

  bool get isAndroidTV => _isAndroidTV ?? false;

  String get ua => config.patchClashConfig.globalUa ?? packageInfo.ua;

  Future<void> startUpdateTasks([UpdateTasks? tasks]) async {
    if (tasks != null) {
      this.tasks = tasks;
    }
    final token = ++_taskLoopToken;
    timer?.cancel();
    timer = null;
    if (_isExecutingTasks) {
      _needsTaskRestart = true;
      return;
    }
    await _runUpdateLoop(token);
  }

  Future<void> _runUpdateLoop(int token) async {
    if (token != _taskLoopToken) return;
    _isExecutingTasks = true;
    try {
      await executorUpdateTask();
    } finally {
      _isExecutingTasks = false;
    }
    if (_needsTaskRestart) {
      _needsTaskRestart = false;
      await _runUpdateLoop(_taskLoopToken);
      return;
    }
    if (token != _taskLoopToken) return;
    timer = Timer(const Duration(seconds: 1), () {
      unawaited(_runUpdateLoop(token));
    });
  }

  Future<void> executorUpdateTask() async {
    for (final task in tasks) {
      try {
        await task();
      } catch (e) {
        commonPrint.log('Background task failed: $e');
      }
    }
    timer = null;
  }

  void stopUpdateTasks() {
    _taskLoopToken++;
    _needsTaskRestart = false;
    timer?.cancel();
    timer = null;
  }

  Future<void> handleBackground() async {
    if (system.isDesktop) {
      final isMinimized = await window?.isMinimized ?? false;
      final isVisible = await window?.isVisible ?? true;
      if (!isMinimized && isVisible) {
        return;
      }
      animationEnabled.value = false;
    }
    if (!backgroundMode.value) {
      backgroundMode.value = true;
      _scheduleBackgroundCleanup();
    }
    render?.pause();

    final vpnProps = appController.ref.read(vpnSettingProvider);
    final keepTrafficUpdates =
        (system.isAndroid && vpnProps.networkSpeedNotification) ||
        (system.isMacOS && vpnProps.enableTraySpeed);
    if (!keepTrafficUpdates) {
      stopUpdateTasks();
    }

    dashboardRefreshManager.stop();
  }

  void handleForeground() {
    if (system.isDesktop) {
      animationEnabled.value = true;
    }
    if (!backgroundMode.value) {
      return;
    }
    backgroundMode.value = false;
    _backgroundCleanupTimer?.cancel();
    _backgroundCleanupTimer = null;
    _syncVpnState();
  }

  Future<void> _syncVpnState() async {
    if (!system.isAndroid) return;
    try {
      final actuallyRunning = await service?.getStatus() ?? false;
      final flutterState = appState.runTime != null;

      if (actuallyRunning && !flutterState) {
        await updateStartTime();
        if (startTime != null) {
          appState = appState.copyWith(runTime: 0);
          await startUpdateTasks([appController.updateTraffic]);
        }
      } else if (!actuallyRunning && flutterState) {
        appState = appState.copyWith(runTime: null);
        startTime = null;
      }
    } catch (e) {
      commonPrint.log('Sync VPN state error: $e');
    }
  }

  Future<void> resumeForegroundUpdates() async {
    dashboardRefreshManager.start();
    if (!isStart) {
      return;
    }

    await appController.updateRunTime();
    await appController.updateTraffic();
    await startUpdateTasks([
      appController.updateRunTime,
      appController.updateTraffic,
    ]);
  }

  void _scheduleBackgroundCleanup() {
    _backgroundCleanupTimer?.cancel();
    _backgroundCleanupTimer = Timer(const Duration(minutes: 3), () {
      _backgroundCleanupTimer = null;
      if (!backgroundMode.value) {
        return;
      }
      cleanupBackgroundResources();
    });
  }

  void cleanupBackgroundResources() async {
    if (!backgroundMode.value) return;

    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.clearLiveImages();

    await Future.delayed(const Duration(milliseconds: 250));
    if (!backgroundMode.value) return;
    WidgetsBinding.instance.handleMemoryPressure();

    await Future.delayed(const Duration(milliseconds: 250));
    if (!backgroundMode.value) return;
    await clashCore.requestGc();
  }

  Future<void> handleStart([
    UpdateTasks? tasks,
    bool includeVpnService = true,
  ]) async {
    if (system.isAndroid && isService) {
      await clashLibHandler?.startListener();
    } else {
      await clashCore.startListener();
    }
    final vpnService = service;
    if (includeVpnService && vpnService != null) {
      final started = await vpnService.startVpn();
      if (started != true) {
        throw StateError('VPN service failed to start');
      }
    }
    startTime ??= DateTime.now();
    final prefs = await preferences.sharedPreferencesCompleter.future;
    await prefs?.setBool('is_vpn_running', true);

    if (system.isAndroid) {
      await service?.setQuickResponse(config.vpnProps.quickResponse);
    }
    await startUpdateTasks(tasks);
  }

  Future updateStartTime() async {
    startTime = await clashLib?.getRunTime();
  }

  void updateWakelockState(bool enabled) {
    if (_appController != null) {
      final container = _appController!.context;
      if (container.mounted) {
        final providerContainer = flutter_riverpod.ProviderScope.containerOf(
          container,
          listen: false,
        );
        providerContainer
                .read(providers_state.wakelockStateProvider.notifier)
                .state =
            enabled;
      }
    }
  }

  Future handleStop([bool includeVpnService = true]) async {
    startTime = null;
    if (system.isAndroid && isService) {
      await clashLibHandler?.stopListener();
    } else {
      await clashCore.stopListener();
    }
    if (!includeVpnService) {
      stopUpdateTasks();
      return;
    }
    await service?.stopVpn();
    final prefs = await preferences.sharedPreferencesCompleter.future;
    await prefs?.setBool('is_vpn_running', false);
    if (system.isDesktop) {
      await prefs?.setBool('is_tun_running', false);
    }
    stopUpdateTasks();
  }

  Future<bool?> showMessage({
    String? title,
    required InlineSpan message,
    String? confirmText,
    bool cancelable = true,
  }) async {
    return await showCommonDialog<bool>(
      child: Builder(
        builder: (context) {
          return CommonDialog(
            title: title ?? appLocalizations.tip,
            actions: [
              if (cancelable)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(appLocalizations.cancel),
                ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(confirmText ?? appLocalizations.confirm),
              ),
            ],
            child: Container(
              width: 300,
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: SelectableText.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.labelLarge,
                    children: [message],
                  ),
                  style: const TextStyle(overflow: TextOverflow.visible),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<T?> showCommonDialog<T>({
    required Widget child,
    bool dismissible = true,
  }) async {
    final state = navigatorKey.currentState;
    if (state == null) return null;
    final context = state.context;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showGeneralDialog<T>(
      context: context,
      barrierColor: isDark ? const Color(0xCC000000) : const Color(0x99000000),
      barrierDismissible: dismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return RepaintBoundary(
          child: FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: curved.drive(Tween<double>(begin: 0.94, end: 1.0)),
              child: child,
            ),
          ),
        );
      },
    );
  }

  bool _dialogWarmedUp = false;

  void warmupCommonDialog() {
    if (_dialogWarmedUp) return;
    _dialogWarmedUp = true;

    final state = navigatorKey.currentState;
    if (state == null) return;
    final overlayState = state.overlay;
    if (overlayState == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          entry.remove();
          entry.dispose();
        });
        return Offstage(
          offstage: true,
          child: RepaintBoundary(
            child: Material(
              type: MaterialType.transparency,
              child: FadeTransition(
                opacity: const AlwaysStoppedAnimation(1.0),
                child: ScaleTransition(
                  scale: const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(blurRadius: 10, color: Colors.black12),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline),
                        SizedBox(height: 8),
                        Text('warmup'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(entry);
  }

  void showNotifier(
    String text, {
    VoidCallback? onAction,
    String? actionLabel,
    bool showCountdown = false,
  }) {
    if (text.isEmpty) return;
    navigatorKey.currentContext?.showNotifier(
      text,
      onAction: onAction,
      actionLabel: actionLabel,
      showCountdown: showCountdown,
    );
  }

  Future<void> openUrl(String url, {bool needConfirm = false}) async {
    if (needConfirm) {
      final res = await showMessage(
        message: TextSpan(text: url),
        title: appLocalizations.externalLink,
        confirmText: appLocalizations.go,
      );
      if (res != true) {
        return;
      }
    }
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> migrateOldData(Config config) async {
    final clashConfig = await preferences.getClashConfig();
    if (clashConfig != null) {
      config = config.copyWith(patchClashConfig: clashConfig);
      preferences.clearClashConfig();
      preferences.saveConfig(config);
    }

    if (config.appSetting.locale == null) {
      final systemLocale = utils.getSystemLocale();
      config = config.copyWith(
        appSetting: config.appSetting.copyWith(locale: systemLocale.toString()),
      );
      preferences.saveConfig(config);
      this.config = config;
    }
  }

  CoreState getCoreState() {
    final currentProfile = config.currentProfile;
    return CoreState(
      vpnProps: config.vpnProps,
      onlyStatisticsProxy: config.appSetting.onlyStatisticsProxy,
      currentProfileName: currentProfile?.label ?? currentProfile?.id ?? '',
      bypassDomain: config.networkProps.bypassDomain,
    );
  }

  Future<SetupParams> getSetupParams({required ClashConfig pathConfig}) async {
    final clashConfig = await patchRawConfig(patchConfig: pathConfig);
    final params = SetupParams(
      config: clashConfig,
      selectedMap: config.currentProfile?.selectedMap ?? {},
      testUrl: config.appSetting.testUrl,
      overrideTestUrl: config.overrideTestUrl,
    );
    return params;
  }

  Future<Map<String, dynamic>> patchRawConfig({
    required ClashConfig patchConfig,
    Profile? profile,
  }) async {
    final targetProfile = profile ?? config.currentProfile;
    if (targetProfile == null) {
      return {};
    }
    final profileId = targetProfile.id;
    final configMap = await getProfileConfig(profileId);
    final rawConfig = await handleEvaluate(configMap, profile: targetProfile);
    final originalProxyGroups = rawConfig['proxy-groups'];

    final platformPatchConfig = system.isOhos
        ? patchConfig.copyWith.tun(stack: TunStack.gvisor, mtu: 1480)
        : patchConfig;
    final realPatchConfig = platformPatchConfig.copyWith(
      dns: patchConfig.dns.copyWith(
        fakeIpRangeV6: patchConfig.dns.effectiveFakeIpRangeV6(
          ipv6Enabled: patchConfig.ipv6,
        ),
      ),
      tun: patchConfig.tun.getRealTun(
        config.networkProps.bypassPrivateRoute,
        fakeIpRange: patchConfig.dns.fakeIpRange,
        fakeIpRangeV6: patchConfig.dns.effectiveFakeIpRangeV6(
          ipv6Enabled: patchConfig.ipv6,
        ),
        bypassPrivateRouteAddress:
            config.networkProps.realBypassPrivateRouteAddress,
      ),
    );
    rawConfig['external-controller'] = realPatchConfig.allowLan
        ? realPatchConfig.externalController.value.replaceAll(
            '127.0.0.1',
            '0.0.0.0',
          )
        : realPatchConfig.externalController.value;
    if (realPatchConfig.externalController == ExternalControllerStatus.open) {
      final secret = realPatchConfig.secret;
      if (secret != null && secret.isNotEmpty) {
        rawConfig['secret'] = secret;
      }
    }
    rawConfig['external-ui'] = await appPath.uiPath;
    rawConfig['external-ui-url'] =
        'https://github.com/Zephyruso/zashboard/releases/latest/download/dist.zip';
    rawConfig.remove('external-ui-name');
    if (rawConfig['interface-name'] == null) {
      rawConfig['interface-name'] = '';
    }
    rawConfig['tcp-concurrent'] = realPatchConfig.tcpConcurrent;
    rawConfig['unified-delay'] = realPatchConfig.unifiedDelay;
    rawConfig['ipv6'] = realPatchConfig.ipv6;
    rawConfig['log-level'] = realPatchConfig.logLevel.name;
    rawConfig['port'] = 0;
    rawConfig['socks-port'] = 0;
    rawConfig['keep-alive-interval'] = realPatchConfig.keepAliveInterval;
    rawConfig['mixed-port'] = realPatchConfig.mixedPort;
    rawConfig['port'] = realPatchConfig.port;
    rawConfig['socks-port'] = realPatchConfig.socksPort;
    rawConfig['redir-port'] = realPatchConfig.redirPort;
    rawConfig['tproxy-port'] = realPatchConfig.tproxyPort;
    rawConfig['find-process-mode'] = realPatchConfig.findProcessMode.name;
    rawConfig['allow-lan'] = realPatchConfig.allowLan;
    rawConfig['mode'] = realPatchConfig.mode.name;
    if (rawConfig['tun'] == null) {
      rawConfig['tun'] = {};
    }
    rawConfig['tun']['enable'] = realPatchConfig.tun.enable;
    rawConfig['tun']['device'] = realPatchConfig.tun.device;
    final dnsHijack = realPatchConfig.tun.dnsHijack;
    rawConfig['tun']['dns-hijack'] = dnsHijack.isEmpty
        ? const ['any:53']
        : dnsHijack;
    rawConfig['tun']['stack'] = realPatchConfig.tun.stack.name;
    rawConfig['tun']['route-address'] = realPatchConfig.tun.routeAddress;
    rawConfig['tun']['route-exclude-address'] =
        realPatchConfig.tun.routeExcludeAddress;
    rawConfig['tun']['auto-route'] = !system.isAndroid;
    rawConfig['tun']['auto-detect-interface'] = !system.isAndroid;
    rawConfig['tun']['strict-route'] = realPatchConfig.tun.strictRoute;
    rawConfig['tun']['endpoint-independent-nat'] =
        realPatchConfig.tun.endpointIndependentNat;
    rawConfig['tun']['disable-icmp-forwarding'] =
        realPatchConfig.tun.disableIcmpForwarding;
    rawConfig['tun']['mtu'] = realPatchConfig.tun.mtu;
    rawConfig['geodata-loader'] = realPatchConfig.geodataLoader.name;
    rawConfig['geodata-mode'] = false;
    if (rawConfig['sniffer']?['sniff'] != null) {
      for (final value in (rawConfig['sniffer']?['sniff'] as Map).values) {
        if (value['ports'] != null && value['ports'] is List) {
          value['ports'] =
              value['ports']?.map((item) => item.toString()).toList() ?? [];
        }
      }
    }
    if (rawConfig['profile'] == null) {
      rawConfig['profile'] = {};
    }
    if (rawConfig['proxy-providers'] != null) {
      final proxyProviders = rawConfig['proxy-providers'] as Map;
      for (final key in proxyProviders.keys) {
        final proxyProvider = proxyProviders[key];
        if (proxyProvider['type'] != 'http') {
          continue;
        }
        if (proxyProvider['url'] != null) {
          proxyProvider['path'] = await appPath.getProvidersFilePath(
            targetProfile.id,
            'proxies',
            proxyProvider['url'],
          );
        }
      }
    }

    if (rawConfig['rule-providers'] != null) {
      final ruleProviders = rawConfig['rule-providers'] as Map;
      for (final key in ruleProviders.keys) {
        final ruleProvider = ruleProviders[key];
        if (ruleProvider['type'] != 'http') {
          continue;
        }
        if (ruleProvider['url'] != null) {
          ruleProvider['path'] = await appPath.getProvidersFilePath(
            targetProfile.id,
            'rules',
            ruleProvider['url'],
          );
        }
      }
    }

    if (rawConfig['profile']['store-selected'] == null) {
      rawConfig['profile']['store-selected'] = true;
    }
    if (rawConfig['profile']['store-fake-ip'] == null) {
      rawConfig['profile']['store-fake-ip'] = true;
    }
    rawConfig['geox-url'] = realPatchConfig.geoXUrl.toJson();
    rawConfig['global-ua'] = realPatchConfig.globalUa;
    if (rawConfig['hosts'] == null) {
      rawConfig['hosts'] = {};
    }
    for (final host in realPatchConfig.hosts.entries) {
      rawConfig['hosts'][host.key] = host.value.splitByMultipleSeparators;
    }

    rawConfig['hosts']['dns.msftncsi.com'] = [
      '131.107.255.255',
      'fd3e:4f5a:5b81::1',
    ];

    if (rawConfig['dns'] == null) {
      rawConfig['dns'] = {};
    }
    final isEnableDns = rawConfig['dns']['enable'] == true;
    final overrideDns = globalState.config.overrideDns;
    if (overrideDns || !isEnableDns) {
      final originalDns = rawConfig['dns'] is Map
          ? (rawConfig['dns'] as Map).cast<String, dynamic>()
          : null;
      final originalHosts = rawConfig['hosts'] is Map
          ? (rawConfig['hosts'] as Map).cast<String, dynamic>()
          : null;
      final dns = switch (!isEnableDns) {
        true => realPatchConfig.dns.copyWith(
          nameserver: [...realPatchConfig.dns.nameserver, 'system://'],
        ),
        false => realPatchConfig.dns,
      };
      rawConfig['dns'] = dns.toJson();
      rawConfig['dns']['nameserver-policy'] = {};
      for (final entry in dns.nameserverPolicy.entries) {
        rawConfig['dns']['nameserver-policy'][entry.key] =
            entry.value.splitByMultipleSeparators;
      }
      applyDnsNodeOverride(
        rawConfig,
        originalDns: originalDns,
        originalHosts: originalHosts,
      );
    }

    if (rawConfig['dns'] != null &&
        rawConfig['dns']['fallback-filter'] != null) {
      if (rawConfig['dns']['fallback-filter'] is Map) {
        (rawConfig['dns']['fallback-filter'] as Map).remove('geosite');
      }
    }

    if (system.isAndroid && rawConfig['dns']['listen'] != null) {
      final listen = rawConfig['dns']['listen'] as String;
      if (listen.endsWith(':53')) {
        rawConfig['dns']['listen'] = listen.replaceAll(':53', ':10053');
      }
      final noProviders =
          rawConfig['proxy-providers'] == null &&
          rawConfig['rule-providers'] == null;
      final proxyServerNameserver = rawConfig['dns']['proxy-server-nameserver'];
      final hasLocalProxyServerNameserver = switch (proxyServerNameserver) {
        List list => list.any((e) => e.toString().startsWith('127.0.0.1')),
        String str => str.startsWith('127.0.0.1'),
        _ => false,
      };
      if (noProviders &&
          hasLocalProxyServerNameserver &&
          listen.startsWith('0.0.0.0')) {
        rawConfig['dns']['listen'] =
            '127.0.0.1${listen.substring('0.0.0.0'.length)}';
      }
    }

    if (rawConfig['ntp'] == null) {
      rawConfig['ntp'] = {};
    }
    final overrideNtp = globalState.config.overrideNtp;
    if (overrideNtp) {
      final ntp = realPatchConfig.ntp;
      rawConfig['ntp'] = ntp.toJson();
    }
    if (system.isAndroid) {
      rawConfig['ntp']['write-to-system'] = false;
    }
    if (rawConfig['sniffer'] == null) {
      rawConfig['sniffer'] = {};
    }
    final overrideSniffer = globalState.config.overrideSniffer;
    if (overrideSniffer) {
      final sniffer = realPatchConfig.sniffer;
      rawConfig['sniffer'] = sniffer.toJson();
    }
    final guiTunnels = realPatchConfig.tunnels;
    if (guiTunnels.isNotEmpty) {
      final existingTunnels = rawConfig['tunnels'] as List? ?? [];
      final allTunnels = [
        ...existingTunnels,
        ...guiTunnels.map((t) => t.toClashJson()),
      ];
      rawConfig['tunnels'] = allTunnels;
    }
    if (rawConfig['experimental'] == null) {
      rawConfig['experimental'] = {};
    }
    final overrideExperimental = globalState.config.overrideExperimental;
    if (overrideExperimental) {
      final experimental = realPatchConfig.experimental;
      rawConfig['experimental'] = experimental.toJson();
    }

    final nodeExcludeFilter = globalState.config.nodeExcludeFilter;
    final healthCheckTimeout = globalState.config.healthCheckTimeout;
    if ((nodeExcludeFilter.isNotEmpty || healthCheckTimeout != 5000) &&
        rawConfig['proxy-groups'] is List) {
      RegExp? filterRegex;
      if (nodeExcludeFilter.isNotEmpty) {
        try {
          filterRegex = RegExp(nodeExcludeFilter);
        } catch (_) {}
      }

      final proxyGroups = rawConfig['proxy-groups'] as List;

      final Set<String> protectedNames = {
        'DIRECT',
        'REJECT',
        'REJECT-DROP',
        'COMPATIBLE',
        'PASS',
      };
      for (final g in proxyGroups) {
        if (g is Map && g['name'] is String) {
          protectedNames.add(g['name'] as String);
        }
      }

      for (final group in proxyGroups) {
        if (group is! Map) continue;

        if (filterRegex != null && group['use'] != null) {
          final existing = group['exclude-filter'];
          if (existing is String && existing.isNotEmpty) {
            group['exclude-filter'] = '$existing|$nodeExcludeFilter';
          } else {
            group['exclude-filter'] = nodeExcludeFilter;
          }
        }

        if (filterRegex != null && group['proxies'] is List) {
          final proxiesList = group['proxies'] as List;
          final filtered = proxiesList.where((item) {
            if (item is! String || protectedNames.contains(item)) return true;
            return !filterRegex!.hasMatch(item);
          }).toList();

          if (filtered.isEmpty &&
              (group['use'] == null ||
                  (group['use'] is List && group['use'].isEmpty))) {
            filtered.add('DIRECT');
          }
          group['proxies'] = filtered;
        }

        if (healthCheckTimeout != 5000) {
          group['timeout'] ??= healthCheckTimeout;
        }
      }

      if (filterRegex != null && rawConfig['proxy-providers'] is Map) {
        final proxyProviders = rawConfig['proxy-providers'] as Map;
        for (final provider in proxyProviders.values) {
          if (provider is! Map) continue;
          final existing = provider['exclude-filter'];
          if (existing is String && existing.isNotEmpty) {
            provider['exclude-filter'] = '$existing|$nodeExcludeFilter';
          } else {
            provider['exclude-filter'] = nodeExcludeFilter;
          }
        }
      }
    }

    if (rawConfig['proxy-groups'] is List) {
      final proxyGroups = rawConfig['proxy-groups'] as List;
      for (final group in proxyGroups) {
        if (group is! Map) continue;
        final tolerance = group['tolerance'];
        if (tolerance != null) {
          if (tolerance is double) {
            group['tolerance'] = tolerance.toInt();
          } else if (tolerance is String) {
            group['tolerance'] = int.tryParse(tolerance) ?? tolerance;
          }
        }
      }
    }

    var rules = [];
    if (rawConfig['rules'] != null) {
      rules = rawConfig['rules'];
      rawConfig.remove('rules');
    } else if (rawConfig['rule'] != null) {
      rules = rawConfig['rule'];
      rawConfig.remove('rule');
    }

    final scriptActive =
        config.scriptProps.currentScript != null &&
        targetProfile.useScriptOverride;

    final overrideData = targetProfile.overrideData;
    if (overrideData.enable && !scriptActive) {
      if (overrideData.rule.type == OverrideRuleType.override) {
        rules = overrideData.runningRule;
      } else {
        rules = [...overrideData.runningRule, ...rules];
      }
    }

    if (config.vpnProps.disableQuic) {
      final isRussian =
          config.appSetting.locale?.toLowerCase().startsWith('ru') ?? false;
      final quicRules = config.vpnProps.excludeChina && !isRussian
          ? [
              'AND,((NETWORK,UDP),(DST-PORT,443),(NOT,((OR,((GEOSITE,geolocation-cn),(GEOIP,CN,no-resolve)))))),REJECT',
            ]
          : ['AND,((NETWORK,UDP),(DST-PORT,443)),REJECT'];
      rules = [...quicRules, ...rules];
    }

    if (rawConfig['proxy-groups'] == null && originalProxyGroups != null) {
      rawConfig['proxy-groups'] = originalProxyGroups;
    }

    final globalClientFingerprint = rawConfig['global-client-fingerprint'];
    if (rawConfig['proxies'] is List) {
      final proxiesList = rawConfig['proxies'] as List;
      for (final proxy in proxiesList) {
        if (proxy is! Map) continue;

        final type = proxy['type']?.toString().toLowerCase();
        final isTls = proxy['tls'] == true;

        bool supportClientFingerprint = false;
        if (type == 'trojan' || type == 'anytls') {
          supportClientFingerprint = true;
        } else if ((type == 'vmess' || type == 'vless') && isTls) {
          supportClientFingerprint = true;
        }

        if (supportClientFingerprint) {
          if (globalClientFingerprint != null &&
              proxy['client-fingerprint'] == null) {
            proxy['client-fingerprint'] = globalClientFingerprint;
          }
        }

        final realityOpts = proxy['reality-opts'];
        if (realityOpts is Map) {
          final shortId = realityOpts['short-id'];
          if (shortId is num) {
            realityOpts['short-id'] = shortId.toString();
          }
        }
      }
    }

    if (targetProfile.groupSwitches.isNotEmpty &&
        !scriptActive &&
        rawConfig['proxy-groups'] is List) {
      final disabledGroups = targetProfile.groupSwitches.entries
          .where((e) => !e.value)
          .map((e) => e.key)
          .toSet();
      if (disabledGroups.isNotEmpty) {
        final proxyGroups = rawConfig['proxy-groups'] as List;
        proxyGroups.removeWhere((g) {
          if (g is Map && g['name'] is String) {
            return disabledGroups.contains(g['name']);
          }
          return false;
        });
        for (int i = 0; i < rules.length; i++) {
          if (rules[i] is String) {
            final parsed = ParsedRule.parseString(rules[i] as String);
            if (parsed.ruleTarget != null &&
                disabledGroups.contains(parsed.ruleTarget)) {
              rules[i] = parsed.copyWith(ruleTarget: 'PASS').value;
            }
          }
        }
      }
    }

    rawConfig['rule'] = rules;
    return rawConfig;
  }

  Future<Map<String, dynamic>> getProfileConfig(String profileId) async {
    final profile = config.profiles.getProfile(profileId);
    final ageSecretKey = profile?.ageSecretKey;
    final configMap = await switch (clashLibHandler != null) {
      true => clashLibHandler!.getConfig(profileId, ageSecretKey: ageSecretKey),
      false => clashCore.getConfig(profileId, ageSecretKey: ageSecretKey),
    };
    configMap['rules'] = configMap['rule'];
    configMap.remove('rule');
    return configMap;
  }

  Future<Map<String, dynamic>> handleEvaluate(
    Map<String, dynamic> config, {
    Profile? profile,
  }) async {
    return _scriptEvaluateLock.synchronized(() async {
      final currentScript = globalState.config.scriptProps.currentScript;
      if (currentScript == null) return config;

      if (profile != null && !profile.useScriptOverride) return config;

      config['proxy-providers'] ??= {};

      try {
        return await JavaScriptRuntimeManager.evaluateScript(
          currentScript.content,
          config,
          customOptions: currentScript.customOptions,
        );
      } catch (e) {
        commonPrint.log('Script execution failed: $e');
        globalState.showNotifier(
          '${appLocalizations.profileParseErrorDesc}: $e',
        );
        return config;
      }
    });
  }
}

class DashboardRefreshManager {
  Timer? _timer;
  bool _isRunning = false;
  int _counter = 0;
  int _tickToken = 0;

  final tick1s = ValueNotifier<int>(0);
  final tick2s = ValueNotifier<int>(0);
  final tick5s = ValueNotifier<int>(0);

  bool get isRunning => _isRunning;

  Future<bool> _isActive() async {
    if (system.isDesktop) {
      final isPinned = globalState.config.windowProps.isPinned;
      if (isPinned) return true;
      final visible = await window?.isVisible;
      if (visible == false) {
        return false;
      }
      final minimized = await window?.isMinimized ?? false;
      if (minimized) {
        return false;
      }
      return true;
    }

    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    if (lifecycleState != null && lifecycleState != AppLifecycleState.resumed) {
      return false;
    }
    return true;
  }

  Future<void> _tryTick(int token) async {
    if (!await _isActive()) {
      return;
    }
    if (token != _tickToken) return;
    _counter++;
    tick1s.value++;
    if (_counter % 2 == 0) {
      tick2s.value++;
    }
    if (_counter % 5 == 0) {
      tick5s.value++;
    }
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tryTick(_tickToken);
    });
  }

  void stop() {
    if (!_isRunning) return;
    _tickToken++;
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }
}

final dashboardRefreshManager = DashboardRefreshManager();

final globalState = GlobalState();

class DetectionState {
  static DetectionState? _instance;
  bool? _preIsStart;
  int _requestId = 0;
  CancelToken? _cancelToken;
  bool _isIpMasked = false;
  IpInfo? _rawIpInfo;
  bool _isFirstLaunch = true;

  final state = ValueNotifier<NetworkDetectionState>(
    const NetworkDetectionState(
      isLoading: true,
      ipInfo: null,
      errorMessage: null,
    ),
  );

  DetectionState._internal();

  factory DetectionState() {
    _instance ??= DetectionState._internal();
    return _instance!;
  }

  bool get isIpMasked => _isIpMasked;

  IpInfo? _maskIpInfo(IpInfo? ipInfo) {
    if (ipInfo == null) return null;
    return _isIpMasked ? ipInfo.copyWith(ip: '*** *** *** ***') : ipInfo;
  }

  void toggleIpPrivacy() {
    _isIpMasked = !_isIpMasked;
    if (_rawIpInfo != null) {
      state.value = state.value.copyWith(ipInfo: _maskIpInfo(_rawIpInfo));
    }
  }

  void manualRefresh() {
    _rawIpInfo = null;
    state.value = state.value.copyWith(
      isLoading: true,
      ipInfo: null,
      errorMessage: null,
    );
    startCheck(immediate: true);
  }

  Future<void> switchToDomesticIp() async {
    _rawIpInfo = null;

    _cancelPreviousRequest();
    _cancelToken = CancelToken();
    final requestId = ++_requestId;

    state.value = state.value.copyWith(
      isLoading: true,
      ipInfo: null,
      errorMessage: null,
    );

    final res = await request.checkIpDomestic(cancelToken: _cancelToken);

    if (requestId != _requestId) return;

    _handleResponse(res);
  }

  void startCheck({bool immediate = false}) {
    final appState = globalState.appState;
    if (!appState.isInit) return;

    final delay = immediate
        ? Duration.zero
        : const Duration(milliseconds: 1000);

    debouncer.call(FunctionTag.checkIp, _checkIp, duration: delay);
  }

  void tryStartCheck() {
    if (!state.value.isLoading &&
        state.value.ipInfo == null &&
        (_preIsStart == null || state.value.errorMessage != null)) {
      startCheck();
    }
  }

  void _cancelPreviousRequest() {
    _cancelToken?.cancel();
    _cancelToken = null;
  }

  void _handleResponse(Result<IpInfo?> res) {
    if (res.isError) {
      if (res.message == 'cancelled') {
        state.value = state.value.copyWith(
          isLoading: false,
          ipInfo: null,
          errorMessage: null,
        );
        return;
      }
      _rawIpInfo = null;
      state.value = state.value.copyWith(
        isLoading: false,
        ipInfo: null,
        errorMessage: appLocalizations.tryManualRefresh,
      );
      return;
    }

    _rawIpInfo = res.data;
    state.value = state.value.copyWith(
      isLoading: false,
      ipInfo: _maskIpInfo(_rawIpInfo),
      errorMessage: _rawIpInfo != null
          ? null
          : appLocalizations.tryManualRefresh,
    );
  }

  Future<void> _checkIp() async {
    final appState = globalState.appState;

    if (!appState.isInit) return;

    final isStart = appState.runTime != null;

    final isStateChanged = _preIsStart != isStart;
    _preIsStart = isStart;

    if (!isStart &&
        _rawIpInfo != null &&
        !state.value.isLoading &&
        !isStateChanged) {
      return;
    }

    _cancelPreviousRequest();
    _cancelToken = CancelToken();
    final requestId = ++_requestId;

    state.value = state.value.copyWith(
      isLoading: true,
      errorMessage: null,
      ipInfo: isStateChanged ? null : _maskIpInfo(_rawIpInfo),
    );

    final timeout = const Duration(seconds: 5);

    final res = isStart
        ? await request.checkIp(cancelToken: _cancelToken, timeout: timeout)
        : await request.checkIpDomestic(
            cancelToken: _cancelToken,
            timeout: timeout,
          );

    if (requestId != _requestId) return;

    if (_isFirstLaunch && (res.isError || res.data == null)) {
      _isFirstLaunch = false;
      _handleResponse(res);

      Future.delayed(const Duration(seconds: 3), () {
        if (state.value.ipInfo == null && !state.value.isLoading) {
          startCheck();
        }
      });
    } else {
      _isFirstLaunch = false;
      _handleResponse(res);
    }
  }
}

final detectionState = DetectionState();
