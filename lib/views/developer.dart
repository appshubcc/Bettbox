import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/common.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeveloperView extends ConsumerWidget {
  const DeveloperView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final enable = ref.watch(
      appSettingProvider.select((state) => state.developerMode),
    );
    final items = [
      ListItem.switchItem(
        title: Text(appLocalizations.developerMode),
        delegate: SwitchDelegate(
          value: enable,
          onChanged: (value) {
            ref
                .read(appSettingProvider.notifier)
                .updateState(
                  (state) => state.copyWith(developerMode: value),
                );
          },
        ),
      ),
      ...generateSection(
        title: appLocalizations.options,
        separated: false,
        items: [
          ListItem(
            title: Text(appLocalizations.messageTest),
            onTap: () {
              context.showNotifier(appLocalizations.messageTestTip);
            },
          ),
          ListItem(
            title: Text(appLocalizations.logsTest),
            onTap: () {
              for (int i = 0; i < 100; i++) {
                globalState.appController.addLog(
                  Log.app(
                    '[$i]${utils.generateRandomString(maxLength: 200, minLength: 20)}',
                  ),
                );
              }
            },
          ),
          ListItem(
            title: Text(appLocalizations.clearData),
            onTap: () async {
              final res = await globalState.showMessage(
                title: appLocalizations.clearDataTipTitle,
                message: TextSpan(
                  text: appLocalizations.clearDataTipDesc,
                ),
              );
              if (res != true) return;
              await globalState.appController.handleClear();
            },
          ),
        ],
      ),
    ];
    return generateListView(items);
  }
}
