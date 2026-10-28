import 'package:bett_box/common/common.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/connection/connections.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('首页连接继承筛选标签，空结果时可删除且同步回连接页', (tester) async {
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
    globalState.config = Config(themeProps: defaultThemeProps);
    final wasBackground = globalState.backgroundMode.value;
    globalState.backgroundMode.value = true;
    addTearDown(() => globalState.backgroundMode.value = wasBackground);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(connectionsProvider.notifier).state = [
      TrackerInfo(
        id: 'active',
        start: DateTime(2026),
        metadata: const Metadata(host: 'example.com'),
        chains: const ['DIRECT'],
        rule: '',
        rulePayload: '',
      ),
    ];
    var showDashboard = false;
    late StateSetter rebuild;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: const [AppLocalizations.delegate],
          home: Builder(
            builder: (context) {
              globalState.measure = Measure.of(context, 1);
              return StatefulBuilder(
                builder: (_, setState) {
                  rebuild = setState;
                  return IndexedStack(
                    index: showDashboard ? 1 : 0,
                    children: [
                      const ConnectionsView(),
                      if (showDashboard)
                        const ConnectionsView(respectCurrentPage: false),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    tester
        .state<CommonScaffoldState>(find.byType(CommonScaffold))
        .addKeyword('unmatched-proxy');
    await tester.pumpAndSettle();
    expect(container.read(filteredConnectionsProvider), isEmpty);
    expect(find.byType(NullStatus), findsOneWidget);

    rebuild(() => showDashboard = true);
    await tester.pumpAndSettle();
    final chip = find.byWidgetPredicate(
      (widget) => widget is CommonChip && widget.label == 'unmatched-proxy',
    );
    expect(chip, findsOneWidget);
    expect(container.read(filteredConnectionsProvider), isEmpty);
    expect(find.byType(NullStatus), findsOneWidget);

    tester.widget<CommonChip>(chip).onPressed!();
    await tester.pumpAndSettle();
    expect(container.read(connectionsKeywordsProvider), isEmpty);
    expect(container.read(filteredConnectionsProvider).single.id, 'active');
    expect(chip, findsNothing);
    expect(find.byType(NullStatus), findsNothing);

    rebuild(() => showDashboard = false);
    await tester.pumpAndSettle();
    expect(chip, findsNothing);
    expect(find.byType(NullStatus), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
