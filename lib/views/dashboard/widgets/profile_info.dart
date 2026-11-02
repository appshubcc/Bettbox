import 'dart:math' as math;

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/views/proxies/card.dart';
import 'package:bett_box/views/proxies/common.dart';
import 'package:bett_box/views/proxies/providers.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_ui/material_ui.dart';

import 'tile.dart';

const List<double> _emptySegments = [0];

extension on Profile {
  bool get canRefresh =>
      type != ProfileType.file || providerSubscriptions.isNotEmpty;
}

Future<void> _updateProfile(Profile profile) async {
  final appController = globalState.appController;
  try {
    appController.setProfile(profile.copyWith(isUpdating: true));
    await appController.updateProfile(profile, applyUnchanged: false);
  } on Object catch (e) {
    appController.setProfile(profile.copyWith(isUpdating: false));
    globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: '${profile.label ?? profile.id}: ${e.formatError}',
      ),
      cancelable: false,
    );
  }
}

Future<void> refreshProfileSubscription(
  BuildContext context,
  WidgetRef ref,
  Profile profile,
) async {
  if (profile.type == ProfileType.bundle) {
    final appController = globalState.appController;
    await appController.safeRun(
      () => appController.generateBundle(profile.id, refresh: true),
      silence: false,
    );
    return;
  }
  if (profile.providerSubscriptions.isNotEmpty) {
    await updateExternalProviders(ref, context, type: 'Proxy');
  }
  if (profile.type != ProfileType.url || !context.mounted) return;
  await _updateProfile(ref.read(currentProfileProvider) ?? profile);
}

void showProfileSwitchSheet(BuildContext context) {
  showSheet(
    context: context,
    builder: (_, type) => AdaptiveSheetScaffold(
      type: type,
      title: appLocalizations.profiles,
      actions: [
        IconButton(
          tooltip: appLocalizations.profiles,
          onPressed: () => globalState.appController.toProfiles(),
          icon: const Icon(Icons.open_in_new),
        ),
      ],
      body: const _ProfileSwitchList(),
    ),
  );
}

void showGroupProxySheet(BuildContext context, String groupName) {
  showSheet(
    context: context,
    builder: (_, type) => _GroupProxySheet(type: type, groupName: groupName),
  );
}

class ProfileInfo extends ConsumerWidget {
  final DashboardTileSize? size;

  const ProfileInfo({super.key, this.size});

  Widget _buildEmpty(BuildContext context, DashboardTileSize size) {
    return DashboardTileCard(
      size: size,
      info: Info(
        label: appLocalizations.profile,
        iconData: Icons.description_outlined,
      ),
      mark: DashboardDecor.icon(context, Icons.description_outlined, 80),
      markAngle: -0.2,
      onPressed: () => globalState.appController.toProfiles(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            appLocalizations.nullProfileDesc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpireText(
    BuildContext context,
    Profile profile,
    ProfileUsage? usage,
  ) {
    final text = profile.usageExpireText(usage);
    if (text == null) return const SizedBox.shrink();
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.labelSmall?.copyWith(
        color: usage?.isExpired == true
            ? context.colorScheme.error
            : context.colorScheme.onSurfaceVariant,
      ),
    );
  }

  List<Widget> _buildActions(Profile profile) => [
    if (profile.canRefresh) _RefreshButton(profile: profile),
  ];

  Widget _buildName(BuildContext context, Profile profile, TextStyle? style) {
    return _TapArea(
      onTap: () => showProfileSwitchSheet(context),
      child: _ProfileName(name: profile.label ?? profile.id, style: style),
    );
  }

  Widget _buildWide(BuildContext context, Profile profile) {
    final usage = ProfileUsage.of(profile);
    final segments = usage?.segments ?? _emptySegments;
    final expireText = profile.usageExpireText(usage);
    final colorScheme = context.colorScheme;
    return SizedBox(
      height: getWidgetHeight(context, 1),
      child: CommonCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.ap, 11.ap, 10.ap, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _buildName(
                        context,
                        profile,
                        context.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (expireText != null)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: _buildExpireText(context, profile, usage),
                    ),
                  if (expireText != null && profile.canRefresh)
                    const SizedBox(width: 4),
                  ..._buildActions(profile),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.ap, 4.ap, 10.ap, 10.ap),
                child: LayoutBuilder(
                  builder: (_, constraints) => Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              usage?.usageText ?? appLocalizations.noUsageData,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: usage == null
                                    ? colorScheme.onSurfaceVariant
                                    : null,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            if (segments.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _SegmentBar(segments: segments, height: 4),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth / 2,
                        ),
                        child: const _CurrentNode(style: _NodeStyle.pill),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLarge(BuildContext context, Profile profile) {
    final usage = ProfileUsage.of(profile);
    final ratio = usage?.ratio;
    final segments = usage?.segments ?? _emptySegments;
    final colorScheme = context.colorScheme;
    final small = context.textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final subtitle = [
      ?profile.lastUpdateDate?.lastUpdateTimeDesc,
      ?profile.usageExpireText(usage),
    ].join(' · ');
    return DashboardTileCard(
      size: DashboardTileSize.large,
      info: Info(
        label: appLocalizations.profile,
        iconData: Icons.description_outlined,
      ),
      mark: DashboardDecor.icon(context, Icons.description_outlined, 80),
      markAngle: -0.2,
      actions: _buildActions(profile),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildName(
              context,
              profile,
              context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (usage?.isMulti != true && subtitle.isNotEmpty)
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: usage?.isExpired == true
                    ? small?.copyWith(color: colorScheme.error)
                    : small,
              ),
            const Spacer(),
            if (usage == null)
              Text(
                appLocalizations.noUsageData,
                style: context.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    TrafficValue(value: usage.used).show,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '  / ${usage.totalText}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (ratio != null)
                    Text(
                      '${(ratio * 100).round()}%',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                ],
              ),
            if (segments.isNotEmpty) ...[
              const SizedBox(height: 6),
              _SegmentBar(segments: segments, height: 5),
            ],
            if (usage != null && usage.isMulti) ...[
              const SizedBox(height: 4),
              Text(
                usage.breakdown,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: small,
              ),
            ],
            const SizedBox(height: 10),
            const _CurrentNode(style: _NodeStyle.grouped),
          ],
        ),
      ),
    );
  }

  Widget _buildTall(BuildContext context, Profile profile) {
    final usage = ProfileUsage.of(profile);
    final ratio = usage?.ratio;
    final colorScheme = context.colorScheme;
    return DashboardTileCard(
      size: DashboardTileSize.tall,
      info: Info(
        label: appLocalizations.profile,
        iconData: Icons.description_outlined,
      ),
      mark: DashboardDecor.icon(context, Icons.description_outlined, 80),
      markAngle: -0.2,
      actions: _buildActions(profile),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildName(
              context,
              profile,
              context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            _buildExpireText(context, profile, usage),
            const Spacer(),
            Row(
              children: [
                SizedBox.square(
                  dimension: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: _UsageRing(segments: usage?.segments ?? []),
                      ),
                      Text(
                        ratio == null ? '—' : '${(ratio * 100).round()}%',
                        style: context.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: usage == null
                      ? Text(
                          appLocalizations.noUsageData,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TrafficValue(value: usage.used).show,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '/ ${usage.totalText}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            const Spacer(),
            const _CurrentNode(style: _NodeStyle.plain),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = this.size ?? DashboardTileSize.wide;
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) return _buildEmpty(context, size);
    return switch (size) {
      DashboardTileSize.large => _buildLarge(context, profile),
      DashboardTileSize.tall => _buildTall(context, profile),
      _ => _buildWide(context, profile),
    };
  }
}

class _TapArea extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _TapArea({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;
    return Transform.translate(
      offset: const Offset(-6, 0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ProfileName extends StatelessWidget {
  final String name;
  final TextStyle? style;

  const _ProfileName({required this.name, this.style});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: EmojiText(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        const SizedBox(width: 2),
        Icon(
          Icons.unfold_more,
          size: 16,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _RefreshButton extends ConsumerWidget {
  final Profile profile;

  const _RefreshButton({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final isProviderUpdating = ref.watch(
      providersProvider.select(
        (providers) =>
            providers.any((item) => item.type == 'Proxy' && item.isUpdating),
      ),
    );
    return SizedBox.square(
      dimension: 24,
      child: profile.isUpdating || isProviderUpdating
          ? Padding(
              padding: const EdgeInsets.all(4),
              child: SyncedLoading(
                size: 16,
                child: SpinKitFadingCircle(
                  color: colorScheme.primary,
                  size: 16,
                ),
              ),
            )
          : IconButton(
              padding: EdgeInsets.zero,
              tooltip: appLocalizations.update,
              onPressed: () =>
                  refreshProfileSubscription(context, ref, profile),
              icon: Icon(
                Icons.sync,
                size: 16.ap,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
    );
  }
}

enum _NodeStyle { pill, grouped, plain }

class _CurrentNode extends ConsumerWidget {
  final _NodeStyle style;

  const _CurrentNode({required this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDirect = ref.watch(
      patchClashConfigProvider.select((state) => state.mode == Mode.direct),
    );
    final groupName = ref.watch(currentMainGroupNameProvider);
    if (isDirect) {
      return _NodeLabel(style: style, nodeName: appLocalizations.direct);
    }
    if (groupName == null) return const SizedBox.shrink();
    return _GroupNode(style: style, groupName: groupName);
  }
}

class _GroupNode extends ConsumerWidget {
  final _NodeStyle style;
  final String groupName;

  const _GroupNode({required this.style, required this.groupName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodeName = ref.watch(
      getProxyCardStateProvider(groupName).select((state) => state.proxyName),
    );
    final delay = ref.watch(getDelayProvider(proxyName: groupName));
    return _NodeLabel(
      style: style,
      nodeName: nodeName,
      delay: delay,
      onTap: () => showGroupProxySheet(context, groupName),
    );
  }
}

class _NodeLabel extends StatelessWidget {
  final _NodeStyle style;
  final String nodeName;
  final int? delay;
  final VoidCallback? onTap;

  const _NodeLabel({
    required this.style,
    required this.nodeName,
    this.delay,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final delay = this.delay;
    final isPlain = style == _NodeStyle.plain;
    final row = Row(
      mainAxisSize: style == _NodeStyle.pill
          ? MainAxisSize.min
          : MainAxisSize.max,
      children: [
        if (style == _NodeStyle.grouped) ...[
          Text(
            appLocalizations.currentSelection,
            style: context.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
        Flexible(
          fit: isPlain ? FlexFit.tight : FlexFit.loose,
          child: EmojiText(
            nodeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: isPlain ? null : FontWeight.w600,
            ),
          ),
        ),
        if (delay != null) ...[
          const SizedBox(width: 8),
          Text(
            delay > 0 ? '$delay ms' : 'Timeout',
            style: context.textTheme.labelSmall?.copyWith(
              color: utils.getDelayColor(delay),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );
    if (isPlain) return _TapArea(onTap: onTap, child: row);
    final radius = BorderRadius.circular(10);
    return Material(
      color: colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: row,
        ),
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  final double value;
  final double height;

  const _UsageBar({required this.value, required this.height});

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    final radius = BorderRadius.circular(height / 2);
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        height: height,
        alignment: Alignment.centerLeft,
        color: primary.withValues(alpha: 0.15),
        child: FractionallySizedBox(
          widthFactor: value,
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(color: primary, borderRadius: radius),
          ),
        ),
      ),
    );
  }
}

class _SegmentBar extends StatelessWidget {
  final List<double> segments;
  final double height;

  const _SegmentBar({required this.segments, required this.height});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (index, segment) in segments.indexed) ...[
          if (index > 0) const SizedBox(width: 3),
          Expanded(
            child: _UsageBar(value: segment, height: height),
          ),
        ],
      ],
    );
  }
}

class _UsageRing extends StatelessWidget {
  final List<double> segments;

  const _UsageRing({required this.segments});

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    return CustomPaint(
      painter: _UsageRingPainter(
        segments: segments,
        color: primary,
        trackColor: primary.withValues(alpha: 0.15),
      ),
    );
  }
}

class _UsageRingPainter extends CustomPainter {
  final List<double> segments;
  final Color color;
  final Color trackColor;

  const _UsageRingPainter({
    required this.segments,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 5.0;
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final isMulti = segments.length > 1;
    Paint stroke(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = isMulti ? StrokeCap.butt : StrokeCap.round;
    final track = stroke(trackColor);
    final fill = stroke(color);
    if (segments.isEmpty) {
      canvas.drawArc(rect, 0, math.pi * 2, false, track);
      return;
    }
    final gap = isMulti ? 0.14 : 0.0;
    final sweep = (math.pi * 2 - gap * segments.length) / segments.length;
    var start = -math.pi / 2 + gap / 2;
    for (final segment in segments) {
      canvas.drawArc(rect, start, sweep, false, track);
      if (segment > 0) {
        canvas.drawArc(rect, start, sweep * segment, false, fill);
      }
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(_UsageRingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      !listEquals(oldDelegate.segments, segments);
}

class _GroupProxySheet extends ConsumerWidget {
  final SheetType type;
  final String groupName;

  const _GroupProxySheet({required this.type, required this.groupName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(getProxyNameProvider(groupName), (previous, next) {
      if (previous == next || !context.mounted) return;
      Navigator.of(context).pop();
    });
    final group = ref.watch(
      groupsProvider.select((groups) => groups.getGroup(groupName)),
    );
    final proxies = ref.watch(sortedGroupProxiesProvider('', groupName)) ?? [];
    final (cardType, layout) = ref.watch(
      proxiesStyleSettingProvider.select(
        (state) => (state.cardType, state.layout),
      ),
    );
    return AdaptiveSheetScaffold(
      type: type,
      title: groupName,
      actions: [
        if (group != null)
          AnimatedBuilder(
            animation: delayTestCoordinator,
            builder: (_, _) => IconButton(
              tooltip: appLocalizations.startTest,
              onPressed: delayTestCoordinator.isTesting
                  ? null
                  : () => delayTest(
                      group.all,
                      testUrl: group.testUrl,
                      groupName: group.name,
                    ),
              icon: const Icon(Icons.network_ping),
            ),
          ),
      ],
      body: group == null
          ? const SizedBox.shrink()
          : LayoutBuilder(
              builder: (_, constraints) => GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  16 + MediaQuery.paddingOf(context).bottom,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: math.max(
                    1,
                    utils.getProxiesColumns(constraints.maxWidth, layout),
                  ),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: getItemHeight(cardType),
                ),
                itemCount: proxies.length,
                itemBuilder: (_, index) => ProxyCard(
                  key: ValueKey(proxies[index].name),
                  testUrl: group.testUrl,
                  groupType: group.type,
                  type: cardType,
                  proxy: proxies[index],
                  groupName: group.name,
                ),
              ),
            ),
    );
  }
}

class _ProfileSwitchList extends ConsumerWidget {
  const _ProfileSwitchList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider);
    final currentProfileId = ref.watch(currentProfileIdProvider);
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: profiles.length,
      itemBuilder: (_, index) {
        final profile = profiles[index];
        return _ProfileSwitchItem(
          key: ValueKey(profile.id),
          profile: profile,
          selected: profile.id == currentProfileId,
          onTap: () {
            if (profile.id != currentProfileId) {
              ref.read(currentProfileIdProvider.notifier).value = profile.id;
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class _ProfileSwitchItem extends StatelessWidget {
  final Profile profile;
  final bool selected;
  final VoidCallback onTap;

  const _ProfileSwitchItem({
    super.key,
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final usage = ProfileUsage.of(profile);
    final segments = usage?.segments ?? [];
    final subtitle = usage != null
        ? [usage.usageText, ?usage.expireText].join(' · ')
        : profile.type == ProfileType.file
        ? [
            appLocalizations.localFile,
            ?profile.lastUpdateDate?.lastUpdateTimeDesc,
          ].join(' · ')
        : appLocalizations.noUsageData;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 21,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EmojiText(
                        profile.label ?? profile.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: usage?.isExpired == true
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (segments.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _SegmentBar(segments: segments, height: 3),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
