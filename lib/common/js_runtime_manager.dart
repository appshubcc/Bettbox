import 'dart:async';
import 'dart:convert';

import 'package:bett_box/common/common.dart';
import 'package:flutter_qjs/flutter_qjs.dart';
import 'package:synchronized/synchronized.dart';

class _ScriptOptionsCache {
  static final _entries = <String, Map<String, dynamic>>{};
  static const _maxEntries = 16;

  static Map<String, dynamic>? get(String content) {
    final key = _key(content);
    final v = _entries[key];
    if (v != null) {
      // Move to end (most recently used)
      _entries.remove(key);
      _entries[key] = v;
    }
    return v;
  }

  static void put(String content, Map<String, dynamic> value) {
    final key = _key(content);
    _entries[key] = value;
    while (_entries.length > _maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  static void remove(String content) {
    _entries.remove(_key(content));
  }

  static String _key(String content) {
    final bytes = utf8.encode(content);
    return '${bytes.length}_${bytes.fold<int>(0, (p, b) => (p * 31 + b) & 0x7fffffff)}';
  }
}

class JavaScriptRuntimeManager {
  static Future<Map<String, dynamic>> evaluateScript(
    String scriptContent,
    Map<String, dynamic> config, {
    Map<String, bool>? customOptions,
  }) async {
    final result = await _evaluateWithRetry(
      scriptContent,
      config,
      customOptions: customOptions,
    );
    if (result is Map) {
      return _deepCastMap(result);
    }
    return config;
  }

  static final Lock _engineLock = Lock();

  static Future<Map<String, dynamic>> extractScriptOptions(
    String scriptContent,
  ) async {
    final cached = _ScriptOptionsCache.get(scriptContent);
    if (cached != null) return cached;

    return _engineLock.synchronized(() async {
      // Double-check after acquiring lock
      final recached = _ScriptOptionsCache.get(scriptContent);
      if (recached != null) return recached;

      final engine = IsolateQjs();
      try {
        final res = await engine.evaluate('''
          var console = {
            log: function() {},
            warn: function() {},
            error: function() {},
            info: function() {},
            debug: function() {}
          };
          (function() {
            $scriptContent
            var options = typeof ruleOptionsEnable !== 'undefined' && ruleOptionsEnable && typeof ruleOptionsEnable === 'object' ? ruleOptionsEnable : {};
            var icons = {};
            if (typeof serviceConfigs !== 'undefined' && Array.isArray(serviceConfigs)) {
              for (var i = 0; i < serviceConfigs.length; i++) {
                var svc = serviceConfigs[i];
                if (svc && svc.name && typeof svc.icon === 'string') {
                  icons[svc.name] = svc.icon;
                }
              }
            }
            return JSON.stringify({ options: options, icons: icons });
          })();
        ''');

        final result = <String, dynamic>{};
        if (res is String) {
          final decoded = json.decode(res);
          if (decoded is Map) {
            result.addAll(_deepCastMap(decoded));
          }
        }
        _ScriptOptionsCache.put(scriptContent, result);
        return result;
      } catch (e) {
        commonPrint.log('extractScriptOptions error: $e');
        return {};
      } finally {
        try {
          await engine.close();
        } catch (e) {
          commonPrint.log('engine.close error: $e');
        }
      }
    });
  }

  static void invalidateCachedOptions(String scriptContent) {
    _ScriptOptionsCache.remove(scriptContent);
  }

  static bool hasCachedOptions(String scriptContent) {
    return _ScriptOptionsCache.get(scriptContent) != null;
  }

  static Map<String, dynamic>? getCachedOptions(String scriptContent) {
    return _ScriptOptionsCache.get(scriptContent);
  }

  static Future<dynamic> _evaluateWithRetry(
    String scriptContent,
    Map<String, dynamic> config, {
    Map<String, bool>? customOptions,
    int maxRetries = 1,
  }) async {
    var attempt = 0;
    while (true) {
      final engine = IsolateQjs();
      try {
        final configJs = json.encode(config);
        final customJs = customOptions != null && customOptions.isNotEmpty
            ? json.encode(customOptions)
            : null;
        final overrideSnippet = customJs != null
            ? 'if (typeof ruleOptionsEnable !== "undefined") { Object.assign(ruleOptionsEnable, $customJs); }'
            : '';

        return await engine.evaluate('''
          var console = {
            log: function(...args) { if (typeof print !== 'undefined') print(...args); },
            warn: function(...args) { if (typeof print !== 'undefined') print('WARN:', ...args); },
            error: function(...args) { if (typeof print !== 'undefined') print('ERROR:', ...args); },
            info: function(...args) { if (typeof print !== 'undefined') print('INFO:', ...args); },
            debug: function(...args) { if (typeof print !== 'undefined') print('DEBUG:', ...args); }
          };
          (function() {
            $scriptContent
            $overrideSnippet
            return main($configJs);
          })();
        ''');
      } catch (e) {
        if (attempt >= maxRetries) {
          throw 'JS Script Error: $e';
        }
        attempt++;
      } finally {
        try {
          await engine.close();
        } catch (e) {
          commonPrint.log('engine.close error: $e');
        }
      }
    }
  }

  static Map<String, dynamic> _deepCastMap(Map dynamicMap) {
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
