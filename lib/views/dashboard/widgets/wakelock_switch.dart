import 'package:bett_box/common/common.dart';
import 'package:bett_box/providers/state.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WakelockSwitch extends StatelessWidget {
  const WakelockSwitch({super.key});

  Future<void> _toggleWakelock(BuildContext context) async {
    try {
      final enabled = await WakelockPlus.enabled;
      if (enabled) {
        await WakelockPlus.disable();
        globalState.appController.stopWakelockAutoRecovery();
      } else {
        await WakelockPlus.enable();
        globalState.appController.startWakelockAutoRecovery();
      }
      globalState.updateWakelockState(!enabled);
    } catch (e) {
      commonPrint.log('WakeLock toggle error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: CommonCard(
        info: Info(label: appLocalizations.wakelock, iconData: ReIcons.lampOn),
        onPressed: () async {
          // click: show function description dialog
          await globalState.showCommonDialog<void>(
            child: CommonDialog(
              title: appLocalizations.wakelock,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(appLocalizations.confirm),
                ),
              ],
              child: Text(appLocalizations.wakelockDescription),
            ),
          );
        },
        child: Container(
          padding: baseInfoEdgeInsets.copyWith(top: 4, bottom: 8, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 1,
                child: TooltipText(
                  text: Text(
                    appLocalizations.switchLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.adjustSize(-2).toLight,
                  ),
                ),
              ),
              Consumer(
                builder: (_, ref, _) {
                  final wakelockEnabled = ref.watch(wakelockStateProvider);
                  return Switch(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: wakelockEnabled,
                    onChanged: (_) => _toggleWakelock(context),
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
