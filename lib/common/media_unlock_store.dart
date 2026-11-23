import 'dart:async';
import 'dart:convert';

import 'package:bett_box/models/media_unlock.dart';
import 'package:flutter/foundation.dart';

import 'preferences.dart';

class MediaUnlockStore {
  static const _key = 'mediaUnlockStatus';
  static const _legacyKey = 'ytUnlockStatus';
  final status = ValueNotifier<Map<String, Map<String, String>>>({});
  Future<void> _writes = Future.value();

  Future<void> load() async {
    final prefs = await preferences.sharedPreferencesCompleter.future;
    final result = <String, Map<String, String>>{};
    try {
      final decoded = jsonDecode(prefs?.getString(_key) ?? '{}');
      if (decoded is Map) {
        for (final entry in decoded.entries) {
          if (entry.key is! String || entry.value is! Map) continue;
          final platforms = <String, String>{};
          for (final platform in (entry.value as Map).entries) {
            if (platform.key is String && platform.value is String) {
              platforms[platform.key as String] = platform.value as String;
            }
          }
          if (platforms.isNotEmpty) result[entry.key as String] = platforms;
        }
      }
    } catch (_) {}
    // Preserve badges saved by the previous YouTube-only version.
    if (prefs?.getString(_key) == null) {
      try {
        final legacy = jsonDecode(prefs?.getString(_legacyKey) ?? '{}');
        if (legacy is Map) {
          for (final entry in legacy.entries) {
            if (entry.key is String && entry.value is String) {
              result[entry.key as String] = {
                MediaPlatform.youtube.name: entry.value as String,
              };
            }
          }
        }
      } catch (_) {}
    }
    status.value = Map.unmodifiable(result.map(
      (key, value) => MapEntry(key, Map<String, String>.unmodifiable(value)),
    ));
    if (prefs?.getString(_key) == null && result.isNotEmpty) {
      await prefs?.setString(_key, jsonEncode(result));
    }
  }

  Future<void> update(String proxyName, MediaUnlockResult result) {
    final region = (result.region ?? '').trim().toUpperCase();
    final platform = result.platform.name;
    final unlocked = result.status == MediaUnlockStatus.unlocked &&
        !(result.platform == MediaPlatform.youtube && region == 'CN');
    final next = Map<String, Map<String, String>>.from(status.value);
    final platforms = Map<String, String>.from(next[proxyName] ?? {});
    if (unlocked) {
      if (platforms[platform] == region) return _writes;
      platforms[platform] = region;
    } else {
      if (!platforms.containsKey(platform)) return _writes;
      platforms.remove(platform);
    }
    if (platforms.isEmpty) {
      next.remove(proxyName);
    } else {
      next[proxyName] = Map.unmodifiable(platforms);
    }
    status.value = Map.unmodifiable(next);
    final json = jsonEncode(next);
    _writes = _writes.then((_) async {
      final prefs = await preferences.sharedPreferencesCompleter.future;
      await prefs?.setString(_key, json);
    }).catchError((Object error, StackTrace stack) {
      debugPrint('Failed to save media unlock status: $error');
    });
    return _writes;
  }
}

final mediaUnlockStore = MediaUnlockStore();
