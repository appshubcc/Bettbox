import 'dart:convert';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/plugins/app.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/dashboard/widgets/profile_info.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AndroidManager extends ConsumerStatefulWidget {
  final Widget child;

  const AndroidManager({super.key, required this.child});

  @override
  ConsumerState<AndroidManager> createState() => _AndroidContainerState();
}

class _AndroidContainerState extends ConsumerState<AndroidManager>
    with WidgetsBindingObserver {
  ProviderSubscription<HomeWidgetSnapshot>? _homeWidget;
  String? _lastHomeWidget;

  @override
  void initState() {
    super.initState();
    ref.listenManual(appSettingProvider.select((state) => state.hidden), (
      prev,
      next,
    ) {
      app.updateExcludeFromRecents(next);
    }, fireImmediately: true);
    WidgetsBinding.instance.addObserver(this);
    app.onHomeWidgetAction = _handleHomeWidgetAction;
    app.onHomeWidgetsChanged = _setHomeWidgetsActive;
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncHomeWidgets());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    app.onHomeWidgetAction = null;
    app.onHomeWidgetsChanged = null;
    _homeWidget?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _syncHomeWidgets();
  }

  Future<void> _syncHomeWidgets() async {
    final active = await app.hasHomeWidgets();
    if (!mounted) return;
    _setHomeWidgetsActive(active);
    final action = await app.consumeHomeWidgetAction();
    if (action == null || !mounted) return;
    _handleHomeWidgetAction(action);
  }

  void _setHomeWidgetsActive(bool active) {
    if (!active) {
      _homeWidget?.close();
      _homeWidget = null;
      _lastHomeWidget = null;
      return;
    }
    if (_homeWidget case final subscription?) {
      _lastHomeWidget = null;
      _pushHomeWidget(subscription.read());
      return;
    }
    _homeWidget = ref.listenManual(
      homeWidgetSnapshotProvider,
      (_, next) => _pushHomeWidget(next),
      fireImmediately: true,
    );
  }

  void _pushHomeWidget(HomeWidgetSnapshot snapshot) {
    debouncer.call(FunctionTag.homeWidget, () {
      final data = json.encode(snapshot);
      if (data == _lastHomeWidget) return;
      _lastHomeWidget = data;
      app.updateHomeWidget(data);
    }, duration: const Duration(milliseconds: 800));
  }

  void _handleHomeWidgetAction(String action) {
    if (!ref.read(initProvider)) {
      late final ProviderSubscription<bool> subscription;
      subscription = ref.listenManual(initProvider, (_, isInit) {
        if (!isInit) return;
        subscription.close();
        _handleHomeWidgetAction(action);
      });
      return;
    }
    if (action != 'refresh') return;
    final context = globalState.navigatorKey.currentState?.context;
    final profile = ref.read(currentProfileProvider);
    if (context == null || !context.mounted || profile == null) return;
    refreshProfileSubscription(context, ref, profile);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
