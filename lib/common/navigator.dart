import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/app.dart';
import 'package:bett_box/state.dart';
import 'package:flutter/cupertino.dart';

class BaseNavigator {
  static Future<T?> push<T>(
    BuildContext context,
    Widget child, {
    bool maintainState = true,
  }) async {
    if (globalState.appState.viewMode != ViewMode.mobile) {
      return await Navigator.of(
        context,
      ).push<T>(
        CommonDesktopRoute(
          builder: (context) => child,
          maintainState: maintainState,
        ),
      );
    }
    return await Navigator.of(
      context,
    ).push<T>(
      _CleanCupertinoPageRoute(
        builder: (context) => child,
        maintainState: maintainState,
      ),
    );
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
  Color? get barrierColor => null;
}

class CommonDesktopRoute<T> extends PageRoute<T> {
  final Widget Function(BuildContext context) builder;

  CommonDesktopRoute({
    required this.builder,
    this.maintainState = true,
  });

  @override
  final bool maintainState;

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
      child: FadeTransition(opacity: animation, child: result),
    );
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  Duration get reverseTransitionDuration => Duration(milliseconds: 200);
}
