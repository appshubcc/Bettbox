import 'dart:async';

import 'package:bett_box/common/context.dart';
import 'package:bett_box/common/navigator.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('转场与手势期间 busy，结束后 whenIdle 完成', (tester) async {
    final observer = RouteIdleObserver();
    addTearDown(observer.busy.dispose);
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        navigatorObservers: [observer],
        home: const Scaffold(body: Text('home')),
      ),
    );
    expect(observer.busy.value, isFalse);
    await observer.whenIdle();

    key.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('b'))),
    );
    await tester.pump();
    expect(observer.busy.value, isTrue);
    await tester.pump(const Duration(milliseconds: 50));
    expect(observer.busy.value, isTrue);
    await tester.pumpAndSettle();
    expect(observer.busy.value, isFalse);

    key.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(observer.busy.value, isTrue);

    var idle = false;
    unawaited(observer.whenIdle().then((_) => idle = true));
    await tester.pump();
    expect(idle, isFalse);
    await tester.pumpAndSettle();
    expect(observer.busy.value, isFalse);
    expect(idle, isTrue);

    final route = MaterialPageRoute<void>(builder: (_) => const SizedBox());
    addTearDown(route.dispose);
    observer.didStartUserGesture(route, null);
    expect(observer.busy.value, isTrue);
    observer.didStopUserGesture();
    expect(observer.busy.value, isFalse);
  });

  testWidgets('页面退场期间及刚结束时未稳定，稍后才算稳定', (tester) async {
    final observer = RouteIdleObserver();
    addTearDown(observer.busy.dispose);
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        navigatorObservers: [observer],
        home: const Scaffold(body: Text('home')),
      ),
    );
    key.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('b'))),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    expect(observer.isSettled, isTrue);

    key.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(observer.busy.value, isTrue);
    expect(observer.isSettled, isFalse);

    await tester.pumpAndSettle();
    expect(observer.busy.value, isFalse);
    expect(observer.isSettled, isFalse);

    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    expect(observer.isSettled, isTrue);
  });

  testWidgets('无动画的出栈同样需要等待稳定', (tester) async {
    final observer = RouteIdleObserver();
    addTearDown(observer.busy.dispose);
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        navigatorObservers: [observer],
        home: const Scaffold(body: Text('home')),
      ),
    );
    key.currentState!.push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const Scaffold(body: Text('b')),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    expect(observer.isSettled, isTrue);

    key.currentState!.pop();
    await tester.pumpAndSettle();
    expect(observer.busy.value, isFalse);
    expect(observer.isSettled, isFalse);
  });

  testWidgets('afterRouteTransition 在进入动画结束后才执行', (tester) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        home: const Scaffold(body: Text('home')),
      ),
    );
    var called = 0;
    key.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => _AfterTransitionProbe(onReady: () => called++),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(called, 0);

    await tester.pumpAndSettle();
    expect(called, 1);

    final context = tester.element(find.byType(_AfterTransitionProbe));
    context.afterRouteTransition(() => called++);
    expect(called, 2);
  });
}

class _AfterTransitionProbe extends StatefulWidget {
  final VoidCallback onReady;

  const _AfterTransitionProbe({required this.onReady});

  @override
  State<_AfterTransitionProbe> createState() => _AfterTransitionProbeState();
}

class _AfterTransitionProbeState extends State<_AfterTransitionProbe> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.afterRouteTransition(widget.onReady);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('probe'));
}
