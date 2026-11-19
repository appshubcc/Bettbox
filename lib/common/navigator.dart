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
import 'package:flutter/scheduler.dart'
    show SchedulerBinding, Ticker, TickerCallback;

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
  Duration get transitionDuration => const Duration(milliseconds: 450);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 360);

  @override
  Color? get barrierColor => null;

  @override
  set offstage(bool value) {}

  static final DelegatedTransitionBuilder? _hostDelegatedTransition = () {
    final route = MaterialPageRoute<void>(
      builder: (_) => const SizedBox.shrink(),
    );
    final transition = route.delegatedTransition;
    route.dispose();
    return transition;
  }();

  LeadTickerProvider? _vsync;
  int _hold = 0;
  CurvedAnimation? _enter;
  CurvedAnimation? _cover;

  @override
  AnimationController createAnimationController() {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return super.createAnimationController();
    }
    return AnimationController(
      duration: transitionDuration,
      reverseDuration: reverseTransitionDuration,
      debugLabel: debugLabel,
      vsync: _vsync = LeadTickerProvider(navigator!),
    );
  }

  @override
  TickerFuture didPush() {
    _holdFirstFrame();
    return super.didPush();
  }

  @override
  bool didPop(T? result) {
    _holdFirstFrame();
    return super.didPop(result);
  }

  void _holdFirstFrame() {
    final ticker = _vsync?.ticker;
    if (ticker == null) return;
    final hold = ++_hold;
    ticker.muted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigator?.context;
      if (hold != _hold || context == null || !context.mounted) return;
      ticker.muted = !TickerMode.getValuesNotifier(context).value.enabled;
    });
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
    final enter = _enter ??= CurvedAnimation(
      parent: animation,
      curve: Curves.fastEaseInToSlowEaseOut,
      reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
    );
    final cover = secondaryAnimation == this.secondaryAnimation
        ? _cover ??= CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.linearToEaseOut,
            reverseCurve: Curves.easeInToLinear,
          )
        : secondaryAnimation;
    return CupertinoPageTransition(
      primaryRouteAnimation: enter,
      secondaryRouteAnimation: cover,
      linearTransition: true,
      child: RouteSnapshot(child: child),
    );
  }

  @override
  void dispose() {
    _enter?.dispose();
    _cover?.dispose();
    super.dispose();
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

class LeadTickerProvider implements TickerProvider {
  LeadTickerProvider(this._parent);

  final TickerProvider _parent;
  Ticker? ticker;
  Duration _lead = Duration.zero;
  Duration? _last;

  Duration get _frameInterval {
    final rate =
        WidgetsBinding
            .instance
            .platformDispatcher
            .implicitView
            ?.display
            .refreshRate ??
        0;
    return rate > 0
        ? Duration(microseconds: Duration.microsecondsPerSecond ~/ rate)
        : Duration.zero;
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return ticker = _parent.createTicker((elapsed) {
      final last = _last;
      if (elapsed == Duration.zero) {
        _lead = _frameInterval;
      } else if (last != null && elapsed <= last) {
        _lead = Duration.zero;
      }
      _last = elapsed;
      onTick(elapsed + _lead);
    });
  }
}

class RouteSnapshot extends StatefulWidget {
  final Widget child;

  const RouteSnapshot({super.key, required this.child});

  @override
  State<RouteSnapshot> createState() => _RouteSnapshotState();
}

class _RouteSnapshotState extends State<RouteSnapshot> {
  final _controller = SnapshotController();
  Animation<double>? _animation;
  Animation<double>? _secondaryAnimation;

  void _update([AnimationStatus? _]) {
    _controller.allowSnapshotting =
        (_animation?.isAnimating ?? false) ||
        _secondaryAnimation?.status == AnimationStatus.forward;
  }

  void _unlisten() {
    _animation?.removeStatusListener(_update);
    _secondaryAnimation?.removeStatusListener(_update);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route?.animation == _animation &&
        route?.secondaryAnimation == _secondaryAnimation) {
      return;
    }
    _unlisten();
    _animation = route?.animation?..addStatusListener(_update);
    _secondaryAnimation = route?.secondaryAnimation
      ?..addStatusListener(_update);
    _update();
  }

  @override
  void dispose() {
    _unlisten();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RouteEntranceScope(
      animation: _animation,
      child: SnapshotWidget(
        controller: _controller,
        mode: SnapshotMode.permissive,
        autoresize: true,
        child: widget.child,
      ),
    );
  }
}

class _RouteEntranceScope extends InheritedWidget {
  final Animation<double>? animation;

  const _RouteEntranceScope({required this.animation, required super.child});

  @override
  bool updateShouldNotify(_RouteEntranceScope oldWidget) => false;
}

VoidCallback whenRouteEntered(BuildContext context, VoidCallback callback) {
  final animation = context
      .getInheritedWidgetOfExactType<_RouteEntranceScope>()
      ?.animation;
  if (animation == null || animation.isCompleted) {
    callback();
    return () {};
  }
  void listener(AnimationStatus status) {
    if (!status.isCompleted) return;
    animation.removeStatusListener(listener);
    callback();
  }

  animation.addStatusListener(listener);
  return () => animation.removeStatusListener(listener);
}

const _arrivalHoldLimit = Duration(milliseconds: 200);

mixin ArrivalHoldRouteMixin<T> on TransitionRoute<T> {
  List<Completer<void>>? _arrivalHolds;

  Ticker? get arrivalTicker;

  @override
  TickerFuture didPush() {
    final ticker = arrivalTicker;
    if (ticker == null) return super.didPush();
    ticker.muted = true;
    final holds = _arrivalHolds = [];
    final pushed = super.didPush();
    final context = navigator!.context;
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _arrivalHolds = null;
      if (holds.isNotEmpty) {
        await Future.wait([for (final hold in holds) hold.future])
            .timeout(_arrivalHoldLimit, onTimeout: () => const []);
      }
      if (!context.mounted) return;
      ticker.muted = !TickerMode.getValuesNotifier(context).value.enabled;
    });
    return pushed;
  }
}

class ArrivalHold extends StatefulWidget {
  final bool ready;
  final Widget child;

  const ArrivalHold({super.key, required this.ready, required this.child});

  @override
  State<ArrivalHold> createState() => _ArrivalHoldState();
}

class _ArrivalHoldState extends State<ArrivalHold> {
  bool _checked = false;
  Completer<void>? _hold;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checked) return;
    _checked = true;
    if (widget.ready) return;
    if (ModalRoute.of(context)
        case final ArrivalHoldRouteMixin<Object?> route) {
      final holds = route._arrivalHolds;
      if (holds == null) return;
      holds.add(_hold = Completer());
    }
  }

  @override
  void didUpdateWidget(ArrivalHold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.ready || _hold == null) return;
    SchedulerBinding.instance.addPostFrameCallback((_) => _release());
  }

  @override
  void dispose() {
    _release();
    super.dispose();
  }

  void _release() {
    final hold = _hold;
    _hold = null;
    if (hold != null && !hold.isCompleted) hold.complete();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
