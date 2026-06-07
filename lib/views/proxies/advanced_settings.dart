import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProxiesAdvancedSettings extends ConsumerWidget {
  const ProxiesAdvancedSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: generateSection(
        items: [
          const _NodeExclusionWithInverseItem(),
          const _ConcurrencyLimitItem(),
          const _HealthCheckTimeoutItem(),
          const _DelayAnimationItem(),
        ],
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

  const _NodeExclusionDialog({
    required this.currentValue,
    this.validator,
  });

  @override
  ConsumerState<_NodeExclusionDialog> createState() => _NodeExclusionDialogState();
}

class _NodeExclusionDialogState extends ConsumerState<_NodeExclusionDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() == false) return;

    final filter = _controller.text.trim();
    // 通过 provider notifier 更新，触发父 Widget 响应式重建
    ref.read(nodeExcludeFilterProvider.notifier).value = filter;
    globalState.appController.applyProfileDebounce();
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
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
    );
  }
}

class _ConcurrencyLimitItem extends ConsumerWidget {
  const _ConcurrencyLimitItem();

  static const _options = [8, 16, 32, 64, 250];

  String _getDisplayText(int value, BuildContext context) {
    if (value == 250) {
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
            ref.read(proxiesStyleSettingProvider.notifier).updateState(
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

  String _getTextForDelayAnimation(DelayAnimationType type) {
    return switch (type) {
      DelayAnimationType.none => appLocalizations.noAnimation,
      DelayAnimationType.rotatingCircle => appLocalizations.rotatingCircle,
      DelayAnimationType.pulse => appLocalizations.pulse,
      DelayAnimationType.spinningLines => appLocalizations.spinningLines,
      DelayAnimationType.threeInOut => appLocalizations.threeInOut,
      DelayAnimationType.threeBounce => appLocalizations.threeBounce,
      DelayAnimationType.circle => appLocalizations.circle,
      DelayAnimationType.fadingCircle => appLocalizations.fadingCircle,
      DelayAnimationType.fadingFour => appLocalizations.fadingFour,
      DelayAnimationType.wave => appLocalizations.wave,
      DelayAnimationType.doubleBounce => appLocalizations.doubleBounce,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delayAnimation = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.delayAnimation),
    );

    return ListItem<DelayAnimationType>.options(
      leading: const Icon(Icons.animation),
      title: Text(appLocalizations.delayAnimation),
      subtitle: Text(appLocalizations.delayAnimationDesc),
      delegate: OptionsDelegate(
        title: appLocalizations.delayAnimation,
        options: DelayAnimationType.values,
        value: delayAnimation,
        textBuilder: (value) => _getTextForDelayAnimation(value),
        onChanged: (value) {
          if (value != null) {
            ref.read(proxiesStyleSettingProvider.notifier).updateState(
                  (state) => state.copyWith(delayAnimation: value),
                );
          }
        },
      ),
    );
  }
}
