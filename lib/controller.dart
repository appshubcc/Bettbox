import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/helper/helper.dart';

import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/plugins/service.dart' as vpn_service;
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/dialog.dart';
import 'package:bett_box/widgets/input.dart';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' hide windows;
import 'package:restart_app/restart_app.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tray_manager/tray_manager.dart';

import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:yaml/yaml.dart';

import 'common/archive.dart'
    show BackupPasswordException, decodeBackupArchive, restoreBackupFiles;
import 'common/common.dart';
import 'common/dav_client.dart';
import 'common/profile_recovery.dart';
import 'models/models.dart';
import 'views/profiles/override_profile.dart';
import 'views/proxies/common.dart' show cancelDelayTests, delayTest;

class _RecoveryApplyException implements Exception {
  const _RecoveryApplyException(this.error);

  final Object error;
}

class AppController {
  int? lastProfileModified;

  final BuildContext context;
  final WidgetRef _ref;
  WidgetRef get ref => _ref;

  Timer? _wakelockSyncTimer;
  final List<Log> _pendingLogs = [];
  Completer<void>? _exitLock;
  final Lock _coreLifecycleLock = Lock(reentrant: true);
  int _backgroundLoadVersion = 0;

  int _updateGroupsRetryCount = 0;
  bool _isUpdatingGroups = false;
  Timer? _updateGroupsRetryTimer;
  int _coreGeneration = 0;
  int _setupGeneration = 0;
  String? _loadedProfileId;
  final Set<String> _updatingProfileIds = {};
  final Lock _bundleLock = Lock();
  final Set<String> _pendingBundleIds = {};
  final Set<String> _refreshingBundleIds = {};
  int _localNetworkId = 0;
  Timer? _idleGcTimer;
  Timer? _expandedUpdateTimer;
  bool _isAutoBackupPending = false;
  bool _isAutoBackupRunning = false;
  bool _isAutoBackupSuppressed = false;

  static const _autoBackupFingerprintKey = 'auto_backup_fingerprint';

  AppController(this.context, WidgetRef ref) : _ref = ref;

  DateTime _lastModeChangeTime = DateTime.fromMillisecondsSinceEpoch(0);
  Mode? _appliedMode;

  bool get _closeConnectionsOnSwitch => system.isAndroid
      ? _ref.read(vpnSettingProvider).quickResponse
      : _ref.read(appSettingProvider).closeConnections;

  void scheduleIdleGc({Duration delay = const Duration(seconds: 2)}) {
    _idleGcTimer?.cancel();
    _idleGcTimer = Timer(delay, () {
      _idleGcTimer = null;
      unawaited(
        clashCore.requestGc(forceFreeOSMemory: true, purge: system.isAndroid),
      );
    });
  }

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
    debouncer.call(FunctionTag.applyProfile, (bool silence) {
      applyProfile(silence: silence);
    }, args: [silence]);
  }

  void savePreferencesDebounce() {
    debouncer.call(FunctionTag.savePreferences, () async {
      await routeIdleObserver.whenIdle();
      await savePreferences();
    });
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

  void _cancelDelayTests() {
    cancelDelayTests();
    _ref.read(delayDataSourceProvider.notifier).dropTesting();
  }

  Future<void> flushDns() async {
    await clashCore.flushFakeIP();
    await clashCore.flushDnsCache();
  }

  Future<void> restartCore() {
    return _coreLifecycleLock.synchronized(() async {
      _ref.read(isRestartingCoreProvider.notifier).value = true;
      try {
        await _restartCore();
      } catch (err) {
        _reportCoreRestartFailure(err);
        rethrow;
      } finally {
        _ref.read(isRestartingCoreProvider.notifier).value = false;
      }
    });
  }

  Future<void> _restartCore({
    bool setupConfig = true,
    bool refreshData = true,
  }) async {
    commonPrint.log('Restarting core');
    _invalidateCoreReads();
    _cancelDelayTests();

    final wasRunning = _ref.read(runTimeProvider.notifier).isStart;
    if (wasRunning) {
      await globalState.handleStop();
      _ref.read(runTimeProvider.notifier).value = null;
    }
    if (system.isAndroid) {
      await clashCore.closeConnections();
      await clashCore.flushFakeIP();
      await clashCore.flushDnsCache();
      await clashCore.requestGc(forceFreeOSMemory: true);
      if (wasRunning) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
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
      scheduleIdleGc();
    }

    if (wasRunning) {
      await globalState.handleStart([updateRunTime, updateTraffic]);
      _scheduleCheckIpRefresh();
      _backgroundLoad();
    }
  }

  Future<void> updateStatus(bool isStart) {
    return _coreLifecycleLock.synchronized(() => _updateStatus(isStart));
  }

  Future<void> _updateStatus(bool isStart) async {
    if (isStart) {
      await _fastStart();
      if (globalState.isStart) {
        final mode = _ref.read(patchClashConfigProvider).mode;
        commonPrint.log('Proxy started in ${mode.name} mode');
      }
      if (globalState.isStart && !_ref.read(runTimeProvider.notifier).isStart) {
        _ref.read(runTimeProvider.notifier).value = 0;
      }
      unawaited(_autoDownloadAppUpdate());
    } else {
      await globalState.handleStop();
      commonPrint.log('Proxy stopped');
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
      commonPrint.warn('Start skipped, no profile selected');
      return;
    }

    final patchConfig = _ref.read(patchClashConfigProvider);
    final isDesktop = system.isDesktop;

    if (isDesktop && patchConfig.tun.enable) {
      await _quickSetupConfig(enableTun: false);

      if (system.isMacOS || system.isLinux) {
        try {
          final res = await _requestAdmin(true);
          if (res.needRestart) {
            await restartCore();
            return;
          }
          await globalState.handleStart([updateRunTime, updateTraffic]);
          if (res.data == true) {
            _runAfterFastStart(_updateClashConfig);
          } else {
            _backgroundLoad();
          }
        } catch (e) {
          commonPrint.warn('TUN authorization failed: $e');
          await globalState.handleStart([updateRunTime, updateTraffic]);
          _backgroundLoad();
        }
        _scheduleCheckIpRefresh();
        return;
      }

      await globalState.handleStart([updateRunTime, updateTraffic]);

      _runAfterFastStart(() async {
        final res = await _requestAdmin(true);
        if (res.needRestart) {
          await restartCore();
          return;
        }
        if (res.data == true) {
          await _updateClashConfig();
        }
      });

      _scheduleCheckIpRefresh();
      return;
    }

    final needReapply = await _needsSetupConfig();
    if (needReapply) {
      final setupResult = await _quickSetupConfig();
      if (setupResult != true) return;
    }

    await globalState.handleStart([updateRunTime, updateTraffic]);

    _scheduleCheckIpRefresh();

    _backgroundLoad();
  }

  void _runAfterFastStart(Future<void> Function() action) {
    Zone.root.run(() {
      unawaited(
        _coreLifecycleLock.synchronized(() async {
          if (!globalState.isStart) return;
          try {
            await action();
          } catch (e) {
            commonPrint.warn('TUN update failed: $e');
          }
          _backgroundLoad();
        }),
      );
    });
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
        await updateProviders();
        if (version != _backgroundLoadVersion) return;
        if (generation != _coreGeneration) return;

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

        scheduleIdleGc();
      } catch (e) {
        commonPrint.warn('Background load failed: $e');
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
    await _initCore();
    final isFileExists = await currentProfile.check();
    if (!isFileExists) {
      await currentProfile.checkAndUpdate();
    }
    final patchConfig = _ref.read(patchClashConfigProvider);
    final targetTun = enableTun ?? patchConfig.tun.enable;

    final realTunEnable = await _prepareTun(targetTun);
    if (realTunEnable == null) return false;

    final realPatchConfig = patchConfig.copyWith.tun(enable: realTunEnable);
    final params = await globalState.getSetupParams(
      pathConfig: realPatchConfig,
    );
    _cancelDelayTests();
    var result = await clashCore.setupConfig(params);
    var message = result.message;
    if (message.isNotEmpty && params.scriptedConfig.isNotEmpty) {
      commonPrint.warn('Script config rejected: $message', module: 'Script');
      globalState.showNotifier(
        '${appLocalizations.profileParseErrorDesc}: $message',
      );
      final managed = currentProfile.runsManagedScript;
      final fallbackScripted =
          managed &&
              ManagedScript.syncedVersion(globalState.config.managedProps) !=
                  null
          ? await globalState.writeBundledManagedConfig(currentProfile)
          : '';
      if (!managed || fallbackScripted.isNotEmpty) {
        result = await clashCore.setupConfig(
          params.copyWith(scriptedConfig: fallbackScripted),
        );
        message = result.message;
      }
    }
    if (message.isNotEmpty) throw message;
    _appliedMode = realPatchConfig.mode;
    _applyGlobalSelection(result.global);
    _loadedProfileId = currentProfile.id;
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

  void _applyGlobalSelection(String global) {
    final profile = _ref.read(currentProfileProvider);
    if (global.isEmpty ||
        profile == null ||
        profile.selectedMap['GLOBAL'] != null) {
      return;
    }
    setProfile(
      profile.copyWith(selectedMap: {...profile.selectedMap, 'GLOBAL': global}),
    );
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
    return dashboardRefreshManager.isActive();
  }

  String? _speedNotificationProfileToSync() {
    if (!system.isAndroid ||
        !globalState.isScreenOn ||
        !_ref.read(vpnSettingProvider).networkSpeedNotification) {
      return null;
    }
    final currentProfileId = _ref.read(currentProfileIdProvider);
    final profiles = _ref.read(profilesProvider);
    final profile = profiles.where((e) => e.id == currentProfileId).firstOrNull;
    final profileName = profile?.label ?? 'Bettbox';
    final needsSync =
        vpn_service.service?.needsSpeedNotificationSync(profileName) ?? false;
    return needsSync ? profileName : null;
  }

  Future<void> updateTraffic() async {
    final shouldUpdateDashboard = await _shouldUpdateDashboardTick();
    final speedNotificationProfile = _speedNotificationProfileToSync();
    final enableTraySpeed =
        system.isMacOS && _ref.read(vpnSettingProvider).enableTraySpeed;

    if (!shouldUpdateDashboard &&
        speedNotificationProfile == null &&
        !enableTraySpeed) {
      return;
    }

    final snapshot = await clashCore.getTrafficSnapshot();
    _ref.read(totalTrafficProvider.notifier).value = snapshot.total;

    final traffic = snapshot.now;

    if (shouldUpdateDashboard) {
      _ref.read(trafficsProvider.notifier).addTraffic(traffic);
    }

    if (enableTraySpeed) {
      await tray.updateSpeed(traffic);
    }

    if (speedNotificationProfile != null) {
      await vpn_service.service?.updateNotificationSpeed(
        speedNotificationProfile,
        traffic.toString(),
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
    _detachBundleMember(id);
    if (globalState.config.currentProfileId == id) {
      final profiles = globalState.config.profiles;
      final currentProfileId = _ref.read(currentProfileIdProvider.notifier);
      if (profiles.isNotEmpty) {
        final updateId = profiles.first.id;
        currentProfileId.value = updateId;
      } else {
        currentProfileId.value = null;
        unawaited(updateStatus(false));
      }
    }
  }

  Future<void> updateProviders() async {
    final providers = await _loadProviders();
    _syncProviderSubscriptions(providers);
    _scheduleExpandedUpdate(providers);
    if (listEquals(_ref.read(providersProvider), providers)) return;
    _ref.read(providersProvider.notifier).value = providers;
  }

  void _setProviders(List<ExternalProvider> providers) {
    _ref.read(providersProvider.notifier).value = providers;
    _syncProviderSubscriptions(providers);
    _scheduleExpandedUpdate(providers);
  }

  Profile? get _loadedProfile => _ref
      .read(profilesProvider)
      .getProfile(_loadedProfileId ?? _ref.read(currentProfileIdProvider));

  Future<List<ExternalProvider>> _loadProviders() async {
    final providers = await clashCore.getExternalProviders();
    final profile = _loadedProfile;
    if (profile == null || !profile.runsManagedScript) return providers;
    final file = File(
      join(await appPath.getProvidersDirPath(profile.id), 'expanded.json'),
    );
    if (!await file.exists()) return providers;
    try {
      final loaded = {
        for (final provider in providers)
          if (provider.type == 'Proxy') provider.name,
      };
      final expanded = (json.decode(await file.readAsString()) as List)
          .map(
            (item) => ExternalProvider.fromJson(item as Map<String, Object?>),
          )
          .where((provider) => !loaded.contains(provider.name));
      return [...providers, ...expanded]
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      commonPrint.warn('Read expanded providers failed: $e', module: 'Profile');
      return providers;
    }
  }

  Future<String> updateExpandedProviders(
    List<String> names, {
    String? content,
  }) async {
    final profile = _loadedProfile;
    if (profile == null || names.isEmpty) return '';
    final messages = <String>[];
    var changed = false;
    for (final name in names) {
      final provider = _ref
          .read(providersProvider)
          .firstWhereOrNull((item) => item.name == name);
      if (provider != null) setProvider(provider.copyWith(isUpdating: true));
      try {
        if (await clashCore.updateExpandedProvider(
          profile,
          name,
          content: content,
        )) {
          changed = true;
        }
      } catch (e) {
        messages.add('$name: $e');
      }
    }
    await updateProviders();
    if (changed) applyProfileDebounce(silence: true);
    return messages.join('\n');
  }

  void _scheduleExpandedUpdate(List<ExternalProvider> providers) {
    _expandedUpdateTimer?.cancel();
    _expandedUpdateTimer = null;
    final due = providers
        .map(_expandedDueAt)
        .nonNulls
        .sorted((a, b) => a.compareTo(b))
        .firstOrNull;
    if (due == null) return;
    final delay = due.difference(DateTime.now());
    _expandedUpdateTimer = Timer(
      delay < const Duration(seconds: 30) ? const Duration(seconds: 30) : delay,
      _autoUpdateExpandedProviders,
    );
  }

  DateTime? _expandedDueAt(ExternalProvider provider) {
    if (!provider.expanded ||
        provider.vehicleType != 'HTTP' ||
        provider.interval <= 0) {
      return null;
    }
    return provider.updateAt.add(Duration(seconds: provider.interval));
  }

  Future<void> _autoUpdateExpandedProviders() async {
    _expandedUpdateTimer = null;
    if (!system.isDesktop && globalState.backgroundMode.value) return;
    final deadline = DateTime.now().add(const Duration(seconds: 30));
    final providers = _ref.read(providersProvider);
    final names = [
      for (final provider in providers)
        if (_expandedDueAt(provider)?.isBefore(deadline) ?? false)
          provider.name,
    ];
    if (names.isEmpty) {
      _scheduleExpandedUpdate(providers);
      return;
    }
    final message = await updateExpandedProviders(names);
    if (message.isEmpty) return;
    commonPrint.warn(
      'Update expanded providers failed: $message',
      module: 'Profile',
    );
    _expandedUpdateTimer?.cancel();
    _expandedUpdateTimer = Timer(
      const Duration(minutes: 10),
      _autoUpdateExpandedProviders,
    );
  }

  void _syncProviderSubscriptions(List<ExternalProvider> providers) {
    final profile = _loadedProfile;
    if (profile == null || profile.bundle != null) return;
    final subscriptions = {
      for (final provider in providers)
        if (provider.type == 'Proxy') provider.name: ?provider.subscriptionInfo,
    };
    if (mapEquals(profile.providerSubscriptions, subscriptions)) return;
    setProfile(profile.copyWith(providerSubscriptions: subscriptions));
  }

  Future<void> updateLocalNetwork({bool silent = false}) async {
    final id = ++_localNetworkId;
    if (!silent) {
      _ref.read(localNetworkProvider.notifier).value = null;
      await Future.delayed(commonDuration);
      if (id != _localNetworkId) return;
    }
    final info = await utils.getNetworkInfo();
    if (id != _localNetworkId) return;
    _ref.read(localNetworkProvider.notifier).value = info;
  }

  Future<void> updateProfile(
    Profile profile, {
    bool validate = true,
    bool applyUnchanged = true,
  }) async {
    if (_updatingProfileIds.contains(profile.id)) {
      _ref
          .read(profilesProvider.notifier)
          .setProfile(profile.copyWith(isUpdating: false));
      return;
    }
    _updatingProfileIds.add(profile.id);
    try {
      final modified = applyUnchanged
          ? null
          : await profile.profileLastModified;
      final name = profile.label ?? profile.id;
      final Profile newProfile;
      try {
        newProfile = await profile.update(validate: validate);
      } catch (e) {
        commonPrint.error(
          'Update $name failed: ${e.formatErrorLog}',
          module: 'Profile',
        );
        rethrow;
      }
      commonPrint.log('Updated $name', module: 'Profile');
      _ref
          .read(profilesProvider.notifier)
          .setProfile(newProfile.copyWith(isUpdating: false));
      if (profile.id != _ref.read(currentProfileIdProvider)) return;
      if (modified != null && modified == await profile.profileLastModified) {
        return;
      }
      if (newProfile.runsManagedScript) {
        globalState.providerRefreshProfileId = profile.id;
      }
      applyProfileDebounce(silence: true);
    } finally {
      _updatingProfileIds.remove(profile.id);
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

  Future<void> createBundle({
    required String label,
    required List<BundleMember> members,
    bool collapsed = false,
    ProfileUsageStyle usageStyle = ProfileUsageStyle.bar,
    String? scriptId,
  }) {
    return _bundleLock.synchronized(() async {
      final profile = Profile.normal(label: label).copyWith(
        autoUpdate: false,
        usageStyle: usageStyle,
        scriptId: scriptId,
        bundle: ProfileBundle(members: members, collapsed: collapsed),
      );
      await addProfile(await _generateBundle(profile, refresh: false));
    });
  }

  Future<void> generateBundle(
    String id, {
    bool refresh = false,
    Profile Function(Profile profile)? update,
  }) {
    return _bundleLock.synchronized(() async {
      final current = _ref.read(profilesProvider).getProfile(id);
      if (current == null || current.bundle == null) return;
      final profile = update?.call(current) ?? current;
      if (refresh) _refreshingBundleIds.add(id);
      setProfile(current.copyWith(isUpdating: true));
      try {
        final file = File(await appPath.getProfilePath(id));
        final modified = await file.exists()
            ? (await file.stat()).modified
            : null;
        final generated = await _generateBundle(profile, refresh: refresh);
        final previous = _ref.read(profilesProvider).getProfile(id);
        final latest = previous == null
            ? null
            : update?.call(previous) ?? previous;
        final latestBundle = latest?.bundle;
        if (latest == null || latestBundle == null) return;
        final setup = _ref.read(needSetupProvider);
        setProfile(
          latest.copyWith(
            isUpdating: false,
            lastUpdateDate: generated.lastUpdateDate,
            providerSubscriptions: generated.providerSubscriptions,
            bundle: latestBundle.copyWith(
              report: generated.bundle?.report ?? latestBundle.report,
              failures: generated.bundle?.failures ?? const {},
              scriptKey: generated.bundle?.scriptKey,
            ),
          ),
        );
        if (id != _ref.read(currentProfileIdProvider)) return;
        if (_ref.read(needSetupProvider) != setup) return;
        if (modified != null && modified == (await file.stat()).modified) {
          return;
        }
        applyProfileDebounce(silence: true);
      } finally {
        _refreshingBundleIds.remove(id);
        final latest = _ref.read(profilesProvider).getProfile(id);
        if (latest != null && latest.isUpdating) {
          setProfile(latest.copyWith(isUpdating: false));
        }
      }
    });
  }

  Future<void> updateBundleScript(
    String id,
    String? scriptId, {
    bool regenerate = false,
  }) async {
    final profile = _ref.read(profilesProvider).getProfile(id);
    if (profile == null || profile.bundle == null) return;
    if (scriptId != profile.scriptId) {
      await generateBundle(
        id,
        update: (profile) => profile.copyWith(scriptId: scriptId),
      );
      return;
    }
    if (regenerate) await generateBundle(id);
  }

  Future<void> deleteScript(String label) async {
    final id = _ref
        .read(scriptStateProvider)
        .scripts
        .where((script) => script.label == label)
        .firstOrNull
        ?.id;
    if (id == null) return;
    try {
      for (final profile in _ref.read(profilesProvider)) {
        if (profile.bundle == null || profile.scriptId != id) continue;
        await updateBundleScript(profile.id, null);
      }
    } finally {
      _ref.read(scriptStateProvider.notifier).del(label);
      final pending = <String>[];
      for (final profile in _ref.read(profilesProvider)) {
        if (profile.scriptId != id) continue;
        _ref
            .read(profilesProvider.notifier)
            .updateProfile(profile.id, (p) => p.copyWith(scriptId: null));
        if (profile.bundle != null) pending.add(profile.id);
      }
      scheduleBundles(pending);
    }
  }

  void _repairBundleScripts() {
    final scripts = _ref.read(scriptStateProvider);
    for (final profile in _ref.read(profilesProvider)) {
      if (profile.bundle == null || profile.scriptId == null) continue;
      if (scripts.findScript(profile.scriptId) != null) continue;
      unawaited(safeRun(() => updateBundleScript(profile.id, null)));
    }
    syncScriptBundles();
  }

  String _bundleScriptKey(Script script) =>
      '${script.id}:${script.digest}:${json.encode(script.customOptions ?? const <String, bool>{})}';

  void syncScriptBundles() {
    final scripts = _ref.read(scriptStateProvider);
    scheduleBundles([
      for (final profile in _ref.read(profilesProvider))
        if (profile.bundle case final bundle? when !profile.isManaged)
          if (scripts.findScript(profile.scriptId) case final script?
              when bundle.scriptKey != _bundleScriptKey(script))
            profile.id,
    ]);
  }

  void updateManagedSetting(ManagedProps Function(ManagedProps state) builder) {
    _ref.read(managedSettingProvider.notifier).updateState(builder);
    generateAllBundles();
  }

  ProxyNode _createNode(
    Map<String, dynamic> proxy,
    Set<String> names, {
    String? warpId,
    String? warpToken,
  }) {
    final base = proxy['name']?.toString() ?? '';
    var name = base;
    for (var index = 2; !names.add(name); index++) {
      name = '$base $index';
    }
    return ProxyNode(
      id: utils.uuidV4,
      proxy: {...proxy, 'name': name},
      warpId: warpId,
      warpToken: warpToken,
    );
  }

  Future<({List<Map<String, dynamic>> proxies, int invalid})> _parseNodes(
    String text,
  ) async {
    final res = await clashCore.parseNodes(text);
    final proxies = res['proxies'];
    if (proxies is! List || proxies.isEmpty) {
      final error = res['error']?.toString() ?? '';
      throw error.isEmpty ? appLocalizations.nodeImportEmpty : error;
    }
    final invalid = res['invalid'];
    return (
      proxies: [
        for (final item in proxies)
          if (item is Map) Map<String, dynamic>.from(item),
      ],
      invalid: invalid is num ? invalid.toInt() : 0,
    );
  }

  Future<({List<ProxyNode> nodes, int invalid})> parseNodes(String text) async {
    final (:proxies, :invalid) = await _parseNodes(text);
    final names = {for (final node in _ref.read(nodesProvider)) node.name};
    return (
      nodes: [for (final proxy in proxies) _createNode(proxy, names)],
      invalid: invalid,
    );
  }

  Future<ProxyNode> updateNodeProxy(ProxyNode node, String text) async {
    final (:proxies, invalid: _) = await _parseNodes(text);
    final names = {
      for (final item in _ref.read(nodesProvider))
        if (item.id != node.id) item.name,
    };
    final updated = node.copyWith(
      proxy: _createNode(proxies.first, names).proxy,
    );
    _ref.read(nodesProvider.notifier).setNode(updated);
    return updated;
  }

  Future<ProxyNode> registerWarp() async {
    final res = await clashCore.registerWarp();
    final proxy = res['proxy'];
    if (proxy is! Map) {
      final error = res['error']?.toString() ?? '';
      throw error.isEmpty ? appLocalizations.registerWarpFailed : error;
    }
    final names = {for (final node in _ref.read(nodesProvider)) node.name};
    return _createNode(
      Map<String, dynamic>.from(proxy),
      names,
      warpId: res['id']?.toString(),
      warpToken: res['token']?.toString(),
    );
  }

  Future<int?> testNode(ProxyNode node, {String? dialer}) async {
    final res = await clashCore.testNode(node.proxy, dialer: dialer);
    final error = res['error']?.toString() ?? '';
    final delay = res['delay'];
    return error.isEmpty && delay is num && delay > 0 ? delay.toInt() : null;
  }

  void generateAllBundles() {
    scheduleBundles([
      for (final profile in _ref.read(profilesProvider))
        if (profile.bundle != null && profile.isManaged) profile.id,
    ]);
  }

  Future<void> checkManagedScriptVersionUpgrade() async {
    final currentVersion = ManagedScript.version(
      _ref.read(managedSettingProvider),
    );
    if (currentVersion.isEmpty) return;
    final prefs = await preferences.sharedPreferencesCompleter.future;
    final lastVersion = prefs?.getString(lastManagedScriptVersionKey);
    if (lastVersion == currentVersion) return;
    await prefs?.setString(lastManagedScriptVersionKey, currentVersion);
    final hasBundles = _ref.read(profilesProvider).any((p) => p.bundle != null);
    if (hasBundles) {
      generateAllBundles();
    }
    final current = _ref.read(currentProfileProvider);
    if (current != null && current.runsManagedScript) {
      applyProfileDebounce(silence: true);
    }
  }

  void scheduleBundles(Iterable<String> ids) {
    _pendingBundleIds.addAll(ids);
    if (_pendingBundleIds.isEmpty) return;
    debouncer.call(
      FunctionTag.generateBundles,
      _flushBundles,
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> _flushBundles() async {
    final ids = _pendingBundleIds.toList();
    _pendingBundleIds.clear();
    for (final id in ids) {
      try {
        await generateBundle(id);
      } catch (e) {
        final label = _ref.read(profilesProvider).getProfile(id)?.label ?? id;
        commonPrint.error(
          'Generate $label failed: ${e.formatErrorLog}',
          module: 'Profile',
        );
        globalState.showNotifier('$label: ${e.formatError}');
      }
    }
  }

  void syncBundles(List<Profile> previous, List<Profile> next) {
    final regenerate = <String>{};
    var usageChanged = false;
    for (final profile in next) {
      if (profile.bundle != null) continue;
      final old = previous.getProfile(profile.id);
      if (old == null || old == profile) continue;
      final bundles = next.bundlesOf(profile.id);
      if (bundles.isEmpty) continue;
      if (old.lastUpdateDate != profile.lastUpdateDate ||
          old.label != profile.label ||
          old.ageSecretKey != profile.ageSecretKey) {
        regenerate.addAll(bundles.map((bundle) => bundle.id));
      }
      if (old.subscriptionInfo != profile.subscriptionInfo ||
          !mapEquals(
            old.providerSubscriptions,
            profile.providerSubscriptions,
          )) {
        usageChanged = true;
      }
    }
    if (usageChanged) {
      scheduleMicrotask(_syncBundleUsages);
    }
    regenerate.removeAll(_refreshingBundleIds);
    if (regenerate.isNotEmpty) {
      scheduleBundles(regenerate);
    }
  }

  void _syncBundleUsages() {
    final profiles = _ref.read(profilesProvider);
    for (final profile in profiles) {
      if (profile.bundle == null) continue;
      final usages = _bundleUsages(profile, profiles);
      if (mapEquals(usages, profile.providerSubscriptions)) continue;
      setProfile(profile.copyWith(providerSubscriptions: usages));
    }
  }

  Map<String, SubscriptionInfo> _bundleUsages(
    Profile bundle,
    List<Profile> profiles,
  ) => {
    for (final member in bundle.bundle?.members ?? const <BundleMember>[])
      if (profiles.getProfile(member.id) case final target?)
        for (final usage in target.subscriptionUsages) usage.key: usage.value,
  };

  void _detachBundleMember(String id) {
    final regenerate = <String>[];
    for (final profile in _ref.read(profilesProvider).bundlesOf(id)) {
      final bundle = profile.bundle;
      if (bundle == null) continue;
      final members = [
        for (final member in bundle.members)
          if (member.id != id) member,
      ];
      setProfile(
        profile.copyWith(
          bundle: bundle.copyWith(
            members: members,
            failures: {...bundle.failures}..remove(id),
          ),
        ),
      );
      if (members.isNotEmpty) regenerate.add(profile.id);
    }
    scheduleBundles(regenerate);
  }

  Future<Profile> _generateBundle(
    Profile profile, {
    required bool refresh,
  }) async {
    final members = profile.bundle?.members ?? const <BundleMember>[];
    if (refresh) {
      for (final member in members) {
        final target = _ref.read(profilesProvider).getProfile(member.id);
        if (target == null || target.type != ProfileType.url) continue;
        try {
          await updateProfile(target);
        } catch (_) {}
      }
    }
    final profiles = _ref.read(profilesProvider);
    final script = profile.isManaged
        ? await ManagedScript.script(
            _ref.read(managedSettingProvider),
            nodeNames: _ref.read(nodesProvider).regionNodeNames,
          )
        : _ref.read(scriptStateProvider).findScript(profile.scriptId);
    final inputs = <({String prefix, String path})>[];
    final failures = <String, String>{};
    final files = <File>[];
    try {
      for (final member in members) {
        final target = profiles.getProfile(member.id);
        if (target == null) continue;
        try {
          final path = script == null
              ? await globalState.writeExpandedConfig(target, refresh: refresh)
              : await globalState.writeScriptedConfig(
                  target,
                  script,
                  managed: profile.isManaged,
                  expandProviders: true,
                  refresh: refresh,
                );
          files.add(File(path));
          inputs.add((
            prefix: member.prefix ?? bundlePrefixOf(target.label ?? target.id),
            path: path,
          ));
        } catch (e) {
          failures[member.id] = e.formatError.split('\n').first;
        }
      }
      if (inputs.isEmpty) {
        if (failures.isEmpty) throw appLocalizations.bundleNoMembers;
        throw [
          for (final entry in failures.entries)
            '${profiles.getProfile(entry.key)?.label ?? entry.key}: ${entry.value}',
        ].join('\n');
      }
      final report = await clashCore.mergeProfiles(
        output: await appPath.getProfilePath(profile.id),
        members: inputs,
        setup: await globalState.buildValidateParams(profile),
        nodesOnly: script == null,
      );
      return profile.copyWith(
        lastUpdateDate: DateTime.now(),
        providerSubscriptions: _bundleUsages(
          profile,
          _ref.read(profilesProvider),
        ),
        bundle: profile.bundle?.copyWith(
          report: report,
          failures: failures,
          scriptKey: script == null || profile.isManaged
              ? null
              : _bundleScriptKey(script),
        ),
      );
    } finally {
      for (final file in files) {
        try {
          if (await file.exists()) await file.delete();
        } catch (_) {}
      }
    }
  }

  void addLog(Log log) {
    _pendingLogs.add(log);
    throttler.call(
      FunctionTag.logs,
      _flushLogs,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _flushLogs() {
    if (_pendingLogs.isEmpty) return;
    final logs = List.of(_pendingLogs);
    _pendingLogs.clear();
    _ref.read(logsProvider.notifier).addLogs(logs);
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
    _ref.read(delayDataSourceProvider.notifier).flush();
    return _ref.read(sortNumProvider.notifier).add();
  }

  String? getCurrentGroupName() {
    final currentGroupName = _ref.read(
      currentProfileProvider.select((state) => state?.currentGroupName),
    );
    return currentGroupName;
  }

  ProxyCardState getProxyCardState(String proxyName) {
    return resolveProxyCardState(
      _ref.read(groupsProvider),
      _ref.read(selectedMapProvider),
      ProxyCardState(proxyName: proxyName),
    );
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
    await _initCore();
    if (await vpn_service.service?.isSmartStopped() ?? false) {
      await vpn_service.service?.resumeCore();
    }
    final updateParams = _ref.read(updateParamsProvider);
    final tunResult = await _requestAdmin(updateParams.tun.enable);
    if (tunResult.isError) return;

    final bool realTunEnable =
        tunResult.data ?? _ref.read(realTunEnableProvider);
    if (tunResult.needRestart) {
      await _restartCore();
      return;
    }

    final message = await clashCore.updateConfig(
      updateParams.copyWith.tun(enable: realTunEnable),
    );
    if (message.isNotEmpty) throw message;
    final previousMode = _appliedMode;
    _appliedMode = updateParams.mode;
    if (previousMode != null &&
        previousMode != updateParams.mode &&
        globalState.isStart &&
        _closeConnectionsOnSwitch) {
      await clashCore.closeConnections();
    }

    if (system.isDesktop) {
      final prefs = await preferences.sharedPreferencesCompleter.future;
      await prefs?.setBool('is_tun_running', realTunEnable);
    }
    scheduleIdleGc();
  }

  Future<Result<bool>> _requestAdmin(bool enableTun) async {
    final realTunEnable = _ref.read(realTunEnableProvider);
    final hasAdmin = await system.checkIsAdmin();
    if (enableTun && (!realTunEnable || !hasAdmin)) {
      final code = await system.authorizeCore();
      switch (code) {
        case AuthorizeCode.success:
          _ref.read(realTunEnableProvider.notifier).value = enableTun;
          return Result.success(enableTun, needRestart: true);
        case AuthorizeCode.none:
          break;
        case AuthorizeCode.error:
          commonPrint.warn('TUN disabled, authorization failed');
          globalState.showNotifier(
            appLocalizations.tunEnableRequireAdmin,
            actionLabel: appPath.isPortable ? appLocalizations.restart : null,
            onAction: appPath.isPortable ? system.restartAsAdmin : null,
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
        final configured = await _setupCoreConfig();
        if (configured) {
          scheduleIdleGc();
        }
      }, needLoading: false);
    });
  }

  Future<void> _applyProfile() async {
    _invalidateCoreReads();
    final configured = await _setupCoreConfig();
    if (!configured) return;
    _ref.read(delayDataSourceProvider.notifier).clear();
    _setProviders(await _loadProviders());
    await updateGroups();
    scheduleIdleGc();
  }

  Future<void> applyProfile({bool silence = false}) {
    return _coreLifecycleLock.synchronized(() async {
      if (silence) {
        try {
          await _applyProfile();
        } catch (err) {
          commonPrint.error('Apply profile failed: ${err.formatErrorLog}');
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
        _ref.read(isRestartingCoreProvider.notifier).value = true;
        try {
          await _restartCore();
          _ref.read(delayDataSourceProvider.notifier).clear();
        } catch (err) {
          _reportCoreRestartFailure(err);
          rethrow;
        } finally {
          _ref.read(isRestartingCoreProvider.notifier).value = false;
        }
      } else {
        final prevProfileId = _ref.read(currentProfileIdProvider);
        try {
          await _applyProfile();
        } catch (err) {
          commonPrint.error('Switch profile failed: ${err.formatErrorLog}');
          _ref.read(currentProfileIdProvider.notifier).value = prevProfileId;
          try {
            await _applyProfile();
          } catch (_) {}
          globalState.showNotifier(err.toString());
        }
        await clashCore.closeConnections();
        await clashCore.flushFakeIP();
        await clashCore.flushDnsCache();
      }
      _ref.read(logsProvider.notifier).clearCoreLogs();
      _ref.read(requestsProvider.notifier).value = FixedList(maxLength);
      globalState.computeHeightMapCache = {};
      addCheckIpNumDebounce();
    });
  }

  void _reportCoreRestartFailure(Object error) {
    final message = error.formatError;
    commonPrint.error('Restart core failed: ${error.formatErrorLog}');
    globalState.showNotifier('${appLocalizations.restartCoreTitle}: $message');
  }

  void updateBrightness() {
    _ref.read(systemBrightnessProvider.notifier).value =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  bool _isProfileUpdateNeeded(Profile profile) {
    if (!profile.autoUpdate) return false;
    if (profile.type != ProfileType.url) return false;
    if (profile.isUpdating) return false;
    final lastUpdate = profile.lastUpdateDate;
    if (lastUpdate == null) return true;
    final expectedNextUpdate = lastUpdate.add(profile.autoUpdateDuration);
    return DateTime.now().difference(expectedNextUpdate) >
        const Duration(minutes: 1);
  }

  Future<void> autoUpdateProfiles() async {
    for (final profile in _ref.read(profilesProvider)) {
      if (!_isProfileUpdateNeeded(profile)) continue;
      try {
        await updateProfile(profile, validate: false, applyUnchanged: false);
      } catch (_) {}
    }
  }

  Future<void> checkAndUpdateMissedProfiles() async {
    final profilesToUpdate = <Profile>[];
    for (final profile in _ref.read(profilesProvider)) {
      if (!_isProfileUpdateNeeded(profile)) continue;
      profilesToUpdate.add(profile);
    }
    if (profilesToUpdate.isNotEmpty) {
      for (final profile in profilesToUpdate) {
        try {
          await updateProfile(profile, validate: false, applyUnchanged: false);
        } catch (_) {}
        if (profilesToUpdate.length > 1) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }

    await _syncExternalProviders();
  }

  Future<void> _syncExternalProviders() async {
    try {
      final providers = await _loadProviders();
      if (providers.isEmpty) return;
      _setProviders(providers);
    } catch (e) {
      commonPrint.warn('Sync providers failed: $e', module: 'Profile');
    }
  }

  Future<void> updateGroups() {
    return _coreLifecycleLock.synchronized(_updateGroups);
  }

  static const List<Duration> _kGroupRetryDelays = [
    Duration.zero,
    Duration(milliseconds: 50),
    Duration(milliseconds: 150),
    Duration(milliseconds: 400),
  ];

  Future<List<Group>> _retryGetProxiesGroups() async {
    for (var attempt = 0; attempt < _kGroupRetryDelays.length; attempt++) {
      if (attempt > 0) {
        await Future.delayed(_kGroupRetryDelays[attempt]);
      }
      final groups = await clashCore.getProxiesGroups();
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
      commonPrint.warn('Update groups failed: $e');
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

  Future<void> _updateGroups() async {
    if (_isUpdatingGroups) {
      commonPrint.debug('Update groups busy, skipped');
      return;
    }
    _isUpdatingGroups = true;
    final generation = _coreGeneration;

    try {
      final currentGroups = _ref.read(groupsProvider);

      final newGroups = await _retryGetProxiesGroups();

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
        commonPrint.warn('Sync mode failed: $e');
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

      if (currentGroups.isNotEmpty) {
        bool activeProxyChanged = false;
        for (final newGroup in newGroups) {
          final oldGroup = currentGroups.firstWhereOrNull(
            (g) => g.name == newGroup.name,
          );
          if (oldGroup != null && oldGroup.now != newGroup.now) {
            activeProxyChanged = true;
            break;
          }
        }
        if (activeProxyChanged) {
          addCheckIpNumDebounce();
        }
      }

      _applyManagedProxiesStyle();
      applyListIconStyle(newGroups);

      if (!listEquals(currentGroups, newGroups)) {
        _ref.read(groupsProvider.notifier).value = newGroups;
      }
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

  void _applyManagedProxiesStyle() {
    final profile = _ref.read(currentProfileProvider);
    if (profile == null || !profile.isManaged || profile.managedStyleApplied) {
      return;
    }
    _ref
        .read(profilesProvider.notifier)
        .updateProfile(
          profile.id,
          (state) => state.copyWith(managedStyleApplied: true),
        );
    _ref.read(proxiesStyleSettingProvider.notifier).updateState((state) {
      return state.copyWith(
        type: ProxiesType.list,
        iconStyle: ProxiesIconStyle.icon,
        hasCustomizedStyle: true,
      );
    });
  }

  void applyListIconStyle([List<Group>? groups]) {
    final style = _ref.read(proxiesStyleSettingProvider);
    if (style.hasCustomizedStyle || style.type != ProxiesType.list) return;
    final List<Group> current = groups ?? _ref.read(groupsProvider);
    if (!current.any((group) => group.icon.trim().isNotEmpty)) return;
    _ref.read(proxiesStyleSettingProvider.notifier).updateState((state) {
      return state.copyWith(
        iconStyle: ProxiesIconStyle.icon,
        hasCustomizedStyle: true,
      );
    });
  }

  Future<void> updateProfiles() async {
    for (final profile in _ref.read(profilesProvider)) {
      if (profile.type != ProfileType.url) {
        continue;
      }
      try {
        await updateProfile(profile);
      } catch (_) {}
    }
  }

  Future<void> savePreferences() async {
    debouncer.cancel(FunctionTag.savePreferences);
    await preferences.saveConfig(globalState.config);
  }

  Future<void> changeProxy({
    required String groupName,
    required String proxyName,
  }) async {
    await clashCore.changeProxy(
      ChangeProxyParams(groupName: groupName, proxyName: proxyName),
    );
    if (_closeConnectionsOnSwitch) {
      await clashCore.closeGroupConnections(groupName);
    }
    addCheckIp();
    unawaited(_retestDialerDependents(groupName));
  }

  Future<void> _retestDialerDependents(String groupName) async {
    try {
      final names = (await clashCore.getDialerDependents(groupName)).toSet();
      if (names.isEmpty) return;
      final proxies = <String, Proxy>{
        for (final group in getCurrentGroups())
          for (final proxy in group.all)
            if (names.contains(proxy.name)) proxy.name: proxy,
      };
      if (proxies.isEmpty) return;
      await delayTest(proxies.values.toList());
    } catch (e) {
      commonPrint.warn('Dialer dependents retest failed: $e');
    }
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
      if (kDebugMode || appPath.isPortable) return;
      await helperClient.setProcessPriority(
        '${AppIdentity.coreExecutableName}.exe',
        enable,
      );
    } catch (e) {
      commonPrint.warn('Set process priority failed: $e', module: 'System');
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

    try {
      if (system.isDesktop) {
        try {
          await trayManager.destroy();
        } catch (e) {
          commonPrint.warn('Destroy tray failed: $e', module: 'System');
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
      commonPrint.warn('Exit cleanup failed: $e');
    } finally {
      try {
        await system.updateDns(true);
      } catch (e) {
        commonPrint.warn('Restore system DNS failed: $e', module: 'System');
      }
      if (!exitLock.isCompleted) {
        exitLock.complete();
      }
      unawaited(system.exit());
    }
  }

  Future<void> handleClear() async {
    await preferences.clearPreferences();
    commonPrint.log('Preferences cleared');
    globalState.config = Config(
      themeProps: defaultThemeProps,
      networkProps: defaultNetworkProps,
    );
  }

  Future<void> autoCheckUpdate() async {
    final prefs = await preferences.sharedPreferencesCompleter.future;
    final lastCheckTime = prefs?.getInt('last_check_update_time') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final isAutoCheck = _ref.read(appSettingProvider).autoCheckUpdate;

    final forceCheck =
        (now - lastCheckTime) > const Duration(days: 28).inMilliseconds;

    if (appUpdater.isSupported && !globalState.isPre) {
      unawaited(appUpdater.removeVersion(globalState.packageInfo.version));
    }

    if (!isAutoCheck && !forceCheck) return;

    final res = await request.checkForUpdate();
    if (res != null && !kDebugMode) {
      unawaited(_handleNewVersion(res));
    }

    await prefs?.setInt('last_check_update_time', now);
  }

  void _setAppUpdate(AppUpdate? update) {
    _ref.read(appUpdateStateProvider.notifier).value = update;
  }

  Future<void> _markAppUpdate(String tagName) async {
    final current = _ref.read(appUpdateStateProvider);
    if (current?.tagName == tagName) {
      final path = current?.filePath;
      if (current?.status != AppUpdateStatus.ready ||
          (path != null && File(path).existsSync())) {
        return;
      }
    }
    final downloaded = appUpdater.isSupported
        ? await appUpdater.findDownloaded(tagName)
        : null;
    final latest = _ref.read(appUpdateStateProvider);
    if (latest?.tagName == tagName &&
        latest?.status == AppUpdateStatus.downloading) {
      return;
    }
    _setAppUpdate(
      downloaded == null
          ? AppUpdate(tagName: tagName)
          : AppUpdate(
              tagName: tagName,
              status: AppUpdateStatus.ready,
              filePath: downloaded.path,
            ),
    );
  }

  Future<void> _handleNewVersion(Map<String, dynamic> data) async {
    await _markAppUpdate(data['tag_name'] as String);
    await _autoDownloadAppUpdate();
  }

  bool get _isAutoDownloadUpdate {
    final appSetting = _ref.read(appSettingProvider);
    return appSetting.autoCheckUpdate && appSetting.autoDownloadUpdate;
  }

  Future<void> _autoDownloadAppUpdate() async {
    if (!appUpdater.isSupported || !_isAutoDownloadUpdate) return;
    if (!globalState.isStart) return;
    await downloadAppUpdate(silent: true);
  }

  bool _downloadWatched = false;

  bool _isUpdateTag(String tagName) =>
      _ref.read(appUpdateStateProvider)?.tagName == tagName;

  void _notifyDownloading() {
    _downloadWatched = true;
    globalState.showNotifier(appLocalizations.updateDownloading);
  }

  Future<void> downloadAppUpdate({bool silent = false}) async {
    final update = _ref.read(appUpdateStateProvider);
    if (update == null || update.status != AppUpdateStatus.available) return;
    final tagName = update.tagName;
    _downloadWatched = !silent;
    _setAppUpdate(update.copyWith(status: AppUpdateStatus.downloading));
    if (!silent) {
      globalState.showNotifier(appLocalizations.updateDownloadStarted);
    }
    try {
      var percent = 0;
      final file = await appUpdater.download(tagName, (progress) {
        final next = (progress * 100).floor();
        if (next == percent || !_isUpdateTag(tagName)) return;
        percent = next;
        _setAppUpdate(
          AppUpdate(
            tagName: tagName,
            status: AppUpdateStatus.downloading,
            progress: progress,
          ),
        );
      });
      if (!_isUpdateTag(tagName)) return;
      _setAppUpdate(
        AppUpdate(
          tagName: tagName,
          status: AppUpdateStatus.ready,
          filePath: file.path,
        ),
      );
      if (_downloadWatched) {
        globalState.showNotifier(
          appLocalizations.updateDownloaded,
          onAction: () => unawaited(installAppUpdate()),
          actionLabel: appLocalizations.install,
          showCountdown: true,
        );
      }
    } catch (e) {
      if (!_isUpdateTag(tagName)) return;
      commonPrint.warn(
        'Download failed: ${e.formatErrorLog}',
        module: 'Update',
      );
      _setAppUpdate(AppUpdate(tagName: tagName));
      if (_downloadWatched) {
        globalState.showNotifier(appLocalizations.updateDownloadFailed);
      }
    }
  }

  Future<void> installAppUpdate() async {
    final update = _ref.read(appUpdateStateProvider);
    final path = update?.filePath;
    if (update == null || path == null) return;
    final file = File(path);
    if (!file.existsSync()) {
      _setAppUpdate(AppUpdate(tagName: update.tagName));
      return downloadAppUpdate();
    }
    if (globalState.isStart) {
      final res = await globalState.showMessage(
        title: appLocalizations.updateTip,
        message: TextSpan(
          text: appLocalizations.updateReadyAppTip(AppIdentity.displayName),
        ),
      );
      if (res != true) return;
      if (system.isAndroid || system.isLinux) {
        await updateStatus(false);
        _resumeAfterInstall = true;
      }
    }
    var installed = false;
    try {
      installed = await appUpdater.install(file);
    } catch (e) {
      commonPrint.warn('Install failed: ${e.formatErrorLog}', module: 'Update');
    }
    if (!installed) {
      globalState.showNotifier(appLocalizations.updateInstallFailed);
    }
    if (!installed || (system.isLinux && _exitLock == null)) {
      await resumeAfterInstall();
    }
  }

  static const _managedScriptBackupKey = 'managedScript';
  static const _backupDesktopKey = 'backupDesktop';
  static const _configBackupName = 'config.json';
  static const _profilesBackupName = 'profiles.json';
  static const _profileBackupKeys = {
    'profiles',
    'currentProfileId',
    'scriptProps',
    'managedProps',
    'nodes',
    _managedScriptBackupKey,
  };

  bool _resumeAfterInstall = false;

  Future<void> resumeAfterInstall() async {
    if (!_resumeAfterInstall) return;
    _resumeAfterInstall = false;
    await updateStatus(true);
  }

  Future<void> handleAppUpdate() async {
    final update = _ref.read(appUpdateStateProvider);
    if (update == null) return;
    final data = {'tag_name': update.tagName};
    if (!appUpdater.isSupported) return checkUpdateResultHandle(data: data);
    switch (update.status) {
      case AppUpdateStatus.available:
        return checkUpdateResultHandle(data: data);
      case AppUpdateStatus.downloading:
        _notifyDownloading();
      case AppUpdateStatus.ready:
        return installAppUpdate();
    }
  }

  Future<void> checkUpdateResultHandle({
    Map<String, dynamic>? data,
    bool handleError = false,
  }) async {
    if (data == null) {
      if (handleError) {
        unawaited(
          globalState.showMessage(
            title: appLocalizations.checkUpdate,
            message: TextSpan(text: appLocalizations.checkUpdateError),
            cancelable: false,
          ),
        );
      }
      return;
    }
    final tagName = data['tag_name'] as String;
    final tagStyle = context.textTheme.headlineSmall;
    await _markAppUpdate(tagName);
    final status = _ref.read(appUpdateStateProvider)?.status;
    final supported = appUpdater.isSupported;
    if (supported && status == AppUpdateStatus.downloading) {
      return _notifyDownloading();
    }
    final res = await globalState.showMessage(
      title: appLocalizations.discoverNewVersion,
      message: TextSpan(text: tagName, style: tagStyle),
      confirmText: !supported
          ? appLocalizations.goDownload
          : status == AppUpdateStatus.ready
          ? appLocalizations.install
          : appLocalizations.download,
      cancelText: supported ? appLocalizations.viewChangelog : null,
    );
    if (res == null || (!supported && !res)) return;
    if (!supported || !res) {
      return globalState.openUrl(appUpdater.releaseTagUrl(tagName));
    }
    return status == AppUpdateStatus.ready
        ? installAppUpdate()
        : downloadAppUpdate();
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
      if (await file.exists()) {
        await file.delete();
      }
      final configFile = File(await appPath.appConfigPath);
      if (await configFile.exists()) {
        await configFile.delete();
      }
    }
    await handleExit();
  }

  Future<void>? _initCoreFuture;

  Future<void> _initCore() {
    return _initCoreFuture ??= () async {
      try {
        if (!await _waitForCoreConnection()) {
          commonPrint.debug('Core not connected, init skipped');
          return;
        }
        final isInit = await clashCore.isInit;
        if (!isInit) {
          await clashCore.init();
          await clashCore.setState(globalState.getCoreState());
        }
      } finally {
        _initCoreFuture = null;
      }
    }();
  }

  Future<bool> _waitForCoreConnection() async {
    final completer = clashService?.socketCompleter;
    if (completer == null || completer.isCompleted) return true;
    try {
      await completer.future.timeout(const Duration(seconds: 15));
      return true;
    } on TimeoutException {
      return false;
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

  Future<void> holdWakelock(bool hold) async {
    try {
      if (hold) {
        await WakelockPlus.enable();
      } else if (!_ref.read(wakelockStateProvider)) {
        await WakelockPlus.disable();
      }
    } catch (e) {
      commonPrint.warn('Update wake lock failed: $e');
    }
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

  Future<void> init() async {
    FlutterError.onError = (details) {
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
        return;
      }
      commonPrint.error(details.exceptionAsString(), module: 'UI');
    };

    vpn_service.service?.addNativeEventCallback((method, arguments) async {
      if (method == 'log') {
        final data = arguments as Map? ?? const {};
        final message = '${data['message'] ?? ''}';
        if (data['level'] == 'error') {
          commonPrint.error(message, module: 'VPN');
        } else {
          commonPrint.warn(message, module: 'VPN');
        }
      } else if (method == 'vpnStartFailed') {
        globalState.showNotifier('Failed, Please try again later');
        await updateStatus(false);
      } else if (method == 'runStateChanged') {
        final state = arguments as String?;
        if (state == 'STOP' && globalState.isStart) {
          await updateStatus(false);
        }
      } else if (method == 'screenStateChanged') {
        await globalState.handleScreenStateChanged(arguments as bool? ?? true);
      }
    });

    if (system.isAndroid) {
      unawaited(app.isIgnoringBatteryOptimizations().catchError((_) => false));
    }

    try {
      final wakelockEnabled = await WakelockPlus.enabled;
      _ref.read(wakelockStateProvider.notifier).value = wakelockEnabled;

      if (wakelockEnabled) {
        startWakelockAutoRecovery();
      }
    } catch (e) {
      commonPrint.warn('Check wake lock failed: $e');
    }

    await updateTray(true);

    await _initCore();
    try {
      await _initStatus();
    } catch (e) {
      commonPrint.warn('Init status failed, applying profile: $e');
      try {
        await applyProfile(silence: true);
      } catch (_) {}
    }

    await updateGroups();
    unawaited(checkManagedScriptVersionUpgrade());
    syncScriptBundles();

    unawaited(
      autoLaunch?.updateStatus(_ref.read(appSettingProvider).autoLaunch),
    );
    Future.delayed(const Duration(seconds: 5), () {
      autoUpdateProfiles();
    });
    unawaited(autoCheckUpdate());

    final isWindowVisible = await window?.isVisible ?? false;
    if (isWindowVisible) {
      unawaited(window?.show());
    } else {
      if (!_ref.read(appSettingProvider).silentLaunch) {
        unawaited(window?.show());
      } else {
        unawaited(window?.hide());
      }
    }
    await syncDesktopRuntimeState(preferCurrentState: true);
    await updateTray(true, false, true);

    await _handlePreference();
    await _handlerDisclaimer();
    if (system.isWindows) {
      unawaited(
        setProcessPriority(
          _ref.read(appSettingProvider).enableHighPriority,
        ).catchError((e) {
          commonPrint.warn('Set process priority failed: $e', module: 'System');
        }),
      );
    }
    _ref.read(initProvider.notifier).value = true;
  }

  Future<bool?> _takeRestartAutoStart() async {
    if (!system.isAndroid) return null;
    final prefs = await preferences.sharedPreferencesCompleter.future;
    final record = prefs?.getStringList(restartAutoStartKey);
    if (record == null) return null;
    await prefs?.remove(restartAutoStartKey);
    final time = int.tryParse(record.elementAtOrNull(1) ?? '');
    if (record.length != 2 || time == null) return null;
    final age = DateTime.now().millisecondsSinceEpoch - time;
    if (age < 0 || age > const Duration(minutes: 1).inMilliseconds) return null;
    return record.first == '1';
  }

  Future<void> restartAndroidApp() async {
    final isSmartStopped = await vpn_service.service?.isSmartStopped() ?? false;
    final wasRunning =
        isSmartStopped ||
        globalState.isStart ||
        _ref.read(runTimeProvider.notifier).isStart;
    final prefs = await preferences.sharedPreferencesCompleter.future;
    await prefs?.setStringList(restartAutoStartKey, [
      wasRunning ? '1' : '0',
      '${DateTime.now().millisecondsSinceEpoch}',
    ]);
    if (wasRunning) {
      try {
        await updateStatus(false).timeout(const Duration(seconds: 3));
      } catch (e) {
        commonPrint.warn('Stop before restart failed: $e');
        await vpn_service.service?.stopVpn();
      }
    }
    await savePreferences();
    final result = await Restart.restartApp(forceKill: true);
    if (result.success) return;
    await prefs?.remove(restartAutoStartKey);
    if (wasRunning) await updateStatus(true);
  }

  Future<void> _initStatus() async {
    final prefs = await preferences.sharedPreferencesCompleter.future;
    final restartAutoStart = await _takeRestartAutoStart();

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
      commonPrint.warn('Abnormal exit detected');
      if (system.isAndroid) {
        await prefs?.setBool('is_vpn_running', false);
      }
    }
    if (!globalState.isStart) {
      await system.updateDns(true);
    }
    if (system.isAndroid && globalState.isStart) {
      await _coreLifecycleLock.synchronized(() async {
        await globalState.handleStart([updateRunTime, updateTraffic]);
      });
      _scheduleCheckIpRefresh();
      _backgroundLoad();
      return;
    }
    final hasProfile = _ref.read(currentProfileProvider) != null;
    final isSmartStopped =
        system.isAndroid &&
        (await vpn_service.service?.isSmartStopped() ?? false);
    final autoStart =
        restartAutoStart == true || _ref.read(appSettingProvider).autoRun;
    final shouldStart =
        hasProfile && !isSmartStopped && (globalState.isStart || autoStart);

    if (shouldStart) {
      try {
        await updateStatus(true);
      } catch (e) {
        commonPrint.error('Auto start failed: $e');
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
      final navigator = Navigator.of(context, rootNavigator: true);
      if (navigator.canPop()) {
        navigator.popUntil((route) => route.isFirst);
      }
    }
    final current = _ref.read(currentPageLabelProvider);
    if (current != pageLabel) {
      final profilesSlide = _ref.read(profilesSlideProvider.notifier);
      if (current == PageLabel.profiles) profilesSlide.leave();
      if (pageLabel == PageLabel.profiles) profilesSlide.enter();
    }
    _ref.read(currentPageLabelProvider.notifier).value = pageLabel;
  }

  void reselectPage(PageLabel pageLabel) {
    if (pageLabel != PageLabel.profiles) return;
    if (system.isAndroid &&
        _ref.read(appSettingProvider).enableNavBarHapticFeedback) {
      HapticFeedback.selectionClick();
    }
    _ref.read(profilesSlideProvider.notifier).toggle();
  }

  void toProfiles() {
    toPage(PageLabel.profiles);
  }

  bool _isRemoteFileUri(Uri uri) {
    if (!uri.isScheme('file')) return false;
    final host = uri.host.toLowerCase();
    final remoteHost =
        host.isNotEmpty &&
        host != 'localhost' &&
        !RegExp(r'^[a-z]$').hasMatch(host);
    return remoteHost ||
        uri.pathSegments.any((segment) => segment.contains('\\'));
  }

  void initLink() {
    linkManager.initAppLinksListen((url) async {
      final uri = Uri.tryParse(url);
      if (uri == null || _isRemoteFileUri(uri)) {
        globalState.showNotifier(
          appLocalizations.profileUrlInvalidValidationDesc,
        );
        return;
      }
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
      unawaited(addProfileFormURL(url));
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
        message: TextSpan(text: e.formatError),
        cancelable: false,
      );
    } finally {
      _ref.read(loadingProvider.notifier).value = false;
    }
  }

  Future<void> addProfileFormFile() async {
    final platformFiles = await safeRun(
      () => picker.pickerFiles(allowMultiple: true),
    );
    if (platformFiles == null || platformFiles.isEmpty) {
      return;
    }
    if (!context.mounted) return;

    const allowedExtensions = {'.yaml', '.yml', '.json', ''};
    final validFiles = platformFiles
        .where(
          (file) =>
              allowedExtensions.contains(extension(file.name).toLowerCase()),
        )
        .toList();

    if (validFiles.isEmpty) {
      return;
    }

    _ref.read(loadingProvider.notifier).value = true;
    int successCount = 0;
    try {
      for (final platformFile in validFiles) {
        try {
          final bytes = await platformFile.readAsBytes();
          if (bytes.isEmpty) continue;
          final profile = await Profile.normal(label: platformFile.name)
              .saveFile(bytes);
          await addProfile(profile);
          successCount++;
        } on Object catch (e) {
          if (!context.mounted) break;
          await globalState.showMessage(
            title: '${platformFile.name} (${appLocalizations.add})',
            message: TextSpan(text: e.formatError),
            cancelable: false,
          );
        }
      }

      if (successCount > 0) {
        globalState.navigatorKey.currentState?.popUntil(
          (route) => route.isFirst,
        );
        toProfiles();
      }
    } finally {
      _ref.read(loadingProvider.notifier).value = false;
    }
  }

  Future<void> addProfileFormQrCode() async {
    final url = await safeRun(picker.pickerConfigQRCode);
    if (url == null) return;
    unawaited(addProfileFormURL(url));
  }

  void updateViewSize(Size size) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_ref.read(viewSizeProvider) == size) return;
      _ref.read(viewSizeProvider.notifier).value = size;
    });
  }

  void setProvider(ExternalProvider? provider) {
    _ref.read(providersProvider.notifier).setProvider(provider);
    if (provider == null || provider.isUpdating) return;
    _syncProviderSubscriptions(_ref.read(providersProvider));
  }

  List<Proxy> getSortProxies({
    required List<Proxy> proxies,
    required ProxiesSortType sortType,
    String? testUrl,
  }) {
    if (sortType != ProxiesSortType.delay) {
      return sortProxies(proxies, sortType);
    }
    final delayOf = createDelayLookup(
      groups: _ref.read(groupsProvider),
      selectedMap: _ref.read(selectedMapProvider),
      delayMap: _ref.read(delayDataSourceProvider),
      defaultTestUrl: _ref.read(appSettingProvider).testUrl,
    );
    return sortProxies(
      proxies,
      sortType,
      delayOf: (proxyName) => delayOf(proxyName, testUrl),
    );
  }

  Future<void> clearEffect(String profileId) async {
    final profilePath = await appPath.getProfilePath(profileId);
    final providersDirPath = await appPath.getProvidersDirPath(profileId);
    final relayPath = await appPath.relayPath;
    await Isolate.run(() async {
      final profileFile = File(profilePath);
      final isExists = await profileFile.exists();
      if (isExists) {
        await profileFile.delete(recursive: true);
      }
      for (final stem in ['cache-$profileId', 'cache-$profileId-managed']) {
        for (final extension in const ['json', 'key']) {
          final cacheFile = File(join(relayPath, '$stem.$extension'));
          if (await cacheFile.exists()) {
            await cacheFile.delete();
          }
        }
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

  void updateAllowLan(bool value) {
    _ref
        .read(patchClashConfigProvider.notifier)
        .updateState((state) => state.copyWith(allowLan: value));
    if (value) unawaited(_ensureLanAccess());
  }

  Future<void> _ensureLanAccess() async {
    if (system.isAndroid) {
      if (await app.requestLocalNetworkPermission()) return;
      final confirmed = await globalState.showMessage(
        message: TextSpan(text: appLocalizations.localNetworkPermissionTip),
        confirmText: appLocalizations.openSettings,
      );
      if (confirmed == true) await app.openAppSettings();
      return;
    }
    final helperWindows = windows;
    if (helperWindows == null || !helperWindows.usesHelper) return;
    if (await helperWindows.hasCoreFirewallRule()) return;
    final confirmed = await globalState.showMessage(
      message: TextSpan(text: appLocalizations.lanFirewallTip),
      confirmText: appLocalizations.add,
    );
    if (confirmed == true) helperWindows.addCoreFirewallRule();
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
      unawaited(window?.show());
    } else {
      unawaited(window?.hide());
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
    final (managed, shared) = ref.read(
      profileOverrideStateProvider.select(
        (state) => (
          state.managed,
          rule != null && state.sharedRules.contains(rule.id),
        ),
      ),
    );
    final result = await globalState
        .showAdaptiveSheet<({Rule rule, bool shared})>(
          child: AddRuleDialog(
            rule: rule,
            shared: managed ? shared : null,
            snippet: ref.read(
              profileOverrideStateProvider.select((state) => state.snippet!),
            ),
          ),
        );
    if (result == null) {
      return;
    }
    final res = result.rule;
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
      return model.copyWith(
        sharedRules: result.shared
            ? {...state.sharedRules, res.id}
            : {
                for (final id in state.sharedRules)
                  if (id != res.id) id,
              },
      );
    });
  }

  Future<void> handleQuickAddRule(Metadata metadata) async {
    final profile = _ref.read(currentProfileProvider);
    if (profile == null) {
      globalState.showNotifier(appLocalizations.nullProfileDesc);
      return;
    }
    final snippet = await safeRun(
      () async => ClashConfigSnippet.fromJson(
        await globalState.getProfileSnippet(profile.id, effective: true),
      ),
      needLoading: true,
    );
    if (snippet == null) return;
    final managed = profile.isManaged;
    final result = await globalState
        .showAdaptiveSheet<({Rule rule, bool shared})>(
          child: AddRuleDialog(
            snippet: snippet,
            metadata: metadata,
            shared: managed ? true : null,
          ),
        );
    if (result == null) return;
    if (result.shared) {
      _ref
          .read(managedSettingProvider.notifier)
          .updateState(
            (state) => state.copyWith(rules: [result.rule, ...state.rules]),
          );
    } else {
      _ref.read(profilesProvider.notifier).updateProfile(profile.id, (state) {
        final overrideData = state.overrideData;
        return state.copyWith(
          overrideData: overrideData.copyWith(
            enable: true,
            rule: overrideData.rule.updateRules(
              (rules) => [result.rule, ...rules],
            ),
          ),
        );
      });
    }
    setupClashConfigDebounce();
    globalState.showNotifier(
      managed ? appLocalizations.ruleAdded : appLocalizations.nonManagedRuleTip,
      actionLabel: appLocalizations.view,
      onAction: () {
        if (!context.mounted) return;
        BaseNavigator.push(context, OverrideProfileView(profileId: profile.id));
      },
    );
  }

  Future<bool> exportLogs() async {
    final logsRaw = _ref
        .read(filteredLogsProvider)
        .logs
        .map((item) => item.line)
        .toList();
    final data = await Isolate.run<List<int>>(() async {
      final logsRawString = logsRaw.join('\n');
      return utf8.encode(logsRawString);
    });
    return await picker.saveFile(utils.logFile, Uint8List.fromList(data)) !=
        null;
  }

  Future<List<int>> backupData({
    String password = '',
    BackupScope scope = BackupScope.all,
  }) async {
    final homeDirPath = await appPath.homeDirPath;
    final profilesPath = await appPath.profilesPath;
    final scripts = await Future.wait(
      globalState.config.scriptProps.scripts.map(
        (script) async => script.copyWith(content: await script.readContent()),
      ),
    );
    final configJson = json.decode(
      json.encode(globalState.config.copyWith.scriptProps(scripts: scripts)),
    ) as Map<String, dynamic>;
    if (configJson['dav'] is Map) {
      final davMap = Map<String, dynamic>.from(configJson['dav'] as Map);
      if (davMap['user'] is String) {
        davMap['user'] = utils.encryptSecret(davMap['user'] as String);
      }
      if (davMap['password'] is String) {
        davMap['password'] = utils.encryptSecret(davMap['password'] as String);
      }
      configJson['dav'] = davMap;
    }
    if (configJson['appSetting'] case final Map<String, dynamic> appSetting) {
      appSetting.remove('backupPassword');
    }
    configJson[_backupDesktopKey] = system.isDesktop;
    final managedProps = globalState.config.managedProps;
    if (ManagedScript.isCustom(managedProps)) {
      configJson[_managedScriptBackupKey] = await ManagedScript.read(
        managedProps,
      );
    }
    final onlyProfiles = scope == BackupScope.onlyProfiles;
    if (onlyProfiles) {
      configJson.removeWhere((key, _) => !_profileBackupKeys.contains(key));
    }
    final configName = onlyProfiles ? _profilesBackupName : _configBackupName;

    // Get valid profile IDs
    final validProfileIds = globalState.config.profiles
        .map((p) => p.id)
        .toSet();
    final currentProfileId = globalState.config.currentProfileId;

    commonPrint.log(
      'Backing up ${validProfileIds.length} profiles',
      module: 'Backup',
    );

    return Isolate.run<List<int>>(() async {
      // Use ZipFileEncoder like FLClash - more reliable than ZipEncoder + Archive
      final tempDir = Directory.systemTemp;
      final tempZipPath = join(
        tempDir.path,
        'bettbox_backup_${DateTime.now().millisecondsSinceEpoch}.zip',
      );
      final encoder = ZipFileEncoder(
        password: password.isEmpty ? null : password,
      );
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
      await encoder.addFile(tempConfigFile, configName);
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

      unawaited(encoder.close());

      // Read the zip file and return bytes
      final zipFile = File(tempZipPath);
      final bytes = await zipFile.readAsBytes();
      await zipFile.delete();
      return bytes;
    });
  }

  Future<String> _webDAVBackupFingerprint(DAV dav) async {
    final profiles = _ref.read(profilesProvider);
    final profilesPath = await appPath.profilesPath;
    final meta = json.encode([
      dav.uri,
      dav.fileName,
      ...profiles.map(
        (profile) => profile.backupView.copyWith(lastUpdateDate: null),
      ),
      _ref.read(nodesProvider),
      _ref.read(scriptStateProvider),
      _ref.read(managedSettingProvider),
    ]);
    final ids = profiles.map((profile) => profile.id).toList();
    return Isolate.run(() {
      final builder = BytesBuilder(copy: false)..add(utf8.encode(meta));
      for (final id in ids) {
        final file = File(join(profilesPath, '$id.yaml'));
        if (!file.existsSync()) continue;
        final bytes = file.readAsBytesSync();
        builder
          ..add(utf8.encode('\n$id:${bytes.length}\n'))
          ..add(bytes);
      }
      return sha256.convert(builder.takeBytes()).toString();
    });
  }

  Future<bool> backupToWebDAV(
    DAVClient client,
    DAV dav, {
    BackupScope scope = BackupScope.all,
  }) async {
    final fingerprint = await _webDAVBackupFingerprint(dav);
    final data = await backupData(
      password: _ref.read(
        appSettingProvider.select((state) => state.backupPassword),
      ),
      scope: scope,
    );
    final res = await client.backup(Uint8List.fromList(data));
    if (res && scope == BackupScope.all) {
      final prefs = await preferences.sharedPreferencesCompleter.future;
      await prefs?.setString(_autoBackupFingerprintKey, fingerprint);
    }
    return res;
  }

  void autoBackupDebounce() {
    if (_isAutoBackupSuppressed) return;
    if (_ref.read(appDAVSettingProvider)?.autoBackup != true) return;
    debouncer.call(FunctionTag.autoBackup, () {
      _isAutoBackupPending = true;
      unawaited(flushAutoBackup());
    }, duration: const Duration(seconds: 10));
  }

  Future<void> flushAutoBackup() async {
    if (!_isAutoBackupPending ||
        _isAutoBackupRunning ||
        _isAutoBackupSuppressed) {
      return;
    }
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    if (lifecycleState != null && lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    final dav = _ref.read(appDAVSettingProvider);
    _isAutoBackupPending = false;
    if (dav == null || !dav.autoBackup) return;
    _isAutoBackupRunning = true;
    try {
      final fingerprint = await _webDAVBackupFingerprint(dav);
      final prefs = await preferences.sharedPreferencesCompleter.future;
      if (prefs?.getString(_autoBackupFingerprintKey) == fingerprint) {
        commonPrint.debug('Auto backup skipped, no changes', module: 'Backup');
        return;
      }
      final res = await backupToWebDAV(DAVClient(dav), dav);
      if (res) {
        globalState.showNotifier(appLocalizations.autoBackupSuccess);
      }
    } catch (e) {
      commonPrint.error(
        'Auto backup failed: ${e.formatErrorLog}',
        module: 'Backup',
      );
      globalState.showNotifier(
        appLocalizations.autoBackupFailed(e.formatError),
      );
    } finally {
      _isAutoBackupRunning = false;
    }
    if (_isAutoBackupPending) {
      unawaited(flushAutoBackup());
    }
  }

  Future<void> updateTray([
    bool focus = false,
    bool silent = false,
    bool force = false,
  ]) async {
    var trayState = _ref.read(trayStateProvider);
    if (tray.showHiddenGroups) {
      trayState = trayState.copyWith(
        groups: getVisibleGroups(
          mode: trayState.mode,
          groups: _ref.read(groupsProvider),
          showHiddenItems: true,
        ),
      );
    }
    await tray.update(
      trayState: trayState,
      focus: focus,
      silent: silent,
      force: force,
    );
  }

  Future<String?> _requestBackupPassword(bool wrong) async {
    if (wrong) {
      globalState.showNotifier(appLocalizations.backupPasswordWrong);
    }
    final loading = _ref.read(loadingProvider);
    if (loading) {
      _ref.read(loadingProvider.notifier).value = false;
    }
    final password = await globalState.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.backupPassword,
        value: '',
        hintText: appLocalizations.backupPasswordRequired,
        obscureText: true,
        autofocus: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.password);
          }
          return null;
        },
      ),
    );
    if (loading) {
      _ref.read(loadingProvider.notifier).value = true;
    }
    return password;
  }

  Future<({bool decrypted})?> _processRecoveryArchive(
    Future<({Archive archive, bool encrypted})> Function(String? password)
    getArchive,
    BackupScope recoveryOption,
  ) async {
    final savedPassword = _ref.read(
      appSettingProvider.select((state) => state.backupPassword),
    );
    String? password = savedPassword.isEmpty ? null : savedPassword;
    var userInput = false;
    _isAutoBackupSuppressed = true;
    try {
      while (true) {
        try {
          final (:archive, :encrypted) = await getArchive(password);
          commonPrint.debug(
            'Archive has ${archive.files.length} files',
            module: 'Backup',
          );
          await _recoveryFromArchive(archive, recoveryOption);
          if (userInput && password != null && savedPassword.isEmpty) {
            final value = password;
            _ref
                .read(appSettingProvider.notifier)
                .updateState((state) => state.copyWith(backupPassword: value));
          }
          return (decrypted: encrypted);
        } on BackupPasswordException catch (e) {
          final value = await _requestBackupPassword(e.wrong && userInput);
          if (value == null) return null;
          password = value;
          userInput = true;
        }
      }
    } on _RecoveryApplyException catch (e) {
      commonPrint.error(
        'Apply after restore failed: ${e.error}',
        module: 'Backup',
      );
      throw e.error;
    } catch (e) {
      commonPrint.error('Restore failed: $e', module: 'Backup');
      throw 'Backup file is corrupted or invalid: $e';
    } finally {
      debouncer.cancel(FunctionTag.autoBackup);
      _isAutoBackupPending = false;
      _isAutoBackupSuppressed = false;
    }
  }

  /// Restore data from bytes
  Future<({bool decrypted})?> recoveryData(
    List<int> data,
    BackupScope recoveryOption,
  ) async {
    commonPrint.log(
      'Restoring backup of ${data.length} bytes',
      module: 'Backup',
    );
    return _processRecoveryArchive(
      (password) => Isolate.run(
        () => decodeBackupArchive(InputMemoryStream(data), password),
      ),
      recoveryOption,
    );
  }

  /// Restore data from file path
  Future<({bool decrypted})?> recoveryDataFromFile(
    String path,
    BackupScope recoveryOption,
  ) async {
    commonPrint.log('Restoring from $path', module: 'Backup');
    return _processRecoveryArchive(
      (password) => Isolate.run(() {
        try {
          final input = InputFileStream(path);
          try {
            final result = decodeBackupArchive(input, password);
            if (result.archive.files.isNotEmpty) {
              return result;
            }
          } finally {
            input.close();
          }
        } on BackupPasswordException {
          rethrow;
        } catch (e) {
          commonPrint.warn('Decode stream failed: $e', module: 'Backup');
        }

        final bytes = File(path).readAsBytesSync();
        return decodeBackupArchive(InputMemoryStream(bytes), password);
      }),
      recoveryOption,
    );
  }

  /// Unified recovery entry: check marker and dispatch to recovery logic
  Future<void> _recoveryFromArchive(
    Archive archive,
    BackupScope recoveryOption,
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
    BackupScope recoveryOption,
    String homeDirPath,
  ) async {
    // Separate config and profile files
    final configs = archive.files
        .where(
          (item) =>
              item.name.endsWith('.json') && item.name != '.bettbox_marker',
        )
        .toList();
    final profileFiles = archive.files.where(
      (item) => !item.name.endsWith('.json') && item.name != '.bettbox_marker',
    );

    // Find config.json
    final configIndex = configs.indexWhere(
      (config) =>
          config.name == _configBackupName ||
          config.name == _profilesBackupName,
    );
    if (configIndex == -1) throw 'invalid backup file';

    // Parse config
    final configFile = configs[configIndex];
    final scope = configFile.name == _profilesBackupName
        ? BackupScope.onlyProfiles
        : recoveryOption;
    final configContent = configFile.content;
    if (configContent.isEmpty) {
      throw 'Config file is empty or corrupted';
    }
    final configJson =
        json.decode(utf8.decode(configContent)) as Map<String, Object?>;
    var tempConfig = Config.compatibleFromJson(configJson);
    if (tempConfig.dav != null) {
      tempConfig = tempConfig.copyWith(
        dav: tempConfig.dav!.copyWith(
          user: utils.decryptSecret(tempConfig.dav!.user),
          password: utils.decryptSecret(tempConfig.dav!.password),
        ),
      );
    }

    final recoveryStrategy = _ref.read(
      appSettingProvider.select((state) => state.recoveryStrategy),
    );
    ProfileRecovery? recovery;
    if (recoveryStrategy == RecoveryStrategy.override) {
      await _cleanProfilesDirForOverride();
    } else {
      recovery = ProfileRecovery.compatible(
        tempConfig.profiles,
        _ref.read(profilesProvider),
      );
      tempConfig = tempConfig.copyWith(
        profiles: recovery.profiles,
        currentProfileId: recovery.targetId(tempConfig.currentProfileId),
      );
    }

    await _restoreArchiveProfiles(
      tempConfig.profiles,
      profileFiles,
      homeDirPath,
      recovery: recovery,
    );

    tempConfig = tempConfig.copyWith(
      scriptProps: await tempConfig.scriptProps.externalize(),
    );
    final managedProps = configJson['managedProps'] is Map
        ? await _restoreManagedProps(
            tempConfig.managedProps,
            configJson[_managedScriptBackupKey],
          )
        : null;

    _recovery(
      tempConfig,
      scope,
      recovery: recovery,
      fromDesktop: switch (configJson[_backupDesktopKey]) {
        final bool value => value,
        _ => null,
      },
    );
    if (managedProps != null) {
      _ref.read(managedSettingProvider.notifier).value = managedProps;
    }
    await savePreferences();
    await _applyRecoveredProfile();
  }

  Future<void> _applyRecoveredProfile() async {
    if (!globalState.isStart) return;
    try {
      await applyProfile(silence: true);
    } catch (e) {
      throw _RecoveryApplyException(e);
    }
  }

  Future<ManagedProps> _restoreManagedProps(
    ManagedProps props,
    Object? script,
  ) async {
    if (script is String &&
        script.isNotEmpty &&
        ManagedScript.isCustom(props)) {
      return props.copyWith(syncedVersion: await ManagedScript.save(script));
    }
    await ManagedScript.restore();
    return props.copyWith(syncedVersion: null);
  }

  Future<void> _restoreArchiveProfiles(
    List<Profile> profiles,
    Iterable<ArchiveFile> files,
    String homeDirPath, {
    ProfileRecovery? recovery,
  }) async {
    final fileMap = <String, ArchiveFile>{};
    final otherFiles = <ArchiveFile>[];
    for (final file in files) {
      final name = file.name.replaceAll('\\', '/');
      if (!name.contains('/providers/') &&
          (name.endsWith('.yaml') || name.endsWith('.yml'))) {
        fileMap[basenameWithoutExtension(name)] = file;
      } else if (recovery == null) {
        otherFiles.add(file);
      } else if (recovery.providerFile(file, name) case final entry?) {
        otherFiles.add(entry);
      }
    }
    await restoreBackupFiles(otherFiles, homeDirPath);
    for (final profile in profiles) {
      for (final id in recovery?.sourceIds(profile.id) ?? [profile.id]) {
        final file = fileMap[id];
        if (file == null) continue;
        await profile.saveFile(file.content);
        break;
      }
    }
  }

  Future<void> _cleanProfilesDirForOverride() async {
    try {
      final profilesDirPath = await appPath.profilesPath;
      final dir = Directory(profilesDirPath);
      if (await dir.exists()) {
        await for (final entity in dir.list(followLinks: false)) {
          try {
            await entity.delete(recursive: true);
          } catch (e) {
            commonPrint.warn(
              'Delete profile file failed: $e',
              module: 'Backup',
            );
          }
        }
      }
    } catch (e) {
      commonPrint.warn('Clean profiles dir failed: $e', module: 'Backup');
    }
  }

  /// Restore legacy
  Future<void> _recoveryLegacyBackup(
    Archive archive,
    BackupScope recoveryOption,
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
      json.decode(utf8.decode(configContent)) as Map<String, Object?>,
    );

    final recoveryStrategy = _ref.read(
      appSettingProvider.select((state) => state.recoveryStrategy),
    );
    if (recoveryStrategy == RecoveryStrategy.override) {
      await _cleanProfilesDirForOverride();
    }

    List<Profile> profiles = [];

    if (backupConfig.profiles.isNotEmpty) {
      profiles = backupConfig.profiles;
    } else {
      for (final profileFile in profileFiles) {
        final fileName = profileFile.name.split('/').last;
        if (fileName.endsWith('.yaml') || fileName.endsWith('.yml')) {
          final id = fileName.replaceAll(RegExp(r'\.(yaml|yml)$'), '');
          final label = await _extractLabelFromYaml(profileFile) ?? id;

          profiles.add(
            Profile(
              id: id,
              label: label,
              autoUpdateDuration: defaultUpdateDuration,
              url: '',
            ),
          );
        }
      }
    }

    final recovery = recoveryStrategy == RecoveryStrategy.compatible
        ? ProfileRecovery.compatible(profiles, _ref.read(profilesProvider))
        : null;
    profiles = recovery?.profiles ?? profiles;
    await _restoreArchiveProfiles(
      profiles,
      profileFiles,
      homeDirPath,
      recovery: recovery,
    );

    Config limitedConfig = globalState.config.copyWith(profiles: profiles);

    if (system.isAndroid) {
      final vpnProps = backupConfig.vpnProps;
      AccessControl? accessControl;

      try {
        accessControl = vpnProps.accessControl;
      } catch (_) {
        try {
          final configJson = json.decode(
            utf8.decode(configFile.content),
          ) as Map<String, dynamic>;
          final vpnPropsJson = configJson['vpnProps'];
          if (vpnPropsJson != null && vpnPropsJson is Map) {
            final accessControlPropsJson = vpnPropsJson['accessControlProps'];
            if (accessControlPropsJson != null &&
                accessControlPropsJson is Map) {
              accessControl = AccessControl.fromJson(
                Map<String, dynamic>.from(accessControlPropsJson),
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

    _recoveryLimited(limitedConfig, recoveryOption);
    await savePreferences();
    await _applyRecoveredProfile();

    _showRecoveryResultMessage(profiles);
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
      commonPrint.warn('Read profile label failed: $e', module: 'Profile');
    }
    return null;
  }

  /// Show results
  void _showRecoveryResultMessage(List<Profile> profiles) {
    if (profiles.isEmpty) return;

    final hasEmptyUrl = profiles.any((p) => p.url.isEmpty);

    String message;
    if (hasEmptyUrl) {
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
  void _recoveryLimited(Config config, BackupScope recoveryOption) {
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
    _repairBundleScripts();
  }

  /// Full restore
  void _recovery(
    Config config,
    BackupScope recoveryOption, {
    ProfileRecovery? recovery,
    bool? fromDesktop,
  }) {
    final profiles = config.profiles;
    final override =
        _ref.read(appSettingProvider).recoveryStrategy ==
        RecoveryStrategy.override;

    _restoreProfiles(profiles);
    if (config.currentProfileId case final id?) {
      _ref.read(currentProfileIdProvider.notifier).value = id;
    }
    _restoreScripts(config.scriptProps, override);
    _restoreNodes(config.nodes, recovery, override);

    if (recoveryOption == BackupScope.all) {
      _restoreSettings(config, fromDesktop);
    }

    _ensureCurrentProfile(profiles);
    _repairBundleScripts();
  }

  void _restoreScripts(ScriptProps scriptProps, bool override) {
    final scriptIds = scriptProps.scripts.map((e) => e.id).toSet();
    final localScripts = _ref
        .read(scriptStateProvider)
        .scripts
        .where((script) => !scriptIds.contains(script.id));
    if (override) {
      for (final script in localScripts) {
        unawaited(script.deleteContent());
      }
      _ref.read(scriptStateProvider.notifier).value = scriptProps;
    } else {
      _ref.read(scriptStateProvider.notifier).value = scriptProps.copyWith(
        scripts: [...scriptProps.scripts, ...localScripts],
      );
    }
  }

  void _restoreNodes(
    List<ProxyNode> nodes,
    ProfileRecovery? recovery,
    bool override,
  ) {
    final restored = [
      for (final node in nodes)
        recovery == null
            ? node
            : node.copyWith(
                bindings: {
                  for (final entry in node.bindings.entries)
                    recovery.targetId(entry.key) ?? entry.key: entry.value,
                },
              ),
    ];
    if (override) {
      _ref.read(nodesProvider.notifier).value = restored;
      return;
    }
    final ids = {for (final node in restored) node.id};
    final names = {for (final node in restored) node.name};
    _ref.read(nodesProvider.notifier).value = [
      ...restored,
      for (final node in _ref.read(nodesProvider))
        if (!ids.contains(node.id) && !names.contains(node.name)) node,
    ];
  }

  void _restoreSettings(Config config, bool? fromDesktop) {
    final sameOrigin = fromDesktop == system.isDesktop;
    final foreign = fromDesktop != null && !sameOrigin;
    final localAppSetting = _ref.read(appSettingProvider);
    final localVpnProps = _ref.read(vpnSettingProvider);
    final localNetworkProps = _ref.read(networkSettingProvider);

    var appSetting = config.appSetting.copyWith(
      backupPassword: localAppSetting.backupPassword,
      recoveryStrategy: localAppSetting.recoveryStrategy,
    );
    var vpnProps = config.vpnProps;
    var networkProps = sameOrigin
        ? config.networkProps
        : config.networkProps.copyWith(
            bypassPrivateRouteAddress:
                localNetworkProps.bypassPrivateRouteAddress,
          );

    if (system.isDesktop) {
      vpnProps = vpnProps.copyWith(enable: localVpnProps.enable);
      if (foreign) {
        appSetting = appSetting.copyWith(
          silentLaunch: localAppSetting.silentLaunch,
          minimizeOnExit: localAppSetting.minimizeOnExit,
          closeConnections: localAppSetting.closeConnections,
          keepDockIcon: localAppSetting.keepDockIcon,
          enableHighPriority: localAppSetting.enableHighPriority,
          sidebarCollapsed: localAppSetting.sidebarCollapsed,
          sidebarFlyout: localAppSetting.sidebarFlyout,
          sidebarFlyoutOutsideTools: localAppSetting.sidebarFlyoutOutsideTools,
          sidebarFlyoutDelay: localAppSetting.sidebarFlyoutDelay,
          sidebarFlyoutEntries: localAppSetting.sidebarFlyoutEntries,
          desktopDashboardWidgets: localAppSetting.desktopDashboardWidgets,
          desktopDashboardSizes: localAppSetting.desktopDashboardSizes,
        );
        vpnProps = vpnProps.copyWith(
          networkFix: localVpnProps.networkFix,
          trayEnhancement: localVpnProps.trayEnhancement,
          trayLeftClickBehavior: localVpnProps.trayLeftClickBehavior,
          trayRightClickBehavior: localVpnProps.trayRightClickBehavior,
          enableTraySpeed: localVpnProps.enableTraySpeed,
          alwaysShowTitleBar: localVpnProps.alwaysShowTitleBar,
        );
        networkProps = networkProps.copyWith(
          systemProxy: localNetworkProps.systemProxy,
          profileSwitchMode: localNetworkProps.profileSwitchMode,
        );
      }
      _ref.read(patchClashConfigProvider.notifier).value = config
          .patchClashConfig
          .copyWith
          .tun(enable: _ref.read(patchClashConfigProvider).tun.enable);
      if (!foreign) {
        _ref.read(windowSettingProvider.notifier).value = config.windowProps;
        _ref.read(hotKeyActionsProvider.notifier).value = config.hotKeyActions;
      }
    } else {
      final accessControl = vpnProps.accessControl;
      final hasBackupAccessControl =
          accessControl.enable ||
          accessControl.acceptList.isNotEmpty ||
          accessControl.rejectList.isNotEmpty;
      if (!hasBackupAccessControl) {
        vpnProps = vpnProps.copyWith(
          accessControl: localVpnProps.accessControl,
        );
      }
      if (foreign) {
        appSetting = appSetting.copyWith(
          hidden: localAppSetting.hidden,
          enableNavBarHapticFeedback:
              localAppSetting.enableNavBarHapticFeedback,
          mobileDashboardWidgets: localAppSetting.mobileDashboardWidgets,
          mobileDashboardSizes: localAppSetting.mobileDashboardSizes,
        );
        vpnProps = vpnProps.copyWith(
          enable: localVpnProps.enable,
          systemProxy: localVpnProps.systemProxy,
          allowBypass: localVpnProps.allowBypass,
          dozeSuspend: localVpnProps.dozeSuspend,
          quickResponse: localVpnProps.quickResponse,
          storeFix: localVpnProps.storeFix,
          highPriorityNotification: localVpnProps.highPriorityNotification,
          networkSpeedNotification: localVpnProps.networkSpeedNotification,
        );
      }
      _ref.read(patchClashConfigProvider.notifier).value =
          config.patchClashConfig;
    }

    _ref.read(appSettingProvider.notifier).value = appSetting.copyWith(
      dashboardWidgets: system.isAndroid
          ? appSetting.mobileDashboardWidgets
          : appSetting.desktopDashboardWidgets,
    );
    _ref.read(vpnSettingProvider.notifier).value = vpnProps;
    _ref.read(networkSettingProvider.notifier).value = networkProps;
    if (config.dav case final dav?) {
      _ref.read(appDAVSettingProvider.notifier).value = dav;
    }
    _ref.read(themeSettingProvider.notifier).value = config.themeProps;
    _ref.read(proxiesStyleSettingProvider.notifier).value = config.proxiesStyle;
    _ref.read(trafficStatsSettingProvider.notifier).value =
        config.trafficStatsProps;
    _ref.read(overrideNtpProvider.notifier).value = config.overrideNtp;
    _ref.read(overrideSnifferProvider.notifier).value = config.overrideSniffer;
    _ref.read(overrideTunnelProvider.notifier).value = config.overrideTunnel;
    _ref.read(overrideExperimentalProvider.notifier).value =
        config.overrideExperimental;
    _ref.read(nodeExcludeFilterProvider.notifier).value =
        config.nodeExcludeFilter;
    _ref.read(healthCheckTimeoutProvider.notifier).value =
        config.healthCheckTimeout;
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
      commonPrint.error(e.formatErrorLog);
      final errorMessage = e.formatError;
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
}
