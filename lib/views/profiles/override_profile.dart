import 'dart:async';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

  void _initState(WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 300), () async {
        final rawConfig = await globalState.getProfileConfig(widget.profileId);
        final snippet = ClashConfigSnippet.fromJson(rawConfig);
        final overrideData = ref.read(
          getProfileOverrideDataProvider(widget.profileId),
        );
        final newOverrideData =
            overrideData?.rule.type == OverrideRuleType.override &&
                overrideData?.rule.overrideRules.isEmpty == true
            ? overrideData?.copyWith(
                rule: overrideData.rule.copyWith(overrideRules: snippet.rule),
              )
            : overrideData;
        ref
            .read(profileOverrideStateProvider.notifier)
            .updateState(
              (state) => state.copyWith(
                snippet: snippet,
                overrideData: newOverrideData,
              ),
            );
      });
    });
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
      final overrideRule = state.overrideData!.rule.updateRules(
        (rules) =>
            List.from(rules.where((item) => !selectedRules.contains(item.id))),
      );
      return state.copyWith.overrideData!(rule: overrideRule);
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
          return Center(child: CircularProgressIndicator());
        }
        return FadeBox(
          child: !isInit ? Center(child: CircularProgressIndicator()) : child!,
        );
      },
      child: LayoutBuilder(
        builder: (_, constraints) {
          _currentMaxWidth = constraints.maxWidth - 144;
          return CommonScrollBar(
            controller: _controller,
            child: CustomScrollView(
              controller: _controller,
              // ignore: deprecated_member_use
              cacheExtent: 500,
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverToBoxAdapter(
                  child: Consumer(
                    builder: (_, ref, child) {
                      final scriptMode = ref.watch(
                        scriptStateProvider.select(
                          (state) => state.realId != null,
                        ),
                      );
                      if (!scriptMode) {
                        return SizedBox();
                      }
                      return child!;
                    },
                    child: ListItem(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                      title: Row(
                        spacing: 8,
                        children: [
                          Icon(Icons.info),
                          Text(appLocalizations.overrideInvalidTip),
                        ],
                      ),
                    ),
                  ),
                ),
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
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                  sliver: RuleContent(maxWidth: _currentMaxWidth),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
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
          return child!;
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
                      icon: Icon(Icons.save),
                    ),
                  if (selectCount > 0)
                    IconButton(
                      onPressed: () {
                        _handleDelete(ref);
                      },
                      icon: Icon(Icons.delete),
                    ),
                ],
                editState: AppBarEditState(
                  editCount: selectCount,
                  onExit: () {
                    ref.read(profileOverrideStateProvider.notifier).updateState(
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
            ref
                .read(profileOverrideStateProvider.notifier)
                .updateState(
                  (state) => state.copyWith.overrideData!(enable: value),
                );
          },
        ),
      ),
    );
  }
}

class RuleTitle extends ConsumerWidget {
  final String profileId;

  const RuleTitle({super.key, required this.profileId});

  void _handleChangeType(WidgetRef ref, isOverrideRule) {
    ref
        .read(profileOverrideStateProvider.notifier)
        .updateState(
          (state) => state.copyWith.overrideData!.rule(
            type: isOverrideRule
                ? OverrideRuleType.added
                : OverrideRuleType.override,
          ),
        );
  }

  @override
  Widget build(BuildContext context, ref) {
    final vm3 = ref.watch(
      profileOverrideStateProvider.select((state) {
        final overrideRule = state.overrideData?.rule;
        return VM3(
          a: state.selectedRules.isNotEmpty,
          b: state.selectedRules.containsAll(
            overrideRule?.rules.map((item) => item.id).toSet() ?? {},
          ),
          c: overrideRule?.type == OverrideRuleType.override,
        );
      }),
    );
    final isSelectMode = vm3.a;
    final isSelectAll = vm3.b;
    final isOverrideRule = vm3.c;
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
          subTitle: isOverrideRule
              ? appLocalizations.overrideOriginRules
              : appLocalizations.addedOriginRules,
          space: 8,
          actions: [
            if (!isSelectMode)
              IconButton.filledTonal(
                icon: Icon(
                  isOverrideRule ? Icons.edit_document : Icons.note_add,
                ),
                onPressed: () {
                  _handleChangeType(ref, isOverrideRule);
                },
              ),
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

/// 规则行。行内布局与全部拖拽交互都归它管，两种起拖方式的作用范围刻意不同：
///
///  - **长按起拖**（[isSelectMode] 为真时）：整张卡都是长按目标。长按本身已是
///    一次明确承诺，目标做大没有副作用，触屏因此不必瞄准小图标。
///  - **鼠标直接拖拽**：只认左侧 drag_indicator 图标那 20px，不做放大。普通模式
///    下把手只随悬停浮现，触屏看不到；触屏起拖本来就是整卡长按，也不必瞄准小图标。
///    鼠标下把手可见可瞄，同样无需放大。
///
/// 图标与 trailing 的复选框同一套显现规则：[isSelectMode] 或本行悬停为真即显示
/// ——多选模式本来就能拖，把手常驻是模式的一部分；悬停只由鼠标类指针产生
/// （[MouseRegion] 对触屏不派发事件）。两个槽位恒占位，出现/消失不挤动正文；
/// 悬停反馈用 [InkResponse]、半径 20，与 Checkbox 的径向光晕同规格。
///
/// 图标层比外层深，先收到落在图标上的 pointer down；靠 [_iconDragPointer] 让
/// 外层跳过已认领的指针，避免一次按下向列表注册两个识别器。图标单击派发
/// [onPressed]，与卡片同一动作。
///
/// 多选模式下长按起拖没有竞技对手：使用方须把卡片的 onLongPress 置空——保证来自
/// 对手缺席，不来自注册顺序。
class RuleRow extends StatefulWidget {
  const RuleRow({
    super.key,
    required this.index,
    required this.iconColor,
    required this.isSelectMode,
    required this.isSelected,
    required this.onPressed,
    required this.onToggleSelect,
    required this.title,
    required this.titleTextStyle,
  });

  final int index;
  final Color iconColor;

  /// 长按起拖只在这个模式下启用；普通模式的长按归卡片（进多选）。
  final bool isSelectMode;

  final bool isSelected;

  /// 图标单击，与卡片同一动作（普通=编辑，多选=切换选中）。
  final VoidCallback onPressed;

  final VoidCallback onToggleSelect;

  final Widget title;
  final TextStyle? titleTextStyle;

  @override
  State<RuleRow> createState() => _RuleRowState();
}

class _RuleRowState extends State<RuleRow> {
  /// 与 DelayedMultiDragGestureRecognizer.delay 保持一致，两者同刻超时。
  static const _longPressDelay = kLongPressTimeout;

  Timer? _hapticTimer;
  Offset? _pressOrigin;

  /// 放弃阈值取本次按下的 hit slop，与长按识别器对齐。
  double _slop = kTouchSlop;

  /// 被图标认领的指针 id，外层据此跳过，避免重复注册识别器。
  int? _iconDragPointer;

  /// 本行悬停态。行内元素共享它，所以留在行内而不是提到列表的父状态：悬停一行
  /// 只重建这一行。重排会重建行的 State，悬停态因此是重新推导而非迁移。
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

  /// 超过 slop 即与长按识别器同步放弃，避免想滚动列表却被震一下。
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

  @override
  Widget build(BuildContext context) {
    final showHandle = widget.isSelectMode || _hovered;
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
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _handleCardPointerDown,
        onPointerMove: _handlePointerMove,
        onPointerUp: _handlePointerEnd,
        onPointerCancel: _handlePointerEnd,
        child: ListTile(
          minTileHeight: 0,
          minVerticalPadding: 0,
          titleTextStyle: widget.titleTextStyle,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          leading: SizedBox(
            width: 20,
            height: 20,
            child: showHandle
                ? Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: _handleIconPointerDown,
                    child: InkResponse(
                      onTap: widget.onPressed,
                      mouseCursor: SystemMouseCursors.move,
                      radius: 20,
                      child: Icon(
                        Icons.drag_indicator,
                        size: 20,
                        color: widget.iconColor,
                      ),
                    ),
                  )
                : null,
          ),
          title: widget.title,
          // GestureDetector 吞掉这一格的 tap：既不落到卡片上，也不显示编辑动作
          trailing: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: SizedBox(
              width: 24,
              height: 24,
              child: showHandle
                  ? CommonCheckBox(
                      value: widget.isSelected,
                      isCircle: true,
                      onChanged: (_) => widget.onToggleSelect(),
                    )
                  : null,
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

  Widget _buildItem({
    Key? key,
    required Rule rule,
    required int index,
    required bool isSelected,
    required bool isSelectMode,
    required VoidCallback onEdit,
    required VoidCallback onTab,
    required BuildContext context,
  }) {
    // 卡片与拖拽图标共用同一单击动作；图标经 InkResponse 显式派发，
    // 与点卡片正文效果一致
    void handleTap() {
      if (isSelectMode) {
        onTab();
      } else {
        onEdit();
      }
    }

    return Material(
      key: key,
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: CommonCard(
          padding: EdgeInsets.zero,
          radius: 18,
          type: CommonCardType.filled,
          isSelected: isSelected,
          onPressed: handleTap,
          // 多选模式置空，让位给行内的长按起拖（契约见 RuleRow）；普通模式长按
          // = 选中本条进入多选
          onLongPress: isSelectMode ? null : onTab,
          child: RuleRow(
            index: index,
            iconColor: context.colorScheme.outline,
            isSelectMode: isSelectMode,
            isSelected: isSelected,
            onPressed: handleTap,
            onToggleSelect: onTab,
            titleTextStyle: context.textTheme.bodyMedium?.toJetBrainsMono,
            title: EmojiText(rule.value),
          ),
        ),
      ),
    );
  }

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
    final vm3 = ref.watch(
      profileOverrideStateProvider.select((state) {
        final overrideRule = state.overrideData?.rule;
        return VM3(
          a: overrideRule?.rules ?? [],
          b: overrideRule?.type ?? OverrideRuleType.added,
          c: state.selectedRules,
        );
      }),
    );
    final rules = vm3.a;
    final type = vm3.b;
    final selectedRules = vm3.c;
    final isSelectMode = selectedRules.isNotEmpty;
    if (rules.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(
            child: type == OverrideRuleType.added
                ? Text(appLocalizations.noData)
                : FilledButton(
                    onPressed: () {
                      final rules = ref.read(
                        profileOverrideStateProvider.select(
                          (state) => state.snippet?.rule ?? [],
                        ),
                      );
                      ref
                          .read(profileOverrideStateProvider.notifier)
                          .updateState((state) {
                            return state.copyWith.overrideData!.rule(
                              overrideRules: rules,
                            );
                          });
                    },
                    child: Text(appLocalizations.getOriginRules),
                  ),
          ),
        ),
      );
    }
    return CacheItemExtentSliverReorderableList(
      tag: CacheTag.rules,
      itemBuilder: (context, index) {
        final rule = rules[index];
        return _buildItem(
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
          context: context,
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
        ref
            .read(profileOverrideStateProvider.notifier)
            .updateState(
              (state) => state.copyWith.overrideData!(
                rule: state.overrideData!.rule.updateRules((_) => newRules),
              ),
            );
      },
      keyBuilder: (int index) {
        return rules[index].value;
      },
      itemExtentBuilder: (index) {
        final rule = rules[index];
        return 40 +
            globalState.measure
                .computeTextSize(
                  Text(
                    rule.value,
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
  final _ruleTargetController = TextEditingController();
  final _contentController = TextEditingController();
  final _ruleProviderController = TextEditingController();
  final _subRuleController = TextEditingController();
  bool _noResolve = false;
  bool _src = false;
  List<DropdownMenuEntry<String>> _targetItems = [];
  List<DropdownMenuEntry<String>> _ruleProviderItems = [];
  List<DropdownMenuEntry<String>> _subRuleItems = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _initState();
    super.initState();
  }

  void _initState() {
    _targetItems = [
      ...widget.snippet.proxyGroups.map(
        (item) => DropdownMenuEntry<String>(value: item.name, label: item.name),
      ),
      ...RuleTarget.values.map(
        (item) => DropdownMenuEntry<String>(value: item.name, label: item.name),
      ),
    ];
    _ruleProviderItems = [
      ...widget.snippet.ruleProvider.map(
        (item) => DropdownMenuEntry<String>(value: item.name, label: item.name),
      ),
    ];
    _subRuleItems = [
      ...widget.snippet.subRules.map(
        (item) => DropdownMenuEntry<String>(value: item.name, label: item.name),
      ),
    ];
    if (widget.rule != null) {
      final parsedRule = ParsedRule.parseString(widget.rule!.value);
      _ruleAction = parsedRule.ruleAction;
      _contentController.text = parsedRule.content ?? '';
      _ruleTargetController.text = parsedRule.ruleTarget ?? '';
      _ruleProviderController.text = parsedRule.ruleProvider ?? '';
      _subRuleController.text = parsedRule.subRule ?? '';
      _noResolve = parsedRule.noResolve;
      _src = parsedRule.src;
      return;
    }
    _ruleAction = RuleAction.values.first;
    if (_targetItems.isNotEmpty) {
      _ruleTargetController.text = _targetItems.first.value;
    }
    if (_ruleProviderItems.isNotEmpty) {
      _ruleProviderController.text = _ruleProviderItems.first.value;
    }
    if (_subRuleItems.isNotEmpty) {
      _subRuleController.text = _subRuleItems.first.value;
    }
  }

  @override
  void didUpdateWidget(AddRuleDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rule != widget.rule) {
      _initState();
    }
  }

  void _handleSubmit() {
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
    final rule = widget.rule != null
        ? widget.rule!.copyWith(value: parsedRule.value)
        : Rule.value(parsedRule.value);
    Navigator.of(context).pop(rule);
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.addRule,
      actions: [
        TextButton(
          onPressed: _handleSubmit,
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: DropdownMenuTheme(
        data: DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(),
            labelStyle: context.textTheme.bodyLarge?.copyWith(
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (_, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton.tonal(
                    onPressed: () async {
                      _ruleAction =
                          await globalState.showCommonDialog<RuleAction>(
                            child: OptionsDialog<RuleAction>(
                              title: appLocalizations.ruleName,
                              options: RuleAction.values,
                              textBuilder: (item) => item.value,
                              value: _ruleAction,
                            ),
                          ) ??
                          _ruleAction;
                      setState(() {});
                    },
                    child: Text(_ruleAction.name),
                  ),
                  SizedBox(height: 24),
                  _ruleAction == RuleAction.RULE_SET
                      ? FormField(
                          validator: (_) {
                            if (_ruleProviderController.text.isEmpty) {
                              return appLocalizations.emptyTip(
                                appLocalizations.ruleProviders,
                              );
                            }
                            return null;
                          },
                          builder: (field) {
                            if (globalState.isAndroidTV) {
                              return OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                onPressed: () async {
                                  final selected = await globalState
                                      .showCommonDialog<String>(
                                        child: OptionsDialog<String>(
                                          title: appLocalizations.ruleProviders,
                                          options: _ruleProviderItems
                                              .map((e) => e.value)
                                              .toList(),
                                          textBuilder: (item) => item,
                                          value: _ruleProviderController.text,
                                        ),
                                      );
                                  if (selected != null) {
                                    setState(() {
                                      _ruleProviderController.text = selected;
                                    });
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _ruleProviderController.text.isEmpty
                                          ? appLocalizations.ruleProviders
                                          : _ruleProviderController.text,
                                      style: context.textTheme.bodyLarge,
                                    ),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              );
                            }
                            return DropdownMenu<String>(
                              expandedInsets: EdgeInsets.zero,
                              controller: _ruleProviderController,
                              label: Text(appLocalizations.ruleProviders),
                              menuHeight: 250,
                              errorText: field.errorText,
                              dropdownMenuEntries: _ruleProviderItems,
                            );
                          },
                        )
                      : TextFormField(
                          controller: _contentController,
                          enabled: _ruleAction != RuleAction.MATCH,
                          maxLines: 1,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: appLocalizations.content,
                          ),
                          validator: (_) {
                            if (_ruleAction == RuleAction.MATCH) {
                              return null;
                            }
                            if (_contentController.text.isEmpty) {
                              return appLocalizations.emptyTip(
                                appLocalizations.content,
                              );
                            }
                            return null;
                          },
                        ),
                  SizedBox(height: 24),
                  _ruleAction == RuleAction.SUB_RULE
                      ? FormField(
                          validator: (_) {
                            if (_subRuleController.text.isEmpty) {
                              return appLocalizations.emptyTip(
                                appLocalizations.subRule,
                              );
                            }
                            return null;
                          },
                          builder: (filed) {
                            if (globalState.isAndroidTV) {
                              return OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                onPressed: () async {
                                  final selected = await globalState
                                      .showCommonDialog<String>(
                                        child: OptionsDialog<String>(
                                          title: appLocalizations.subRule,
                                          options: _subRuleItems
                                              .map((e) => e.value)
                                              .toList(),
                                          textBuilder: (item) => item,
                                          value: _subRuleController.text,
                                        ),
                                      );
                                  if (selected != null) {
                                    setState(() {
                                      _subRuleController.text = selected;
                                    });
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _subRuleController.text.isEmpty
                                          ? appLocalizations.subRule
                                          : _subRuleController.text,
                                      style: context.textTheme.bodyLarge,
                                    ),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              );
                            }
                            return DropdownMenu<String>(
                              width: 200,
                              enableFilter: false,
                              enableSearch: false,
                              controller: _subRuleController,
                              label: Text(appLocalizations.subRule),
                              menuHeight: 250,
                              dropdownMenuEntries: _subRuleItems,
                            );
                          },
                        )
                      : FormField<String>(
                          validator: (_) {
                            if (_ruleTargetController.text.isEmpty) {
                              return appLocalizations.emptyTip(
                                appLocalizations.ruleTarget,
                              );
                            }
                            return null;
                          },
                          builder: (filed) {
                            if (globalState.isAndroidTV) {
                              return OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                onPressed: () async {
                                  final selected = await globalState
                                      .showCommonDialog<String>(
                                        child: OptionsDialog<String>(
                                          title: appLocalizations.ruleTarget,
                                          options: _targetItems
                                              .map((e) => e.value)
                                              .toList(),
                                          textBuilder: (item) => item,
                                          value: _ruleTargetController.text,
                                        ),
                                      );
                                  if (selected != null) {
                                    setState(() {
                                      _ruleTargetController.text = selected;
                                    });
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _ruleTargetController.text.isEmpty
                                          ? appLocalizations.ruleTarget
                                          : _ruleTargetController.text,
                                      style: context.textTheme.bodyLarge,
                                    ),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              );
                            }
                            return DropdownMenu<String>(
                              controller: _ruleTargetController,
                              label: Text(appLocalizations.ruleTarget),
                              width: 200,
                              menuHeight: 250,
                              enableFilter: false,
                              enableSearch: false,
                              dropdownMenuEntries: _targetItems,
                              errorText: filed.errorText,
                            );
                          },
                        ),
                  if (_ruleAction.hasParams) ...[
                    SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      children: [
                        CommonCard(
                          radius: 8,
                          isSelected: _src,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Text(
                              appLocalizations.sourceIp,
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _src = !_src;
                            });
                          },
                        ),
                        CommonCard(
                          radius: 8,
                          isSelected: _noResolve,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Text(
                              appLocalizations.noResolve,
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _noResolve = !_noResolve;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
