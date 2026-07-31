import 'dart:async';

import 'package:bett_box/clash/core_startup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('waitForCoreReady returns the completed value', () async {
    expect(await waitForCoreReady(Future.value(7)), 7);
  });

  test('waitForCoreReady reports a typed timeout', () async {
    final ready = Completer<void>();

    await expectLater(
      waitForCoreReady(ready.future, timeout: Duration.zero),
      throwsA(isA<CoreReadyTimeoutException>()),
    );
  });

  test('CoreStartGuard always resets after an error', () async {
    final guard = CoreStartGuard();

    await expectLater(
      guard.run<void>(() async => throw StateError('boom')),
      throwsStateError,
    );

    expect(guard.isRunning, isFalse);
    expect(await guard.run(() async => 9), 9);
  });
}
