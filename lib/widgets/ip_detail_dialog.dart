import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void showIpDetailDialog(
  BuildContext context,
  String rawIp, {
  IpInfo? preloaded,
}) {
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
    child: _IpDetailDialog(ip: cleanIp, preloaded: preloaded),
  );
}

class _IpDetailDialog extends StatefulWidget {
  final String ip;
  final IpInfo? preloaded;

  const _IpDetailDialog({required this.ip, this.preloaded});

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
    final preloaded = widget.preloaded;
    if (preloaded != null) {
      _ipInfo = preloaded;
      _isLoading = false;
      return;
    }
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

  Widget _buildStatTile({
    required IconData icon,
    required Color iconColor,
    String label = '',
    required String value,
    Widget? action,
    Widget? customValue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: label.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      customValue ??
                          SelectableText(
                            value,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                          ),
                    ],
                  )
                : (customValue ??
                      SelectableText(
                        value,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      )),
          ),
          if (action != null) ...[const SizedBox(width: 4), action],
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      icon: Icon(icon, size: 15, color: context.colorScheme.onSurfaceVariant),
      tooltip: tooltip,
      onPressed: onPressed,
    );
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
            if (ipInfo.countryCode.isNotEmpty) ipInfo.countryCode,
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

    final ispText = (ipInfo?.isp != null && (ipInfo?.isp?.isNotEmpty ?? false))
        ? (ipInfo?.isp ?? '')
        : '';

    final operatorText = ipInfo != null
        ? [
            if (ipInfo.asName != null &&
                ipInfo.asName!.isNotEmpty &&
                ipInfo.asName != ipInfo.isp &&
                ipInfo.asName != ipInfo.asDomain)
              ipInfo.asName,
            if (ipInfo.asn != null && ipInfo.asn!.isNotEmpty) ipInfo.asn,
          ].join(' · ')
        : '';

    final domainText =
        (ipInfo?.asDomain != null && (ipInfo?.asDomain?.isNotEmpty ?? false))
        ? (ipInfo?.asDomain ?? '')
        : '';

    Widget content;
    if (_isLoading) {
      content = Container(
        height: 120,
        alignment: Alignment.center,
        child: SpinKitThreeBounce(color: context.colorScheme.primary, size: 24),
      );
    } else if (_category == IpCategory.tun) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatTile(
            icon: ReIcons.location,
            iconColor: context.colorScheme.primary,
            label: appLocalizations.ipAddress,
            value: widget.ip,
          ),
          const SizedBox(height: 8),
          _buildStatTile(
            icon: ReIcons.shieldNetwork,
            iconColor: context.colorScheme.tertiary,
            label: appLocalizations.tunVirtualAddress,
            value: 'TUN Virtual Network Adapter',
          ),
        ],
      );
    } else if (_category == IpCategory.lan) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatTile(
            icon: ReIcons.location,
            iconColor: context.colorScheme.primary,
            label: appLocalizations.ipAddress,
            value: widget.ip,
          ),
          const SizedBox(height: 8),
          _buildStatTile(
            icon: ReIcons.sitemap,
            iconColor: context.colorScheme.secondary,
            label: appLocalizations.privateIp,
            value: 'LAN / Private Network',
          ),
        ],
      );
    } else if (_errorMessage != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatTile(
            icon: ReIcons.location,
            iconColor: context.colorScheme.primary,
            label: appLocalizations.ipAddress,
            value: widget.ip,
            action: _buildIconButton(
              icon: ReIcons.export,
              tooltip: appLocalizations.viewDetailedIpData,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                globalState.openUrl('https://www.ip2location.com/${widget.ip}');
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildStatTile(
            icon: ReIcons.alertCircle,
            iconColor: Colors.red,
            value: _errorMessage ?? '',
            customValue: Text(
              _errorMessage ?? '',
              style: context.textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
          ),
        ],
      );
    } else {
      final items = <Widget>[
        _buildStatTile(
          icon: ReIcons.location,
          iconColor: context.colorScheme.primary,
          label: appLocalizations.ipAddress,
          value: widget.ip,
          action: _buildIconButton(
            icon: ReIcons.export,
            tooltip: appLocalizations.viewDetailedIpData,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              globalState.openUrl('https://www.ip2location.com/${widget.ip}');
            },
          ),
        ),
        if (countryText.isNotEmpty || flagEmoji.isNotEmpty)
          _buildStatTile(
            icon: ReIcons.flag,
            iconColor: context.colorScheme.secondary,
            label: appLocalizations.countryOrRegion,
            value: countryText,
            customValue: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (flagEmoji.isNotEmpty) ...[
                  Text(
                    flagEmoji,
                    style: TextStyle(
                      fontFamily: FontFamily.twEmoji.value,
                      fontFamilyFallback: [FontFamily.twEmoji.value],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: SelectableText(
                    countryText,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        if (provinceCity.isNotEmpty)
          _buildStatTile(
            icon: ReIcons.buildings,
            iconColor: context.colorScheme.tertiary,
            label: appLocalizations.provinceAndCity,
            value: provinceCity,
          ),
        if (operatorText.isNotEmpty)
          _buildStatTile(
            icon: ReIcons.building,
            iconColor: context.colorScheme.secondary,
            label: appLocalizations.operatorOrAsn,
            value: operatorText,
          ),
        if (ispText.isNotEmpty)
          _buildStatTile(
            icon: ReIcons.router,
            iconColor: context.colorScheme.primary,
            label: appLocalizations.isp,
            value: ispText,
          ),
        if (domainText.isNotEmpty)
          _buildStatTile(
            icon: ReIcons.link,
            iconColor: context.colorScheme.tertiary,
            label: appLocalizations.organizationDomain,
            value: domainText,
          ),
      ];

      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1) const SizedBox(height: 8),
          ],
        ],
      );
    }

    return CommonDialog(
      title: appLocalizations.moreIpInfo,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: SingleChildScrollView(child: content),
    );
  }
}
