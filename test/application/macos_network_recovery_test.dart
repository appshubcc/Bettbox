import 'package:bett_box/application.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('macOS network recovery', () {
    test('skips an unchanged network during regular connectivity updates', () {
      expect(
        shouldReconcileMacOSNetworkState(
          previousFingerprint: 'same-network',
          currentFingerprint: 'same-network',
        ),
        isFalse,
      );
    });

    test('forces recovery after wake even when the network is unchanged', () {
      expect(
        shouldReconcileMacOSNetworkState(
          previousFingerprint: 'same-network',
          currentFingerprint: 'same-network',
          force: true,
        ),
        isTrue,
      );
    });

    test('recovers when the network fingerprint changes', () {
      expect(
        shouldReconcileMacOSNetworkState(
          previousFingerprint: 'old-network',
          currentFingerprint: 'new-network',
        ),
        isTrue,
      );
    });

    test('drops a queued recovery after a newer event arrives', () {
      expect(
        isMacOSNetworkRecoveryCurrent(
          mounted: true,
          scheduledGeneration: 3,
          currentGeneration: 4,
        ),
        isFalse,
      );
      expect(
        isMacOSNetworkRecoveryCurrent(
          mounted: true,
          scheduledGeneration: 4,
          currentGeneration: 4,
        ),
        isTrue,
      );
    });
  });
}
