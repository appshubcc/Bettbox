import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/state.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  globalState.backgroundMode.value;
  routeIdleObserver.busy.value;
  MediaUnlockStateNotifier().state.value;
  LeakTesting.enable();
  LeakTesting.settings = LeakTesting.settings.withIgnored(
    createdByTestHelpers: true,
    classes: ['DeferredPointerHandlerLink', 'DelayTestCoordinator'],
  );
  await testMain();
}
