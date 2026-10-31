import 'package:bett_box/common/common.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/config/dns.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DnsOverride extends StatelessWidget {
  const DnsOverride({super.key});

  Future<void> _handleClearCache(BuildContext context) async {
    // Show confirmation dialog
    final result = await globalState.showCommonDialog<bool>(
      child: CommonDialog(
        title: appLocalizations.clearCacheTitle,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(false);
            },
            child: Text(appLocalizations.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(true);
            },
            child: Text(appLocalizations.confirm),
          ),
        ],
        child: Text(appLocalizations.clearCacheDesc),
      ),
    );

    // Clear cache after user confirms
    if (result == true) {
      await globalState.appController.flushDns();
      globalState.showNotifier(appLocalizations.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: CommonCard(
        info: Info(label: 'DNS', iconData: ReIcons.globalSearch),
        onPressed: () {
          // Open DNS settings
          showExtend(
            context,
            builder: (_, type) {
              return AdaptiveSheetScaffold(
                type: type,
                title: 'DNS',
                body: const DnsListView(),
              );
            },
            props: const ExtendProps(blur: false),
          );
        },
        onLongPress: () async {
          // Long press: clear DNS cache
          await _handleClearCache(context);
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
                    appLocalizations.override,
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
                  final override = ref.watch(overrideDnsProvider);
                  return Switch(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: override,
                    onChanged: (value) {
                      ref.read(overrideDnsProvider.notifier).value = value;
                    },
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
