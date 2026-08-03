import 'package:bett_box/controller.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('macOS TUN startup', () {
    test('starts the listener before applying TUN', () async {
      final events = <String>[];

      final started = await runMacOSTunStartup(
        requestAdmin: () async {
          events.add('authorize');
          return Result.success(true);
        },
        restartCore: () async => events.add('restart'),
        applyTunConfig: () async => events.add('apply'),
        startListener: () async => events.add('start'),
        stopListener: () async => events.add('stop'),
      );

      expect(started, isTrue);
      expect(events, ['authorize', 'start', 'apply']);
    });

    test(
      'restarts, starts, then reapplies TUN after new authorization',
      () async {
        final events = <String>[];

        final started = await runMacOSTunStartup(
          requestAdmin: () async {
            events.add('authorize');
            return Result.success(true, needRestart: true);
          },
          restartCore: () async => events.add('restart'),
          applyTunConfig: () async => events.add('apply'),
          startListener: () async => events.add('start'),
          stopListener: () async => events.add('stop'),
        );

        expect(started, isTrue);
        expect(events, ['authorize', 'restart', 'start', 'apply']);
      },
    );

    test('does not start when authorization fails', () async {
      final events = <String>[];

      final started = await runMacOSTunStartup(
        requestAdmin: () async {
          events.add('authorize');
          return Result<bool>.error('authorization failed');
        },
        restartCore: () async => events.add('restart'),
        applyTunConfig: () async => events.add('apply'),
        startListener: () async => events.add('start'),
        stopListener: () async => events.add('stop'),
      );

      expect(started, isFalse);
      expect(events, ['authorize']);
    });

    test('stops the listener when applying TUN fails', () async {
      final events = <String>[];

      await expectLater(
        runMacOSTunStartup(
          requestAdmin: () async {
            events.add('authorize');
            return Result.success(true);
          },
          restartCore: () async => events.add('restart'),
          applyTunConfig: () async {
            events.add('apply');
            throw StateError('apply failed');
          },
          startListener: () async => events.add('start'),
          stopListener: () async => events.add('stop'),
        ),
        throwsStateError,
      );

      expect(events, ['authorize', 'start', 'apply', 'stop']);
    });

    test('does not start when restarting the core fails', () async {
      final events = <String>[];

      await expectLater(
        runMacOSTunStartup(
          requestAdmin: () async {
            events.add('authorize');
            return Result.success(true, needRestart: true);
          },
          restartCore: () async {
            events.add('restart');
            throw StateError('restart failed');
          },
          applyTunConfig: () async => events.add('apply'),
          startListener: () async => events.add('start'),
          stopListener: () async => events.add('stop'),
        ),
        throwsStateError,
      );

      expect(events, ['authorize', 'restart']);
    });
  });

  group('macOS TUN listener rebuild', () {
    test(
      'forces a disabled-to-enabled transition around network repair',
      () async {
        final events = <String>[];

        await rebuildMacOSTunListener(
          disableTun: () async => events.add('disable'),
          stopListener: () async => events.add('stop'),
          repairNetwork: () async => events.add('repair'),
          startListener: () async => events.add('start'),
          enableTun: () async => events.add('enable'),
        );

        expect(events, ['disable', 'stop', 'repair', 'start', 'enable']);
      },
    );

    test('restores the listener and TUN when network repair fails', () async {
      final events = <String>[];

      await expectLater(
        rebuildMacOSTunListener(
          disableTun: () async => events.add('disable'),
          stopListener: () async => events.add('stop'),
          repairNetwork: () async {
            events.add('repair');
            throw StateError('repair failed');
          },
          startListener: () async => events.add('start'),
          enableTun: () async => events.add('enable'),
        ),
        throwsStateError,
      );

      expect(events, ['disable', 'stop', 'repair', 'start', 'enable']);
    });

    test('reenables TUN when stopping the listener fails', () async {
      final events = <String>[];

      await expectLater(
        rebuildMacOSTunListener(
          disableTun: () async => events.add('disable'),
          stopListener: () async {
            events.add('stop');
            throw StateError('stop failed');
          },
          repairNetwork: () async => events.add('repair'),
          startListener: () async => events.add('start'),
          enableTun: () async => events.add('enable'),
        ),
        throwsStateError,
      );

      expect(events, ['disable', 'stop', 'enable']);
    });

    test('does not reenable TUN after a manual stop takes priority', () async {
      final events = <String>[];
      var shouldResume = true;

      await rebuildMacOSTunListener(
        disableTun: () async => events.add('disable'),
        stopListener: () async {
          events.add('stop');
          shouldResume = false;
        },
        repairNetwork: () async => events.add('repair'),
        startListener: () async => events.add('start'),
        enableTun: () async => events.add('enable'),
        shouldResume: () => shouldResume,
      );

      expect(events, ['disable', 'stop', 'repair']);
    });
  });
}
