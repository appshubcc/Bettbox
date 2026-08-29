import 'dart:async';
import 'dart:math';

import 'package:bett_box/state.dart';

import 'package:defer_pointer/defer_pointer.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customDashboardTitleProvider =
    StateNotifierProvider<CustomDashboardTitleNotifier, String?>((ref) {
      return CustomDashboardTitleNotifier();
    });

class CustomDashboardTitleNotifier extends StateNotifier<String?> {
  CustomDashboardTitleNotifier() : super(null) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await preferences.sharedPreferencesCompleter.future;
    state = prefs?.getString(customDashboardTitleKey);
  }

  Future<void> updateTitle(String? title) async {
    state = title;
    final prefs = await preferences.sharedPreferencesCompleter.future;
    if (title == null) {
      prefs?.remove(customDashboardTitleKey);
    } else {
      prefs?.setString(customDashboardTitleKey, title);
    }
  }
}

typedef _IsEditWidgetBuilder = Widget Function(bool isEdit);

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  final key = GlobalKey<SuperGridState>();
  final GlobalKey<_DashboardStartSwitchState> _startSwitchKey = GlobalKey();
  final _isEditNotifier = ValueNotifier<bool>(false);
  final _addedWidgetsNotifier = ValueNotifier<List<GridItem>>([]);

  @override
  void initState() {
    super.initState();
    if (globalState.isAndroidTV) {
      globalState.focusDashboardStartSwitch = _requestStartSwitchFocus;
    }
  }

  void _requestStartSwitchFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSwitchKey.currentState?.requestFocus();
    });
  }

  @override
  void dispose() {
    if (globalState.focusDashboardStartSwitch == _requestStartSwitchFocus) {
      globalState.focusDashboardStartSwitch = null;
    }
    _isEditNotifier.dispose();
    _addedWidgetsNotifier.dispose();
    super.dispose();
  }

  Widget _buildIsEdit(_IsEditWidgetBuilder builder) {
    return ValueListenableBuilder(
      valueListenable: _isEditNotifier,
      builder: (_, isEdit, _) {
        return builder(isEdit);
      },
    );
  }

  List<Widget> _buildActions() {
    final showStartSwitch = ref.watch(
      appSettingProvider.select((state) => state.showStartSwitch),
    );
    return [
      _buildIsEdit((isEdit) {
        return isEdit
            ? ValueListenableBuilder(
                valueListenable: _addedWidgetsNotifier,
                builder: (_, addedChildren, child) {
                  if (addedChildren.isEmpty) {
                    return Container();
                  }
                  return child!;
                },
                child: IconButton(
                  onPressed: () {
                    _showAddWidgetsModal();
                  },
                  icon: Icon(Icons.add_circle),
                ),
              )
            : SizedBox();
      }),
      Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: _handleUpdateIsEdit,
          onLongPress: () {
            if (!_isEditNotifier.value) {
              _showEditTitleDialog();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildIsEdit((isEdit) {
              return isEdit ? const Icon(Icons.save) : const Icon(Icons.edit);
            }),
          ),
        ),
      ),
      if (showStartSwitch) _DashboardStartSwitch(key: _startSwitchKey),
    ];
  }

  void _showAddWidgetsModal() {
    showSheet(
      builder: (_, type) {
        return ValueListenableBuilder(
          valueListenable: _addedWidgetsNotifier,
          builder: (_, value, _) {
            return AdaptiveSheetScaffold(
              type: type,
              body: _AddDashboardWidgetModal(
                items: value,
                onAdd: (gridItem) {
                  key.currentState?.handleAdd(gridItem);
                },
              ),
              title: appLocalizations.add,
            );
          },
        );
      },
      context: context,
    );
  }

  void _showEditTitleDialog() async {
    final currentTitle = ref.read(customDashboardTitleProvider) ?? '';
    final title = await globalState.showCommonDialog<String>(
      child: _DashboardTitleDialog(initialValue: currentTitle),
    );
    if (title != null) {
      ref
          .read(customDashboardTitleProvider.notifier)
          .updateTitle(title.isEmpty ? null : title);
    }
  }

  void _handleUpdateIsEdit() {
    if (_isEditNotifier.value == true) {
      _handleSave();
    }
    _isEditNotifier.value = !_isEditNotifier.value;
  }

  void _handleSave() {
    final children = key.currentState?.children;
    if (children == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardWidgets = children
          .map((item) => DashboardWidget.getDashboardWidget(item))
          .toList();
      ref
          .read(appSettingProvider.notifier)
          .updateState(
            (state) => system.isMobile
                ? state.copyWith(
                    mobileDashboardWidgets: dashboardWidgets,
                    dashboardWidgets: dashboardWidgets,
                  )
                : state.copyWith(
                    desktopDashboardWidgets: dashboardWidgets,
                    dashboardWidgets: dashboardWidgets,
                  ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final columns = max(4 * ((dashboardState.viewWidth / 320).ceil()), 8);
    final spacing = 16.ap;
    final isMobileView = ref.watch(isMobileViewProvider);
    final children = [
      ...dashboardState.dashboardWidgets
          .where(
            (item) => item.platforms.contains(SupportPlatform.currentPlatform),
          )
          .map((item) => item.widget),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addedWidgetsNotifier.value = DashboardWidget.values
          .where(
            (item) =>
                !children.contains(item.widget) &&
                item.platforms.contains(SupportPlatform.currentPlatform),
          )
          .map((item) => item.widget)
          .toList();
    });
    return CommonScaffold(
      title:
          ref.watch(customDashboardTitleProvider) ?? appLocalizations.dashboard,
      actions: _buildActions(),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16).copyWith(
            bottom:
                16 +
                (isMobileView ? getFloatingBottomBarReserveHeight(context) : 0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIsEdit((isEdit) {
                if (isEdit) {
                  return SystemBackBlock(
                    child: CommonPopScope(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SuperGrid(
                            key: key,
                            crossAxisCount: columns,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            children: [
                              ...dashboardState.dashboardWidgets
                                  .where(
                                    (item) => item.platforms.contains(
                                      SupportPlatform.currentPlatform,
                                    ),
                                  )
                                  .map((item) => item.widget),
                            ],
                            onUpdate: () {
                              _handleSave();
                            },
                          ),
                        ],
                      ),
                      onPop: () {
                        _handleUpdateIsEdit();
                        return false;
                      },
                    ),
                  );
                } else {
                  return Grid(
                    crossAxisCount: columns,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    children: [...children],
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddDashboardWidgetModal extends StatelessWidget {
  final List<GridItem> items;
  final Function(GridItem item) onAdd;

  const _AddDashboardWidgetModal({required this.items, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return DeferredPointerHandler(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Grid(
          crossAxisCount: 8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: items
              .map(
                (item) => item.wrap(
                  builder: (child) {
                    return _AddedContainer(
                      onAdd: () {
                        onAdd(item);
                      },
                      child: child,
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _AddedContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onAdd;

  const _AddedContainer({required this.child, required this.onAdd});

  @override
  State<_AddedContainer> createState() => _AddedContainerState();
}

class _AddedContainerState extends State<_AddedContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(_AddedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {}
  }

  Future<void> _handleAdd() async {
    widget.onAdd();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ActivateBox(child: widget.child),
        Positioned(
          top: -8,
          right: -8,
          child: DeferPointer(
            child: SizedBox(
              width: 24,
              height: 24,
              child: IconButton.filled(
                iconSize: 20,
                padding: EdgeInsets.all(2),
                onPressed: _handleAdd,
                icon: Icon(Icons.add),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardTitleDialog extends StatefulWidget {
  final String initialValue;

  const _DashboardTitleDialog({required this.initialValue});

  @override
  State<_DashboardTitleDialog> createState() => _DashboardTitleDialogState();
}

class _DashboardTitleDialogState extends State<_DashboardTitleDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate(String value) {
    int len = 0;
    for (int i = 0; i < value.length; i++) {
      len += value.codeUnitAt(i) > 127 ? 2 : 1;
    }
    setState(() {
      if (len > 20) {
        _errorText = appLocalizations.titleTooLong;
      } else {
        _errorText = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.customDashboardTitle,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: _errorText == null
              ? () {
                  Navigator.of(context).pop(_controller.text);
                }
              : null,
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Have fun with Bettbox',
            errorText: _errorText,
            border: const OutlineInputBorder(),
          ),
          onChanged: _validate,
        ),
      ),
    );
  }
}

class _DashboardStartSwitch extends ConsumerStatefulWidget {
  const _DashboardStartSwitch({super.key});

  @override
  ConsumerState<_DashboardStartSwitch> createState() =>
      _DashboardStartSwitchState();
}

class _DashboardStartSwitchState extends ConsumerState<_DashboardStartSwitch> {
  bool _isDisabled = false;
  bool? _optimisticStart;
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    if (globalState.isAndroidTV) {
      _focusNode = FocusNode()..addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode?.removeListener(_onFocusChange);
    _focusNode?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    globalState.isDashboardStartSwitchFocused = _focusNode?.hasFocus ?? false;
  }

  void requestFocus() {
    _focusNode?.requestFocus();
  }

  void _handleStart() async {
    if (_isDisabled) return;
    final isStart = ref.read(runTimeProvider) != null;
    final newState = !isStart;
    setState(() {
      _isDisabled = true;
      _optimisticStart = newState;
    });

    try {
      await globalState.appController.updateStatus(newState);
    } catch (e) {
      commonPrint.log('updateStatus failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDisabled = false;
          _optimisticStart = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(startButtonSelectorStateProvider);
    final isRestarting = ref.watch(isRestartingCoreProvider);
    final runTime = ref.watch(runTimeProvider);
    final isStart = runTime != null;
    final displayStart = _optimisticStart ?? isStart;

    final canPress =
        state.isInit && state.hasProfile && !_isDisabled && !isRestarting;

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Switch(
        focusNode: _focusNode,
        value: displayStart,
        onChanged: canPress ? (_) => _handleStart() : null,
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected) &&
              !states.contains(WidgetState.disabled)) {
            return theme.colorScheme.primary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected) &&
              !states.contains(WidgetState.disabled)) {
            return theme.colorScheme.primary.withValues(alpha: 0.2);
          }
          return null;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected) &&
              !states.contains(WidgetState.disabled)) {
            return Colors.transparent;
          }
          return null;
        }),
      ),
    );
  }
}
