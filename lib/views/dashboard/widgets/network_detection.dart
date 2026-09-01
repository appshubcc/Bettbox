import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NetworkDetection extends ConsumerStatefulWidget {
  const NetworkDetection({super.key});

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

  void _showIpClickBehaviorSettings() {
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    globalState.showCommonDialog<IpClickBehavior>(
      child: CommonDialog(
        title: appLocalizations.ipClickBehavior,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.sync),
              title: Text(appLocalizations.manualRefreshIp),
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                detectionState.manualRefresh();
              },
            ),
            if (isZh)
              ListTile(
                leading: Icon(Icons.public),
                title: Text(appLocalizations.switchToDomesticIp),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  detectionState.switchToDomesticIp();
                },
              ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text(appLocalizations.ipPrivacyProtection),
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                detectionState.toggleIpPrivacy();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreIpInfoDialog() {
    final rawIpInfo = detectionState.rawIpInfo;
    if (rawIpInfo == null) return;

    final flagEmoji = rawIpInfo.countryCode.isNotEmpty
        ? _countryCodeToEmoji(rawIpInfo.countryCode)
        : '';

    final countryName =
        (rawIpInfo.country != null && rawIpInfo.country!.isNotEmpty)
        ? rawIpInfo.country!
        : (rawIpInfo.countryCode.isNotEmpty ? rawIpInfo.countryCode : '');

    final countryContinent = [
      if (countryName.isNotEmpty) countryName,
      if (rawIpInfo.continent != null && rawIpInfo.continent!.isNotEmpty)
        rawIpInfo.continent,
    ].join(' · ');

    final provinceCity = [
      if (rawIpInfo.province != null && rawIpInfo.province!.isNotEmpty)
        rawIpInfo.province,
      if (rawIpInfo.city != null &&
          rawIpInfo.city!.isNotEmpty &&
          rawIpInfo.city != rawIpInfo.province)
        rawIpInfo.city,
    ].join(' · ');

    final ispText = (rawIpInfo.isp != null && rawIpInfo.isp!.isNotEmpty)
        ? rawIpInfo.isp!
        : '';

    final operatorText = [
      if (rawIpInfo.asName != null &&
          rawIpInfo.asName!.isNotEmpty &&
          rawIpInfo.asName != rawIpInfo.isp &&
          rawIpInfo.asName != rawIpInfo.asDomain)
        rawIpInfo.asName,
      if (rawIpInfo.asn != null && rawIpInfo.asn!.isNotEmpty)
        rawIpInfo.asn,
    ].join(' · ');

    globalState.showCommonDialog(
      child: CommonDialog(
        title: appLocalizations.moreIpInfo,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(appLocalizations.confirm),
          ),
        ],
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. IP 地址（附带查看详细 IP 数据外链与 Tooltip 提示）
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.location_on_outlined),
                title: Text(appLocalizations.ipAddress),
                subtitle: SelectableText(
                  rawIpInfo.ip,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  tooltip: appLocalizations.viewDetailedIpData,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    globalState.openUrl('https://ipinfo.io/what-is-my-ip');
                  },
                ),
              ),
              // 2. 国家与大洲合并（Emoji 统一使用 twEmoji，精准间距）
              if (countryContinent.isNotEmpty || flagEmoji.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(appLocalizations.countryOrRegion),
                  subtitle: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (flagEmoji.isNotEmpty) ...[
                        Text(
                          flagEmoji,
                          style: TextStyle(
                            fontFamily: FontFamily.twEmoji.value,
                            fontFamilyFallback: [
                              FontFamily.twEmoji.value,
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          countryContinent,
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              // 3. 省份 / 城市 (独立行，非空才展示)
              if (provinceCity.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_city_outlined),
                  title: Text(appLocalizations.provinceAndCity),
                  subtitle: Text(provinceCity),
                ),
              // 4. 归属 / ASN (非空才展示)
              if (operatorText.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.business_outlined),
                  title: Text(appLocalizations.operatorOrAsn),
                  subtitle: Text(operatorText),
                ),
              // 5. 运营商 (非空才展示)
              if (ispText.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.router_outlined),
                  title: Text(appLocalizations.isp),
                  subtitle: Text(ispText),
                ),
              // 6. 组织 / 域名 (非空才展示)
              if (rawIpInfo.asDomain != null && rawIpInfo.asDomain!.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.link_outlined),
                  title: Text(appLocalizations.domain),
                  subtitle: Text(rawIpInfo.asDomain!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(1),
      child: ValueListenableBuilder<NetworkDetectionState>(
        valueListenable: detectionState.state,
        builder: (_, state, _) {
          final ipInfo = state.ipInfo;
          final isLoading = state.isLoading;
          return CommonCard(
            onPressed: ipInfo != null ? _showMoreIpInfoDialog : () {},
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
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: _showIpClickBehaviorSettings,
                          icon: Icon(
                            size: 16.ap,
                            Icons.settings_outlined,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
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
                          ? TooltipText(
                              text: Text(
                                ipInfo.ip,
                                style: context.textTheme.bodyMedium?.toLight
                                    .adjustSize(1),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
