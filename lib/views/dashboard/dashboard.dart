import 'dart:async';
import 'dart:math' as math;

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'widgets/widgets.dart';

typedef _IsEditWidgetBuilder = Widget Function(bool isEdit);

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  final GlobalKey<_DashboardStartSwitchState> _startSwitchKey = GlobalKey();
  final _isEditNotifier = ValueNotifier<bool>(false);
  final _menuOpenNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    if (globalState.isAndroidTV) {
      globalState.focusDashboardStartSwitch = _requestStartSwitchFocus;
    }
  }

  void _requestStartSwitchFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startSwitchKey.currentState?.requestFocus();
    });
  }

  @override
  void dispose() {
    if (globalState.focusDashboardStartSwitch == _requestStartSwitchFocus) {
      globalState.focusDashboardStartSwitch = null;
    }
    _isEditNotifier.dispose();
    _menuOpenNotifier.dispose();
    super.dispose();
  }

  Widget _buildIsEdit(_IsEditWidgetBuilder builder) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isEditNotifier,
      builder: (_, isEdit, _) => builder(isEdit),
    );
  }

  List<DashboardWidget> _addableWidgets(List<DashboardWidget> current) {
    final families = {for (final item in current) item.family};
    return [
      for (final item in DashboardWidget.values)
        if (item == item.family &&
            !families.contains(item) &&
            item.platforms.contains(SupportPlatform.currentPlatform))
          item,
    ];
  }

  List<DashboardWidget> _currentWidgets() =>
      ref.read(dashboardStateProvider).dashboardWidgets;

  Map<String, String> _currentSizes() => ref.read(
    appSettingProvider.select(
      (state) => system.isAndroid
          ? state.mobileDashboardSizes
          : state.desktopDashboardSizes,
    ),
  );

  void _saveWidgets(
    List<DashboardWidget> dashboardWidgets, {
    Map<String, String>? sizes,
  }) {
    ref
        .read(appSettingProvider.notifier)
        .updateState(
          (state) => system.isAndroid
              ? state.copyWith(
                  mobileDashboardWidgets: dashboardWidgets,
                  dashboardWidgets: dashboardWidgets,
                  mobileDashboardSizes: sizes ?? state.mobileDashboardSizes,
                )
              : state.copyWith(
                  desktopDashboardWidgets: dashboardWidgets,
                  dashboardWidgets: dashboardWidgets,
                  desktopDashboardSizes: sizes ?? state.desktopDashboardSizes,
                ),
        );
  }

  Map<String, String> _sizesWithout(DashboardWidget widget) =>
      {..._currentSizes()}..remove(widget.family.name);

  void _resizeWidget(DashboardTile tile) {
    final sizes = tile.widget.sizes;
    final next = sizes[(sizes.indexOf(tile.size) + 1) % sizes.length];
    final widget = tile.widget.variantFor(next);
    final nextSizes = _sizesWithout(widget);
    if (widget.nativeSize != next) nextSizes[widget.family.name] = next.name;
    _saveWidgets([
      for (final item in _currentWidgets()) item == tile.widget ? widget : item,
    ], sizes: nextSizes);
  }

  void _deleteWidget(DashboardTile tile) {
    _saveWidgets([
      for (final item in _currentWidgets())
        if (item != tile.widget) item,
    ], sizes: _sizesWithout(tile.widget));
  }

  void _moveWidget(DashboardTile from, DashboardTile to) {
    final widgets = [..._currentWidgets()];
    final source = widgets.indexOf(from.widget);
    final target = widgets.indexOf(to.widget);
    if (source < 0 || target < 0 || source == target) return;
    widgets.insert(target, widgets.removeAt(source));
    _saveWidgets(widgets);
  }

  List<Widget> _buildActions(
    bool showStartSwitch,
    ThemeMode themeMode,
    bool watermark,
  ) {
    return [
      _buildIsEdit((isEdit) {
        if (!isEdit) return const SizedBox.shrink();
        return Consumer(
          builder: (_, ref, child) {
            final addable = _addableWidgets(
              ref.watch(dashboardStateProvider).dashboardWidgets,
            );
            if (addable.isEmpty || child == null) {
              return const SizedBox.shrink();
            }
            return child;
          },
          child: IconButton(
            onPressed: _showAddWidgetsModal,
            icon: const Icon(Icons.add_circle),
          ),
        );
      }),
      _buildIsEdit((isEdit) {
        if (isEdit) {
          return IconButton(
            onPressed: _handleUpdateIsEdit,
            tooltip: appLocalizations.save,
            icon: const Icon(Icons.save),
          );
        }
        return CommonPopupBox(
          targetBuilder: (open) {
            final button = IconButton(
              onPressed: () async {
                _menuOpenNotifier.value = true;
                await open(offset: const Offset(0, 20));
                if (!mounted) return;
                _menuOpenNotifier.value = false;
              },
              tooltip: appLocalizations.more,
              icon: showStartSwitch
                  ? ValueListenableBuilder<bool>(
                      valueListenable: _menuOpenNotifier,
                      builder: (_, isOpen, _) => _MenuDots(isOpen: isOpen),
                    )
                  : const Icon(Icons.more_vert),
            );
            if (!showStartSwitch) return button;
            return Transform.translate(
              offset: const Offset(4, 0),
              child: button,
            );
          },
          popup: CommonPopupMenu(
            items: [
              PopupMenuItemData(
                icon: Icons.edit,
                label: appLocalizations.edit,
                onPressed: _handleUpdateIsEdit,
              ),
              PopupMenuItemData(
                icon: switch (themeMode) {
                  ThemeMode.system => Icons.auto_mode,
                  ThemeMode.light => Icons.light_mode,
                  ThemeMode.dark => Icons.dark_mode,
                },
                label: switch (themeMode) {
                  ThemeMode.system => appLocalizations.auto,
                  ThemeMode.light => appLocalizations.light,
                  ThemeMode.dark => appLocalizations.dark,
                },
                onPressed: () {
                  final nextThemeMode = switch (themeMode) {
                    ThemeMode.system => ThemeMode.light,
                    ThemeMode.light => ThemeMode.dark,
                    ThemeMode.dark => ThemeMode.system,
                  };
                  ref
                      .read(themeSettingProvider.notifier)
                      .updateState(
                        (state) => state.copyWith(themeMode: nextThemeMode),
                      );
                  final label = switch (nextThemeMode) {
                    ThemeMode.system => appLocalizations.auto,
                    ThemeMode.light => appLocalizations.light,
                    ThemeMode.dark => appLocalizations.dark,
                  };
                  globalState.showNotifier(
                    '${appLocalizations.themeMode}: $label',
                  );
                },
              ),
              PopupMenuItemData(
                icon: Icons.title,
                label: appLocalizations.customDashboardTitle,
                onPressed: _showEditTitleDialog,
              ),
              PopupMenuItemData(
                icon: watermark
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                label: appLocalizations.backgroundWatermark,
                onPressed: () {
                  ref
                      .read(appSettingProvider.notifier)
                      .updateState(
                        (state) =>
                            state.copyWith(dashboardWatermark: !watermark),
                      );
                },
              ),
              PopupMenuItemData(
                icon: Icons.restart_alt,
                label: appLocalizations.restartCoreTitle,
                onPressed: _handleRestartCore,
              ),
            ],
          ),
        );
      }),
      if (showStartSwitch) _DashboardStartSwitch(key: _startSwitchKey),
    ];
  }

  void _showAddWidgetsModal() {
    showSheet(
      builder: (_, type) {
        return Consumer(
          builder: (_, ref, _) {
            final current = ref.watch(dashboardStateProvider).dashboardWidgets;
            return AdaptiveSheetScaffold(
              type: type,
              body: _AddDashboardWidgetModal(
                items: [
                  for (final item in _addableWidgets(current)) item.widget,
                ],
                onAdd: (gridItem) {
                  final widget = DashboardWidget.values.firstWhere(
                    (item) => item.widget == gridItem,
                  );
                  _saveWidgets([
                    ..._currentWidgets(),
                    widget,
                  ], sizes: _sizesWithout(widget));
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

  Future<void> _handleRestartCore() async {
    if (system.isAndroid) {
      await system.restartApp();
      return;
    }
    final result = await globalState.showMessage(
      title: appLocalizations.restartCoreTitle,
      message: TextSpan(text: appLocalizations.restartCoreDesc),
    );
    if (result != true) return;
    await globalState.appController.restartCore();
    globalState.showNotifier(appLocalizations.success);
  }

  Future<void> _showEditTitleDialog() async {
    final currentTitle =
        ref.read(appSettingProvider.select((s) => s.dashboardTitle)) ?? '';
    final title = await globalState.showCommonDialog<String>(
      child: _DashboardTitleDialog(initialValue: currentTitle),
    );
    if (title != null) {
      ref
          .read(appSettingProvider.notifier)
          .updateState(
            (state) =>
                state.copyWith(dashboardTitle: title.isEmpty ? null : title),
          );
    }
  }

  void _handleUpdateIsEdit() {
    _isEditNotifier.value = !_isEditNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    final dashboardWidgets = ref.watch(
      dashboardStateProvider.select((state) => state.dashboardWidgets),
    );
    final isMobileView = ref.watch(isMobileViewProvider);
    final (customTitle, showStartSwitch) = ref.watch(
      appSettingProvider.select(
        (state) => (state.dashboardTitle, state.showStartSwitch),
      ),
    );
    final themeMode = ref.watch(
      themeSettingProvider.select((state) => state.themeMode),
    );
    final watermark = ref.watch(
      appSettingProvider.select((state) => state.dashboardWatermark),
    );

    final spacing = 12.mAp;
    final sizes = ref.watch(
      appSettingProvider.select(
        (state) => system.isAndroid
            ? state.mobileDashboardSizes
            : state.desktopDashboardSizes,
      ),
    );
    final children = <DashboardTile>[
      for (final item in dashboardWidgets)
        if (item.platforms.contains(SupportPlatform.currentPlatform))
          (widget: item, size: resolveDashboardSize(item, sizes)),
    ];

    final title = customTitle ?? appLocalizations.dashboard;
    return LayoutBuilder(
      builder: (context, page) => _buildScaffold(
        title: title,
        inset: math.max(0, (page.maxWidth - dashboardMaxGridWidth) / 2),
        isMobileView: isMobileView,
        showStartSwitch: showStartSwitch,
        themeMode: themeMode,
        watermark: watermark,
        spacing: spacing,
        children: children,
      ),
    );
  }

  Widget _buildScaffold({
    required String title,
    required double inset,
    required bool isMobileView,
    required bool showStartSwitch,
    required ThemeMode themeMode,
    required bool watermark,
    required double spacing,
    required List<DashboardTile> children,
  }) {
    return CommonScaffold(
      title: title,
      titleWidget: Padding(
        padding: EdgeInsets.only(left: inset),
        child: globalState.isPre
            ? Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: EmojiText(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _PreviewMark(),
                ],
              )
            : EmojiText(title),
      ),
      actions: [
        ..._buildActions(showStartSwitch, themeMode, watermark),
        if (inset > 4) SizedBox(width: inset - 4),
      ],
      body: ScrollEdgeRise(
        builder: (_, rise) => Align(
          alignment: Alignment.topCenter,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = math.min(
                constraints.maxWidth,
                dashboardMaxGridWidth,
              );
              final int columns = isMobileView
                  ? 8
                  : DashboardGridBand.of(contentWidth).columns;
              final bottomReserve = isMobileView
                  ? getFloatingBottomBarReserveHeight(context)
                  : 0.0;
              final verticalPadding = 32.0 + bottomReserve;
              final unitHeight = dashboardUnitHeight(
                contentWidth,
                availableHeight: constraints.hasBoundedHeight
                    ? constraints.maxHeight - rise
                    : null,
                spacing: spacing,
                verticalPadding: verticalPadding,
              );

              final dashboardContent = ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: dashboardMaxGridWidth,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16 + rise,
                    16,
                    16 + bottomReserve,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildIsEdit(
                        (isEdit) => isEdit
                            ? SystemBackBlock(
                                child: CommonPopScope(
                                  onPop: () {
                                    _handleUpdateIsEdit();
                                    return false;
                                  },
                                  child: const SizedBox.shrink(),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      _buildIsEdit(
                        (isEdit) => EditableGrid<DashboardTile>(
                          key: const ValueKey('dashboard-grid'),
                          items: children,
                          editing: isEdit,
                          crossAxisCount: columns,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          keyOf: (tile) => tile.widget.family,
                          crossAxisCellCountOf: (tile) => tile.size.cross * 4,
                          itemBuilder: (_, tile) => buildDashboardTile(tile),
                          canResize: (tile) => tile.widget.resizable,
                          onResize: _resizeWidget,
                          canDelete: (tile) => tile.widget.widget.isDeletable,
                          onDelete: _deleteWidget,
                          onMove: _moveWidget,
                          overlayWrapper: (child) => DashboardWidgetMetrics(
                            unitHeight: unitHeight,
                            spacing: spacing,
                            columns: columns,
                            child: child,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );

              return DashboardWidgetMetrics(
                unitHeight: unitHeight,
                spacing: spacing,
                columns: columns,
                child: dashboardContent,
              );
            },
          ),
        ),
      ),
    );
  }
}

List<GridItem> packGridItems(List<GridItem> items, int totalColumns) {
  if (items.isEmpty) return const [];
  final pool = List<GridItem>.from(items);
  final packed = <GridItem>[];
  var remainingColumns = totalColumns;

  while (pool.isNotEmpty) {
    final index = pool.indexWhere(
      (item) =>
          math.min(item.crossAxisCellCount, totalColumns) <= remainingColumns,
    );
    if (index != -1) {
      final item = pool.removeAt(index);
      packed.add(item);
      remainingColumns -= math.min(item.crossAxisCellCount, totalColumns);
      if (remainingColumns <= 0) {
        remainingColumns = totalColumns;
      }
    } else {
      remainingColumns = totalColumns;
    }
  }

  return packed;
}

class _AddDashboardWidgetModal extends StatelessWidget {
  final List<GridItem> items;
  final void Function(GridItem item) onAdd;

  const _AddDashboardWidgetModal({required this.items, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final spacing = 12.mAp;
    const columns = 8;
    final packedItems = packGridItems(items, columns);
    return DashboardWidgetMetrics(
      unitHeight: 84.0.ap,
      spacing: spacing,
      columns: columns,
      child: DeferredPointerHandler(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Grid(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            children: [
              for (final item in packedItems)
                item.wrap(
                  builder: (child) {
                    return _AddedContainer(
                      onAdd: () => onAdd(item),
                      child: child,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddedContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback onAdd;

  const _AddedContainer({required this.child, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ActivateBox(child: child),
        Positioned(
          top: -8,
          right: -8,
          child: DeferPointer(
            child: SizedBox(
              width: 24,
              height: 24,
              child: IconButton.filled(
                iconSize: 20,
                padding: const EdgeInsets.all(2),
                onPressed: onAdd,
                icon: const Icon(Icons.add),
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
    final nextErrorText = len > 20 ? appLocalizations.titleTooLong : null;
    if (nextErrorText != _errorText) {
      setState(() {
        _errorText = nextErrorText;
      });
    }
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

  Future<void> _handleStart() async {
    if (_isDisabled) return;
    final newState =
        ref.read(isSmartStoppedProvider) || ref.read(runTimeProvider) == null;
    setState(() {
      _isDisabled = true;
      _optimisticStart = newState;
    });

    try {
      await globalState.appController.updateStatus(newState);
    } catch (e) {
      commonPrint.error('updateStatus failed: $e');
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
    final (isInit, hasProfile) = ref.watch(
      startButtonSelectorStateProvider.select(
        (state) => (state.isInit, state.hasProfile),
      ),
    );
    final isRestarting = ref.watch(isRestartingCoreProvider);
    final isSmartStopped = ref.watch(isSmartStoppedProvider);
    final isStart = ref.watch(runTimeProvider.select((state) => state != null));
    final displayStart = isSmartStopped ? false : (_optimisticStart ?? isStart);

    final canPress = isInit && hasProfile && !_isDisabled && !isRestarting;

    final colorScheme = context.colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    final isBusy = _isDisabled || isRestarting;
    final isAvailable = isInit && hasProfile;
    final (style, onLabel, offLabel) = ref.watch(
      appSettingProvider.select(
        (state) => (
          state.startSwitchStyle,
          state.startSwitchOnLabel,
          state.startSwitchOffLabel,
        ),
      ),
    );
    final isOutlined = style == StartSwitchStyle.outlined;
    final trackColor = isOutlined
        ? isLight
              ? Color.lerp(
                  colorScheme.surface,
                  colorScheme.surfaceContainerLowest,
                  0.5,
                )
              : colorScheme.surfaceContainerHigh
        : displayStart
        ? colorScheme.primary.withValues(alpha: isLight ? 0.12 : 0.2)
        : colorScheme.onSurface.withValues(alpha: 0.06);
    final borderSide = isOutlined
        ? BorderSide(
            color: displayStart
                ? colorScheme.primary.withValues(alpha: 0.45)
                : colorScheme.outlineVariant.withValues(
                    alpha: isLight ? 0.45 : 0.25,
                  ),
          )
        : BorderSide.none;
    final iconColor = displayStart
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    final labelMediumStyle = context.textTheme.labelMedium;
    final labels = [
      (
        offLabel ?? appLocalizations.disabled,
        !displayStart,
        colorScheme.onSurfaceVariant,
      ),
      (onLabel ?? appLocalizations.enabled, displayStart, colorScheme.primary),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: AnimatedOpacity(
        opacity: isAvailable ? 1 : 0.38,
        duration: midDuration,
        child: TextButton(
          focusNode: _focusNode,
          onPressed: canPress ? _handleStart : null,
          style: ButtonStyle(
            visualDensity: VisualDensity.standard,
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            minimumSize: const WidgetStatePropertyAll(Size.zero),
            backgroundColor: WidgetStatePropertyAll(trackColor),
            shape: WidgetStateProperty.resolveWith(
              (states) => StadiumBorder(
                side: states.contains(WidgetState.focused)
                    ? BorderSide(color: colorScheme.primary, width: 2)
                    : borderSide,
              ),
            ),
          ),
          child: Stack(
            children: [
              AnimatedPadding(
                duration: midDuration,
                curve: Curves.easeOutCubic,
                padding: EdgeInsetsDirectional.only(
                  start: displayStart ? 4 : 26,
                  end: displayStart ? 26 : 4,
                ),
                child: SizedBox(
                  height: 24,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (final (label, isActive, color) in labels)
                        AnimatedOpacity(
                          opacity: isActive ? 1 : 0,
                          duration: midDuration,
                          child: Text(
                            label,
                            maxLines: 1,
                            style: labelMediumStyle?.copyWith(color: color),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: AnimatedAlign(
                  duration: midDuration,
                  curve: Curves.easeOutCubic,
                  alignment: displayStart
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: SizedBox.square(
                    dimension: 20,
                    child: Center(
                      child: isBusy
                          ? RepaintBoundary(
                              child: SizedBox.square(
                                dimension: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: iconColor,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.power_settings_new,
                              size: 18,
                              color: iconColor,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewMark extends StatelessWidget {
  const _PreviewMark();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.6)),
      ),
      child: Text(
        kDebugMode ? 'DEBUG' : 'PRE',
        style: context.textTheme.labelSmall?.copyWith(
          fontSize: 9.5,
          height: 1.3,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class _MenuDots extends ConsumerWidget {
  final bool isOpen;

  const _MenuDots({required this.isOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStart = ref.watch(runTimeProvider.select((value) => value != null));
    return MenuDotsIcon(
      isOpen: isOpen,
      accent: isStart ? context.colorScheme.primary : null,
    );
  }
}
