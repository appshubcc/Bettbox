import 'dart:convert';
import 'dart:io';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/path.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:synchronized/synchronized.dart';

class ToolHistoryStore {
  static const maxItems = 10;

  final _lock = Lock();
  bool _migrated = false;

  ToolHistoryStore._();

  static final instance = ToolHistoryStore._();

  String _storeKey(String key) => 'history:$key';

  Future<void> _migrate() async {
    if (_migrated) return;
    final file = File(await appPath.toolHistoryPath);
    if (!await file.exists()) {
      _migrated = true;
      return;
    }
    var legacy = <String, List<String>>{};
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map) {
        legacy = {
          for (final MapEntry(:key, :value) in decoded.entries)
            if (key is String && value is List)
              key: value.whereType<String>().take(maxItems).toList(),
        };
      }
    } catch (_) {}
    for (final MapEntry(:key, :value) in legacy.entries) {
      if (!await clashCore.storeSet(
        StoreSpace.toolbox,
        _storeKey(key),
        value,
      )) {
        return;
      }
    }
    await file.delete();
    _migrated = true;
  }

  Future<List<String>> _read(String key) async {
    await _migrate();
    final raw = await clashCore.storeGet(StoreSpace.toolbox, _storeKey(key));
    try {
      final decoded = raw.isEmpty ? null : json.decode(raw);
      return decoded is List
          ? decoded.whereType<String>().take(maxItems).toList()
          : <String>[];
    } catch (_) {
      return <String>[];
    }
  }

  Future<List<String>> load(String key) =>
      _lock.synchronized(() async => List.unmodifiable(await _read(key)));

  Future<List<String>> add(String key, String value) =>
      _lock.synchronized(() async {
        final items = [
          value,
          ...(await _read(key)).where((item) => item != value),
        ].take(maxItems).toList();
        await clashCore.storeSet(StoreSpace.toolbox, _storeKey(key), items);
        return List.unmodifiable(items);
      });

  Future<void> clear(String key) => _lock.synchronized(() async {
    await _migrate();
    await clashCore.storeSet(
      StoreSpace.toolbox,
      _storeKey(key),
      const <String>[],
    );
  });
}
