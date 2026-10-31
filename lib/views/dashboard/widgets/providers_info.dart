import 'package:bett_box/common/common.dart';
import 'package:bett_box/views/proxies/providers.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class ProvidersInfo extends StatelessWidget {
  const ProvidersInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: CommonCard(
        info: const Info(iconData: ReIcons.layers, label: 'INFO'),
        onPressed: () {
          showExtend(
            context,
            builder: (_, type) {
              return ProvidersView(type: type);
            },
          );
        },
        child: Container(
          padding: baseInfoEdgeInsets.copyWith(top: 0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              'Rule & Providers',
              style: context.textTheme.bodyMedium?.toLight.adjustSize(0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
