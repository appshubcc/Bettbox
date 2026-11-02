import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:material_ui/material_ui.dart';

import 'dialog.dart';

const _riskGradient = [Colors.green, Color(0xFFC57F0A), Colors.red];

extension IpRiskLevelExt on IpRiskLevel {
  String get label => switch (this) {
    IpRiskLevel.low => appLocalizations.ipRiskLow,
    IpRiskLevel.medium => appLocalizations.ipRiskMedium,
    IpRiskLevel.high => appLocalizations.ipRiskHigh,
    IpRiskLevel.veryHigh => appLocalizations.ipRiskVeryHigh,
  };
}

extension IpRiskGroupExt on IpRiskGroup {
  String get label => switch (this) {
    IpRiskGroup.datacenter => appLocalizations.ipRiskHostingOrProxy,
    IpRiskGroup.blacklist => appLocalizations.ipRiskBlacklist,
    IpRiskGroup.proxy => appLocalizations.ipRiskProxyType,
  };
}

String _checkLabel(String name) => switch (name) {
  'Datacenter' => appLocalizations.ipRiskDatacenter,
  'Anonymizing VPN' => appLocalizations.ipRiskAnonymousVpn,
  'Tor Exit Node' => appLocalizations.ipRiskTorExit,
  'Server' => appLocalizations.ipRiskServer,
  'Public Proxy' => appLocalizations.ipRiskPublicProxy,
  'Web Proxy' => appLocalizations.ipRiskWebProxy,
  'Search Engine Robot' => appLocalizations.ipRiskSearchRobot,
  'Residential Proxy' => appLocalizations.ipRiskResidentialProxy,
  _ => name,
};

Color _scoreColor(int score) {
  final t = score / 100;
  return t < 0.5
      ? Color.lerp(_riskGradient[0], _riskGradient[1], t * 2) ??
            _riskGradient[1]
      : Color.lerp(_riskGradient[1], _riskGradient[2], (t - 0.5) * 2) ??
            _riskGradient[1];
}

Color _tone(BuildContext context, Color color) {
  final hsl = HSLColor.fromColor(color);
  return Theme.of(context).brightness == Brightness.dark
      ? hsl.withLightness(hsl.lightness.clamp(0.66, 1)).toColor()
      : hsl.withLightness(hsl.lightness.clamp(0, 0.38)).toColor();
}

class IpRiskSource extends StatelessWidget {
  const IpRiskSource({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          '${appLocalizations.ipRiskSource} Scamalytics',
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

class IpRiskScoreBar extends StatelessWidget {
  final int score;

  const IpRiskScoreBar({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(colors: _riskGradient);
    final factor = score / 100;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: 14,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Opacity(
                opacity: 0.22,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: factor,
                  child: Container(
                    width: width,
                    height: 6,
                    decoration: const BoxDecoration(gradient: gradient),
                  ),
                ),
              ),
              Positioned(
                left: (width * factor - 7).clamp(0, width - 14),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colorScheme.surfaceContainerLowest,
                    border: Border.all(color: _scoreColor(score), width: 3),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class IpRiskScore extends StatelessWidget {
  final IpRisk risk;

  const IpRiskScore({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    final score = risk.displayScore;
    final color = _scoreColor(score);
    final muted = context.textTheme.labelSmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(appLocalizations.ipRiskScore, style: muted),
                    InkResponse(
                      radius: 14,
                      onTap: () => showIpRiskNote(risk),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 13,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$score',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _tone(context, color),
                      ),
                    ),
                    Text(' / 100', style: muted),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                risk.level.label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: _tone(context, color),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        IpRiskScoreBar(score: score),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(IpRiskLevel.low.label, style: muted),
            Text(IpRiskLevel.high.label, style: muted),
          ],
        ),
      ],
    );
  }
}

class IpRiskChecks extends StatelessWidget {
  final IpRisk risk;

  const IpRiskChecks({super.key, required this.risk});

  Widget _chip(BuildContext context, IpRiskCheck check) {
    final colorScheme = context.colorScheme;
    final hit = check.hit;
    final color = switch (hit) {
      true => colorScheme.error,
      false => colorScheme.onSurfaceVariant,
      null => colorScheme.outline,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
      decoration: BoxDecoration(
        color: hit == true
            ? colorScheme.error.withValues(alpha: 0.12)
            : colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            switch (hit) {
              true => Icons.error_rounded,
              false => Icons.circle_outlined,
              null => Icons.help_outline_rounded,
            },
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            _checkLabel(check.name),
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: hit == true ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeChip(BuildContext context) {
    final color = _tone(context, Colors.green);
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            appLocalizations.ipRiskHomeBroadband,
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final muted = context.textTheme.labelSmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    final groups = [
      for (final group in IpRiskGroup.values)
        (group, risk.checks.where((check) => check.group == group).toList()),
    ].where((entry) => entry.$2.isNotEmpty).toList();
    final isHome = risk.isHomeBroadband;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, (group, checks)) in groups.indexed) ...[
          if (index > 0) const SizedBox(height: 8),
          Text(group.label, style: muted),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: isHome && group == IpRiskGroup.datacenter
                ? [_homeChip(context)]
                : [for (final check in checks) _chip(context, check)],
          ),
        ],
      ],
    );
  }
}

extension on IpRiskAmount {
  String get label => switch (this) {
    IpRiskAmount.low => appLocalizations.ipRiskAmountLow,
    IpRiskAmount.medium => appLocalizations.ipRiskAmountMedium,
    IpRiskAmount.high => appLocalizations.ipRiskAmountHigh,
  };
}

extension on IpRiskShare {
  String get label => switch (this) {
    IpRiskShare.little => appLocalizations.ipRiskShareLittle,
    IpRiskShare.some => appLocalizations.ipRiskShareSome,
    IpRiskShare.almostAll => appLocalizations.ipRiskShareAlmostAll,
  };
}

extension on IpRiskConnection {
  String get label => switch (this) {
    IpRiskConnection.server => appLocalizations.ipRiskCommercialServer,
    IpRiskConnection.vpn => appLocalizations.ipRiskAnonymousVpn,
    IpRiskConnection.publicProxy => appLocalizations.ipRiskPublicProxy,
    IpRiskConnection.tor => appLocalizations.ipRiskTorExit,
    IpRiskConnection.webProxy => appLocalizations.ipRiskWebProxy,
  };
}

Color _levelColor(IpRiskLevel level) => _scoreColor(switch (level) {
  IpRiskLevel.low => 0,
  IpRiskLevel.medium => 50,
  IpRiskLevel.high || IpRiskLevel.veryHigh => 100,
});

Future<void> showIpRiskNote(IpRisk risk) async {
  await globalState.showCommonDialog(
    child: Builder(
      builder: (context) => CommonDialog(
        title: appLocalizations.ipRiskNoteTitle,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appLocalizations.confirm),
          ),
        ],
        child: IpRiskNoteView(risk: risk.normalized),
      ),
    ),
  );
}

class IpRiskNoteView extends StatelessWidget {
  final IpRisk risk;

  const IpRiskNoteView({super.key, required this.risk});

  String get _basis {
    final note = risk.note;
    final score = risk.displayScore;
    final isp = note?.isp ?? '';
    return switch (note?.direct) {
      true => appLocalizations.ipRiskNoteDirect(score),
      false => appLocalizations.ipRiskNoteIndirect(
        score,
        isp.isNotEmpty ? isp : risk.isp,
      ),
      null => appLocalizations.ipRiskNoteGeneric,
    };
  }

  Widget _row(
    BuildContext context,
    String label,
    InlineSpan value, {
    String? detail,
  }) {
    final muted = context.textTheme.labelSmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: muted),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  value,
                  textAlign: TextAlign.end,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Text(detail, style: muted),
          ],
        ],
      ),
    );
  }

  InlineSpan _party(BuildContext context, String name, IpRiskLevel? level) {
    return TextSpan(
      children: [
        TextSpan(text: name),
        if (level != null) ...[
          const TextSpan(text: ' · '),
          TextSpan(
            text: level.label,
            style: TextStyle(color: _tone(context, _levelColor(level))),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final note = risk.note;
    final rows = <Widget>[
      if (note?.amount case final amount?)
        _row(
          context,
          note?.direct == false
              ? appLocalizations.ipRiskNoteAmountIsp
              : appLocalizations.ipRiskNoteAmount,
          TextSpan(text: amount.label),
        ),
      if (note?.share case final share?)
        _row(
          context,
          appLocalizations.ipRiskNoteShare,
          TextSpan(text: share.label),
        ),
      if (note case IpRiskNote(
        :final operatorName,
      ) when operatorName.isNotEmpty)
        _row(
          context,
          appLocalizations.isp,
          _party(context, operatorName, note.operatorLevel),
        ),
      if (note case IpRiskNote(:final ownerName)
          when ownerName.isNotEmpty &&
              (ownerName != note.operatorName ||
                  note.ownerLevel != note.operatorLevel))
        _row(
          context,
          appLocalizations.ipRiskNoteOwner,
          _party(context, ownerName, note.ownerLevel),
        ),
      if (note?.connection case final connection?)
        _row(
          context,
          appLocalizations.ipRiskNoteConnection,
          TextSpan(text: connection.label),
          detail: connection == IpRiskConnection.server
              ? null
              : appLocalizations.ipRiskNoteProxying,
        ),
    ];
    final warning = switch (note?.warning) {
      IpRiskLevel.veryHigh => appLocalizations.ipRiskNoteWarningVeryHigh,
      IpRiskLevel.high => appLocalizations.ipRiskNoteWarningHigh,
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_basis),
        if (rows.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: rows),
          ),
        ],
        if (warning != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    warning,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          appLocalizations.ipRiskNoteFootnote,
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
