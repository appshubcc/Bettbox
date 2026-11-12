import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoPageRoute, CupertinoPageTransitionsBuilder;
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
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
  });

  testWidgets('提示气泡显示时推入页面不触发布局期间的子树迁移', (tester) async {
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
    await tester.pump(const Duration(milliseconds: 16));
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

  testWidgets('CleanCupertinoPageRoute 转场时长为 500ms', (tester) async {
    Route<dynamic>? pushedRoute;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                BaseNavigator.push(context, const Scaffold(body: Text('page')));
              },
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.popUntil((route) {
      if (route is CupertinoPageRoute) {
        pushedRoute = route;
      }
      return true;
    });
    expect(pushedRoute, isNotNull);
    if (pushedRoute case final PageRoute<dynamic> pageRoute) {
      expect(pageRoute.transitionDuration, const Duration(milliseconds: 500));
      expect(
        pageRoute.reverseTransitionDuration,
        const Duration(milliseconds: 500),
      );
    }
  });

  testWidgets('Android 转场在首帧之后的下一帧才开始计时并正常完成', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => BaseNavigator.push(
                context,
                const Scaffold(body: Text('page')),
              ),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final startX = tester.getTopLeft(find.text('page')).dx;
    expect(startX, greaterThan(0));
    await tester.pump(const Duration(milliseconds: 24));
    final movedX = tester.getTopLeft(find.text('page')).dx;
    expect(movedX, lessThan(startX));
    await tester.pump(const Duration(milliseconds: 476));
    expect(tester.getTopLeft(find.text('page')).dx, closeTo(0, 0.1));
    await tester.pumpAndSettle();
    expect(find.text('page'), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.text('go'), findsOneWidget);
  });

  testWidgets('ListItem.next 在移动端禁用按压反馈', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pumpNextItem(tester);
    final theme = tester.widget<Theme>(_tileTheme());
    expect(theme.data.splashColor, Colors.transparent);
    expect(theme.data.highlightColor, Colors.transparent);
    expect(theme.data.splashFactory, NoSplash.splashFactory);
  });

  testWidgets('ListItem.next 在桌面端保留按压反馈', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pumpNextItem(tester);
    expect(_tileTheme(), findsNothing);
  });

  testWidgets('系统开启减少动态效果时移动端转场改用淡入路由', (tester) async {
    Route<dynamic>? pushed;
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [_PushRecorder((route) => pushed = route)],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(reduceMotion: true),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => BaseNavigator.push(
                context,
                const Scaffold(body: Text('next')),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('next'), findsOneWidget);
    expect(pushed, isA<CommonDesktopRoute<Object?>>());
  });
}

Finder _tileTheme() {
  return find.descendant(
    of: find.byType(ListItem),
    matching: find.byType(Theme),
  );
}

Future<void> _pumpNextItem(WidgetTester tester) {
  return tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: ListItem.next(
          title: Text('Title'),
          delegate: NextDelegate(title: 'Subpage', widget: Text('Subpage')),
        ),
      ),
    ),
  );
}

class _PushRecorder extends NavigatorObserver {
  _PushRecorder(this.onPush);

  final void Function(Route<dynamic> route) onPush;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) onPush(route);
  }
}
