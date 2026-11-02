import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'tile.dart';

class NetworkDetection extends ConsumerStatefulWidget {
  final DashboardTileSize? size;

  const NetworkDetection({super.key, this.size});

  @override
  ConsumerState<NetworkDetection> createState() => _NetworkDetectionState();
}

class _NetworkDetectionState extends ConsumerState<NetworkDetection> {
  String _countryCodeToEmoji(String countryCode) {
    final String code = countryCode.toUpperCase();
    if (code.length != 2) {
      return countryCode;
    }
    final int firstLetter = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  Widget _buildSettingsButton(BuildContext context) {
    final ipRiskAlert = ref.watch(
      appSettingProvider.select((state) => state.ipRiskAlert),
    );
    return CommonPopupBox(
      targetBuilder: (open) => IconButton(
        padding: EdgeInsets.zero,
        onPressed: () => open(offset: const Offset(0, 20)),
        icon: Icon(
          size: 16.ap,
          Icons.settings_outlined,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      popup: CommonPopupMenu(
        items: [
          PopupMenuItemData(
            icon: Icons.sync,
            label: appLocalizations.manualRefreshIp,
            onPressed: detectionState.manualRefresh,
          ),
          PopupMenuItemData(
            icon: detectionState.isIpMasked
                ? Icons.check_circle_rounded
                : Icons.security,
            label: appLocalizations.ipPrivacyProtection,
            onPressed: detectionState.toggleIpPrivacy,
          ),
          PopupMenuItemData(
            icon: ipRiskAlert
                ? Icons.check_circle_rounded
                : Icons.circle_outlined,
            label: appLocalizations.ipRiskAlert,
            onPressed: () {
              ref
                  .read(appSettingProvider.notifier)
                  .updateState(
                    (state) => state.copyWith(ipRiskAlert: !ipRiskAlert),
                  );
              detectionState.refreshRiskCheck();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRiskMark(BuildContext context, Widget child) {
    return ValueListenableBuilder<String?>(
      valueListenable: detectionState.riskyIp,
      builder: (_, ip, child) {
        final ipText = child ?? const SizedBox();
        if (ip == null || ip != detectionState.rawIpInfo?.ip) return ipText;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_rounded,
              size: 14,
              color: context.colorScheme.error,
            ),
            const SizedBox(width: 4),
            Flexible(child: ipText),
          ],
        );
      },
      child: child,
    );
  }

  void _showMoreIpInfoDialog() {
    final rawIpInfo = detectionState.rawIpInfo;
    if (rawIpInfo == null) return;
    showIpDetailDialog(
      context,
      rawIpInfo.ip,
      preloaded: rawIpInfo,
      showRisk: detectionState.riskyIp.value == rawIpInfo.ip,
    );
  }

  Widget _buildHeader(BuildContext context, IpInfo? ipInfo) {
    return Container(
      height: globalState.measure.titleMediumHeight + 16,
      padding: baseInfoEdgeInsets.copyWith(bottom: 0),
      child: Row(
        children: [
          ipInfo != null
              ? Text(
                  _countryCodeToEmoji(ipInfo.countryCode),
                  style: Theme.of(context).textTheme.titleMedium?.toLight
                      .copyWith(
                        fontFamily: FontFamily.twEmoji.value,
                        fontFamilyFallback: [FontFamily.twEmoji.value],
                      ),
                )
              : Icon(
                  Icons.network_check,
                  color: context.colorScheme.onSurfaceVariant,
                ),
          const SizedBox(width: 8),
          Flexible(
            child: TooltipText(
              text: Text(
                appLocalizations.networkDetection,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          AspectRatio(aspectRatio: 1, child: _buildSettingsButton(context)),
        ],
      ),
    );
  }

  Widget _buildDetail(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.toLight,
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, DashboardTileSize size) {
    final isTall = size == DashboardTileSize.tall;
    return SizedBox(
      height: getWidgetHeight(context, size.rows),
      child: ValueListenableBuilder<NetworkDetectionState>(
        valueListenable: detectionState.state,
        builder: (_, state, _) {
          final ipInfo = state.ipInfo;
          final masked = detectionState.isIpMasked;
          final location = ipInfo == null
              ? ''
              : [
                  ipInfo.country,
                  if (ipInfo.city != ipInfo.country) ipInfo.city,
                ].where((item) => item?.isNotEmpty ?? false).join(' · ');
          final operator = ipInfo == null
              ? ''
              : [
                  ipInfo.asn,
                  ipInfo.asName ?? ipInfo.isp,
                ].where((item) => item?.isNotEmpty ?? false).join(' ');
          final countryCode = ipInfo?.countryCode ?? '';
          final ipText = ipInfo != null
              ? _buildRiskMark(
                  context,
                  Text(
                    ipInfo.ip,
                    style: context.textTheme.bodyMedium?.toLight.adjustSize(1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : state.isLoading == false
              ? Text(
                  state.errorMessage ?? 'timeout',
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: Colors.red)
                      .adjustSize(1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 1,
                  child: SpinKitThreeBounce(
                    color: context.colorScheme.primary,
                    size: 16,
                  ),
                );
          return CommonCard(
            onPressed: ipInfo != null ? _showMoreIpInfoDialog : null,
            child: DashboardDecor(
              mark: countryCode.length == 2
                  ? DashboardDecor.flag(countryCode, 80)
                  : DashboardDecor.icon(context, Icons.public, 80),
              angle: isTall ? 0.18 : -0.18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: isTall
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.spaceBetween,
                children: [
                  _buildHeader(context, ipInfo),
                  if (isTall)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 12, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: globalState.measure.bodyMediumHeight + 2,
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: ipText,
                            ),
                          ),
                          if (!masked && location.isNotEmpty)
                            _buildDetail(
                              context,
                              appLocalizations.countryOrRegion,
                              location,
                            ),
                          if (!masked && operator.isNotEmpty)
                            _buildDetail(
                              context,
                              appLocalizations.operatorOrAsn,
                              operator,
                            ),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: baseInfoEdgeInsets.copyWith(top: 0),
                      child: SizedBox(
                        height: globalState.measure.bodyMediumHeight + 2,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(child: ipText),
                            if (!masked && ipInfo != null) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  [location, operator]
                                      .where((item) => item.isNotEmpty)
                                      .join(' · '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.size case final size?) return _buildTile(context, size);
    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: ValueListenableBuilder<NetworkDetectionState>(
        valueListenable: detectionState.state,
        builder: (_, state, _) {
          final ipInfo = state.ipInfo;
          final isLoading = state.isLoading;
          return CommonCard(
            onPressed: ipInfo != null ? _showMoreIpInfoDialog : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: globalState.measure.titleMediumHeight + 16,
                  padding: baseInfoEdgeInsets.copyWith(bottom: 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ipInfo != null
                          ? Text(
                              _countryCodeToEmoji(ipInfo.countryCode),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.toLight
                                  .copyWith(
                                    fontFamily: FontFamily.twEmoji.value,
                                    fontFamilyFallback: [
                                      FontFamily.twEmoji.value,
                                    ],
                                  ),
                            )
                          : Icon(
                              Icons.network_check,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 1,
                        child: TooltipText(
                          text: Text(
                            appLocalizations.networkDetection,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2),
                      AspectRatio(
                        aspectRatio: 1,
                        child: _buildSettingsButton(context),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: baseInfoEdgeInsets.copyWith(top: 0),
                  child: SizedBox(
                    height: globalState.measure.bodyMediumHeight + 2,
                    child: FadeThroughBox(
                      child: ipInfo != null
                          ? _buildRiskMark(
                              context,
                              TooltipText(
                                text: Text(
                                  ipInfo.ip,
                                  style: context.textTheme.bodyMedium?.toLight
                                      .adjustSize(1),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          : FadeThroughBox(
                              child: isLoading == false && ipInfo == null
                                  ? Text(
                                      state.errorMessage ?? 'timeout',
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.red)
                                          .adjustSize(1),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : Container(
                                      padding: const EdgeInsets.all(2),
                                      child: Center(
                                        child: OverflowBox(
                                          maxWidth: 30,
                                          maxHeight: 16,
                                          child: SpinKitThreeBounce(
                                            color: context.colorScheme.primary,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
