import 'dart:async';
import 'dart:convert';

import 'package:bett_box/models/media_unlock.dart';
import 'package:flutter/foundation.dart';

import 'preferences.dart';

typedef MediaUnlockResults = Map<String, Map<MediaPlatform, MediaUnlockResult>>;

class MediaUnlockStore {
  static const _key = 'mediaUnlockStatus';
  static const _legacyKey = 'ytUnlockStatus';
  static final _platforms = MediaPlatform.values.asNameMap();
  static final _statuses = MediaUnlockStatus.values.asNameMap();

  final results = ValueNotifier<MediaUnlockResults>(const {});
  Future<void> _writes = Future.value();

  Future<void> load() async {
    final prefs = await preferences.sharedPreferencesCompleter.future;
    final saved = prefs?.getString(_key);
    final decoded = _decodeMap(saved);
    final next = <String, Map<MediaPlatform, MediaUnlockResult>>{};
    for (final entry in decoded.entries) {
      final value = entry.value;
      if (value is! Map<String, dynamic>) continue;
      final platforms = <MediaPlatform, MediaUnlockResult>{};
      for (final entry in value.entries) {
        final platform = _platforms[entry.key];
        if (platform == null) continue;
        final result = _decodeResult(platform, entry.value);
        if (result != null) platforms[platform] = result;
      }
      if (platforms.isNotEmpty) {
        next[entry.key] = Map.unmodifiable(platforms);
      }
    }

    if (saved == null) {
      final legacy = _decodeMap(prefs?.getString(_legacyKey));
      for (final entry in legacy.entries) {
        if (entry.value case final String region) {
          next[entry.key] = Map.unmodifiable({
            MediaPlatform.youtube: _legacyResult(MediaPlatform.youtube, region),
          });
        }
      }
    }
    results.value = Map.unmodifiable(next);
    if (saved == null && next.isNotEmpty) await _save(results.value);
  }

  Future<void> update(String proxyName, MediaUnlockResult result) {
    final previous = results.value[proxyName];
    final oldResult = previous?[result.platform];
    if (oldResult != null &&
        mapEquals(_encodeResult(oldResult), _encodeResult(result))) {
      return _writes;
    }
    results.value =
        Map<String, Map<MediaPlatform, MediaUnlockResult>>.unmodifiable({
          ...results.value,
          proxyName: Map<MediaPlatform, MediaUnlockResult>.unmodifiable({
            ...?previous,
            result.platform: result,
          }),
        });
    return _save(results.value);
  }

  Future<void> _save(MediaUnlockResults snapshot) {
    _writes = _writes
        .then((_) async {
          final prefs = await preferences.sharedPreferencesCompleter.future;
          final data = {
            for (final node in snapshot.entries)
              node.key: {
                for (final result in node.value.values)
                  result.platform.name: _encodeResult(result),
              },
          };
          await prefs?.setString(_key, jsonEncode(data));
        })
        .catchError((Object error, StackTrace stack) {
          debugPrint('Failed to save media unlock status: $error');
        });
    return _writes;
  }

  static Map<String, dynamic> _decodeMap(String? json) {
    if (json == null) return const {};
    try {
      final decoded = jsonDecode(json);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }

  static MediaUnlockResult _legacyResult(
    MediaPlatform platform,
    String region,
  ) {
    return MediaUnlockResult(
      platform: platform,
      status: MediaUnlockStatus.unlocked,
      region: region,
    );
  }

  static MediaUnlockResult? _decodeResult(
    MediaPlatform platform,
    Object? value,
  ) {
    if (value is String) return _legacyResult(platform, value);
    if (value is! Map<String, dynamic>) return null;
    final status = _statuses[value['status']];
    if (status == null) return null;
    return MediaUnlockResult(
      platform: platform,
      status: status,
      region: switch (value['region']) {
        String value => value,
        _ => null,
      },
      latency: switch (value['latency']) {
        int value => value,
        _ => null,
      },
      colo: switch (value['colo']) {
        String value => value,
        _ => null,
      },
      ip: switch (value['ip']) {
        String value => value,
        _ => null,
      },
      isWarp: value['isWarp'] == true,
    );
  }

  static Map<String, Object> _encodeResult(MediaUnlockResult result) => {
    'status': result.status.name,
    'region': ?result.region,
    'latency': ?result.latency,
    'colo': ?result.colo,
    'ip': ?result.ip,
    if (result.isWarp) 'isWarp': true,
  };
}

final mediaUnlockStore = MediaUnlockStore();
