import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoPageTransitionsBuilder;
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('提示气泡显示时推入页面不触发布局期间的子树迁移', (tester) async {
    globalState.appState = AppState(
      brightness: Brightness.light,
      version: 0,
      viewSize: const Size(400, 800),
      requests: FixedList(maxLength),
      logs: FixedList(maxLogLength),
      traffics: FixedList(30),
      totalTraffic: Traffic(),
      systemUiOverlayStyle: const SystemUiOverlayStyle(),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        builder: (_, child) => LayoutBuilder(builder: (_, _) => child!),
        home: Builder(
          builder: (context) => Scaffold(
            body: IconButton(
              tooltip: 'tip',
              onPressed: () => BaseNavigator.push(
                context,
                const Scaffold(body: Text('next')),
              ),
              icon: const Text('open'),
            ),
          ),
        ),
      ),
    );
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.text('open')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('tip'), findsOneWidget);
    final homeLeft = tester.getTopLeft(find.text('open')).dx;

    await gesture.down(tester.getCenter(find.text('open')));
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
    expect(tester.getTopLeft(find.text('open')).dx, lessThan(homeLeft));

    await tester.pumpAndSettle();
    expect(find.text('next'), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getTopLeft(find.text('open')).dx, homeLeft);
  });
}
