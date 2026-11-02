import 'package:bett_box/common/common.dart';
import 'package:bett_box/views/resources.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class ProvidersInfo extends StatelessWidget {
  const ProvidersInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: CommonCard(
        info: const Info(iconData: Icons.poll_outlined, label: 'INFO'),
        onPressed: () {
          showExtend(
            context,
            props: const ExtendProps(forceFull: true),
            builder: (_, _) => const ResourcesView(),
          );
        },
        child: Container(
          padding: baseInfoEdgeInsets.copyWith(top: 0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              'Geo & Providers',
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
