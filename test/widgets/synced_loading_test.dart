import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/delay_animation_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

void main() {
  for (final type in DelayAnimationType.values) {
    testWidgets(
      '同步加载动画 ${type.name} 不超出给定尺寸',
      (tester) async {
        globalState.appState = AppState(
          brightness: Brightness.light,
          version: 0,
          viewSize: Size.zero,
          requests: FixedList(maxLength),
          logs: FixedList(maxLogLength),
          traffics: FixedList(30),
          totalTraffic: Traffic(),
          systemUiOverlayStyle: const SystemUiOverlayStyle(),
        );
        globalState.config = Config(
          themeProps: defaultThemeProps,
          proxiesStyle: ProxiesStyle(
            delayAnimation: type,
            syncDelayAnimation: true,
          ),
        );
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Center(
                child: SyncedLoading(
                  size: 40,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
      experimentalLeakTesting: LeakTesting.settings.withIgnored(
        classes: ['CurvedAnimation'],
      ),
    );
  }
}
