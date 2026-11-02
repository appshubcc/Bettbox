import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import 'constant.dart';
import 'path.dart';
import 'print.dart';

class Preferences {
  static Preferences? _instance;
  Completer<SharedPreferences?> sharedPreferencesCompleter = Completer();

  Future<bool> get isInit async =>
      await sharedPreferencesCompleter.future != null;

  Preferences._internal() {
    if (appPath.isPortable) {
      SharedPreferencesStorePlatform.instance = _FilePreferencesStore(
        appPath.sharedPreferencesPath,
      );
    }
    SharedPreferences.getInstance()
        .then((value) => sharedPreferencesCompleter.complete(value))
        .onError((_, _) => sharedPreferencesCompleter.complete(null));
  }

  factory Preferences() {
    _instance ??= Preferences._internal();
    return _instance!;
  }

  Future<ClashConfig?> getClashConfig() async {
    final preferences = await sharedPreferencesCompleter.future;
    final clashConfigString = preferences?.getString(clashConfigKey);
    if (clashConfigString == null) return null;
    try {
      final clashConfigMap = json.decode(clashConfigString);
      return ClashConfig.fromJson(clashConfigMap);
    } catch (e, stackTrace) {
      commonPrint.error(
        'Failed to parse clash config from preferences: $e\n$stackTrace',
      );
      return null;
    }
  }

  Config? _pendingConfig;
  Config? _lastConfig;
  String? _lastSaved;
  Future<bool>? _saving;

  Future<String?> _readText(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      return content.isEmpty ? null : content;
    } catch (_) {
      return null;
    }
  }

  Config? _parseConfig(String? content, String source) {
    if (content == null) return null;
    try {
      return Config.compatibleFromJson(json.decode(content));
    } catch (e, stackTrace) {
      commonPrint.error('Failed to parse config from $source: $e\n$stackTrace');
      return null;
    }
  }

  Future<void> _writeAtomic(String path, String content) async {
    final temp = File('$path.${DateTime.now().microsecondsSinceEpoch}.tmp');
    await temp.parent.create(recursive: true);
    await temp.writeAsString(content, flush: true);
    try {
      await temp.rename(path);
    } catch (_) {
      await temp.copy(path);
      await temp.delete();
    }
  }

  Future<void> _syncFlag(
    SharedPreferences? preferences,
    String key,
    bool value,
  ) async {
    if (preferences == null || preferences.getBool(key) == value) return;
    await preferences.setBool(key, value);
  }

  Future<Config?> getConfig() async {
    final preferences = await sharedPreferencesCompleter.future;
    final path = await appPath.appConfigPath;

    final content = await _readText(path);
    final fileConfig = _parseConfig(content, 'file');
    var selected = fileConfig;
    _lastConfig = null;
    _lastSaved = fileConfig != null ? content : null;
    if (fileConfig != null && content != null) {
      try {
        await _writeAtomic('$path.bak', content);
      } catch (e) {
        commonPrint.warn('Failed to back up config: $e');
      }
    } else {
      selected = _parseConfig(await _readText('$path.bak'), 'backup');
    }

    if (selected == null || selected.profiles.isEmpty) {
      final legacy = _parseConfig(
        preferences?.getString(configKey),
        'preferences',
      );
      if (legacy != null && (selected == null || legacy.profiles.isNotEmpty)) {
        selected = legacy;
      }
    }

    if (selected != null && !identical(selected, fileConfig)) {
      await saveConfig(selected);
    } else if (preferences?.containsKey(configKey) == true) {
      await preferences?.remove(configKey);
    }

    if (selected != null) {
      await _syncFlag(
        preferences,
        'autoLaunch',
        selected.appSetting.autoLaunch,
      );
      if (Platform.isMacOS) {
        await _syncFlag(
          preferences,
          'keepDockIcon',
          selected.appSetting.keepDockIcon,
        );
      }
    }

    return selected;
  }

  Future<bool> saveConfig(Config config) {
    _pendingConfig = config;
    return _saving ??= _drainConfig();
  }

  Future<bool> _drainConfig() async {
    var saved = true;
    try {
      for (
        var config = _pendingConfig;
        config != null;
        config = _pendingConfig
      ) {
        _pendingConfig = null;
        saved = await _writeConfig(config);
      }
    } finally {
      _saving = null;
    }
    return saved;
  }

  Future<bool> _writeConfig(Config config) async {
    if (identical(config, _lastConfig)) return true;
    final preferences = await sharedPreferencesCompleter.future;
    await _syncFlag(preferences, 'autoLaunch', config.appSetting.autoLaunch);
    if (Platform.isMacOS) {
      await _syncFlag(
        preferences,
        'keepDockIcon',
        config.appSetting.keepDockIcon,
      );
    }

    final jsonStr = await Isolate.run(() => json.encode(config));
    final path = await appPath.appConfigPath;
    if (jsonStr == _lastSaved && await File(path).exists()) {
      _lastConfig = config;
      return true;
    }

    try {
      await _writeAtomic(path, jsonStr);
      _lastSaved = jsonStr;
      _lastConfig = config;
    } catch (e, stackTrace) {
      commonPrint.error('Failed to save config to file: $e\n$stackTrace');
      return false;
    }

    if (preferences?.containsKey(configKey) == true) {
      try {
        await preferences?.remove(configKey);
      } catch (e) {
        commonPrint.warn('Failed to remove legacy config mirror: $e');
      }
    }
    return true;
  }

  Future<void> clearClashConfig() async {
    final preferences = await sharedPreferencesCompleter.future;
    preferences?.remove(clashConfigKey);
  }

  Future<void> clearPreferences() async {
    final sharedPreferencesIns = await sharedPreferencesCompleter.future;
    await sharedPreferencesIns?.clear();
    final path = await appPath.appConfigPath;
    for (final file in [File(path), File('$path.bak')]) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
    _lastSaved = null;
    _lastConfig = null;
    await clashCore.storeClear(StoreSpace.ip);
  }
}

final preferences = Preferences();

class _FilePreferencesStore extends SharedPreferencesStorePlatform {
  _FilePreferencesStore(this._path);

  static const _defaultPrefix = 'flutter.';

  final Future<String> _path;
  Map<String, Object>? _cache;

  Future<Map<String, Object>> _read() async {
    final cached = _cache;
    if (cached != null) return cached;
    final file = File(await _path);
    var data = <String, Object>{};
    if (file.existsSync()) {
      final content = file.readAsStringSync();
      if (content.isNotEmpty) {
        final decoded = json.decode(content);
        if (decoded is Map) {
          data = decoded.cast<String, Object>();
        }
      }
    }
    return _cache ??= data;
  }

  Future<bool> _write(Map<String, Object> data) async {
    try {
      final file = File(await _path);
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }
      file.writeAsStringSync(json.encode(data), flush: true);
      return true;
    } catch (e) {
      commonPrint.warn('Failed to write preferences: $e');
      return false;
    }
  }

  bool _matches(String key, PreferencesFilter filter) =>
      key.startsWith(filter.prefix) &&
      (filter.allowList?.contains(key) ?? true);

  @override
  Future<bool> remove(String key) async {
    final data = await _read();
    data.remove(key);
    return _write(data);
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    final data = await _read();
    data[key] = value;
    return _write(data);
  }

  @override
  Future<bool> clear() => clearWithParameters(
    ClearParameters(filter: PreferencesFilter(prefix: _defaultPrefix)),
  );

  @override
  Future<bool> clearWithParameters(ClearParameters parameters) async {
    final data = await _read();
    data.removeWhere((key, _) => _matches(key, parameters.filter));
    return _write(data);
  }

  @override
  Future<Map<String, Object>> getAll() => getAllWithParameters(
    GetAllParameters(filter: PreferencesFilter(prefix: _defaultPrefix)),
  );

  @override
  Future<Map<String, Object>> getAllWithParameters(
    GetAllParameters parameters,
  ) async {
    final data = Map<String, Object>.from(await _read());
    data.removeWhere((key, _) => !_matches(key, parameters.filter));
    return data;
  }
}
