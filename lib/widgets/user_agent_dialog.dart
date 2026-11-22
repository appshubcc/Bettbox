import 'package:bett_box/common/common.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'dialog.dart';
import 'input.dart';

class _UserAgentChoice {
  final String? value;
  final bool custom;

  const _UserAgentChoice(this.value, {this.custom = false});
}

Future<({String? value})?> pickUserAgent({
  String? current,
  String? customValue,
}) async {
  final choice = await globalState.showAdaptiveSheet<_UserAgentChoice>(
    child: _UserAgentDialog(current: current),
  );
  if (choice == null) return null;
  if (!choice.custom) return (value: choice.value);
  final input = await globalState.showCommonDialog<String>(
    child: InputDialog(
      title: appLocalizations.custom,
      value: customValue ?? current ?? '',
      hintText: 'Clash.Meta',
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return appLocalizations.emptyTip('UA');
        }
        return null;
      },
    ),
  );
  final value = input?.trim();
  if (value == null || value.isEmpty) return null;
  return (value: value);
}

class _UserAgentDialog extends ConsumerWidget {
  final String? current;

  const _UserAgentDialog({required this.current});

  void _pop(BuildContext context, _UserAgentChoice choice) {
    Navigator.of(context, rootNavigator: true).pop(choice);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalUa = ref.watch(
      patchClashConfigProvider.select((state) => state.globalUa),
    );
    final profiles = ref.watch(profilesProvider);
    final history = {
      ?globalUa,
      for (final profile in profiles) ?profile.userAgent,
    };
    return CommonDialog(
      title: 'UA',
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OptionItem(
            text: appLocalizations.defaultText,
            selected: current == null,
            onTap: () => _pop(context, const _UserAgentChoice(null)),
          ),
          for (final value in history)
            OptionItem(
              text: value,
              selected: current == value,
              onTap: () => _pop(context, _UserAgentChoice(value)),
            ),
          OptionItem(
            text: appLocalizations.custom,
            selected: false,
            onTap: () =>
                _pop(context, const _UserAgentChoice(null, custom: true)),
          ),
        ],
      ),
    );
  }
}
