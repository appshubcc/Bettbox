import 'package:bett_box/common/common.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/views/config/network.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showTunSheet(BuildContext context) {
  showSheet(
    context: context,
    props: const SheetProps(expandable: false),
    builder: (_, type) {
      return AdaptiveSheetScaffold(
        type: type,
        body: generateListView(
          shrinkWrap: true,
          generateSection(
            items: [
              if (system.isDesktop) const TUNItem(),
              if (system.isDesktop) const DnsHijackItem(),
              if (!system.isAndroid) const StrictRouteItem(),
              const IcmpForwardingItem(),
              if (!AppIdentity.isLite) const TunStackItem(),
            ],
          ),
        ),
        title: appLocalizations.tun,
      );
    },
  );
}

void showVpnSheet(BuildContext context) {
  showSheet(
    context: context,
    props: const SheetProps(expandable: false),
    builder: (_, type) {
      return AdaptiveSheetScaffold(
        type: type,
        body: generateListView(
          shrinkWrap: true,
          generateSection(
            items: [
              const VPNItem(),
              if (!system.isAndroid) const StrictRouteItem(),
              const IcmpForwardingItem(),
              if (!AppIdentity.isLite) const TunStackItem(),
            ],
          ),
        ),
        title: 'VPN',
      );
    },
  );
}

void showSystemProxySheet(BuildContext context) {
  showSheet(
    context: context,
    props: const SheetProps(expandable: false),
    builder: (_, type) {
      return AdaptiveSheetScaffold(
        type: type,
        body: generateListView(
          shrinkWrap: true,
          generateSection(
            items: [
              system.isAndroid
                  ? const VpnSystemProxyItem()
                  : const SystemProxyItem(),
              const BypassDomainItem(),
            ],
          ),
        ),
        title: appLocalizations.systemProxy,
      );
    },
  );
}

class TUNButton extends StatelessWidget {
  const TUNButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: CommonCard(
        onPressed: () => showTunSheet(context),
        info: Info(
          label: appLocalizations.tun,
          iconData: Icons.stacked_line_chart,
        ),
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
                    appLocalizations.options,
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
                  final enable = ref.watch(
                    patchClashConfigProvider.select(
                      (state) => state.tun.enable,
                    ),
                  );

                  return Switch(
                    value: enable,
                    onChanged: (value) {
                      ref
                          .read(patchClashConfigProvider.notifier)
                          .updateState(
                            (state) => state.copyWith.tun(enable: value),
                          );
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

class SystemProxyButton extends StatelessWidget {
  const SystemProxyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: CommonCard(
        onPressed: () => showSystemProxySheet(context),
        info: Info(
          label: appLocalizations.systemProxy,
          iconData: Icons.shuffle,
        ),
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
                    appLocalizations.options,
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
                  final systemProxy = ref.watch(
                    networkSettingProvider.select((state) => state.systemProxy),
                  );

                  return Switch(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: systemProxy,
                    onChanged: (value) {
                      ref
                          .read(networkSettingProvider.notifier)
                          .updateState(
                            (state) => state.copyWith(systemProxy: value),
                          );
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

class VpnButton extends StatelessWidget {
  const VpnButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: CommonCard(
        onPressed: () => showVpnSheet(context),
        info: Info(label: 'VPN', iconData: Icons.stacked_line_chart),
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
                    appLocalizations.options,
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
                  final enable = ref.watch(
                    vpnSettingProvider.select((state) => state.enable),
                  );
                  return Switch(
                    value: enable,
                    onChanged: (value) {
                      ref
                          .read(vpnSettingProvider.notifier)
                          .updateState(
                            (state) => state.copyWith(enable: value),
                          );
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
