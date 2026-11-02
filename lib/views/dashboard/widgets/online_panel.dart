import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/config/general.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class OnlinePanel extends ConsumerWidget {
  const OnlinePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: CommonCard(
        info: Info(label: appLocalizations.onlinePanel, iconData: Icons.launch),
        onPressed: () async {
          // Get external controller status and secret
          final clashConfig = ref.read(patchClashConfigProvider);
          final externalController = clashConfig.externalController;
          final secret = clashConfig.secret;

          if (externalController != ExternalControllerStatus.open) {
            showSheet(
              context: context,
              props: const SheetProps(expandable: false),
              builder: (_, type) => AdaptiveSheetScaffold(
                title: appLocalizations.externalController,
                type: type,
                body: generateListView(
                  shrinkWrap: true,
                  generateSection(items: const [ExternalControllerItem()]),
                ),
              ),
            );
            return;
          }

          // Pass secret only if external controller is enabled
          if (secret != null && secret.isNotEmpty) {
            // Build URL with secret in fragment
            final uri = Uri.parse(
              'http://127.0.0.1:9090/ui/#/setup?hostname=127.0.0.1&port=9090&secret=$secret',
            );
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          } else {
            // External controller enabled but no secret
            final uri = Uri.parse('http://127.0.0.1:9090/ui/');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
        child: Container(
          padding: baseInfoEdgeInsets.copyWith(top: 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: globalState.measure.bodyMediumHeight + 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      appLocalizations.openDashboard,
                      style: context.textTheme.bodyMedium?.toLight.adjustSize(
                        0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
