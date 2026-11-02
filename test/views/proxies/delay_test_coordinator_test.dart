import 'dart:async';

import 'package:bett_box/models/models.dart';
import 'package:bett_box/views/proxies/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shares testing state and rejects overlapping group tests', () async {
    final coordinator = DelayTestCoordinator();

    expect(coordinator.isTesting, isFalse);
    expect(coordinator.testingGroupName, null);

    var actionExecuted = false;
    final testFuture = coordinator.run('ProxyGroup', () async {
      actionExecuted = true;
      expect(coordinator.isTesting, isTrue);
      expect(coordinator.testingGroupName, 'ProxyGroup');
      expect(coordinator.isTestingGroup('ProxyGroup'), isTrue);
      expect(coordinator.isTestingGroup('OtherGroup'), isFalse);
    });

    final secondTestStarted = await coordinator.run('OtherGroup', () async {});
    expect(secondTestStarted, isFalse);

    await testFuture;

    expect(actionExecuted, isTrue);
    expect(coordinator.isTesting, isFalse);
    expect(coordinator.testingGroupName, null);
  });

  test('clears testing state when a delay test fails', () async {
    final coordinator = DelayTestCoordinator();

    try {
      await coordinator.run('ProxyGroup', () async {
        throw Exception('network error');
      });
    } catch (_) {}

    expect(coordinator.isTesting, isFalse);
    expect(coordinator.testingGroupName, null);
  });

  test('notifies listeners when a group test starts and finishes', () async {
    final coordinator = DelayTestCoordinator();
    var notifications = 0;

    coordinator.addListener(() {
      notifications++;
    });

    await coordinator.run('ProxyGroup', () async {});

    expect(notifications, 2);
  });

  test('cancel releases the lock and ignores the stale test', () async {
    final coordinator = DelayTestCoordinator();
    final stale = Completer<void>();
    var notifications = 0;
    coordinator.addListener(() => notifications++);

    final staleRun = coordinator.run('Old', () => stale.future);
    final epoch = coordinator.epoch;
    coordinator.cancel();

    expect(coordinator.isTesting, isFalse);
    expect(coordinator.epoch, epoch + 1);

    final fresh = Completer<void>();
    final freshRun = coordinator.run('New', () => fresh.future);
    expect(coordinator.testingGroupName, 'New');

    stale.complete();
    await staleRun;
    expect(coordinator.testingGroupName, 'New');

    fresh.complete();
    await freshRun;
    expect(coordinator.isTesting, isFalse);
    expect(notifications, 4);
  });

  test('clear drops pending requests so new tests start again', () async {
    final pool = DelayTestRequestPool();
    const target = DelayTestTarget(name: 'proxy', url: 'u');
    final stale = Completer<Delay>();
    var requestCount = 0;

    pool.run(target, () {
      requestCount += 1;
      return stale.future;
    });
    pool.clear();
    final fresh = pool.run(target, () async {
      requestCount += 1;
      return const Delay(name: 'proxy', url: 'u', value: 10);
    });

    expect(requestCount, 2);
    stale.complete(const Delay(name: 'proxy', url: 'u', value: -1));
    expect((await fresh).value, 10);
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
