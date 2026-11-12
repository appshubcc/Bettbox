import 'package:bett_box/common/frame_probe.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/app.dart';
import 'package:bett_box/state.dart';

import 'dart:async';
import 'dart:ui' show FlutterView;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart' show MaterialPageRoute;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

class BaseNavigator {
  static const _keyboardTimeout = Duration(milliseconds: 350);

  static Future<void> _dismissKeyboard(BuildContext context) async {
    final view = View.maybeOf(context);
    if (view == null || view.viewInsets.bottom <= 0) return;
    final observer = _KeyboardObserver(view);
    WidgetsBinding.instance.addObserver(observer);
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      await observer.closed.timeout(_keyboardTimeout, onTimeout: () {});
    } finally {
      WidgetsBinding.instance.removeObserver(observer);
    }
  }

  static Future<T?> push<T>(
    BuildContext context,
    Widget child, {
    bool maintainState = true,
  }) async {
    final navigator = Navigator.of(context);
    if (globalState.appState.viewMode != ViewMode.mobile) {
      return await navigator.push<T>(
        CommonDesktopRoute(
          builder: (context) => child,
          maintainState: maintainState,
        ),
      );
    }
    final reduceMotion = MediaQuery.maybeReduceMotionOf(context) ?? false;
    final keyboardVisible = (View.maybeOf(context)?.viewInsets.bottom ?? 0) > 0;
    await _dismissKeyboard(context);
    if (keyboardVisible) await WidgetsBinding.instance.endOfFrame;
    if (!navigator.mounted) return null;
    return await navigator.push<T>(
      reduceMotion
          ? CommonDesktopRoute(
              builder: (context) => child,
              maintainState: maintainState,
            )
          : _CleanCupertinoPageRoute(
              builder: (context) => child,
              maintainState: maintainState,
            ),
    );
  }
}

class _KeyboardObserver with WidgetsBindingObserver {
  final FlutterView view;
  final _closed = Completer<void>();

  _KeyboardObserver(this.view);

  Future<void> get closed => _closed.future;

  @override
  void didChangeMetrics() {
    if (_closed.isCompleted || view.viewInsets.bottom > 0) return;
    _closed.complete();
  }
}

class _CleanCupertinoPageRoute<T> extends CupertinoPageRoute<T> {
  _CleanCupertinoPageRoute({
    required super.builder,
    super.title,
    super.settings,
    super.fullscreenDialog,
    super.maintainState,
  }) : super(allowSnapshotting: false);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 500);

  @override
  Color? get barrierColor => null;

  static final DelegatedTransitionBuilder? _hostDelegatedTransition = () {
    final route = MaterialPageRoute<void>(
      builder: (_) => const SizedBox.shrink(),
    );
    final transition = route.delegatedTransition;
    route.dispose();
    return transition;
  }();

  @override
  Simulation? createSimulation({required bool forward}) {
    if (defaultTargetPlatform != TargetPlatform.android) return null;
    final begin = controller?.value ?? (forward ? 0.0 : 1.0);
    return _FrameAlignedSimulation(
      duration: forward ? transitionDuration : reverseTransitionDuration,
      begin: begin,
      end: forward ? 1.0 : 0.0,
    );
  }

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      _hostDelegatedTransition;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return super.buildTransitions(
        context,
        animation,
        secondaryAnimation,
        child,
      );
    }
    return CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: false,
      child: _TransitionSnapshot(
        animation: animation,
        snapshotOnReverse: true,
        child: child,
      ),
    );
  }
}

class CommonDesktopRoute<T> extends PageRoute<T> {
  final Widget Function(BuildContext context) builder;

  CommonDesktopRoute({required this.builder, this.maintainState = true});

  @override
  final bool maintainState;

  static final _enterTween = CurveTween(curve: const Interval(0.2, 1));
  static final _exitTween = Tween<double>(
    begin: 1,
    end: 0,
  ).chain(CurveTween(curve: const Interval(0, 0.4)));

  static Widget? _buildExitTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    bool allowSnapshotting,
    Widget? child,
  ) {
    return FadeTransition(
      opacity: _exitTween.animate(secondaryAnimation),
      child: child,
    );
  }

  @override
  DelegatedTransitionBuilder? get delegatedTransition => _buildExitTransition;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: FadeTransition(
        opacity: _enterTween.animate(animation),
        child: result,
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: _exitTween.animate(secondaryAnimation),
      child: child,
    );
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  Duration get reverseTransitionDuration => Duration(milliseconds: 200);
}

class RouteIdleObserver extends NavigatorObserver {
  static const _settleDuration = Duration(milliseconds: 250);
  static const _busyTimeout = Duration(seconds: 3);

  final busy = ValueNotifier<bool>(false);
  final _clock = Stopwatch()..start();
  Duration _changedAt = Duration.zero;
  int _activeTransitions = 0;
  bool _gestureActive = false;

  bool get isSettled {
    final elapsed = _clock.elapsed - _changedAt;
    return elapsed >= (busy.value ? _busyTimeout : _settleDuration);
  }

  void _update() {
    _changedAt = _clock.elapsed;
    busy.value = _gestureActive || _activeTransitions > 0;
  }

  void _track(Route<dynamic>? route) {
    final animation = route is ModalRoute ? route.animation : null;
    if (animation == null ||
        animation.status == AnimationStatus.completed ||
        animation.status == AnimationStatus.dismissed) {
      _update();
      return;
    }
    _activeTransitions++;
    _update();
    void listener(AnimationStatus status) {
      if (status != AnimationStatus.completed &&
          status != AnimationStatus.dismissed) {
        return;
      }
      if (route is ModalRoute && route.offstage) return;
      animation.removeStatusListener(listener);
      _activeTransitions--;
      _update();
    }

    animation.addStatusListener(listener);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    FrameProbe.mark('push');
    _track(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    FrameProbe.mark('pop');
    _track(route);
  }

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    _gestureActive = true;
    _update();
  }

  @override
  void didStopUserGesture() {
    _gestureActive = false;
    _update();
  }

  Future<void> whenIdle({Duration timeout = const Duration(seconds: 3)}) async {
    if (!busy.value) return;
    final completer = Completer<void>();
    void listener() {
      if (!busy.value && !completer.isCompleted) completer.complete();
    }

    busy.addListener(listener);
    await completer.future.timeout(timeout, onTimeout: () {});
    busy.removeListener(listener);
  }
}

final routeIdleObserver = RouteIdleObserver();

mixin IdleAutofocusMixin<T extends StatefulWidget> on State<T> {
  FocusNode? _autofocusNode;

  bool get autofocusWhenIdle => true;

  FocusNode? get autofocusNode => _autofocusNode;

  @override
  void initState() {
    super.initState();
    if (!autofocusWhenIdle) return;
    final node = _autofocusNode = FocusNode();
    unawaited(node.requestFocusWhenIdle());
  }

  @override
  void dispose() {
    _autofocusNode?.dispose();
    super.dispose();
  }
}

extension FocusNodeIdleExt on FocusNode {
  Future<void> requestFocusWhenIdle() async {
    final binding = WidgetsBinding.instance;
    await binding.endOfFrame;
    await routeIdleObserver.whenIdle();
    await binding.endOfFrame;
    if (context == null || !canRequestFocus) return;
    requestFocus();
  }
}

class _FrameAlignedSimulation extends Simulation {
  _FrameAlignedSimulation({
    required this.duration,
    required this.begin,
    required this.end,
  });

  final Duration duration;
  final double begin;
  final double end;
  double? _origin;

  double get _duration =>
      duration.inMicroseconds / Duration.microsecondsPerSecond;

  double _progress(double time) {
    if (time <= 0) return 0;
    final origin = _origin ??= time;
    return ((time - origin) / _duration).clamp(0.0, 1.0);
  }

  @override
  double x(double time) => begin + (end - begin) * _progress(time);

  @override
  double dx(double time) {
    final origin = _origin;
    if (origin == null || time <= origin) return 0;
    return (end - begin) / _duration;
  }

  @override
  bool isDone(double time) {
    final origin = _origin;
    return origin != null && time - origin >= _duration;
  }
}

class _TransitionSnapshot extends StatefulWidget {
  final Animation<double> animation;
  final bool snapshotOnReverse;
  final Widget child;

  const _TransitionSnapshot({
    required this.animation,
    this.snapshotOnReverse = false,
    required this.child,
  });

  @override
  State<_TransitionSnapshot> createState() => _TransitionSnapshotState();
}

class _TransitionSnapshotState extends State<_TransitionSnapshot> {
  final _controller = SnapshotController();

  bool get _shouldSnapshot => widget.snapshotOnReverse
      ? widget.animation.status.isAnimating
      : widget.animation.status == AnimationStatus.forward;

  @override
  void initState() {
    super.initState();
    _controller.allowSnapshotting = _shouldSnapshot;
    widget.animation.addStatusListener(_handleStatus);
  }

  void _handleStatus(AnimationStatus status) {
    _controller.allowSnapshotting = widget.snapshotOnReverse
        ? status.isAnimating
        : status == AnimationStatus.forward;
  }

  @override
  void didUpdateWidget(_TransitionSnapshot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation == widget.animation) return;
    oldWidget.animation.removeStatusListener(_handleStatus);
    widget.animation.addStatusListener(_handleStatus);
    _controller.allowSnapshotting = _shouldSnapshot;
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_handleStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SnapshotWidget(
      controller: _controller,
      mode: SnapshotMode.permissive,
      autoresize: true,
      child: widget.child,
    );
  }
}
