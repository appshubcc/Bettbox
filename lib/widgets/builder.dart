import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:material_ui/material_ui.dart';

class RouteScrollCacheBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, ScrollCacheExtent? cacheExtent)
  builder;

  const RouteScrollCacheBuilder({super.key, required this.builder});

  @override
  State<RouteScrollCacheBuilder> createState() =>
      _RouteScrollCacheBuilderState();
}

class _RouteScrollCacheBuilderState extends State<RouteScrollCacheBuilder> {
  bool _settled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.afterRouteTransition(() {
        if (!mounted) return;
        setState(() {
          _settled = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _settled ? null : const ScrollCacheExtent.pixels(0),
    );
  }
}

class IdleFocusBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, FocusNode focusNode) builder;

  const IdleFocusBuilder({super.key, required this.builder});

  @override
  State<IdleFocusBuilder> createState() => _IdleFocusBuilderState();
}

class _IdleFocusBuilderState extends State<IdleFocusBuilder> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    unawaited(_focusNode.requestFocusWhenIdle());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _focusNode);
  }
}

class FocusStateBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool focused) builder;

  const FocusStateBuilder({super.key, required this.builder});

  @override
  State<FocusStateBuilder> createState() => _FocusStateBuilderState();
}

class _FocusStateBuilderState extends State<FocusStateBuilder> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) {
        if (focused != _focused) setState(() => _focused = focused);
      },
      child: widget.builder(context, _focused),
    );
  }
}

class ScrollOverBuilder extends StatefulWidget {
  final Widget Function(bool isOver) builder;

  const ScrollOverBuilder({super.key, required this.builder});

  @override
  State<ScrollOverBuilder> createState() => _ScrollOverBuilderState();
}

class _ScrollOverBuilderState extends State<ScrollOverBuilder> {
  final isOverNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    isOverNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (scrollNotification) {
        isOverNotifier.value = scrollNotification.metrics.maxScrollExtent > 0;
        return true;
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: isOverNotifier,
        builder: (_, isOver, _) {
          return widget.builder(isOver);
        },
      ),
    );
  }
}

// class ProxiesActionsBuilder extends StatelessWidget {
//   final Widget? child;
//   final Widget Function(
//     ProxiesActionsState state,
//     Widget? child,
//   ) builder;
//
//   const ProxiesActionsBuilder({
//     super.key,
//     required this.child,
//     required this.builder,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Selector<AppState, ProxiesActionsState>(
//       selector: (_, appState) => ProxiesActionsState(
//         isCurrent: appState.currentLabel == "proxies",
//         hasProvider: appState.providers.isNotEmpty,
//       ),
//       builder: (_, state, child) => builder(state, child),
//       child: child,
//     );
//   }
// }

// class ActiveBuilder extends StatelessWidget {
//   final String label;
//   final StateAndChildWidgetBuilder<bool> builder;
//   final Widget? child;
//
//   const ActiveBuilder({
//     super.key,
//     required this.label,
//     required this.builder,
//     required this.child,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Selector<AppState, bool>(
//       selector: (_, appState) => appState.currentLabel == label,
//       builder: (_, state, child) {
//         return builder(
//           state,
//           child,
//         );
//       },
//       child: child,
//     );
//   }
// }

typedef StateWidgetBuilder<T> = Widget Function(T state);

typedef StateAndChildWidgetBuilder<T> = Widget Function(T state, Widget? child);
