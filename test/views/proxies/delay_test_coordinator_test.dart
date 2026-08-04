import 'dart:async';

import 'package:bett_box/models/models.dart';
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
    expect(coordinator.testingGroupName, 'Fallback');

    var secondExecuted = false;
    final secondResult = await coordinator.run('Other', () async {
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

  test(
    'deduplicates concurrent requests for the same resolved target',
    () async {
      final pool = DelayTestRequestPool();
      const target = DelayTestTarget(
        name: 'resolved-proxy',
        url: 'https://example.com/generate_204',
      );
      final completer = Completer<Delay>();
      var requestCount = 0;

      Future<Delay> request() {
        requestCount += 1;
        return completer.future;
      }

      final first = pool.run(target, request);
      final second = pool.run(target, request);

      expect(requestCount, 1);
      expect(pool.pendingCount, 1);

      const result = Delay(
        name: 'resolved-proxy',
        url: 'https://example.com/generate_204',
        value: 120,
      );
      completer.complete(result);

      expect(await first, result);
      expect(await second, result);
      expect(pool.pendingCount, 0);
    },
  );

  test('keeps targets with different test URLs independent', () {
    const first = DelayTestTarget(
      name: 'resolved-proxy',
      url: 'https://example.com/a',
    );
    const second = DelayTestTarget(
      name: 'resolved-proxy',
      url: 'https://example.com/b',
    );

    expect({first, second}, hasLength(2));
  });
}
