import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/access.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverrideProfileView extends StatefulWidget {
  final String profileId;

  const OverrideProfileView({super.key, required this.profileId});

  @override
  State<OverrideProfileView> createState() => _OverrideProfileViewState();
}

class _OverrideProfileViewState extends State<OverrideProfileView> {
  final _controller = ScrollController();
  double _currentMaxWidth = 0;
  bool _initialized = false;

  void _initState(WidgetRef ref) {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.afterRouteTransition(() async {
        final rawConfig = await globalState.getProfileSnippet(
          widget.profileId,
          effective: true,
        );
        if (!mounted) return;
        final snippet = ClashConfigSnippet.fromJson(rawConfig);
        final overrideData = ref.read(
          getProfileOverrideDataProvider(widget.profileId),
        );
        ref
            .read(profileOverrideStateProvider.notifier)
            .updateState(
              (state) =>
                  state.copyWith(snippet: snippet, overrideData: overrideData),
            );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave(WidgetRef ref, OverrideData overrideData) {
    ref
        .read(profilesProvider.notifier)
        .updateProfile(
          widget.profileId,
          (state) => state.copyWith(overrideData: overrideData),
        );
    globalState.appController.setupClashConfigDebounce();
  }

  Future<void> _handleDelete(WidgetRef ref) async {
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteMultipTip(appLocalizations.rule),
      ),
    );
    if (res != true) {
      return;
    }
    final selectedRules = ref.read(
      profileOverrideStateProvider.select((state) => state.selectedRules),
    );
    ref.read(profileOverrideStateProvider.notifier).updateState((state) {
      final overrideData = state.overrideData;
      if (overrideData == null) return state;
      final overrideRule = overrideData.rule.updateRules(
        (rules) =>
            List.from(rules.where((item) => !selectedRules.contains(item.id))),
      );
      return state.copyWith(
        overrideData: overrideData.copyWith(rule: overrideRule),
      );
    });
    ref
        .read(profileOverrideStateProvider.notifier)
        .updateState((state) => state.copyWith(selectedRules: {}));
  }

  Widget _buildContent() {
    return Consumer(
      builder: (_, ref, child) {
        final isInit = ref.watch(
          profileOverrideStateProvider.select(
            (state) => state.snippet != null && state.overrideData != null,
          ),
        );
        if (!isInit) {
          return const Center(
            child: SyncedLoading(size: 40, child: CircularProgressIndicator()),
          );
        }
        return FadeBox(child: child ?? const SizedBox());
      },
      child: LayoutBuilder(
        builder: (_, constraints) {
          _currentMaxWidth = constraints.maxWidth - 66;
          return ScrollEdgeRise(
            builder: (_, rise) => CommonScrollBar(
              controller: _controller,
              child: CustomScrollView(
                controller: _controller,
                // ignore: deprecated_member_use
                cacheExtent: 500,
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: 8 + rise)),
                  SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(child: OverrideSwitch()),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: RuleTitle(profileId: widget.profileId),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 0,
                    ),
                    sliver: RuleContent(maxWidth: _currentMaxWidth),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        profileOverrideStateProvider.overrideWith(() => ProfileOverrideState()),
      ],
      child: Consumer(
        builder: (_, ref, child) {
          _initState(ref);
          return child ?? const SizedBox();
        },
        child: Consumer(
          builder: (_, ref, _) {
            final selectCount = ref.watch(
              profileOverrideStateProvider.select(
                (state) => state.selectedRules.length,
              ),
            );
            final isSelectMode = selectCount != 0;
            final overrideData = ref.watch(
              getProfileOverrideDataProvider(widget.profileId),
            );
            final newOverrideData = ref.watch(
              profileOverrideStateProvider.select(
                (state) => state.overrideData,
              ),
            );
            final equals = overrideData == newOverrideData;
            final hasUnsavedChanges =
                !isSelectMode && !equals && newOverrideData != null;

            return CommonPopScope(
              onPop: () async {
                if (!hasUnsavedChanges) {
                  return true;
                }
                final res = await globalState.showMessage(
                  message: TextSpan(text: appLocalizations.saveChanges),
                );
                if (res == null) {
                  return false;
                }
                if (res == true && context.mounted) {
                  _handleSave(ref, newOverrideData);
                }
                return true;
              },
              child: CommonScaffold(
                title: appLocalizations.override,
                body: _buildContent(),
                actions: [
                  if (hasUnsavedChanges)
                    IconButton(
                      onPressed: () async {
                        final res = await globalState.showMessage(
                          message: TextSpan(text: appLocalizations.saveChanges),
                        );
                        if (res != true) {
                          return;
                        }
                        _handleSave(ref, newOverrideData);
                      },
                      tooltip: appLocalizations.save,
                      icon: Icon(Icons.save),
                    ),
                  if (selectCount > 0)
                    IconButton(
                      onPressed: () {
                        _handleDelete(ref);
                      },
                      tooltip: appLocalizations.delete,
                      icon: Icon(Icons.delete),
                    ),
                ],
                editState: AppBarEditState(
                  editCount: selectCount,
                  onExit: () {
                    ref
                        .read(profileOverrideStateProvider.notifier)
                        .updateState(
                          (state) => state.copyWith(selectedRules: {}),
                        );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class OverrideSwitch extends ConsumerWidget {
  const OverrideSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enable = ref.watch(
      profileOverrideStateProvider.select(
        (state) => state.overrideData?.enable,
      ),
    );
    return CommonCard(
      onPressed: () {},
      type: CommonCardType.filled,
      radius: 18,
      child: ListItem.switchItem(
        padding: const EdgeInsets.only(left: 16, right: 16),
        title: Text(appLocalizations.enableOverride),
        delegate: SwitchDelegate(
          value: enable ?? false,
          onChanged: (value) {
            ref.read(profileOverrideStateProvider.notifier).updateState((
              state,
            ) {
              final data = state.overrideData;
              if (data == null) return state;
              return state.copyWith(overrideData: data.copyWith(enable: value));
            });
          },
        ),
      ),
    );
  }
}

class RuleTitle extends ConsumerWidget {
  final String profileId;

  const RuleTitle({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, ref) {
    final (isSelectMode, isSelectAll) = ref.watch(
      profileOverrideStateProvider.select((state) {
        final overrideRule = state.overrideData?.rule;
        final rules = overrideRule?.rules ?? [];
        return (
          state.selectedRules.isNotEmpty,
          rules.isNotEmpty &&
              rules.every((item) => state.selectedRules.contains(item.id)),
        );
      }),
    );
    return FilledButtonTheme(
      data: FilledButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
          visualDensity: VisualDensity.compact,
        ),
      ),
      child: IconButtonTheme(
        data: IconButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            visualDensity: VisualDensity.compact,
            iconSize: WidgetStatePropertyAll(20),
          ),
        ),
        child: ListHeader(
          title: appLocalizations.rule,
          subTitle: appLocalizations.addedOriginRules,
          space: 8,
          actions: [
            !isSelectMode
                ? FilledButton.tonal(
                    onPressed: () {
                      globalState.appController.handleAddOrUpdate(ref);
                    },
                    child: Text(appLocalizations.add),
                  )
                : isSelectAll
                ? FilledButton(
                    onPressed: () {
                      ref
                          .read(profileOverrideStateProvider.notifier)
                          .updateState(
                            (state) => state.copyWith(selectedRules: {}),
                          );
                    },
                    child: Text(appLocalizations.selectAll),
                  )
                : FilledButton.tonal(
                    onPressed: () {
                      ref
                          .read(profileOverrideStateProvider.notifier)
                          .updateState(
                            (state) => state.copyWith(
                              selectedRules:
                                  state.overrideData?.rule.rules
                                      .map((item) => item.id)
                                      .toSet() ??
                                  {},
                            ),
                          );
                    },
                    child: Text(appLocalizations.selectAll),
                  ),
          ],
        ),
      ),
    );
  }
}

class _RuleParts {
  final String type;
  final String content;
  final String target;
  final List<String> flags;

  const _RuleParts({
    required this.type,
    required this.content,
    required this.target,
    required this.flags,
  });

  static final _partsCache = Expando<_RuleParts>();

  static _RuleParts of(Rule rule) {
    final cached = _partsCache[rule];
    if (cached != null) return cached;
    final parts = _RuleParts.parse(rule.value);
    _partsCache[rule] = parts;
    return parts;
  }

  factory _RuleParts.parse(String value) {
    final raw = value.trim();
    final index = raw.indexOf(',');
    final parsed = ParsedRule.parseString(raw);
    return _RuleParts(
      type: index == -1 ? raw : raw.substring(0, index).trim(),
      content: parsed.content ?? parsed.ruleProvider ?? '',
      target: parsed.ruleTarget ?? parsed.subRule ?? '',
      flags: [if (parsed.src) 'src', if (parsed.noResolve) 'no-resolve'],
    );
  }
}

class RuleRow extends StatefulWidget {
  const RuleRow({
    super.key,
    required this.rule,
    required this.index,
    required this.isSelected,
    required this.isSelectMode,
    required this.onEdit,
    required this.onTab,
  });

  final Rule rule;
  final int index;
  final bool isSelected;
  final bool isSelectMode;
  final VoidCallback onEdit;
  final VoidCallback onTab;

  @override
  State<RuleRow> createState() => _RuleRowState();
}

class _RuleRowState extends State<RuleRow> {
  static const _longPressDelay = kLongPressTimeout;

  Timer? _hapticTimer;
  Offset? _pressOrigin;
  double _slop = kTouchSlop;
  int? _iconDragPointer;
  bool _hovered = false;

  @override
  void dispose() {
    _cancelHaptic();
    super.dispose();
  }

  void _cancelHaptic() {
    _hapticTimer?.cancel();
    _hapticTimer = null;
    _pressOrigin = null;
  }

  void _startDrag(
    PointerDownEvent event,
    MultiDragGestureRecognizer recognizer,
  ) {
    final settings = MediaQuery.maybeGestureSettingsOf(context);
    SliverReorderableList.maybeOf(context)?.startItemDragReorder(
      index: widget.index,
      event: event,
      recognizer: recognizer..gestureSettings = settings,
    );
  }

  void _handleCardPointerDown(PointerDownEvent event) {
    if (!widget.isSelectMode || event.pointer == _iconDragPointer) {
      return;
    }
    _cancelHaptic();
    _pressOrigin = event.position;
    _slop = computeHitSlop(
      event.kind,
      MediaQuery.maybeGestureSettingsOf(context),
    );
    _hapticTimer = Timer(_longPressDelay, HapticFeedback.selectionClick);
    _startDrag(event, DelayedMultiDragGestureRecognizer());
  }

  void _handleIconPointerDown(PointerDownEvent event) {
    if (event.kind != PointerDeviceKind.mouse) {
      return;
    }
    _iconDragPointer = event.pointer;
    _startDrag(event, ImmediateMultiDragGestureRecognizer());
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final origin = _pressOrigin;
    if (origin != null && (event.position - origin).distance > _slop) {
      _cancelHaptic();
    }
  }

  void _handlePointerEnd(PointerEvent event) {
    _cancelHaptic();
    _iconDragPointer = null;
  }

  void _handleTap() {
    if (widget.isSelectMode) {
      widget.onTab();
    } else {
      widget.onEdit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showControls = widget.isSelectMode || _hovered;
    final parts = _RuleParts.of(widget.rule);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (!_hovered) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (_hovered) {
          setState(() => _hovered = false);
        }
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: CommonCard(
            elevated: false,
            padding: EdgeInsets.zero,
            radius: 18,
            type: CommonCardType.filled,
            isSelected: widget.isSelected,
            onPressed: _handleTap,
            onLongPress: widget.isSelectMode ? null : widget.onTab,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _handleCardPointerDown,
              onPointerMove: _handlePointerMove,
              onPointerUp: _handlePointerEnd,
              onPointerCancel: _handlePointerEnd,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      child: Row(
                        spacing: 6,
                        children: [
                          Expanded(
                            child: Row(
                              spacing: 6,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colorScheme.primary
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    parts.type,
                                    maxLines: 1,
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(
                                          color: context.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                if (parts.target.isNotEmpty) ...[
                                  Icon(
                                    Icons.arrow_right_alt,
                                    size: 16,
                                    color: context.colorScheme.outline,
                                  ),
                                  Flexible(
                                    child: EmojiText(
                                      parts.target,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.labelLarge
                                          ?.copyWith(
                                            color: context
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                                for (final flag in parts.flags)
                                  Text(
                                    flag,
                                    maxLines: 1,
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(
                                          color: context.colorScheme.outline,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                          if (showControls) ...[
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                shape: const CircleBorder(),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                value: widget.isSelected,
                                onChanged: (_) => widget.onTab(),
                              ),
                            ),
                            Listener(
                              behavior: HitTestBehavior.opaque,
                              onPointerDown: _handleIconPointerDown,
                              child: Tooltip(
                                message: appLocalizations.sort,
                                child: InkResponse(
                                  onTap: _handleTap,
                                  mouseCursor: SystemMouseCursors.move,
                                  radius: 16,
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Icon(
                                      Icons.drag_indicator,
                                      size: 20,
                                      color: context.colorScheme.outline,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (parts.content.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: EmojiText(
                          parts.content,
                          style: context.textTheme.bodyMedium?.toJetBrainsMono,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RuleContent extends ConsumerWidget {
  final double maxWidth;

  const RuleContent({super.key, required this.maxWidth});

  void _handleSelect(WidgetRef ref, String ruleId) {
    ref.read(profileOverrideStateProvider.notifier).updateState((state) {
      final newSelectedRules = Set<String>.from(state.selectedRules);
      if (newSelectedRules.contains(ruleId)) {
        newSelectedRules.remove(ruleId);
      } else {
        newSelectedRules.add(ruleId);
      }
      return state.copyWith(selectedRules: newSelectedRules);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (rules, selectedRules) = ref.watch(
      profileOverrideStateProvider.select((state) {
        final overrideRule = state.overrideData?.rule;
        return (overrideRule?.rules ?? [], state.selectedRules);
      }),
    );
    final isSelectMode = selectedRules.isNotEmpty;
    if (rules.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(child: Text(appLocalizations.noData)),
        ),
      );
    }
    return CacheItemExtentSliverReorderableList(
      tag: CacheTag.rules,
      itemBuilder: (context, index) {
        final rule = rules[index];
        return RuleRow(
          key: ObjectKey(rule),
          rule: rule,
          index: index,
          isSelected: selectedRules.contains(rule.id),
          isSelectMode: isSelectMode,
          onEdit: () {
            globalState.appController.handleAddOrUpdate(ref, rule);
          },
          onTab: () {
            _handleSelect(ref, rule.id);
          },
        );
      },
      proxyDecorator: proxyDecorator,
      itemCount: rules.length,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final newRules = List<Rule>.from(rules);
        final item = newRules.removeAt(oldIndex);
        newRules.insert(newIndex, item);
        ref.read(profileOverrideStateProvider.notifier).updateState((state) {
          final data = state.overrideData;
          if (data == null) return state;
          return state.copyWith(
            overrideData: data.copyWith(
              rule: data.rule.updateRules((_) => newRules),
            ),
          );
        });
      },
      keyBuilder: (int index) {
        return rules[index].value;
      },
      itemExtentBuilder: (index) {
        final content = _RuleParts.of(rules[index]).content;
        if (content.isEmpty) return 60;
        return 66 +
            globalState.measure
                .computeTextSize(
                  Text(
                    content,
                    style: context.textTheme.bodyMedium?.toJetBrainsMono,
                  ),
                  maxWidth: maxWidth,
                )
                .height;
      },
    );
  }
}

class AddRuleDialog extends StatefulWidget {
  final ClashConfigSnippet snippet;
  final Rule? rule;

  const AddRuleDialog({super.key, required this.snippet, this.rule});

  @override
  State<AddRuleDialog> createState() => _AddRuleDialogState();
}

class _AddRuleDialogState extends State<AddRuleDialog> {
  late RuleAction _ruleAction;
  late final List<RuleAction> _ruleActions = [
    if (system.isAndroid) RuleAction.PROCESS_NAME,
    ...RuleAction.values.where(
      (item) => !system.isAndroid || item != RuleAction.PROCESS_NAME,
    ),
  ];
  final _ruleTargetController = TextEditingController();
  final _contentController = TextEditingController();
  final _ruleProviderController = TextEditingController();
  final _subRuleController = TextEditingController();
  bool _noResolve = false;
  bool _src = false;
  List<String> _targetItems = [];
  List<String> _ruleProviderItems = [];
  List<String> _subRuleItems = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _initState();
    super.initState();
  }

  void _initState() {
    _targetItems = [
      ...widget.snippet.proxyGroups
          .map((item) => item.name)
          .where((name) => name != 'GLOBAL'),
      ...RuleTarget.values.map((item) => item.name),
    ];
    _ruleProviderItems = [
      ...widget.snippet.ruleProvider.map((item) => item.name),
    ];
    _subRuleItems = [...widget.snippet.subRules.map((item) => item.name)];
    final currentRule = widget.rule;
    if (currentRule != null) {
      final parsedRule = ParsedRule.parseString(currentRule.value);
      _ruleAction = parsedRule.ruleAction;
      _contentController.text = parsedRule.content ?? '';
      _ruleTargetController.text = parsedRule.ruleTarget ?? '';
      _ruleProviderController.text = parsedRule.ruleProvider ?? '';
      _subRuleController.text = parsedRule.subRule ?? '';
      _noResolve = parsedRule.noResolve;
      _src = parsedRule.src;
      return;
    }
    _ruleAction = _ruleActions.first;
    if (_targetItems.isNotEmpty) {
      _ruleTargetController.text = _targetItems.first;
    }
    if (_ruleProviderItems.isNotEmpty) {
      _ruleProviderController.text = _ruleProviderItems.first;
    }
    if (_subRuleItems.isNotEmpty) {
      _subRuleController.text = _subRuleItems.first;
    }
  }

  @override
  void didUpdateWidget(AddRuleDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rule != widget.rule) {
      _initState();
    }
  }

  @override
  void dispose() {
    _ruleTargetController.dispose();
    _contentController.dispose();
    _ruleProviderController.dispose();
    _subRuleController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final res = _formKey.currentState?.validate();
    if (res == false) {
      return;
    }
    final parsedRule = ParsedRule(
      ruleAction: _ruleAction,
      content: _contentController.text,
      ruleProvider: _ruleProviderController.text,
      ruleTarget: _ruleTargetController.text,
      subRule: _subRuleController.text,
      noResolve: _noResolve,
      src: _src,
    );
    final targetRule = widget.rule;
    final rule = targetRule != null
        ? targetRule.copyWith(value: parsedRule.value)
        : Rule.value(parsedRule.value);
    await context.dismissKeyboard();
    if (!mounted) return;
    Navigator.of(context).pop(rule);
  }

  Future<void> _pick({
    required String title,
    required List<String> options,
    required TextEditingController controller,
  }) async {
    await context.dismissKeyboard();
    if (!mounted) return;
    final selected = await globalState.showAdaptiveSheet<String>(
      child: OptionsDialog<String>(
        title: title,
        options: options,
        textBuilder: (item) => item,
        value: controller.text,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      controller.text = selected;
    });
  }

  Future<void> _pickPackage() async {
    final selected = await showPackagePicker(context);
    if (selected == null || !mounted) return;
    setState(() {
      _contentController.text = selected;
    });
  }

  Future<void> _pickRuleAction() async {
    await context.dismissKeyboard();
    if (!mounted) return;
    final selected = await globalState.showAdaptiveSheet<RuleAction>(
      child: OptionsDialog<RuleAction>(
        title: appLocalizations.ruleName,
        options: _ruleActions,
        textBuilder: (item) => item.value,
        value: _ruleAction,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _ruleAction = selected;
    });
  }

  Widget _buildPicker({
    required String label,
    required List<String> options,
    required TextEditingController controller,
  }) {
    return FormField<String>(
      validator: (_) {
        if (controller.text.isEmpty) {
          return appLocalizations.emptyTip(label);
        }
        return null;
      },
      builder: (field) => _PickerField(
        label: label,
        value: controller.text,
        errorText: field.errorText,
        onTap: () =>
            _pick(title: label, options: options, controller: controller),
      ),
    );
  }

  Widget _buildFlag(String label, bool value, ValueChanged<bool> onChanged) {
    return CommonCard(
      radius: 12,
      isSelected: value,
      onPressed: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(label, style: context.textTheme.bodyMedium),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await context.dismissKeyboard();
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
      child: CommonDialog(
        title: widget.rule != null
            ? appLocalizations.edit
            : appLocalizations.addRule,
        actions: [
          TextButton(
            onPressed: _handleSubmit,
            child: Text(appLocalizations.confirm),
          ),
        ],
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              _PickerField(
                label: appLocalizations.ruleName,
                value: _ruleAction.value,
                onTap: _pickRuleAction,
              ),
              if (_ruleAction == RuleAction.RULE_SET)
                _buildPicker(
                  label: appLocalizations.ruleProviders,
                  options: _ruleProviderItems,
                  controller: _ruleProviderController,
                )
              else if (_ruleAction != RuleAction.MATCH)
                TextFormField(
                  controller: _contentController,
                  maxLines: 1,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: appLocalizations.content,
                    suffixIcon:
                        system.isAndroid &&
                            _ruleAction == RuleAction.PROCESS_NAME
                        ? IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _pickPackage,
                          )
                        : null,
                  ),
                  validator: (_) {
                    if (_contentController.text.isEmpty) {
                      return appLocalizations.emptyTip(appLocalizations.content);
                    }
                    return null;
                  },
                ),
              if (_ruleAction == RuleAction.SUB_RULE)
                _buildPicker(
                  label: appLocalizations.subRule,
                  options: _subRuleItems,
                  controller: _subRuleController,
                )
              else
                _buildPicker(
                  label: appLocalizations.ruleTarget,
                  options: _targetItems,
                  controller: _ruleTargetController,
                ),
              if (_ruleAction.hasParams)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFlag(
                      appLocalizations.sourceIp,
                      _src,
                      (value) => setState(() => _src = value),
                    ),
                    _buildFlag(
                      appLocalizations.noResolve,
                      _noResolve,
                      (value) => setState(() => _noResolve = value),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final String? errorText;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.value,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: InputDecorator(
        isEmpty: value.isEmpty,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
