import 'dart:io';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;
  late MediaUnlockStore store;
  late Directory directory;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('bettbox_unlock_store_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => directory.path,
        );
    SharedPreferences.setMockInitialValues({});
    prefs = (await preferences.sharedPreferencesCompleter.future)!;
  });

  tearDownAll(() => directory.delete(recursive: true));

  setUp(() async {
    await prefs.clear();
    store = MediaUnlockStore();
  });

  tearDown(() => store.results.dispose());

  test('loads regions from the previous multi-platform format', () async {
    await prefs.setString(
      'mediaUnlockStatus',
      '{"node":{"claude":"SG","netflix":"","obsolete":"JP"}}',
    );

    await store.load();

    final results = store.results.value['node']!;
    expect(results.keys, [MediaPlatform.claude, MediaPlatform.netflix]);
    expect(results[MediaPlatform.claude]?.status, MediaUnlockStatus.unlocked);
    expect(results[MediaPlatform.claude]?.region, 'SG');
    expect(results[MediaPlatform.netflix]?.status, MediaUnlockStatus.unlocked);
  });

  test('imports the original YouTube-only format', () async {
    await prefs.setString('ytUnlockStatus', '{"node":"JP"}');

    await store.load();

    final result = store.results.value['node']?[MediaPlatform.youtube];
    expect(result?.status, MediaUnlockStatus.unlocked);
    expect(result?.region, 'JP');
    expect(prefs.getString('mediaUnlockStatus'), isNotNull);
  });

  test('persists detailed results and updates a node independently', () async {
    await Future.wait([
      store.update(
        'node',
        const MediaUnlockResult(
          platform: MediaPlatform.claude,
          status: MediaUnlockStatus.unlocked,
        ),
      ),
      store.update(
        'other',
        const MediaUnlockResult(
          platform: MediaPlatform.youtube,
          status: MediaUnlockStatus.unlocked,
        ),
      ),
      store.update(
        'node',
        const MediaUnlockResult(
          platform: MediaPlatform.claude,
          status: MediaUnlockStatus.blocked,
          region: 'SG',
          latency: 65,
          ip: '192.0.2.1',
          colo: 'SIN',
          isWarp: true,
        ),
      ),
    ]);

    await store.load();

    final result = store.results.value['node']?[MediaPlatform.claude];
    expect(result?.status, MediaUnlockStatus.blocked);
    expect(result?.region, 'SG');
    expect(result?.latency, 65);
    expect(result?.ip, '192.0.2.1');
    expect(result?.colo, 'SIN');
    expect(result?.isWarp, isTrue);
    expect(
      store.results.value['other']?[MediaPlatform.youtube]?.status,
      MediaUnlockStatus.unlocked,
    );
  });
}
