import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/providers/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:bett_box/views/config/dns.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DnsOverride extends StatelessWidget {
  const DnsOverride({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: CommonCard(
        info: Info(label: 'DNS', iconData: Icons.dns),
        onPressed: () {
          // Open DNS settings
          showExtend(
            context,
            builder: (_, type) {
              return AdaptiveSheetScaffold(
                type: type,
                title: 'DNS',
                actions: dnsActions,
                body: const DnsListView(),
              );
            },
            props: const ExtendProps(blur: false),
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
                  final managed = ref.watch(
                    currentProfileProvider.select(
                      (profile) => profile?.isManaged ?? false,
                    ),
                  );
                  return Switch(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: override && !managed,
                    onChanged: managed
                        ? null
                        : (value) {
                            ref.read(overrideDnsProvider.notifier).value =
                                value;
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
