import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/pages/pages.dart';
import 'package:bett_box/providers/providers.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';

class MediaUnlock extends ConsumerStatefulWidget {
  const MediaUnlock({super.key});

  @override
  ConsumerState<MediaUnlock> createState() => _MediaUnlockState();
}

class _MediaUnlockState extends ConsumerState<MediaUnlock> {
  String _getStatusText(MediaUnlockStatus status, [MediaPlatform? platform]) {
    switch (status) {
      case MediaUnlockStatus.unlocked:
        if (platform?.category == MediaCategory.streaming) {
          return appLocalizations.mediaUnlocked;
        }
        return appLocalizations.unlocked;
      case MediaUnlockStatus.limited:
        if (platform?.category == MediaCategory.streaming) {
          return appLocalizations.limitedUnlock;
        }
        return appLocalizations.flagged;
      case MediaUnlockStatus.flagged:
        return appLocalizations.flagged;
      case MediaUnlockStatus.blocked:
        return appLocalizations.notUnlocked;
      case MediaUnlockStatus.failed:
        return appLocalizations.checkFailed;
      case MediaUnlockStatus.testing:
        return '...';
      case MediaUnlockStatus.unknown:
        return '-';
    }
  }

  Widget _buildLatencyBar(
    MediaUnlockStatus status,
    int? latency,
    BuildContext context,
  ) {
    if (status == MediaUnlockStatus.testing) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(3.ap),
        child: SizedBox(
          height: 6.ap,
          child: LinearProgressIndicator(
            backgroundColor:
                context.colorScheme.primary.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(
              context.colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    final double widthFactor;
    if (latency != null && latency > 0) {
      widthFactor = (0.10 + (latency / 1000) * 0.90).clamp(0.10, 1.0);
    } else {
      widthFactor = 0.0;
    }

    return Container(
      height: 6.ap,
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3.ap),
      ),
      alignment: Alignment.centerLeft,
      child: widthFactor > 0
          ? FractionallySizedBox(
              widthFactor: widthFactor,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(3.ap),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildPlatformRow(
    MediaPlatform platform,
    MediaUnlockResult? result,
    bool isLoading,
    BuildContext context, {
    bool isItemTesting = false,
    required bool colorfulIcons,
  }) {
    final isTesting = isItemTesting ||
        (isLoading &&
            (result == null || result.status == MediaUnlockStatus.testing));
    final status = isTesting
        ? MediaUnlockStatus.testing
        : (result?.status ?? (isLoading ? MediaUnlockStatus.testing : MediaUnlockStatus.unknown));
    final color = status.statusColor(context.colorScheme);
    final latency = result?.latency;
    final String statusDisplay;
    if (status == MediaUnlockStatus.unknown) {
      statusDisplay = '-';
    } else if (status == MediaUnlockStatus.testing) {
      statusDisplay = '...';
    } else if (status == MediaUnlockStatus.limited) {
      statusDisplay = platform.category == MediaCategory.streaming
          ? appLocalizations.limitedUnlock
          : appLocalizations.flagged;
    } else if (status == MediaUnlockStatus.flagged) {
      statusDisplay = appLocalizations.flagged;
    } else if (latency != null) {
      statusDisplay = '${latency}ms';
    } else {
      statusDisplay = _getStatusText(status, platform);
    }

    final isError = status == MediaUnlockStatus.blocked ||
        status == MediaUnlockStatus.failed;

    final iconSize = platform.iconSize;
    final Widget icon;
    if (platform.isMonochrome) {
      icon = SvgPicture.asset(
        'assets/images/platforms/${platform.name}.svg',
        width: iconSize.width.ap,
        height: iconSize.height.ap,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          context.colorScheme.onSurfaceVariant,
          BlendMode.srcIn,
        ),
      );
    } else if (colorfulIcons) {
      icon = SvgPicture.asset(
        'assets/images/platforms/${platform.name}.svg',
        width: iconSize.width.ap,
        height: iconSize.height.ap,
        fit: BoxFit.contain,
      );
    } else {
      icon = ColorFiltered(
        colorFilter: monochromeColorFilter,
        child: SvgPicture.asset(
          'assets/images/platforms/${platform.name}.svg',
          width: iconSize.width.ap,
          height: iconSize.height.ap,
          fit: BoxFit.contain,
        ),
      );
    }

    return SizedBox(
      key: ValueKey(platform),
      height: 24.ap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.ap,
            height: 20.ap,
            child: Center(child: icon),
          ),
          SizedBox(width: 8.ap),
          SizedBox(
            width: 64.ap,
            child: Text(
              platform.defaultName,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12.ap,
                color: context.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 6.ap),
          SizedBox(
            width: 8.ap,
            height: 20.ap,
            child: Center(
              child: Container(
                width: 6.ap,
                height: 6.ap,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.ap),
          Expanded(
            child: _buildLatencyBar(status, latency, context),
          ),
          SizedBox(width: 10.ap),
          SizedBox(
            width: 52.ap,
            child: Text(
              statusDisplay,
              textAlign: TextAlign.right,
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11.5.ap,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: isError
                    ? context.colorScheme.error
                    : context.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinned = ref.watch(
      appSettingProvider.select((state) => state.pinnedMediaPlatforms),
    );
    final colorfulIcons = ref.watch(
      appSettingProvider.select((state) => state.mediaUnlockColorfulIcons),
    );
    final displayedPlatforms =
        (pinned.isNotEmpty ? pinned : defaultPinnedMediaPlatforms)
            .take(4)
            .toList();

    return SizedBox(
      height: getWidgetHeight(2),
      child: ValueListenableBuilder<MediaUnlockState>(
        valueListenable: mediaUnlockState.state,
        builder: (context, state, _) {
          final isWidgetLoading =
              displayedPlatforms.any(state.testingPlatforms.contains);
          return CommonCard(
            onPressed: () {
              showExtend(
                context,
                builder: (_, type) => MediaUnlockPage(type: type),
              );
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.ap, 10.ap, 8.ap, 6.ap),
                  child: Row(
                    children: [
                      Icon(
                        Icons.link_rounded,
                        size: 18.ap,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appLocalizations.mediaUnlock,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 24.ap,
                        height: 24.ap,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: isWidgetLoading
                              ? null
                              : () => mediaUnlockState.checkPlatforms(
                                    displayedPlatforms,
                                    force: true,
                                  ),
                          icon: isWidgetLoading
                              ? SizedBox(
                                  width: 13.ap,
                                  height: 13.ap,
                                  child: SpinKitRing(
                                    color: context.colorScheme.primary,
                                    lineWidth: 1.5,
                                    size: 13.ap,
                                  ),
                                )
                              : Icon(
                                  Icons.sync,
                                  size: 16.ap,
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.ap),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: context.colorScheme.outlineVariant.withValues(
                      alpha: 0.2,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.ap, 6.ap, 16.ap, 8.ap),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final p in displayedPlatforms)
                          _buildPlatformRow(
                            p,
                            state.results[p],
                            state.isLoading,
                            context,
                            isItemTesting:
                                state.testingPlatforms.contains(p),
                            colorfulIcons: colorfulIcons,
                          ),
                      ],
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
