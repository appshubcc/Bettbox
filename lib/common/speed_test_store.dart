import 'dart:convert';
import 'dart:io';

import 'package:bett_box/clash/clash.dart';
import 'package:bett_box/common/path.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:synchronized/synchronized.dart';

class SpeedTestStore {
  static const _settingsKey = 'speedTestSettings';

  final _lock = Lock();
  bool _migrated = false;

  SpeedTestStore._();

  static final instance = SpeedTestStore._();

  Future<void> _migrate() async {
    if (_migrated) return;
    final file = File(await appPath.speedTestPath);
    if (!await file.exists()) {
      _migrated = true;
      return;
    }
    SpeedTestData? legacy;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map) {
        legacy = SpeedTestData.fromJson(Map<String, Object?>.from(decoded));
      }
    } catch (_) {}
    if (legacy != null) {
      final saved = [
        await clashCore.storeSet(
          StoreSpace.toolbox,
          _settingsKey,
          legacy.settings.toJson(),
        ),
        for (final record in legacy.records)
          await clashCore.storeSet(
            StoreSpace.speedTest,
            '${record.time}',
            record.toJson(),
            time: record.time,
          ),
      ];
      if (saved.contains(false)) return;
    }
    await file.delete();
    _migrated = true;
  }

  Future<SpeedTestData> _read() async {
    final settings = await clashCore.storeGet(StoreSpace.toolbox, _settingsKey);
    final records = await clashCore.storeList(StoreSpace.speedTest);
    try {
      final settingsJson = settings.isEmpty ? null : json.decode(settings);
      final recordsJson = records.isEmpty ? null : json.decode(records);
      return SpeedTestData(
        settings: settingsJson is Map<String, Object?>
            ? SpeedTestSettings.fromJson(settingsJson)
            : const SpeedTestSettings(),
        records: [
          if (recordsJson is List)
            for (final item in recordsJson.whereType<Map<String, Object?>>())
              SpeedTestRecord.fromJson(item),
        ],
      );
    } catch (_) {
      return const SpeedTestData();
    }
  }

  Future<SpeedTestData> _update([Future<void> Function()? write]) {
    return _lock.synchronized(() async {
      await _migrate();
      await write?.call();
      return _read();
    });
  }

  Future<SpeedTestData> load() => _update();

  Future<SpeedTestData> addRecord(SpeedTestRecord record) => _update(
    () => clashCore.storeSet(
      StoreSpace.speedTest,
      '${record.time}',
      record.toJson(),
      time: record.time,
    ),
  );

  Future<SpeedTestData> saveSettings(SpeedTestSettings settings) => _update(
    () =>
        clashCore.storeSet(StoreSpace.toolbox, _settingsKey, settings.toJson()),
  );

  Future<SpeedTestData> clearRecords() =>
      _update(() => clashCore.storeClear(StoreSpace.speedTest));
}

final speedTestStore = SpeedTestStore.instance;
