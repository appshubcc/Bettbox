import 'dart:io';

import 'package:bett_box/clash/core.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory home;
  late File bundle;
  late File version;
  late int bundledLength;

  void setVersion(String version, String buildNumber) {
    globalState.packageInfo = PackageInfo(
      appName: 'Bettbox',
      packageName: 'test',
      version: version,
      buildNumber: buildNumber,
    );
  }

  setUp(() async {
    home = await Directory.systemTemp.createTemp('bundle_sync');
    bundle = File('${home.path}/$bundleMRSFileName');
    version = File('${home.path}/$bundleMRSFileName.version');
    bundledLength = (await rootBundle.load('assets/data/$bundleMRSFileName'))
        .lengthInBytes;
    setVersion('1.0.0', '1');
  });

  tearDown(() async {
    await home.delete(recursive: true);
  });

  test('copies the packaged bundle when none exists', () async {
    await ClashCore.syncBundleMRS(home.path);

    expect(await bundle.length(), bundledLength);
    expect(await version.readAsString(), '1.0.0+1');
  });

  test('keeps a bundle the user updated within the same version', () async {
    await ClashCore.syncBundleMRS(home.path);
    await bundle.writeAsString('downloaded');

    await ClashCore.syncBundleMRS(home.path);

    expect(await bundle.readAsString(), 'downloaded');
  });

  test('replaces the bundle after an app upgrade', () async {
    await ClashCore.syncBundleMRS(home.path);
    await bundle.writeAsString('downloaded');
    setVersion('1.0.1', '2');

    await ClashCore.syncBundleMRS(home.path);

    expect(await bundle.length(), bundledLength);
    expect(await version.readAsString(), '1.0.1+2');
  });

  test('replaces a bundle left by a version without a marker', () async {
    await bundle.writeAsString('legacy');

    await ClashCore.syncBundleMRS(home.path);

    expect(await bundle.length(), bundledLength);
    expect(await version.exists(), isTrue);
    expect(
      home.listSync().where((entity) => entity.path.endsWith('.tmp')),
      isEmpty,
    );
  });
}
