import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:code_forge/script.dart' as rust;
import 'package:synchronized/synchronized.dart';

class _ScriptOptionsCache {
  static final _entries = <String, Map<String, dynamic>>{};
  static const _maxEntries = 16;

  static Map<String, dynamic>? get(String key) {
    final v = _entries[key];
    if (v != null) {
      // Move to end (most recently used)
      _entries.remove(key);
      _entries[key] = v;
    }
    return v;
  }

  static void put(String key, Map<String, dynamic> value) {
    _entries[key] = value;
    while (_entries.length > _maxEntries) {
      _entries.remove(_entries.keys.first);
    }
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
      commonPrint.log('[Script] ${log.level}: ${log.text}');
    }
  }

  static Future<Map<String, dynamic>> _extractScriptOptions(
    Script script,
  ) async {
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
      commonPrint.warn('extractScriptOptions error: ${e.message}');
      return <String, dynamic>{};
    } catch (e) {
      commonPrint.warn('extractScriptOptions error: $e');
      return <String, dynamic>{};
    }
    _ScriptOptionsCache.put(_cacheKey(script), result);
    return result;
  }

  static String _cacheKey(Script script) => script.digest ?? script.id;

  static Future<Map<String, dynamic>> extractScriptOptions(
    Script script,
  ) async {
    final cached = _ScriptOptionsCache.get(_cacheKey(script));
    if (cached != null) return cached;

    return _engineLock.synchronized(() async {
      // Double-check after acquiring lock
      final recached = _ScriptOptionsCache.get(_cacheKey(script));
      if (recached != null) return recached;
      return _extractScriptOptions(script);
    });
  }

  static bool hasCachedOptions(Script script) {
    return _ScriptOptionsCache.get(_cacheKey(script)) != null;
  }

  static Map<String, dynamic>? getCachedOptions(Script script) {
    return _ScriptOptionsCache.get(_cacheKey(script));
  }

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
