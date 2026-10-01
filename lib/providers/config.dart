import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/config.g.dart';

/// 自定义开关是否有变化（Map 没有值相等语义，这里逐项比）。
bool _sameCustomOptions(Map<String, bool>? a, Map<String, bool>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == null && b == null;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}

@riverpod
class AppSetting extends _$AppSetting with AutoDisposeNotifierMixin {
  @override
  AppSettingProps build() {
    return globalState.config.appSetting;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(appSetting: value);
  }

  void updateState(AppSettingProps Function(AppSettingProps state) builder) {
    state = builder(state).copyWith(minimizeOnExit: true);
  }
}

@riverpod
class WindowSetting extends _$WindowSetting with AutoDisposeNotifierMixin {
  @override
  WindowProps build() {
    return globalState.config.windowProps;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(windowProps: value);
  }

  void updateState(WindowProps Function(WindowProps state) builder) {
    state = builder(state);
  }
}

@riverpod
class VpnSetting extends _$VpnSetting with AutoDisposeNotifierMixin {
  @override
  VpnProps build() {
    return globalState.config.vpnProps;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(vpnProps: value);
  }

  void updateState(VpnProps Function(VpnProps state) builder) {
    state = builder(state);
  }
}

@riverpod
class NetworkSetting extends _$NetworkSetting with AutoDisposeNotifierMixin {
  @override
  NetworkProps build() {
    return globalState.config.networkProps;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(networkProps: value);
  }

  void updateState(NetworkProps Function(NetworkProps state) builder) {
    state = builder(state);
  }
}

@riverpod
class ThemeSetting extends _$ThemeSetting with AutoDisposeNotifierMixin {
  @override
  ThemeProps build() {
    return globalState.config.themeProps;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(themeProps: value);
  }

  void updateState(ThemeProps Function(ThemeProps state) builder) {
    state = builder(state);
  }
}

@riverpod
class Profiles extends _$Profiles with AutoDisposeNotifierMixin {
  @override
  List<Profile> build() {
    return globalState.config.profiles;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(profiles: value);
  }

  String? _getLabel(String? label, String id) {
    final realLabel = label ?? id;
    final hasDup =
        state.indexWhere(
          (element) => element.label == realLabel && element.id != id,
        ) !=
        -1;
    if (hasDup) {
      return _getLabel(utils.getOverwriteLabel(realLabel), id);
    } else {
      return label;
    }
  }

  void setProfile(Profile profile) {
    final List<Profile> profilesTemp = List.from(state);
    final index = profilesTemp.indexWhere(
      (element) => element.id == profile.id,
    );
    final updateProfile = profile.copyWith(
      label: _getLabel(profile.label, profile.id),
    );
    if (index == -1) {
      profilesTemp.add(updateProfile);
    } else {
      profilesTemp[index] = updateProfile;
    }
    state = profilesTemp;
  }

  void updateProfile(
    String profileId,
    Profile Function(Profile profile) builder,
  ) {
    final List<Profile> profilesTemp = List.from(state);
    final index = profilesTemp.indexWhere((element) => element.id == profileId);
    if (index != -1) {
      profilesTemp[index] = builder(profilesTemp[index]);
    }
    state = profilesTemp;
  }

  void deleteProfileById(String id) {
    state = state.where((element) => element.id != id).toList();
  }
}

@riverpod
class CurrentProfileId extends _$CurrentProfileId
    with AutoDisposeNotifierMixin {
  @override
  String? build() {
    return globalState.config.currentProfileId;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(currentProfileId: value);
  }
}

@riverpod
class AppDAVSetting extends _$AppDAVSetting with AutoDisposeNotifierMixin {
  @override
  DAV? build() {
    return globalState.config.dav;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(dav: value);
  }

  void updateState(DAV? Function(DAV? state) builder) {
    state = builder(state);
  }
}

@riverpod
class OverrideDns extends _$OverrideDns with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return globalState.config.overrideDns;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(overrideDns: value);
  }
}

@riverpod
class OverrideTestUrl extends _$OverrideTestUrl with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return globalState.config.overrideTestUrl;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(overrideTestUrl: value);
  }
}

@riverpod
class OverrideNtp extends _$OverrideNtp with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return globalState.config.overrideNtp;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(overrideNtp: value);
  }
}

@riverpod
class OverrideSniffer extends _$OverrideSniffer with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return globalState.config.overrideSniffer;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(overrideSniffer: value);
  }
}

@riverpod
class OverrideTunnel extends _$OverrideTunnel with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return globalState.config.overrideTunnel;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(overrideTunnel: value);
  }
}

@riverpod
class OverrideExperimental extends _$OverrideExperimental
    with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return globalState.config.overrideExperimental;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(
      overrideExperimental: value,
    );
  }
}

@riverpod
class HotKeyActions extends _$HotKeyActions with AutoDisposeNotifierMixin {
  @override
  List<HotKeyAction> build() {
    return globalState.config.hotKeyActions;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(hotKeyActions: value);
  }
}

@riverpod
class ProxiesStyleSetting extends _$ProxiesStyleSetting
    with AutoDisposeNotifierMixin {
  @override
  ProxiesStyle build() {
    return globalState.config.proxiesStyle;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(proxiesStyle: value);
  }

  void updateState(ProxiesStyle Function(ProxiesStyle state) builder) {
    state = builder(state);
  }
}

@riverpod
class ScriptState extends _$ScriptState with AutoDisposeNotifierMixin {
  @override
  ScriptProps build() {
    return globalState.config.scriptProps;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(scriptProps: value);
  }

  void setScript(Script script) {
    // 内置脚本用不到的开关（链式代理）不允许落盘：存量数据里开着也在这里归零，
    // 免得它被当成 true 传给脚本、把整份配置跑崩
    final options = script.customOptions;
    if (script.id == builtinScriptId && options != null && options.isNotEmpty) {
      script = script.copyWith(
        customOptions: builtinScriptCustomOptions(options),
      );
    }
    final list = List<Script>.from(state.scripts);
    final index = list.indexWhere((item) => item.id == script.id);
    final previous = index == -1 ? null : list[index];
    if (index != -1) {
      list[index] = script;
    } else {
      list.add(script);
    }
    state = state.copyWith(scripts: list);
    // 内置脚本是合并配置的产出源：内容（编辑 / 同步）或自定义开关一改，
    // 已有的合并配置就过期了，这里立刻触发一次重新合并。
    final isBuiltinChanged =
        script.id == builtinScriptId &&
        (previous == null ||
            previous.content != script.content ||
            !_sameCustomOptions(previous.customOptions, script.customOptions));
    if (isBuiltinChanged && globalState.isInit) {
      unawaited(globalState.appController.regenerateBundles());
    }
  }

  void setId(String id) {
    state = state.copyWith(currentId: state.currentId != id ? id : null);
  }

  void del(String id) {
    final list = List<Script>.from(state.scripts);
    final index = list.indexWhere((item) => item.label == id);
    if (index == -1) {
      return;
    }
    // 内置脚本随包分发，用户不可删除。
    if (list[index].id == builtinScriptId) {
      return;
    }
    list.removeAt(index);
    final nextId = id == state.currentId ? null : state.currentId;
    state = state.copyWith(scripts: list, currentId: nextId);
  }

  bool isExits(String label) {
    return state.scripts.indexWhere((item) => item.label == label) != -1;
  }

  String getAvailableLabel(String baseLabel) {
    if (!isExits(baseLabel)) {
      return baseLabel;
    }
    var i = 1;
    while (isExits('$baseLabel$i')) {
      i++;
    }
    return '$baseLabel$i';
  }

  Future<void> syncScript(String id) async {
    final script = state.scripts.firstWhere((item) => item.id == id);
    final url = script.url;
    if (url == null || url.isEmpty) return;
    final res = await request.getTextResponseForUrl(url);
    if (script.content != res.data) {
      JavaScriptRuntimeManager.invalidateCachedOptions(script.content);
    }
    final updated = script.copyWith(content: res.data);
    setScript(updated);
  }
}

@riverpod
class PatchClashConfig extends _$PatchClashConfig
    with AutoDisposeNotifierMixin {
  @override
  ClashConfig build() {
    return globalState.config.patchClashConfig;
  }

  void updateState(ClashConfig? Function(ClashConfig state) builder) {
    final newState = builder(state);
    if (newState == null) {
      return;
    }
    state = newState;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(patchClashConfig: value);
  }
}

@riverpod
class NodeExcludeFilter extends _$NodeExcludeFilter
    with AutoDisposeNotifierMixin {
  @override
  String build() {
    return globalState.config.nodeExcludeFilter;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(nodeExcludeFilter: value);
  }

  void updateState(String Function(String state) builder) {
    state = builder(state);
  }
}

@riverpod
class HealthCheckTimeout extends _$HealthCheckTimeout
    with AutoDisposeNotifierMixin {
  @override
  int build() {
    return globalState.config.healthCheckTimeout;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(healthCheckTimeout: value);
  }

  void updateState(int Function(int state) builder) {
    state = builder(state);
  }
}

