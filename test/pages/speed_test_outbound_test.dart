import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/speed_test.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUp(() {
    globalState.appState = AppState(
      brightness: Brightness.light,
      version: 0,
      viewSize: const Size(600, 900),
      requests: FixedList(maxLength),
      logs: FixedList(maxLogLength),
      traffics: FixedList(30),
      totalTraffic: Traffic(),
      systemUiOverlayStyle: const SystemUiOverlayStyle(),
      groups: [
        Group(
          type: GroupType.Selector,
          name: 'Group 1',
          now: 'Node 1-A',
          all: [
            Proxy(name: 'Node 1-A', type: 'Shadowsocks'),
            Proxy(name: 'Node 1-B', type: 'Shadowsocks'),
          ],
        ),
        Group(
          type: GroupType.Selector,
          name: 'Group 2',
          now: 'Node 2-A',
          all: [
            Proxy(name: 'Node 2-A', type: 'Shadowsocks'),
            Proxy(name: 'Node 2-B', type: 'Shadowsocks'),
          ],
        ),
      ],
    );
    globalState.config = Config(
      themeProps: defaultThemeProps,
      currentProfileId: 'test',
      profiles: const [
        Profile(
          id: 'test',
          label: 'test',
          autoUpdateDuration: Duration(days: 1),
        ),
      ],
    );
  });

  Future<void> openDialog(WidgetTester tester, {String selected = ''}) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [AppLocalizations.delegate],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                globalState.measure = Measure.of(context, 1);
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => buildSpeedTestOutboundPickerForTesting(
                        selected: selected,
                        groups: globalState.appState.groups,
                      ),
                    );
                  },
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('打开出站选择弹窗时所有代理组默认折叠', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await openDialog(tester, selected: '');

    expect(find.text('Group 1'), findsOneWidget);
    expect(find.text('Group 2'), findsOneWidget);
    expect(find.text('Node 1-B'), findsNothing);
    expect(find.text('Node 2-B'), findsNothing);
  });

  testWidgets('展开代理组后节点卡片不显示勾选标记', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await openDialog(tester, selected: '');

    await tester.tap(find.text('Group 1'));
    await tester.pumpAndSettle();

    expect(find.text('Node 1-B'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('手动选择出站节点时对应代理组自动展开且仅选中该节点', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await openDialog(tester, selected: 'Node 1-B');

    expect(find.text('Node 1-B'), findsOneWidget);
    expect(find.text('Node 2-B'), findsNothing);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });
}
