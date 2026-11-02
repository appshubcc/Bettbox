import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Future<void> showIpDetailDialog(
  BuildContext context,
  String rawIp, {
  IpInfo? preloaded,
  bool showRisk = false,
  bool followRiskSetting = true,
}) async {
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

  final isPublic = utils.classifyIp(cleanIp) == IpCategory.public;
  final riskView =
      (showRisk ||
          (followRiskSetting && globalState.config.appSetting.ipRiskDetail)) &&
      isPublic;
  final preloadedRisk = riskView
      ? await request
            .readIpRiskCache(cleanIp)
            .timeout(const Duration(milliseconds: 300), onTimeout: () => null)
      : null;

  final info =
      preloaded ??
      (isPublic && !riskView
          ? await request
                .readIpDetailCache(cleanIp)
                .timeout(
                  const Duration(milliseconds: 300),
                  onTimeout: () => null,
                )
          : null);

  globalState.showAdaptiveSheet(
    child: _IpDetailDialog(
      ip: cleanIp,
      preloaded: info,
      riskView: riskView,
      preloadedRisk: preloadedRisk,
      persistRisk: followRiskSetting,
    ),
  );
}

class _IpDetailDialog extends ConsumerStatefulWidget {
  final String ip;
  final IpInfo? preloaded;
  final bool riskView;
  final IpRisk? preloadedRisk;
  final bool persistRisk;

  const _IpDetailDialog({
    required this.ip,
    this.preloaded,
    this.riskView = false,
    this.preloadedRisk,
    this.persistRisk = true,
  });

  @override
  ConsumerState<_IpDetailDialog> createState() => _IpDetailDialogState();
}

class _IpDetailDialogState extends ConsumerState<_IpDetailDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  IpCategory? _category;
  IpInfo? _ipInfo;
  String? _riskIp;
  IpRisk? _risk;
  bool _riskFailed = false;
  bool _editing = false;
  int _riskSerial = 0;
  final _cancelToken = CancelToken();
  final _ipController = TextEditingController();

  @override
  void dispose() {
    _cancelToken.cancel();
    _ipController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.riskView) {
      _riskIp = widget.ip;
      if (widget.preloadedRisk case final risk?) {
        _risk = risk;
      } else {
        _fetchRisk(widget.ip);
      }
    }
    final preloaded = widget.preloaded;
    if (preloaded != null) {
      _ipInfo = preloaded;
      _isLoading = false;
      return;
    }
    _fetchIpDetail();
  }

  Future<void> _afterEntrance() async {
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.status != AnimationStatus.forward) {
      return;
    }
    final completer = Completer<void>();
    void listener(AnimationStatus status) {
      if (status != AnimationStatus.forward && !completer.isCompleted) {
        completer.complete();
      }
    }

    animation.addStatusListener(listener);
    await completer.future;
    animation.removeStatusListener(listener);
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

    final res = await request.queryIpDetail(
      widget.ip,
      cancelToken: _cancelToken,
    );
    if (!mounted) return;
    await _afterEntrance();
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
      decoration: panelTileDecoration(context),
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

  void _loadRisk(String ip, {bool force = false}) {
    setState(() {
      _riskIp = ip;
      _risk = null;
      _riskFailed = false;
      _editing = false;
    });
    _fetchRisk(ip, force: force);
  }

  Future<void> _fetchRisk(String ip, {bool force = false}) async {
    final serial = ++_riskSerial;
    final res = await request.queryIpRisk(
      ip,
      force: force,
      cancelToken: _cancelToken,
    );
    if (!mounted) return;
    await _afterEntrance();
    if (!mounted || serial != _riskSerial) return;
    setState(() {
      _risk = res.data;
      _riskFailed = res.isError || res.data == null;
    });
  }

  void _submitIp(String value) {
    final address = InternetAddress.tryParse(value.trim());
    if (address == null ||
        utils.classifyIp(address.address) != IpCategory.public) {
      context.showNotifier(appLocalizations.ipRiskInvalid);
      return;
    }
    if (address.address == _riskIp && _risk != null) {
      setState(() => _editing = false);
      return;
    }
    _loadRisk(address.address);
  }

  void _toggleRisk() {
    final detail = _riskIp == null;
    if (widget.persistRisk) {
      ref
          .read(appSettingProvider.notifier)
          .updateState((state) => state.copyWith(ipRiskDetail: detail));
    }
    if (detail) {
      _loadRisk(widget.ip);
      return;
    }
    setState(() {
      _riskSerial++;
      _riskIp = null;
      _risk = null;
      _riskFailed = false;
      _editing = false;
    });
  }

  Widget _buildRiskButton() {
    return _buildIconButton(
      icon: Icons.swap_horiz_rounded,
      tooltip: appLocalizations.toggle,
      onPressed: _toggleRisk,
    );
  }

  Widget _buildRiskCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: panelTileDecoration(context),
      child: child,
    );
  }

  Widget _buildRiskIpTile(String ip) {
    final valueStyle = context.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.bold,
    );
    return _buildStatTile(
      icon: Icons.location_on_rounded,
      iconColor: context.colorScheme.primary,
      label: appLocalizations.ipAddress,
      value: ip,
      customValue: _editing
          ? TextField(
              controller: _ipController,
              autofocus: true,
              style: valueStyle,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: appLocalizations.ipRiskHint,
                hintStyle: valueStyle?.copyWith(
                  fontWeight: FontWeight.normal,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: _submitIp,
            )
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _ipController.text = ip;
                setState(() => _editing = true);
              },
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      ip,
                      style: valueStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit_outlined,
                    size: 13,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
      action: _editing
          ? _buildIconButton(
              icon: Icons.search_rounded,
              tooltip: appLocalizations.search,
              onPressed: () => _submitIp(_ipController.text),
            )
          : _buildRiskButton(),
    );
  }

  Widget _buildRiskInfo(IpRisk risk) {
    final muted = context.textTheme.labelSmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    final valueStyle = context.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    Widget? cell(String label, String value, {Widget? leading}) {
      if (value.isEmpty) return null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: muted),
          const SizedBox(height: 1),
          Row(
            children: [
              ?leading,
              Flexible(child: SelectableText(value, style: valueStyle)),
            ],
          ),
        ],
      );
    }

    final countryCode = IpInfo.normalizeCountryCode(
      risk.countryCode,
      risk.country,
      risk.region,
    );
    final countryName =
        IpInfo.normalizeCountry(risk.country, countryCode, risk.region) ?? '';
    final country = cell(
      appLocalizations.countryOrRegion,
      countryName.isNotEmpty ? countryName : countryCode,
      leading: countryCode.length == 2
          ? Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                utils.countryCodeToEmoji(countryCode),
                style: TextStyle(
                  fontFamily: FontFamily.twEmoji.value,
                  fontFamilyFallback: [FontFamily.twEmoji.value],
                  fontSize: 14,
                ),
              ),
            )
          : null,
    );
    final region = cell(
      appLocalizations.provinceAndCity,
      [
        if (risk.region.isNotEmpty) risk.region,
        if (risk.city.isNotEmpty && risk.city != risk.region) risk.city,
      ].join(' · '),
    );
    final rows = <Widget>[
      if (country != null && region != null)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: country),
            const SizedBox(width: 12),
            Expanded(child: region),
          ],
        )
      else
        ?(country ?? region),
      ?cell(
        appLocalizations.operatorOrAsn,
        [
          if (risk.organization.isNotEmpty) risk.organization,
          if (risk.asn.isNotEmpty) risk.asn,
        ].join(' · '),
      ),
      if (risk.isp != risk.organization) ?cell(appLocalizations.isp, risk.isp),
      ?cell(appLocalizations.ipRiskHostname, risk.hostname),
    ];
    return _buildRiskCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _fadeSwitcher(Widget child) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.4, 1, curve: Curves.easeOut),
        ),
        child: child,
      ),
      layoutBuilder: (current, previous) => Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topLeft,
        children: [
          for (final child in previous)
            Positioned(left: 0, top: 0, right: 0, child: child),
          ?current,
        ],
      ),
      child: child,
    );
  }

  Widget _spaced(List<Widget> items, {Key? key}) {
    return Column(
      key: key,
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

  Widget _buildRiskContent(String ip) {
    final risk = _risk;
    final body = risk != null
        ? _spaced(key: ValueKey(risk), [
            _buildRiskCard(IpRiskScore(risk: risk)),
            if (risk.checks.isNotEmpty)
              _buildRiskCard(IpRiskChecks(risk: risk)),
            _buildRiskInfo(risk),
            const IpRiskSource(),
          ])
        : KeyedSubtree(
            key: ValueKey(_riskFailed),
            child: _buildRiskCard(
              SizedBox(
                height: 84,
                child: _riskFailed
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            appLocalizations.networkErrorRetryLater,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.error,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _loadRisk(ip, force: true),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: Text(appLocalizations.retry),
                          ),
                        ],
                      )
                    : Center(
                        child: SpinKitThreeBounce(
                          color: context.colorScheme.primary,
                          size: 16,
                        ),
                      ),
              ),
            ),
          );
    return _spaced(key: const ValueKey('risk'), [
      _buildRiskIpTile(ip),
      _fadeSwitcher(body),
    ]);
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
            icon: Icons.location_on_rounded,
            iconColor: context.colorScheme.primary,
            label: appLocalizations.ipAddress,
            value: widget.ip,
          ),
          const SizedBox(height: 8),
          _buildStatTile(
            icon: Icons.stacked_line_chart,
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
            icon: Icons.location_on_rounded,
            iconColor: context.colorScheme.primary,
            label: appLocalizations.ipAddress,
            value: widget.ip,
          ),
          const SizedBox(height: 8),
          _buildStatTile(
            icon: Icons.shuffle_rounded,
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
            icon: Icons.location_on_rounded,
            iconColor: context.colorScheme.primary,
            label: appLocalizations.ipAddress,
            value: widget.ip,
            action: _buildRiskButton(),
          ),
          const SizedBox(height: 8),
          _buildStatTile(
            icon: Icons.error_outline,
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
          icon: Icons.location_on_rounded,
          iconColor: context.colorScheme.primary,
          label: appLocalizations.ipAddress,
          value: widget.ip,
          action: _buildRiskButton(),
        ),
        if (countryText.isNotEmpty || flagEmoji.isNotEmpty)
          _buildStatTile(
            icon: Icons.flag_rounded,
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
            icon: Icons.location_city_rounded,
            iconColor: context.colorScheme.tertiary,
            label: appLocalizations.provinceAndCity,
            value: provinceCity,
          ),
        if (operatorText.isNotEmpty)
          _buildStatTile(
            icon: Icons.business_rounded,
            iconColor: context.colorScheme.secondary,
            label: appLocalizations.operatorOrAsn,
            value: operatorText,
          ),
        if (ispText.isNotEmpty)
          _buildStatTile(
            icon: Icons.router_rounded,
            iconColor: context.colorScheme.primary,
            label: appLocalizations.isp,
            value: ispText,
          ),
        if (domainText.isNotEmpty)
          _buildStatTile(
            icon: Icons.link_rounded,
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

    if (_riskIp case final riskIp?) {
      content = _buildRiskContent(riskIp);
    }

    return CommonDialog(
      title: appLocalizations.moreIpInfo,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      actions: isInBottomSheet(context)
          ? null
          : [
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Text(appLocalizations.confirm),
              ),
            ],
      child: SingleChildScrollView(
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: _fadeSwitcher(content),
        ),
      ),
    );
  }
}
