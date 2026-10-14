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
        patchClashConfig: system.isAndroid
            ? const ClashConfig(findProcessMode: FindProcessMode.always)
            : defaultClashConfig,
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
    config =
        await preferences.getConfig() ??
        Config(
          themeProps: defaultThemeProps,
          patchClashConfig: system.isAndroid
              ? const ClashConfig(findProcessMode: FindProcessMode.always)
              : defaultClashConfig,
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
      await service?.setQuickResponse(config.vpnProps.quickResponse);
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
    final params = await buildSetupParams(patchConfig: pathConfig);
    return params.copyWith(
      resetTailscaleDirs: config.tailscaleProps.retiredDirs,
    );
  }

  Future<SetupParams> buildSetupParams({
    required ClashConfig patchConfig,
    Profile? profile,
  }) async {
    final targetProfile = profile ?? config.currentProfile;
    final params = SetupParams(
      selectedMap: targetProfile?.selectedMap ?? {},
      testUrl: config.appSetting.testUrl,
      overrideTestUrl: config.overrideTestUrl,
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

  Future<SetupParams?> buildValidateParams(Profile profile) async {
    final currentProfileId = config.currentProfileId;
    final scriptActive =
        config.scriptProps.currentScript != null && profile.useScriptOverride;
    if (isService ||
        scriptActive ||
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
    if (config.scriptProps.currentScript == null ||
        !profile.useScriptOverride) {
      return '';
    }
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final relayPath = await appPath.relayPath;
    final separator = Platform.pathSeparator;
    final file = File('$relayPath${separator}scripted-$stamp.json');
    return _scriptEvaluateLock.synchronized(() async {
      final currentScript = config.scriptProps.currentScript;
      if (currentScript == null) return '';
      unawaited(_sweepRelay(relayPath));
      final cache = File('$relayPath${separator}cache-${profile.id}.json');
      final cacheKey = File('$relayPath${separator}cache-${profile.id}.key');
      String? content;
      var digest = currentScript.digest;
      var volatile = currentScript.volatile;
      if (digest == null || volatile == null) {
        content = await currentScript.readContent();
        digest = content.toMd5();
        volatile = volatileScriptPattern.hasMatch(content);
      }
      final key = volatile
          ? null
          : await _scriptedCacheKey(profile, currentScript, digest);
      final exported = File('$relayPath${separator}profile-$stamp.json');
      try {
        if (key != null &&
            await cache.exists() &&
            await cacheKey.exists() &&
            await cacheKey.readAsString() == key) {
          await cache.copy(file.path);
          return file.path;
        }
        await _exportProfileConfig(profile, exported.path);
        await JavaScriptRuntimeManager.evaluateScriptFile(
          scriptContent: content ?? await currentScript.readContent(),
          inputPath: exported.path,
          outputPath: file.path,
          customOptions: currentScript.customOptions,
        );
        if (key != null) {
          if (await cacheKey.exists()) {
            await cacheKey.delete();
          }
          await file.copy(cache.path);
          await cacheKey.writeAsString(key, flush: true);
        }
        return file.path;
      } catch (e) {
        commonPrint.error('Script execution failed: $e');
        showNotifier('${appLocalizations.profileParseErrorDesc}: $e');
        return '';
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
        if (entity is! File ||
            entity.uri.pathSegments.last.startsWith('cache-') ||
            (await entity.stat()).modified.isAfter(expire)) {
          continue;
        }
        await entity.delete();
      }
    } catch (_) {}
  }

  Future<String?> _scriptedCacheKey(
    Profile profile,
    Script script,
    String digest,
  ) async {
    final profileFile = File(await appPath.getProfilePath(profile.id));
    if (!await profileFile.exists()) {
      return null;
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

  Future<void> _exportProfileConfig(Profile profile, String output) async {
    final handler = clashLibHandler;
    if (handler != null) {
      return handler.exportConfig(
        profile.id,
        output,
        ageSecretKey: profile.ageSecretKey,
      );
    }
    return clashCore.exportConfig(
      profile.id,
      output,
      ageSecretKey: profile.ageSecretKey,
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
      forceRouteAddress: config.tailscaleProps.tunRouteCidrs,
    );
    final externalController = patchConfig.externalController;
    final secret = patchConfig.secret;
    final hasAuthentication = patchConfig.authentication.isNotEmpty;
    final general = <String, dynamic>{
      'external-controller': patchConfig.allowLan
          ? externalController.value.replaceAll('127.0.0.1', '0.0.0.0')
          : externalController.value,
      if (externalController == ExternalControllerStatus.open &&
          secret != null &&
          secret.isNotEmpty)
        'secret': secret,
      'external-ui': await appPath.uiPath,
      'external-ui-url':
          'https://github.com/Zephyruso/zashboard/releases/latest/download/dist.zip',
      'external-ui-name': '',
      'tcp-concurrent': patchConfig.tcpConcurrent,
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
        'dns-hijack': tun.dnsHijack.isEmpty ? const ['any:53'] : tun.dnsHijack,
        'stack': tun.stack.name,
        'congestion-controller': tun.congestionController.name,
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

    final scriptActive =
        config.scriptProps.currentScript != null && profile.useScriptOverride;
    final overrideData = profile.overrideData;
    final isRussian =
        config.appSetting.locale?.toLowerCase().startsWith('ru') ?? false;
    final isChinese =
        config.appSetting.locale?.toLowerCase().startsWith('zh') ?? false;
    final listenPorts = patchConfig.listenPorts;

    return {
      'general': general,
      'geox-url': patchConfig.geoXUrl.toJson(),
      'hosts': [
        for (final host in patchConfig.hosts.entries)
          if (system.isAndroid || host.key != 'services.googleapis.cn')
            {'key': host.key, 'value': host.value.splitByMultipleSeparators},
        {
          'key': 'dns.msftncsi.com',
          'value': ['131.107.255.255', 'fd3e:4f5a:5b81::1'],
        },
      ],
      'override-dns': config.overrideDns,
      'dns-node-override': isChinese,
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
              'override': overrideData.rule.type == OverrideRuleType.override,
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
        if (config.vpnProps.disableQuic)
          config.vpnProps.excludeChina && !isRussian
              ? 'AND,((NETWORK,UDP),(DST-PORT,443),(NOT,((OR,((GEOSITE,geolocation-cn),(GEOIP,CN,no-resolve)))))),REJECT'
              : 'AND,((NETWORK,UDP),(DST-PORT,443)),REJECT',
      ],
      'disabled-groups': scriptActive
          ? const []
          : [
              for (final entry in profile.groupSwitches.entries)
                if (!entry.value) entry.key,
            ],
      'select-global': profile.selectedMap['GLOBAL'] == null,
      'tailscale': _buildTailscalePatch(),
    };
  }

  /// The running Tailscale network's proxy, and the rules and DNS policy
  /// sending its entries to it. They target [tailscaleProxyName]; the core
  /// renames the proxy if the profile already uses that name.
  Map<String, dynamic>? _buildTailscalePatch() {
    final tailscale = config.tailscaleProps.runningNetwork;
    if (tailscale == null) return null;
    const name = tailscaleProxyName;
    // tsnet resolves its control server through mihomo DNS and must reach
    // it directly; keep it off a routed `+.domain`.
    final host = Uri.tryParse(tailscale.controlUrl)?.host ?? '';
    final controlHost = host.isNotEmpty ? host : 'controlplane.tailscale.com';
    final selfResolve = tailscaleRoutesCover([
      ...tailscale.routes,
      ...tailscaleDnsDomains(tailscale.dns),
    ], controlHost);
    return {
      'proxy': {
        'type': 'tailscale',
        'hostname': tailscale.hostname.isNotEmpty
            ? tailscale.hostname
            : 'bettbox',
        if (tailscale.authKey.isNotEmpty) 'auth-key': tailscale.authKey,
        if (tailscale.controlUrl.isNotEmpty)
          'control-url': tailscale.controlUrl,
        'state-dir': tailscale.stateDir,
        'udp': tailscale.udp,
        'accept-routes': tailscale.acceptRoutes,
        if (tailscale.exitNode.isNotEmpty) ...{
          'exit-node': tailscale.exitNode,
          'exit-node-allow-lan-access': tailscale.exitNodeAllowLanAccess,
        },
      },
      'rules': tailscaleRules(
        tailscale.routes,
        name,
        dns: tailscale.dns,
        except: selfResolve ? controlHost : null,
      ),
      'nameserver-policy': tailscaleNameserverPolicy(
        tailscale.routes,
        name,
        dns: tailscale.dns,
        udp: tailscale.udp,
      ),
      // Sniffed domains would otherwise clear DstIP and miss the IP rules.
      'skip-dst-address': tailscaleRouteCidrs(tailscale.routes),
      if (selfResolve) 'control-host': controlHost,
      'dns-domains': tailscaleDnsDomains(tailscale.dns),
    };
  }

  Future<Map<String, dynamic>?> _readScriptedConfig(Profile profile) async {
    final path = await _writeScriptedConfig(profile);
    if (path.isEmpty) return null;
    final file = File(path);
    try {
      final content = await file.readAsString();
      return await Isolate.run(
        () => Map<String, dynamic>.from(json.decode(content) as Map),
      );
    } finally {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<Map<String, dynamic>> getProfileConfig(
    String profileId, {
    bool effective = false,
  }) async {
    final profile = config.profiles.getProfile(profileId);
    if (effective && profile != null) {
      final scripted = await _readScriptedConfig(profile);
      if (scripted != null) return scripted;
    }
    final ageSecretKey = profile?.ageSecretKey;
    final disabledGroups = effective && profile != null
        ? [
            for (final entry in profile.groupSwitches.entries)
              if (!entry.value) entry.key,
          ]
        : const <String>[];
    final configMap = await switch (clashLibHandler != null) {
      true => clashLibHandler!.getConfig(
        profileId,
        ageSecretKey: ageSecretKey,
        disabledGroups: disabledGroups,
      ),
      false => clashCore.getConfig(
        profileId,
        ageSecretKey: ageSecretKey,
        disabledGroups: disabledGroups,
      ),
    };
    configMap['rules'] = configMap['rule'];
    configMap.remove('rule');
    return configMap;
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
  }

  Future<void> switchToDomesticIp() async {
    _rawIpInfo = null;
    _isIpMasked = false;

    _cancelPreviousRequest();
    _cancelToken = CancelToken();
    final requestId = ++_requestId;

    state.value = state.value.copyWith(
      isLoading: true,
      ipInfo: null,
      errorMessage: null,
    );

    final res = await request.checkIpDomestic(
      cancelToken: _cancelToken,
      onUpdate: (info) => _onIpProgress(requestId, info),
    );

    if (requestId != _requestId) return;

    _handleResponse(res);
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

    final res = isStart
        ? await request.checkIp(
            cancelToken: _cancelToken,
            timeout: timeout,
            onUpdate: (info) => _onIpProgress(requestId, info),
          )
        : await request.checkIpDomestic(
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

  void checkSingle(MediaPlatform platform) async {
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
      final finalMap = Map<MediaPlatform, MediaUnlockResult>.from(
        state.value.results,
      );
      finalMap[platform] = res;
      state.value = state.value.copyWith(
        results: finalMap,
        lastChecked: DateTime.now(),
      );
    } catch (_) {
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
