import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/icon_sets.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProxiesAdvancedSettings extends ConsumerWidget {
  const ProxiesAdvancedSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScrollEdgeRise(
      builder: (_, rise) => ListView(
        padding: EdgeInsets.only(top: 8 + rise, bottom: 20),
        children: generateSection(
          items: [
            const _NodeExclusionWithInverseItem(),
            const _ConcurrencyLimitItem(),
            const _HealthCheckTimeoutItem(),
            const _DelayAnimationItem(),
            const _IconConfigItem(),
          ],
        ),
      ),
    );
  }
}

class _NodeExclusionWithInverseItem extends ConsumerWidget {
  const _NodeExclusionWithInverseItem();

  String? _validateRegex(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      RegExp(value.trim());
      return null;
    } catch (e) {
      final detail = e is FormatException && e.message.isNotEmpty
          ? e.message
          : null;
      return detail != null
          ? '${appLocalizations.formatError}: $detail'
          : appLocalizations.formatError;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 通过响应式 provider 监听，对话框确认后立即重建
    final nodeExcludeFilter = ref.watch(nodeExcludeFilterProvider);

    return ListItem(
      leading: const Icon(Icons.filter_alt_outlined),
      title: Text(appLocalizations.nodeExclusion),
      subtitle: Text(appLocalizations.nodeExclusionDesc),
      onTap: () async {
        await context.dismissKeyboard();
        if (!context.mounted) return;
        await globalState.showCommonDialog(
          child: _NodeExclusionDialog(
            currentValue: nodeExcludeFilter,
            validator: _validateRegex,
          ),
        );
      },
    );
  }
}

class _NodeExclusionDialog extends ConsumerStatefulWidget {
  final String currentValue;
  final String? Function(String?)? validator;

  const _NodeExclusionDialog({required this.currentValue, this.validator});

  @override
  ConsumerState<_NodeExclusionDialog> createState() =>
      _NodeExclusionDialogState();
}

class _NodeExclusionDialogState extends ConsumerState<_NodeExclusionDialog>
    with IdleAutofocusMixin {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  bool get autofocusWhenIdle => true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() == false) return;

    final filter = _controller.text.trim();
    ref.read(nodeExcludeFilterProvider.notifier).value = filter;
    globalState.appController.applyProfileDebounce();
    await context.dismissKeyboard();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await context.dismissKeyboard();
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
      },
      child: CommonDialog(
        title: appLocalizations.nodeExclusion,
        actions: [
          TextButton(
            onPressed: _handleSubmit,
            child: Text(appLocalizations.submit),
          ),
        ],
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                focusNode: autofocusNode,
                controller: _controller,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: appLocalizations.nodeExclusion,
                  hintText: appLocalizations.nodeExclusionPlaceholder,
                ),
                validator: widget.validator,
                onFieldSubmitted: (_) => _handleSubmit(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConcurrencyLimitItem extends ConsumerWidget {
  const _ConcurrencyLimitItem();

  static const _options = [2, 8, 16, 32, maxDelayTestConcurrency];

  String _getDisplayText(int value, BuildContext context) {
    if (value == maxDelayTestConcurrency) {
      return 'MAX';
    }
    return '$value';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final concurrencyLimit = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.concurrencyLimit),
    );

    return ListItem<int>.options(
      leading: const Icon(Icons.speed),
      title: Text(appLocalizations.concurrencyLimit),
      subtitle: Text(appLocalizations.concurrencyLimitDesc),
      delegate: OptionsDelegate(
        title: appLocalizations.concurrencyLimit,
        options: _options,
        value: concurrencyLimit,
        textBuilder: (value) => _getDisplayText(value, context),
        onChanged: (value) {
          if (value != null) {
            ref
                .read(proxiesStyleSettingProvider.notifier)
                .updateState(
                  (state) => state.copyWith(concurrencyLimit: value),
                );
          }
        },
      ),
    );
  }
}

class _HealthCheckTimeoutItem extends ConsumerWidget {
  const _HealthCheckTimeoutItem();

  static const _options = [1000, 2000, 3000, 5000, 8000];

  String _getDisplayText(int value) {
    return '${value ~/ 1000}s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeout = ref.watch(healthCheckTimeoutProvider);

    return ListItem<int>.options(
      leading: const Icon(Icons.timer_outlined),
      title: Text(appLocalizations.healthCheckTimeout),
      subtitle: Text(appLocalizations.healthCheckTimeoutDesc),
      delegate: OptionsDelegate(
        title: appLocalizations.healthCheckTimeout,
        options: _options,
        value: timeout,
        textBuilder: _getDisplayText,
        onChanged: (value) {
          if (value != null) {
            ref
                .read(healthCheckTimeoutProvider.notifier)
                .updateState((_) => value);
            globalState.appController.applyProfileDebounce();
          }
        },
      ),
    );
  }
}

class _DelayAnimationItem extends ConsumerWidget {
  const _DelayAnimationItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (delayAnimation, syncDelayAnimation) = ref.watch(
      proxiesStyleSettingProvider.select(
        (state) => (state.delayAnimation, state.syncDelayAnimation),
      ),
    );

    return ListItem(
      leading: const Icon(Icons.animation),
      title: Text(appLocalizations.delayAnimation),
      subtitle: Text(appLocalizations.delayAnimationDesc),
      onTap: () async {
        final value = await globalState
            .showCommonDialog<(DelayAnimationType, bool)>(
              child: DelayAnimationPickerDialog(
                title: appLocalizations.delayAnimation,
                initialValue: delayAnimation,
                initialSync: syncDelayAnimation,
              ),
            );
        if (value == null) return;
        ref
            .read(proxiesStyleSettingProvider.notifier)
            .updateState(
              (state) => state.copyWith(
                delayAnimation: value.$1,
                syncDelayAnimation: value.$2,
              ),
            );
      },
    );
  }
}

class _IconConfigItem extends StatelessWidget {
  const _IconConfigItem();

  Future<void> _handleResetIconCache() async {
    final res = await globalState.showMessage(
      title: appLocalizations.resetIconCache,
      message: TextSpan(text: appLocalizations.resetIconCacheDesc),
    );
    if (res != true) return;
    await globalState.appController.safeRun(() async {
      await CommonTargetIcon.clearCache();
      globalState.showNotifier(appLocalizations.success);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListItem(
      leading: const Icon(Icons.style_outlined),
      title: Text(appLocalizations.iconConfiguration),
      subtitle: Text(appLocalizations.iconConfigurationDesc),
      onTap: () {
        showExtend(
          context,
          builder: (_, type) {
            return AdaptiveSheetScaffold(
              type: type,
              body: const _IconConfigView(),
              title: appLocalizations.iconConfiguration,
              actions: [
                IconButton(
                  onPressed: () => showIconSets(context),
                  tooltip: appLocalizations.iconSets,
                  icon: const Icon(Icons.collections_outlined),
                ),
                IconButton(
                  onPressed: _handleResetIconCache,
                  tooltip: appLocalizations.resetIconCache,
                  icon: const Icon(Icons.cleaning_services_outlined),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _IconConfigView extends ConsumerWidget {
  const _IconConfigView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconMap = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.iconMap),
    );
    return MapInputPage(
      title: appLocalizations.iconConfiguration,
      map: iconMap,
      keyLabel: appLocalizations.regExp,
      valueLabel: appLocalizations.icon,
      titleBuilder: (item) => EmojiText(item.key),
      leadingBuilder: (item) => Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: CommonTargetIcon(src: item.value, size: 42),
      ),
      subtitleBuilder: (item) => Text(
        iconFileStem(item.value),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      editor: (item) => showSheet<MapEntry<String, String>>(
        context: context,
        props: const SheetProps(expandable: false, initialFraction: 0.86),
        builder: (_, type) =>
            _IconRuleSheet(type: type, item: item, keys: iconMap.keys.toSet()),
      ),
      onChange: (value) {
        ref
            .read(proxiesStyleSettingProvider.notifier)
            .updateState((state) => state.copyWith(iconMap: value));
      },
    );
  }
}

class _IconRuleSheet extends StatefulWidget {
  final SheetType type;
  final MapEntry<String, String>? item;
  final Set<String> keys;

  const _IconRuleSheet({
    required this.type,
    required this.item,
    required this.keys,
  });

  @override
  State<_IconRuleSheet> createState() => _IconRuleSheetState();
}

class _IconRuleSheetState extends State<_IconRuleSheet>
    with IdleAutofocusMixin {
  late final _controller = TextEditingController(text: widget.item?.key);
  late String _icon = widget.item?.value ?? '';

  @override
  bool get autofocusWhenIdle => widget.item == null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? get _error {
    final text = _controller.text;
    if (text.isEmpty) return null;
    if (text != widget.item?.key && widget.keys.contains(text)) {
      return appLocalizations.existsTip(appLocalizations.regExp);
    }
    try {
      RegExp(text);
    } catch (_) {
      return appLocalizations.formatError;
    }
    return null;
  }

  Future<void> _handleConfirm() async {
    await context.dismissKeyboard();
    if (!mounted) return;
    Navigator.of(context).pop(MapEntry(_controller.text, _icon));
  }

  Future<void> _handleCancel() async {
    await context.dismissKeyboard();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    final valid =
        _controller.text.isNotEmpty && error == null && _icon.isNotEmpty;
    final colorScheme = context.colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleCancel();
      },
      child: AdaptiveSheetScaffold(
        type: widget.type,
        title: appLocalizations.iconConfiguration,
        actions: [
          const IconSetsButton(),
          IconButton(
            tooltip: appLocalizations.confirm,
            onPressed: valid ? _handleConfirm : null,
            icon: const Icon(Icons.check),
          ),
        ],
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _icon.isEmpty
                        ? Icon(
                            Icons.image_outlined,
                            color: colorScheme.onSurfaceVariant,
                          )
                        : CommonTargetIcon(
                            key: ValueKey(_icon),
                            src: _icon,
                            size: 36,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      focusNode: autofocusNode,
                      controller: _controller,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: appLocalizations.regExp,
                        hintText: 'YouTube|Netflix',
                        errorText: error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IconPickerBody(
                selected: _icon.isEmpty ? null : _icon,
                suggest: _controller.text,
                onSelect: (value) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() => _icon = value ?? '');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
