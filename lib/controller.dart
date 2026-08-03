import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/helper/helper.dart';

import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/plugins/service.dart' as vpn_service;
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tray_manager/tray_manager.dart';

import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:yaml/yaml.dart';

import 'common/common.dart';
import 'common/flclash_database_extractor.dart';
import 'models/models.dart';
import 'views/profiles/override_profile.dart';

@visibleForTesting
Future<bool> runMacOSTunStartup({
  required Future<Result<bool>> Function() requestAdmin,
  required Future<void> Function() restartCore,
  required Future<void> Function() applyTunConfig,
  required Future<void> Function() startListener,
  required Future<void> Function() stopListener,
}) async {
  final result = await requestAdmin();
  if (result.isError) {
    return false;
  }

  if (result.needRestart) {
    await restartCore();
  }

  await startListener();
  try {
    await applyTunConfig();
  } catch (error, stackTrace) {
    try {
      await stopListener();
    } catch (_) {}
    Error.throwWithStackTrace(error, stackTrace);
  }

  return true;
}

@visibleForTesting
Future<void> rebuildMacOSTunListener({
  required Future<void> Function() disableTun,
  required Future<void> Function() stopListener,
  required Future<void> Function() repairNetwork,
  required Future<void> Function() startListener,
  required Future<void> Function() enableTun,
  bool Function()? shouldResume,
}) async {
  var tunTemporarilyDisabled = false;
  var listenerStopped = false;
  try {
    await disableTun();
    tunTemporarilyDisabled = true;
    await stopListener();
    listenerStopped = true;
    await repairNetwork();
  } finally {
    if (shouldResume?.call() ?? true) {
      if (listenerStopped) {
        try {
          await startListener();
        } finally {
          if (tunTemporarilyDisabled) {
            await enableTun();
          }
        }
      } else if (tunTemporarilyDisabled) {
        await enableTun();
      }
    }
  }
}

class AppController {
  int? lastProfileModified;

  final BuildContext context;
  final WidgetRef _ref;
  WidgetRef get ref => _ref;

  Timer? _wakelockSyncTimer;
  Completer<void>? _exitLock;
  final Lock _coreLifecycleLock = Lock(reentrant: true);
  int _backgroundLoadVersion = 0;

  int _updateGroupsRetryCount = 0;
  bool _isUpdatingGroups = false;
  Timer? _updateGroupsRetryTimer;
  int _coreGeneration = 0;
  int _setupGeneration = 0;
  int _macOSNetworkRecoveryGeneration = 0;

  AppController(this.context, WidgetRef ref) : _ref = ref;

  DateTime _lastModeChangeTime = DateTime.fromMillisecondsSinceEpoch(0);

  void setupClashConfigDebounce() {
    debouncer.call(FunctionTag.setupClashConfig, () async {
      await safeRun(() async {
        await setupClashConfig();
      }, needLoading: true);
    });
  }

  void updateClashConfigDebounce() {
    debouncer.call(FunctionTag.updateClashConfig, () async {
      await updateClashConfig();
    });
  }

  void updateGroupsDebounce() {
    debouncer.call(FunctionTag.updateGroups, updateGroups);
  }

  void addCheckIpNumDebounce() {
    debouncer.call(FunctionTag.addCheckIpNum, () {
      _ref.read(checkIpNumProvider.notifier).add();
    });
  }

  void addCheckIp() {
    _ref.read(checkIpNumProvider.notifier).add();
  }

  void applyProfileDebounce({bool silence = false}) {
    debouncer.call(FunctionTag.applyProfile, (silence) {
      applyProfile(silence: silence);
    }, args: [silence]);
  }

  void savePreferencesDebounce() {
    debouncer.call(FunctionTag.savePreferences, savePreferences);
  }

  void changeProxyDebounce(String groupName, String proxyName) {
    debouncer.call(FunctionTag.changeProxy, (
      String groupName,
      String proxyName,
    ) async {
      await changeProxy(groupName: groupName, proxyName: proxyName);
      await updateGroups();
      addCheckIp();
    }, args: [groupName, proxyName]);
  }

  void _invalidateCoreReads() {
    _coreGeneration++;
    _backgroundLoadVersion++;
    _updateGroupsRetryTimer?.cancel();
    _updateGroupsRetryTimer = null;
    _updateGroupsRetryCount = 0;
  }

  Future<void> restartCore() {
    return _coreLifecycleLock.synchronized(() async {
      _ref.read(isRestartingCoreProvider.notifier).state = true;
      try {
        await _restartCore();
      } catch (err) {
        _reportCoreRestartFailure(err);
        rethrow;
      } finally {
        _ref.read(isRestartingCoreProvider.notifier).state = false;
      }
    });
  }

  Future<void> _restartCore({
    bool setupConfig = true,
    bool refreshData = true,
  }) async {
    commonPrint.log('restart core');
    _invalidateCoreReads();

    final wasRunning = _ref.read(runTimeProvider.notifier).isStart;
    final keepVpnService = system.isAndroid;
    if (wasRunning) {
      await globalState.handleStop(!keepVpnService);
      _ref.read(runTimeProvider.notifier).value = null;
    }
    if (system.isAndroid) {
      await clashCore.closeConnections();
      await clashCore.flushFakeIP();
      await clashCore.flushDnsCache();
      await clashCore.requestGc(forceFreeOSMemory: true);
    }
    if (system.isDesktop) {
      lastProfileModified = null;
      await clashService!.reStart();
    }
    await _initCore();

    final configured = setupConfig ? await _setupCoreConfig() : false;
    if (refreshData && configured) {
      await updateGroups();
      await updateProviders();
    }

    if (wasRunning) {
      await globalState.handleStart([
        updateRunTime,
        updateTraffic,
      ], !keepVpnService);
      _scheduleCheckIpRefresh();
      _backgroundLoad();
    }
  }

  Future<void> updateStatus(bool isStart) {
    if (system.isMacOS && !isStart) {
      _macOSNetworkRecoveryGeneration++;
    }
    return _coreLifecycleLock.synchronized(() => _updateStatus(isStart));
  }

  Future<bool> handleMacOSNetworkChange(
    MacOSNetworkState networkState, {
    bool Function()? isCancelled,
  }) {
    if (!system.isMacOS) return Future.value(false);

    final recoveryGeneration = _macOSNetworkRecoveryGeneration;

    bool recoveryCancelled() {
      return recoveryGeneration != _macOSNetworkRecoveryGeneration ||
          isCancelled?.call() == true;
    }

    return _coreLifecycleLock.synchronized(() async {
      if (recoveryCancelled()) return false;

      final isStart = _ref.read(runTimeProvider.notifier).isStart;
      final dnsState = _ref.read(autoSetSystemDnsStateProvider);
      final shouldSetSystemDns = dnsState.a && dnsState.b;
      final shouldRestartTunListener = isStart && dnsState.a;

      Future<void> repairNetwork() async {
        if (recoveryCancelled()) return;

        if (isStart) {
          await clashCore.closeConnections();
        }
        if (recoveryCancelled()) return;

        await macOS?.updateDns(
          !shouldSetSystemDns,
          serviceName: networkState.serviceName,
        );

        if (!isStart || recoveryCancelled()) return;

        await clashCore.flushDnsCache();
        if (recoveryCancelled()) return;
        await clashCore.flushFakeIP();
      }

      if (!shouldRestartTunListener) {
        await repairNetwork();
        return !recoveryCancelled();
      }

      commonPrint.log('Rebuilding macOS TUN after network change');
      await rebuildMacOSTunListener(
        disableTun: () => _applyCoreTunConfig(false, persist: false),
        stopListener: clashCore.stopListener,
        repairNetwork: repairNetwork,
        startListener: clashCore.startListener,
        enableTun: _updateClashConfig,
        shouldResume: () => !recoveryCancelled(),
      );
      return !recoveryCancelled();
    });
  }

  Future<void> _updateStatus(bool isStart) async {
    if (isStart) {
      await _fastStart();
    } else {
      await globalState.handleStop();
      clashCore.resetTraffic();
      _ref.read(trafficsProvider.notifier).clear();
      _ref.read(totalTrafficProvider.notifier).value = Traffic();
      _ref.read(runTimeProvider.notifier).value = null;
      addCheckIpNumDebounce();
    }
  }

  Future<void> _fastStart() async {
    final currentProfile = _ref.read(currentProfileProvider);
    if (currentProfile == null) {
      commonPrint.log('Fast start aborted: No active profile configured.');
      return;
    }

    final patchConfig = _ref.read(patchClashConfigProvider);
    final isDesktop = system.isDesktop;

    if (isDesktop && patchConfig.tun.enable) {
      final setupResult = await _quickSetupConfig(enableTun: false);
      if (system.isMacOS && setupResult != true) {
        commonPrint.log('Fast start aborted: initial TUN setup failed');
        return;
      }

      if (system.isMacOS) {
        try {
          final started = await runMacOSTunStartup(
            requestAdmin: () => _requestAdmin(true),
            restartCore: restartCore,
            applyTunConfig: _updateClashConfig,
            startListener: clashCore.startListener,
            stopListener: clashCore.stopListener,
          );
          if (!started) {
            commonPrint.log(
              'Fast start aborted: macOS TUN authorization failed',
            );
            return;
          }
          await globalState.handleStartWithActiveListener([
            updateRunTime,
            updateTraffic,
          ]);
          await updateProviders();
          _backgroundLoad();
        } catch (e) {
          commonPrint.log('FastStart macOS TUN startup failed: $e');
          rethrow;
        }
        _scheduleCheckIpRefresh();
        return;
      }

      await globalState.handleStart([updateRunTime, updateTraffic]);
      await updateProviders();

      Future.microtask(() async {
        try {
          final res = await _requestAdmin(true);
          if (res.needRestart) {
            await restartCore();
            return;
          }
          if (!res.isError) {
            await _updateClashConfig();
          }
        } catch (e) {
          commonPrint.log('FastStart update config failed: $e');
        }
        _backgroundLoad();
      });

      _scheduleCheckIpRefresh();
      return;
    }

    final needReapply = await _needsSetupConfig();
    if (needReapply) {
      final setupResult = await _quickSetupConfig();
      if (setupResult != true) {
        commonPrint.log('Fast start aborted: setupConfig failed');
        return;
      }
    }

    await globalState.handleStart([updateRunTime, updateTraffic]);

    _scheduleCheckIpRefresh();

    await updateProviders();
    _backgroundLoad();
  }

  void _scheduleCheckIpRefresh() {
    Future.delayed(const Duration(seconds: 1), () {
      addCheckIpNumDebounce();
    });
  }

  void _backgroundLoad() {
    final version = ++_backgroundLoadVersion;
    final generation = _coreGeneration;

    Future.microtask(() async {
      try {
        List<Group> groups = [];
        for (var attempt = 0; attempt < 3; attempt++) {
          if (version != _backgroundLoadVersion) return;
          if (generation != _coreGeneration) return;
          if (attempt > 0) {
            await Future.delayed(Duration(milliseconds: 200 * attempt));
          }
          groups = await clashCore.getProxiesGroups();
          if (groups.isNotEmpty) break;
        }
        if (version != _backgroundLoadVersion) return;
        if (generation != _coreGeneration) return;

        if (groups.isNotEmpty) {
          _ref.read(groupsProvider.notifier).value = groups;
        }

        await Future.delayed(const Duration(seconds: 2));
        if (version != _backgroundLoadVersion) return;
        await clashCore.requestGc();
      } catch (e) {
        commonPrint.log('Background load error: $e');
      }
    });
  }

  Future<bool> _checkIfNeedReapply() async {
    final currentLastModified = await _ref
        .read(currentProfileProvider)
        ?.profileLastModified;
    if (currentLastModified != null &&
        lastProfileModified != null &&
        currentLastModified <= lastProfileModified!) {
      return false;
    }
    return true;
  }

  Future<bool> _needsSetupConfig() async {
    if (_setupGeneration != _coreGeneration) {
      return true;
    }
    return _checkIfNeedReapply();
  }

  Future<bool> _setupCoreConfig({bool? enableTun}) async {
    final currentProfile = _ref.read(currentProfileProvider);
    if (currentProfile == null) {
      return false;
    }
    await currentProfile.checkAndUpdate();
    final patchConfig = _ref.read(patchClashConfigProvider);
    final targetTun = enableTun ?? patchConfig.tun.enable;

    final realTunEnable = await _prepareTun(targetTun);
    if (realTunEnable == null) return false;

    final realPatchConfig = patchConfig.copyWith.tun(enable: realTunEnable);
    final params = await globalState.getSetupParams(
      pathConfig: realPatchConfig,
    );
    final message = await clashCore.setupConfig(params);
    if (message.isNotEmpty) {
      commonPrint.log('[Core] Setup config failed: $message');
      throw message;
    }
    if (system.isDesktop) {
      final prefs = await preferences.sharedPreferencesCompleter.future;
      await prefs?.setBool('is_tun_running', realTunEnable);
    }
    lastProfileModified = await _ref.read(
      currentProfileProvider.select((state) => state?.profileLastModified),
    );
    _setupGeneration = _coreGeneration;
    return true;
  }

  Future<bool?> _quickSetupConfig({bool? enableTun}) async {
    return await safeRun(() async {
      return await _setupCoreConfig(enableTun: enableTun);
    }, needLoading: false);
  }

  Future<void> updateRunTime() async {
    if (globalState.backgroundMode.value) return;
    final startTime = globalState.startTime;
    if (startTime == null) {
      if (_ref.read(runTimeProvider) != null) {
        _ref.read(runTimeProvider.notifier).value = null;
      }
      return;
    }

    final startTimeStamp = startTime.millisecondsSinceEpoch;
    final nowTimeStamp = DateTime.now().millisecondsSinceEpoch;
    final elapsed = nowTimeStamp - startTimeStamp;

    final current = _ref.read(runTimeProvider);
    if (current == null) {
      _ref.read(runTimeProvider.notifier).value = elapsed;
      return;
    }
    _ref.read(runTimeProvider.notifier).value = elapsed;
  }

  Future<bool> _shouldUpdateDashboardTick() async {
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    final isPinned = system.isDesktop &&
        _ref.read(windowSettingProvider.select((s) => s.isPinned));
    if (!isPinned && lifecycleState != AppLifecycleState.resumed) return false;

    if (system.isDesktop) {
      if (await window?.isVisible == false) return false;
      if (await window?.isMinimized == true) return false;
    }

    return true;
  }

  Future<void> updateTraffic() async {
    _ref.read(totalTrafficProvider.notifier).value = await clashCore
        .getTotalTraffic();

    final shouldUpdateDashboard = await _shouldUpdateDashboardTick();
    final networkSpeedNotification =
        system.isAndroid &&
        _ref.read(vpnSettingProvider).networkSpeedNotification;

    if (!shouldUpdateDashboard && !networkSpeedNotification) {
      return;
    }

    if (networkSpeedNotification &&
        !shouldUpdateDashboard &&
        !globalState.appState.isScreenOn) {
      return;
    }

    final traffic = await clashCore.getTraffic();

    if (shouldUpdateDashboard) {
      _ref.read(trafficsProvider.notifier).addTraffic(traffic);
    }

    if (networkSpeedNotification) {
      final currentProfileId = _ref.read(currentProfileIdProvider);
      final profiles = _ref.read(profilesProvider);
      final profile = profiles
          .where((e) => e.id == currentProfileId)
          .firstOrNull;
      final profileName = profile?.label ?? 'Bettbox';
      final speedInfo = traffic.toString();
      await vpn_service.service?.updateNotificationSpeed(
        profileName,
        speedInfo,
      );
    }
  }

  Future<void> addProfile(Profile profile) async {
    _ref.read(profilesProvider.notifier).setProfile(profile);
    if (_ref.read(currentProfileIdProvider) != null) return;
    _ref.read(currentProfileIdProvider.notifier).value = profile.id;
  }

  Future<void> deleteProfile(String id) async {
    _ref.read(profilesProvider.notifier).deleteProfileById(id);
    await clearEffect(id);
    if (globalState.config.currentProfileId == id) {
      final profiles = globalState.config.profiles;
      final currentProfileId = _ref.read(currentProfileIdProvider.notifier);
      if (profiles.isNotEmpty) {
        final updateId = profiles.first.id;
        currentProfileId.value = updateId;
      } else {
        currentProfileId.value = null;
        updateStatus(false);
      }
    }
  }

  Future<void> updateProviders() async {
    _ref.read(providersProvider.notifier).value = await clashCore
        .getExternalProviders();
  }

  Future<void> updateLocalIp() async {
    _ref.read(localIpProvider.notifier).value = null;
    await Future.delayed(commonDuration);
    _ref.read(localIpProvider.notifier).value = await utils.getLocalIpAddress();
  }

  Future<void> updateProfile(Profile profile, {bool validate = true}) async {
    final newProfile = await profile.update(validate: validate);
    _ref
        .read(profilesProvider.notifier)
        .setProfile(newProfile.copyWith(isUpdating: false));
    if (profile.id == _ref.read(currentProfileIdProvider)) {
      applyProfileDebounce(silence: true);
    }
  }

  void setProfile(Profile profile) {
    _ref.read(profilesProvider.notifier).setProfile(profile);
  }

  void setProfileAndAutoApply(Profile profile) {
    _ref.read(profilesProvider.notifier).setProfile(profile);
    if (profile.id == _ref.read(currentProfileIdProvider)) {
      applyProfileDebounce(silence: true);
    }
  }

  void setProfiles(List<Profile> profiles) {
    _ref.read(profilesProvider.notifier).value = profiles;
  }

  void addLog(Log log) {
    _ref.read(logsProvider.notifier).addLog(log);
  }

  void updateOrAddHotKeyAction(HotKeyAction hotKeyAction) {
    final hotKeyActions = _ref.read(hotKeyActionsProvider);
    final index = hotKeyActions.indexWhere(
      (item) => item.action == hotKeyAction.action,
    );

    final newList = List.of(hotKeyActions);
    if (index == -1) {
      newList.add(hotKeyAction);
    } else {
      newList[index] = hotKeyAction;
    }

    _ref.read(hotKeyActionsProvider.notifier).value = newList;
  }

  List<Group> getCurrentGroups() {
    return _ref.read(currentGroupsStateProvider.select((state) => state.value));
  }

  String getRealTestUrl(String? url) {
    return _ref.read(getRealTestUrlProvider(url));
  }

  int getProxiesColumns() {
    return _ref.read(getProxiesColumnsProvider);
  }

  dynamic addSortNum() {
    return _ref.read(sortNumProvider.notifier).add();
  }

  String? getCurrentGroupName() {
    final currentGroupName = _ref.read(
      currentProfileProvider.select((state) => state?.currentGroupName),
    );
    return currentGroupName;
  }

  ProxyCardState getProxyCardState(String proxyName) {
    return _ref.read(getProxyCardStateProvider(proxyName));
  }

  String? getSelectedProxyName(String groupName) {
    return _ref.read(getSelectedProxyNameProvider(groupName));
  }

  void updateCurrentGroupName(String groupName) {
    final profile = _ref.read(currentProfileProvider);
    if (profile == null || profile.currentGroupName == groupName) {
      return;
    }
    setProfile(profile.copyWith(currentGroupName: groupName));
  }

  Future<void> updateClashConfig() {
    return _coreLifecycleLock.synchronized(() async {
      await safeRun(() async {
        await _updateClashConfig();
      }, needLoading: true);
    });
  }

  Future<bool?> _prepareTun(bool targetTun) async {
    final res = await _requestAdmin(targetTun);
    if (res.needRestart) {
      await _restartCore(setupConfig: false, refreshData: false);
    } else if (res.isError) {
      return null;
    }
    return res.data ?? _ref.read(realTunEnableProvider);
  }

  Future<void> _updateClashConfig() async {
    final updateParams = _ref.read(updateParamsProvider);
    final tunResult = await _requestAdmin(updateParams.tun.enable);
    if (tunResult.isError) return;

    final bool realTunEnable =
        tunResult.data ?? _ref.read(realTunEnableProvider);
    if (tunResult.needRestart) {
      await _restartCore();
      return;
    }

    await _applyCoreTunConfig(realTunEnable);
  }

  Future<void> _applyCoreTunConfig(bool enable, {bool persist = true}) async {
    final updateParams = _ref.read(updateParamsProvider);
    final message = await clashCore.updateConfig(
      updateParams.copyWith.tun(enable: enable),
    );
    if (message.isNotEmpty) throw message;

    if (persist && system.isDesktop) {
      final prefs = await preferences.sharedPreferencesCompleter.future;
      await prefs?.setBool('is_tun_running', enable);
    }
  }

  Future<Result<bool>> _requestAdmin(bool enableTun) async {
    final realTunEnable = _ref.read(realTunEnableProvider);
    if (enableTun != realTunEnable && realTunEnable == false) {
      final code = await system.authorizeCore();
      switch (code) {
        case AuthorizeCode.success:
          _ref.read(realTunEnableProvider.notifier).value = enableTun;
          return Result.success(enableTun, needRestart: true);
        case AuthorizeCode.none:
          break;
        case AuthorizeCode.error:
          globalState.showNotifier(
            'TUN mode requires administrator privileges.',
          );
          enableTun = false;
          break;
      }
    }
    _ref.read(realTunEnableProvider.notifier).value = enableTun;
    return Result.success(enableTun);
  }

  Future<void> setupClashConfig() {
    return _coreLifecycleLock.synchronized(() async {
      await safeRun(() async {
        await _setupCoreConfig();
      }, needLoading: false);
    });
  }

  Future<void> _applyProfile() async {
    _invalidateCoreReads();
    _ref.read(delayDataSourceProvider.notifier).value = {};
    unawaited(clashCore.requestGc());
    final configured = await _setupCoreConfig();
    if (!configured) return;
    final providers = await clashCore.getExternalProviders();
    _ref.read(providersProvider.notifier).value = providers;
    await updateGroups(preloadedProviders: providers);
  }

  Future<void> applyProfile({bool silence = false}) {
    return _coreLifecycleLock.synchronized(() async {
      if (silence) {
        try {
          await _applyProfile();
        } catch (err) {
          globalState.showNotifier(err.toString());
          rethrow;
        }
      } else {
        await safeRun(() async {
          await _applyProfile();
        }, needLoading: true);
      }
    });
  }

  Future<void> handleChangeProfile({bool hardRestart = false}) {
    return _coreLifecycleLock.synchronized(() async {
      if (hardRestart) {
        _ref.read(isRestartingCoreProvider.notifier).state = true;
        try {
          await _restartCore();
        } catch (err) {
          _reportCoreRestartFailure(err);
          rethrow;
        } finally {
          _ref.read(isRestartingCoreProvider.notifier).state = false;
        }
      } else {
        if (system.isAndroid) {
          clashCore.closeConnections();
          await clashCore.flushFakeIP();
          await clashCore.flushDnsCache();
        }
        final prevProfileId = _ref.read(currentProfileIdProvider);
        try {
          await _applyProfile();
        } catch (err) {
          _ref.read(currentProfileIdProvider.notifier).value = prevProfileId;
          try {
            await _applyProfile();
          } catch (_) {}
          globalState.showNotifier(err.toString());
        }
      }
      _ref.read(logsProvider.notifier).value = FixedList(maxLength);
      _ref.read(requestsProvider.notifier).value = FixedList(maxLength);
      globalState.computeHeightMapCache = {};
      addCheckIpNumDebounce();
    });
  }

  void _reportCoreRestartFailure(Object error) {
    final message = error.formatError;
    commonPrint.log('[Core] Restart failed: $message');
    globalState.showNotifier('${appLocalizations.restartCoreTitle}: $message');
  }

  void updateBrightness() {
    _ref.read(systemBrightnessProvider.notifier).value =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  Future<void> autoUpdateProfiles() async {
    for (final profile in _ref.read(profilesProvider)) {
      if (!profile.autoUpdate) continue;
      final isNotNeedUpdate = profile.lastUpdateDate
          ?.add(profile.autoUpdateDuration)
          .isBeforeNow;
      if (isNotNeedUpdate == false || profile.type == ProfileType.file) {
        continue;
      }
      try {
        await updateProfile(profile, validate: false);
      } catch (e) {
        commonPrint.log(
          '[AutoUpdate] Failed to update ${profile.label ?? profile.id}: ${e.formatError}',
        );
      }
    }
  }

  Future<void> checkAndUpdateMissedProfiles() async {
    final now = DateTime.now();
    final profilesToUpdate = <Profile>[];
    for (final profile in _ref.read(profilesProvider)) {
      if (!profile.autoUpdate) continue;
      if (profile.type == ProfileType.file) continue;
      if (profile.isUpdating) continue;
      final lastUpdate = profile.lastUpdateDate;
      if (lastUpdate == null) continue;
      final expectedNextUpdate = lastUpdate.add(profile.autoUpdateDuration);
      final isOverdue =
          now.difference(expectedNextUpdate) > const Duration(minutes: 1);
      if (isOverdue) {
        profilesToUpdate.add(profile);
      }
    }
    if (profilesToUpdate.isEmpty) return;
    for (final profile in profilesToUpdate) {
      try {
        commonPrint.log(
          '[MissedUpdate] Updating profile: ${profile.label ?? profile.id}',
        );
        await updateProfile(profile, validate: false);
      } catch (e) {
        commonPrint.log(
          '[MissedUpdate] Failed to update ${profile.label ?? profile.id}: ${e.formatError}',
        );
      }
      if (profilesToUpdate.length > 1) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  Future<void> updateGroups({List<ExternalProvider>? preloadedProviders}) {
    return _coreLifecycleLock.synchronized(
      () => _updateGroups(preloadedProviders: preloadedProviders),
    );
  }

  static const List<Duration> _kGroupRetryDelays = [
    Duration.zero,
    Duration(milliseconds: 50),
    Duration(milliseconds: 150),
    Duration(milliseconds: 400),
  ];

  Future<List<Group>> _retryGetProxiesGroups(
    List<ExternalProvider>? preloadedProviders,
  ) async {
    for (var attempt = 0; attempt < _kGroupRetryDelays.length; attempt++) {
      if (attempt > 0) {
        await Future.delayed(_kGroupRetryDelays[attempt]);
      }
      final groups = await clashCore.getProxiesGroups(
        preloadedProviders: preloadedProviders,
      );
      if (groups.isNotEmpty) return groups;
    }
    return [];
  }

  void _handleUpdateGroupsError(int generation, dynamic e) {
    if (generation != _coreGeneration) {
      return;
    }
    final currentGroups = _ref.read(groupsProvider);
    final isInitialLoad = currentGroups.isEmpty;
    final maxRetryRounds = isInitialLoad ? 6 : 4;
    final retryDelay = isInitialLoad
        ? const Duration(seconds: 2)
        : const Duration(seconds: 3);
    if (currentGroups.isNotEmpty) {
      commonPrint.log('updateGroups error: $e');
      return;
    }

    if (_updateGroupsRetryCount >= maxRetryRounds) {
      _updateGroupsRetryCount = 0;
      return;
    }
    _updateGroupsRetryCount++;
    _updateGroupsRetryTimer?.cancel();
    _updateGroupsRetryTimer = Timer(retryDelay, () {
      if (generation != _coreGeneration) return;
      Zone.root.run(() {
        unawaited(updateGroups());
      });
    });
  }

  Future<void> _updateGroups({
    List<ExternalProvider>? preloadedProviders,
  }) async {
    if (_isUpdatingGroups) {
      commonPrint.log('updateGroups already in progress, skipping');
      return;
    }
    _isUpdatingGroups = true;
    final generation = _coreGeneration;

    try {
      final currentGroups = _ref.read(groupsProvider);

      final newGroups = await _retryGetProxiesGroups(preloadedProviders);

      if (newGroups.isEmpty) {
        _handleUpdateGroupsError(
          generation,
          'getProxiesGroups returned empty after inner retries',
        );
        return;
      }

      try {
        final activeMode = await clashCore.getMode();
        final currentMode = _ref.read(patchClashConfigProvider).mode;
        if (activeMode != currentMode) {
          if (DateTime.now().difference(_lastModeChangeTime) >
              const Duration(seconds: 2)) {
            _ref
                .read(patchClashConfigProvider.notifier)
                .updateState((state) => state.copyWith(mode: activeMode));
            if (activeMode == Mode.global) {
              updateCurrentGroupName(GroupName.GLOBAL.name);
            }
            addCheckIpNumDebounce();
          }
        }
      } catch (e) {
        commonPrint.log('Failed to sync active mode: $e');
      }

      final currentProfile = _ref.read(currentProfileProvider);
      if (currentProfile != null) {
        final selectedMap = Map<String, String>.from(
          currentProfile.selectedMap,
        );
        bool hasChanged = false;

        for (final newGroup in newGroups) {
          final oldGroup = currentGroups.firstWhereOrNull(
            (g) => g.name == newGroup.name,
          );
          if (oldGroup != null &&
              newGroup.type == GroupType.Selector &&
              newGroup.now != oldGroup.now) {
            if (selectedMap[newGroup.name] != newGroup.realNow) {
              selectedMap[newGroup.name] = newGroup.realNow;
              hasChanged = true;
            }
          }
        }

        if (hasChanged) {
          _ref
              .read(profilesProvider.notifier)
              .setProfile(currentProfile.copyWith(selectedMap: selectedMap));
        }
      }

      _ref.read(groupsProvider.notifier).value = newGroups;
      _updateGroupsRetryCount = 0;
      _updateGroupsRetryTimer?.cancel();
      _updateGroupsRetryTimer = null;
      return;
    } catch (e) {
      _handleUpdateGroupsError(generation, e);
    } finally {
      _isUpdatingGroups = false;
    }
  }

  Future<void> updateProfiles() async {
    for (final profile in _ref.read(profilesProvider)) {
      if (profile.type == ProfileType.file) {
        continue;
      }
      try {
        await updateProfile(profile);
      } catch (e) {
        commonPrint.log(
          '[UpdateProfiles] Failed to update ${profile.label ?? profile.id}: ${e.formatError}',
        );
      }
    }
  }

  Future<void> savePreferences() async {
    await preferences.saveConfig(globalState.config);
  }

  Future<void> changeProxy({
    required String groupName,
    required String proxyName,
  }) async {
    await clashCore.changeProxy(
      ChangeProxyParams(groupName: groupName, proxyName: proxyName),
    );
    if (_ref.read(appSettingProvider).closeConnections) {
      clashCore.closeConnections();
    }
    addCheckIp();
  }

  Future<void> handleBackOrExit() async {
    if (_ref.read(backBlockProvider)) {
      return;
    }
    if (system.isDesktop) {
      await savePreferences();
    }
    await system.back();
  }

  void backBlock() {
    _ref.read(backBlockProvider.notifier).value = true;
  }

  void unBackBlock() {
    _ref.read(backBlockProvider.notifier).value = false;
  }

  Future<void> setProcessPriority(bool enable) async {
    if (!system.isWindows) return;

    try {
      await system.setProcessPriority(
        '${AppIdentity.mainExecutableName}.exe',
        enable,
      );
      await helperClient.setProcessPriority(
        '${AppIdentity.coreExecutableName}.exe',
        enable,
      );
    } catch (e) {
      commonPrint.log('Set process priority error: $e');
      rethrow;
    }
  }

  Future<void> handleExit() async {
    if (_exitLock != null) {
      return _exitLock!.future;
    }

    final exitLock = Completer<void>();
    _exitLock = exitLock;
    globalState.isExiting = true;
    if (system.isMacOS) {
      _macOSNetworkRecoveryGeneration++;
    }

    try {
      if (system.isDesktop) {
        try {
          await trayManager.destroy();
        } catch (e) {
          commonPrint.log('Failed to destroy tray icon on exit: $e');
        }
      }
      stopWakelockAutoRecovery();
      await globalState.handleBackground();
      if (system.isDesktop) {
        final prefs = await preferences.sharedPreferencesCompleter.future;
        await prefs?.setBool('is_tun_running', false);
      }
      await savePreferences();
      if (proxy != null) {
        await proxy!.stopProxy();
      }
      await clashCore.shutdown();
      if (clashService != null) {
        await clashService!.destroy();
      }
    } catch (e) {
      commonPrint.log('handleExit error: $e');
    } finally {
      if (macOS != null) {
        try {
          await macOS!.updateDns(true);
        } catch (e) {
          commonPrint.log('Failed to restore macOS system DNS on exit: $e');
        }
      }
      if (!exitLock.isCompleted) {
        exitLock.complete();
      }
      system.exit();
    }
  }

  Future handleClear() async {
    await preferences.clearPreferences();
    commonPrint.log('clear preferences');
    globalState.config = Config(themeProps: defaultThemeProps);
  }

  Future<void> autoCheckUpdate() async {
    final prefs = await preferences.sharedPreferencesCompleter.future;
    final lastCheckTime = prefs?.getInt('last_check_update_time') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final isAutoCheck = _ref.read(appSettingProvider).autoCheckUpdate;

    final forceCheck =
        (now - lastCheckTime) > const Duration(days: 28).inMilliseconds;

    if (!isAutoCheck && !forceCheck) return;

    final res = await request.checkForUpdate();
    if (res != null) {
      checkUpdateResultHandle(data: res);
    }

    await prefs?.setInt('last_check_update_time', now);
  }

  Future<void> checkUpdateResultHandle({
    Map<String, dynamic>? data,
    bool handleError = false,
  }) async {
    if (globalState.isPre && !handleError) {
      return;
    }
    if (data != null) {
      final tagName = data['tag_name'];
      final body = data['body'];
      final submits = utils.parseReleaseBody(body);
      final textTheme = context.textTheme;
      final res = await globalState.showMessage(
        title: appLocalizations.discoverNewVersion,
        message: TextSpan(
          text: '$tagName \n',
          style: textTheme.headlineSmall,
          children: [
            TextSpan(text: '\n', style: textTheme.bodyMedium),
            for (final submit in submits)
              TextSpan(text: '- $submit \n', style: textTheme.bodyMedium),
          ],
        ),
        confirmText: appLocalizations.goDownload,
      );
      if (res != true) {
        return;
      }
      const String assetSuffix = String.fromEnvironment('APP_ASSET_SUFFIX');
      String downloadUrl = 'https://github.com/$repository/releases/latest';

      if (assetSuffix.isNotEmpty) {
        final versionWithoutV = tagName.startsWith('v')
            ? tagName.substring(1)
            : tagName;
        downloadUrl =
            'https://github.com/$repository/releases/download/$tagName/Bettbox-$versionWithoutV-$assetSuffix';
      }

      globalState.openUrl(downloadUrl);
    } else if (handleError) {
      globalState.showMessage(
        title: appLocalizations.checkUpdate,
        message: TextSpan(text: appLocalizations.checkUpdateError),
        cancelable: false,
      );
    }
  }

  Future<void> _handlePreference() async {
    if (await preferences.isInit) {
      return;
    }
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.cacheCorrupt),
    );
    if (res == true) {
      final file = File(await appPath.sharedPreferencesPath);
      final isExists = await file.exists();
      if (isExists) {
        await file.delete();
      }
    }
    await handleExit();
  }

  Future<void> _initCore() async {
    final isInit = await clashCore.isInit;
    if (!isInit) {
      await clashCore.init();
      await clashCore.setState(globalState.getCoreState());
    }
  }

  void startWakelockAutoRecovery() {
    _wakelockSyncTimer?.cancel();
    _wakelockSyncTimer = Timer.periodic(const Duration(seconds: 168), (
      _,
    ) async {
      try {
        final userEnabled = _ref.read(wakelockStateProvider);

        if (!userEnabled) {
          stopWakelockAutoRecovery();
          return;
        }

        await syncWakelockIfNeeded();
      } catch (_) {}
    });
  }

  void stopWakelockAutoRecovery() {
    _wakelockSyncTimer?.cancel();
    _wakelockSyncTimer = null;
  }

  Future<void> syncWakelockIfNeeded() async {
    final userEnabled = _ref.read(wakelockStateProvider);
    if (!userEnabled) {
      stopWakelockAutoRecovery();
      return;
    }
    final actualState = await WakelockPlus.enabled;
    if (actualState) {
      return;
    }
    await WakelockPlus.enable();
  }

  Future<void> _initHighRefreshRateDefault() async {
    try {
      final androidVersion = await system.version;
      final currentSetting = _ref.read(appSettingProvider);

      final bool shouldEnableHighRefreshRate =
          androidVersion >= 31; // Android 12+

      if (currentSetting.enableHighRefreshRate != shouldEnableHighRefreshRate) {
        _ref
            .read(appSettingProvider.notifier)
            .updateState(
              (state) => state.copyWith(
                enableHighRefreshRate: shouldEnableHighRefreshRate,
              ),
            );
      }
    } catch (e) {
      commonPrint.log('Failed to initialize high refresh rate default: $e');
    }
  }

  Future<void> init() async {
    FlutterError.onError = (details) {
      if (kDebugMode) {
        commonPrint.log(details.stack.toString());
      }
    };

    vpn_service.service?.addNativeEventCallback((method, arguments) async {
      if (method == 'vpnStartFailed') {
        globalState.showNotifier('Failed, Please try again later');
        await updateStatus(false);
      } else if (method == 'runStateChanged') {
        final state = arguments as String?;
        if (state == 'STOP' && globalState.isStart) {
          await updateStatus(false);
        }
      }
    });

    if (system.isAndroid) {
      await _initHighRefreshRateDefault();
    }

    try {
      final wakelockEnabled = await WakelockPlus.enabled;
      _ref.read(wakelockStateProvider.notifier).state = wakelockEnabled;

      if (wakelockEnabled) {
        startWakelockAutoRecovery();
      }
    } catch (e) {
      commonPrint.log('Failed to check wake lock status: $e');
    }

    await updateTray(true);

    await _initCore();
    try {
      await _initStatus();
    } catch (e) {
      commonPrint.log('_initStatus failed, falling back to basic startup: $e');
      try {
        await applyProfile(silence: true);
      } catch (e2) {
        commonPrint.log('Fallback applyProfile also failed: $e2');
      }
    }

    await updateGroups();

    autoLaunch?.updateStatus(_ref.read(appSettingProvider).autoLaunch);
    autoUpdateProfiles();
    autoCheckUpdate();

    final isWindowVisible = await window?.isVisible ?? false;
    if (isWindowVisible) {
      window?.show();
    } else {
      if (!_ref.read(appSettingProvider).silentLaunch) {
        window?.show();
      } else {
        window?.hide();
      }
    }
    await syncDesktopRuntimeState(preferCurrentState: true);
    await updateTray(true);

    await _handlePreference();
    await _handlerDisclaimer();
    if (system.isWindows) {
      unawaited(
        setProcessPriority(
          _ref.read(appSettingProvider).enableHighPriority,
        ).catchError((e) {
          commonPrint.log('Failed to set initial process priority: $e');
        }),
      );
    }
    _ref.read(initProvider.notifier).value = true;
  }

  Future<void> _initStatus() async {
    if (system.isAndroid) {
      await globalState.updateStartTime();
      if (globalState.isStart && _ref.read(runTimeProvider) == null) {
        _ref.read(runTimeProvider.notifier).value = 0;
      }
    } else if (system.isDesktop) {
      await syncDesktopRuntimeState();
    }

    final needRecovery = await _detectAbnormalExit();

    if (needRecovery) {
      commonPrint.log('Abnormal exit detected');
      if (system.isAndroid) {
        try {
          await applyProfile(silence: true);
        } catch (e) {
          commonPrint.log('Recovery failed: $e');
        }
      }
    }
    if (system.isMacOS && !globalState.isStart) {
      await macOS?.updateDns(true);
    }
    final hasProfile = _ref.read(currentProfileProvider) != null;
    final shouldStart =
        hasProfile &&
        (globalState.isStart || _ref.read(appSettingProvider).autoRun);

    if (shouldStart) {
      try {
        await updateStatus(true);
      } catch (e) {
        commonPrint.log('Auto start failed: $e');
        await applyProfile();
        addCheckIpNumDebounce();
      }
    } else {
      await applyProfile();
      addCheckIpNumDebounce();
    }
  }

  Future<void> syncDesktopRuntimeState({
    bool preferCurrentState = false,
  }) async {
    if (!system.isDesktop) return;
    if (!preferCurrentState || !globalState.isStart) {
      await globalState.updateStartTime();
    }

    if (globalState.isStart) {
      if (_ref.read(runTimeProvider) == null) {
        _ref.read(runTimeProvider.notifier).value = 0;
      }
      await globalState.startUpdateTasks([updateTraffic]);
      return;
    }

    if (_ref.read(runTimeProvider) != null) {
      _ref.read(runTimeProvider.notifier).value = null;
    }
    globalState.stopUpdateTasks();
  }

  Future<bool> _detectAbnormalExit() async {
    final prefs = await preferences.sharedPreferencesCompleter.future;

    if (system.isAndroid) {
      final isVpnRunningFlag = prefs?.getBool('is_vpn_running') ?? false;
      return !globalState.isStart && isVpnRunningFlag;
    }

    if (system.isDesktop) {
      final wasTunRunning = prefs?.getBool('is_tun_running') ?? false;
      return !globalState.isStart && wasTunRunning;
    }

    return false;
  }

  void setDelay(Delay delay) {
    _ref.read(delayDataSourceProvider.notifier).setDelay(delay);
  }

  int? getTrayProxyDelay({required String proxyName, String? testUrl}) {
    return _ref.read(getDelayProvider(proxyName: proxyName, testUrl: testUrl));
  }

  void toPage(PageLabel pageLabel) {
    final context = globalState.navigatorKey.currentState?.context;
    if (context != null && context.mounted) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).popUntil((route) => route.isFirst);
    }
    _ref.read(currentPageLabelProvider.notifier).value = pageLabel;
  }

  void toProfiles() {
    toPage(PageLabel.profiles);
  }

  void initLink() {
    linkManager.initAppLinksListen((url) async {
      final res = await globalState.showMessage(
        title: appLocalizations.add,
        message: TextSpan(
          children: [
            TextSpan(text: appLocalizations.doYouWantToPass),
            TextSpan(
              text: ' $url ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            TextSpan(text: appLocalizations.create),
          ],
        ),
      );

      if (res != true) {
        return;
      }
      addProfileFormURL(url);
    });
  }

  Future<bool> showDisclaimer() async {
    return await globalState.showCommonDialog<bool>(
          dismissible: false,
          child: CommonDialog(
            title: appLocalizations.disclaimer,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop<bool>(false);
                },
                child: Text(appLocalizations.exit),
              ),
              TextButton(
                onPressed: () {
                  _ref
                      .read(appSettingProvider.notifier)
                      .updateState(
                        (state) => state.copyWith(disclaimerAccepted: true),
                      );
                  Navigator.of(context).pop<bool>(true);
                },
                child: Text(appLocalizations.agree),
              ),
            ],
            child: SelectableText(appLocalizations.disclaimerDesc),
          ),
        ) ??
        false;
  }

  Future<void> _handlerDisclaimer() async {
    if (_ref.read(appSettingProvider).disclaimerAccepted) {
      return;
    }
    final isDisclaimerAccepted = await showDisclaimer();
    if (!isDisclaimerAccepted) {
      await handleExit();
    }
    return;
  }

  Future<void> addProfileFormURL(String url, {String? ageSecretKey}) async {
    _ref.read(loadingProvider.notifier).value = true;
    try {
      final profile = await Profile.normal(
        url: url,
        ageSecretKey: ageSecretKey,
      ).update();
      if (globalState.navigatorKey.currentState?.canPop() ?? false) {
        globalState.navigatorKey.currentState?.popUntil(
          (route) => route.isFirst,
        );
      }
      toProfiles();
      await addProfile(profile);
    } on Object catch (e) {
      await globalState.showMessage(
        title: appLocalizations.add,
        message: TextSpan(text: _formatErrorMessage(e)),
        cancelable: false,
      );
    } finally {
      _ref.read(loadingProvider.notifier).value = false;
    }
  }

  Future<void> addProfileFormFile() async {
    final platformFiles = await safeRun(
      () => picker.pickerFiles(
        allowMultiple: true,
        allowedExtensions: ['yaml', 'yml'],
      ),
    );
    if (platformFiles == null || platformFiles.isEmpty) {
      return;
    }
    if (!context.mounted) return;

    final validFiles = platformFiles.where((file) {
      final name = file.name.toLowerCase();
      return name.endsWith('.yaml') || name.endsWith('.yml');
    }).toList();

    if (validFiles.isEmpty) {
      return;
    }

    _ref.read(loadingProvider.notifier).value = true;
    int successCount = 0;
    try {
      for (final platformFile in validFiles) {
        final bytes = platformFile.bytes;
        if (bytes == null || bytes.isEmpty) continue;

        try {
          final profile = await Profile.normal(
            label: platformFile.name,
          ).saveFile(bytes);
          await addProfile(profile);
          successCount++;
        } on Object catch (e) {
          if (!context.mounted) break;
          await globalState.showMessage(
            title: '${platformFile.name} (${appLocalizations.add})',
            message: TextSpan(text: _formatErrorMessage(e)),
            cancelable: false,
          );
        }
      }

      if (successCount > 0) {
        globalState.navigatorKey.currentState
            ?.popUntil((route) => route.isFirst);
        toProfiles();
      }
    } finally {
      _ref.read(loadingProvider.notifier).value = false;
    }
  }

  Future<void> addProfileFormQrCode() async {
    final url = await safeRun(picker.pickerConfigQRCode);
    if (url == null) return;
    addProfileFormURL(url);
  }

  void updateViewSize(Size size) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ref.read(viewSizeProvider.notifier).value = size;
    });
  }

  void setProvider(ExternalProvider? provider) {
    _ref.read(providersProvider.notifier).setProvider(provider);
  }

  List<Proxy> _sortOfName(List<Proxy> proxies) {
    return List.of(proxies)..sort(
      (a, b) =>
          utils.sortByChar(utils.getPinyin(a.name), utils.getPinyin(b.name)),
    );
  }

  int _delayValue(int? delay) =>
      (delay == null || delay == -1) ? 1 << 30 : delay;

  List<Proxy> _sortOfDelay({required List<Proxy> proxies, String? testUrl}) {
    return List.of(proxies)..sort((a, b) {
      final aDelay = _ref.read(
        getDelayProvider(proxyName: a.name, testUrl: testUrl),
      );
      final bDelay = _ref.read(
        getDelayProvider(proxyName: b.name, testUrl: testUrl),
      );
      return _delayValue(aDelay).compareTo(_delayValue(bDelay));
    });
  }

  List<Proxy> getSortProxies({
    required List<Proxy> proxies,
    required ProxiesSortType sortType,
    String? testUrl,
  }) {
    return switch (sortType) {
      ProxiesSortType.none => proxies,
      ProxiesSortType.delay => _sortOfDelay(proxies: proxies, testUrl: testUrl),
      ProxiesSortType.name => _sortOfName(proxies),
    };
  }

  Future<void> clearEffect(String profileId) async {
    final profilePath = await appPath.getProfilePath(profileId);
    final providersDirPath = await appPath.getProvidersDirPath(profileId);
    await Isolate.run(() async {
      final profileFile = File(profilePath);
      final isExists = await profileFile.exists();
      if (isExists) {
        await profileFile.delete(recursive: true);
      }
      final providersFileDir = Directory(providersDirPath);
      final providersFileIsExists = await providersFileDir.exists();
      if (providersFileIsExists) {
        await providersFileDir.delete(recursive: true);
      }
    });
  }

  void updateTun() {
    _ref
        .read(patchClashConfigProvider.notifier)
        .updateState((state) => state.copyWith.tun(enable: !state.tun.enable));
    if (system.isLinux && globalState.backgroundMode.value) {
      unawaited(updateClashConfig());
    } else {
      updateClashConfigDebounce();
    }
  }

  void updateSystemProxy() {
    _ref
        .read(networkSettingProvider.notifier)
        .updateState(
          (state) => state.copyWith(systemProxy: !state.systemProxy),
        );
  }

  Future<List<Package>> getPackages({bool forceRefresh = false}) async {
    final cached = _ref.read(packagesProvider);
    if (!forceRefresh && cached.isNotEmpty) return cached;

    final packages = await app.getPackages(forceRefresh: forceRefresh);
    _ref.read(packagesProvider.notifier).value = packages;
    return packages;
  }

  void updateStart() {
    updateStatus(!_ref.read(runTimeProvider.notifier).isStart);
  }

  void updateCurrentSelectedMap(String groupName, String proxyName) {
    final currentProfile = _ref.read(currentProfileProvider);
    if (currentProfile != null &&
        currentProfile.selectedMap[groupName] != proxyName) {
      final SelectedMap selectedMap = Map.from(currentProfile.selectedMap)
        ..[groupName] = proxyName;
      _ref
          .read(profilesProvider.notifier)
          .setProfile(currentProfile.copyWith(selectedMap: selectedMap));
    }
  }

  void updateCurrentUnfoldSet(Set<String> value) {
    final currentProfile = _ref.read(currentProfileProvider);
    if (currentProfile == null) {
      return;
    }
    _ref
        .read(profilesProvider.notifier)
        .setProfile(currentProfile.copyWith(unfoldSet: value));
  }

  void changeMode(Mode mode) {
    _lastModeChangeTime = DateTime.now();
    _ref
        .read(patchClashConfigProvider.notifier)
        .updateState((state) => state.copyWith(mode: mode));
    if (mode == Mode.global) {
      updateCurrentGroupName(GroupName.GLOBAL.name);
    }
    if (system.isLinux && globalState.backgroundMode.value) {
      unawaited(updateClashConfig());
    } else {
      updateClashConfigDebounce();
    }
    updateGroupsDebounce();
    addCheckIpNumDebounce();
  }

  void updateAutoLaunch() {
    _ref
        .read(appSettingProvider.notifier)
        .updateState((state) => state.copyWith(autoLaunch: !state.autoLaunch));
  }

  Future<void> updateVisible() async {
    final visible = await window?.isVisible;
    if (visible != null && !visible) {
      window?.show();
    } else {
      window?.hide();
    }
  }

  void updateMode() {
    _lastModeChangeTime = DateTime.now();
    _ref.read(patchClashConfigProvider.notifier).updateState((state) {
      final index = Mode.values.indexWhere((item) => item == state.mode);
      if (index == -1) {
        return null;
      }
      final nextIndex = index + 1 > Mode.values.length - 1 ? 0 : index + 1;
      return state.copyWith(mode: Mode.values[nextIndex]);
    });
  }

  Future<void> handleAddOrUpdate(WidgetRef ref, [Rule? rule]) async {
    final res = await globalState.showCommonDialog<Rule>(
      child: AddRuleDialog(
        rule: rule,
        snippet: ref.read(
          profileOverrideStateProvider.select((state) => state.snippet!),
        ),
      ),
    );
    if (res == null) {
      return;
    }
    ref.read(profileOverrideStateProvider.notifier).updateState((state) {
      final model = state.copyWith.overrideData!(
        rule: state.overrideData!.rule.updateRules((rules) {
          final index = rules.indexWhere((item) => item.id == res.id);
          if (index == -1) {
            return List.from([res, ...rules]);
          }
          return List.from(rules)..[index] = res;
        }),
      );
      return model;
    });
  }

  Future<bool> exportLogs() async {
    final logsRaw = _ref.read(logsProvider).list.map((item) => item.toString());
    final data = await Isolate.run<List<int>>(() async {
      final logsRawString = logsRaw.join('\n');
      return utf8.encode(logsRawString);
    });
    return await picker.saveFile(utils.logFile, Uint8List.fromList(data)) !=
        null;
  }

  Future<List<int>> backupData() async {
    final homeDirPath = await appPath.homeDirPath;
    final profilesPath = await appPath.profilesPath;
    final configJson = globalState.config.toJson();

    // Get valid profile IDs
    final validProfileIds = globalState.config.profiles
        .map((p) => p.id)
        .toSet();
    final currentProfileId = globalState.config.currentProfileId;

    commonPrint.log(
      'Starting backup: ${validProfileIds.length} profiles, current: $currentProfileId',
    );

    return Isolate.run<List<int>>(() async {
      // Use ZipFileEncoder like FLClash - more reliable than ZipEncoder + Archive
      final tempDir = Directory.systemTemp;
      final tempZipPath = join(
        tempDir.path,
        'bettbox_backup_${DateTime.now().millisecondsSinceEpoch}.zip',
      );
      final encoder = ZipFileEncoder();
      encoder.create(tempZipPath);

      // Add marker file
      final markerData = json.encode({
        'app': 'Bettbox',
        'version': '1.0',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      final markerBytes = utf8.encode(markerData);
      final tempMarkerFile = File(
        join(
          tempDir.path,
          'bettbox_marker_${DateTime.now().millisecondsSinceEpoch}.tmp',
        ),
      );
      await tempMarkerFile.writeAsBytes(markerBytes);
      await encoder.addFile(tempMarkerFile, '.bettbox_marker');
      await tempMarkerFile.delete();

      // Add config file
      final configStr = json.encode(configJson);
      final tempConfigFile = File(
        join(
          tempDir.path,
          'bettbox_config_${DateTime.now().millisecondsSinceEpoch}.tmp',
        ),
      );
      await tempConfigFile.writeAsString(configStr);
      await encoder.addFile(tempConfigFile, 'config.json');
      await tempConfigFile.delete();

      // Add profiles dir (valid subscriptions only)
      final profilesDir = Directory(profilesPath);
      if (await profilesDir.exists()) {
        final files = await profilesDir
            .list(recursive: false)
            .toList(); // First level only

        for (final file in files) {
          if (file is File) {
            // Check if valid subscription config
            final fileName = basename(file.path);
            final profileId = fileName.replaceAll(RegExp(r'\.(yaml|yml)$'), '');

            if (validProfileIds.contains(profileId)) {
              // Normalize path: use Unix-style / separator
              final relativePath = relative(
                file.path,
                from: homeDirPath,
              ).replaceAll('\\', '/');
              await encoder.addFile(file, relativePath);
            }
          }
        }

        // Add current active subscription Providers
        if (currentProfileId != null &&
            validProfileIds.contains(currentProfileId)) {
          final providersDir = Directory(
            join(profilesPath, 'providers', currentProfileId),
          );

          if (await providersDir.exists()) {
            final providerFiles = await providersDir
                .list(recursive: true)
                .toList();

            for (final providerFile in providerFiles) {
              if (providerFile is File) {
                final relativePath = relative(
                  providerFile.path,
                  from: homeDirPath,
                ).replaceAll('\\', '/');
                await encoder.addFile(providerFile, relativePath);
              }
            }
          }
        }
      }

      encoder.close();

      // Read the zip file and return bytes
      final zipFile = File(tempZipPath);
      final bytes = await zipFile.readAsBytes();
      await zipFile.delete();
      return bytes;
    });
  }

  Future<void> updateTray([
    bool focus = false,
    bool silent = false,
    bool force = false,
  ]) async {
    final trayState = _ref.read(trayStateProvider);
    await tray.update(
      trayState: trayState,
      focus: focus,
      silent: silent,
      force: force,
    );
  }

  Future<void> _processRecoveryArchive(
    Future<Archive> Function() getArchive,
    RecoveryOption recoveryOption,
  ) async {
    try {
      final archive = await getArchive();
      commonPrint.log('Archive decoded: ${archive.files.length} files');
      await _recoveryFromArchive(archive, recoveryOption);
    } catch (e) {
      commonPrint.log('Recovery failed: $e');
      throw 'Backup file is corrupted or invalid: $e';
    }
  }

  /// Restore data from bytes
  Future<void> recoveryData(
    List<int> data,
    RecoveryOption recoveryOption,
  ) async {
    commonPrint.log('Starting recovery from bytes: ${data.length} bytes');
    await _processRecoveryArchive(
      () => Isolate.run<Archive>(() {
        final zipDecoder = ZipDecoder();
        return zipDecoder.decodeBytes(data);
      }),
      recoveryOption,
    );
  }

  /// Restore data from file path
  Future<void> recoveryDataFromFile(
    String path,
    RecoveryOption recoveryOption,
  ) async {
    commonPrint.log('Starting recovery from file: $path');
    await _processRecoveryArchive(
      () => Isolate.run<Archive>(() {
        try {
          final input = InputFileStream(path);
          final zipDecoder = ZipDecoder();
          final result = zipDecoder.decodeStream(input);
          input.close();
          if (result.files.isNotEmpty) {
            return result;
          }
        } catch (e) {
          commonPrint.log('Stream decoding failed: $e');
        }

        final bytes = File(path).readAsBytesSync();
        final zipDecoder = ZipDecoder();
        return zipDecoder.decodeBytes(bytes);
      }),
      recoveryOption,
    );
  }

  /// Unified recovery entry: check marker and dispatch to recovery logic
  Future<void> _recoveryFromArchive(
    Archive archive,
    RecoveryOption recoveryOption,
  ) async {
    if (archive.files.isEmpty) {
      throw 'Backup file is empty or corrupted';
    }

    final homeDirPath = await appPath.homeDirPath;

    // Check for Bettbox marker
    final hasBettboxMarker = archive.files.any(
      (file) => file.name == '.bettbox_marker',
    );

    if (hasBettboxMarker) {
      // Bettbox backup
      await _recoveryBettboxBackup(archive, recoveryOption, homeDirPath);
    } else {
      // Legacy backup
      await _recoveryLegacyBackup(archive, recoveryOption, homeDirPath);
    }
  }

  /// Restore Bettbox
  Future<void> _recoveryBettboxBackup(
    Archive archive,
    RecoveryOption recoveryOption,
    String homeDirPath,
  ) async {
    // Separate config and profile files
    final configs = archive.files
        .where(
          (item) =>
              item.name.endsWith('.json') && item.name != '.bettbox_marker',
        )
        .toList();
    final profiles = archive.files.where(
      (item) => !item.name.endsWith('.json') && item.name != '.bettbox_marker',
    );

    // Find config.json
    final configIndex = configs.indexWhere(
      (config) => config.name == 'config.json',
    );
    if (configIndex == -1) throw 'invalid backup file';

    // Parse config
    final configFile = configs[configIndex];
    final configContent = configFile.content;
    if (configContent.isEmpty) {
      throw 'Config file is empty or corrupted';
    }
    var tempConfig = Config.compatibleFromJson(
      json.decode(utf8.decode(configContent)),
    );

    // Restore profile files to disk
    for (final profile in profiles) {
      final filePath = join(homeDirPath, profile.name);
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(profile.content);
    }

    // Apply recovery logic
    _recovery(tempConfig, recoveryOption);
  }

  /// Restore legacy
  Future<void> _recoveryLegacyBackup(
    Archive archive,
    RecoveryOption recoveryOption,
    String homeDirPath,
  ) async {
    // Separate config and profile files
    final configs = archive.files
        .where((item) => item.name.endsWith('.json'))
        .toList();
    final profileFiles = archive.files
        .where(
          (item) =>
              !item.name.endsWith('.json') && !item.name.endsWith('.sqlite'),
        )
        .toList();

    // Find config.json
    final configIndex = configs.indexWhere(
      (config) => config.name == 'config.json',
    );
    if (configIndex == -1) throw 'invalid backup file';

    // Parse backup config
    final configFile = configs[configIndex];
    final configContent = configFile.content;
    if (configContent.isEmpty) {
      throw 'Config file is empty or corrupted';
    }
    final backupConfig = Config.compatibleFromJson(
      json.decode(utf8.decode(configContent)),
    );

    // Restore profile files to disk
    for (final profile in profileFiles) {
      final filePath = join(homeDirPath, profile.name);
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(profile.content);
    }

    // Extract profiles from backup
    List<Profile> profiles = [];
    bool extractedFromDatabase = false;

    // 1. Try SQLite database first (FlClash backup)
    final dbFile = archive.files.firstWhereOrNull(
      (file) => file.name.endsWith('database.sqlite'),
    );

    if (dbFile != null && dbFile.content.isNotEmpty) {
      try {
        // Save database temporarily
        final tempDbPath = join(await appPath.tempPath, 'temp_flclash.db');
        final tempDb = File(tempDbPath);
        await tempDb.writeAsBytes(dbFile.content);

        // Extract profiles from database
        profiles = await FlClashDatabaseExtractor.extractProfiles(tempDbPath);
        extractedFromDatabase = true;

        // Clean up temp file
        if (await tempDb.exists()) {
          await tempDb.delete();
        }

        commonPrint.log(
          'Extracted ${profiles.length} profiles from FlClash database',
        );
      } catch (e) {
        commonPrint.log(
          'Failed to extract from database, fallback to file names: $e',
        );
        profiles = [];
        extractedFromDatabase = false;
      }
    }

    // 2. Fallback if database extraction failed
    if (profiles.isEmpty) {
      // Get from config.json
      if (backupConfig.profiles.isNotEmpty) {
        profiles = backupConfig.profiles;
      } else {
        // Extract ID from profile file names (FlClash mode)
        for (final profileFile in profileFiles) {
          final fileName = profileFile.name.split('/').last;
          if (fileName.endsWith('.yaml') || fileName.endsWith('.yml')) {
            final id = fileName.replaceAll(RegExp(r'\.(yaml|yml)$'), '');

            // Try to extract friendly label from YAML
            final label = await _extractLabelFromYaml(profileFile) ?? id;

            // Create basic Profile object
            profiles.add(
              Profile(
                id: id,
                label: label,
                autoUpdateDuration: defaultUpdateDuration,
                url: '', // Mark empty, user needs to add
              ),
            );
          }
        }
      }
    }

    // Create limited recovery config (subscriptions only)
    Config limitedConfig = globalState.config.copyWith(profiles: profiles);

    // Android: also restore app list
    if (system.isAndroid) {
      // FlClash uses accessControlProps instead of accessControl
      final vpnProps = backupConfig.vpnProps;
      AccessControl? accessControl;

      // Try to get from vpnProps.accessControl
      try {
        accessControl = vpnProps.accessControl;
      } catch (_) {
        // Fallback: try accessControlProps from raw JSON
        try {
          final configJson = json.decode(utf8.decode(configFile.content));
          final vpnPropsJson = configJson['vpnProps'];
          if (vpnPropsJson != null && vpnPropsJson is Map) {
            final accessControlPropsJson = vpnPropsJson['accessControlProps'];
            if (accessControlPropsJson != null) {
              accessControl = AccessControl.fromJson(
                accessControlPropsJson as Map<String, dynamic>,
              );
            }
          }
        } catch (_) {}
      }

      if (accessControl != null) {
        limitedConfig = limitedConfig.copyWith.vpnProps(
          accessControl: accessControl,
        );
      }
    }

    // Apply limited recovery
    _recoveryLimited(limitedConfig, recoveryOption);

    // Show recovery result message
    _showRecoveryResultMessage(profiles, extractedFromDatabase);
  }

  /// Extract label
  Future<String?> _extractLabelFromYaml(ArchiveFile profileFile) async {
    try {
      final yamlContent = utf8.decode(profileFile.content);

      // Try to extract from comments
      final lines = yamlContent.split('\n');
      for (final line in lines) {
        if (line.trim().startsWith('#')) {
          final comment = line.trim().substring(1).trim();
          if (comment.isNotEmpty &&
              comment.length < 50 &&
              !comment.startsWith('!')) {
            return comment;
          }
        }
      }

      // Try to extract from first proxy name
      final yamlMap = loadYaml(yamlContent);
      if (yamlMap is Map && yamlMap['proxies'] is List) {
        final proxies = yamlMap['proxies'] as List;
        if (proxies.isNotEmpty && proxies[0] is Map) {
          final firstProxy = proxies[0] as Map;
          final name = firstProxy['name'];
          if (name != null && name.toString().isNotEmpty) {
            return 'Sub - $name';
          }
        }
      }
    } catch (e) {
      commonPrint.log('Failed to extract label from YAML: $e');
    }
    return null;
  }

  /// Show results
  void _showRecoveryResultMessage(
    List<Profile> profiles,
    bool extractedFromDatabase,
  ) {
    if (profiles.isEmpty) return;

    final hasEmptyUrl = profiles.any((p) => p.url.isEmpty);

    String message;
    if (extractedFromDatabase) {
      // Successfully extracted from database
      message = 'Restored ${profiles.length} subscriptions with URLs.';
    } else if (hasEmptyUrl) {
      // Partial recovery, missing URLs
      message =
          'Restored ${profiles.length} subscriptions.\n\n'
          'Warning: URLs not included. Edit subscriptions to add URLs for auto-update.';
    } else {
      // Complete recovery
      message = 'Restored ${profiles.length} subscriptions.';
    }

    globalState.showMessage(
      title: appLocalizations.recoverySuccess,
      message: TextSpan(text: message),
      cancelable: false,
    );
  }

  void _restoreProfiles(List<Profile> profiles) {
    final recoveryStrategy = _ref.read(
      appSettingProvider.select((state) => state.recoveryStrategy),
    );
    if (recoveryStrategy == RecoveryStrategy.override) {
      _ref.read(profilesProvider.notifier).value = profiles;
    } else {
      for (final profile in profiles) {
        _ref.read(profilesProvider.notifier).setProfile(profile);
      }
    }
  }

  void _ensureCurrentProfile(List<Profile> profiles) {
    final currentProfile = _ref.read(currentProfileProvider);
    if (currentProfile == null && profiles.isNotEmpty) {
      _ref.read(currentProfileIdProvider.notifier).value = profiles.first.id;
    }
  }

  /// Partial restore
  void _recoveryLimited(Config config, RecoveryOption recoveryOption) {
    final profiles = config.profiles;

    // Restore subscriptions
    _restoreProfiles(profiles);

    // Android: restore app list
    if (system.isAndroid) {
      _ref
          .read(vpnSettingProvider.notifier)
          .updateState(
            (state) =>
                state.copyWith(accessControl: config.vpnProps.accessControl),
          );
    }

    // Ensure current profile exists
    _ensureCurrentProfile(profiles);
  }

  /// Full restore
  void _recovery(Config config, RecoveryOption recoveryOption) {
    final profiles = config.profiles;

    // Restore subscriptions
    _restoreProfiles(profiles);

    final onlyProfiles = recoveryOption == RecoveryOption.onlyProfiles;
    if (!onlyProfiles) {
      // Restore settings

      // 1. Clash config
      if (system.isDesktop) {
        // Desktop: preserve current TUN state, avoid mobile backup override
        final currentTunEnable = _ref.read(patchClashConfigProvider).tun.enable;
        _ref.read(patchClashConfigProvider.notifier).value = config
            .patchClashConfig
            .copyWith
            .tun(enable: currentTunEnable);
      } else {
        // Mobile: restore directly
        _ref.read(patchClashConfigProvider.notifier).value =
            config.patchClashConfig;
      }

      // 2. App settings
      final backupAppSetting = config.appSetting;

      _ref.read(appSettingProvider.notifier).value = backupAppSetting.copyWith(
        mobileDashboardWidgets: backupAppSetting.mobileDashboardWidgets,
        desktopDashboardWidgets: backupAppSetting.desktopDashboardWidgets,
        dashboardWidgets: system.isAndroid
            ? backupAppSetting.mobileDashboardWidgets
            : backupAppSetting.desktopDashboardWidgets,
      );

      // 3. Restore current profile ID
      _ref.read(currentProfileIdProvider.notifier).value =
          config.currentProfileId;

      // 4. Restore WebDAV settings
      _ref.read(appDAVSettingProvider.notifier).value = config.dav;

      // 5. Restore theme settings
      _ref.read(themeSettingProvider.notifier).value = config.themeProps;

      // 6. Restore window settings (desktop only)
      if (system.isDesktop) {
        _ref.read(windowSettingProvider.notifier).value = config.windowProps;
      }

      // 7. VPN settings
      if (system.isAndroid) {
        final currentVpnProps = _ref.read(vpnSettingProvider);
        final hasBackupAccessControl =
            config.vpnProps.accessControl.enable ||
            config.vpnProps.accessControl.acceptList.isNotEmpty ||
            config.vpnProps.accessControl.rejectList.isNotEmpty;
        _ref.read(vpnSettingProvider.notifier).value = config.vpnProps.copyWith(
          accessControl: hasBackupAccessControl
              ? config.vpnProps.accessControl
              : currentVpnProps.accessControl,
        );
      } else if (system.isDesktop) {
        // Desktop: restore network settings, preserve TUN state
        final currentVpnProps = _ref.read(vpnSettingProvider);
        _ref.read(networkSettingProvider.notifier).value = config.networkProps;

        // Only restore non-platform-specific VPN settings
        _ref.read(vpnSettingProvider.notifier).value = config.vpnProps.copyWith(
          enable: currentVpnProps.enable, // Preserve current TUN state
        );
      }

      // 8. Restore proxy style
      _ref.read(proxiesStyleSettingProvider.notifier).value =
          config.proxiesStyle;

      // 9. Restore DNS override settings
      _ref.read(overrideDnsProvider.notifier).value = config.overrideDns;

      // 10. Restore hotkey settings (desktop only)
      if (system.isDesktop) {
        _ref.read(hotKeyActionsProvider.notifier).value = config.hotKeyActions;
      }

      // 11. Restore script settings
      _ref.read(scriptStateProvider.notifier).value = config.scriptProps;
    }

    // Ensure current profile exists
    _ensureCurrentProfile(profiles);
  }



  Future<T?> safeRun<T>(
    FutureOr<T> Function() futureFunction, {
    String? title,
    bool needLoading = false,
    bool silence = true,
  }) async {
    try {
      if (needLoading) {
        _ref.read(loadingProvider.notifier).value = true;
      }
      final res = await futureFunction();
      return res;
    } on Object catch (e) {
      commonPrint.log(e.formatError);
      final errorMessage = _formatErrorMessage(e);
      if (needLoading) {
        _ref.read(loadingProvider.notifier).value = false;
      }
      if (silence) {
        globalState.showNotifier(errorMessage);
      } else {
        try {
          await globalState.showMessage(
            title: title ?? appLocalizations.tip,
            message: TextSpan(text: errorMessage),
            cancelable: false,
          );
        } catch (_) {
          globalState.showNotifier(errorMessage);
        }
      }
      return null;
    } finally {
      if (needLoading) {
        _ref.read(loadingProvider.notifier).value = false;
      }
    }
  }

  String _formatErrorMessage(dynamic error) {
    final errorStr = error.toString();

    final statusCodeMatch = RegExp(
      r'status code of (\d+)',
    ).firstMatch(errorStr);
    final statusCode = statusCodeMatch?.group(1);

    if (statusCode != null) {
      return appLocalizations.profileImportFailed(statusCode);
    }

    return error.formatError;
  }
}
