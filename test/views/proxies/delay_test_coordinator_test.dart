import 'dart:async';

import 'package:bett_box/views/proxies/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shares testing state and rejects overlapping group tests', () async {
    final coordinator = DelayTestCoordinator();
    final firstStarted = Completer<void>();
    final finishFirst = Completer<void>();

    final firstRun = coordinator.run('Fallback', () async {
      firstStarted.complete();
      await finishFirst.future;
    });
    await firstStarted.future;

    expect(coordinator.isTesting, isTrue);
    expect(coordinator.isTestingGroup('Fallback'), isTrue);
    expect(coordinator.isTestingGroup('Proxy'), isFalse);

    var secondExecuted = false;
    final secondResult = await coordinator.run('Proxy', () async {
      secondExecuted = true;
    });

    expect(secondResult, isFalse);
    expect(secondExecuted, isFalse);

    finishFirst.complete();
    expect(await firstRun, isTrue);
    expect(coordinator.isTesting, isFalse);
    expect(coordinator.testingGroupName, isNull);
  });

  test('clears testing state when a delay test fails', () async {
    final coordinator = DelayTestCoordinator();

    await expectLater(
      coordinator.run('Fallback', () async {
        throw StateError('delay test failed');
      }),
      throwsStateError,
    );

    expect(coordinator.isTesting, isFalse);
    expect(coordinator.testingGroupName, isNull);
  });

  test('notifies listeners when a group test starts and finishes', () async {
    final coordinator = DelayTestCoordinator();
    final started = Completer<void>();
    final finish = Completer<void>();
    final states = <String?>[];
    coordinator.addListener(() {
      states.add(coordinator.testingGroupName);
    });

    final run = coordinator.run('Global', () async {
      started.complete();
      await finish.future;
    });
    await started.future;

    expect(states, ['Global']);

    finish.complete();
    await run;

    expect(states, ['Global', null]);
  });
}
