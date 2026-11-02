import 'dart:convert';
import 'dart:io';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Config _config(String label) => Config(
  themeProps: defaultThemeProps,
  profiles: [Profile.normal(label: label)],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory home;
  late String path;

  Future<SharedPreferences> prefs() async =>
      (await preferences.sharedPreferencesCompleter.future)!;

  Future<String?> savedLabel([String? target]) async {
    final file = File(target ?? path);
    if (!await file.exists()) return null;
    final config = Config.compatibleFromJson(
      json.decode(await file.readAsString()),
    );
    return config.profiles.firstOrNull?.label;
  }

  setUpAll(() async {
    home = await Directory.systemTemp.createTemp('bettbox_preferences_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => home.path,
        );
    SharedPreferences.setMockInitialValues({});
    path = await appPath.appConfigPath;
  });

  tearDownAll(() => home.delete(recursive: true));

  setUp(() async {
    for (final name in [path, '$path.bak']) {
      final file = File(name);
      if (await file.exists()) await file.delete();
    }
    await (await prefs()).clear();
    await preferences.getConfig();
  });

  test('并发保存时最后一次写入胜出', () async {
    final results = await Future.wait([
      for (var index = 0; index < 8; index++)
        preferences.saveConfig(_config('profile-$index')),
    ]);
    expect(results, everyElement(isTrue));
    expect(await savedLabel(), 'profile-7');
    expect(
      home.listSync().where((item) => item.path.endsWith('.tmp')),
      isEmpty,
    );
  });

  test('内容没变时不重复写盘，文件丢失时补写', () async {
    final config = _config('same');
    await preferences.saveConfig(config);
    final modified = await File(path).lastModified();
    await Future.delayed(const Duration(milliseconds: 20));
    await preferences.saveConfig(config);
    await preferences.saveConfig(config.copyWith());
    expect(await File(path).lastModified(), modified);
    await File(path).delete();
    await preferences.saveConfig(config.copyWith());
    expect(await savedLabel(), 'same');
    await preferences.saveConfig(_config('changed'));
    expect(await savedLabel(), 'changed');
  });

  test('配置文件损坏时回退到启动时备份', () async {
    await preferences.saveConfig(_config('good'));
    expect((await preferences.getConfig())?.profiles.single.label, 'good');
    expect(await savedLabel('$path.bak'), 'good');
    await File(path).writeAsString('{broken');
    final config = await preferences.getConfig();
    expect(config?.profiles.single.label, 'good');
    expect(await savedLabel(), 'good');
  });

  test('旧版镜像只用于恢复，并在写入后清除', () async {
    final store = await prefs();
    await store.setString(configKey, json.encode(_config('legacy')));
    final config = await preferences.getConfig();
    expect(config?.profiles.single.label, 'legacy');
    expect(await savedLabel(), 'legacy');
    expect(store.containsKey(configKey), isFalse);
  });

  test('不再把配置镜像写入 SharedPreferences', () async {
    await preferences.saveConfig(_config('file-only'));
    final store = await prefs();
    expect(store.containsKey(configKey), isFalse);
    expect(store.getBool('autoLaunch'), isFalse);
  });
}
