import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:code_forge/script.dart' as rust;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';

class _ScriptOptionsCache {
  static const _version = 1;
  static const _fileName = 'cache-script-options.json';
  static const _maxEntries = 16;
  static final _entries = <String, Map<String, dynamic>>{};
  static final _writeLock = Lock();
  static Future<void>? _loadFuture;

  static Future<String> get _filePath async =>
      p.join(await appPath.relayPath, _fileName);

  static String get _appVersion {
    final info = globalState.packageInfo;
    return '${info.version}+${info.buildNumber}';
  }

  static Future<void> ensureLoaded() => _loadFuture ??= _load();

  static Future<void> _load() async {
    try {
      final file = File(await _filePath);
      if (!await file.exists()) return;
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map ||
          decoded['version'] != _version ||
          decoded['app'] != _appVersion) {
        return;
      }
      final entries = decoded['entries'];
      if (entries is! Map) return;
      final current = Map.of(_entries);
      _entries.clear();
      for (final entry in entries.entries) {
        if (entry.value case final Map<dynamic, dynamic> map) {
          _entries[entry.key.toString()] =
              JavaScriptRuntimeManager._deepCastMap(map);
        }
      }
      _entries.addAll(current);
      _trim();
    } catch (_) {}
  }

  static void _trim() {
    while (_entries.length > _maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  static Map<String, dynamic>? get(String key) {
    final v = _entries[key];
    if (v != null) {
      _entries.remove(key);
      _entries[key] = v;
    }
    return v;
  }

  static Future<void> put(String key, Map<String, dynamic> value) {
    _entries.remove(key);
    _entries[key] = value;
    _trim();
    return _save();
  }

  static Future<void> _save() {
    return _writeLock.synchronized(() async {
      File? temp;
      try {
        final target = await _filePath;
        temp = File('$target.${DateTime.now().microsecondsSinceEpoch}.tmp');
        await temp.writeAsString(
          json.encode({
            'version': _version,
            'app': _appVersion,
            'entries': _entries,
          }),
          flush: true,
        );
        await temp.rename(target);
      } catch (_) {
        if (temp != null && await temp.exists()) {
          try {
            await temp.delete();
          } catch (_) {}
        }
      }
    });
  }

  static void resetMemory() {
    _entries.clear();
    _loadFuture = null;
  }
}

class JavaScriptRuntimeManager {
  static final Lock _engineLock = Lock();
  static final Random _random = Random();

  static Future<void> evaluateScriptFile({
    required String scriptContent,
    required String inputPath,
    required String outputPath,
    Map<String, bool>? customOptions,
  }) async {
    if (!await ensureRustLib()) {
      throw 'JS Script Error: script engine is unavailable';
    }
    try {
      final output = await rust.evaluateScriptFile(
        script: scriptContent,
        inputPath: inputPath,
        outputPath: outputPath,
        customOptions: customOptions != null && customOptions.isNotEmpty
            ? json.encode(customOptions)
            : null,
        token: _random.nextInt(1 << 31),
      );
      _printScriptLogs(output.logs);
    } on rust.ScriptError catch (e) {
      _printScriptLogs(e.logs);
      final stack = e.stack;
      throw 'JS Script Error: ${e.message}${stack == null ? '' : '\n$stack'}';
    }
  }

  static void _printScriptLogs(List<rust.ScriptLog> logs) {
    for (final log in logs) {
      switch (log.level) {
        case 'error':
          commonPrint.error(log.text, module: 'Script');
        case 'warn':
          commonPrint.warn(log.text, module: 'Script');
        case 'debug':
          commonPrint.debug(log.text, module: 'Script');
        default:
          commonPrint.log(log.text, module: 'Script');
      }
    }
  }

  static Future<Map<String, dynamic>> _extractScriptOptions(
    Script script, {
    required bool cache,
  }) async {
    final result = <String, dynamic>{};
    if (!await ensureRustLib()) {
      return result;
    }
    try {
      final decoded = json.decode(
        await rust.extractScriptOptions(script: await script.readContent()),
      );
      if (decoded is Map) {
        result.addAll(_deepCastMap(decoded));
      }
    } on rust.ScriptError catch (e) {
      commonPrint.warn('Read options failed: ${e.message}', module: 'Script');
      return <String, dynamic>{};
    } catch (e) {
      commonPrint.warn('Read options failed: $e', module: 'Script');
      return <String, dynamic>{};
    }
    if (cache) {
      unawaited(_ScriptOptionsCache.put(_cacheKey(script), result));
    }
    return result;
  }

  static String _cacheKey(Script script) => script.digest ?? script.id;

  static Future<void> preloadOptionsCache() =>
      _ScriptOptionsCache.ensureLoaded();

  static Future<Map<String, dynamic>> extractScriptOptions(
    Script script, {
    bool cache = true,
  }) async {
    if (!cache) {
      return _engineLock.synchronized(
        () => _extractScriptOptions(script, cache: false),
      );
    }
    await _ScriptOptionsCache.ensureLoaded();
    final key = _cacheKey(script);
    final cached = _ScriptOptionsCache.get(key);
    if (cached != null) return cached;

    return _engineLock.synchronized(() async {
      final recached = _ScriptOptionsCache.get(key);
      if (recached != null) return recached;
      return _extractScriptOptions(script, cache: true);
    });
  }

  static bool hasCachedOptions(Script script) {
    return _ScriptOptionsCache.get(_cacheKey(script)) != null;
  }

  static Map<String, dynamic>? getCachedOptions(Script script) {
    return _ScriptOptionsCache.get(_cacheKey(script));
  }

  @visibleForTesting
  static Future<void> seedCachedOptions(
    Script script,
    Map<String, dynamic> value,
  ) async {
    await _ScriptOptionsCache.ensureLoaded();
    await _ScriptOptionsCache.put(_cacheKey(script), value);
  }

  @visibleForTesting
  static void resetOptionsCacheMemory() => _ScriptOptionsCache.resetMemory();

  static Map<String, dynamic> _deepCastMap(Map<dynamic, dynamic> dynamicMap) {
    return dynamicMap.map<String, dynamic>((key, value) {
      return MapEntry(key.toString(), _deepCastValue(value));
    });
  }

  static dynamic _deepCastValue(dynamic value) {
    if (value is Map) {
      return _deepCastMap(value);
    } else if (value is List) {
      return value.map((e) => _deepCastValue(e)).toList();
    }
    return value;
  }
}
