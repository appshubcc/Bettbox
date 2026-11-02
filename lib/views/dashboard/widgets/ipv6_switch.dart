import 'package:bett_box/common/common.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Ipv6Switch extends ConsumerWidget {
  const Ipv6Switch({super.key});

  void _update(WidgetRef ref, bool value) {
    ref
        .read(patchClashConfigProvider.notifier)
        .updateState((state) => state.copyWith(ipv6: value));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ipv6 = ref.watch(
      patchClashConfigProvider.select((state) => state.ipv6),
    );
    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: CommonCard(
        info: Info(label: 'IPv6', iconData: Icons.filter_6_rounded),
        onPressed: () => _update(ref, !ipv6),
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
              Switch(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: ipv6,
                onChanged: (value) => _update(ref, value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
