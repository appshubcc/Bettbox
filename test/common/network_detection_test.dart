import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _waitFor(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('condition not met in time');
    }
    await Future.delayed(const Duration(milliseconds: 20));
  }
}

void main() {
  late HttpServer server;
  final pending = <Completer<void>>[];
  var requestCount = 0;

  void setConfig({Mode mode = Mode.rule}) {
    globalState.config = Config(
      themeProps: defaultThemeProps,
      appSetting: const AppSettingProps(
        mobileDashboardWidgets: [],
        desktopDashboardWidgets: [],
      ),
      patchClashConfig: ClashConfig(mixedPort: server.port, mode: mode),
    );
  }

  void setAppState({required bool isInit}) {
    globalState.appState = AppState(
      isInit: isInit,
      runTime: 1,
      brightness: Brightness.light,
      version: 0,
      viewSize: Size.zero,
      requests: FixedList(maxLength),
      logs: FixedList(maxLogLength),
      traffics: FixedList(30),
      totalTraffic: Traffic(),
      systemUiOverlayStyle: const SystemUiOverlayStyle(),
    );
  }

  void release() {
    for (final completer in pending) {
      completer.complete();
    }
    pending.clear();
  }

  setUpAll(() async {
    HttpOverrides.global = BettboxHttpOverrides();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      if (request.method != 'GET') {
        request.response.statusCode = HttpStatus.badGateway;
        await request.response.close();
        return;
      }
      requestCount++;
      final completer = Completer<void>();
      pending.add(completer);
      await completer.future;
      request.response.write(
        json.encode({
          'status': 'success',
          'query': '1.2.3.4',
          'countryCode': 'US',
        }),
      );
      await request.response.close().catchError((_) {});
    });
  });

  tearDownAll(() async {
    release();
    await server.close(force: true);
  });

  setUp(() {
    requestCount = 0;
    setConfig();
    setAppState(isInit: true);
  });

  tearDown(() async {
    release();
    await _waitFor(() => !detectionState.state.value.isLoading);
  });

  test('进行中的检测不会被相同条件的触发重启', () async {
    detectionState.startCheck(immediate: true);
    await _waitFor(() => requestCount == 1);

    detectionState.startCheck(immediate: true);
    await Future.delayed(const Duration(milliseconds: 300));
    expect(requestCount, 1);

    release();
    await _waitFor(() => detectionState.state.value.ipInfo?.ip == '1.2.3.4');
    expect(detectionState.state.value.isLoading, isFalse);
  });

  test('初始化前的触发在初始化完成后补发', () async {
    setAppState(isInit: false);
    detectionState.startCheck(immediate: true);
    await Future.delayed(const Duration(milliseconds: 300));
    expect(requestCount, 0);

    setAppState(isInit: true);
    detectionState.flushPendingCheck();
    await _waitFor(() => requestCount == 1);

    detectionState.flushPendingCheck();
    release();
    await _waitFor(() => !detectionState.state.value.isLoading);
    await Future.delayed(const Duration(milliseconds: 2300));
    expect(requestCount, 1);
  });

  test('条件变化时重启检测', () async {
    detectionState.startCheck(immediate: true);
    await _waitFor(() => requestCount == 1);

    setConfig(mode: Mode.global);
    detectionState.startCheck(immediate: true);
    await _waitFor(() => requestCount == 2);

    release();
    await _waitFor(() => detectionState.state.value.ipInfo?.ip == '1.2.3.4');
  });
}
