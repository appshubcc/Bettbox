import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

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
import 'package:bett_box/widgets/sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
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
  bool isScreenOn = true;
  Timer? timer;
  Timer? groupsUpdateTimer;
  Config? _config;

  bool get hasConfig => _config != null;

  Config get config =>
      _config ??
      Config(
        themeProps: defaultThemeProps,
        patchClashConfig: defaultClashConfig,
        networkProps: defaultNetworkProps,
        appSetting: defaultAppSettingProps,
      );

  set config(Config value) => _config = value;
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
  Timer? _backgroundCoreGcTimer;
  Timer? _backgroundCleanupTimer;
  final Lock _scriptEvaluateLock = Lock();
  bool isInit = false;

  bool get hasMediaUnlockWidget {
    final widgets = system.isAndroid
        ? config.appSetting.mobileDashboardWidgets
        : config.appSetting.desktopDashboardWidgets;
    return widgets.contains(DashboardWidget.mediaUnlock) ||
        widgets.contains(DashboardWidget.mediaUnlockSmall);
  }

  bool get hasNetworkDetectionWidget {
    final widgets = system.isAndroid
        ? config.appSetting.mobileDashboardWidgets
        : config.appSetting.desktopDashboardWidgets;
    return widgets.contains(DashboardWidget.networkDetection);
  }

  String getCurrentOutboundNode() {
    final mode = config.patchClashConfig.mode;
    if (mode == Mode.direct) {
      return UsedProxy.DIRECT.name;
    }
    final profile = config.currentProfile;
    final selectedMap = profile?.selectedMap ?? const <String, String>{};
    final groups = appState.groups;
    if (mode == Mode.global) {
      var name = UsedProxy.GLOBAL.name;
      final visited = <String>{};
      while (visited.add(name)) {
        final next = groups.getGroup(name)?.now ?? selectedMap[name];
        if (next == null || next.isEmpty) break;
        name = next;
      }
      return '${profile?.id}|${mode.name}|$name';
    }
    final selected = groups.isEmpty
        ? selectedMap.entries.map((e) => '${e.key}:${e.value}')
        : groups.map((g) => '${g.name}:${g.realNow}');
    return '${profile?.id}|${mode.name}|${selected.join(';')}';
  }

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
    if (system.isLinux && appPath.isAppImage) {
      await appPath.ensureAppImageCoreSynced();
    }
    coreSHA256 = const String.fromEnvironment('CORE_SHA256');
    if (system.isWindows &&
        !kDebugMode &&
        (coreSHA256 == null || coreSHA256!.isEmpty)) {
      coreSHA256 = await _calcCoreSHA256();
    }
    isPre = const String.fromEnvironment('APP_ENV') != 'stable';
    appState = AppState(
      brightness: WidgetsBinding.instance.platformDispatcher.platformBrightness,
      version: version,
      viewSize: Size.zero,
      requests: FixedList(maxLength),
      logs: FixedList(maxLogLength),
      traffics: FixedList(30),
      totalTraffic: Traffic(),
      systemUiOverlayStyle: const SystemUiOverlayStyle(),
    );
    await _initDynamicColor();
    await init();
  }

  Future<String?> getOrCalcCoreSHA256() async {
    if (coreSHA256 != null && coreSHA256!.isNotEmpty) return coreSHA256;
    coreSHA256 = await _calcCoreSHA256();
    return coreSHA256;
  }

  Future<String?> _calcNativeSHA256(String path) async {
    try {
      ProcessResult result;
      if (Platform.isWindows) {
        result = await Process.run('certutil', ['-hashfile', path, 'SHA256']);
      } else if (Platform.isMacOS) {
        result = await Process.run('shasum', ['-a', '256', path]);
      } else if (Platform.isLinux) {
        result = await Process.run('sha256sum', [path]);
      } else {
        return null;
      }

      if (result.exitCode != 0) return null;
      final output = result.stdout.toString();
      final clean = output.replaceAll(' ', '');
      final match = RegExp(r'[0-9a-fA-F]{64}').firstMatch(clean);
      return match?.group(0)?.toLowerCase();
    } catch (_) {
      return null;
    }
  }

  Future<String?> _calcCoreSHA256() async {
    try {
      final path = appPath.corePath;
      final file = File(path);
      if (!await file.exists()) return null;

      final nativeHash = await _calcNativeSHA256(path);
      if (nativeHash != null && nativeHash.isNotEmpty) {
        return nativeHash;
      }

      return await Isolate.run(() async {
        final digest = await sha256.bind(File(path).openRead()).first;
        return digest.toString();
      });
    } catch (e) {
      commonPrint.warn('Failed to calculate core SHA256: $e');
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
    await ManagedScript.loadBundledVersion();
    config =
        await preferences.getConfig() ??
        Config(
          themeProps: defaultThemeProps,
          patchClashConfig: defaultClashConfig,
          networkProps: defaultNetworkProps,
          appSetting: defaultAppSettingProps,
        );
    final scriptProps = await config.scriptProps.externalize();
    if (scriptProps != config.scriptProps) {
      config = config.copyWith(scriptProps: scriptProps);
      await preferences.saveConfig(config);
    }
    await globalState.migrateOldData(config);
    final locale =
        utils.getLocaleForString(config.appSetting.locale) ??
        utils.getSystemLocale();
    await AppLocalizations.load(locale);
  }

  bool get isAndroidTV => _isAndroidTV ?? false;

  @visibleForTesting
  set isAndroidTV(bool value) => _isAndroidTV = value;

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
        commonPrint.warn('Background task failed: $e');
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
      windows?.setBackgroundMemoryPriority(true);
      _scheduleBackgroundCleanup();
    }
    render?.pause();

    if (!_keepBackgroundTrafficUpdates) {
      stopUpdateTasks();
    }

    dashboardRefreshManager.stop();
  }

  bool get _keepBackgroundTrafficUpdates {
    final vpnProps = appController.ref.read(vpnSettingProvider);
    return system.isMacOS && vpnProps.enableTraySpeed;
  }

  Future<void> handleScreenStateChanged(bool isOn) async {
    isScreenOn = isOn;
    if (!backgroundMode.value) return;
    if (!_keepBackgroundTrafficUpdates) {
      stopUpdateTasks();
      return;
    }
    if (!isStart) return;
    await startUpdateTasks([
      appController.updateRunTime,
      appController.updateTraffic,
    ]);
  }

  void handleForeground() {
    isScreenOn = true;
    if (system.isDesktop) {
      animationEnabled.value = true;
    }
    if (!backgroundMode.value) {
      return;
    }
    backgroundMode.value = false;
    windows?.setBackgroundMemoryPriority(false);
    _backgroundCoreGcTimer?.cancel();
    _backgroundCoreGcTimer = null;
    _backgroundCleanupTimer?.cancel();
    _backgroundCleanupTimer = null;
    _syncVpnState();
  }

  Future<void> _syncVpnState() async {
    if (!system.isAndroid) return;
    try {
      final actuallyRunning = await service?.getStatus() ?? false;
      if (!actuallyRunning || isStart) return;
      await updateStartTime();
      if (!isStart) return;
      appController.ref.read(runTimeProvider.notifier).value = 0;
      await startUpdateTasks([
        appController.updateRunTime,
        appController.updateTraffic,
      ]);
    } catch (e) {
      commonPrint.warn('Sync VPN state error: $e');
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
    _backgroundCoreGcTimer?.cancel();
    _backgroundCoreGcTimer = Timer(const Duration(seconds: 30), () {
      _backgroundCoreGcTimer = null;
      if (!backgroundMode.value) {
        return;
      }
      _checkAndRunBackgroundCoreGc();
    });

    _backgroundCleanupTimer?.cancel();
    _backgroundCleanupTimer = Timer(
      Duration(seconds: system.isAndroid ? 180 : 300),
      () {
        _backgroundCleanupTimer = null;
        if (!backgroundMode.value) {
          return;
        }
        cleanupBackgroundResources();
      },
    );
  }

  Future<void> _checkAndRunBackgroundCoreGc() async {
    if (!backgroundMode.value) return;
    try {
      await clashCore.requestGc(forceFreeOSMemory: true, purge: false);
    } catch (e) {
      commonPrint.debug('Background requestGc ignored: $e');
    }
  }

  void cleanupBackgroundResources() async {
    if (!backgroundMode.value) return;

    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.clearLiveImages();

    await Future.delayed(const Duration(milliseconds: 250));
    if (!backgroundMode.value) return;
    WidgetsBinding.instance.handleMemoryPressure();
    if (system.isAndroid) await app.notifyLowMemory();

    await Future.delayed(const Duration(seconds: 3));
    if (!backgroundMode.value) return;
    android?.purgeMemory();
    system.purgeMemory();
    windows?.emptyWorkingSet();
  }

  Future<void> handleStart([
    UpdateTasks? tasks,
    bool includeVpnService = true,
  ]) async {
    startTime ??= DateTime.now();
    if (system.isAndroid && isService) {
      await clashLibHandler?.startListener();
    } else {
      await clashCore.startListener();
    }
    if (includeVpnService) {
      await service?.startVpn();
    }
    final prefs = await preferences.sharedPreferencesCompleter.future;
    await prefs?.setBool('is_vpn_running', true);

    if (system.isAndroid) {
      await service?.setHighPriorityNotification(
        config.vpnProps.highPriorityNotification,
      );
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
              constraints: const BoxConstraints(maxHeight: 240),
              child: SingleChildScrollView(
                child: SelectableText.rich(
                  TextSpan(
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(fontSize: 15, height: 1.5),
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
        final curved = animation.drive(CurveTween(curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: curved.drive(Tween<double>(begin: 0.94, end: 1.0)),
            child: RepaintBoundary(child: child),
          ),
        );
      },
    );
  }

  Future<T?> showAdaptiveSheet<T>({
    required Widget child,
    bool nested = false,
  }) async {
    final context = navigatorKey.currentContext;
    if (context == null) return null;
    if (appState.viewMode != ViewMode.mobile) {
      return await showCommonDialog<T>(child: child);
    }
    return await showSheet<T>(
      context: context,
      props: nested
          ? const SheetProps(expandable: false, initialFraction: 0)
          : const SheetProps(expandable: false),
      builder: (_, _) => child,
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

    final prefs = await preferences.sharedPreferencesCompleter.future;
    if (prefs != null && prefs.containsKey(customDashboardTitleKey)) {
      config = config.copyWith(
        appSetting: config.appSetting.copyWith(
          dashboardTitle:
              prefs.getString(customDashboardTitleKey) ??
              config.appSetting.dashboardTitle,
        ),
      );
      await preferences.saveConfig(config);
      this.config = config;
      await prefs.remove(customDashboardTitleKey);
    }
    await prefs?.remove(customSidebarIconKey);

    final synced = config.managedProps.syncedVersion;
    if (synced != null &&
        ManagedScript.bundledVersion.isNotEmpty &&
        !ManagedScript.isCustom(config.managedProps) &&
        ManagedScript.compareVersions(synced, ManagedScript.bundledVersion) <
            0) {
      await ManagedScript.restore();
      config = config.copyWith(
        managedProps: config.managedProps.copyWith(syncedVersion: null),
      );
      await preferences.saveConfig(config);
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
      trafficStats: TrafficStatsOptions.fromProps(config.trafficStatsProps),
    );
  }

  Future<SetupParams> getSetupParams({required ClashConfig pathConfig}) {
    return buildSetupParams(patchConfig: pathConfig);
  }

  Future<SetupParams> buildSetupParams({
    required ClashConfig patchConfig,
    Profile? profile,
  }) async {
    final targetProfile = profile ?? config.currentProfile;
    final params = SetupParams(
      selectedMap: targetProfile?.selectedMap ?? {},
      testUrl: config.appSetting.testUrl,
    );
    if (targetProfile == null) {
      return params;
    }
    return params.copyWith(
      profilePath: await appPath.getProfilePath(targetProfile.id),
      ageSecretKey: targetProfile.ageSecretKey ?? '',
      scriptedConfig: await _writeScriptedConfig(targetProfile),
      patch: await buildPatchParams(
        patchConfig: patchConfig,
        profile: targetProfile,
      ),
    );
  }

  bool _scriptActive(Profile profile) =>
      profile.runsManagedScript || config.scriptProps.scriptOf(profile) != null;

  Future<SetupParams?> buildValidateParams(Profile profile) async {
    final currentProfileId = config.currentProfileId;
    if (isService ||
        _scriptActive(profile) ||
        (currentProfileId != null && currentProfileId != profile.id)) {
      return null;
    }
    final patchConfig = config.patchClashConfig;
    return buildSetupParams(
      patchConfig: patchConfig.copyWith.tun(
        enable: patchConfig.tun.enable && appState.realTunEnable,
      ),
      profile: profile,
    );
  }

  Future<String> getRuntimeConfigContent({
    required ClashConfig patchConfig,
    Profile? profile,
  }) async {
    return clashCore.getRuntimeConfig(
      await buildSetupParams(patchConfig: patchConfig, profile: profile),
    );
  }

  Future<String> validatePatchedConfig({
    required ClashConfig patchConfig,
  }) async {
    return await clashCore.validateConfig(
      '',
      setup: await buildSetupParams(patchConfig: patchConfig),
    );
  }

  Future<String> _writeScriptedConfig(Profile profile) async {
    if (!_scriptActive(profile)) return '';
    final managed = profile.runsManagedScript;
    try {
      final script = managed
          ? await ManagedScript.script(config.managedProps)
          : config.scriptProps.scriptOf(profile);
      if (script == null) return '';
      return await writeScriptedConfig(profile, script, managed: managed);
    } catch (e) {
      commonPrint.error('Script execution failed: $e');
      showNotifier('${appLocalizations.profileParseErrorDesc}: $e');
      if (managed && ManagedScript.syncedVersion(config.managedProps) != null) {
        return await writeBundledManagedConfig(profile);
      }
      return '';
    }
  }

  Future<String> writeBundledManagedConfig(Profile profile) async {
    try {
      final fallback = await ManagedScript.script(
        config.managedProps,
        bundled: true,
      );
      return await writeScriptedConfig(profile, fallback, managed: true);
    } catch (e) {
      commonPrint.error('Bundled managed script execution failed: $e');
      return '';
    }
  }

  Future<void> validateScript(Script script, {required bool managed}) async {
    Profile? profile = config.currentProfile;
    if (profile == null || profile.bundle != null || !await profile.check()) {
      profile = null;
      for (final item in config.profiles) {
        if (item.bundle == null && await item.check()) {
          profile = item;
          break;
        }
      }
    }
    if (profile == null) {
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final relayPath = await appPath.relayPath;
      final separator = Platform.pathSeparator;
      final input = File('$relayPath${separator}validate-in-$stamp.json');
      final output = File('$relayPath${separator}validate-out-$stamp.json');
      try {
        await input.parent.create(recursive: true);
        await input.writeAsString(
          '{"proxies":[],"proxy-groups":[],"rules":[]}',
          flush: true,
        );
        await JavaScriptRuntimeManager.evaluateScriptFile(
          scriptContent: await script.readContent(),
          inputPath: input.path,
          outputPath: output.path,
          customOptions: script.customOptions,
        );
      } finally {
        for (final file in [input, output]) {
          if (await file.exists()) {
            try {
              await file.delete();
            } catch (_) {}
          }
        }
      }
      return;
    }
    final scriptedPath = await writeScriptedConfig(
      profile,
      script,
      managed: managed,
      cache: false,
    );
    try {
      final patchConfig = config.patchClashConfig;
      final realPatchConfig = patchConfig.copyWith.tun(
        enable: patchConfig.tun.enable && appState.realTunEnable,
      );
      final setupParams = SetupParams(
        selectedMap: profile.selectedMap,
        testUrl: config.appSetting.testUrl,
        profilePath: await appPath.getProfilePath(profile.id),
        ageSecretKey: profile.ageSecretKey ?? '',
        scriptedConfig: scriptedPath,
        patch: await buildPatchParams(
          patchConfig: realPatchConfig,
          profile: profile,
        ),
      );
      final message = await clashCore.validateConfig('', setup: setupParams);
      if (message.isNotEmpty) {
        throw message;
      }
    } finally {
      final file = File(scriptedPath);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
  }

  Future<String> writeScriptedConfig(
    Profile profile,
    Script script, {
    bool managed = false,
    bool refresh = false,
    bool cache = true,
  }) async {
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final relayPath = await appPath.relayPath;
    final separator = Platform.pathSeparator;
    final file = File('$relayPath${separator}scripted-$stamp.json');
    final stem =
        '$relayPath${separator}cache-${profile.id}${managed ? '-managed' : ''}';
    return _scriptEvaluateLock.synchronized(() async {
      unawaited(_sweepRelay(relayPath));
      final cacheFile = File('$stem.json');
      final cacheKey = File('$stem.key');
      String? content;
      var digest = script.digest;
      var volatile = script.volatile;
      if (digest == null || volatile == null) {
        content = await script.readContent();
        digest = content.toMd5();
        volatile = volatileScriptPattern.hasMatch(content);
      }
      final key = !cache || volatile
          ? null
          : await _scriptedCacheKey(profile, script, digest, managed: managed);
      final exported = File('$relayPath${separator}profile-$stamp.json');
      try {
        if (!refresh &&
            key != null &&
            await cacheFile.exists() &&
            await cacheKey.exists() &&
            await cacheKey.readAsString() == key) {
          await cacheFile.copy(file.path);
          return file.path;
        }
        await _exportProfileConfig(
          profile,
          exported.path,
          managed: managed,
          refresh: refresh,
        );
        await JavaScriptRuntimeManager.evaluateScriptFile(
          scriptContent: content ?? await script.readContent(),
          inputPath: exported.path,
          outputPath: file.path,
          customOptions: script.customOptions,
        );
        if (key != null) {
          if (await cacheKey.exists()) {
            await cacheKey.delete();
          }
          await file.copy(cacheFile.path);
          await cacheKey.writeAsString(key, flush: true);
        }
        return file.path;
      } finally {
        if (await exported.exists()) {
          try {
            await exported.delete();
          } catch (_) {}
        }
      }
    });
  }

  Future<void> _sweepRelay(String relayPath) async {
    final expire = DateTime.now().subtract(const Duration(minutes: 10));
    try {
      await for (final entity in Directory(relayPath).list()) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        if (name.startsWith('cache-')) continue;
        final stamp = _relayStampPattern.firstMatch(name)?.group(1);
        final created = stamp == null
            ? (await entity.stat()).modified
            : DateTime.fromMicrosecondsSinceEpoch(int.parse(stamp));
        if (created.isAfter(expire)) continue;
        await entity.delete();
      }
    } catch (_) {}
  }

  Future<String?> _scriptedCacheKey(
    Profile profile,
    Script script,
    String digest, {
    required bool managed,
  }) async {
    final profileFile = File(await appPath.getProfilePath(profile.id));
    if (!await profileFile.exists()) {
      return null;
    }
    if (managed) {
      final providers = Directory(
        '${await appPath.getProvidersDirPath(profile.id)}${Platform.pathSeparator}proxies',
      );
      if (await providers.exists() && !await providers.list().isEmpty) {
        return null;
      }
    }
    final stat = await profileFile.stat();
    return [
      packageInfo.version,
      packageInfo.buildNumber,
      stat.modified.microsecondsSinceEpoch,
      stat.size,
      profile.ageSecretKey ?? '',
      digest,
      json.encode(script.customOptions ?? const <String, bool>{}),
    ].join('\n').toMd5();
  }

  Future<void> _exportProfileConfig(
    Profile profile,
    String output, {
    required bool managed,
    required bool refresh,
  }) async {
    final providersPath = managed
        ? await appPath.getProvidersDirPath(profile.id)
        : null;
    final handler = clashLibHandler;
    if (handler != null) {
      return handler.exportConfig(
        profile.id,
        output,
        ageSecretKey: profile.ageSecretKey,
        providersPath: providersPath,
      );
    }
    return clashCore.exportConfig(
      profile.id,
      output,
      ageSecretKey: profile.ageSecretKey,
      expandProviders: providersPath != null,
      refresh: refresh,
    );
  }

  Future<Map<String, dynamic>> buildPatchParams({
    required ClashConfig patchConfig,
    required Profile profile,
  }) async {
    final fakeIpRangeV6 = patchConfig.dns.effectiveFakeIpRangeV6(
      ipv6Enabled: patchConfig.ipv6,
    );
    final dns = patchConfig.dns.copyWith(fakeIpRangeV6: fakeIpRangeV6);
    final tun = patchConfig.tun.getRealTun(
      config.networkProps.bypassPrivateRoute,
      fakeIpRange: patchConfig.dns.fakeIpRange,
      fakeIpRangeV6: fakeIpRangeV6,
      bypassPrivateRouteAddress:
          config.networkProps.realBypassPrivateRouteAddress,
    );
    final externalController = patchConfig.externalController;
    final secret = patchConfig.secret;
    final hasSecret = secret != null && secret.isNotEmpty;
    final hasAuthentication = patchConfig.authentication.isNotEmpty;
    final general = <String, dynamic>{
      'external-controller': patchConfig.allowLan && hasSecret
          ? externalController.value.replaceAll('127.0.0.1', '0.0.0.0')
          : externalController.value,
      if (externalController == ExternalControllerStatus.open && hasSecret)
        'secret': secret,
      'external-ui': await appPath.uiPath,
      'external-ui-url':
          'https://github.com/Zephyruso/zashboard/releases/latest/download/dist.zip',
      'external-ui-name': '',
      'tcp-concurrent': patchConfig.tcpConcurrent,
      if (!system.isAndroid && patchConfig.interfaceName.isNotEmpty)
        'interface-name': patchConfig.interfaceName,
      'unified-delay': patchConfig.unifiedDelay,
      'ipv6': patchConfig.ipv6,
      'log-level': patchConfig.logLevel.name,
      'keep-alive-interval': patchConfig.keepAliveInterval,
      'mixed-port': patchConfig.mixedPort,
      'port': patchConfig.port,
      'socks-port': patchConfig.socksPort,
      'redir-port': patchConfig.redirPort,
      'tproxy-port': patchConfig.tproxyPort,
      'find-process-mode': patchConfig.findProcessMode.name,
      'allow-lan': patchConfig.allowLan,
      'authentication': patchConfig.authentication,
      'skip-auth-prefixes':
          hasAuthentication && patchConfig.skipAuthPrefixes.isNotEmpty
          ? patchConfig.skipAuthPrefixes
          : null,
      'mode': patchConfig.mode.name,
      'tun': {
        'enable': tun.enable,
        'device': tun.device,
        if (tun.dnsMode case final dnsMode?) 'dns-mode': dnsMode.name,
        'dns-hijack': tun.dnsHijack,
        'stack': (AppIdentity.isLite ? TunStack.mips : tun.stack).name,
        'route-address': tun.routeAddress,
        'route-exclude-address': tun.routeExcludeAddress,
        'auto-route': !system.isAndroid,
        'auto-detect-interface': !system.isAndroid,
        'auto-redirect': system.isLinux,
        'strict-route': tun.strictRoute,
        'endpoint-independent-nat': tun.endpointIndependentNat,
        'disable-icmp-forwarding': tun.disableIcmpForwarding,
        'mtu': tun.mtu,
      },
      'geodata-loader': 'memconservative',
      'geodata-mode': false,
      'global-ua': patchConfig.globalUa,
    };

    final scriptActive = profile.isManaged || _scriptActive(profile);
    final overrideData = profile.overrideData;
    final listenPorts = patchConfig.listenPorts;

    return {
      'general': general,
      'geox-url': patchConfig.geoXUrl.toJson(),
      'hosts': [
        for (final host in patchConfig.hosts.entries)
          if (system.isAndroid || host.key != 'services.googleapis.cn')
            {'key': host.key, 'value': host.value.splitByMultipleSeparators},
        if (system.isWindows)
          {
            'key': 'dns.msftncsi.com',
            'value': ['131.107.255.255', 'fd3e:4f5a:5b81::1'],
          },
      ],
      'dns': {
        ...dns.toJson(),
        'nameserver-policy': {
          for (final entry in dns.nameserverPolicy.entries)
            entry.key: entry.value.splitByMultipleSeparators,
        },
      },
      'ntp': config.overrideNtp ? patchConfig.ntp.toJson() : null,
      'sniffer': config.overrideSniffer ? patchConfig.sniffer.toJson() : null,
      'experimental': config.overrideExperimental
          ? patchConfig.experimental.toJson()
          : null,
      'tunnels': patchConfig.tunnels.isEmpty
          ? null
          : patchConfig.tunnels.map((item) => item.toClashJson()).toList(),
      'providers-path': await appPath.getProvidersDirPath(profile.id),
      'node-exclude-filter': config.nodeExcludeFilter,
      'health-check-timeout': config.healthCheckTimeout,
      'override-rules': overrideData.enable
          ? {
              'rules': overrideData.runningRule,
            }
          : null,
      'prepend-rules': [
        if (config.vpnProps.loopbackProtection) ...[
          if (listenPorts.isNotEmpty) ...[
            'AND,((DST-PORT,$listenPorts),(IP-CIDR,127.0.0.0/8,no-resolve)),REJECT',
            'AND,((DST-PORT,$listenPorts),(IP-CIDR6,::1/128,no-resolve)),REJECT',
          ],
          if (system.isAndroid)
            'AND,((DST-PORT,853),(IP-CIDR,198.51.100.0/30,no-resolve)),REJECT',
        ],
        if (config.vpnProps.disableQuic && !profile.isManaged)
          'AND,((NETWORK,UDP),(DST-PORT,443)),REJECT',
      ],
      'disabled-groups': scriptActive
          ? const []
          : [
              for (final entry in profile.groupSwitches.entries)
                if (!entry.value) entry.key,
            ],
      'select-global': profile.selectedMap['GLOBAL'] == null,
    };
  }

  Future<Map<String, dynamic>?> _readScriptedSnippet(Profile profile) async {
    final path = await _writeScriptedConfig(profile);
    if (path.isEmpty) return null;
    final file = File(path);
    try {
      return await Isolate.run(() {
        final decoded = json.decode(file.readAsStringSync()) as Map;
        return <String, dynamic>{
          for (final key in _profileSnippetKeys)
            if (decoded.containsKey(key)) key: decoded[key],
        };
      });
    } finally {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  static const _profileSnippetKeys = [
    'proxy-groups',
    'rules',
    'rule-providers',
    'sub-rules',
  ];

  Future<Map<String, dynamic>> getProfileSnippet(
    String profileId, {
    bool effective = false,
  }) async {
    final profile = config.profiles.getProfile(profileId);
    if (effective && profile != null) {
      final scripted = await _readScriptedSnippet(profile);
      if (scripted != null) return scripted;
    }
    final ageSecretKey = profile?.ageSecretKey;
    final disabledGroups = effective && profile != null
        ? [
            for (final entry in profile.groupSwitches.entries)
              if (!entry.value) entry.key,
          ]
        : const <String>[];
    return await switch (clashLibHandler != null) {
      true => clashLibHandler!.getConfig(
        profileId,
        ageSecretKey: ageSecretKey,
        disabledGroups: disabledGroups,
        snippet: true,
      ),
      false => clashCore.getConfig(
        profileId,
        ageSecretKey: ageSecretKey,
        disabledGroups: disabledGroups,
        snippet: true,
      ),
    };
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

  Future<bool> isActive() => _isActive();

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

    if (globalState.appState.pageLabel != PageLabel.dashboard) {
      return false;
    }

    return true;
  }

  void triggerImmediateTick() {
    _tryTick(_tickToken);
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

final _relayStampPattern = RegExp(r'^(?:scripted|profile)-(\d+)\.json$');

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
  String? _lastCheckedOutboundNode;
  String? _pendingCheckKey;
  bool _recheckOnFailure = false;
  bool _pendingInit = false;
  String? _riskIp;
  CancelToken? _riskToken;

  final riskyIp = ValueNotifier<String?>(null);

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
  IpInfo? get rawIpInfo => _rawIpInfo;

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
    _isIpMasked = false;
    _riskIp = null;
    state.value = state.value.copyWith(
      isLoading: true,
      ipInfo: null,
      errorMessage: null,
    );
    startCheck(immediate: true, showLoading: true, force: true);
  }

  void _onIpProgress(int requestId, IpInfo info) {
    if (requestId != _requestId) return;
    _rawIpInfo = info;
    _lastCheckedOutboundNode = globalState.getCurrentOutboundNode();
    state.value = state.value.copyWith(
      isLoading: false,
      ipInfo: _maskIpInfo(_rawIpInfo),
      errorMessage: null,
    );
    _scheduleRiskCheck();
  }

  Future<void> _scheduleRiskCheck() async {
    final ip = _rawIpInfo?.ip;
    if (ip == null || ip == _riskIp) return;
    _riskIp = ip;
    _riskToken?.cancel();
    debouncer.cancel(FunctionTag.checkIpRisk);
    riskyIp.value = null;
    if (!globalState.hasNetworkDetectionWidget ||
        !globalState.config.appSetting.ipRiskAlert ||
        utils.classifyIp(ip) != IpCategory.public) {
      return;
    }
    final cached = await request.readIpRiskCache(ip);
    if (ip != _riskIp) return;
    if (cached != null) {
      _applyRisk(ip, cached);
      return;
    }
    debouncer.call(
      FunctionTag.checkIpRisk,
      _checkRisk,
      args: [ip],
      duration: const Duration(seconds: 2),
    );
  }

  void _applyRisk(String ip, IpRisk? risk) {
    final level = risk?.level;
    riskyIp.value = level != null && level != IpRiskLevel.low ? ip : null;
  }

  void refreshRiskCheck() {
    _riskIp = null;
    _scheduleRiskCheck();
  }

  Future<void> _checkRisk(String ip) async {
    if (!globalState.hasNetworkDetectionWidget ||
        !globalState.config.appSetting.ipRiskAlert) {
      return;
    }
    final token = _riskToken = CancelToken();
    final res = await request
        .queryIpRisk(ip, cancelToken: token)
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            token.cancel();
            return Result.error('timeout');
          },
        );
    if (ip != _riskIp) return;
    _applyRisk(ip, res.data);
  }

  void startCheck({
    bool immediate = false,
    bool showLoading = false,
    bool force = false,
  }) {
    final appState = globalState.appState;
    if (!appState.isInit) {
      _pendingInit = true;
      return;
    }

    state.value = state.value.copyWith(isLoading: true, errorMessage: null);

    final delay = immediate
        ? Duration.zero
        : const Duration(milliseconds: 1000);

    debouncer.call(
      FunctionTag.checkIp,
      () => _checkIp(showLoading: showLoading, force: force),
      duration: delay,
    );
  }

  void flushPendingCheck() {
    if (!_pendingInit) return;
    _pendingInit = false;
    debouncer.call(
      FunctionTag.checkIp,
      _checkIp,
      duration: const Duration(seconds: 2),
    );
  }

  void tryStartCheck() {
    if (!globalState.hasNetworkDetectionWidget) return;
    if (!state.value.isLoading &&
        state.value.ipInfo == null &&
        (_preIsStart == null || state.value.errorMessage != null)) {
      startCheck();
    }
  }

  void checkOnForegroundResume() {
    if (!globalState.hasNetworkDetectionWidget) return;
    final currentNode = globalState.getCurrentOutboundNode();
    if (state.value.ipInfo != null &&
        _lastCheckedOutboundNode == currentNode &&
        state.value.errorMessage == null) {
      return;
    }
    _lastCheckedOutboundNode = currentNode;
    startCheck(showLoading: state.value.ipInfo == null);
  }

  void _cancelPreviousRequest() {
    _cancelToken?.cancel();
    _cancelToken = null;
    _pendingCheckKey = null;
  }

  void _handleResponse(Result<IpInfo?> res) {
    if (res.isError) {
      if (res.message == 'cancelled') {
        state.value = state.value.copyWith(
          isLoading: false,
          errorMessage: null,
        );
        return;
      }
      if (state.value.ipInfo == null) {
        _rawIpInfo = null;
        state.value = state.value.copyWith(
          isLoading: false,
          ipInfo: null,
          errorMessage: appLocalizations.tryManualRefresh,
        );
      } else {
        state.value = state.value.copyWith(isLoading: false);
      }
      return;
    }

    if (res.data != null) {
      _rawIpInfo = res.data;
      _lastCheckedOutboundNode = globalState.getCurrentOutboundNode();
    }
    state.value = state.value.copyWith(
      isLoading: false,
      ipInfo: _maskIpInfo(_rawIpInfo),
      errorMessage: _rawIpInfo != null
          ? null
          : (state.value.ipInfo == null
                ? appLocalizations.tryManualRefresh
                : null),
    );
    _scheduleRiskCheck();
  }

  Future<void> _checkIp({bool showLoading = false, bool force = false}) async {
    final appState = globalState.appState;

    if (!appState.isInit) return;

    final isStart = appState.runTime != null;
    final checkKey = '$isStart|${globalState.getCurrentOutboundNode()}';
    if (!force && _pendingCheckKey == checkKey) {
      _recheckOnFailure = true;
      return;
    }

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
    _pendingCheckKey = checkKey;
    _recheckOnFailure = false;
    final requestId = ++_requestId;

    final shouldShowLoading =
        showLoading || state.value.ipInfo == null || isStateChanged;
    if (shouldShowLoading) {
      _rawIpInfo = null;
      state.value = state.value.copyWith(
        isLoading: true,
        errorMessage: null,
        ipInfo: isStateChanged ? null : state.value.ipInfo,
      );
    }

    final timeout = const Duration(seconds: 8);

    final res = await request.checkIp(
      cancelToken: _cancelToken,
      timeout: timeout,
      onUpdate: (info) => _onIpProgress(requestId, info),
    );

    if (requestId != _requestId) return;
    _pendingCheckKey = null;

    final isFailed = res.isError || res.data == null;
    final isFirstLaunch = _isFirstLaunch;
    _isFirstLaunch = false;
    _handleResponse(res);
    if (!isFailed) return;

    if (_recheckOnFailure) {
      startCheck();
      return;
    }
    if (isFirstLaunch) {
      Future.delayed(const Duration(seconds: 3), () {
        if (state.value.ipInfo == null && !state.value.isLoading) {
          startCheck();
        }
      });
    }
  }
}

final detectionState = DetectionState();

class MediaUnlockStateNotifier {
  static MediaUnlockStateNotifier? _instance;
  final _checker = MediaUnlockChecker();
  int _requestId = 0;
  int _epoch = 0;
  Timer? _nodeChangeTimer;
  static const _nodeChangeDelay = Duration(milliseconds: 800);
  String? _lastCheckedOutboundNode;
  bool? _preIsStart;

  final state = ValueNotifier<MediaUnlockState>(const MediaUnlockState());
  final Set<MediaPlatform> _batchTestingPlatforms = {};

  bool isBatchChecking([Iterable<MediaPlatform>? platforms]) {
    if (state.value.isLoading) return true;
    if (platforms == null) {
      return state.value.testingPlatforms.any(_batchTestingPlatforms.contains);
    }
    return platforms.any(
      (p) =>
          state.value.testingPlatforms.contains(p) &&
          _batchTestingPlatforms.contains(p),
    );
  }

  MediaUnlockStateNotifier._internal();

  factory MediaUnlockStateNotifier() {
    _instance ??= MediaUnlockStateNotifier._internal();
    return _instance!;
  }

  List<MediaPlatform> get pinnedPlatforms {
    final pinned = globalState.config.appSetting.pinnedMediaPlatforms;
    return (pinned.isNotEmpty ? pinned : defaultPinnedMediaPlatforms)
        .take(3)
        .toList();
  }

  void cancelUnattended() {
    if (globalState.hasMediaUnlockWidget) return;
    if (!state.value.isLoading && state.value.testingPlatforms.isEmpty) return;
    _epoch++;
    _requestId++;
    _checker.cancel();
    state.value = state.value.copyWith(isLoading: false);
  }

  void checkSingle(MediaPlatform platform) async {
    final epoch = _epoch;
    _batchTestingPlatforms.remove(platform);
    if (state.value.testingPlatforms.contains(platform)) return;
    final currentTesting = Set<MediaPlatform>.from(state.value.testingPlatforms)
      ..add(platform);
    state.value = state.value.copyWith(testingPlatforms: currentTesting);

    try {
      final res = await _checker
          .checkPlatform(platform)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => MediaUnlockResult(
              platform: platform,
              status: MediaUnlockStatus.failed,
            ),
          );
      if (epoch != _epoch) return;
      final finalMap = Map<MediaPlatform, MediaUnlockResult>.from(
        state.value.results,
      );
      finalMap[platform] = res;
      state.value = state.value.copyWith(
        results: finalMap,
        lastChecked: DateTime.now(),
      );
    } catch (_) {
      if (epoch != _epoch) return;
      final finalMap = Map<MediaPlatform, MediaUnlockResult>.from(
        state.value.results,
      );
      finalMap.putIfAbsent(
        platform,
        () => MediaUnlockResult(
          platform: platform,
          status: MediaUnlockStatus.failed,
        ),
      );
      state.value = state.value.copyWith(
        results: finalMap,
        lastChecked: DateTime.now(),
      );
    } finally {
      final nextTesting = Set<MediaPlatform>.from(state.value.testingPlatforms)
        ..remove(platform);
      state.value = state.value.copyWith(testingPlatforms: nextTesting);
    }
  }

  void checkPlatforms(
    List<MediaPlatform> platforms, {
    bool force = false,
    bool isFullCheck = false,
    bool isBatchCheck = false,
  }) async {
    final isRunning = globalState.appState.runTime != null;
    if (!isRunning && !force) return;

    if (force) {
      _checker.cancel();
    }

    final targetPlatforms = force
        ? platforms.toList()
        : platforms
              .where((p) => !state.value.testingPlatforms.contains(p))
              .toList();
    if (targetPlatforms.isEmpty) return;

    final requestId = ++_requestId;
    if (isBatchCheck) {
      _batchTestingPlatforms.addAll(targetPlatforms);
    }
    final pendingTesting = Set<MediaPlatform>.from(state.value.testingPlatforms)
      ..addAll(targetPlatforms);

    state.value = state.value.copyWith(
      isLoading: isFullCheck ? true : state.value.isLoading,
      testingPlatforms: pendingTesting,
    );

    Timer? throttleTimer;
    final bufferResults = <MediaPlatform, MediaUnlockResult>{};

    void flushUpdates() {
      throttleTimer?.cancel();
      throttleTimer = null;
      if (bufferResults.isEmpty) return;
      final updates = Map<MediaPlatform, MediaUnlockResult>.from(bufferResults);
      bufferResults.clear();
      final nextResults = Map<MediaPlatform, MediaUnlockResult>.from(
        state.value.results,
      )..addAll(updates);
      final nextTesting = Set<MediaPlatform>.from(state.value.testingPlatforms)
        ..removeAll(updates.keys);
      state.value = state.value.copyWith(
        results: nextResults,
        testingPlatforms: nextTesting,
      );
    }

    try {
      final results = await _checker
          .checkAll(
            platforms: targetPlatforms,
            onProgress: (res) {
              if (requestId != _requestId) return;
              bufferResults[res.platform] = res;
              throttleTimer ??= Timer(
                const Duration(milliseconds: 100),
                flushUpdates,
              );
            },
          )
          .timeout(
            Duration(seconds: (targetPlatforms.length / 8).ceil() * 8 + 5),
            onTimeout: () {
              _checker.cancel();
              final timeoutMap = <MediaPlatform, MediaUnlockResult>{};
              for (final p in targetPlatforms) {
                timeoutMap[p] =
                    bufferResults[p] ??
                    state.value.results[p] ??
                    MediaUnlockResult(
                      platform: p,
                      status: MediaUnlockStatus.failed,
                    );
              }
              return timeoutMap;
            },
          );
      if (requestId != _requestId) return;
      flushUpdates();
      final nextResults = Map<MediaPlatform, MediaUnlockResult>.from(
        state.value.results,
      );
      for (final p in targetPlatforms) {
        nextResults[p] =
            results[p] ??
            bufferResults[p] ??
            state.value.results[p] ??
            MediaUnlockResult(platform: p, status: MediaUnlockStatus.failed);
      }
      _lastCheckedOutboundNode = globalState.getCurrentOutboundNode();
      state.value = state.value.copyWith(
        isLoading: isFullCheck ? false : state.value.isLoading,
        results: nextResults,
        lastChecked: DateTime.now(),
      );
    } catch (_) {
      throttleTimer?.cancel();
      if (requestId != _requestId) return;
      flushUpdates();
      final fallbackResults = Map<MediaPlatform, MediaUnlockResult>.from(
        state.value.results,
      );
      for (final p in targetPlatforms) {
        fallbackResults.putIfAbsent(
          p,
          () =>
              MediaUnlockResult(platform: p, status: MediaUnlockStatus.failed),
        );
      }
      _lastCheckedOutboundNode = globalState.getCurrentOutboundNode();
      state.value = state.value.copyWith(
        isLoading: isFullCheck ? false : state.value.isLoading,
        results: fallbackResults,
        lastChecked: DateTime.now(),
      );
    } finally {
      throttleTimer?.cancel();
      _batchTestingPlatforms.removeAll(targetPlatforms);
      final nextTesting = Set<MediaPlatform>.from(state.value.testingPlatforms)
        ..removeAll(targetPlatforms);
      state.value = state.value.copyWith(
        isLoading: (requestId == _requestId && isFullCheck)
            ? false
            : state.value.isLoading,
        testingPlatforms: nextTesting,
      );
    }
  }

  void checkPinned({bool force = false, List<MediaPlatform>? platforms}) {
    checkPlatforms(platforms ?? pinnedPlatforms, force: force);
  }

  void checkAll({bool force = false, List<MediaPlatform>? platforms}) {
    final showMoreStreaming =
        globalState.config.appSetting.mediaUnlockMoreStreamingPlatforms;
    final allAvailable = MediaPlatform.values
        .where((p) => showMoreStreaming || !moreStreamingPlatforms.contains(p))
        .toList();
    final targets = platforms ?? allAvailable;
    final isFull = targets.length >= allAvailable.length;
    checkPlatforms(
      targets,
      force: force,
      isFullCheck: isFull,
      isBatchCheck: true,
    );
  }

  void startCheckOnNodeChange() async {
    final isRunning = globalState.appState.runTime != null;
    if (!isRunning) {
      _preIsStart = false;
      _nodeChangeTimer?.cancel();
      return;
    }
    final isStartup = _preIsStart != true;
    _preIsStart = true;

    if (!globalState.hasMediaUnlockWidget) return;
    if (!globalState.config.appSetting.mediaUnlockRefreshOnNodeChange) return;

    if (isStartup) {
      _nodeChangeTimer?.cancel();
      _checker.cancel();
      final requestId = ++_requestId;

      if (globalState.hasNetworkDetectionWidget) {
        var waited = 0;
        while (detectionState.state.value.isLoading &&
            waited < 6000 &&
            globalState.appState.runTime != null &&
            requestId == _requestId) {
          await Future.delayed(const Duration(milliseconds: 150));
          waited += 150;
        }
      } else {
        await Future.delayed(const Duration(seconds: 2));
      }
      if (requestId != _requestId || globalState.appState.runTime == null) {
        return;
      }
      final nextResults = Map<MediaPlatform, MediaUnlockResult>.from(
        state.value.results,
      );
      for (final p in pinnedPlatforms) {
        nextResults.remove(p);
      }
      state.value = state.value.copyWith(
        results: nextResults,
        testingPlatforms: {},
        isLoading: false,
      );
      _lastCheckedOutboundNode = globalState.getCurrentOutboundNode();
      checkPinned(force: true);
      return;
    }

    _nodeChangeTimer?.cancel();
    _nodeChangeTimer = Timer(_nodeChangeDelay, () {
      if (globalState.appState.runTime == null) return;
      if (globalState.backgroundMode.value) return;

      final currentNode = globalState.getCurrentOutboundNode();
      if (_lastCheckedOutboundNode == currentNode &&
          state.value.results.isNotEmpty) {
        return;
      }
      _lastCheckedOutboundNode = currentNode;
      final nextResults = Map<MediaPlatform, MediaUnlockResult>.from(
        state.value.results,
      );
      for (final p in pinnedPlatforms) {
        nextResults.remove(p);
      }
      state.value = state.value.copyWith(
        results: nextResults,
        testingPlatforms: {},
        isLoading: false,
      );
      checkPinned(force: true);
    });
  }

  void checkOnForegroundResume() {
    final isRunning = globalState.appState.runTime != null;
    if (!isRunning) return;
    if (!globalState.hasMediaUnlockWidget) return;
    if (!globalState.config.appSetting.mediaUnlockRefreshOnNodeChange) return;
    if (state.value.isLoading || state.value.testingPlatforms.isNotEmpty) {
      return;
    }
    final currentNode = globalState.getCurrentOutboundNode();
    if (state.value.results.isNotEmpty &&
        _lastCheckedOutboundNode == currentNode) {
      return;
    }
    _lastCheckedOutboundNode = currentNode;
    final nextResults = Map<MediaPlatform, MediaUnlockResult>.from(
      state.value.results,
    );
    for (final p in pinnedPlatforms) {
      nextResults.remove(p);
    }
    state.value = state.value.copyWith(
      results: nextResults,
      testingPlatforms: {},
      isLoading: false,
    );
    checkPinned(force: true);
  }

  void tryStartCheck() {
    final isRunning = globalState.appState.runTime != null;
    if (!isRunning) return;
    if (!globalState.hasMediaUnlockWidget) return;
    if (state.value.isLoading || state.value.testingPlatforms.isNotEmpty) {
      return;
    }
    if (state.value.results.isNotEmpty) return;
    final needsInitialCheck = pinnedPlatforms.any(
      (p) => !state.value.results.containsKey(p),
    );
    if (!needsInitialCheck) return;
    checkPinned();
  }
}

final mediaUnlockState = MediaUnlockStateNotifier();
