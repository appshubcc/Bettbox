```dart
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogLevelItem extends ConsumerWidget {
  const LogLevelItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final logLevel = ref.watch(
      patchClashConfigProvider.select((state) => state.logLevel),
    );
    return ListItem<LogLevel>.options(
      leading: const Icon(Icons.info_outline),
      title: Text(appLocalizations.logLevel),
      subtitle: Text(logLevel.name),
      delegate: OptionsDelegate<LogLevel>(
        title: appLocalizations.logLevel,
        options: LogLevel.values,
        onChanged: (LogLevel? value) {
          if (value == null) {
            return;
          }
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState((state) => state.copyWith(logLevel: value));
        },
        textBuilder: (logLevel) => logLevel.name,
        value: logLevel,
      ),
    );
  }
}

class UaItem extends ConsumerStatefulWidget {
  const UaItem({super.key});

  @override
  ConsumerState<UaItem> createState() => _UaItemState();
}

class _UaItemState extends ConsumerState<UaItem> {
  String _lastCustomUa = '';

  @override
  Widget build(BuildContext context) {
    final globalUa = ref.watch(
      patchClashConfigProvider.select((state) => state.globalUa),
    );
    final isCustom = globalUa != null;

    if (isCustom) {
      _lastCustomUa = globalUa;
    }

    return ListItem(
      leading: const Icon(Icons.computer_outlined),
      title: const Text('UA'),
      subtitle: Text(isCustom ? appLocalizations.custom : appLocalizations.defaultText),
      onTap: () async {
        final notifier = ref.read(patchClashConfigProvider.notifier);
        final result = await globalState.showCommonDialog<_UaOption>(
          child: _UaDialog(isCustom: isCustom),
        );

        if (result == null) return;

        switch (result.type) {
          case _UaOptionType.default_:
            notifier.updateState((state) => state.copyWith(globalUa: null));
          case _UaOptionType.custom:
            final customUa = await globalState.showCommonDialog<String>(
              child: InputDialog(
                title: appLocalizations.custom,
                value: _lastCustomUa,
                hintText: 'Clash.Meta',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return appLocalizations.emptyTip('UA');
                  }
                  return null;
                },
              ),
            );
            if (customUa != null && customUa.trim().isNotEmpty) {
              notifier.updateState((state) => state.copyWith(globalUa: customUa.trim()));
            }
        }
      },
    );
  }
}

enum _UaOptionType { default_, custom }

class _UaOption {
  final _UaOptionType type;

  const _UaOption(this.type);
}

class _UaDialog extends StatelessWidget {
  final bool isCustom;

  const _UaDialog({required this.isCustom});

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: 'UA',
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Default option
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop(const _UaOption(_UaOptionType.default_));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      !isCustom ? Icons.check_circle_rounded : Icons.circle_outlined,
                      size: 21,
                      color: !isCustom
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      appLocalizations.defaultText,
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Custom option
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop(const _UaOption(_UaOptionType.custom));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      isCustom ? Icons.check_circle_rounded : Icons.circle_outlined,
                      size: 21,
                      color: isCustom
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      appLocalizations.custom,
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KeepAliveIntervalItem extends ConsumerWidget {
  const KeepAliveIntervalItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final keepAliveInterval = ref.watch(
      patchClashConfigProvider.select((state) => state.keepAliveInterval),
    );
    return ListItem.input(
      leading: const Icon(Icons.timer_outlined),
      title: Text(appLocalizations.keepAliveIntervalDesc),
      subtitle: Text('$keepAliveInterval ${appLocalizations.seconds}'),
      delegate: InputDelegate(
        title: appLocalizations.keepAliveIntervalDesc,
        suffixText: appLocalizations.seconds,
        resetValue: '$defaultKeepAliveInterval',
        value: '$keepAliveInterval',
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.interval);
          }
          final intValue = int.tryParse(value);
          if (intValue == null) {
            return appLocalizations.numberTip(appLocalizations.interval);
          }
          return null;
        },
        onChanged: (String? value) {
          if (value == null) {
            return;
          }
          final intValue = int.parse(value);
          ref
              .read(patchClashConfigProvider.notifier)
              .updateState(
                (state) => state.copyWith(keepAliveInterval: intValue),
              );
        },
      ),
    );
  }
}

class TestUrlItem extends ConsumerWidget {
  const TestUrlItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final testUrl = ref.watch(
      appSettingProvider.select((state) => state.testUrl),
    );

    return ListItem(
      leading: const Icon(Icons.timeline),
      title: Text(appLocalizations.testUrl),
      subtitle: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(testUrl),
      ),
      onTap: () async {
        await globalState.showCommonDialog(
          child: _TestUrlDialog(currentUrl: testUrl),
        );
      },
    );
  }
}

class _TestUrlDialog extends ConsumerWidget {
  final String currentUrl;

  const _TestUrlDialog({required this.currentUrl});

  @override
  Widget build(BuildContext context, ref) {
    final overrideTestUrl = ref.watch(overrideTestUrlProvider);
    return CommonDialog(
      title: appLocalizations.testUrl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: TextEditingController(text: currentUrl),
            decoration: InputDecoration(
              hintText: appLocalizations.testUrl,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref.read(appSettingProvider.notifier).updateState(
                    (state) => state.copyWith(testUrl: value),
                  );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(appLocalizations.overrideTestUrl),
              ),
              Switch(
                value: overrideTestUrl,
                onChanged: (bool value) async {
                  ref.read(overrideTestUrlProvider.notifier).value = value;
                  if (value) {
                    await globalState.appController.updateClashConfigDebounce();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```