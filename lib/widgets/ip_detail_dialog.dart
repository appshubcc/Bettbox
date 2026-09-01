import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void showIpDetailDialog(BuildContext context, String rawIp) {
  var cleanIp = rawIp.trim();
  if (cleanIp.startsWith('[') && cleanIp.contains(']')) {
    cleanIp = cleanIp.substring(1, cleanIp.indexOf(']'));
  } else if (cleanIp.contains(':') && !cleanIp.contains('::')) {
    final parts = cleanIp.split(':');
    if (parts.length == 2 && int.tryParse(parts[1]) != null) {
      cleanIp = parts[0];
    }
  }

  if (cleanIp.isEmpty) return;

  globalState.showCommonDialog(
    child: _IpDetailDialog(ip: cleanIp),
  );
}

class _IpDetailDialog extends StatefulWidget {
  final String ip;

  const _IpDetailDialog({required this.ip});

  @override
  State<_IpDetailDialog> createState() => _IpDetailDialogState();
}

class _IpDetailDialogState extends State<_IpDetailDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  IpCategory? _category;
  IpInfo? _ipInfo;

  @override
  void initState() {
    super.initState();
    _fetchIpDetail();
  }

  Future<void> _fetchIpDetail() async {
    final cat = utils.classifyIp(widget.ip);
    if (cat != IpCategory.public) {
      if (mounted) {
        setState(() {
          _category = cat;
          _isLoading = false;
        });
      }
      return;
    }

    final res = await request.queryIpDetail(widget.ip);
    if (!mounted) return;

    if (res.isError) {
      final msg = res.message;
      if (msg.contains('private') || msg.contains('reserved')) {
        setState(() {
          _category = IpCategory.lan;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = appLocalizations.networkErrorRetryLater;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _ipInfo = res.data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ipInfo = _ipInfo;

    final flagEmoji = (ipInfo != null && ipInfo.countryCode.isNotEmpty)
        ? utils.countryCodeToEmoji(ipInfo.countryCode)
        : '';

    final countryText = ipInfo != null
        ? [
            if (ipInfo.country != null && ipInfo.country!.isNotEmpty)
              ipInfo.country,
            if (ipInfo.countryCode.isNotEmpty)
              ipInfo.countryCode,
          ].join(' · ')
        : '';

    final provinceCity = ipInfo != null
        ? [
            if (ipInfo.province != null && ipInfo.province!.isNotEmpty)
              ipInfo.province,
            if (ipInfo.city != null &&
                ipInfo.city!.isNotEmpty &&
                ipInfo.city != ipInfo.province)
              ipInfo.city,
          ].join(' · ')
        : '';

    final ispText = (ipInfo?.isp != null && ipInfo!.isp!.isNotEmpty)
        ? ipInfo.isp!
        : '';

    final operatorText = ipInfo != null
        ? [
            if (ipInfo.asName != null &&
                ipInfo.asName!.isNotEmpty &&
                ipInfo.asName != ipInfo.isp &&
                ipInfo.asName != ipInfo.asDomain)
              ipInfo.asName,
            if (ipInfo.asn != null && ipInfo.asn!.isNotEmpty)
              ipInfo.asn,
          ].join(' · ')
        : '';

    final domainText = (ipInfo?.asDomain != null && ipInfo!.asDomain!.isNotEmpty)
        ? ipInfo.asDomain!
        : '';

    Widget content;
    if (_isLoading) {
      content = Container(
        height: 120,
        alignment: Alignment.center,
        child: SpinKitThreeBounce(
          color: context.colorScheme.primary,
          size: 24,
        ),
      );
    } else if (_category == IpCategory.tun) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_on_outlined),
            title: Text(appLocalizations.ipAddress),
            subtitle: SelectableText(
              widget.ip,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.stacked_line_chart),
            title: Text(appLocalizations.tunVirtualAddress),
            subtitle: Text(
              'TUN Virtual Network Adapter',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    } else if (_category == IpCategory.lan) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_on_outlined),
            title: Text(appLocalizations.ipAddress),
            subtitle: SelectableText(
              widget.ip,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.shuffle),
            title: Text(appLocalizations.privateIp),
            subtitle: Text(
              'LAN / Private Network',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    } else if (_errorMessage != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_on_outlined),
            title: Text(appLocalizations.ipAddress),
            subtitle: SelectableText(
              widget.ip,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.error_outline, color: Colors.red),
            title: Text(
              _errorMessage!,
              style: context.textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
          ),
        ],
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. IP 地址
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_on_outlined),
            title: Text(appLocalizations.ipAddress),
            subtitle: SelectableText(
              widget.ip,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 2. 国家 / 地区（twEmoji 国旗 + 国家名 · 国家代码）
          if (countryText.isNotEmpty || flagEmoji.isNotEmpty)
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
                      countryText,
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          // 3. 省份 / 城市
          if (provinceCity.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_city_outlined),
              title: Text(appLocalizations.provinceAndCity),
              subtitle: Text(provinceCity),
            ),
          // 4. 归属 / ASN
          if (operatorText.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.business_outlined),
              title: Text(appLocalizations.operatorOrAsn),
              subtitle: Text(operatorText),
            ),
          // 5. 运营商（单独一行放到下方）
          if (ispText.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.router_outlined),
              title: Text(appLocalizations.isp),
              subtitle: Text(ispText),
            ),
          // 6. 组织 / 域名（非空才展示）
          if (domainText.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.link_outlined),
              title: Text(appLocalizations.domain),
              subtitle: Text(domainText),
            ),
        ],
      );
    }

    return CommonDialog(
      title: appLocalizations.moreIpInfo,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: content,
    );
  }
}
