import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KeepScope extends StatefulWidget {
  final Widget child;
  final bool keep;

  const KeepScope({super.key, required this.child, this.keep = true});

  @override
  State<KeepScope> createState() => _KeepContainerState();
}

class _KeepContainerState extends State<KeepScope>
    with AutomaticKeepAliveClientMixin {
  @override
  void didUpdateWidget(KeepScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keep != widget.keep) {
      updateKeepAlive();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => widget.keep;
}

class PageActivityScope extends InheritedWidget {
  final bool isActive;

  const PageActivityScope({
    super.key,
    required this.isActive,
    required super.child,
  });

  static bool isActiveOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<PageActivityScope>()
            ?.isActive ??
        true;
  }

  @override
  bool updateShouldNotify(PageActivityScope oldWidget) {
    return isActive != oldWidget.isActive;
  }
}

class ActiveConsumer extends ConsumerStatefulWidget {
  final Widget Function(BuildContext context, WidgetRef ref) builder;

  const ActiveConsumer({super.key, required this.builder});

  @override
  ConsumerState<ActiveConsumer> createState() => _ActiveConsumerState();
}

class _ActiveConsumerState extends ConsumerState<ActiveConsumer> {
  Widget? _child;

  @override
  Widget build(BuildContext context) {
    final child = _child;
    if (child != null && !PageActivityScope.isActiveOf(context)) {
      return child;
    }
    return _child = widget.builder(context, ref);
  }
}
